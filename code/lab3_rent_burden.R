# ==========================================================================
# Lab 3: Reading Census tables like a researcher -- your first real measure
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# Where we are. After labs 1 and 2 you can already:
#   - save objects with <- and chain steps with the pipe %>%
#   - pull Census data with get_acs() and question it with filter(),
#     arrange(), select(), and mutate()
#   - find any variable in the Census catalog with load_variables() + View()
#   - build a labeled bar chart in ggplot layers and save it with ggsave()
#
# Tonight we level up from LOOKING UP numbers to BUILDING one. By the end
# you will have constructed the course's first real measure from raw
# Census counts: the share of renter households in every Alameda County
# neighborhood that is rent-burdened. Along the way you learn the three
# skills that separate a Census user from a Census researcher:
#
#   1. Reading table names like a librarian (dollars vs. counts, and the
#      all-important "universe" rule).
#   2. Reshaping data from long to wide with pivot_wider().
#   3. Summarizing groups of rows with group_by() and summarize().
#
# Assignment 1 is due Monday July 27 at 5pm. The last section of this lab
# walks through a complete example so you know exactly what to submit.
#
# Open the toolboxes (installed back in lab 1 -- nothing new to install):

library(tidyverse)
library(tidycensus)

# ==========================================================================
# 1. How Census tables are named
# ==========================================================================
# Every ACS variable code has two parts. Take B25070_001:
#
#   B25070  = the TABLE (one topic: "Gross Rent as a Percentage of
#             Household Income" -- sound familiar? That is rent burden.)
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
# Let's look at both in the catalog. (load_variables() is from lab 2; the
# cache = TRUE input just makes it load faster next time.)

vars_2024 <- load_variables(2024, "acs5", cache = TRUE)
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
# 2. Tonight's question: what SHARE of renters are burdened?
# ==========================================================================
# In lab 1 we used B25071: the rent burden of the TYPICAL (median) renter
# household. One number per place. Useful -- but it hides everyone who is
# not the typical household. A county where the median renter pays 29%
# looks "fine" even if a third of renters pay over half their income.
#
# The researcher's move is to ask about the DISTRIBUTION: what share of
# renter households pay 30% or more? For that we need a count table:
#
#   B25070 -- "Gross Rent as a Percentage of Household Income"
#   Universe (line 001): renter-occupied housing units
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
# Our measure: (007 + 008 + 009 + 010) / 001 -- the share of renter
# households at or past the 30% cost-burden line. This is a measure the
# Eviction Research Network actually uses, and you are about to build it
# from scratch.
#
# One more new idea tonight: GEOGRAPHY. So far we compared counties. But
# displacement is a neighborhood story, so we drop down to CENSUS TRACTS
# -- small areas of roughly 1,200 to 8,000 people (about 4,000 on
# average) that the Census designs to approximate neighborhoods. Same
# get_acs(), one new value in the geography slot.

# ==========================================================================
# 3. Pulling several variables at once
# ==========================================================================
# We need six variables, so we hand get_acs() a c() vector of codes --
# exactly like the county vectors from lab 2, just with variable codes.
# Good practice you should copy: comment every code with its plain-English
# meaning. Your future self will thank you; so will your grader.

rb_vars <- c(
  "B25070_001",  # total renter households (the universe)
  "B25070_007",  # paying 30.0 - 34.9% of income on rent
  "B25070_008",  # paying 35.0 - 39.9%
  "B25070_009",  # paying 40.0 - 49.9%
  "B25070_010"   # paying 50% or more
)

rb_vars

# Now the pull. Compare this call to lab 1's: the only NEW thing is
# geography = "tract" plus naming a county. (A whole state of tracts is a
# big download -- one county is plenty, and kinder to the DataHub.)
# We use Alameda County -- home of Oakland and Berkeley.

alameda_raw <- get_acs(
  geography = "tract",       # one row per census tract now, not county
  variables = rb_vars,       # our commented vector of codes
  state     = "CA",
  county    = "Alameda",
  year      = 2024
)

# Meet the data, lab-1 style:

alameda_raw
nrow(alameda_raw)

# 1,895 rows. Why so many? Alameda County has 379 tracts, and we asked
# for 5 variables: 379 x 5 = 1,895. Every tract-variable pair gets its
# OWN ROW. Look at the printout: the same tract appears five times, once
# per variable, stacked vertically.
#
# This shape is called LONG data. The Census always hands you long data.

# ==========================================================================
# 4. Reshaping: pivot_wider()
# ==========================================================================
# For math BETWEEN variables ("add columns 007 through 010, divide by
# 001") we want each tract on ONE row with the five variables side by
# side as COLUMNS. That shape is called WIDE data.
#
# The verb that goes from long to wide is pivot_wider(). It needs to know
# two things:
#   names_from  = which column holds the future COLUMN NAMES
#   values_from = which column holds the future CELL VALUES
#
# Try the obvious version first:

alameda_messy <- alameda_raw %>%
  pivot_wider(
    names_from  = variable,
    values_from = estimate
  )

