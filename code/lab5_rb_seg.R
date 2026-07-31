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
#   3. You will get your results OUT of R -- as a file any tool can read --
#      and learn two ways to publish a map of them.
#   4. You will leave with a final-project checklist that points every task
#      in the prompt back to the lab section that teaches it.
#
# WHERE WE ARE (the course toolkit so far)
#   Lab 1: run code, save objects, get_acs(), filter/arrange/select, ggplot
#   Lab 2: find any Census variable, pull many at once, mutate(), AMI tiers
#   Lab 3: counts vs. dollars, denominators, pivot_wider(), group_by() +
#          summarize(), your own rent-burden measure
#   Lab 4: outside data (evictions), joins, rates, and maps with tmap
#
# Today adds: a GitHub package, case_when(), write_csv(), and
# publishing. After this you own a complete research pipeline.

# ==========================================================================
# 0. Packages -- including your first GitHub package
# ==========================================================================
# Our usual toolboxes first:

library(tidyverse)
library(tidycensus)

# Now something new. Most packages live on CRAN, R's official library, and
# install with install.packages(). But researchers often share packages
# straight from GitHub, the website where code projects live. Tim's lab --
# the Eviction Research Network -- shares its "neighborhood" package there.
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

# One small cleanup: ntdf() returns the type column as a "factor" (R's
# data type for fixed categories -- useful later, fussy today). Text is
# simpler to work with, so we convert it:

seg <- seg %>%
  mutate(nt_conc = as.character(nt_conc))

# Meet the data:

glimpse(seg)

# Column tour:
#   GEOID     = the tract ID -- SAME format as our Census pulls (11 digits:
#               state 06 + county 001 + tract). That is what makes the
#               join below possible.
#   pWhite, pBlack, pAsian, pLatine, pOther = each group's share (0 to 1)
#   NeighType = the full recipe name ("Black-Latine-White", ...)
#   nt_conc   = the same thing CONCentrated into fewer, chart-friendly
#               categories ("3 Group Mixed", "Mostly White", ...)
#
# How segregated is Alameda County? Count tracts by type:

seg %>%
  count(nt_conc, sort = TRUE)

# When we ran this (July 2026): "3 Group Mixed" led with 177 tracts, then
# "4 Group Mixed" (92) and "Asian-White" (37) -- and 13 "Black-Latine"
# tracts where White and Asian residents are each under 10%. Even in a
# county famous for diversity, many neighborhoods are missing whole
# groups. That IS segregation, measured.
#
# (The package also has a helper, ntcheck(seg), that tabulates the finer
# NeighType labels -- and if you are curious after class, ask Tim about
# nt_map(), the one-line interactive map his lab uses on these objects.)

# ==========================================================================
# 3. A new verb: case_when(), for many-way recodes
# ==========================================================================
# In Lab 3 you met if_else(): ONE yes/no question. case_when() is its big
# sibling: MANY questions, checked top to bottom, first match wins.
#
# Why we need it here: thirteen categories make an unreadable chart. Three
# of them -- "3 Group Mixed", "4 Group Mixed", "Diverse" -- all mean "no
# single group dominates," so for charting we can merge them into one
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
# Now the full recode -- same shape, two more rules -- saved onto the
# object this time:

seg_grouped <- seg %>%
  mutate(nt_group = case_when(
    nt_conc == "3 Group Mixed" ~ "Mixed (3+ groups)",
    nt_conc == "4 Group Mixed" ~ "Mixed (3+ groups)",
    nt_conc == "Diverse"       ~ "Mixed (3+ groups)",
    TRUE ~ nt_conc
  ))

seg_grouped %>%
  count(nt_group, sort = TRUE)

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

rb_seg <- rent_burden %>%
  left_join(seg_grouped, by = "GEOID")

# ALWAYS check a join before trusting it. Three questions, three lines:

nrow(rent_burden)          # rows going in: 379
nrow(rb_seg)               # rows coming out: must still be 379
sum(is.na(rb_seg$nt_group))  # tracts that failed to match: want 0

# When we ran this: 379, 379, 0. A perfect match -- every tract in the
# rent-burden table found its segregation type. If YOUR numbers disagree
# (rows appearing, disappearing, or failing to match), stop and look:
# join problems are the most common silent error in data work.
#
# Now clean the edges we spotted earlier: drop the tracts with no renters
# (p_rb was NA) and the "Unpopulated Tract" type in one filter (the comma
# means AND):

rb_seg <- rb_seg %>%
  filter(!is.na(p_rb), NeighType != "Unpopulated Tract")

nrow(rb_seg)               # 377 -- we knowingly dropped 2 empty tracts

# Note the habit: we did not delete data silently. We looked, counted,
# decided, and wrote the reason down. Your future collaborators (and
# graders) will thank you.

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

