# ==========================================================================
# Lab 3: Reading Census tables like a researcher -- and charts, done right
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# This lab spans TWO sessions:
#   PART A (Tuesday)  -- the census geography ladder (fresh from our Social
#                        Explorer tour), reading count tables, building the
#                        course's first real measure, and the first two
#                        chart shapes: bar and histogram
#   PART B (Thursday) -- two more shapes (boxplot, scatter), the
#                        which-chart-when card, YOUR county, and the
#                        Assignment 1 walkthrough (A1 is due Monday!)
#
# Where we are. After labs 1 and 2 you can already:
#   - save objects with <- and chain steps with the pipe %>%
#   - pull Census data with get_acs() and question it with filter(),
#     arrange(), select(), and mutate()
#   - find any variable in the Census catalog with load_variables() + View()
# And you have SEEN a ggplot built in layers -- once, quickly, at the end
# of Thursday night. Charts deserve better than quickly: they are how every
# finding you make this term will reach other people. So this lab does two
# jobs at once:
#
#   1. Build the course's first real MEASURE from raw Census counts: the
#      share of renter households in every neighborhood that is
#      rent-burdened. (Assignment 2 asks you to build a measure like this
#      for your own area -- tonight is the template.)
#   2. Teach charts properly, with repetition: the four basic chart
#      shapes, what QUESTION each one answers, and when to reach for
#      which. We rebuild the ggplot moves from lab 2 slowly, then extend
#      them -- repetition is how this sticks.
#
# This week's reading (Walker, chapters 3 and 4 -- due Thursday) is this
# lab in book form: chapter 3 is the wrangling verbs, chapter 4 the
# charts. Tuesday runs a little ahead of the reading; everything here is
# taught from zero, and the book then makes a first-rate second pass.
#
# Assignment 1 is due Monday July 27 at 5pm. Section 13 walks through a
# complete example so you know exactly what to submit.
#
# (As always, start from a fresh RStudio session via the RStudio link on
# the course site, so the newest course files pull in automatically.)
#
# Open the toolboxes (installed back in lab 1 -- nothing new to install):

library(tidyverse)
library(tidycensus)

# ==========================================================================
# ==========================================================================
# PART A -- TUESDAY: THE LADDER, THE TABLES, THE MEASURE, TWO CHARTS
# ==========================================================================
# ==========================================================================

# ==========================================================================
# 1. The geography ladder (what you just saw in Social Explorer)
# ==========================================================================
# We opened tonight in Social Explorer, zooming from the whole country down
# toward city blocks. What you were climbing is the Census Bureau's
# geography LADDER -- each rung a set of polygons that nest inside the
# rung above:
#
#   nation  >  states  >  counties  >  TRACTS  >  block groups  >  blocks
#
# The rung this course lives on is the CENSUS TRACT: a small area the
# Bureau draws to approximate a neighborhood -- roughly 1,200 to 8,000
# people, about 4,000 on average. Displacement is a neighborhood story, so
# tracts are where it becomes visible. (Below tracts sit block groups,
# roughly 600 to 3,000 people -- the smallest rung the ACS publishes --
# and then blocks, which only the every-ten-years decennial count covers:
# a survey sample gets too thin that far down.)
#
# (Last week's reading drew this exact picture: Walker chapter 1,
# section 1.2, "Census hierarchies" -- nesting diagram included.)
#
# Here is the payoff of the tour: in get_acs(), the ladder is just the
# geography input. Watch ONE variable -- B25071_001, lab 1's median rent
# burden -- at three rungs of the ladder. First, the state as one polygon:

ca_burden_state <- get_acs(
  geography = "state",
  variables = "B25071_001",   # median renter's burden -- lab 1's variable
  state     = "CA",
  year      = 2024
)

ca_burden_state

# One row. One number for the whole state, and it is worth reading out
# loud: the median California renter household pays 32.8% of its income
# in rent. The TYPICAL renter in this state is past the 30% burden line.
# But one number that size hides everything local. One rung down:

ca_burden_county <- get_acs(
  geography = "county",       # the only line that changed
  variables = "B25071_001",
  state     = "CA",
  year      = 2024
)

ca_burden_county

nrow(ca_burden_county)

# 58 rows -- one per California county. This is exactly the table you
# pulled in lab 1, and where the Humboldt lesson lived. One more rung:

alameda_burden_tract <- get_acs(
  geography = "tract",        # down to neighborhoods
  variables = "B25071_001",
  state     = "CA",
  county    = "Alameda",      # tracts are requested county by county
  year      = 2024
)

nrow(alameda_burden_tract)

# 379 rows: every census tract in Alameda County -- home of Oakland and
# Berkeley. ONE county holds 379 neighborhoods. (A whole state of tracts
# is a big download; one county is plenty, and kinder to the DataHub.)
# Look at the first rows:

alameda_burden_tract

# Two columns are worth reading closely. NAME spells out the nesting in
# words: "Census Tract 4001; Alameda County; California". And GEOID spells
# it out as an ID. Read 06001400100 left to right:
#
#   06      = California       (the state)
#   001     = Alameda County   (so 06001 is the county's full ID)
#   400100  = tract 4001       (the neighborhood)
#
# The ID nests exactly the way the polygons nest. File that away: in lab
# 4, GEOIDs are how eviction court records find their census tract -- and
# how numbers find their polygon when we start drawing MAPS. Every shape
# you saw in Social Explorer tonight is waiting to be drawn by you, with
# your own measure painted on it. That is where this course is headed,
# and it is the skill your final project presentation leans on.
#
# So why not always use the smallest area? Because the ACS is a SAMPLE:
# the smaller the area, the fewer surveyed households behind each number,
# the shakier the estimate. State numbers are rock solid; tract numbers
# wobble. That trade-off -- detail versus reliability -- comes back at
# the end of Part A.

# ==========================================================================
# 2. How Census tables are named
# ==========================================================================
# Every ACS variable code has two parts. Take B19013_001 -- the median
# household income variable you met in lab 2:
#
#   B19013  = the TABLE (one topic: "Median Household Income")
#   _001    = the LINE within the table (line 001 is almost always the
#             total -- everyone the table counts)
#
# Two kinds of tables will cover most of what you do in this course, and
# mixing them up is the most common Census mistake there is:
#
#   DOLLAR tables report an amount. B19013_001 is "median household income
#   in dollars" -- ONE number that summarizes a place.
#
#   COUNT tables report how many households fall in each bucket. B19001
#   splits households into income buckets: line 002 is "less than
#   $10,000", line 017 is "$200,000 or more". Each line is a COUNT of
#   households, not a dollar amount.
#
# Let's look at both in the catalog -- the exact call from lab 2:

vars_2024 <- load_variables(2024, "acs5")
View(vars_2024)

# In the View search box, type  B19013  -- read the label column: "Median
# household income..." That is a dollar amount.
# Now search  B19001  -- lines 002 through 017 are income buckets. Counts.
#
# One more thing you will see in the catalog: letters after a table
# number, like B19013B. The letter is a RACE OR ETHNICITY version of the
# same table (A = White alone, B = Black alone, D = Asian alone,
# I = Hispanic or Latino -- we used these in lab 2). Same table, same
# meaning, restricted to householders in that group.
#
# +------------------------------------------------------------------+
# | THE UNIVERSE RULE (the one rule to never break)                  |
# |                                                                  |
# | Every count table counts a specific UNIVERSE -- the group of     |
# | people or households it describes. Line _001 IS that universe.   |
# | When you turn counts into a percentage, you ALWAYS ALWAYS ALWAYS |
# | divide by that same table's _001 -- never by a total from some   |
# | other table. Different tables count different universes (all     |
# | households vs. renter households vs. people), and mixing them    |
# | produces percentages that are quietly, confidently wrong.        |
# +------------------------------------------------------------------+

