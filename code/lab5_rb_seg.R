# ==========================================================================
# Lab 5: Segregation, rent burden, and your final project
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# This is our last teaching lab -- next week is group work and presentations.
# Today two threads of the course meet:
#
#   1. You will measure racial SEGREGATION at the neighborhood level, using
#      the Eviction Research Network's own R package.
#   2. You will join it to the rent-burden measure you built in Lab 3 and
#      ask a real research question: do segregation and rent burden move
#      together?
#   3. You will look at MIGRATION data -- who left a county and where they
#      went -- and at the hard limits of what it can prove.
#   4. You will get your results OUT of R -- as a file any tool can read --
#      and learn two ways to publish a map of them.
#   5. You will leave with a final-project checklist that points every task
#      in the prompt back to the lab section that teaches it.
#
# WHERE WE ARE (the course toolkit so far)
#   Lab 1: run code, save objects, get_acs(), filter/arrange/select, ggplot
#   Lab 2: find any Census variable, pull many at once, mutate(), AMI tiers
#   Lab 3: counts vs. dollars, denominators, pivot_wider(), group_by() +
#          summarize(), your own rent-burden measure
#   Lab 4: outside data (evictions), joins, rates, and maps with tmap
#
# Today adds: a GitHub package, case_when(), get_flows(), write_csv(),
# publishing, and -- if time allows -- downloading a dataset off an
# agency's website yourself. After this you own a complete research
# pipeline.
#
# NEW FUNCTIONS IN THIS LAB, and the line where each is introduced. If one
# looks unfamiliar mid-lab, jump to that line -- it is where the lab
# teaches it. (All of them are on the course cheat sheet too,
# code/r_functions_cheatsheet.R.)
#
#   remotes::install_github()  L81   install a package from GitHub
#   ntdf()                     L167  ERN's neighborhood segregation types
#   count()                    L189  group and tally in one move
#   levels()                   L203  a factor's categories, in stored order
#   case_when()                L268  many-way recode (if_else's big sibling)
#   read_csv()                 L598  read a CSV, from a file or a URL
#   dim()                      L600  rows and columns at once
#   str_pad()                  L619  pad an ID back to its full width
#   round()                    L710  round numbers
#   get_flows()                L742  ACS migration flows between counties
#   nchar()                    L775  how many characters a value has
#   abs()                      L805  drop the minus sign, to sort by size
#   scales::comma_format()     L822  axis numbers with thousands commas
#   scale_fill_manual()        L823  pick which category gets which color
#   dir.create()               L900  make a folder
#   write_csv()                L904  save a table as a CSV
#   options()                  L958  change an R setting for this session
#   tm_fill()                  L970  map fill without borders

# ==========================================================================
# 0. Packages -- including your first GitHub package
# ==========================================================================
# Our usual toolboxes first:

library(tidyverse)
library(tidycensus)

# Now something new. Most packages live on CRAN, R's official library, and
# install with install.packages(). But researchers often share packages
# straight from GitHub, the website where code projects live. My lab -- the
# Eviction Research Network -- shares its "neighborhood" package there.
#
# Getting a GitHub package takes two one-time steps. First, install the
# CRAN package "remotes", whose job is fetching packages from GitHub
# (RUN ONCE, then put a # in front of it):

install.packages("remotes")

# Second, use remotes to fetch the neighborhood package from the
# evictionresearch account on GitHub (RUN ONCE as well -- it prints a lot
# of text while it builds, and that is normal):

remotes::install_github("evictionresearch/neighborhood")

# The remotes:: prefix means "use the install_github tool from the remotes
# toolbox without opening the whole toolbox." You will see this
# package::function() style often in other people's code.
#
# Installed? Then open it like any other package (EVERY session):

library(neighborhood)

# ==========================================================================
# 1. Rebuild the rent-burden measure (Lab 3, from memory to muscle)
# ==========================================================================
# Quick reprise -- this is exactly the measure you built in Lab 3, so we
# move fast. If any step feels foggy, revisit Lab 3 for the slow version.
# We use Alameda County (Berkeley and Oakland's county) so the
# results are about the place many of you are sitting in.
#
# Table B25070: renter households by rent-as-a-share-of-income bracket.
# Burdened = paying 30% or more, so we need the 30%+ brackets and the
# all-renters total (the DENOMINATOR -- always table line _001):

rb_vars <- c(
  "B25070_001",  # Total renter households  <- the universe (denominator)
  "B25070_007",  # paying 30.0 to 34.9 percent of income
  "B25070_008",  # paying 35.0 to 39.9 percent
  "B25070_009",  # paying 40.0 to 49.9 percent
  "B25070_010"   # paying 50.0 percent or more (extreme burden)
)

rb_raw <- get_acs(
  geography = "tract",       # neighborhoods, not whole counties
  variables = rb_vars,
  state     = "CA",
  county    = "Alameda",
  year      = 2024
)

# Reshape long to wide and compute the share (Lab 3's pivot_wider move --
# we keep just three columns first so each tract collapses to one row):

rent_burden <- rb_raw %>%
  select(GEOID, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb     = rb_count / B25070_001
  )

# Meet the result:

nrow(rent_burden)       # 379 tracts in Alameda County (as of the 2024 ACS)
summary(rent_burden$p_rb)

# Read that summary line out loud: the median tract's share is about 0.47.
# In HALF of Alameda County's neighborhoods, at least ~47% of renter
# households are rent-burdened. Also notice: 2 NA's. Two tracts have no
# renter households to measure (one is mostly open water on the Bay --
# the same two edge-case tracts you met in Lab 3). Real data always
# has edges like this; we will handle them at the join step.

