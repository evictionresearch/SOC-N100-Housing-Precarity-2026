# ==========================================================================
# Lab 4: Real eviction records -- and your first maps
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# This lab spans TWO sessions:
#   PART A (Tuesday)  -- load real eviction data, compute eviction rates,
#                        and join them to Census data
#   PART B (Thursday) -- put those rates on a map
#
# WHERE WE ARE: in labs 1-3 every number came from the Census API through
# get_acs(). Real research almost always means combining that with data
# someone HANDS you -- a file. Today that file is real: eviction court
# filings collected by the Eviction Research Network (ERN), the research
# group I direct at Berkeley. Every row summarizes actual households who
# had an eviction case filed against them in Indiana. Treat it with the
# respect that deserves: these are people in the worst weeks of their
# housing lives, not just rows in a table.
#
# WHAT YOU ALREADY KNOW (labs 1-3): get_acs(), the pipe %>%, filter /
# arrange / select / mutate, pivot_wider(), group_by() + summarize(),
# ggplot charts built layer by layer. We use all of it today.

library(tidyverse)
library(tidycensus)

# (Nothing new to install for Part A. If any library() line ever says
# "there is no package called ...", the fix is the same as always:
# install.packages("that-package-name") once, then library() again.)

# ==========================================================================
# ==========================================================================
# PART A -- TUESDAY: EVICTION DATA
# ==========================================================================
# ==========================================================================

# ==========================================================================
# A1. Reading a data file: readRDS()
# ==========================================================================
# R has a native file format for saved data objects, called RDS. Reading
# one takes a single base-R function -- no packages at all:

indiana_evictions <- readRDS("~/SOC-N100-Housing-Precarity-2026/data/evictions/d5_case_aggregated.rds")
data <- readRDS("~/Downloads/file.rds")
data3 <- read.csv("~/Downloads/fils_name.csv")

# Read that path like a street address, left to right:
#   ~                                  = your HOME folder (on the DataHub,
#                                        everything you own lives in here)
#   /SOC-N100-Housing-Precarity-2026   = the course folder inside it
#   /data/evictions/                   = a folder inside a folder
#   /d5_case_aggregated.rds            = the file itself
# Forward slashes, even on Windows. (Working on your own laptop instead of
# the DataHub? Change the address to wherever your course folder lives.)
#
# (Look closer at the folder and you will see the OTHER datasets come
# twice -- a .rds and a .parquet of the same table. Two formats, two
# jobs. .rds is R's native format: one function reads it, any R object
# survives the trip exactly as saved, but only R speaks it. .parquet
# is the format the wider data world shares tables in -- R, Python,
# and SQL engines all read it, and it stores data by COLUMN, so a big
# file can be read a few columns at a time instead of all at once.
# Rule of thumb: .rds for your own work in R, .parquet when a table is
# big or has to travel between tools. The bonus lab puts parquet to
# work; today runs on .rds.)
#
# Where did this file come from? ERN collects raw eviction case records
# from county courts, cleans them, links names to demographics, and
# aggregates them to census tracts by month. What you have is that
# tract-by-month summary. You cannot download this from a website -- this
# is the "someone hands you their data" experience, which is most of
# real-world sociology.

# ==========================================================================
# A2. Meeting a big unfamiliar table
# ==========================================================================
# Same ritual as always -- but this table is bigger than anything we have
# touched, so we add one new tool.

nrow(indiana_evictions)   # 139,072 rows
ncol(indiana_evictions)   # 58 columns

# With 58 columns, head() would wrap into an unreadable mess. glimpse()
# is the tidyverse's answer: one COLUMN per line, with its type and first
# few values. It is the standard first move on any new dataset:

glimpse(indiana_evictions)

# You do not need all 58 columns. Here are the ones we use today:
#
#   tract_geoid  = the census tract's ID code (text! leading zeros)
#   county       = county name
#   year, month  = when the filings happened (2016 through 2022)
#   filings      = number of eviction cases filed in that tract that month
#   black_head   = filings whose head of household is estimated to be
#                  Black. ERN estimates race statistically from names and
#                  neighborhood demographics, so the race columns carry
#                  DECIMALS -- they are expected counts, not exact tallies.
#                  (Court records do not list race; estimation is how all
#                  eviction-by-race research works. Another reason for
#                  humility when the groups get small.)
#   tr_totrent   = renter households in that TRACT (from the census)
#   co_totrent   = renter households in that COUNTY (from the census)
#   state_code, county_code = the two pieces of a county's GEOID
#
# (You will also spot columns named latine_*: ERN uses "Latine" as the
# gender-neutral term for Latino/Latina/Latinx populations.)
#
# So the UNIT OF OBSERVATION of this table -- what one row IS -- is one
# tract in one month. Check that claim instead of trusting it: pick one
# tract, one year, and count the rows. Twelve months, twelve rows:

indiana_evictions %>%
  filter(tract_geoid == "18001030300", year == 2019) %>%
  select(tract_geoid, year, month, filings)

# Knowing the unit of observation is THE first question to ask of any
# dataset. Almost every wrong number in a beginner's analysis comes from
# mistaking it -- counting something twice, or summing what was already
# a total.