# YOUR TURN (1): search the catalog for  B25064 . Read its label and
# concept. Is it a dollar table or a count table? What is it measuring,
# in plain English?
# [PUT YOUR ANSWER BELOW AS A COMMENT]
#

# ==========================================================================
# 3. Tonight's question -- and hunting down its table yourself
# ==========================================================================
# Section 1's B25071 gave us the burden of the TYPICAL (median) renter
# household: one number per place. Useful -- but it hides everyone who is
# not the typical household. A county where the median renter pays 29%
# looks "fine" even if a third of its renters pay over half their income.
#
# The researcher's move is to ask about the DISTRIBUTION: what SHARE of
# renter households pay 30% or more? For that we need a COUNT table --
# and this time YOU find it. Go back to the catalog tab (or run
# View(vars_2024) again) and type into the search box:
#
#     gross rent as a percentage
#
# The concept that surfaces is "Gross Rent as a Percentage of Household
# Income in the Past 12 Months" -- table B25070. This is the bucket-by-
# bucket version of the story B25071 compressed into one median: it files
# every renter household by how much of its income the rent eats.
# Reading the lines you just found:
#
#   B25070_001  total renter households        <- the universe
#   B25070_002  paying < 10% of income
#     ... (buckets climb in steps) ...
#   B25070_007  paying 30.0 - 34.9%            <- burdened starts here
#   B25070_008  paying 35.0 - 39.9%
#   B25070_009  paying 40.0 - 49.9%
#   B25070_010  paying 50% or more             <- "severe" burden
#   B25070_011  not computed (no cash rent, or no income reported)
#
# And check the universe while you are there: renter-occupied housing
# units. So our measure is
#
#   (B25070_007 + B25070_008 + B25070_009 + B25070_010) / B25070_001
#
# -- the share of renter households at or past the 30% cost-burden line.
# This is a measure the Eviction Research Network actually uses, and you
# are about to build it from scratch for every neighborhood in Alameda
# County.

# ==========================================================================
# 4. Pulling several variables at once
# ==========================================================================
# We need five B25070 lines, so we hand get_acs() a c() vector of codes --
# exactly like the county vectors from lab 2, just with variable codes.
# Good practice you should copy: comment every code with its plain-English
# meaning. Your future self will thank you; so will your grader.
#
# And one STOWAWAY: we tuck B19013_001 -- median household income, the
# dollar table from section 2 -- into the same pull. Not for tonight's
# arithmetic: the universe rule stands, and income will never enter the
# burden formula. But Part B's scatter plot wants income and burden side
# by side, and pulling them together now saves a second trip.

rb_vars <- c(
  "B25070_001",  # total renter households (the universe)
  "B25070_007",  # paying 30.0 - 34.9% of income on rent
  "B25070_008",  # paying 35.0 - 39.9%
  "B25070_009",  # paying 40.0 - 49.9%
  "B25070_010",  # paying 50% or more
  "B19013_001"   # median household income -- dollar stowaway, for Part B
)

rb_vars

# Now the pull: section 1's tract call with the vector swapped in.

alameda_raw <- get_acs(
  geography = "tract",
  variables = rb_vars,       # our commented vector of codes
  state     = "CA",
  county    = "Alameda",
  year      = 2024
)

# Meet the data, lab-1 style:

alameda_raw
nrow(alameda_raw)

# 2,274 rows. Why so many? Alameda County has 379 tracts, and we asked
# for 6 variables: 379 x 6 = 2,274. Every tract-variable pair gets its
# OWN ROW. Look at the printout: the same tract appears six times, once
# per variable, stacked vertically.
#
# This shape is called LONG data. The Census always hands you long data by
# default.

# ==========================================================================
# 5. Reshaping: pivot_wider()
# ==========================================================================
# For math BETWEEN variables ("add columns 007 through 010, divide by
# 001") we want each tract on ONE row with the variables side by side as
# COLUMNS. That shape is called WIDE data.
#
# Picture one tract making the trip -- tract 4002, the second row of
# your data, exactly as the Census sent it. LONG: six rows, all the
# SAME tract.
#
#     NAME         variable     estimate
#     Tract 4002   B19013_001     208438
#     Tract 4002   B25070_001        342
#     Tract 4002   B25070_007         22
#     Tract 4002   B25070_008          5
#     Tract 4002   B25070_009          4
#     Tract 4002   B25070_010         33
#
# WIDE: the same tract as ONE row, variables fanned out as columns,
# ready for add-and-divide.
#
#     NAME         B19013_001  B25070_001  B25070_007  B25070_008  ...
#     Tract 4002       208438         342          22           5  ...
#
# Nothing is lost and nothing is computed -- the same six numbers,
# hinged from vertical to horizontal. That is ALL pivoting is.
#
# The verb that goes from long to wide is pivot_wider(). It needs to know
# two things:
#   names_from  = which column holds the future COLUMN NAMES
#   values_from = which column holds the future CELL VALUES
#
# Before aiming it at 2,274 rows of Census data, practice the move on a
# table small enough to check every number by eye. Remember three_cities
# from lab 1, section 4 -- the tiny table you built by hand? Here it is
# again, except MELTED into the long shape the Census uses: one row per
# city-measure pair.

three_cities_long <- data.frame(
  city    = c("Oakland", "Oakland", "Fresno", "Fresno", "Chico", "Chico"),
  measure = c("rent", "income", "rent", "income", "rent", "income"),
  value   = c(2200, 6100, 1300, 4400, 1400, 4300)
)

three_cities_long

# Six rows: every city appears twice, once per measure -- exactly how
# the Census would deliver it. Now hand pivot_wider() its two inputs:

three_cities_long %>%
  pivot_wider(
    names_from  = measure,   # this column's values become column NAMES
    values_from = value      # this column's values fill the cells
  )

# Three rows, and rent and income sit side by side as columns again --
# the exact table you typed by hand in lab 1. Six long rows in, three
# wide rows out, every number accounted for, nothing lost. That is the
# whole move.
#
# Now the real Alameda table. Same verb, same two inputs, so this
# SHOULD just work:

alameda_messy <- alameda_raw %>%
  pivot_wider(
    names_from  = variable,
    values_from = estimate
  )

alameda_messy
nrow(alameda_messy)

# Something is wrong. We expected 379 rows -- one per tract -- and got
# 2,169, riddled with NA (R's symbol for "missing"). This is the single
# most common reshaping accident in Census work, so let's understand it
# instead of fearing it.
#
# The culprit is the moe column we ignored. Each of a tract's six rows
# has a DIFFERENT margin of error, so R sees six rows that do NOT match,
# refuses to merge them, and gives each its own mostly-empty row. R did
# exactly what we asked; we just asked badly. No error message, either --
# which is why you always LOOK at your data after every step.
#
# The fix: drop moe (with select's minus sign, from lab 2) BEFORE
# pivoting, so the rows collapse cleanly:

alameda_wide <- alameda_raw %>%
  select(-moe) %>%          # set the margin-of-error column aside
  pivot_wider(
    names_from  = variable,
    values_from = estimate
  )

alameda_wide
nrow(alameda_wide)

# 379 rows, one per tract: five tidy columns of counts plus the income
# stowaway. (R ordered the value columns alphabetically, which is why
# B19013_001 landed first -- column order carries no meaning.) We will
# come back to what dropping moe costs us at the end of Part A -- it is
# not free, just deferred.

# YOUR TURN (2): in the Console, run  alameda_wide %>% View()  and scroll.
# Every B25070 column should be a whole-number count of households; the
# B19013_001 column is dollars (the stowaway). Which tract number is the
# FIRST row, and how many total renter households does it have (the
# B25070_001 column)?
# [PUT YOUR ANSWER BELOW AS A COMMENT]
#

# ==========================================================================
# 6. Building the measure with mutate()
# ==========================================================================
# Now the payoff, and it is two lines of arithmetic. mutate() (from lab 2)
# adds new columns computed from existing ones:

alameda_rb <- alameda_wide %>%
  mutate(
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb     = rb_count / B25070_001    # divide by the UNIVERSE (rule!)
  )

# Look at what we made (select keeps the printout readable):

alameda_rb %>%
  select(NAME, B25070_001, rb_count, p_rb)

# p_rb is a PROPORTION: 0.45 means 45% of that tract's renter households
# are rent-burdened. Let's inspect it the way a researcher would:

summary(alameda_rb$p_rb)
alameda_rb %>%
  filter(p_rb == 1) %>% data.frame()

# Read that summary line slowly -- three things worth noticing:
#
#   1. The MEDIAN is about 0.47: in the typical Alameda County tract,
#      nearly HALF of renter households are rent-burdened. Sit with that.
#   2. Min is 0 and Max is 1 -- a proportion must live between 0 and 1.
#      If you ever see 1.4 or -0.2, you broke the universe rule (wrong
#      denominator) -- go back and check your _001.
#   3. There are 2 NA's. Two tracts have no value at all. Why?

alameda_rb %>%
  filter(is.na(p_rb)) %>%
  select(NAME, B25070_001, rb_count, p_rb)

# Both tracts have ZERO renter households -- so p_rb was 0 divided by 0,
# which is not a number. (One of these "tracts" is mostly open water on
# the Bay; the Census keeps a tract for it anyway.) Dividing by zero
# happens constantly in real data. The fix is if_else(): a function that
# picks between two values based on a yes/no question --
#   if_else(test, value_if_yes, value_if_no)

alameda_rb_clean <- alameda_rb %>%
  mutate(
    p_rb = if_else(is.na(p_rb), 0, p_rb)
    #      if p_rb is missing -> use 0; otherwise -> keep p_rb as is
  )
alameda_rb_clean
summary(alameda_rb_clean$p_rb)

# No more NA's. Note we saved the fixed table under a NEW name instead of
# overwriting alameda_rb. Habit worth copying: when a step CHANGES your
# data, give the result a new name. If something looks wrong later, you
# can walk back through the chain of objects and find where it broke.

# ======================= PICK UP HERE ON THURSDAY =========================

# ==========================================================================
# 7. Charts, done right this time: which plot answers which question?
# ==========================================================================
# Thursday night we sprinted through your first ggplot in the last minutes
# of class. Tonight we walk it -- because the secret nobody tells
# beginners is that choosing a chart is not about taste. Every basic
# chart shape answers ONE KIND of question:
#
#   "How does a value COMPARE across a few places?"   -> bar chart
#   "How is one number SPREAD across many places?"    -> histogram
#   "How do whole spreads compare, group by group?"   -> boxplot
#   "Do TWO numbers move TOGETHER?"                   -> scatter plot
#   (and "how does it move over TIME?" -> line chart, waiting in
#    section 15)
#
# You will build all four in this lab, every one of them from tonight's
# rent-burden measure. Keep the ggplot2 cheat sheet open while you plot
# -- two pages that map every basic chart to its geom_*() function, with
# the polish layers on page two. Bookmark it; it is the reference I still
# reach for:
#
#   https://opensource.posit.co/resources/cheatsheets/data-visualization/
#
# (A PDF copy also ships in this course's repo: docs/cheatsheets/
# data-visualization.pdf -- and more cheat sheets live in that folder.)
#
# Thursday's reading pairs with this whole section: Walker chapter 4
# builds these same shapes on Census data -- histograms, bar charts,
# boxplots, scatters with trend lines -- plus, in his section 4.3, the
# margin-of-error bars we defer to the book.
#
# And the sixty-second recap of how ggplot thinks, from lab 2:
#
#   ggplot(data)              1. start a canvas from a table
#     + aes(x = , y = )       2. MAP columns to visual slots
#     + geom_something()      3. add a layer that draws shapes
#     + labs(), theme_...()   4. words, then polish
#
# Layers stack with +, one at a time. Inside aes() = a MAPPING (the look
# varies with your data). Outside aes() = a SETTING (one look for
# everything, chosen by you). That distinction is half of ggplot; you met
# it Thursday and you will use it four more times before this lab ends.

# --------------------------------------------------------------------------
# 7.1 The BAR chart: compare a few places
# --------------------------------------------------------------------------
# Question: how does renter burden COMPARE across Bay Area counties?
# A bar chart wants a handful of rows with one number each. We have 379
# tract rows -- the wrong shape for this question -- so pull the same
# B25070 table at the COUNTY rung of section 1's ladder, for five Bay
# counties, and rebuild the measure. Read this chain out loud: pull, and
# then drop moe, and then widen, and then compute. It is sections 4
# through 6 in one breath -- thirty seconds of typing now that you know
# the moves. That is what the repetition buys.

bay_raw <- get_acs(
  geography = "county",      # the ladder again -- county rung this time
  variables = rb_vars,       # the SAME commented vector
  state     = "CA",
  county    = c("Alameda", "Contra Costa", "San Francisco",
                "San Mateo", "Solano"),
  year      = 2024
)

bay_rb <- bay_raw %>%
  select(-moe) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb     = rb_count / B25070_001
  )

bay_rb %>% select(NAME, p_rb)

# Five rows, five shares. You can read them as numbers -- but a chart
# makes the comparison instant, so let's build one properly, one layer
# at a time. Base + bars first, exactly like lab 2:

ggplot(bay_rb, aes(x = NAME, y = p_rb)) +
  geom_col()

# Bars -- and a mess. Five long county names shoulder-to-shoulder on the
# x-axis, printed over each other. County names are almost always too
# long for the bottom of a chart, so here is the move to memorize: SWAP
# the aes slots, and the bars turn sideways.

ggplot(bay_rb, aes(x = p_rb, y = NAME)) +
  geom_col()

# Horizontal bars, every label readable. Next problem, same as lab 2:
# R ordered the counties alphabetically, which scrambles the story. The
# fix is also the same -- reorder() -- just aimed at the y slot now:
# "put NAME in order of p_rb."

ggplot(bay_rb, aes(x = p_rb, y = reorder(NAME, p_rb))) +
  geom_col()

# Sorted: heaviest burden on top, lightest on the bottom. Now a color --
# outside aes(), because this is a SETTING (one look for all bars, our
# choice), not a mapping:

ggplot(bay_rb, aes(x = p_rb, y = reorder(NAME, p_rb))) +
  geom_col(fill = "steelblue")

# Then the words. A finished chart carries its own story: a title that
# STATES THE FINDING, a subtitle that says exactly what data this is,
# axis labels, a source caption. (y = NULL because the county names
# already explain themselves.)

ggplot(bay_rb, aes(x = p_rb, y = reorder(NAME, p_rb))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "The Bay Area's heaviest rent burden is where rents are cheapest",
    subtitle = "Share of renter households paying 30%+ of income, 2020-2024 ACS",
    x        = "Share of renter households rent-burdened",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates, table B25070."
  )

# Last polish, and one new friend: lab 2 dressed a money axis with
# dollar_format(); its cousin percent_format() turns our 0.57 into 57%.
# Save the finished chart as an object, print it, ggsave it:

bay_bar <- ggplot(bay_rb, aes(x = p_rb, y = reorder(NAME, p_rb))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "The Bay Area's heaviest rent burden is where rents are cheapest",
    subtitle = "Share of renter households paying 30%+ of income, 2020-2024 ACS",
    x        = "Share of renter households rent-burdened",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates, table B25070."
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::percent_format())

bay_bar

ggsave("~/lab3_bay_rent_burden.png", bay_bar, width = 8, height = 5)

