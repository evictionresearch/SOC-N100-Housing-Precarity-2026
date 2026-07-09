# ==========================================================================
# Lab 2: Finding the data you need -- income, race, and place
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# Last week you learned the full loop: pull data with get_acs(), question
# it with verbs, chart it with ggplot(). But we handed you the variable
# ("B25071_001"). Tonight you learn to find ANY variable yourself, pull
# several at once, and use them to see one of the engines of soft
# displacement: the gap between what people earn and what their area costs.
#
# By the end of tonight you will have:
#   1. Searched the Census's giant variable catalog on your own.
#   2. Turned median income into HUD's income tiers with a new verb, mutate().
#   3. Compared incomes across race in one county -- and seen why
#      "low income" only makes sense relative to a PLACE.
#
# Quick recap of the moves you already own (lab 1):
#   name <- value        save an object          filter()   keep rows
#   c(...)               combine values          arrange()  sort rows
#   get_acs(...)         pull Census data        select()   keep columns
#   %>%                  "and then"              ggplot()   chart in layers
#
# As always: read the # comments (the lecture), run the code lines (the
# practice), one at a time.

# ==========================================================================
# 1. Setup (30 seconds now that lab 1 is done)
# ==========================================================================
# You installed tidycensus and saved your Census key in lab 1, so R
# remembers both. From now on, every lab starts with just these two lines:

library(tidyverse)
library(tidycensus)

# (If R says "there is no package called 'tidycensus'", you are probably on
# a fresh account -- run install.packages("tidycensus") once, then the
# library() line again. If get_acs() later complains about a missing key,
# redo the census_api_key() step from lab 1, section 6.)

# ==========================================================================
# 2. The catalog: every variable the ACS knows
# ==========================================================================
# The American Community Survey publishes THOUSANDS of variables. Nobody
# memorizes the codes -- researchers look them up in a catalog table, and
# tidycensus will hand you that catalog with load_variables().
#
# Its two basic inputs: which year, and which dataset. "acs5" means the
# 5-year ACS -- the same pooled version we used in lab 1:

vars_2023 <- load_variables(2023, "acs5")

# How big is this catalog?

nrow(vars_2023)

# About 28,000 rows -- one per variable. Open it like any table:

View(vars_2023)

# Three columns matter:
#   name    = the code you give get_acs()  (e.g., "B19013_001")
#   label   = what the number measures, in Census-speak
#   concept = the topic of the whole table it belongs to
#
# HOW TO SEARCH: in the View() tab, use the search box (top right of the
# tab) and type:   median household income
# Scroll until you find the plain version -- concept "Median Household
# Income in the Past 12 Months" -- with name B19013_001. That code has an
# anatomy you will see everywhere:
#
#     B19013     _    001
#     the TABLE       the LINE (row) within that table
#
# You will also spot near-twins (B19019, B25119, ...). This is the #1 way
# Census work goes wrong: grabbing a lookalike table. Slow down and read
# the label AND concept before you copy a code. We will practice.

# YOUR TURN (1): use the search box to find the code for
# "Median Gross Rent" (the typical rent, in dollars). Write the code you
# found in a comment below. Hint: its concept is exactly Median Gross Rent
# (Dollars), and gross rent lives in the B25xxx housing tables.
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 3. Area Median Income (AMI) -- one county
# ==========================================================================
# In lab 1 we pulled every county in a state. Tonight's new get_acs()
# input: county = "..." narrows the pull to counties you name. One new
# thing at a time -- same call as lab 1, plus the county line:

sf_income <- get_acs(
  geography = "county",
  variables = "B19013_001",       # median household income (you just found it)
  state     = "CA",
  county    = "San Francisco",
  year      = 2023
)

sf_income