# ==========================================================================
# A3. Your first aggregation: the pandemic, visible from orbit
# ==========================================================================
# The table is tract-by-month. Most questions are bigger than that:
# "how many filings per YEAR?" That is what group_by() + summarize() do
# (you met them in lab 3 -- here is the one-minute rebuild).
#
# Step 1: group_by() alone. Run it -- and notice that almost nothing
# happens. The printout just gains a small "Groups: year" note at the top.
# group_by() only plants a flag that says "treat each year as a team."
summary(indiana_evictions)

indiana_evictions %>%
  group_by(year)

# Step 2: summarize() collapses each team down to ONE row, using a rule
# you write. Our rule: add up the filings.

indiana_evictions %>%
  group_by(year) %>%
  summarize(total_filings = sum(filings))

# Read that little table slowly, because it contains a national story:
# roughly 72-78 thousand filings every year from 2016 to 2019... and then
# 2020 collapses to about 42 thousand. That is the COVID-19 eviction
# moratorium -- courts closed and federal/state protections paused most
# filings. 2021 (~54k) and 2022 (~60k) climb back toward "normal" as the
# protections expired. You just found a major policy event in seven rows
# of output. Policy leaves fingerprints in data.
#
# It deserves a quick chart (nothing new here -- lab 1 skills):

indiana_evictions %>%
  group_by(year) %>%
  summarize(total_filings = sum(filings)) %>%
  ggplot(aes(x = year, y = total_filings)) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Eviction filings in Indiana collapsed during the pandemic",
    x     = NULL,
    y     = "Filings per year",
    caption = "Source: Eviction Research Network, Indiana court records."
  ) +
  theme_minimal()

# YOUR TURN (1): change the grouping to county -- which Indiana counties
# have the most total filings across all years? Sort your answer with
# arrange(desc(...)). [PUT YOUR ANSWER BELOW]

indiana_evictions %>%
  group_by(county) %>%
  summarize(total_filings = sum(filings)) %>%
  ggplot(aes(x = total_filings, y = reorder(county, total_filings))) +
  geom_col(fill = "steelblue") +
  labs(
    title = "Eviction filings in Indiana collapsed during the pandemic",
    x     = NULL,
    y     = "Filings per county",
    caption = "Source: Eviction Research Network, Indiana court records."
  ) +
  theme_minimal()

# ==========================================================================
# A4. Aggregating to county-years -- and a very instructive mistake
# ==========================================================================
# For eviction RATES we need county-by-year counts (rates need a
# denominator, and our renter counts live at the county level). You can
# group by TWO things at once -- every county-year combination becomes
# a team:

indiana_evictions %>%
  group_by(county, year) %>%
  summarize(evictions = sum(filings))

# 644 rows: 92 counties x 7 years. So far so good.
#
# Now the mistake, on purpose. We also want each county's renter count,
# which sits in co_totrent. The tempting move is to just name it:

indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    renters   = co_totrent
  )

# R complains -- read the message. It says summarize() expected ONE value
# per group and got many, warns you this is deprecated, and suggests
# reframe(). Here is what actually went wrong: sum(filings) collapses a
# group's many rows to one number, but co_totrent is just a column with
# HUNDREDS of values per county (one per tract-month). R does not know
# which one you meant. (On newer versions of R this same mistake stops
# with an error instead of a warning -- same cause, louder alarm. And
# reframe() is the tool for the rare case where you WANT many rows back;
# that is not what we want here.)
#
# See the mistake with your own eyes. summarize() works through the
# groups alphabetically, so the first group it met was Adams County,
# 2016. Print exactly what it saw there:

indiana_evictions %>%
  filter(county == "Adams", year == 2016) %>%
  select(tract_geoid, month, filings, co_totrent)

# 84 rows: 7 tracts x 12 months. Now read the two columns the way
# summarize() did. filings is 84 monthly counts, and we gave R a rule
# -- sum() -- that squeezes them into one number. co_totrent is ALSO
# 84 values, but we gave R no rule at all; we just named the column.
# That is the whole anatomy of the mistake (and of its message on
# current R: "must be size 1, not 84").
#
# But look DOWN the co_totrent column: 2400, 2400, 2400... Adams
# County has one renter total, and the file stamped that same number
# onto every tract-month row -- 84 copies of one fact. Which is why
# the fix is a rule that sounds almost too casual: take the FIRST
# one. When every value in the group is an identical copy, the first
# one IS the county total. first() is a legitimate summarizing rule
# with the same standing as sum() -- sum() collapses many values by
# adding them, first() collapses them by keeping the one on top:

county_year <- indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions       = sum(filings),
    black_evictions = sum(black_head),
    renters         = first(co_totrent)
  )

county_year

# (Two sanity notes before you trust it. First: first() was safe ONLY
# because we looked and saw 84 identical copies -- on a column whose
# values genuinely vary, first() would silently throw away the rest.
# Second: sum() would have been the wrong rule here -- adding 84
# copies of 2,400 would invent a county of 201,600 renter households.
# Neither rule is "the" answer; match the rule to what the column
# MEANS. Counts you are combining: sum(). One fact repeated on every
# row: first().)