# Read it like a sociologist, top to bottom: Solano 57%, Contra Costa
# 53%, Alameda 48%, San Mateo 46%, San Francisco 38%. Now hold that
# against 2024 median rents: Solano has the CHEAPEST rent of these five
# counties ($2,163 a month) and the heaviest burden; San Mateo has the
# priciest ($2,922) and sits near the bottom; famously expensive San
# Francisco ($2,476) is lightest of all. Burden is rent RELATIVE TO
# INCOME -- lab 1's Humboldt lesson, now across the Bay. Where rents are
# low but incomes are lower still, the squeeze is worst. Remember Solano
# and San Francisco: they return in section 9's boxplot and section 15's
# time series.
#
# That title, by the way, is a habit to steal: state the FINDING, not the
# topic. "Rent burden by county" describes; this title argues.

# --------------------------------------------------------------------------
# 7.2 The HISTOGRAM: the spread of one number
# --------------------------------------------------------------------------
# The bar chart compared five summary numbers -- one per county. But
# section 6's summary() told us Alameda's own tracts run all the way from
# 0 to 1. Five bars can never show that. When the question is "how is
# one number SPREAD across hundreds of places?", the shape is a
# HISTOGRAM: it chops p_rb's range into bins and draws one bar per bin,
# as tall as the number of tracts that land in it.
#
# Same layer game as 7.1. Base + bars -- a histogram needs only an x,
# because the bar heights are computed for you:

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram()

# It works, and R prints a message: it guessed 30 bins and is telling you
# to pick a better value. (Remember: a message is not an error.) Take
# control of the bins -- one new input:

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25)

# Bar colors: fill for the inside, color for the outline (the outline
# makes adjacent bars readable). Both outside aes() -- settings again:

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25, fill = "steelblue", color = "white")

# Labels and the clean theme, exactly like 7.1:

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25, fill = "steelblue", color = "white") +
  labs(
    title    = "Rent burden across Alameda County neighborhoods",
    subtitle = "Share of renter households paying 30%+ of income, by tract (2020-2024 ACS)",
    x        = "Share of renter households rent-burdened",
    y        = "Number of tracts",
    caption  = "Source: ACS 5-year, table B25070."
  ) +
  theme_minimal()

# Last layer: mark the median so readers can anchor themselves. In lab 2
# the dashed line sat at a number we grabbed from a table; here we
# COMPUTE where the line goes, right inside the layer:

rb_hist <- ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25, fill = "steelblue", color = "white") +
  geom_vline(xintercept = median(alameda_rb_clean$p_rb), linetype = "dashed") +
  labs(
    title    = "Rent burden across Alameda County neighborhoods",
    subtitle = "Share of renter households paying 30%+ of income, by tract (2020-2024 ACS)",
    x        = "Share of renter households rent-burdened",
    y        = "Number of tracts",
    caption  = "Source: ACS 5-year, table B25070. Dashed line = median tract."
  ) +
  theme_minimal()

rb_hist

# (~ in the file name = your home folder -- same trick as lab 2.)
ggsave("~/lab3_alameda_rent_burden.png", rb_hist, width = 8, height = 5)

# How to read it: the mass of tracts sits between roughly 0.37 and 0.57,
# the dashed median line lands just above 0.47, and a tail of
# neighborhoods stretches toward 0.8 and beyond. Rent burden in Alameda
# County is not a few bad blocks -- it is the ordinary condition of
# renting, with some neighborhoods in outright crisis. THAT is what the
# bar chart's single 48% bar was hiding.
#
# A DATA HUMILITY note before you trust any single tract: we dropped moe
# to make the pivot work, but tract-level counts have LARGE margins of
# error -- far larger, relatively, than the county numbers (fewer
# surveyed households per tract -- section 1's trade-off, cashing in).
# The overall SHAPE of this histogram is trustworthy; the exact value of
# any one tract is not. Rule of thumb for this course: use tracts to see
# patterns, not to rank individual neighborhoods against each other.
# (The grown-up fix -- carrying each estimate's moe through your math
# instead of dropping it -- is Walker section 3.5, in this week's
# reading.)

# ---- End of Part A -------------------------------------------------------
# Tuesday's haul: the geography ladder, dollar vs. count tables, the
# universe rule, long-to-wide reshaping, a real measure -- and two chart
# shapes chosen by their questions. Thursday: two more shapes, the
# chart-picker card, YOUR county, and the Assignment 1 walkthrough.
# (If class pacing moved the boundary, no harm -- nothing below assumes a
# particular night.)
# --------------------------------------------------------------------------

# ==========================================================================
# ==========================================================================
# PART B -- THURSDAY: TWO MORE SHAPES, YOUR COUNTY, AND ASSIGNMENT 1
# ==========================================================================
# ==========================================================================
# Fresh RStudio session tonight? Then the objects from Tuesday are gone
# from memory, and Part B needs them. Fastest reboot: run the script from
# the top down through section 7 (click line 1, then Code menu > Run
# Region > Run All is one way; re-running the pulls takes well under a
# minute). Then meet us back here.

# ==========================================================================
# 8. Two new verbs: summarize() and group_by()
# ==========================================================================
# --------------------------------------------------------------------------
# 8.1 summarize(): boil many rows down to one
# --------------------------------------------------------------------------
# Back to Tuesday's tract table, alameda_rb_clean. filter() and mutate()
# keep one row per tract. summarize() COLLAPSES the whole table into a
# single summary row. You name the new columns and say how to compute
# each one:

alameda_rb_clean %>%
  summarize(
    tracts    = n(),              # n() counts rows -- no inputs needed
    avg_p_rb  = mean(p_rb),
    median_rb = median(p_rb)
  )

# 379 tracts, average tract burden share around 46%.

# --------------------------------------------------------------------------
# 8.2 group_by(): summarize within groups
# --------------------------------------------------------------------------
# summarize() gets truly powerful when you group first. group_by() by
# itself changes nothing you can see -- it just tags the table with "when
# you summarize, do it PER GROUP."
#
# Let's ask: how many tracts are MAJORITY-burdened -- where more than
# half of renter households pass the 30% line? First mutate a category,
# then group by it, then count:

alameda_rb_clean %>%
  mutate(
    burden_level = if_else(p_rb > 0.5, "majority burdened", "less than half")
  ) %>%
  group_by(burden_level) %>%
  summarize(tracts = n())

# 158 of Alameda County's 379 tracts -- two of every five neighborhoods --
# have a MAJORITY of renter households rent-burdened. That single table
# is a finding you could put in front of a county supervisor.
# (Walker section 3.3 calls this move "group-wise Census data analysis"
# -- it is the heart of this week's chapter 3 reading.)

# YOUR TURN (3): copy the chunk above and change the 0.5 threshold to
# __ (try 0.3). How many tracts have more than 30% of renters burdened?
# What happens to the story you would tell?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 9. The BOXPLOT: compare whole spreads, group by group
# ==========================================================================
# The 7.1 bar chart compared counties with ONE number each; the 7.2
# histogram showed the full spread of ONE county. The obvious next
# question needs both at once: how do the SPREADS compare across
# counties? Does every county hide as much variety as Alameda?
#
# The shape for that question is the BOXPLOT -- think of it as group_by()
# for your eyes: one compact summary drawing per group, lined up on a
# shared axis.
#
# We need tract-level data for more than one county. You already have
# Alameda (alameda_raw). Pull the same tract table for San Francisco and
# Solano -- the cheapest-rent and priciest-rent poles from 7.1:

sf_tract_raw <- get_acs(
  geography = "tract",
  variables = rb_vars,
  state     = "CA",
  county    = "San Francisco",
  year      = 2024
)

solano_tract_raw <- get_acs(
  geography = "tract",
  variables = rb_vars,
  state     = "CA",
  county    = "Solano",
  year      = 2024
)

# For the chart we need one column that says which county each tract
# belongs to. The recipe is lab 2's stamp-and-stack: mutate() a label
# onto each table, then bind_rows() them into one. After that, the same
# widen-and-measure chain as always -- third time tonight, and it should
# be starting to feel like breathing:

three_counties_rb <- bind_rows(
  alameda_raw      %>% mutate(county = "Alameda"),
  sf_tract_raw     %>% mutate(county = "San Francisco"),
  solano_tract_raw %>% mutate(county = "Solano")
) %>%
  select(-moe) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb     = rb_count / B25070_001
  )

nrow(three_counties_rb)

# 723 rows: Alameda's 379 tracts + San Francisco's 244 + Solano's 100.
# (San Francisco is a whole county with fewer tracts than Alameda;
# Solano is smaller still. County sizes vary wildly -- the ladder again.)
#
# The boxplot maps the GROUP to x and the NUMBER to y:

ggplot(three_counties_rb, aes(x = county, y = p_rb)) +
  geom_boxplot()

# Two things just happened. First, the drawing -- how to read a box:
#
#   the LINE in the middle  = the group's MEDIAN tract (the histogram's
#                             dashed line, one per county)
#   the BOX                 = the middle HALF of tracts (25th to 75th
#                             percentile -- summary()'s quartiles, drawn)
#   the WHISKERS            = the typical range beyond the box
#   the lone DOTS           = outliers -- tracts unusual for their county
#
# Second, R printed a warning: 8 rows removed ("non-finite values").
# Those are our zero-renter tracts -- Alameda's two from section 6 plus
# four in San Francisco and two in Solano, all with no renter households
# to measure. ggplot dropped them and TOLD you. A warning is information,
# not punishment: read it, decide whether it makes sense (here it does),
# move on.
#
# Now finish it -- labels and polish are the same moves as every chart
# tonight:

bay_box <- ggplot(three_counties_rb, aes(x = county, y = p_rb)) +
  geom_boxplot() +
  labs(
    title    = "Same Bay, different spreads of neighborhood rent burden",
    subtitle = "Each box = one county's census tracts, 2020-2024 ACS; middle line = median tract",
    x        = NULL,
    y        = "Share of renter households rent-burdened",
    caption  = "Source: ACS 5-year estimates, table B25070."
  ) +
  theme_minimal() +
  scale_y_continuous(labels = scales::percent_format())

bay_box

ggsave("~/lab3_bay_burden_boxplot.png", bay_box, width = 8, height = 5)

# Read it against 7.1's bar chart. The bars said Solano 57%, San
# Francisco 38% -- one number each. The boxes show what those numbers
# were hiding: Solano's MEDIAN tract (56%) would land in the top quarter
# of San Francisco's distribution; San Francisco's box is the lowest AND
# the tightest (its middle half runs about 30% to 46%); Alameda sprawls
# across nearly the whole range, 0 to 100%. A bar chart of summaries is
# a fine headline -- a boxplot is the honest fine print. When a reader
# asks "but is it like that EVERYWHERE in the county?", this is the
# chart that answers.

# ==========================================================================
# 10. The SCATTER plot: do two numbers move together?
# ==========================================================================
# Every chart so far drew ONE number per place. The last basic shape asks
# a genuinely new kind of question: do TWO numbers move TOGETHER? Time to
# cash in the stowaway from section 4 -- every tract in alameda_rb_clean
# carries its median household income (B19013_001) right next to the
# burden share you built.
#
# State the hypothesis BEFORE looking (good science hygiene): this course
# has argued since week 1 that displacement pressure is an INCOME crisis,
# so burden should run HIGHEST where incomes are LOWEST. Does the data
# agree?
#
# A scatter maps one number to x, the other to y, one DOT per row:

ggplot(alameda_rb_clean, aes(x = B19013_001, y = p_rb)) +
  geom_point()

# Each dot is one tract: its income (left-right) and its burden share
# (up-down). R also warned you: 4 rows removed. Four tracts have no
# published median income (too few households to estimate one), so they
# cannot have a dot. Same lesson as the boxplot -- ggplot dropped them
# and said so out loud.
#
# Also look at the RIGHT EDGE: a vertical stripe of dots stacked at
# $250,001. That is a Census TOP-CODE: any tract whose median income is
# above $250,000 gets reported as exactly 250,001 -- 22 of Alameda's
# richest neighborhoods, filed on one line for privacy and reliability.
# Real data has quirks like this; spotting them is what LOOKING at your
# data means.
#
# Is there a trend in the cloud? geom_smooth() drapes a trend line over
# the dots, with a gray ribbon showing its uncertainty:

ggplot(alameda_rb_clean, aes(x = B19013_001, y = p_rb)) +
  geom_point() +
  geom_smooth()

# (The Console message about "method = 'loess'" is R naming the smoothing
# recipe it picked -- a message, not an error.) Now the full dress: labs,
# theme, and BOTH axis formats you know -- dollars for income,
# percents for burden:

alameda_scatter <- ggplot(alameda_rb_clean, aes(x = B19013_001, y = p_rb)) +
  geom_point() +
  geom_smooth() +
  labs(
    title    = "Rent burden concentrates in Alameda County's lower-income neighborhoods",
    subtitle = "Each dot = one census tract, 2020-2024 ACS",
    x        = "Tract median household income",
    y        = "Share of renter households rent-burdened",
    caption  = "Source: ACS 5-year estimates, tables B25070 and B19013."
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::percent_format())

alameda_scatter

ggsave("~/lab3_alameda_income_burden.png", alameda_scatter, width = 8, height = 5)

# The cloud runs DOWNHILL: as tract income rises, the burdened share
# falls. Concretely: in the poorer half of Alameda's neighborhoods, the
# median tract has 53% of renter households burdened; in the richer
# half, 40%. The hypothesis survives -- rent burden is not spread evenly,
# it POOLS in the neighborhoods with the least income to spare. That is
# the course's soft-displacement argument in a single picture, built by
# you from two Census tables.
#
# But also notice the dots hug the line LOOSELY. Income explains a lot;
# it does not explain everything. Low-burden poor tracts and high-burden
# rich tracts both exist, and asking "what else is going on in those
# places?" is exactly the kind of research question A2 and your final
# project feed on. A scatter that surprises you is a project idea.
#
# (Optional section 16 pushes tonight's finding one level deeper: not
# WHERE burden pools, but WHO carries it -- burden rates computed within
# each household income group.)

# ==========================================================================
# 11. The chart-picker, on one card
# ==========================================================================
# Four shapes, four questions -- plus the time shape waiting in section
# 15. Steal this card for every chart you make this term:
#
#   QUESTION                                          REACH FOR
#   Compare a few places/groups (one number each)     geom_col()        7.1
#   See one number's spread across many rows          geom_histogram()  7.2
#   Compare whole spreads across groups               geom_boxplot()    9
#   Ask whether two numbers move together             geom_point()      10
#   Follow a number through time                      geom_line()       15
#
# Start from your QUESTION, never from the chart you find prettiest. And
# lab 2's storytelling rule still governs everything: ONE comparison per
# chart, readable from the title and axes alone, with you nowhere in the
# room. If a fourth element is creeping in, that is usually a second
# chart trying to happen.
#
# When in doubt, open the cheat sheet -- its first page is this card,
# drawn much bigger:
#   https://opensource.posit.co/resources/cheatsheets/data-visualization/

# ==========================================================================
# 12. YOUR TURN (4): build it all for a county you care about
# ==========================================================================
# Rebuild the whole arc, start to finish, for another county -- ideally
# the place you are eyeing for Assignment 1 and beyond. Fill the two
# blanks, then run each step:

my_county_raw <- get_acs(
  geography = "tract",
  variables = rb_vars,     # the same commented vector -- reuse is the point
  state     = "__",
  county    = "__",
  year      = 2024
)

# (a) Reshape it: drop moe, pivot wider (copy from Section 5).


# (b) Build rb_count and p_rb with mutate, and fix any NA's with if_else
#     (copy from Section 6). Check summary(): are you inside 0 and 1?