# ==========================================================================
# 2. Measuring segregation: the neighborhood package
# ==========================================================================
# How do you turn "who lives in this tract" into a MEASURE? The method in
# ERN's neighborhood package comes from published sociology (Hall, Crowder,
# and Spring 2015, American Sociological Review 80:526-549) and works like
# a recipe:
#
#   1. For each tract, get the share of residents who are White, Black,
#      Asian, Latine, or Other (from Census table B03002 -- race by
#      Hispanic/Latino ethnicity, so the groups do not overlap).
#   2. Any group making up at least 10% of the tract "counts" as a
#      meaningful presence.
#   3. Name the tract by the groups that count: a tract at least 10% Black
#      and at least 10% Latine (and under 10% everything else) is
#      "Black-Latine". A tract 90%+ one group is "All" that group.
#
# ("Latine" is the gender-neutral form ERN uses -- same population the
# Census labels "Hispanic or Latino.")
#
# The function ntdf() -- "neighborhood type data frame" -- runs that whole
# recipe for you: it downloads the race data and returns one row per tract.
# One call, three inputs you already know from get_acs(). (We go straight
# to a single county: a whole state of tracts is a big download.)

seg <- ntdf(
  state  = "CA",
  county = "Alameda",
  year   = 2024
)

# Meet the data:

glimpse(seg)

# Column tour:
#   GEOID     = the tract ID -- SAME format as our Census pulls (11 digits:
#               state 06 + county 001 + tract). That is what makes the
#               join below possible.
#   pWhite, pBlack, pAsian, pLatine, pOther = each group's share (0 to 1)
#   NeighType = the full recipe name ("Black-Latine-White", ...)
#   nt_conc   = the same thing CONCatinated into fewer, chart-friendly
#               categories ("3 Group Mixed", "Mostly White", ...)
#
# How segregated is Alameda County? Count tracts by type:

seg %>%
  count(nt_conc, sort = TRUE)

# When we ran this (August 2026): "3 Group Mixed" led with 177 tracts, then
# "4 Group Mixed" (92) and "Asian-White" (37) -- and 13 "Black-Latine"
# tracts where White and Asian residents are each under 10%. Even in a
# county famous for diversity, many neighborhoods are missing whole
# groups. That IS segregation, measured.
#
# ONE MORE THING ABOUT THIS COLUMN, and it is your first look at a data
# type you will meet constantly. nt_conc is not plain text. It is a
# FACTOR -- R's type for a column whose values come from a fixed, known
# list of categories. A factor remembers that list, in a set order, even
# for categories that never show up in your county. levels() shows it:

levels(seg$nt_conc)

# Nineteen categories, and look at the sequence: the five single-group
# types first ("Mostly Asian" through "Mostly White"), then every
# two-group pair, then "3 Group Mixed", "4 Group Mixed", "Diverse", and
# finally "Unpopulated Tract". That is not alphabetical. My lab built the
# list to run from the most concentrated neighborhoods to the most
# mixed, and every tract in the country gets sorted into it.
#
# Two things follow from that, both useful:
#
#   - Your count() above returned 13 rows, not 19. Six categories have no
#     Alameda tracts at all -- no "Mostly Black" tract, for one. The factor
#     still knows those categories exist; count() just does not print
#     empty ones. The absence is a finding, and you only see it by
#     comparing levels() to your counts.
#   - Anything R sorts by this column follows the level order, not the
#     dictionary. That is the point of a factor.
#
# (The package also has a helper, ntcheck(seg), that tabulates the finer
# NeighType labels -- and if you are curious after class, ask me about
# nt_map(), the one-line interactive map my lab uses on these objects.)

# ==========================================================================
# 3. A new verb: case_when(), for many-way recodes
# ==========================================================================
# FIRST, THREE WORDS WE HAVE USED ALL TERM WITHOUT SAYING THEM. Section 2
# just handed you a column that behaves nothing like the ones you know.
#
#   CONTINUOUS   a number whose arithmetic means something -- p_rb (0.42),
#                median rent ($2,335). Average it, put it on a scaled axis.
#   CATEGORICAL  a label that sorts rows into buckets -- nt_conc, county.
#                Count it, group by it. You cannot average it.
#   ORDINAL      categories with an ORDER but no guaranteed spacing --
#                "Low" < "Medium" < "High". Treat it as categorical unless
#                you have a reason not to, and say so in your writeup.
#
# Everything you built before tonight was continuous; nt_conc is one of your first
# categorical columns, Counties is another. These types also pick
# your chart. Tonight's question is one continuous variable split by one
# categorical, which is exactly why section 5 reaches for bars and a boxplot
# and never once for a scatter.
#
# (A caution that pays off below. nt_conc arrived as a factor, so it carries
# the level order you just printed. The case_when() recode you are about to
# write hands back plain TEXT, and text has no order -- R falls back to
# alphabetical for anything built from it. Section 5 sidesteps that by
# sorting its bars with reorder(); when you want a specific order instead,
# factor(x, levels = c(...)) is how you put one back.)
#
# Now the verb itself.
#
# In Lab 3 you met if_else(): ONE yes/no question. case_when() is its big
# sibling: MANY questions, checked top to bottom, first match wins.
#
# Why we need it here: thirteen categories make an unreadable chart, and
# several of them are carrying two or three tracts. We are going to MERGE,
# in two moves.
#
# MERGE ONE, the easy one. "3 Group Mixed", "4 Group Mixed", and "Diverse"
# all say the same thing -- no single group dominates -- so they become one
# label. Start with case_when() in its smallest form: one rule, plus a
# catch-all:

seg %>%
  mutate(nt_group = case_when(
    nt_conc == "3 Group Mixed" ~ "Mixed (3+ groups)",
    TRUE ~ nt_conc
  )) %>%
  count(nt_group, sort = TRUE)

# Anatomy: each line is  condition ~ new_value.  The ~ separates the
# question (left) from the answer (right). The final line, TRUE ~ nt_conc,
# is the catch-all: "for every row nothing above matched, keep what
# nt_conc already says."
#
# MERGE TWO, and this one is a judgment call rather than a rule. Look back
# at your count. Alameda has 37 Asian-White tracts and 17 Asian-Latine
# tracts, enough to say something about either one. It also has 6
# Latine-White, 2 Asian-Other, and 2 Other-White. Those are all TWO-GROUP
# neighborhoods, and one at a time they are far too thin to chart. So
# instead of dropping them, pool them into a single bucket that keeps their
# tracts in the analysis.
#
# WHY YOU CANNOT JUST COPY MY LIST. Which categories come out small depends
# entirely on WHERE you are, because segregation has a geography. You will
# not find many "Mostly Black" neighborhoods in the Pacific Northwest; you
# will find plenty of them in the Southeast. A place's racial composition
# and its particular history of segregation decide which categories fill up
# and which stay nearly empty. The three names below are ALAMEDA's small
# types. Run the count for your own county and you will get a different
# list, and that difference is itself a finding worth a sentence.
#
# Now the full recode. %in% (lab 4) is the compact way to write "any of
# these," so one line does the work of three separate == lines:

seg_grouped <- seg %>%
  mutate(nt_group = case_when(
    nt_conc %in% c("3 Group Mixed", "4 Group Mixed", "Diverse")  ~ "Mixed (3+ groups)",
    nt_conc %in% c("Latine-White", "Asian-Other", "Other-White") ~ "Other 2 Group Mixed",
    TRUE ~ nt_conc
  ))

seg_grouped %>%
  count(nt_group, sort = TRUE)

# "Other 2 Group Mixed" lands at 10 tracts: three categories too small to
# stand alone, together just big enough to keep. Notice what that label
# does NOT claim. Asian-White and Black-Latine are two-group types too, and
# they kept their own names because they had the tracts to earn them.
# Pooling is for the ones that would otherwise vanish.
#
# Order matters in case_when(): rows are tested from the top, and a row
# takes the FIRST answer whose condition is true. Keep your most specific
# rules first and the TRUE catch-all last.

# YOUR TURN (1): add one more rule to the case_when() above that renames
# "Asian-White" to a label of your choosing, and re-run the count. Which
# line did you add, and where?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 4. Join: rent burden meets segregation
# ==========================================================================
# Lab 4's move: left_join() glues two tables together by a shared ID
# column. Left join = keep every row of the LEFT (first) table, attach
# matching columns from the right. Both tables carry the same 11-digit
# tract GEOID, so:

rb_seg_all <- rent_burden %>%
  left_join(seg_grouped, by = "GEOID")

# ALWAYS check a join before trusting it. Three questions, three lines:

rb_seg_all
glimpse(rb_seg_all)            # rb_seg_all is too big so we use glimpse
nrow(rent_burden)              # rows going in: 379
nrow(rb_seg_all)               # rows coming out: must still be 379
sum(is.na(rb_seg_all$nt_group))  # tracts that failed to match: want 0

# When we ran this: 379, 379, 0. A perfect match -- every tract in the
# rent-burden table found its segregation type. If YOUR numbers disagree
# (rows appearing, disappearing, or failing to match), stop and look:
# join problems are the most common silent error in data work.
#
# Now clean the edges we spotted earlier: drop the tracts with no renters
# (p_rb was NA) and the "Unpopulated Tract" type in one filter (the comma
# means AND):

rb_seg <- rb_seg_all %>%
  filter(!is.na(p_rb), NeighType != "Unpopulated Tract")

nrow(rb_seg)               # 377 -- we knowingly dropped 2 empty tracts

# Note the habit: we did not delete data silently. We looked, counted,
# decided, and wrote the reason down. Your future collaborators (and
# graders) will thank you.
#
# And notice the NAMING habit, which matters just as much. The filtered
# table got a NEW name; we did not write rb_seg <- rb_seg %>% filter(...)
# and paint over the original. Overwriting an object destroys the thing you
# would need to check the change against, and it makes a script impossible
# to re-run from the middle -- run that line twice and the second pass is
# filtering something already filtered. One object, one meaning, all the
# way down. Keep rb_seg_all and you can always answer "what did I drop?"

# ==========================================================================
# 5. The question: does rent burden differ by neighborhood type?
# ==========================================================================
# Lab 3's summary move, applied to today's question -- for each
# neighborhood type, how many tracts are there and what is the median
# rent-burden share?

rb_by_type <- rb_seg %>%
  group_by(nt_group) %>%
  summarize(
    n_tracts  = n(),
    median_rb = median(p_rb)
  ) %>%
  arrange(desc(median_rb))

rb_by_type

# Before charting, a data-humility check straight out of Lab 1: even after
# Section 3's merges, two types are down to 3 tracts each. A "median" of
# three tracts is barely a median at all. So we chart only the types with a
# real base -- at least 10 tracts:
#
# (Two answers to the same small-n problem, and you have now used both.
# Section 3 MERGED the categories that could sensibly be pooled; this
# filter DROPS the ones that could not. "Mostly Latine" and "Mostly White"
# mean opposite things, so pooling them would invent a category nobody
# lives in. When in doubt, merge what belongs together and drop the rest.)

rb_by_type_solid <- rb_by_type %>%
  filter(n_tracts >= 10)

rb_by_type_solid

# The chart itself is pure Lab 1: ordered bars. (One reminder beat:
# reorder() sorts the category labels by their values.) And bring back
# Lab 3's axis-dressing line, scale_x_continuous(labels =
# scales::percent_format()), so the axis writes 0.4 as 40%. House rule
# from here to your final slides: every axis names its units --
# percent_format(), dollar_format(), or comma_format() for big counts
# -- so readers never have to guess what 0.4 means.

ggplot(rb_by_type_solid, aes(x = median_rb, y = reorder(nt_group, median_rb))) +
  geom_col(fill = "steelblue") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(
    title    = "Rent burden is highest in Alameda's Black-Latine neighborhoods",
    subtitle = "Median tract share of renter households paying 30%+ of income, 2020-2024 ACS",
    x        = "Median rent-burdened share",
    y        = NULL,
    caption  = "Source: ACS 5-year + ERN neighborhood package. Types with 10+ tracts."
  ) +
  theme_minimal()

# When we ran this, Black-Latine tracts topped the chart (median share
# about 55%) and majority-Asian tracts sat lowest (about 32%) -- in the
# same county, the typical neighborhood's rent-burden rate swings by more
# than 20 percentage points depending on who lives there. That is the
# course thesis in one picture: housing precarity is racially structured.
#
# Notice the title: it states the FINDING, not the topic. "Rent burden by
# neighborhood type" is a label; a claim your reader can check against the
# bars is a story. And keep my plot rule in mind for your projects:
# 2-3 ideas per chart, no more. If a plot needs a paragraph to decode,
# split it into two plots.

