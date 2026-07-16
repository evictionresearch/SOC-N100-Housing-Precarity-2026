# ==========================================================================
# Lab 2: Finding the data you need -- income, race, and place
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# Last week you learned to pull data with get_acs() and question it with
# verbs (filter, arrange, select). But we handed you the variable
# ("B25071_001") -- and we ran out of time before charts. Tonight you learn
# to find ANY variable yourself, pull several at once, and use them to see
# one of the engines of soft displacement: the gap between what people earn
# and what their area costs. Then the payoff: your FIRST ggplot chart,
# built one layer at a time.
#
# By the end of tonight you will have:
#   1. Searched the Census's giant variable catalog on your own.
#   2. Turned median income into HUD's income tiers with a new verb, mutate().
#   3. Compared incomes across race in one county -- and seen why
#      "low income" only makes sense relative to a PLACE.
#   4. Built, polished, and saved your first chart.
#
# Quick recap of the moves you already own (lab 1):
#   name <- value        save an object          filter()   keep rows
#   c(...)               combine values          arrange()  sort rows
#   get_acs(...)         pull Census data        select()   keep columns
#   %>%                  "and then"              table$col  grab one column
#
# (Charts are NOT on that list -- lab 1's chart section, 10, is the part we
# skipped in class. Section 6 tonight teaches charts from zero; lab 1
# section 10 then makes good extra practice on your own.)
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
# redo the census_api_key() step from lab 1, section 6.). 
# Also remember to start with a fresh RStudio session. This pulls the latest
# code and data you need from github.com. 
# To do that, just close your current RStudio session tab in your browser, go
# to the class webpage 
# https://evictionresearch.net/SOC-N100-Housing-Precarity-2026/
# and click on the RStudio link in the header. 

# ==========================================================================
# 2. The catalog: every variable the ACS knows
# ==========================================================================
# The American Community Survey publishes THOUSANDS of variables. Nobody
# memorizes the codes -- researchers look them up in a catalog table, and
# tidycensus will hand you that catalog with load_variables().
#
# Its two basic inputs: which year, and which dataset. "acs5" means the
# 5-year ACS -- the same pooled version we used in lab 1:

vars_2024 <- load_variables(2024, "acs5")

# How big is this catalog?

nrow(vars_2024)

# About 28,000 rows -- one per variable. Open it like any table:

View(vars_2024)

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
  year      = 2024
)

sf_income

# One row: San Francisco County, estimate 140970. The median -- half of SF
# households earn more, half earn less. Researchers call this the AREA
# MEDIAN INCOME (AMI) when they use it as a local yardstick.
#
# (If you compared notes with lab 1's income exercise you might notice
# slightly different numbers there. Those were the 2022 estimates; these
# are 2024. The ACS re-estimates every year -- one more reason we always
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

# Read it out loud: in San Francisco, a household earning $112,776 a year
# is LOW INCOME by HUD's standard. $70,485 is VERY low. Sit with that.

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
  year      = 2024
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

# Read across the rows. Hinds County's overall median income (49402) is
# BELOW San Francisco's "very low income" line (70485). The same dollar
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
  year      = 2024
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
  year      = 2024
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
  year      = 2024
)

sf_race_income

# Five rows, one per group. Before charting, read the estimate column like
# a sociologist. The median White household in San Francisco makes 175732;
# the median Black household makes 54384. That is not a gap -- that is a
# canyon: more than three times as much. Notice also where each group sits
# against the HUD lines you built in section 3: the Black median (54384)
# is below SF's VERY-low-income line (70485), and the Latinx median
# (102392) is below the low-income line (112776). The White median is far
# above the AMI itself.
#
# One habit to build before we chart this: the ACS is a SURVEY -- a sample
# of households, not a count of everyone -- so every value it reports is an
# ESTIMATE, and the moe column is its margin of error: the Bureau's honest
# "give or take" number. Always ask whether a gap is real or inside the
# noise. The largest margin here is about 8700. The White-Black gap is
# over 121000. The canyon is real.