# (c) How many of your tracts are majority-burdened? (Section 8.2.)


# (d) Make the histogram with a median line and ggsave it (Section 7.2).


# (e) Pick ONE more shape from section 11's card and build it for your
#     place -- whichever answers a question you actually have. Ideas: the
#     7.1 bar across your county and its neighbors; the section 10
#     scatter for your county's tracts (the income stowaway is already
#     in my_county_raw). Title it so it states YOUR finding.


# (f) In one or two sentences: how does your county compare to Alameda?
#     Higher burden? Wider spread? Any surprises?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 13. Assignment 1: exactly what to do (due Monday July 27, 5pm)
# ==========================================================================
# A1 is deliberately SIMPLER than what you just did. From the syllabus:
#
#   Pick a county, set of counties, or region you care about -- you will
#   keep working with this same area all term.
#     1. Use get_acs() to pull ONE ACS variable that says something about
#        housing precarity (rent burden, median rent, share who rent...).
#     2. Make ONE chart of it (a bar chart across your counties works --
#        and after 7.1 you know to turn it sideways).
#     3. Write 2-3 sentences describing what the chart shows and anything
#        that surprised you.
#   Submit: your R script, the chart image, your sentences, and the
#   public share link(s) for any AI conversations you used. Keep it
#   simple -- no bibliography needed yet.
#
# Everything A1 needs, you learned in labs 1 and 2 -- and this lab handed
# you the chart-picker card and a worked example of every shape. This
# lab's measure-building is where Assignment 2 goes next (A2 asks you to
# COMBINE variables into a measure for your area -- what we just did).
#
# Now open the model answer:  code/a1_example.R  -- a complete A1
# submission for five Washington counties, with the interpretation
# sentences and the AI-citation format shown inline. Read it top to
# bottom, run it, then swap in your own place and variable.
#
# Grader's checklist (this is literally what gets checked):
#   [ ] Script runs top to bottom on the DataHub with no edits
#   [ ] The chart has a title, labeled axes, and a source caption
#   [ ] The chart file is saved with ggsave() and attached
#   [ ] 2-3 honest sentences -- describe, then interpret
#   [ ] AI share links pasted as comments next to the code they helped

# ==========================================================================
# 14. What you can do now (and what's next)
# ==========================================================================
# In this lab you learned to:
#   - climb the Census geography ladder inside get_acs() -- state,
#     county, tract -- and read the nesting in a GEOID
#   - read a Census table code: table + line, dollars vs. counts
#   - respect the universe rule (divide by the table's own _001, always)
#   - hunt down the table you need in the catalog yourself (B25070)
#   - reshape long data to wide with select(-moe) + pivot_wider()
#   - build a real measure with mutate() and guard it with if_else()
#   - collapse rows with summarize(), by group with group_by()
#   - pick a chart by its QUESTION, and build all four basic shapes:
#     bar (compare places), histogram (one spread), boxplot (spreads by
#     group), scatter (two numbers together)
#   - read R's messages and warnings without flinching -- and catch data
#     quirks like the $250,001 top-code by LOOKING
#   - distrust any single tract estimate (and say why)
#
# NEXT LAB (Tue Jul 28): we leave the Census for the first time. You will
# load eviction filings data collected by the Eviction Research Network
# -- court records, not surveys -- join it TO census data (keyed on
# section 1's GEOIDs), and compute eviction rates. And then: MAPS. The
# tract polygons you toured in Social Explorer come back with YOUR
# numbers painted on them -- the skill your final project presentation
# leans on. Hard displacement meets soft displacement, on one map. (Next
# week's reading is matched to it: the assigned slices of Walker
# chapters 5-6 are the simple core of Census mapping -- nothing more.)
#
# Between labs: A1 is due Monday. Start tonight if you can -- twenty
# minutes while lab 3 is fresh beats two hours on Sunday. Errors? Same
# drill as always -- read it out loud, paste the full message to your AI,
# ask for the explanation before the fix, keep the share link.
# ==========================================================================

# ==========================================================================
# 15. EXTRA PRACTICE (optional): the burden over TIME
# ==========================================================================
# Everything in this lab was one year. But the question a county
# supervisor actually asks is "is it getting WORSE?" -- and answering it
# just means running this lab's build for several years and letting the
# x-axis be year. This closing section is optional, for after class. (If
# you did lab 2's optional section 10, the two chart ideas at the end are
# review; everything else here is new and taught from zero.)
#
# (Walker section 3.4 -- in this week's reading -- is this exact topic,
# comparing ACS estimates over time, and its "some cautions" subsection
# is worth two minutes before you trust any year-over-year move.)
#
# The plan: (1) turn the build into a reusable RECIPE, (2) run the
# recipe for 2016, 2020, and 2024, (3) stack the results, (4) draw lines.
# We work at the COUNTY level -- three counties to compare -- so each
# year is one small, quick pull.

# --------------------------------------------------------------------------
# 15.1 function(): turn your build into a recipe
# --------------------------------------------------------------------------
# You have been USING functions all course -- get_acs(), mutate(), and
# median() are recipes somebody else wrote. Tonight you write one. The
# shape:
#
#   recipe_name <- function(blank) { steps that use the blank }
#
# Our steps are sections 4-6 glued into one chain -- pull the B25070
# counts (county level this time), drop moe, widen, compute the share.
# The only thing that changes between runs is the year, so the year is
# the blank:

burden_one_year <- function(y) {
  get_acs(
    geography = "county",
    variables = rb_vars,       # the same commented vector from section 4
    state     = "CA",
    county    = c("Alameda", "San Francisco", "Solano"),
    year      = y
  ) %>%
    select(-moe) %>%
    pivot_wider(names_from = variable, values_from = estimate) %>%
    mutate(
      year     = y,            # stamp the rows with the year they came from
      rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
      p_rb     = rb_count / B25070_001
    )
}

# Running that block SAVES the recipe (check the Environment pane -- it
# is listed under Functions) but cooks nothing yet. Cook once, filling
# the blank with 2016:

burden_one_year(2016)

# Three rows -- Alameda, San Francisco, and Solano in 2016 -- with the
# same p_rb you built in section 6, plus the year stamp. (The income
# stowaway rides along; ignore it here.) These are section 9's boxplot
# counties -- and remember what the boxes showed: Solano's whole
# distribution sat highest. Now we watch it move.

# --------------------------------------------------------------------------
# 15.2 map(): run the recipe once per year
# --------------------------------------------------------------------------
# You could type burden_one_year(2020) and burden_one_year(2024) and
# stack the printouts by hand. map() does the repetition for you: hand
# it a c() of years and the recipe, and it runs the recipe on each one:

burden_list <- map(c(2016, 2020, 2024), burden_one_year)

# (Notice: no parentheses after burden_one_year in that line. We are
# handing map() the recipe itself, not one cooked result.) Back comes a
# LIST of three tables, one per year. list_rbind() stacks a list of
# tables into one table -- the same job bind_rows() did in lab 2:

burden_over_time <- burden_list %>% list_rbind()

burden_over_time %>% select(year, NAME, p_rb)

# Nine rows: 3 counties x 3 years. This recipe-map-stack pattern is the
# workhorse of temporal analysis, and you will meet it again in the
# bonus lab, looping over whole states.

# --------------------------------------------------------------------------
# 15.3 A new layer: geom_line()
# --------------------------------------------------------------------------
# geom_col() drew one bar per row; geom_line() CONNECTS the rows with a
# line -- the natural shape for time. One county first (filter, lab 1):

alameda_over_time <- burden_over_time %>%
  filter(NAME == "Alameda County, California")

ggplot(alameda_over_time, aes(x = year, y = p_rb)) +
  geom_line()

# Alameda's renter burden dipped into 2020 and climbed most of the way
# back by 2024. But one county alone has no comparison, and comparison
# is the whole game. We want all three, each with its own line.