# --------------------------------------------------------------------------
# 5.1 The boxplot again: the spread behind the medians
# --------------------------------------------------------------------------
# The bar chart shows one number (the median) per type. Lab 3's chart
# card says the shape for "compare whole spreads across groups" is the
# BOXPLOT -- box = middle 50% of tracts, middle line = median, whiskers =
# the typical range, dots = outlier tracts. Same move as lab 3's
# three-county boxes, with one new trick in the reorder:

rb_seg %>%
  filter(nt_group %in% rb_by_type_solid$nt_group) %>%   # the 10+ types only
  ggplot(aes(x = p_rb, y = reorder(nt_group, p_rb, FUN = median))) +
  geom_boxplot(fill = "steelblue") +
  scale_x_continuous(labels = scales::percent_format()) +   # house rule
  labs(
    title    = "The spread behind the medians",
    subtitle = "Tract-level rent-burdened share by neighborhood type, Alameda County",
    x        = "Share of renter households rent-burdened",
    y        = NULL,
    caption  = "Source: ACS 5-year + ERN neighborhood package. Types with 10+ tracts."
  ) +
  theme_minimal()

# Two notes:
#   - reorder(..., FUN = median) sorts the boxes by each group's median
#     (reorder's usual sorting is by the mean; we say median explicitly).
#   - See the dots pinned at 0% and at 100%? Tracts where a handful
#     of renter households make the share jump to extremes -- small
#     denominators again, Lab 1's margin-of-error lesson wearing a new
#     costume. The box, not the dots, is the story.

# YOUR TURN (2): in a comment, answer in two sentences: what does the
# boxplot show that the bar chart hides, and when would you choose each
# for a presentation slide?
# [PUT YOUR ANSWER BELOW]
#

# --------------------------------------------------------------------------
# 5.2 Two kinds of burden, side by side: geom_col(position = "dodge")
# --------------------------------------------------------------------------
# One last chart move for the course, and the segregation story earns it.
# Our p_rb lumps every burdened household together -- the one paying 32%
# of income with the one paying 60%. Lab 3's table tour drew a line
# inside B25070: brackets _007 to _009 are 30-49.9% of income (call it
# MODERATE burden), bracket _010 is 50%+ -- SEVERE burden, rent
# swallowing half the household's income. So far we charted their sum.
# The sharper question: does segregation shape the two the same way?
#
# That takes TWO numbers per neighborhood type, side by side. Build the
# table first -- every verb here is an old friend, and the B25070
# bracket columns are still sitting in rb_seg from Section 1's
# pivot_wider:

rb_levels <- rb_seg %>%
  filter(nt_group %in% rb_by_type_solid$nt_group) %>%   # the 10+ types again
  mutate(
    p_moderate = (B25070_007 + B25070_008 + B25070_009) / B25070_001,
    p_severe   = B25070_010 / B25070_001
  ) %>%
  group_by(nt_group) %>%
  summarize(
    median_moderate = median(p_moderate),
    median_severe   = median(p_severe)
  )

rb_levels

# Six rows, two number columns. But ggplot wants one row PER BAR, and
# we want twelve bars. Lab 4's pivot_longer() -- pivot_wider's return trip
# -- stacks the two columns into one, and case_when(), hired back in
# Section 3, turns the column names into legend-ready labels:

rb_levels_long <- rb_levels %>%
  pivot_longer(-nt_group,
               names_to = "burden_level", values_to = "median_share") %>%
  mutate(burden_level = case_when(
    burden_level == "median_moderate" ~ "Moderate (30-49.9%)",
    burden_level == "median_severe"   ~ "Severe (50%+)"
  ))

rb_levels_long            # 12 rows: 6 types x 2 burden levels. Twelve bars.

# Now the chart. In Lab 3 (section 15.4) you put color INSIDE aes() and
# got one line per county, plus a legend, for free. Same move for bars,
# with fill (bars are colored by fill; lines by color):

ggplot(rb_levels_long,
       aes(x = median_share, y = reorder(nt_group, median_share),
           fill = burden_level)) +
  geom_col()

# A legend, two colors... but R STACKED each pair, gluing moderate and
# severe end to end. That is geom_col()'s default when two bars land on
# the same row -- position = "stack" -- and it answers "how do the
# pieces add up to a total?" Not today's question (and quietly wrong
# for it here: the stacked pairs look like Section 5's totals, but
# medians of parts do not sum exactly to the median of the whole).
#
# Today's question is "compare the pieces TO EACH OTHER," and its
# position is "dodge" -- as in step aside: every bar gets its own slot,
# shoulder to shoulder:

ggplot(rb_levels_long,
       aes(x = median_share, y = reorder(nt_group, median_share),
           fill = burden_level)) +
  geom_col(position = "dodge") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(
    title    = "The racial gap in rent burden is mostly a severe-burden gap",
    subtitle = "Median tract share of renters at each burden level, 2020-2024 ACS",
    x        = "Median share of renter households",
    y        = NULL,
    fill     = NULL,
    caption  = "Source: ACS 5-year + ERN neighborhood package. Types with 10+ tracts."
  ) +
  theme_minimal()

# Read it pair by pair. When we ran this, the MODERATE bars barely
# moved: every neighborhood type sits between about 19% and 24%. The
# SEVERE bars are where segregation shows: about 11% in Mostly Asian
# tracts and 13% in Asian-White tracts, but 34% in Black-Latine
# tracts -- three times as high, and the one type where severe burden
# towers over moderate, at nearly half again its size. Section 5's
# twenty-plus-point swing was never "a few more households just over
# the 30% line." It is the deep end -- households handing over HALF
# their income -- that is racially sorted. One argument, position =
# "dodge", and the finding sharpens from "burden differs by
# neighborhood" to "SEVERE burden is what differs."
#
# Add the row to Lab 3's chart card: compare a few groups on two
# measures each -> dodged bars. And mind the 2-3-ideas rule harder
# than ever here -- with dodging, every extra fill level multiplies
# the bars. Two levels read at a glance; four is a wall of stripes.