# One row: San Francisco County, estimate 141446. The median -- half of SF
# households earn more, half earn less. Researchers call this the AREA
# MEDIAN INCOME (AMI) when they use it as a local yardstick.
#
# (If you compared notes with lab 1's income exercise you might notice
# slightly different numbers there. Those were the 2022 estimates; these
# are 2023. The ACS re-estimates every year -- one more reason we always
# say the year out loud.)
#
# Remember HUD's income tiers from lab 1, which you computed by hand?
#   80% of AMI = low income
#   50% of AMI = very low income
#   30% of AMI = extremely low income
#
# --------------------------------------------------------------------------
# 3.1 mutate(): a new verb -- add a column
# --------------------------------------------------------------------------
# mutate() creates a NEW column, computed from existing ones. In its basic
# form: mutate(new_column_name = a formula). Let's add the low-income line:

sf_income %>%
  mutate(low_income = estimate * 0.8)

# Look at the printout: same row, one new column on the end. (Scroll the
# Console printout right, or pipe into View().) The original sf_income is
# unchanged -- we printed a view, we did not save.
#
# mutate() happily makes several columns in one call -- one per line, each
# with its own formula, separated by commas:

sf_ami <- sf_income %>%
  mutate(
    low_income     = estimate * 0.8,   # HUD: low income
    very_low       = estimate * 0.5,   # HUD: very low income
    extremely_low  = estimate * 0.3    # HUD: extremely low income
  )

# We saved it this time (the arrow), so print it, keeping just the columns
# that tell the story:

sf_ami %>%
  select(NAME, estimate, low_income, very_low, extremely_low)

# Read it out loud: in San Francisco, a household earning $113,157 a year
# is LOW INCOME by HUD's standard. $70,723 is VERY low. Sit with that.

# YOUR TURN (2): copy the pattern -- pull B19013_001 for one of the other
# Bay Area counties from lab 1's exercise (San Mateo, Santa Clara, Alameda,
# Contra Costa, or Marin) and mutate all three HUD tiers. Does R's answer
# roughly match what you computed by hand in lab 1? (Vintages differ --
# lab 1's figures were 2022 -- so "close" is the right expectation.)
# [PUT YOUR CODE BELOW]


# ==========================================================================
# 4. Why "low income" must be LOCAL
# ==========================================================================
# The federal poverty line is one national number -- the same whether you
# live in San Francisco or Jackson, Mississippi. But the cost of living is
# not the same, which is exactly why HUD pegs its tiers to the LOCAL
# median instead. Watch what happens when we put a Deep South county next
# to San Francisco. Hinds County, Mississippi holds Jackson, the state
# capital:

hinds_ami <- get_acs(
  geography = "county",
  variables = "B19013_001",
  state     = "MS",
  county    = "Hinds",
  year      = 2023
) %>%
  mutate(
    low_income     = estimate * 0.8,
    very_low       = estimate * 0.5,
    extremely_low  = estimate * 0.3
  )

# (New trick, no new ideas: we piped get_acs() STRAIGHT into mutate() --
# pull, and then compute. You will see this pull-then-clean pattern
# everywhere from now on.)
#
# --------------------------------------------------------------------------
# 4.1 bind_rows(): stack tables
# --------------------------------------------------------------------------
# Two tables with the same columns can be stacked into one -- that is all
# bind_rows() does:

two_counties <- bind_rows(sf_ami, hinds_ami)

two_counties %>%
  select(NAME, estimate, low_income, very_low, extremely_low)

# Read across the rows. Hinds County's overall median income (49966) is
# BELOW San Francisco's "very low income" line (70723). The same dollar
# income can mean a stable life in one county and housing precarity in
# another. That is why every measure this course builds starts from local
# context -- and why a national poverty line misses so much.