alameda_messy
nrow(alameda_messy)

# Something is wrong. We expected 379 rows -- one per tract -- and got
# 1,790, riddled with NA (R's symbol for "missing"). This is the single
# most common reshaping accident in Census work, so let's understand it
# instead of fearing it.
#
# The culprit is the moe column we ignored. Each of a tract's five rows
# has a DIFFERENT margin of error, so R sees five rows that do NOT match,
# refuses to merge them, and gives each its own half-empty row. R did
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

# 379 rows, one per tract, five tidy columns of counts. (We will come
# back to what dropping moe costs us at the end of the lab -- it is not
# free, just deferred.)

# YOUR TURN (2): in the Console, run  alameda_wide %>% View()  and scroll.
# Every column after NAME should be a whole-number count of households.
# Which tract number is the FIRST row, and how many total renter
# households does it have (the B25070_001 column)?
# [PUT YOUR ANSWER BELOW AS A COMMENT]
#

# ==========================================================================
# 5. Building the measure with mutate()
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

summary(alameda_rb_clean$p_rb)

# No more NA's. Note we saved the fixed table under a NEW name instead of
# overwriting alameda_rb. Habit worth copying: when a step CHANGES your
# data, give the result a new name. If something looks wrong later, you
# can walk back through the chain of objects and find where it broke.

# ==========================================================================
# 6. Two new verbs: summarize() and group_by()
# ==========================================================================
# --------------------------------------------------------------------------
# 6.1 summarize(): boil many rows down to one
# --------------------------------------------------------------------------
# filter() and mutate() keep one row per tract. summarize() COLLAPSES the
# whole table into a single summary row. You name the new columns and say
# how to compute each one:

alameda_rb_clean %>%
  summarize(
    tracts    = n(),              # n() counts rows -- no inputs needed
    avg_p_rb  = mean(p_rb),
    median_rb = median(p_rb)
  )

# 379 tracts, average tract burden share around 46%.

# --------------------------------------------------------------------------
# 6.2 group_by(): summarize within groups
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

# YOUR TURN (3): copy the chunk above and change the 0.5 threshold to
# __ (try 0.3). How many tracts have more than 30% of renters burdened?
# What happens to the story you would tell?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 7. Seeing the whole distribution: your first histogram
# ==========================================================================
# A summary table is one number; a HISTOGRAM shows the whole spread. It
# chops p_rb's range into bins and draws one bar per bin, as tall as the
# number of tracts that land in it. Build it in layers, lab-1 style.
#
# Base + bars (a histogram needs only an x -- the heights are computed):

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram()

# It works, and R prints a message: it guessed 30 bins and is telling you
# to pick a better value. (Remember: a message is not an error.) Take
# control of the bins -- one new input:

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25)

# Bar colors: fill for the inside, color for the outline (the outline
# makes adjacent bars readable):

ggplot(alameda_rb_clean, aes(x = p_rb)) +
  geom_histogram(bins = 25, fill = "steelblue", color = "white")

# Labels and the clean theme, exactly like lab 1:

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

# Last layer: mark the median so readers can anchor themselves. In lab 1
# the line was vertical at a value we chose (30); here we COMPUTE where
# the line goes:

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
# renting, with some neighborhoods in outright crisis.
#
# A DATA HUMILITY note before you trust any single tract: we dropped moe
# to make the pivot work, but tract-level counts have LARGE margins of
# error -- far larger, relatively, than the county numbers from lab 1
# (fewer surveyed households per tract). The overall SHAPE of this
# histogram is trustworthy; the exact value of any one tract is not.
# Rule of thumb for this course: use tracts to see patterns, not to
# rank individual neighborhoods against each other.

# ==========================================================================
# 8. YOUR TURN (4): build it for a county you care about
# ==========================================================================
# Rebuild the whole measure, start to finish, for another county --
# ideally the place you are eyeing for Assignment 1 and beyond. Fill the
# two blanks, then run each step:

my_county_raw <- get_acs(
  geography = "tract",
  variables = rb_vars,     # the same commented vector -- reuse is the point
  state     = "__",
  county    = "__",
  year      = 2024
)

# (a) Reshape it: drop moe, pivot wider (copy from Section 4).


# (b) Build rb_count and p_rb with mutate, and fix any NA's with if_else
#     (copy from Section 5). Check summary(): are you inside 0 and 1?


# (c) How many of your tracts are majority-burdened? (Section 6.2.)


# (d) Make the histogram with a median line and ggsave it (Section 7).


# (e) In one or two sentences: how does your county's distribution
#     compare to Alameda's? Higher? Wider? Any surprises?
# [PUT YOUR ANSWER BELOW]
#