# --------------------------------------------------------------------------
# 5.3 OPTIONAL: going and getting outside data (pollution burden)
# --------------------------------------------------------------------------
#
# Every dataset you have used so far arrived through an R function:
# get_acs(), ntdf(). Most data in the world does not work that way. It sits
# on an agency's website as a file, and somebody has to go get it. Here is
# that whole skill on one dataset, because several of you asked what the
# environmental side of housing precarity looks like.
#
# THE SOURCE. CalEnviroScreen, from California's Office of Environmental
# Health Hazard Assessment. Version 5.0 came out in July 2026. It scores
# every census tract in the state on pollution exposure (ozone, PM2.5,
# diesel, traffic, drinking water, cleanup sites) and on how vulnerable
# the people living there are to it. Tract level -- which is the only
# reason we can join it to tonight's table.
#
# STEP 1, GET IT (three clicks, in your browser):
#   1. Go to  data.ca.gov/dataset/calenviroscreen-5-0
#   2. Click the resource named "CalEnviroScreen 5.0 CSV file"
#   3. Click Download. You get calenviroscreen50_070126.csv, about 7 MB.
#
# STEP 2, PUT IT ON THE DATAHUB. The file landed on YOUR computer. R is
# running on Berkeley's server, which cannot see your Downloads folder.
# In the Files pane (lower right): click into SOC-N100-Housing-Precarity-2026,
# then into data, then Upload > Choose File > pick the CSV > OK. That gap
# between "my laptop" and "the machine running R" catches everyone once.
#
# STEP 3, READ IT. Lab 4's readRDS() has a sibling for CSVs:

ces_raw <- read_csv("~/SOC-N100-Housing-Precarity-2026/data/calenviroscreen50_070126.csv")

dim(ces_raw)      # 9,106 tracts x 70 columns -- all of California

# (Upload not working? The line below fetches the same file straight from
# the state's server. Do the clicks at least once, though: most agencies
# are not this tidy, and knowing how to move a file yourself is the point.)
# ces_raw <- read_csv("https://data.ca.gov/dataset/72b28c84-ceac-4886-9f71-d422470d2223/resource/c4e277e0-cf23-4a8f-b07e-c8544c5d3d2b/download/calenviroscreen50_070126.csv")

# STEP 4, THE ID PROBLEM. This is the bug that eats outside data. Look at
# their tract IDs next to ours:

head(ces_raw$tract)

# 6001400100 -- ten digits. Ours are "06001400100", eleven. California's
# state code is 06, and this CSV stored the ID as a NUMBER, so R dropped
# the leading zero the way it would from 007. A text ID and a number ID
# never join, no matter how identical they look. str_pad() pads a value
# out to a fixed width with a character you choose:

ces <- ces_raw %>%
  mutate(GEOID = str_pad(tract, width = 11, side = "left", pad = "0"))

head(ces$GEOID)   # "06001400100" -- now it matches ours

# (Same naming habit as Section 4: the fixed table gets its own name
# instead of painting over ces_raw. If the pad ever goes wrong, the
# untouched original is still sitting there to compare against.)

# STEP 5, TAKE ONLY WHAT YOU NEED. Seventy columns is a lot to carry for
# one chart. We want PollutionP: this tract's pollution burden as a
# PERCENTILE among all California tracts. 90 means "more polluted than 90%
# of the state." 10 means cleaner than most.
#
# Why the pollution half and not CalEnviroScreen's headline score? Because
# the headline score has poverty, unemployment, AND housing burden folded
# into it. Correlate that with rent burden and you have partly correlated
# rent burden with itself. The environment-only column keeps the comparison
# honest -- worth a sentence in your writeup when you use an index someone
# else built.

ces_small <- ces %>%
  filter(county == "Alameda") %>%
  select(GEOID, PollutionP)

# STEP 6, JOIN -- and check it, the way section 4 taught you:

rb_seg_env <- rb_seg %>%
  left_join(ces_small, by = "GEOID")

nrow(rb_seg)                        # in:  377
nrow(rb_seg_env)                    # out: 377
sum(is.na(rb_seg_env$PollutionP))   # unmatched: 0

# STEP 7, THE CHART. One continuous variable split by one categorical --
# section 5's shape exactly, so this is that code with two words changed:

rb_seg_env %>%
  filter(nt_group %in% rb_by_type_solid$nt_group) %>%
  group_by(nt_group) %>%
  summarize(median_poll = median(PollutionP)) %>%
  ggplot(aes(x = median_poll, y = reorder(nt_group, median_poll))) +
  geom_col(fill = "darkolivegreen") +
  labs(
    title    = "The same neighborhoods carry the rent and the pollution",
    subtitle = "Median tract pollution-burden percentile, Alameda County",
    x        = "Statewide pollution-burden percentile (0-100)",
    y        = NULL,
    caption  = "Source: CalEnviroScreen 5.0 (OEHHA, 2026) + ERN neighborhood package."
  ) +
  theme_minimal()

# Notice what did NOT happen to that axis: no percent_format(). The house
# rule is that every axis names its units, and these units are RANKS. 65 is
# not "65% of" anything, so the axis label does the naming instead.
#
# When we ran this the order was Black-Latine (66th percentile), then
# Asian-Latine (56), Other 2 Group Mixed (52), Mixed (43), Asian-White
# (33), Mostly Asian (31). Set
# it beside section 5's bars: Black-Latine tracts top both charts. The
# neighborhoods paying the most rent relative to income are also breathing
# the most pollution.
#
# One caution before you write that up. That pattern is between neighborhood
# TYPES. Tract by tract the two measures barely track each other (their
# correlation is about 0.09). "Group medians differ" and "the two move
# together across tracts" are different claims, and only the first is on
# this chart. Say what you actually measured.

# ==========================================================================
# 6. Scaling up: your project region, county by county
# ==========================================================================
# Final projects compare places -- at least two counties. The same B25070
# build works at the county level: change geography, hand county= a
# VECTOR (Lab 1's c()!). Here: the nine-county Bay Area.