# ==========================================================================
# 5. Several variables at once: income by race
# ==========================================================================
# Median income for everyone hides who sits where. The Census publishes
# B19013 again for each race/ethnicity group -- same table, with a letter:
#
#   B19013A = White alone            B19013D = Asian alone
#   B19013B = Black alone            B19013I = Hispanic or Latino
#
# (You can see the full A-I list by searching B19013 in the catalog. Two
# cautions we will come back to in this course: these groups are how the
# Census asks about race and ethnicity, and "White alone" overlaps with
# "Hispanic or Latino" -- a person can be counted in both. Keep that in
# mind whenever you compare groups.)
#
# --------------------------------------------------------------------------
# 5.1 A vector of variables
# --------------------------------------------------------------------------
# get_acs() accepts a c() vector of codes -- remember c() from lab 1.
# Start with just two, total and White alone:

get_acs(
  geography = "county",
  variables = c("B19013_001", "B19013A_001"),
  state     = "CA",
  county    = "San Francisco",
  year      = 2023
)

# Two rows now -- one per variable -- and the "variable" column tells you
# which is which. But codes make terrible labels; imagine a chart axis
# reading "B19013A_001".
#
# --------------------------------------------------------------------------
# 5.2 Naming as you pull
# --------------------------------------------------------------------------
# One new thing: put name = inside the c(). Whatever name you write on the
# left replaces the code in the variable column:

get_acs(
  geography = "county",
  variables = c(ami = "B19013_001", white = "B19013A_001"),
  state     = "CA",
  county    = "San Francisco",
  year      = 2023
)

# Same data, readable labels. Now the full pull -- five variables, named:

sf_race_income <- get_acs(
  geography = "county",
  variables = c(
    ami    = "B19013_001",    # everyone
    white  = "B19013A_001",   # White alone
    black  = "B19013B_001",   # Black alone
    asian  = "B19013D_001",   # Asian alone
    latinx = "B19013I_001"    # Hispanic or Latino
  ),
  state     = "CA",
  county    = "San Francisco",
  year      = 2023
)

sf_race_income

# Five rows, one per group. Before charting, read the estimate column like
# a sociologist. The median White household in San Francisco makes 177030;
# the median Black household makes 51610. That is not a gap -- that is a
# canyon: more than three times as much. Notice also where each group sits
# against the HUD lines you built in section 3: the Black median (51610)
# is below SF's VERY-low-income line (70723), and the Latinx median
# (99984) is below the low-income line (113157). The White median is far
# above the AMI itself.
#
# And the humility check you learned in lab 1 -- are these gaps real or
# noise? Look at the moe column: the largest margin here is about 5800.
# The White-Black gap is over 125000. The canyon is real.

# ==========================================================================
# 6. Charting the gap
# ==========================================================================
# You know the ggplot recipe from lab 1: data, aes(), then layers. We will
# build the income-by-race chart the same way -- one new layer per chunk.
#
# First, keep just the four race/ethnicity rows (the overall AMI becomes a
# reference line instead of a bar -- a chart should make ONE comparison,
# and mixing "everyone" bars with group bars muddies it):

sf_race_plot_df <- sf_race_income %>%
  filter(variable != "ami")

# (!= means "not equal to" -- the opposite of ==. So: keep every row whose
# variable is NOT "ami".)

# --------------------------------------------------------------------------
# 6.1 Bars, sorted -- straight to the lab 1 pattern
# --------------------------------------------------------------------------
# This is exactly the chart skeleton you built in lab 1, sections 10.1 to
# 10.4 -- groups on the x-axis this time, dollars on the y:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue")

# (One small new thing: the minus sign in reorder(variable, -estimate)
# sorts HIGH to low, so the tallest bar comes first.)
#
# --------------------------------------------------------------------------
# 6.2 The AMI reference line
# --------------------------------------------------------------------------
# In lab 1 the threshold was vertical (geom_vline). Bars point up now, so
# the reference line lies flat: geom_hline(), with a y-intercept. Let's
# draw HUD's low-income line -- 80% of AMI -- using the number straight
# from our sf_ami table:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed")