# One more column before we can talk to the Census: a join key. Census
# county GEOIDs are state code + county code glued together: "18" (Indiana)
# + "001" (Adams County) = "18001" -- lab 3's geography ladder, cashing
# in as an ID you can BUILD. paste0() glues text end to end --
# and because these are TEXT codes, the leading zeros survive (lab 1's
# leading-zero trap, still paying rent):

county_year <- indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions       = sum(filings),
    black_evictions = sum(black_head),
    renters         = first(co_totrent),
    county_geoid    = first(paste0(state_code, county_code))
  )

county_year

# ==========================================================================
# A5. The Census side: renter households by county
# ==========================================================================
# For rates BY RACE we need denominators by race, and it is good practice
# to pull our own fresh census numbers rather than lean only on columns
# someone baked into a file. Table B25003 is "Tenure" (own vs rent), and
# like income in lab 2, it comes in race flavors: B25003B is Tenure for
# Black householders. Line _003 is "Renter occupied" in both.
# Named-vector renaming, exactly like lab 2:

co_census <- get_acs(
  geography = "county",
  variables = c(
    total_renters = "B25003_003",   # renter households, everyone
    black_renters = "B25003B_003"   # renter households, Black householder
  ),
  state = "IN",
  year  = 2022
)

co_census

# Two variables per county means the table is LONG: two rows per county.
# To do math BETWEEN the variables we widen it -- and, as in lab 3, we
# must first drop the columns that would make each row unique (moe, and
# NAME while we are at it; the GEOID is a better key anyway):

co_census_wide <- co_census %>%
  select(-NAME, -moe) %>%
  pivot_wider(
    names_from  = variable,
    values_from = estimate
  )

co_census_wide
nrow(co_census_wide)   # 92 -- one row per Indiana county. Always check.

# ==========================================================================
# A6. left_join(): gluing two tables together
# ==========================================================================
# We now have two tables that describe the same counties:
#   county_year     (from ERN)    -- has a county_geoid column
#   co_census_wide  (from Census) -- has a GEOID column
# A JOIN matches rows across tables using a shared ID -- the KEY. Same
# idea as VLOOKUP in a spreadsheet, but sturdier.
#
# left_join(x, y) keeps EVERY row of x and attaches matching columns
# from y. The by = argument says which column in x equals which in y:

county_rates <- county_year %>%
  left_join(co_census_wide, by = c("county_geoid" = "GEOID"))

county_rates

# JOIN DISCIPLINE -- run these checks every single time you join, forever.
# A silently broken join is the most dangerous bug in data work, because
# everything downstream still LOOKS fine.
#
# Check 1: the row count must not change (left_join keeps x's rows;
# if it GREW, some key matched more than one row):

nrow(county_year)
nrow(county_rates)
# 644 and 644. Good.

# Check 2: did every row find a partner? anti_join() shows the rows of x
# that found NO match in y -- you want to SEE the leftovers, not guess:

anti_join(county_year, co_census_wide, by = c("county_geoid" = "GEOID"))
# 0 rows. Every county-year matched a census county. A clean join.

# A 0-row answer only reassures you if you know what a FAILURE looks
# like -- so let's break the join on purpose. Suppose we had matched on
# county NAMES instead of codes. co_census (the long table from A5)
# still has its NAME column; try pairing our "Adams" with theirs:

anti_join(county_year, co_census, by = c("county" = "NAME"))

# 644 rows -- EVERY county-year came back unmatched, the exact opposite
# of clean. Why? Look at how each table spells the same place: ours
# says "Adams", the Census says "Adams County, Indiana". To a join,
# text matches EXACTLY or not at all -- there is no "close enough".
# THIS is what anti_join() is for: when a join goes wrong, the
# leftovers pile up where you can see them instead of silently
# vanishing downstream. And it is why we built county_geoid out of
# code pieces rather than trusting names: "18001" is spelled exactly
# one way, everywhere.

# ==========================================================================
# A7. Rates at last -- and the divide-by-zero trap
# ==========================================================================
# A count alone ("Marion County had thousands of filings") mostly measures
# how BIG a place is. A RATE -- filings per renter household -- measures
# how INTENSE eviction is, and lets small and large counties be compared
# fairly. mutate() does the arithmetic on every row at once:

county_rates <- county_rates %>%
  mutate(
    eviction_rate       = evictions / renters,
    black_eviction_rate = black_evictions / black_renters
  )

# Meet your new columns before trusting them:

summary(county_rates)

# Look at black_eviction_rate: the maximum is "Inf" -- infinity. R is
# telling you that somewhere it divided by ZERO. Never shrug at a weird
# value; go find it:

county_rates %>%
  filter(is.infinite(black_eviction_rate)) %>%
  select(county, year, evictions, black_evictions, black_renters)

# There it is: counties where the ACS estimates ZERO Black renter
# households -- 28 of Indiana's 92 counties -- while our black_head
# column still carries positive numbers there. Before we referee that
# disagreement, we need to know what black_head actually IS.
#
# Court records do not list race (A2 warned you). ERN estimates it
# with an R package called wru ("Who are You?"), and the logic is
# Bayes' rule: start with the defendant's SURNAME -- the Census
# publishes how often each surname belongs to each race group -- then
# update by WHERE they live, since neighborhoods differ. Out comes a
# probability that each defendant's household is Black, white,
# Latine... One filing might score 0.90, another 0.03. black_head is
# those probabilities ADDED UP: an expected count. That is why it
# carries decimals -- 0.195 is not a fifth of a family, it is a small
# pile of small probabilities. (The method: Imai & Khanna 2016,
# Political Analysis.)
#
# So the standoff is estimate vs. estimate -- a survey's count against
# a model's expectation -- and neither side is ground truth. Watch how
# differently it leans in two of our 28 counties. (%in% is a handy
# filter comparison -- "is each value one of these?")

