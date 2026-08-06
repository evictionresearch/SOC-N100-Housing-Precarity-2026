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
#   3. You will look at MIGRATION data -- who moved IN during the past
#      year, by race, tract by tract -- and at its hard limits.
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
# Today adds: a GitHub package, case_when(), race iterations (B07004),
# publishing, and -- if time allows -- downloading a dataset off an
# agency's website yourself. After this you own a complete research
# pipeline.
#
# NEW FUNCTIONS IN THIS LAB, and the line where each is introduced. If one
# looks unfamiliar mid-lab, jump to that line -- it is where the lab
# teaches it. (All of them are on the course cheat sheet too,
# code/r_functions_cheatsheet.R.)
#
#   remotes::install_github()  L82    install a package from GitHub
#   ntdf()                     L168   ERN's neighborhood segregation types
#   count()                    L190   group and tally in one move
#   levels()                   L204   a factor's categories, in stored order
#   case_when()                L269   many-way recode (if_else's big sibling)
#   read_csv()                 L600   read a CSV, from a file or a URL
#   dim()                      L602   rows and columns at once
#   str_pad()                  L621   pad an ID back to its full width
#   round()                    L712   round numbers
#   options()                  L938   change an R setting for this session
#   tmap_arrange()             L1046  two maps side by side, pan/zoom linked
#   get_flows()                L1221  county-to-county migration, incl. moved-OUT
#   nchar()                    L1245  how many characters a value has
#   abs()                      L1274  drop the minus sign, to sort by size
#   scales::comma_format()     L1290  axis numbers with thousands commas
#   scale_fill_manual()        L1291  pick which category gets which color
#   dir.create()               L1343  make a folder
#   write_csv()                L1347  save a table as a CSV
#   tm_fill()                  L1413  map fill without borders

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
# 6.1 Who moved IN? A brief on migration data
# --------------------------------------------------------------------------
# Everything you have measured tonight is a SNAPSHOT of who is here now.
# Rent burden, segregation type, pollution -- all of it describes the
# people currently living in a tract.
#
# But displacement is about MOVEMENT. The Census asks one question that
# gets at it: did you live in this same house one year ago? Table B07004
# carries the answer, and it is the closest the ACS lets us get to
# watching new people arrive in a neighborhood.
#
# READ THAT QUESTION AGAIN, BECAUSE THE DIRECTION IS EVERYTHING. The
# Census asks it of people at the address where they live NOW. So B07004
# is a table of ARRIVALS and STAYERS: who is here today, and which of them
# were somewhere else a year ago. It is in-migration.
#
# It does NOT count who moved OUT, and it cannot. A household pushed out
# of a tract last year is not in that tract's rows anymore -- it answers
# the same question at its new address, counted in somebody else's
# neighborhood. Keep the word IN attached to every number in this section.
# We will come back to what that costs us at the end.
#
# WHY THIS TABLE. The Census also publishes county-to-county migration
# flows, which are fun to look at, but they stop at the county line --
# there is no tract version. B07004 works at BOTH county and tract level,
# so it joins to everything else you built tonight. That difference is not
# a technicality. It is the entire finding of this section.
#

vars_2024 <- load_variables(2024, "acs5")
View(vars_2024)

# SOMETHING NEW ABOUT TABLE NAMES: RACE ITERATIONS. Search the catalog for
# B07004 and you will not find it. What you find is nine tables:
#
#   B07004A  White alone                B07004F  Some other race alone
#   B07004B  Black alone                B07004G  Two or more races
#   B07004C  Am. Indian / AK Native     B07004H  White alone, NOT Latine
#   B07004D  Asian alone                B07004I  Latine (of any race)
#   B07004E  Native Hawaiian / Pac. Isl.
#
# A trailing letter means "this same table, for this racial group." Once
# you know the pattern you will see it on Census tables everywhere.
#
# Every one of the nine has the same six lines:
#
#   _001  Total  (everyone living here now)
#   _002  Same house 1 year ago                     <- stayed put
#   _003  Moved FROM elsewhere in the same county   <- arrived
#   _004  Moved FROM a different county, same state <- arrived
#   _005  Moved FROM a different state              <- arrived
#   _006  Moved FROM abroad                         <- arrived
#
# Look at lines _003 through _006: every one says moved FROM. There is no
# "moved TO" line anywhere in this table, and that is the point above.
#
# So "moved in during the past year" is _001 minus _002. Build the vector
# exactly the way you built rb_vars in Section 1. One call can mix tables:

mob_vars <- c(
  "B07004H_001", "B07004H_002",   # White, not Latine: total, stayed put
  "B07004B_001", "B07004B_002",   # Black
  "B07004D_001", "B07004D_002",   # Asian
  "B07004I_001", "B07004I_002"    # Latine
)

# START AT THE COUNTY LEVEL, the way most people would:

mob_county <- get_acs(
  geography = "county",
  variables = mob_vars,
  state     = "CA",
  county    = "Alameda",
  year      = 2024
) %>%
  select(GEOID, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    White  = round(100 * (B07004H_001 - B07004H_002) / B07004H_001, 1),
    Black  = round(100 * (B07004B_001 - B07004B_002) / B07004B_001, 1),
    Asian  = round(100 * (B07004D_001 - B07004D_002) / B07004D_001, 1),
    Latine = round(100 * (B07004I_001 - B07004I_002) / B07004I_001, 1)
  ) %>%
  select(White, Black, Asian, Latine)

mob_county

# Read those four numbers, and read them as ARRIVALS: about 12.4% of the
# White residents living in Alameda today moved into their current home
# within the past year. Same for 12.8% of Black residents, 12.6% of Asian
# residents, 10.6% of Latine residents. Nearly identical. If you stopped
# here you would write "mobility barely differs by race in Alameda
# County," and you would have a defensible, sourced, completely misleading
# sentence.
#
# Do not stop here.
#
# THE SAME TABLE AT TRACT LEVEL. One word changes in the call:

mob_tract <- get_acs(
  geography = "tract",
  variables = mob_vars,
  state     = "CA",
  county    = "Alameda",
  year      = 2024
) %>%
  select(GEOID, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    arrived_white = (B07004H_001 - B07004H_002) / B07004H_001,
    arrived_black = (B07004B_001 - B07004B_002) / B07004B_001
  )

mob_tract
glimpse(mob_tract)

# Join it to tonight's table, and check the join the way Section 4 taught:

rb_seg_mob <- rb_seg %>%
  left_join(mob_tract, by = "GEOID")

rb_seg_mob
glimpse(rb_seg_mob)
nrow(rb_seg)                          # 377
nrow(rb_seg_mob)                      # still 377
sum(is.na(rb_seg_mob$arrived_white))    # 0

# DENOMINATORS, one more time, because they decide whether any of this is
# real. A tract with 40 Black residents swings from 0% to 25% on ten
# people. So we read a tract's rate only where that group actually lives
# there in numbers -- Lab 4's rule again, at least 100 people:

mob_by_type <- rb_seg_mob %>%
  filter(nt_group %in% rb_by_type_solid$nt_group) %>%
  group_by(nt_group) %>%
  summarize(
    white_arrived = median(arrived_white[B07004H_001 >= 100]),
    black_arrived = median(arrived_black[B07004B_001 >= 100]),
    n_white     = sum(B07004H_001 >= 100),
    n_black     = sum(B07004B_001 >= 100)
  )

mob_by_type