bay_counties <- c(
  "Alameda", "Contra Costa", "Marin", "Napa", "San Francisco",
  "San Mateo", "Santa Clara", "Solano", "Sonoma"
)

bay_rb <- get_acs(
  geography = "county",
  variables = rb_vars,
  state     = "CA",
  county    = bay_counties,
  year      = 2024
) %>%
  select(GEOID, NAME, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb_pct = round(100 * rb_count / B25070_001, 1)   # percent, for map legends
  )

bay_rb %>%
  select(NAME, p_rb_pct) %>%
  arrange(desc(p_rb_pct))

# Look at that ranking. When we ran it, SOLANO County -- the Bay Area's
# most affordable rents -- had the region's highest rent-burdened share
# (about 57%), and famously expensive San Francisco had the LOWEST (about
# 38%). Sound familiar? It is Lab 1's Humboldt lesson at county scale:
# burden is the ratio of rent to income, and it is worst where incomes
# lag, not where rents are highest. If your final project only maps rents,
# you will miss this entirely.

# --------------------------------------------------------------------------
# 6.1 Who left? A brief on migration data
# --------------------------------------------------------------------------
# Everything you have measured tonight is a SNAPSHOT of who is here now.
# Rent burden, segregation type, pollution -- all of it describes the
# people currently living in a tract.
#
# But displacement is about who LEFT. And the households pushed out of a
# neighborhood are, by definition, not in the rows describing that
# neighborhood anymore. A tract can look calm precisely because the people
# under the most pressure are already gone. Every measure in this course
# has that blind spot, and migration data is the closest thing we have to
# looking into it.
#
# THE FUNCTION. tidycensus has a second data-getter you have not met:
# get_flows(). Same shape as get_acs() -- geography, state, county, year:

flows_alameda <- get_flows(
  geography = "county",
  state     = "CA",
  county    = "Alameda",
  year      = 2020
)

# A VINTAGE WARNING, and it is a real one. Everything else in this lab uses
# year = 2024. This line cannot. The Census publishes these flows on a long
# lag, and as of August 2026 asking for a newer year still returns flows to
# STATES rather than to individual counties -- which would break the whole
# point below. So: county-to-county tops out at 2020 (the 2016-2020 ACS),
# and that window straddles the start of the pandemic. Check for a newer
# vintage when you use this in your project, and name the years you used.
#
# What came back:

flows_alameda %>%
  count(variable)

# Three variables, one row each per PARTNER place:
#
#   MOVEDIN   people who moved from that place TO Alameda
#   MOVEDOUT  people who moved from Alameda TO that place
#   MOVEDNET  MOVEDIN minus MOVEDOUT (positive = Alameda gained)
#
# AN ID TRICK. Place IDs have lengths, and the length tells you what KIND
# of place you are looking at. Here: 5 digits is
# a U.S. county, 10 digits is a Connecticut town (that state reports towns
# instead of counties), and a missing GEOID2 is a world region like "Asia."
# nchar() counts the characters in a value, so this keeps counties only:

flows_counties <- flows_alameda %>%
  filter(nchar(GEOID2) == 5)

# Where did people GO? Sort the outflows:

flows_counties %>%
  filter(variable == "MOVEDOUT") %>%
  arrange(desc(estimate)) %>%
  select(FULL2_NAME, estimate, moe) %>%
  head(6)

# And where did they COME FROM?

flows_counties %>%
  filter(variable == "MOVEDIN") %>%
  arrange(desc(estimate)) %>%
  select(FULL2_NAME, estimate, moe) %>%
  head(6)

# Read those two lists together before charting anything. Contra Costa is
# the number-one DESTINATION (about 16,500 people) and also the number-three
# ORIGIN (about 7,800). Santa Clara is on both lists too. Movement between
# neighboring counties is enormous in both directions at once -- which is
# exactly why the gross numbers cannot tell you the story by themselves.
# The NET is where the direction shows up.
#
# Twelve biggest net flows, in either direction. abs() strips the minus
# sign so we sort by SIZE, and if_else() (Lab 3) labels the direction:

net_biggest <- flows_counties %>%
  filter(variable == "MOVEDNET") %>%
  arrange(desc(abs(estimate))) %>%
  head(12) %>%
  mutate(direction = if_else(estimate > 0, "Alameda gained", "Alameda lost"))

net_biggest %>%
  select(FULL2_NAME, estimate, moe, direction)

# The chart is Section 5's ordered bars with two additions: a line at zero,
# because this measure has a meaningful center, and hand-picked colors.
# scale_fill_manual() lets you say which category gets which color, which
# matters here -- a chart about loss and gain must not scramble red and
# blue. And comma_format() on the axis, since these are counts of people.

ggplot(net_biggest,
       aes(x = estimate, y = reorder(FULL2_NAME, estimate), fill = direction)) +
  geom_col() +
  geom_vline(xintercept = 0, color = "grey30") +
  scale_x_continuous(labels = scales::comma_format()) +
  scale_fill_manual(values = c("Alameda gained" = "steelblue",
                               "Alameda lost"   = "firebrick")) +
  labs(
    title    = "Alameda gains from the expensive core and loses to the cheaper edge",
    subtitle = "Net migration with other U.S. counties, 2016-2020 ACS flows",
    x        = "Net movers (in minus out)",
    y        = NULL,
    fill     = NULL,
    caption  = "Source: ACS Migration Flows, 2016-2020."
  ) +
  theme_minimal()