county_rates %>%
  filter(county %in% c("Brown", "Clinton")) %>%
  select(county, year, evictions, black_evictions, black_renters)

# Same Inf problem, very different stories.
#
# Brown County: 16 to 40 filings a year, and the probabilities across
# ALL of them add up to at most 0.195 expected Black-headed filings --
# that in its highest year. Probability dust. Most likely nothing
# happened here that the census zero gets wrong: "roughly zero over
# zero," nothing to report.
#
# Clinton County: 198 to 363 filings a year, and the probabilities add
# up to 3 to 9.4 expected Black-headed filings EVERY year -- one to
# three percent of the county's filings, year after year. Now look at
# its denominator with lab 1 eyes: the ACS zero is an estimate too,
# and it has a margin of error like every ACS number. Clinton's is
# 0 +/- 27 households, so "zero" means "somewhere between 0 and 27."
# Which story is true, then? Maybe a small, real Black renter
# community lives inside that +/- 27, and some of those households met
# the eviction court -- model right, survey zero misleading. Or maybe
# wru misread a few hundred names and addresses by a few percent each
# -- survey right, the 9.4 a mirage. From these two numbers alone YOU
# CANNOT TELL, and no third dataset is waiting to break the tie.
# Measuring tiny populations is like this all the way down.
#
# Working honestly under that uncertainty is the skill. What to DO:
#   1. Never publish a rate built on a zero denominator: a shaky
#      numerator over an unknown denominator makes a number that
#      LOOKS precise and means nothing.
#   2. Do not let the rate's failure erase the numerator. Clinton's
#      filings still count in A9's statewide sums, and "roughly 3 to
#      9 expected Black-headed filings a year, denominator too
#      uncertain for a rate" is a reportable finding on its own.
#   3. Treat a Clinton as a FLAG, not a conclusion -- a place worth
#      pooling more years, another data source, or a phone call to
#      someone who knows the county. (Brown is not a flag; there is
#      nothing there to chase.)
#   4. Only COMPARE rates where denominators are solid. A8 returns to
#      this, and Thursday makes it a hard rule: filter(renters >= 100).
#
# All 28 counties still need SOMETHING in their rate column, though.
# So what value SHOULD it be? Not 0 -- that would claim "no
# eviction risk for Black renters," a certainty we just admitted we do
# not have. The honest answer is
# "cannot compute": NA, R's missing value. if_else() picks row by row --
# if_else(condition, value_if_yes, value_if_no):

county_rates <- county_rates %>%
  mutate(
    black_eviction_rate = if_else(
      black_renters > 0,
      black_evictions / black_renters,
      NA
    )
  )

# Verify the repair -- no more Inf, and the impossible cases are now
# honestly missing:

summary(county_rates$black_eviction_rate)
### Left off here
# ==========================================================================
# A8. The question that matters: is eviction racially unequal?
# ==========================================================================
# Take one clean pre-pandemic year -- 2019 -- and put the overall rate
# against the Black rate, county by county:

rates_2019 <- county_rates %>%
  filter(year == 2019)

glimpse(rates_2019)

# Base scatter -- lab 3's geom_point(), on a new question: each point is
# one county.

ggplot(rates_2019, aes(x = eviction_rate, y = black_eviction_rate)) +
  geom_point()

# Now the layer that turns a scatter into an argument: the EQUALITY LINE.
# geom_abline() draws y = x. If eviction touched everyone equally, every
# county would sit ON that line. A point ABOVE the line is a county where
# Black renters are evicted at a HIGHER rate than renters overall:

ggplot(rates_2019, aes(x = eviction_rate, y = black_eviction_rate)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed")

# (A note appeared in the Console: "Removed 28 rows containing missing
# values". That is not an error -- it is our NA fix from A7 showing up.
# The 28 counties where the rate cannot be computed are left off the
# chart, and R is transparently telling you so. Always read those notes
# and make sure you can explain them.)
#
# Finish it properly -- labels, the works:

ggplot(rates_2019, aes(x = eviction_rate, y = black_eviction_rate)) +
  geom_point() +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed") +
  labs(
    title    = "Black renters face higher eviction rates in most Indiana counties",
    subtitle = "Each point is a county, 2019. Dashed line = racial equality.",
    x        = "Eviction filings per renter household (all renters)",
    y        = "Eviction filings per Black renter household",
    caption  = "Source: Eviction Research Network; ACS 2018-2022 (B25003)."
  ) +
  theme_minimal()

# Count it instead of eyeballing it: among the counties where the Black
# rate is computable, how many sit above the line? One catch first.
# Remember A3: group_by() plants flags. A4 planted two (county, year),
# and summarize() pulls up only the LAST one -- so county_year, and
# every table we built from it since, is still quietly grouped by
# county. (That "Groups: county [92]" note at the top of the printouts
# has been saying so all along.) Left alone, summarize() here would
# answer once PER COUNTY -- 64 rows of 1s and 0s, not the one-row
# total we want. ungroup() pulls up the remaining flag:

rates_2019 %>%
  ungroup() %>%
  filter(!is.na(black_eviction_rate)) %>%
  summarize(
    counties_with_a_rate = n(),
    black_rate_higher    = sum(black_eviction_rate > eviction_rate)
  )

# 38 of 64. And remember the denominators: rates in counties with very
# few Black renter households swing wildly (five families, one filing =
# a huge "rate"). The disparity story is strongest where the population
# -- and therefore the estimate -- is solid. That is why Desmond studied
# Milwaukee and ERN studies whole states: patterns, not anecdotes.
#
# One last data-humility note. Our file came with a renters column baked
# in (co_totrent), and we ALSO pulled total_renters fresh from the 2022
# ACS. Compare them -- they disagree slightly in every county (Marion:
# 174,535 vs 174,973). Neither is wrong; they are different ACS releases.
# Real analysts write down WHICH vintage they used (see the chart caption
# above) so others can reproduce the number exactly.

county_rates %>%
  filter(year == 2022) %>%
  select(county, renters, total_renters) %>%
  mutate(difference = renters - total_renters)

# YOUR TURN (2): remake the 2019 scatter for 2022. Does the pandemic
# recovery year look more or less unequal? [PUT YOUR ANSWER BELOW]


# YOUR TURN (3) -- stretch: the Tenure table has other race iterations,
# e.g. B25003I_003 is renter households with a Hispanic or Latino
# householder, and the ERN file has latine_head filings. Build a
# latine_eviction_rate the same way we built the Black rate -- traps,
# fixes, and all. [PUT YOUR ANSWER BELOW]


# ==========================================================================
# A9. The whole state through time: one line, then many
# ==========================================================================
# (Short on time tonight? This section is a perfect Thursday warm-up --
# nothing after it depends on it running tonight.)
#
# A3 showed the pandemic collapse as BARS. Lab 3's chart card says time's
# natural shape is the LINE -- and lines can carry something bars cannot:
# several groups on one canvas. We build up in three steps: totals, then
# rates, then rates BY RACE.
#
# Step 1 -- the total, as a line. Also grab the race counts while we are
# here (same summarize, three more sums):

indiana_yearly <- indiana_evictions %>%
  group_by(year) %>%
  summarize(
    filings = sum(filings),
    black   = sum(black_head),
    white   = sum(white_head),
    latine  = sum(latine_head)
  )

ggplot(indiana_yearly, aes(x = year, y = filings)) +
  geom_line() +
  labs(title = "One line: Indiana filings collapse in 2020, then climb back",
       x = NULL, y = "Filings per year") +
  theme_minimal()

# Same numbers as A3's bars, drawn as motion.
#
# Step 2 -- one line PER RACE. Multiple lines need the LONG shape (one
# row per year-group pair), and our race counts sit side by side as
# columns. The verb is pivot_longer(): pivot_wider()'s return trip.
# Name the two new columns it should build; -year means "melt every
# column except year":

yearly_counts_long <- indiana_yearly %>%
  select(year, black, white, latine) %>%
  pivot_longer(-year, names_to = "group", values_to = "filings")

ggplot(yearly_counts_long, aes(x = year, y = filings, color = group)) +
  geom_line() +
  labs(title = "Counts follow group size", x = NULL,
       y = "Filings per year", color = NULL) +
  theme_minimal()

# How to read a multi-line chart: every line answers the SAME question
# for a different group, so the VERTICAL GAP between lines at any year
# is the comparison -- and the gap's movement over time is the story.
# (We chart the three largest groups; "other" bundles too many distinct
# populations to read as one honest line.)
#
# Here the White line rides on top every year. Is that the story? Look
# at the denominators before you decide: Indiana has about 535,000
# White renter households and 153,000 Black renter households. Counts
# track population size -- A7's lesson at full scale.
#
# Step 3 -- so divide each group's filings by ITS OWN renter households
# (the county totals summed statewide; distinct() first so each county
# counts once, not once per tract-month row):

state_renters <- indiana_evictions %>%
  distinct(county, co_totrent_black, co_totrent_white_nl, co_totrent_latine) %>%
  summarize(
    black  = sum(co_totrent_black),
    white  = sum(co_totrent_white_nl),
    latine = sum(co_totrent_latine)
  )

yearly_rates_long <- indiana_yearly %>%
  mutate(
    black  = black  / state_renters$black,
    white  = white  / state_renters$white,
    latine = latine / state_renters$latine
  ) %>%
  select(year, black, white, latine) %>%
  pivot_longer(-year, names_to = "group", values_to = "rate")

rates_by_race <- ggplot(yearly_rates_long, aes(x = year, y = rate, color = group)) +
  geom_line() +
  labs(
    title    = "Black renters face more than double the eviction rate, every year",
    subtitle = "Eviction filings per renter household, Indiana, 2016-2022",
    x        = NULL,
    y        = "Filings per renter household",
    color    = NULL,
    caption  = "Source: Eviction Research Network; denominators from the ACS."
  ) +
  theme_minimal()

rates_by_race

ggsave("~/lab4_rates_by_race.png", rates_by_race, width = 8, height = 5)

# The lines FLIPPED. In counts, White households received the most
# filings; per household, Black renters carry the highest rate in every
# single year -- 0.16 to 0.18 before the pandemic against roughly 0.08
# for White and Latine renters, and still on top through the 2020
# collapse (0.089 vs 0.044). Read the moratorium with both eyes: it
# pulled every line down, and it did not close the gap. A8's scatter
# showed this inequality across counties in one year; these lines show
# it across years for the whole state. Same finding, two shapes --
# which one would you put on a slide, and when?

# ============================== STOP HERE ================================
# End of Part A (Tuesday). Thursday we take these rates to the map.
# ==========================================================================

# ==========================================================================
# ==========================================================================
# PART B -- THURSDAY: PUTTING EVICTION ON THE MAP
# ==========================================================================
# ==========================================================================
#
# Quick recap of Tuesday: readRDS() loaded ERN's tract-month eviction
# file; group_by + summarize aggregated it; first() grabbed repeated
# totals; left_join attached census denominators (with row-count checks);
# rates + if_else handled divide-by-zero; the equality-line scatter
# showed Black renters evicted at higher rates in most counties.
#
# Today's question is WHERE. "Which tracts in Indianapolis carry the
# eviction crisis?" is a map question. The San Diego displacement study
# linked on the course website is the professional version of what you
# build today: a CHOROPLETH -- a map where each area is shaded by a
# value. Ours: census tracts shaded by eviction rate.
#
# If you are starting fresh today, run these to catch up:

library(tidyverse)
library(tidycensus)

indiana_evictions <- readRDS("~/SOC-N100-Housing-Precarity-2026/data/evictions/d5_case_aggregated.rds")

# ==========================================================================
# B1. Spatial data: tables where each row has a SHAPE
# ==========================================================================
# A map needs geometry -- the actual polygon outline of every tract.
# The Census publishes those shapes, and the tigris package downloads
# them. tigris and sf (the package that lets tables carry shapes) both
# arrived on your account with tidycensus back in lab 1 -- nothing to
# install, just open them:

library(tigris)
library(sf)

# tracts() downloads tract outlines. State, county, year -- and the year
# should match your data's era so boundaries line up:

marion_tracts <- tracts(state = "IN", county = "Marion", year = 2022)

# (First run prints download progress -- it is fetching the shapes from
# the Census. Marion County is Indianapolis: Indiana's biggest city and
# county, and where the filings are concentrated.)

marion_tracts

# Look at the printout header: "Simple feature collection with 253
# features". A FEATURE is a row-with-a-shape; sf is the "simple features"
# format. Scroll right conceptually: familiar columns (GEOID!), plus a
# special geometry column holding each tract's polygon. Confirm what
# kind of object this is:

class(marion_tracts)

# "sf" AND "data.frame" -- it is still a table (every verb you know still
# works on it), it just carries shapes on its back.

# ==========================================================================
# B2. Prepare the eviction side: one row per tract
# ==========================================================================
# Our eviction file is tract-by-MONTH; the map needs tract totals. Same
# aggregation pattern as Tuesday, one level down the geography ladder --
# and note we sum a YEAR of filings, 2022, the most recent year:

marion_2022 <- indiana_evictions %>%
  filter(county == "Marion", year == 2022) %>%
  group_by(tract_geoid) %>%
  summarize(
    filings = sum(filings),
    renters = first(tr_totrent)
  ) %>%
  mutate(eviction_rate = filings / renters)

marion_2022
nrow(marion_2022)   # 253 tracts -- same count as the shapes. Promising.

# Tuesday's reflex: before trusting eviction_rate, look for trouble.
# is.finite() is FALSE for Inf, NaN, and NA all at once:

marion_2022 %>%
  filter(!is.finite(eviction_rate))

# One tract, with zero renter households recorded. You know this movie
# and you know the fix -- undefined, not zero:

marion_2022 <- marion_2022 %>%
  mutate(
    eviction_rate = if_else(renters > 0, filings / renters, NA)
  )

# YOUR TURN (4): how many filings did Marion County record in 2022 in
# total, and which single tract has the highest eviction rate? (Hint:
# summarize for the first, arrange(desc()) for the second.)
# [PUT YOUR ANSWER BELOW]


# --------------------------------------------------------------------------
# B2.1 When a rate passes 100%: filings are not families
# --------------------------------------------------------------------------
# Before we map 2022, rewind to 2017 for the single most instructive
# number in this dataset. Build the same tract table for 2017, keeping
# the Black-renter columns from Tuesday:

marion_2017 <- indiana_evictions %>%
  filter(county == "Marion", year == 2017) %>%
  group_by(tract_geoid) %>%
  summarize(
    filings       = sum(filings),
    renters       = first(tr_totrent),
    black_filings = sum(black_head),
    black_renters = first(tr_totrent_black)
  )

# Sort by the eviction rate -- and only tracts with a real renter base
# (100+ renter households), so no small-denominator flukes:

marion_2017 %>%
  filter(renters >= 100) %>%
  mutate(rate = filings / renters) %>%
  arrange(desc(rate)) %>%
  select(tract_geoid, filings, renters, rate) %>%
  slice_head(n = 3)

# Read the top row twice. Tract 360406: 2,235 filings against 1,082
# renter households -- a rate of 2.07. TWO filings for every renter
# household in the tract, in one year. How can more than 100% of
# households be evicted? They cannot. A filing is a COURT CASE, not a
# family: a landlord can file on the same household again and again,
# and in some buildings the eviction court functions as the
# rent-collection desk -- a summons in the mail every time rent runs
# late. Researchers call this SERIAL FILING. So say the measure out
# loud, precisely: filings PER renter household, never "the share of
# households evicted." A rate can pass 1; a share cannot. If you catch
# yourself -- or a headline -- reading one as the other, stop.
#
# Now the same table for Black renter households:

marion_2017 %>%
  filter(black_renters >= 100) %>%
  mutate(black_rate = black_filings / black_renters) %>%
  arrange(desc(black_rate)) %>%
  select(tract_geoid, black_filings, black_renters, black_rate) %>%
  slice_head(n = 3)

# Tract 360406 again, worse: filings against Black-headed households
# run to nearly THREE per Black renter household (2.79). And read the
# second row -- tract 340108: 579 filings against 620 Black renter
# households. Even stated carefully -- filings, not families -- that is
# courthouse volume equal to 93% of every Black renter household in the
# neighborhood, in a single year. Tuesday's scatter said Black renters
# face higher eviction rates in most Indiana counties; the tract level
# shows what "higher" means where it is worst. This is what the map you
# are about to build is FOR: finding the neighborhoods where the
# courthouse has become part of how the rental market runs.

# ==========================================================================
# B3. Joining a table to shapes -- ORDER MATTERS
# ==========================================================================
# We join eviction numbers to tract shapes with left_join, keyed on the
# tract GEOID. But with spatial data there is a real trap: the result
# keeps the CLASS of the table you START from.
#
# Wrong order -- start from the plain table, attach shapes:

flat_join <- marion_2022 %>%
  left_join(marion_tracts, by = c("tract_geoid" = "GEOID"))

class(flat_join)

# Just a plain table. The geometry column is IN there, but the object
# forgot it is spatial -- mapping tools will refuse it.
#
# Right order -- start from the SHAPES, attach the numbers:

marion_map_data <- marion_tracts %>%
  left_join(marion_2022, by = c("GEOID" = "tract_geoid"))

class(marion_map_data)

# Still sf. Rule of thumb: THE SHAPES GO FIRST. (If you ever do get stuck
# with a flat table that has a geometry column, st_as_sf() re-awakens it:
# st_as_sf(flat_join) -- your rescue hatch, not your habit.)
#
# And because it is a join, the join discipline applies -- rows kept,
# leftovers seen:

nrow(marion_tracts)
nrow(marion_map_data)
anti_join(marion_tracts %>% st_drop_geometry(), marion_2022,
          by = c("GEOID" = "tract_geoid"))
# 253 in, 253 out, 0 tracts without eviction data. (st_drop_geometry()
# peels the shapes off for the check -- anti_join wants plain tables.)

# ==========================================================================
# B4. The map, one layer at a time: tmap
# ==========================================================================
# Several packages draw maps; we use tmap because it thinks in layers,
# exactly like ggplot. It is already on the DataHub. Open it:

library(tmap)

# HEADS UP before your first map: depending on the tmap version, you may
# see chatty notes like "[v3->v4] ..." suggesting newer argument names.
# Those are suggestions from a newer tmap translating our commands, NOT
# errors -- the map draws either way. Read them, then move on.
#
# Layer 1: tm_shape() declares WHICH spatial object we are drawing --
# like ggplot()'s data argument. Plus tm_polygons() to actually draw
# the shapes:

tm_shape(marion_map_data) +
  tm_polygons()

# Indianapolis appears -- every tract outlined, all the same color.
# A map, but not yet an argument.
#
# Layer 2, one new input: col = names the column whose VALUES color the
# tracts. This is the aes() moment -- data becomes shade:

tm_shape(marion_map_data) +
  tm_polygons(col = "eviction_rate")

# A choropleth! Darker tracts = higher eviction rates. Now refine it,
# one argument per step, same as lab 1's chart build.
#
# A legend title (people cannot read "eviction_rate"):

tm_shape(marion_map_data) +
  tm_polygons(col = "eviction_rate", title = "Filings per renter household, 2022")

# A color palette that means something -- sequential red reads as
# "more = worse" at a glance:

tm_shape(marion_map_data) +
  tm_polygons(
    col     = "eviction_rate",
    title   = "Filings per renter household, 2022",
    palette = "Reds"
  )

# ==========================================================================
# B5. Where the colors BREAK: the quiet power move of map-making
# ==========================================================================
# tmap just chopped the rates into equal-width bins. Equal bins are
# honest but can hide structure when values bunch up. style = "jenks"
# asks for "natural breaks" -- bin edges placed where the data itself
# has gaps:

tm_shape(marion_map_data) +
  tm_polygons(
    col     = "eviction_rate",
    title   = "Filings per renter household, 2022",
    palette = "Reds",
    style   = "jenks"
  )

# Compare the two maps and their legends. Same data, different story
# strength. WHERE THE BREAKS FALL IS AN EDITORIAL CHOICE -- two honest
# analysts can make the same data whisper or shout. When you publish a
# choropleth, say which break method you used. (This is "Pie Chart with
# a Bayesian Chaser" in map form: the sophistication is in the choices,
# the output stays simple.)

# YOUR TURN (5): change style = "jenks" to style = "quantile" (equal
# COUNTS of tracts per bin). Which of the three tells the starkest
# story? Which feels most honest here, and why?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# B6. Interactive mode -- and saving your map
# ==========================================================================
# One line flips tmap from static pictures to a pannable, zoomable web
# map (leaflet under the hood -- the same tech as the San Diego study):

tmap_mode("view")

# Re-run the jenks map from B5 now -- it opens in the Viewer pane. Zoom
# into downtown Indianapolis. Hover a tract. THIS is the moment to ask
# the sociological question: which neighborhoods are dark red? What do
# you know -- or need to learn -- about them?
#
# Flip back to static mode (static is what goes in a paper):

tmap_mode("plot")

# To save a map, store it in an object (arrow, as ever), then
# tmap_save():

eviction_map <- tm_shape(marion_map_data) +
  tm_polygons(
    col     = "eviction_rate",
    title   = "Filings per renter household, 2022",
    palette = "Reds",
    style   = "jenks"
  )

tmap_save(eviction_map, "~/lab4_eviction_map.png", width = 7, height = 7)

# Check the Files pane (house icon) -- lab4_eviction_map.png is in your
# home folder (that is what the ~ does), ready for a writeup.

# ==========================================================================
# B7. Counts vs rates -- the map version of an old lesson
# ==========================================================================
# YOUR TURN (6): map col = "filings" (the raw count) instead of the rate,
# side by side with the rate map. Where do they disagree? Which tracts
# look alarming in counts but calm in rates -- and what does that tell
# you about what raw counts actually measure? [PUT YOUR ANSWER BELOW]


# YOUR TURN (7) -- stretch: map a different year (2019, say) and compare
# to 2022. Did the pandemic reshape WHERE eviction concentrates, or just
# how much of it there is? [PUT YOUR ANSWER BELOW]


# ==========================================================================
# B8. Flat maps from a round planet: reference systems (file this away)
# ==========================================================================
# One quiet reason today went smoothly: every shape you drew came from a
# single source (the Census, via tigris), and that source ships
# everything in one COORDINATE REFERENCE SYSTEM -- the agreed-upon
# recipe for flattening the round earth onto a flat map. Ask what ours
# is:

st_crs(marion_tracts)$Name

# "NAD83" -- the Census Bureau's standard for the United States. Every
# spatial object carries a tag like this, and mapping tools compare
# tags before they combine layers.
#
# The one rule to file away for your final project: LAYERS MUST AGREE.
# If you ever mix map sources -- Census shapes plus, say, a shapefile
# from a city's open-data portal -- and the layers refuse to combine
# ("st_crs(x) == st_crs(y) is not TRUE") or draw in the wrong place,
# the diagnosis is two different reference systems, and the fix is one
# line:
#
#   city_layer <- st_transform(city_layer, st_crs(marion_tracts))
#
# -- "make this layer use that layer's system." That is as deep as this
# course goes. Today you never had to think about reference systems
# because we stayed inside one source on purpose; when you mix sources,
# think about it once, at the start. (The full story, when you want it:
# Walker chapter 5, section 5.4 -- the optional part of this week's
# reading.)

# ==========================================================================
# B9. What you can do now (and what's next)
# ==========================================================================
# After this lab you can:
#   - load a data file with readRDS() and size it up with glimpse()
#   - state a table's unit of observation (what one row is) and verify
#     it with a filter
#   - aggregate with group_by() + summarize(), including first() for
#     repeated group values -- and explain the many-values-per-group trap
#   - build GEOID join keys with paste0() and text codes
#   - left_join() two data sources WITH row-count and anti_join checks
#   - turn counts into rates, and handle divide-by-zero honestly with NA
#   - argue about inequality with an equality-line scatter
#   - put time on the x-axis: totals, then rates, then rates by race --
#     reshape with pivot_longer() and read multi-line gaps as disparities
#   - download tract shapes (tigris), join shapes-first, and build
#     choropleths in tmap with deliberate break choices
#
# ASSIGNMENT 2 is due Monday Aug 3 at 5pm: stay in your Assignment 1
# area, add 2-3 more ACS variables, and combine them into a measure of
# displacement risk or housing precarity -- with descriptive statistics,
# plots, interpretation, and a draft research question plus two
# hypotheses for your final project. Everything you need is now in your
# hands: multi-variable pulls (lab 2), building measures (lab 3), and
# joins, rates, and maps (today). A map is not required -- but a good
# one talks.
#
# NEXT LAB (Thursday Aug 6): the last new tool -- measuring racial
# segregation with ERN's neighborhood package -- and a working session
# to point everything you have learned at your group's final project.
#
# As always: errors are normal, read them out loud, ask your AI to
# explain before it fixes (and keep the share link for your submission).
# ==========================================================================