# Find the Black-Latine row. Read it twice.
#
# In Alameda's Black-Latine neighborhoods, about 17% of WHITE residents
# moved into their home within the past year. About 4% of BLACK residents
# did. Same tracts, same year, same table: White residents arriving
# roughly FOUR TIMES as fast as their Black neighbors. And it is the
# extreme on both ends -- of every neighborhood type, Black-Latine tracts
# have the HIGHEST White arrival rate and the LOWEST Black arrival rate.
#
# That is what arrival looks like in a neighborhood that is changing.
# Newcomers arriving fast; long-term residents staying put.
#
# Now go back to the county numbers. 12.4% against 12.8%, a difference of
# nothing. The county average did not just miss this, it actively hid it,
# by averaging the arriving with the staying across 379 tracts at once.
# Same table, same year, same county. The only thing that changed was the
# geography you asked about. Keep that in mind every time someone hands
# you a county-level statistic about a neighborhood-level problem.
#
# Before charting, look at n_white and n_black. The Black rate rests on 13
# tracts in the Black-Latine row and just 2 in "Mostly Asian" -- so that
# second one is not a finding, it is a rounding error wearing a label. We
# chart only the types where both groups clear 10 tracts:

mob_long <- mob_by_type %>%
  filter(n_black >= 10) %>%
  select(nt_group, white_arrived, black_arrived) %>%
  pivot_longer(-nt_group, names_to = "group", values_to = "share") %>%
  mutate(group = case_when(
    group == "white_arrived" ~ "White (non-Latine) residents",
    group == "black_arrived" ~ "Black residents"
  ))

# Section 5.2's dodged bars, doing the same job for a different question:

ggplot(mob_long, aes(x = share, y = reorder(nt_group, share), fill = group)) +
  geom_col(position = "dodge") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(
    title    = "In Black-Latine neighborhoods, White residents are four times likelier to be new arrivals",
    subtitle = "Median tract share who moved into their home in the past year, 2020-2024 ACS",
    x        = "Share who moved in within the past year",
    y        = NULL,
    fill     = NULL,
    caption  = "Source: ACS 5-year table B07004. Tracts with 100+ residents of that group."
  ) +
  theme_minimal()

# Notice the Asian-Latine row runs the other way: 3% of White residents
# moved, 5.7% of Black residents did. The pattern is not "White people
# move more." It is specific to which neighborhoods are changing and who
# is arriving in them.
# --------------------------------------------------------------------------
# 6.2 Mapping it: where are these neighborhoods, and who is arriving?
# --------------------------------------------------------------------------
# The dodged bars gave you one number per neighborhood type. A median hides
# geography, and geography is the whole subject of this course. So put it
# on a map.
#
# Lab 4's recipe, unchanged: tigris for the tract shapes, left_join
# starting FROM the shapes so the result stays spatial, tmap to draw it.

library(tigris)
library(tmap)

# Cache map downloads so re-runs are instant:
options(tigris_use_cache = TRUE)

alameda_tracts <- tracts(state = "CA", county = "Alameda", year = 2024)

mob_map <- alameda_tracts %>%
  left_join(rb_seg_mob, by = "GEOID")

# Pull out just the Black-Latine tracts, keeping the 100-resident rule:

bl_map <- mob_map %>%
  filter(nt_group == "Black-Latine", B07004H_001 >= 100)

nrow(bl_map)   # 12 of the 13 -- one has too few White residents to rate

# TWO LAYERS IN ONE MAP, which is new. Each tm_shape() starts a layer, and
# layers draw in order, so the second one lands on top of the first. Grey
# for the whole county to show where you are, then the Black-Latine tracts
# colored by how fast White residents are arriving:

tm_shape(mob_map) +
  tm_polygons(col = "grey92", border.col = "white", title = "Rest of county") +
tm_shape(bl_map) +
  tm_polygons(
    col        = "arrived_white",
    palette    = "Reds",
    style      = "quantile",
    border.col = "grey30",
    title      = "White arrivals\n(share of White\nresidents, past year)"
  )