# (sf_ami$low_income -- the $ column-grab from lab 1, feeding a chart.
# Every group whose bar ends below that dashed line has a MEDIAN household
# that HUD would call low income, in their own county.)
#
# --------------------------------------------------------------------------
# 6.3 Labels that carry the story
# --------------------------------------------------------------------------

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed") +
  labs(
    title    = "Median household income by race in San Francisco",
    subtitle = "Dashed line = HUD low-income threshold (80% of area median), 2019-2023 ACS",
    x        = NULL,
    y        = "Median household income ($)",
    caption  = "Source: ACS 5-year estimates, table B19013 and race iterations."
  ) +
  theme_minimal()

# --------------------------------------------------------------------------
# 6.4 One polish move: dollar signs on the axis
# --------------------------------------------------------------------------
# Those raw numbers (150000) read like machine output. One added line
# formats the y-axis as money -- dollar_format() comes from a helper
# package called scales that rides along with ggplot:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed") +
  labs(
    title    = "Median household income by race in San Francisco",
    subtitle = "Dashed line = HUD low-income threshold (80% of area median), 2019-2023 ACS",
    x        = NULL,
    y        = "Median household income ($)",
    caption  = "Source: ACS 5-year estimates, table B19013 and race iterations."
  ) +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar_format())

# Save it for your records -- same move as lab 1:

ggsave("lab2_sf_income_by_race.png", width = 8, height = 5)

# A STORYTELLING RULE for this whole course: a plot should make one
# comparison, and a reader should get it from the title and axes alone,
# with you nowhere in the room. Two or three elements maximum -- here,
# bars plus one reference line. If you feel a fourth element coming on,
# that is usually a second plot trying to happen. Browse the ggplot
# cheatsheet for plot types as you plan your assignments:
#   https://opensource.posit.co/resources/cheatsheets/
# (copies also live in the class repo under docs/cheatsheets)

# ==========================================================================
# 7. YOUR TURN: your county's income canyon
# ==========================================================================
# Run the whole arc for a county YOU care about (an A1 candidate!):
#
# (a) Pull the five named income variables (copy section 5.2's full pull,
#     change state/county):
# [PUT YOUR CODE BELOW]


# (b) Compute the county's HUD tiers from its ami row. Two lab-1 moves and
#     one from tonight: filter(variable == "ami"), then mutate() the three
#     tiers -- save it under a name like my_ami:
# [PUT YOUR CODE BELOW]


# (c) Make the chart (copy section 6.4, swap in your data and your county's
#     low-income line from my_ami$low_income; fix the title):
# [PUT YOUR CODE BELOW]


# (d) In one or two sentences: which groups sit below your county's
#     low-income line? Did anything surprise you?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 8. What you can do now (and what's next)
# ==========================================================================
# Tonight you added:
#   - load_variables() + View() search: find any ACS variable yourself
#   - the anatomy of a variable code (table + line, race letters A-I)
#   - get_acs(county = ...): pull exactly the places you want
#   - mutate(): new columns from formulas (HUD's 80/50/30 tiers)
#   - bind_rows(): stack tables to compare places
#   - named variable vectors: readable labels from the moment you pull
#   - geom_hline() + dollar axes: reference lines and polished money charts
#
# ASSIGNMENT 1 (due Mon Jul 27) is now fully within reach: one ACS
# variable that speaks to housing precarity, for a place you care about,
# one chart, two or three sentences. Pick your place this week -- you will
# keep it for Assignment 2 and the final project.
#
# NEXT LAB: we go from copying the Census's numbers to BUILDING our own
# measure -- the share of renters who are rent-burdened -- from a table of
# counts. That means learning what a table's "universe" is, reshaping data
# with pivot_wider(), and two new verbs: group_by() and summarize().
#
# Stuck between labs? Same drill as lab 1: read the error out loud, paste
# the full message plus your code into your AI assistant, ask it to explain
# before it fixes, and keep the share link for your submission.
# ==========================================================================