# --------------------------------------------------------------------------
# 15.4 Color INSIDE aes(): one line per county
# --------------------------------------------------------------------------
# All lab long you SET colors -- fill = "steelblue", outside aes(): one
# look for everything, chosen by you. Put color INSIDE aes() and point
# it at a COLUMN, and R draws one line per value of that column, each in
# its own color, with a legend for free:

ggplot(burden_over_time, aes(x = year, y = p_rb, color = NAME)) +
  geom_line()

# Inside aes() = a MAPPING: the look varies with your data. Outside
# aes() = a SETTING: one look for everything. That distinction is half
# of ggplot. Now finish it -- a title that states the finding, like
# every chart in this lab:

ggplot(burden_over_time, aes(x = year, y = p_rb, color = NAME)) +
  geom_line() +
  labs(
    title    = "The heaviest renter burden is not where rents are highest",
    subtitle = "Share of renter households paying 30%+ of income, ACS 5-year snapshots",
    x        = NULL,
    y        = "Share of renter households rent-burdened",
    color    = NULL,
    caption  = "Source: ACS 5-year estimates, table B25070."
  ) +
  theme_minimal()

ggsave("~/lab3_burden_over_time.png", width = 8, height = 5)

# Read it with this lab's eyes. Solano -- the cheapest rents of the three
# (2024 median gross rent: $2,163, vs Alameda's $2,357 and San
# Francisco's $2,476) -- carries the HIGHEST burdened share in all three
# years: 0.54 in 2016, 0.57 in 2024. Famously expensive San Francisco is
# lowest the whole way (about 0.41, then 0.38). Burden is rent RELATIVE
# TO INCOME -- lab 1's Humboldt lesson, now moving through time. And
# notice the shape: every county dipped into 2020, then rose -- but only
# Solano now sits above where it started.
#
# YOUR TURN (5): swap the three counties inside burden_one_year() for
# your own -- your A1/A2 area plus two neighbors -- rerun 15.1 through
# 15.4, and fix the title so it states YOUR finding. Then two sentences:
# what moved, and does it read like soft-displacement pressure building
# or easing?
# [PUT YOUR ANSWER BELOW]
#
# ==========================================================================

# ==========================================================================
# 16. EXTRA PRACTICE (optional): WHO carries the burden?
# ==========================================================================
# Section 10's scatter showed WHERE burden pools -- low-income
# neighborhoods. This last optional section asks the sharper question:
# WHICH HOUSEHOLDS carry it? What share of poor renters are burdened,
# versus middle-income renters, versus rich ones?
#
# One Census table answers it: B25074, "Household Income by Gross Rent as
# a Percentage of Household Income" -- a CROSS-TAB. It takes the renter
# universe you know from B25070 and splits it twice: first into seven
# household income groups, then, inside each group, into the same burden
# buckets. Sixty-four lines in all. This is not a toy: the full 64-line
# version of tonight's vector lives in the Eviction Research Network's
# shared codebase and feeds our precarity models. What you build here is
# the real thing, trimmed to the lines the 30% question needs.
#
# One label to resist before we start: these are the Census's DOLLAR
# buckets, not HUD's AMI tiers from lab 2 (80/50/30% of the area
# median). The two do not line up -- Alameda's very-low-income line
# (50% of median = $64,684, from lab 2's YOUR TURN) lands in the middle
# of the $50k-75k bucket. Converting dollar buckets into true AMI tiers
# takes HUD's special tabulations or interpolation -- genuine research
# plumbing, beyond this course. So when you caption a chart like this
# one, say "by household income," never "by AMI."
#
# --------------------------------------------------------------------------
# 16.1 A bigger named vector -- names ARE the documentation
# --------------------------------------------------------------------------
# Six lines per income group: the group's total (its universe!), the four
# burdened buckets, and "not computed." With 42 codes, per-line prose
# comments would drown you. The professional habit instead: SYSTEMATIC
# names -- <income group>_<piece> -- so every column explains itself.
# The first group is commented in full; after that, the names carry it.

rb_income_vars <- c(
  # under $10,000
  u10k_total = "B25074_002",   # all renter households in this income group
  u10k_b30   = "B25074_006",   # paying 30.0 - 34.9% of income on rent
  u10k_b35   = "B25074_007",   # paying 35.0 - 39.9%
  u10k_b40   = "B25074_008",   # paying 40.0 - 49.9%
  u10k_b50   = "B25074_009",   # paying 50% or more
  u10k_nc    = "B25074_010",   # not computed (no cash rent, or no income)
  # $10,000 - $19,999
  i10_20k_total = "B25074_011", i10_20k_b30 = "B25074_015",
  i10_20k_b35   = "B25074_016", i10_20k_b40 = "B25074_017",
  i10_20k_b50   = "B25074_018", i10_20k_nc  = "B25074_019",
  # $20,000 - $34,999
  i20_35k_total = "B25074_020", i20_35k_b30 = "B25074_024",
  i20_35k_b35   = "B25074_025", i20_35k_b40 = "B25074_026",
  i20_35k_b50   = "B25074_027", i20_35k_nc  = "B25074_028",
  # $35,000 - $49,999
  i35_50k_total = "B25074_029", i35_50k_b30 = "B25074_033",
  i35_50k_b35   = "B25074_034", i35_50k_b40 = "B25074_035",
  i35_50k_b50   = "B25074_036", i35_50k_nc  = "B25074_037",
  # $50,000 - $74,999
  i50_75k_total = "B25074_038", i50_75k_b30 = "B25074_042",
  i50_75k_b35   = "B25074_043", i50_75k_b40 = "B25074_044",
  i50_75k_b50   = "B25074_045", i50_75k_nc  = "B25074_046",
  # $75,000 - $99,999
  i75_100k_total = "B25074_047", i75_100k_b30 = "B25074_051",
  i75_100k_b35   = "B25074_052", i75_100k_b40 = "B25074_053",
  i75_100k_b50   = "B25074_054", i75_100k_nc  = "B25074_055",
  # $100,000 or more
  o100k_total = "B25074_056", o100k_b30 = "B25074_060",
  o100k_b35   = "B25074_061", o100k_b40 = "B25074_062",
  o100k_b50   = "B25074_063", o100k_nc  = "B25074_064"
)

# The pull-and-widen is the same two moves as all lab long -- county
# level, one county:

alameda_by_income <- get_acs(
  geography = "county",
  variables = rb_income_vars,
  state     = "CA",
  county    = "Alameda",
  year      = 2024
) %>%
  select(-moe) %>%
  pivot_wider(names_from = variable, values_from = estimate)

# Before trusting a new table, CHECK ITS UNIVERSE against one you know.
# The seven group totals should add up to every renter household in the
# county -- the exact B25070_001 number sitting in section 7.1's bay_rb:

alameda_by_income %>%
  mutate(
    all_groups = u10k_total + i10_20k_total + i20_35k_total +
                 i35_50k_total + i50_75k_total + i75_100k_total +
                 o100k_total
  ) %>%
  select(NAME, all_groups)

bay_rb %>%
  filter(NAME == "Alameda County, California") %>%   # full name, always
  select(NAME, B25070_001)

# 272,737 and 272,737. Same universe, sliced two ways -- B25074 passes.
# Run a check like this every time a new table claims to cover a
# universe you have already measured. Ten seconds, and it catches the
# wrong-table accidents the catalog's lookalikes invite.
#
# --------------------------------------------------------------------------
# 16.2 One share per income group -- and a denominator decision
# --------------------------------------------------------------------------
# Each group's burdened share is the section 6 formula, seven times --
# with ONE new wrinkle. Look at the not-computed counts:

alameda_by_income %>%
  select(u10k_total, u10k_nc)