# Before charting, a data-humility check straight out of Lab 1: some
# types have 1, 2, or 3 tracts. A "median" of one tract is just... that
# tract. It tells you nothing general. So we chart only the types with a
# real base -- at least 10 tracts:

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
# bars is a story. And keep Tim's plot rule in mind for your projects:
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

# Five rows, two number columns. But ggplot wants one row PER BAR, and
# we want ten bars. Lab 4's pivot_longer() -- pivot_wider's return trip
# -- stacks the two columns into one, and case_when(), hired back in
# Section 3, turns the column names into legend-ready labels:

rb_levels_long <- rb_levels %>%
  pivot_longer(-nt_group,
               names_to = "burden_level", values_to = "median_share") %>%
  mutate(burden_level = case_when(
    burden_level == "median_moderate" ~ "Moderate (30-49.9%)",
    burden_level == "median_severe"   ~ "Severe (50%+)"
  ))

rb_levels_long            # ten rows: 5 types x 2 burden levels. Ten bars.

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
# moved: every neighborhood type sits between about 19% and 23%. The
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

# --------------------------------------------------------------------------
# 9.2 Where the colors break: the style menu
# --------------------------------------------------------------------------
# Lab 4 showed that WHERE the bins fall is an editorial choice (jenks vs
# the default). Here is the fuller menu -- each style answers a different
# question:
#
#   style = "equal" / "pretty"   even-width ruler bins   "fair intervals"
#   style = "quantile"           equal COUNTS per bin    "rank the tracts"
#   style = "jenks"              natural clusters        "let the data group itself"
#   style = "sd"                 bins one standard       "how far from a
#                                deviation wide,          TYPICAL tract?"
#                                centered on the mean
#
# Try quantile -- five bins, each holding a fifth of the tracts:

tm_shape(rb_map_data) +
  tm_fill(
    col     = "p_rb",
    title   = "Share rent-burdened (quantile)",
    palette = "Reds",
    style   = "quantile"
  )

# Maximum drama: a fifth of the county in every shade, top fifth darkest
# (everything above about 0.59 here). Quantile maps ALWAYS look striking
# -- even when the underlying differences are small. That is their power
# and their danger.
#
# Now sd -- read the legend before the map:

tm_shape(rb_map_data) +
  tm_fill(
    col     = "p_rb",
    title   = "Share rent-burdened (sd)",
    palette = "Reds",
    style   = "sd"
  )

# The bins are all the same width -- about 0.15, one standard deviation
# -- and the middle boundary sits at the county mean (about 0.46). This
# map answers "how unusual is this tract?" Most of the county sits in
# the middle shades (within one sd of typical); only the true outliers
# darken. And notice the legend's bottom bin dips BELOW ZERO: the sd
# ruler is symmetric around the mean and does not know a share cannot be
# negative. Legends tell on their break styles -- read them.
#
# The rule from Lab 4, upgraded: same data, four honest maps, four
# different stories. WHICH story is yours to choose -- so choose it on
# purpose, and SAY which style you used in the caption.

# --------------------------------------------------------------------------
# 9.3 Choosing your colors
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

# --------------------------------------------------------------------------
# 9.4 Make it interactive
# --------------------------------------------------------------------------
# Lab 4's mode switch, now with a payoff for exploration: popup.vars
# puts columns you choose into a click-card on every tract, and a
# little transparency (alpha) lets the base map's streets and city
# names show through:

tmap_mode("view")

tm_shape(rb_map_data) +
  tm_fill(
    col        = "p_rb",
    title      = "Share rent-burdened",
    palette    = "Reds",
    style      = "jenks",
    alpha      = 0.7,
    popup.vars = c("p_rb", "nt_group")
  )

# Zoom to a neighborhood you know. Click a tract: its burden share and
# its segregation type, together -- the whole lab in one click-card.
# When you are done exploring, flip back (static is what goes in a
# paper or on a slide; interactive is for exploring and presenting live):

tmap_mode("plot")

# Where are the dark tracts? Compare with the segregation map idea from
# Lab 4 -- or simply color the SAME shapes by type: swap col = "p_rb" for
# col = "nt_group" and re-run. Two maps, one story, ready for a slide.

# YOUR TURN (3): make the nt_group version of the map (types are
# categories, so break styles do not apply -- but palettes do). Then
# remap p_rb one more time with YOUR choice of break style and palette
# from 9.2-9.3, and defend the choice in one sentence: what question
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
#   Maps........................... Lab 4 + Lab 5 sec 8-9 (tmap or
#                                   Datawrapper)
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
) %>%
  mutate(nt_conc = as.character(nt_conc))

my_seg %>%
  count(nt_conc, sort = TRUE)

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