# Look at which counties sit on which side. Alameda GAINED from San
# Francisco (+5,257), Santa Clara (+3,344), and San Mateo (+3,100) -- three
# of the most expensive housing markets in the country. It LOST to Contra
# Costa (-8,702), San Joaquin (-3,962), Stanislaus, Solano, Sacramento, and
# Placer -- the cheaper edge of the region and beyond it.
#
# That is people moving DOWN the rent ladder, one county at a time. And set
# it beside Section 6's ranking: Solano had the Bay Area's HIGHEST
# rent-burdened share on the region's CHEAPEST rents. The flows show one
# mechanism that is consistent with that paradox -- the counties absorbing
# the outflow are the counties where burden is worst. Consistent with, not
# proof of. Which brings us to the part that matters most.
#
# THREE THINGS THIS DATA CANNOT TELL YOU
#
# 1. WHO MOVED. These are ALL movers -- owners and renters, rich and poor,
#    together in one number. You cannot split them. The Census used to
#    publish these flows broken down by tenure, income, and race, but that
#    stopped: ask get_flows() for breakdown = "TENURE" on any recent year
#    and it refuses, because those characteristics are only available for
#    surveys before 2016. So "where did low-income RENTERS go" is not a
#    question this file can answer.
#
# 2. WHY THEY MOVED. This is the big one. A family priced out of Oakland
#    and a family that bought a bigger house in Walnut Creek on purpose
#    appear in this data as the same arrow. Migration is not displacement.
#    Displacement is migration UNDER PRESSURE, and the pressure is invisible
#    here. Anyone who shows you a net-outflow number and calls it
#    displacement has skipped the hardest step in the field.
#
# 3. WHO LEFT THE COUNTRY. Notice that the world-region rows have a MOVEDIN
#    number but no MOVEDOUT. The ACS asks people living in the U.S. where
#    they lived a year ago. Someone who moved abroad is not here to be
#    asked, so emigration simply is not measured.
#
# And the margins of error have not left either. Sacramento's net loss is
# about -1,177 with a margin of roughly +/- 1,050, which nearly touches
# zero. Solano's is -1,213 +/- 644. Lean on the big bars at the ends of that
# chart, not the small ones in the middle.
#
# WHAT RESEARCHERS DO INSTEAD. Because of limits 1 and 2, models that
# actually estimate displacement risk reach for data that follows the same
# households or individuals over time, rather than counting anonymous
# arrivals and departures. That is one of the inputs behind the Housing
# Precarity Risk Model in the bonus Lab 6, and it is a large part of why
# that model can say things a flow table cannot.

# YOUR TURN (3): run the get_flows() call for one county in your project
# area. Which county does yours lose the most people to, and which does it
# gain the most from? Then, in two sentences: what would you need to know
# about those movers before calling any of it displacement?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 7. Getting results OUT of R: write_csv()
# ==========================================================================
# Your group's writeup, slides, and maps need your numbers outside of R.
# The universal answer is a CSV file -- "comma separated values" -- which
# Excel, Google Sheets, Datawrapper, and every tool on earth can read.
#
# First make a folder inside your home folder (the ~ again) to keep
# outputs tidy (if it already exists, R just grumbles a warning -- that
# is fine, nothing breaks):

dir.create("~/output")

# write_csv(the_object, "where/to/put_it.csv") -- that is the whole verb:

write_csv(rb_seg, "~/output/alameda_rb_by_tract.csv")
write_csv(bay_rb %>% select(GEOID, NAME, p_rb_pct), "~/output/bay_rb_by_county.csv")

# Check the Files pane (click the house icon -- the folder was created in
# your home directory): an output folder with two CSVs. Click one to peek.
# The county file is deliberately three columns -- an ID, a name, a value.
# That is the shape web mapping tools want.

# ==========================================================================
# 8. Publishing path 1: a web map with Datawrapper (no code)
# ==========================================================================
# Datawrapper (datawrapper.de) is a free web tool newsrooms use for
# interactive charts and maps -- perfect for final-project visuals your
# audience can hover over. You already made its input file. The clicks,
# from their official guide (menu names may differ slightly as the site
# updates):
#
#   1. Sign up / log in at datawrapper.de (free tier is plenty), then go
#      to app.datawrapper.de/create/map and choose "Choropleth map".
#   2. It asks what map you want: search for "USA counties", select the
#      United States counties basemap, and click Proceed.
#   3. Step "Add your data": on the Upload tab, click "Upload file" and
#      give it bay_rb_by_county.csv -- first download it from the DataHub
#      to your computer (Files pane > house icon > output folder > check
#      the box > More > Export), or just copy-paste the table.
#   4. The "Match" tab asks which column identifies each county. Pick
#      GEOID -- Datawrapper knows U.S. county FIPS codes, and their docs
#      say it plainly: an ID code is safer than matching on names.
#   5. The "Check" tab flags any county it could not match (with a clean
#      GEOID column there should be none). Proceed.
#   6. Step "Visualize": choose your color palette and steps, write a
#      claim-style title, add the source line (ACS 5-year, 2020-2024).
#   7. Publish to get a shareable link / embed code for your slides.
#
# Two honest caveats:
#   - Our Bay Area map will render those 9 counties on a full-US county
#     basemap -- zoom the map view to the Bay Area before publishing.
#   - Datawrapper's basemap list changes over time. If you want TRACT-level
#     web maps, check whether a census-tract basemap exists for your
#     county; if not, use path 2 below and put the picture on your slide.
# TODO(Tim): the create/upload/match/check steps above are grounded in
# Datawrapper's academy how-to; publish-step wording and tract-basemap
# availability are worth one click-through before class.

# ==========================================================================
# 9. Publishing path 2: the same map in R (Lab 4's tmap)
# ==========================================================================
# Everything here is Lab 4: tigris for tract shapes, left_join starting
# FROM the shapes (so the result stays spatial), tmap to draw it.

library(tigris)
library(tmap)

# Cache map downloads so re-runs are instant:
options(tigris_use_cache = TRUE)

alameda_tracts <- tracts(state = "CA", county = "Alameda", year = 2024)

rb_map_data <- alameda_tracts %>%
  left_join(rb_seg, by = "GEOID")

# --------------------------------------------------------------------------
# 9.1 The first map -- Lab 4's recipe
# --------------------------------------------------------------------------

tm_shape(rb_map_data) +
  tm_fill(
    col     = "p_rb",
    title   = "Share rent-burdened",
    palette = "Reds",
    style   = "jenks"
  )