# ==========================================================================
# 6. Your first chart, one layer at a time
# ==========================================================================
# We skipped lab 1's chart section in class, so tonight is your first
# chart -- the payoff of everything so far. And you have already SEEN this
# chart: Tuesday's lecture showed the Washington / King County version,
# with the grey AMI bands. You are rebuilding that lecture graphic for San
# Francisco, from raw data. ggplot2 (it rode in with the tidyverse) builds
# charts the way you build a sandwich: start with a base, add ONE layer at
# a time with +. One new idea per chunk, as always.
#
# First, the table we want to draw. Keep just the four race/ethnicity rows
# (the overall AMI becomes a reference line instead of a bar -- a chart
# should make ONE comparison, and mixing "everyone" bars with group bars
# muddies it):

sf_race_plot_df <- sf_race_income %>%
  filter(variable != "ami")

# (!= means "not equal to" -- the opposite of ==. So: keep every row whose
# variable is NOT "ami".)

# --------------------------------------------------------------------------
# 6.1 The base: ggplot() alone
# --------------------------------------------------------------------------

ggplot(sf_race_plot_df)

# A blank gray canvas appears in the Plots pane (bottom-right). ggplot()
# has the data but no instructions yet. That is all this layer is: a canvas.

# --------------------------------------------------------------------------
# 6.2 aes(): which columns go where
# --------------------------------------------------------------------------
# aes() is short for "aesthetics" -- the mapping from your table's columns
# to the chart's visual slots. Groups along the x-axis, dollars up the y:

ggplot(sf_race_plot_df, aes(x = variable, y = estimate))

# Now the canvas has labeled axes -- group names along the bottom, numbers
# up the side -- but still no shapes. We have said WHERE, not WHAT.

# --------------------------------------------------------------------------
# 6.3 geom_col(): the bars
# --------------------------------------------------------------------------
# Layers are added with +. geom_col() draws a column for each row, as tall
# as its y value:

ggplot(sf_race_plot_df, aes(x = variable, y = estimate)) +
  geom_col()

# Bars! But look at the order: R put the groups alphabetically (asian,
# black, latinx, white), which scrambles the story. A bar chart should
# usually be sorted by its VALUES.

# --------------------------------------------------------------------------
# 6.4 reorder(): sort the bars by their values
# --------------------------------------------------------------------------
# reorder(variable, -estimate) means "put the groups in order of their
# estimate." The minus sign flips the sort so the tallest bar comes first.
# It replaces the plain variable inside aes():

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col()

# Now the chart reads high to low, left to right -- the gap is the first
# thing a reader sees.

# --------------------------------------------------------------------------
# 6.5 fill: color the bars
# --------------------------------------------------------------------------
# fill is a bar's inside color (a separate input, color, does outlines):

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue")

# R knows hundreds of color names ("steelblue", "tomato", "forestgreen")
# and any hex code (try fill = "#7ECDBB"). Palettes to browse as you plan
# assignments: https://colorbrewer2.org -- my favorite.

# --------------------------------------------------------------------------
# 6.6 geom_hline(): the AMI reference line
# --------------------------------------------------------------------------
# Our threshold deserves to be ON the chart. geom_hline() draws a
# horizontal line at a y value you choose -- and we already computed the
# perfect one: HUD's low-income line (80% of AMI), sitting in the sf_ami
# table. Grab it with $ (the one-column grab from lab 1, section 4).
# linetype = "dashed" keeps it reading as a reference, not as data:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed")

# Read it: every group whose bar ends below that dashed line has a MEDIAN
# household that HUD would call low income, in their own county.

# --------------------------------------------------------------------------
# 6.7 labs(): say what the chart shows
# --------------------------------------------------------------------------
# A chart that needs you standing next to it explaining is not finished.
# labs() adds the words: a title, a subtitle with the years (so readers
# know exactly what data this is), an axis label, and a source caption.
# x = NULL removes the x-axis title -- the group names under the bars
# already explain themselves:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed") +
  labs(
    title    = "Median household income by race in San Francisco",
    subtitle = "Dashed line = HUD low-income threshold (80% of area median), 2020-2024 ACS",
    x        = NULL,
    y        = "Median household income ($)",
    caption  = "Source: ACS 5-year estimates, table B19013 and race iterations."
  )