# 5,360 of the poorest group's 17,992 households -- nearly a third --
# have NO computable burden: they pay no cash rent, or reported no
# income. County-wide (section 6) the not-computeds were about 4% of the
# universe and we let them ride. Inside the poorest bucket they are 30%,
# and leaving them in the denominator would drag the group's "share
# burdened" down to 66% -- an artifact, not a finding. Scale decides
# when a wrinkle matters. So here we subtract them, and the share reads:
# "of the households whose burden CAN be measured."

alameda_income_rb <- alameda_by_income %>%
  mutate(
    p_u10k     = (u10k_b30 + u10k_b35 + u10k_b40 + u10k_b50) /
                 (u10k_total - u10k_nc),
    p_i10_20k  = (i10_20k_b30 + i10_20k_b35 + i10_20k_b40 + i10_20k_b50) /
                 (i10_20k_total - i10_20k_nc),
    p_i20_35k  = (i20_35k_b30 + i20_35k_b35 + i20_35k_b40 + i20_35k_b50) /
                 (i20_35k_total - i20_35k_nc),
    p_i35_50k  = (i35_50k_b30 + i35_50k_b35 + i35_50k_b40 + i35_50k_b50) /
                 (i35_50k_total - i35_50k_nc),
    p_i50_75k  = (i50_75k_b30 + i50_75k_b35 + i50_75k_b40 + i50_75k_b50) /
                 (i50_75k_total - i50_75k_nc),
    p_i75_100k = (i75_100k_b30 + i75_100k_b35 + i75_100k_b40 + i75_100k_b50) /
                 (i75_100k_total - i75_100k_nc),
    p_o100k    = (o100k_b30 + o100k_b35 + o100k_b40 + o100k_b50) /
                 (o100k_total - o100k_nc)
  )

# --------------------------------------------------------------------------
# 16.3 Chart it: a bar per income group, in INCOME order
# --------------------------------------------------------------------------
# Seven shares sitting side by side in one row -- the same shape problem
# as lab 2's homeownership rates, with the same fix: build the chart
# table by hand with data.frame(). One extra column this time: income
# groups have a NATURAL order, and alphabetical sorting would shred it
# ("$100k+" files before "$10k-20k"). So we write the order down:

income_plot_df <- data.frame(
  income = c("Under $10k", "$10k-20k", "$20k-35k", "$35k-50k",
             "$50k-75k", "$75k-100k", "$100k+"),
  share  = c(alameda_income_rb$p_u10k,    alameda_income_rb$p_i10_20k,
             alameda_income_rb$p_i20_35k, alameda_income_rb$p_i35_50k,
             alameda_income_rb$p_i50_75k, alameda_income_rb$p_i75_100k,
             alameda_income_rb$p_o100k),
  order  = 1:7
)

income_plot_df

# And a small revelation about a friend: reorder() sorts by ANY column
# you hand it -- not just the value being drawn. reorder(income, -order)
# means "arrange the groups by our hand-written order column," poorest
# at the top. The rest of the chart is section 7.1, unchanged:

income_bar <- ggplot(income_plot_df,
                     aes(x = share, y = reorder(income, -order))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "Below $100,000, rent burden in Alameda County is the norm",
    subtitle = "Share of renter households paying 30%+ of income, by household income, 2020-2024 ACS",
    x        = "Share rent-burdened (of households whose burden is computable)",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates, table B25074."
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::percent_format())

income_bar

ggsave("~/lab3_alameda_burden_by_income.png", income_bar, width = 8, height = 5)

# Read it slowly; this is the course's argument in one chart. Among
# Alameda renter households earning under $50,000, roughly nine in ten
# of those measurable are rent-burdened (95%, 84%, 88%, 90% down the
# first four bars). At $50-75k it is still four in five (79%); at
# $75-100k, three in five (60%). Then the cliff: cross $100,000 and the
# share collapses to 15%. Burden is not a housing-market mood that
# strikes at random -- it is an INCOME condition, exactly Chapple's
# week-1 argument, now built by you from raw counts.
#
# One puzzle to keep: the $10k-20k bar (84%) sits BELOW its two
# upstairs neighbors (88%, 90%). The data alone will not say why. One
# hypothesis worth chasing: subsidized housing -- public housing and
# vouchers cap rent near 30% of income for the poorest households
# lucky enough to hold them, pulling measured burden down toward the
# line. Testing that would take more data. Notice what just happened:
# a chart handed you a RESEARCH QUESTION. That is what A2's "draft
# research question and hypotheses" asks you to bottle.

# YOUR TURN (6): rebuild this section for the county you used in
# section 12 -- only state and county change; the vector and every
# formula reuse exactly as written.
# (a) Does your county show the same shape -- a high plateau, then a
#     cliff? Where does YOUR cliff start?
# (b) Look at your $10k-20k bar next to its neighbors. Same dip as
#     Alameda? In two sentences: what would you want to know about
#     your county's subsidized housing before explaining it?
# [PUT YOUR ANSWERS BELOW]
#
# If you build this for your A2 area, you have already done A2's hard
# part: combining Census variables into a measure that says something
# about housing precarity -- with a chart a county supervisor would
# stop scrolling for.
# ==========================================================================

# ==========================================================================
# 17. EXTRA PRACTICE (optional): a menu of OTHER soft-displacement measures
# ==========================================================================
# Rent burden is one thermometer for soft displacement -- the slow
# economic squeeze that moves people without any court order. It is not
# the only one. This closing section hands you one more measure you can
# compute RIGHT NOW with zero new pulls, then a shopping list for
# Assignment 2.
#
# --------------------------------------------------------------------------
# 17.1 Severe rent burden: the 50% line (one new line of code)
# --------------------------------------------------------------------------
# Policy work distinguishes burdened (30%+) from SEVERELY burdened:
# households paying at least HALF their income in rent. You have been
# carrying that count all lab -- it is the B25070_010 column -- so the
# measure is one mutate() on the section 7.1 county table you already
# built:

bay_rb %>%
  mutate(p_severe = B25070_010 / B25070_001) %>%
  select(NAME, p_rb, p_severe)

# Read the new column: in Solano, Contra Costa, and Alameda, at least
# one in four renter households pays HALF or more of its income in rent
# (29%, 27%, 25%). Statewide it is 27.3% -- over one in four renter
# households in all of California. And the county ordering matches
# section 7.1's burden ranking: wherever the squeeze is widespread, it
# is also deep. In your A2 writeup, reporting both lines is the
# professional move -- 30%+ says how WIDESPREAD the pressure is, 50%+
# says how DEEP.

# --------------------------------------------------------------------------
# 17.2 The A2 menu: three more thermometers (no code tonight)
# --------------------------------------------------------------------------
# Each of these is buildable with ONLY moves you now own -- catalog
# hunt, commented vector, widen, mutate a share, chart it by the
# section 11 card. Pick the one that fits your area's story:
#
#   OVERCROWDING -- table B25014 (catalog search: occupants per room).
#   More than one person per room is the standard crowding line, and
#   families doubling up to afford the rent is soft displacement
#   happening BEFORE any move shows up in other data. Mind the
#   universe: the table branches into owners and renters -- climb the
#   renter branch.
#
#   RENTS THEMSELVES, OVER TIME -- B25064, median gross rent (YOUR
#   TURN 1's table). One year says "expensive"; the section 15 pattern
#   -- pull several years, stamp each, stack, geom_line() -- says
#   "rising, and how fast." Pressure you can watch building.
#
#   WHO RENTS AT ALL -- B25003, tenure (lab 2, section 8). The renter
#   SHARE of a place is exposure, not pressure: it says how many
#   households the other thermometers even apply to. It pairs naturally
#   with any measure above.
#
# The honest caveat that travels with all of them: each is one
# indicator, not displacement itself. The Eviction Research Network's
# precarity models stack several of these together -- plus the eviction
# court records you meet next week -- precisely because no single
# thermometer is the weather. A2 asks you to combine two or three
# variables into a measure. Now you know where to shop.
# ==========================================================================