# (If your tmap version prints notes about "v3 code" and newer function
# names, that is advice, not an error -- the map still draws.)
#
# Lab 4 showed that WHERE the bins fall is an editorial choice. The menu,
# each style answering a different question -- swap any one into style =
# above and re-run:
#
#   style = "equal" / "pretty"   even-width bins     "fair intervals"
#   style = "quantile"           equal COUNTS/bin    "rank the tracts"
#   style = "jenks"              natural clusters    "let the data group itself"
#   style = "sd"                 one standard        "how far from a TYPICAL
#                                deviation per bin    tract is this one?"
#
# Quantile maps ALWAYS look striking, even when the real differences are
# small -- that is their power and their danger. Same data, four honest
# maps, four different stories. Which story is yours to choose, so choose
# on purpose and NAME the style you used in the caption.

# --------------------------------------------------------------------------
# 9.2 Choosing your colors
# --------------------------------------------------------------------------
# palette = takes ColorBrewer names -- the same palettes from lab 2's
# favorite picker, https://colorbrewer2.org (find a palette you like,
# use its name). Sequential palettes (Reds, Blues, YlOrRd, PuBu...) run
# light-to-dark and suit values that run low-to-high, like shares. A
# minus sign flips any palette's direction: palette = "-Reds".
#
# DIVERGING palettes (RdBu, BrBG, PuOr...) have two directions and a
# neutral middle -- made for values with a meaningful CENTER. Pair one
# with style = "sd", whose center IS the mean, and the map splits the
# county into below-average blue and above-average red:

tm_shape(rb_map_data) +
  tm_fill(
    col     = "p_rb",
    title   = "Burden vs. the typical tract",
    palette = "-RdBu",     # reversed so red = above average
    style   = "sd"
  )

# One map, one sentence: blue tracts carry less burden than the county's
# typical tract, red tracts more. Break style and palette are a TEAM --
# match them to the question, not to what looks prettiest.

# Where are the dark tracts? Color the SAME shapes by type instead: swap
# col = "p_rb" for col = "nt_group" and re-run. Two maps, one story, ready
# for a slide. (Want to click around inside a map? Lab 4's tmap_mode("view")
# still works on rb_map_data -- run tmap_mode("plot") to switch back.)

# YOUR TURN (4): make the nt_group version of the map (types are
# categories, so break styles do not apply -- but palettes do). Then
# remap p_rb one more time with YOUR choice of break style and palette
# from 9.1-9.2, and defend the choice in one sentence: what question
# does your map answer? Which parts of the county light up as Mixed, and
# how does that overlay with the high-burden tracts?
# [PUT YOUR ANSWERS BELOW]
#

# ==========================================================================
# 10. Your final-project toolkit (keep this section open while you work)
# ==========================================================================
# The prompt asks your group for: an area of at least two counties or a
# region; a research question about displacement; 3-5 data points/plots;
# at least two hypotheses about disparate impact; a 10-15 minute
# presentation (aim for ~5 slides). Here is where every piece lives:
#
#   Pick and pull your area........ Lab 1 sec 7 (get_acs), Lab 5 sec 6
#                                   (county vectors for your region)
#   Find your variables............ Lab 2 (load_variables + the catalog)
#   Income / AMI context........... Lab 2 (HUD tiers: 80/50/30 of median)
#   Build a measure................ Lab 3 (counts vs dollars, denominators,
#                                   pivot_wider, shares)
#   Eviction rates................. Lab 4 (ERN data, rates, joins)
#   Segregation types.............. Lab 5 sec 2-3 (ntdf + case_when)
#   Compare groups/places.......... Lab 3 + Lab 5 sec 5 (group_by,
#                                   summarize, bars, boxplots, dodged bars)
#   Who left, and where to........ Lab 5 sec 6.1 (get_flows, net migration
#                                   -- and its three hard limits)
#   Maps........................... Lab 4 + Lab 5 sec 8-9 (tmap or
#                                   Datawrapper)
#   Outside data off a website..... Lab 5 sec 5.3 (download, upload to the
#                                   DataHub, str_pad the ID, join, check)
#   Ship it........................ Lab 5 sec 7 (write_csv, output folder)
#
# Presentation rules of thumb (they are graded habits, not decoration):
#   - Titles state findings ("X is highest in Y"), not topics.
#   - 2-3 ideas per plot. Split crowded plots.
#   - Every plot: source line + years + who is being counted (renters?
#     households? people?).
#   - Check your denominators, and say them out loud in the talk.
#   - Small groups and small places wobble: lean on medians, show your n,
#     and do not oversell a 1-2 point gap (margins of error never left).
#
# And the AI policy one last time: any AI help on the project -- keep the
# shareable conversation link, cite it in code comments where you used it
# and in writeup footnotes.

# ==========================================================================
# 11. YOUR TURN: run it for YOUR group's area
# ==========================================================================
# The whole pipeline, one county of your project area. Fill the blanks.
#
# (a) Segregation types for your county:

my_seg <- ntdf(
  state  = "__",
  county = "__",
  year   = 2024
)

my_seg %>%
  count(nt_conc, sort = TRUE)

#     Then compare your counts against the full list of categories. Which
#     neighborhood types does your county not have AT ALL? (Section 2's
#     move -- and the empty ones are worth a sentence in your writeup.)

levels(my_seg$nt_conc)

# (b) Rent burden for the same county (copy the Section 1 build, swap the
#     state and county):


# (c) Join them, CHECK the join (three questions!), and drop empty tracts:


# (d) Median rent burden by type, types with 10+ tracts, one chart --
#     bar or boxplot, your call:


# (e) Two sentences, as comments: What did you find? What would your group
#     need to check before putting this on a slide?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 12. Where you started, where you are
# ==========================================================================
# Four weeks ago you typed 1 + 1. Today you pulled two federal datasets,
# built a published segregation measure, joined it to a housing-precarity
# measure you constructed yourself, tested a research question, and
# published the answer two different ways. That is not "learning R" --
# that is doing sociology with data.
#
# Next week: group work Tuesday (bring your area pulled and one draft
# plot), presentations Thursday. Final materials due Friday Aug 14.
#
# Go make something a city council member would underline.
# ==========================================================================