# Two things to take from it.
#
# FIRST, WHERE THEY ARE. Alameda's Black-Latine tracts are not scattered
# across the county at random. Nearly all of them pack into one cluster at
# the northwest end, the Oakland and Berkeley side, with a single outlier
# further south -- while the whole eastern half of the county has none at
# all. Segregation is not only a number attached to a tract. It has a
# shape, and you just drew it.
#
# SECOND, AND THIS IS THE PART THE BAR CHART COULD NOT SHOW: they are not
# all changing at the same speed. Across those 12 tracts the White arrival
# rate runs from 0% to about 46%. The 17% median you charted is the middle
# of a very wide spread. White residents are moving into some Black-Latine
# neighborhoods fast, and into others barely at all. "Where, exactly?" is a
# question
# only the map can answer, and it is the question a city council member
# actually has.

# --------------------------------------------------------------------------
# 6.2.1 Click around: interactive maps of where each group is arriving
# --------------------------------------------------------------------------
# Lab 4's tmap_mode("view") turns any tmap into a slippy web map you can
# pan, zoom, and click. Switch it on once:

tmap_mode("view")

# WHERE ARE BLACK HOUSEHOLDS MOVING IN? Countywide this time, not just the
# Black-Latine tracts, and only where at least 100 Black residents live so
# the rate means something. popup.vars picks what a click shows you:

mob_black <- mob_map %>%
  filter(B07004B_001 >= 100)

# Save the map to a NAME this time instead of just printing it -- we want
# both maps as objects in a moment. Typing the name draws it:

map_black <- tm_shape(mob_black) +
  tm_polygons(
    col        = "arrived_black",
    palette    = "Purples",
    style      = "quantile",
    alpha      = 0.7,
    title      = "Black arrivals",
    popup.vars = c("nt_group", "arrived_black", "p_rb")
  )

map_black

# 281 tracts qualify. The median is about 8%, and the top of the range is
# extreme -- click a dark tract before you believe it, because the highest
# values sit in tracts with dorms and group quarters, where "moved in the
# past year" describes a student body, not a housing market.
#
# NOW THE SAME MAP FOR WHITE HOUSEHOLDS. Identical code, two words changed:

mob_white <- mob_map %>%
  filter(B07004H_001 >= 100)

map_white <- tm_shape(mob_white) +
  tm_polygons(
    col        = "arrived_white",
    palette    = "Reds",
    style      = "quantile",
    alpha      = 0.7,
    title      = "White arrivals",
    popup.vars = c("nt_group", "arrived_white", "p_rb")
  )

map_white

# 372 tracts qualify, median about 10%.
#
# NOW PUT THEM SIDE BY SIDE. This is what saving the maps to names bought
# us. tmap_arrange() takes any number of tmap objects and lays them out in
# one view; ncol says how many across; and sync = TRUE LINKS them, so
# panning or zooming one map moves the other to match. That linking is the
# whole point -- comparing two maps at different zooms tells you nothing.

tmap_arrange(map_black, map_white, ncol = 2, sync = TRUE)

# The Viewer pane is small for two maps. Click the "Show in new window"
# icon (top-right of the Viewer, a little arrow leaving a box) to open them
# full-screen in your browser, then zoom into Oakland and drag around.
# Both maps move together.
#
# (One rough edge: tmap_save() works on a single interactive map but errors
# on an arranged pair in the current tmap. For a slide, save the two maps
# separately, or take a screenshot of the linked view.)
#
# Compare where the dark patches sit. That comparison is the section's
# argument in one gesture: countywide the two medians are close (8% and
# 10%), but they are dark in DIFFERENT PLACES. Sameness on average,
# difference on the ground.
#
# Then click the Black-Latine tracts specifically on each map. In those 12
# tracts the White arrival rates run 0, 9.6, 10.7, 11.8, 15, 17, 17.6,
# 20.3, 24, 32.2, 38.9, 45.5 -- while the Black arrival rates in the same
# tracts run 0, 0, 0, 0.1, 2.2, 4.4, 5.4, 8.2, 9.8, 15.2, 23.5, 28.2. Four
# of those neighborhoods took in essentially no Black residents at all last
# year, while White arrivals ran into the tens of percent next door.
#
# Interactive maps are for exploring and for presentations; static ones are
# for print and for slides you cannot click. Switch back when you are done,
# or every later map in this lab opens in a browser:

tmap_mode("plot")

# (Keep the reliability habit from Lab 4 in view. Every rate on these maps
# is an ACS estimate with a margin of error, and the tracts with the
# smallest populations have the widest ones. The map draws a confident
# color either way -- that confidence is the map's, not the data's.)


# --------------------------------------------------------------------------
# 6.2.2 One map instead of two: where is White arrival outpacing Black?
# --------------------------------------------------------------------------
# Two maps side by side works, but look at what your eyes are actually
# doing: flicking between them and subtracting. Anything a reader has to
# compute in their head belongs in the data instead. So compute it.
#
# ONE NUMBER PER TRACT: the White arrival rate minus the Black arrival
# rate. Positive means White residents are moving in faster than Black
# residents; negative means the reverse; zero means the two are arriving at
# the same rate. We multiply by 100 so the units are PERCENTAGE POINTS,
# which is what the legend will say.
#
# This measure needs BOTH denominators, so a tract only qualifies if it has
# at least 100 White AND at least 100 Black residents:

mob_gap <- mob_map %>%
  filter(B07004H_001 >= 100, B07004B_001 >= 100) %>%
  mutate(arrival_gap = 100 * (arrived_white - arrived_black))

nrow(mob_gap)              # 278 of 379 tracts can be compared at all
summary(mob_gap$arrival_gap)

# THIS IS WHAT DIVERGING COLORS ARE FOR. A sequential palette (Reds, Blues)
# runs light to dark and answers "how much?" This measure is not "how
# much." It has a meaningful ZERO in the middle and two directions away
# from it, so it wants a palette with two directions and a neutral center:
# RdBu, which runs red at the low end through near-white in the middle to
# blue at the high end. (Put a minus in front, "-RdBu", to flip which side
# gets which color. Section 9.2 comes back to this.)
#
# One more decision, and it matters. One tract sits at -76 percentage
# points. Left alone, a single outlier stretches the color scale so far
# that every other tract washes out to near-white. So we set the breaks by
# hand, and the outer bins absorb the extremes:

tm_shape(mob_gap) +
  tm_polygons(
    col        = "arrival_gap",
    palette    = "RdBu",
    breaks     = c(-Inf, -20, -10, -5, 5, 10, 20, Inf),
    border.col = "grey60",
    alpha = .5,
    title      = "White minus Black\narrival rate\n(percentage points)"
  )

# READING IT. Check the legend before you say a word about this map, every
# time, because a diverging palette can be pointed either direction.
#
# BLUE tracts are the POSITIVE side: White residents arrived faster than
# Black residents last year, by 5, 10, more than 20 points as the blue
# deepens.
#
# RED tracts are the NEGATIVE side: the reverse, Black arrival outpacing
# White arrival.
#
# NEAR-WHITE in the middle means the two groups arrived at roughly the
# same rate.
#
# And notice what is NOT on this map: only the 278 comparable tracts are
# drawn at all. The other 101 are simply absent, because one of the two
# groups has fewer than 100 residents there and the rate would be noise.
# A blank tract is not a zero and not a tie. It means we could not tell,
# which is a finding worth saying out loud rather than coloring in.
#
# Countywide the split is 172 tracts where White arrival is faster against
# 104 where Black arrival is, with a median gap of about +4 points. But go
# back to the neighborhood types and the concentration shows: the median
# gap is +14.4 points in Black-Latine tracts, against +4.3 in Asian-White,
# +4.2 in Mixed, and -1.1 in Asian-Latine. The Black-Latine neighborhoods
# are not just the ones with the most White arrival. They are the ones
# where the RACIAL GAP in who is arriving is widest, by a factor of three.
#
# ONE CAUTION, and it is the arithmetic. Every rate here is an estimate
# with a margin of error, and a DIFFERENCE of two estimates carries both
# margins -- it is always noisier than either number alone. Treat the
# strong colors at the ends as the signal and the pale middle as "probably
# nothing." If you put this map on a slide, say the two denominators out
# loud, and say why some tracts are blank.