# --------------------------------------------------------------------------
# 6.8 Finishing touches: theme and a dollar axis
# --------------------------------------------------------------------------
# Two polish layers to finish. theme_minimal() swaps the gray default for
# a cleaner look. And those raw axis numbers (150000) read like machine
# output -- one more layer formats them as money. dollar_format() comes
# from a helper package called scales that rides along with ggplot:

ggplot(sf_race_plot_df, aes(x = reorder(variable, -estimate), y = estimate)) +
  geom_col(fill = "steelblue") +
  geom_hline(yintercept = sf_ami$low_income, linetype = "dashed") +
  labs(
    title    = "Median household income by race in San Francisco",
    subtitle = "Dashed line = HUD low-income threshold (80% of area median), 2020-2024 ACS",
    x        = NULL,
    y        = "Median household income ($)",
    caption  = "Source: ACS 5-year estimates, table B19013 and race iterations."
  ) +
  theme_minimal() +
  scale_y_continuous(labels = scales::dollar_format())

# That is a finished chart: bars, one reference line, and labels that
# carry the story on their own.

# --------------------------------------------------------------------------
# 6.9 ggsave(): save it to a file
# --------------------------------------------------------------------------
# ggsave() writes the most recent chart to an image file. The size inputs
# are in inches:

ggsave("lab2_sf_income_by_race.png", width = 8, height = 5)

# Where did it go? Your HOME folder. Click the little house icon in the
# Files pane (bottom-right) and there it is -- click the file to admire
# your work. To download it from the DataHub to your own computer: check
# the box next to the file, then More (gear icon) > Export. You will
# attach charts like this to your assignments.

# A STORYTELLING RULE for this whole course: a plot should make one
# comparison, and a reader should get it from the title and axes alone,
# with you nowhere in the room. Two or three elements maximum -- here,
# bars plus one reference line. If you feel a fourth element coming on,
# that is usually a second plot trying to happen. Browse the ggplot
# cheatsheet for plot types as you plan your assignments:
#   https://opensource.posit.co/resources/cheatsheets/
# (copies also live in the class repo under docs/cheatsheets)
#
# (Extra practice, any time after tonight: lab 1 section 10 builds a
# horizontal twin of this chart -- California's most rent-burdened
# counties, with geom_vline instead of geom_hline -- and lab 1 section 11
# is the margin-of-error habit in full. Both are worth twenty quiet
# minutes before Assignment 1.)

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


# (c) Make the chart (copy the finished chart from section 6.8, swap in
#     your data and your county's low-income line from my_ami$low_income;
#     fix the title):
# [PUT YOUR CODE BELOW]


# (d) In one or two sentences: which groups sit below your county's
#     low-income line? Did anything surprise you?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 8. Recreating Tuesday's homeownership-gap chart
# ==========================================================================
# Tuesday's lecture showed a homeownership gap that has barely moved in
# forty years (the Urban Institute chart: White 68%, Black 42% nationally
# in 2016). Let's rebuild that chart for San Francisco, today, from raw
# Census counts. (If class runs long, this section is yours to finish at
# home -- everything in it is two known moves plus ONE new input.)
#
# The Census's tenure table, B25003, counts occupied homes two ways:
#   B25003_001 = all households        B25003_002 = households that OWN
# and it comes in the same race letters you met in section 5 (A, B, D, I).
# A group's homeownership rate is owners divided by households.

# --------------------------------------------------------------------------
# 8.1 One new input: output = "wide"
# --------------------------------------------------------------------------
# Our usual pull returns one ROW per variable ("long"). Tonight we need
# arithmetic BETWEEN variables (owners / households), which is easier with
# one COLUMN per variable. One new get_acs() input does that:

sf_tenure <- get_acs(
  geography = "county",
  variables = c(
    white_total  = "B25003A_001", white_owner  = "B25003A_002",
    black_total  = "B25003B_001", black_owner  = "B25003B_002",
    asian_total  = "B25003D_001", asian_owner  = "B25003D_002",
    latinx_total = "B25003I_001", latinx_owner = "B25003I_002"
  ),
  state     = "CA",
  county    = "San Francisco",
  year      = 2024,
  output    = "wide"
)

names(sf_tenure)

# One row now, and every variable became TWO columns: your name plus E
# (the Estimate) and your name plus M (its Margin of error). So
# white_ownerE is the count of White householders who own their home.

# --------------------------------------------------------------------------
# 8.2 mutate() the rates -- known moves only
# --------------------------------------------------------------------------
# Owners divided by households, times 100 to read as a percent:

sf_own_rates <- sf_tenure %>%
  mutate(
    white  = 100 * white_ownerE  / white_totalE,
    black  = 100 * black_ownerE  / black_totalE,
    asian  = 100 * asian_ownerE  / asian_totalE,
    latinx = 100 * latinx_ownerE / latinx_totalE
  )

sf_own_rates %>% select(white, black, asian, latinx)

# Read it: about 47% of Asian households in San Francisco own their home,
# 38% of White households, 26% of Latinx households, 22% of Black
# households. Two things to notice. First, the locality lesson AGAIN:
# nationally, Tuesday's chart had White homeownership on top -- in San
# Francisco it is Asian households. Never assume the national pattern
# holds in your county. Second, the gap the lecture traced from covenants
# to lending is right here in 2024: the Black rate is under half the
# Asian rate. And remember why ownership matters -- it is where American
# families store wealth (Tuesday's Seattle figures: median owner net
# worth $898,000 vs renter $36,000).

# --------------------------------------------------------------------------
# 8.3 Chart it -- with a table you build by hand
# --------------------------------------------------------------------------
# ggplot wants one ROW per bar, and our four rates sit side by side in
# one row. Remember building a tiny table by hand in lab 1, section 4
# (three_cities)? Same move, using the $ grab for each rate:

sf_own_plot_df <- data.frame(
  group = c("white", "black", "asian", "latinx"),
  share = c(sf_own_rates$white, sf_own_rates$black,
            sf_own_rates$asian, sf_own_rates$latinx)
)

sf_own_plot_df

# Four rows, two columns -- chart-ready. Now the exact recipe from
# section 6: sorted bars, labels that carry the story, clean theme:

ggplot(sf_own_plot_df, aes(x = reorder(group, -share), y = share)) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "Who owns their home in San Francisco?",
    subtitle = "Share of households that are owner-occupied, 2020-2024 ACS",
    x        = NULL,
    y        = "Share of households that own (%)",
    caption  = "Source: ACS 5-year estimates, table B25003 and race iterations."
  ) +
  theme_minimal()

ggsave("lab2_sf_homeownership_by_race.png", width = 8, height = 5)

# YOUR TURN (3): rebuild this chart for YOUR county -- three edits: state,
# county, and the title. Does the national ordering hold where you live?
# [PUT YOUR CODE BELOW]


# ==========================================================================
# 9. What you can do now (and what's next)
# ==========================================================================
# Tonight you added:
#   - load_variables() + View() search: find any ACS variable yourself
#   - the anatomy of a variable code (table + line, race letters A-I)
#   - get_acs(county = ...): pull exactly the places you want
#   - mutate(): new columns from formulas (HUD's 80/50/30 tiers)
#   - bind_rows(): stack tables to compare places
#   - named variable vectors: readable labels from the moment you pull
#   - your first chart: a ggplot() canvas, aes() mappings, then layers
#     added one + at a time (geom_col, reorder, fill)
#   - geom_hline(), labs(), theme_minimal(), dollar axes, ggsave():
#     a reference line and a polished, saved money chart
#   - output = "wide": one column per variable, for arithmetic between them
#   - two of Tuesday's lecture charts, rebuilt from raw Census data
#     (income by race vs the HUD line; the homeownership gap)
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