# ==========================================================================
# 9. Assignment 1: exactly what to do (due Monday July 27, 5pm)
# ==========================================================================
# A1 is deliberately SIMPLER than what you just did. From the syllabus:
#
#   Pick a county, set of counties, or region you care about -- you will
#   keep working with this same area all term.
#     1. Use get_acs() to pull ONE ACS variable that says something about
#        housing precarity (rent burden, median rent, share who rent...).
#     2. Make ONE chart of it (a bar chart across your counties works).
#     3. Write 2-3 sentences describing what the chart shows and anything
#        that surprised you.
#   Submit: your R script, the chart image, your sentences, and the
#   public share link(s) for any AI conversations you used. Keep it
#   simple -- no bibliography needed yet.
#
# Everything A1 needs, you learned in labs 1 and 2. Tonight's
# measure-building is where Assignment 2 goes next (A2 asks you to
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
#
# ==========================================================================
# 10. What you can do now (and what's next)
# ==========================================================================
# Tonight you learned to:
#   - read a Census table code: table + line, dollars vs. counts
#   - respect the universe rule (divide by the table's own _001, always)
#   - pull many variables for many places at tract level
#   - reshape long data to wide with select(-moe) + pivot_wider()
#   - build a real measure with mutate() and guard it with if_else()
#   - collapse rows with summarize(), by group with group_by(), count
#     with n()
#   - draw and read a histogram, and mark its median
#   - distrust any single tract estimate (and say why)
#
# NEXT LAB (Tue Jul 28): we leave the Census for the first time. You will
# load eviction filings data collected by the Eviction Research Network
# -- court records, not surveys -- join it TO census data, and compute
# eviction rates. Hard displacement meets soft displacement, in one table.
#
# Between labs: start Assignment 1 tonight if you can. Twenty minutes
# while lab 3 is fresh beats two hours on Sunday. Errors? Same drill as
# always -- read it out loud, paste the full message to your AI, ask for
# the explanation before the fix, keep the share link.
# ==========================================================================

# ==========================================================================
# 11. EXTRA PRACTICE (optional): the burden over TIME
# ==========================================================================
# Everything tonight was one year. But the question a county supervisor
# actually asks is "is it getting WORSE?" -- and answering it just means
# running tonight's build for several years and letting the x-axis be
# year. This closing section is optional, for after class. (If you did
# lab 2's optional section 10, the two chart ideas at the end are review;
# everything else here is new and taught from zero.)
#
# The plan: (1) turn tonight's build into a reusable RECIPE, (2) run the
# recipe for 2016, 2020, and 2024, (3) stack the results, (4) draw lines.
# We work at the COUNTY level -- three counties to compare -- so each
# year is one small, quick pull.

# --------------------------------------------------------------------------
# 11.1 function(): turn your build into a recipe
# --------------------------------------------------------------------------
# You have been USING functions all course -- get_acs(), mutate(), and
# median() are recipes somebody else wrote. Tonight you write one. The
# shape:
#
#   recipe_name <- function(blank) { steps that use the blank }
#
# Our steps are tonight's sections 3-5 glued into one chain -- pull the
# B25070 counts (county level this time), drop moe, widen, compute the
# share. The only thing that changes between runs is the year, so the
# year is the blank:

burden_one_year <- function(y) {
  get_acs(
    geography = "county",
    variables = rb_vars,       # the same commented vector from section 3
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
# same p_rb you built tonight, plus the year stamp. One new county in
# the mix: Solano (Vallejo, Fairfield), which has the cheapest rents of
# these three. Hold that thought.

# --------------------------------------------------------------------------
# 11.2 map(): run the recipe once per year
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
# 11.3 A new layer: geom_line()
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
# 11.4 A new idea: color INSIDE aes()
# --------------------------------------------------------------------------
# In section 7 you SET a color -- fill = "steelblue", outside aes(): one
# look for everything, chosen by you. Put color INSIDE aes() and point
# it at a COLUMN, and R draws one line per value of that column, each in
# its own color, with a legend for free:

ggplot(burden_over_time, aes(x = year, y = p_rb, color = NAME)) +
  geom_line()

# Inside aes() = a MAPPING: the look varies with your data. Outside
# aes() = a SETTING: one look for everything. That distinction is half
# of ggplot. Now finish it -- a title that states the finding, like
# tonight's histogram:

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

# Read it with tonight's eyes. Solano -- the cheapest rents of the three
# (2024 median gross rent: $2,163, vs Alameda's $2,357 and San
# Francisco's $2,476) -- carries the HIGHEST burdened share in all three
# years: 0.54 in 2016, 0.57 in 2024. Famously expensive San Francisco is
# lowest the whole way (about 0.41, then 0.38). Burden is rent RELATIVE
# TO INCOME -- lab 1's Humboldt lesson, now moving through time. And
# notice the shape: every county dipped into 2020, then rose -- but only
# Solano now sits above where it started.
#
# YOUR TURN (5): swap the three counties inside burden_one_year() for
# your own -- your A1/A2 area plus two neighbors -- rerun 11.1 through
# 11.4, and fix the title so it states YOUR finding. Then two sentences:
# what moved, and does it read like soft-displacement pressure building
# or easing?
# [PUT YOUR ANSWER BELOW]
#
# ==========================================================================