# --------------------------------------------------------------------------
# 6.2.3 Three things none of this can tell you
# --------------------------------------------------------------------------
# Tables, chart, and maps together -- here is what B07004 still cannot say,
# no matter how good the map looks.
#
# 1. WHO LEFT. This is the big one, and it is built into the question.
#    The ACS asks where you lived a year ago -- and it asks people who are
#    HERE NOW. Anyone pushed out of a tract last year answers that
#    question at their new address, counted in somebody else's
#    neighborhood. A tract that lost the people who could no longer afford
#    it looks, in this table, quiet. Every measure tonight shares this
#    blind spot; this one just makes it obvious.
#
# 2. WHY THEY MOVED. A household priced out of its apartment and a
#    household that bought a bigger place two miles away are both "moved
#    within same county." Migration is not displacement. Displacement is
#    migration UNDER PRESSURE, and the pressure is invisible here. Anyone
#    who shows you a mobility rate and calls it displacement has skipped
#    the hardest step in the field.
#
# 3. HOW THE GROUPS OVERLAP. B07004B is "Black alone" and includes Black
#    Latine residents; B07004I is "Latine of any race" and counts those
#    same people again. The iterations do not sum to the total and were
#    never built to. Name the iteration you used, every time.

# YOUR TURN (3): run mob_vars for one county in your project area, first
# at county level and then at tract level joined to your own rb_seg. Did
# the tract view change the story the county view told you? Then, in two
# sentences: what would you need to know about those movers before calling
# any of it displacement?
# [PUT YOUR ANSWER BELOW]
#

# --------------------------------------------------------------------------
# 6.3 OPTIONAL: the data that DOES count who left (counties only)
# --------------------------------------------------------------------------
# Skip this if we are short on time -- nothing later depends on it.
#
# Sections 6.1 and 6.2 ended on a real limit: B07004 counts arrivals, and no ACS
# table reports departures for a census tract. So the obvious question is
# whether ANY public data counts who left. The answer is yes, with one
# expensive catch.
#
# The Census publishes MIGRATION FLOWS: for a given place, how many people
# arrived from each other place, and how many left for each other place.
# Pairing an origin with a destination is exactly what B07004 could not do.
# tidycensus gets it with a second function, get_flows().
#
# THE CATCH, and it is why this is not the main section: get_flows() only
# accepts counties, county subdivisions, and metro areas. There is no tract
# version, and there is no way to make one. If your question is about
# neighborhoods, Section 6.1 is your table and this one cannot help you.
#
# A VINTAGE WARNING TOO. Everything else in this lab uses year = 2024. This
# cannot. County-to-county flows top out at 2020 (the 2016-2020 ACS) -- ask
# for a newer year and the Census hands back flows between STATES instead,
# which is not what we want. That window also straddles the start of the
# pandemic. Name the years you used.

flows_alameda <- get_flows(
  geography = "county",
  state     = "CA",
  county    = "Alameda",
  year      = 2020
)

flows_alameda %>%
  count(variable)

# Three variables, one row each per PARTNER place -- and note that the
# second one is the thing Section 6.1 could not give us at any price:
#
#   MOVEDIN   people who moved from that place TO Alameda
#   MOVEDOUT  people who moved from Alameda TO that place    <- departures
#   MOVEDNET  MOVEDIN minus MOVEDOUT (positive = Alameda gained)
#
# AN ID TRICK. Place IDs have lengths, and the length tells you what KIND
# of place you are looking at: 5 digits is a U.S. county, 10 digits is a
# Connecticut town (that state reports towns instead of counties), and a
# missing GEOID2 is a world region like "Asia." nchar() counts the
# characters in a value, so this keeps counties only:

flows_counties <- flows_alameda %>%
  filter(nchar(GEOID2) == 5)

# Where did people GO? This is the question we could not ask before:

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

# Read the two lists together before charting. Contra Costa is the
# number-one DESTINATION (about 16,500 people) and also the number-three
# ORIGIN (about 7,800). Movement between neighboring counties is enormous
# in both directions at once, which is why gross numbers cannot tell the
# story alone. The NET is where direction shows up.
#
# Twelve biggest net flows, either direction. abs() strips the minus sign
# so we sort by SIZE, and if_else() (Lab 3) labels the direction:

net_biggest <- flows_counties %>%
  filter(variable == "MOVEDNET") %>%
  arrange(desc(abs(estimate))) %>%
  head(12) %>%
  mutate(direction = if_else(estimate > 0, "Alameda gained", "Alameda lost"))

net_biggest %>%
  select(FULL2_NAME, estimate, moe, direction)

# Section 5's ordered bars, plus a line at zero because this measure has a
# meaningful center, plus hand-picked colors. scale_fill_manual() lets you
# say which category gets which color, which matters when a chart is about
# loss and gain. comma_format() because these are counts of people.

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

# Alameda GAINED from San Francisco (+5,257), Santa Clara (+3,344), and San
# Mateo (+3,100) -- three of the most expensive housing markets in the
# country. It LOST to Contra Costa (-8,702), San Joaquin (-3,962),
# Stanislaus, Solano, Sacramento, and Placer -- the cheaper edge of the
# region and past it. That is people moving DOWN the rent ladder, one
# county at a time. Set it beside Section 6: Solano had the Bay Area's
# HIGHEST rent-burdened share on its CHEAPEST rents. The flows are
# consistent with that, though they do not prove it.
#
# WHAT THIS STILL CANNOT TELL YOU, briefly, because Section 6.1 made the
# same three points at length:
#
#   - ALL MOVERS, not renters and not low-income households. Ask
#     get_flows() for breakdown = "TENURE" and it refuses; those
#     characteristics stopped being published after 2016.
#   - PUSHED vs CHOSE is still invisible. A family priced out of Oakland
#     and a family that wanted a yard in Walnut Creek are the same arrow.
#   - EMIGRATION is still missing. The world-region rows carry a MOVEDIN
#     number but no MOVEDOUT: someone who moved abroad is not here to be
#     asked.
#
# And the margins of error have not left either. Sacramento's net loss is
# about -1,177 with a margin near +/- 1,050, which nearly touches zero.
# Lean on the big bars at the ends, not the small ones in the middle.

# ==========================================================================
# 7. OPTIONAL: Getting results OUT of R: write_csv()
# ==========================================================================
# We are not covering this in class, and you do not need it for the final
# project. It is here for when you want it -- and you will want it the
# first time someone asks for your numbers in a spreadsheet.
#
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
# 8. OPTIONAL: Publishing path 1: a web map with Datawrapper (no code)
# ==========================================================================
# Also not covered in class, and not needed for the final. Section 9 is
# the mapping path we do use. This one is here if you want an interactive
# web map for a slide, and it runs on Section 7's CSV.
#
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
#
# Section 6.2 already loaded tigris and tmap and downloaded alameda_tracts,
# so we go straight to the join. (If you skipped 6.2, run its three setup
# lines first -- the two library() calls and the tracts() download.)

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
# 10. OPTIONAL: Your final-project toolkit (keep this open while you work)
# ==========================================================================
# We are not walking through this in class. It is a reference card: every
# task the final-project prompt asks for, and the lab section that taught
# it. Read it on your own when your group sits down to work.
#
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
#   Who is moving, by race........ Lab 5 sec 6.1 (B07004 race iterations,
#                                   county vs tract -- and its three limits)
#   Maps........................... Lab 4 + Lab 5 sec 9 (tmap; sec 8 is
#                                   the optional Datawrapper path)
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
