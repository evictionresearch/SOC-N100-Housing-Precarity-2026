# ==========================================================================
# Lab 1: Your first day in R
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# Welcome to your first coding lab. You need ZERO coding background tonight --
# this lab assumes nothing. By the end of two hours you will have:
#
#   1. Run your first lines of R.
#   2. Computed one household's rent burden by hand.
#   3. Asked the U.S. Census Bureau that same question about EVERY county
#      in California -- and made a real chart of the answer.
#
# If you are nervous about coding, you are in good company. Most sociology
# students start exactly where you are. Two promises before we begin:
#
#   - You cannot break anything. Not your computer, not the Census, not this
#     class. The worst that happens is a red message, and red messages are
#     how every coder -- including me -- learns.
#   - We only ever move one small step at a time. Every new idea gets its
#     own tiny chunk of code, and each chunk adds exactly one new thing.
#
# HOW TO USE THIS FILE
# This is a "script": a text file full of R code plus notes. Any line that
# starts with # (like this one) is a COMMENT -- a note for humans that R
# skips over. The notes are the lecture; the code is the practice.
#
# So all you need to do is read through the commented text (things that
# start with # and execute the uncommented text (like on line 67 below).
#
# ==========================================================================
# 0. Getting set up (we do this together, step by step)
# ==========================================================================
#
# (a) Open RStudio on the DataHub
#     - Click the RStudio link on the course website (in the header). It
#       signs you in with your CalNet ID and opens RStudio in your browser.
#       Nothing to install.
#     - In the Files pane (bottom-right), click the folder
#       "SOC-N100-Housing-Precarity-2026", then the "code" folder inside
#       it, then click this file: lab1_intro_to_.R. You are now looking
#       at it in the editor. That is the whole setup.
#
# (b) A quick tour of the four panes
#     - TOP-LEFT: the editor. This script. Where you read and write code.
#     - BOTTOM-LEFT: the Console. Where code actually runs and answers appear.
#     - TOP-RIGHT: the Environment. A list of things you have saved so far.
#     - BOTTOM-RIGHT: Files, Plots, Help. Charts and file listings show here.
#
# (c) How to run a line of code
#     Click anywhere on a line of code, then press:
#         Mac:      Cmd + Return
#         Windows:  Ctrl + Enter
#     (You can also click the "Run" button at the top of this pane.)
#     The line is sent to the Console below, runs, and prints its answer.
#
# (d) If you get stuck in the Console
#     If the Console shows a "+" instead of ">" and seems frozen, R thinks
#     you started a sentence and never finished it. Click in the Console and
#     press the Escape key. That cancels the half-typed command. ">" means
#     "ready for your next instruction."
#
# Try your very first line of R. Click on the line below and run it:

1 + 1

# Look at the Console: it printed [1] 2. The [1] is just R numbering its
# answers -- the answer itself is 2. Congratulations, you are coding.

# ==========================================================================
# 1. R is a calculator
# ==========================================================================
# Run each line, one at a time. Watch the Console after each one.

2 * 5      # multiply
10 / 2     # divide
7 - 3      # subtract
2^3        # 2 to the power of 3

# Notice the notes to the right of the code? Anything after a # is ignored
# by R, even on a line that has code. Coders leave comments everywhere --
# good code is a conversation with the next human who reads it (often
# future-you). In this class, comments are also how you will cite any AI
# help you used (more on that at the end).

# YOUR TURN (1): the federal government calls a household "cost-burdened"
# when it spends more than 30% of its income on housing. What is 30% of a
# $4,000 monthly income? Type the math on the line below and run it:

# [PUT YOUR ANSWER BELOW]

# Let's do another exercise. By HUD's standards, 80% of the area median income
# is considered "low income", 50% is considered "very low income", and 30% is 
# "extremely low income". Below are 6 Bay county median household incomes
# (2022 ACS 5-year estimates -- in lab 2 you will pull fresher ones yourself).
# Calculate Low, very low, and extremely low income for one or more of these
# counties. 
# 
# San Francisco: 136689
# San Mateo: 149907
# Santa Clara: 153792
# Alameda: 122488
# Contra Costa: 120020
# Marin: 142019

# [Below, write your equation and comment your answer next to it]


# ==========================================================================
# 2. Saving values: objects and the arrow  <-
# ==========================================================================
# A calculator forgets every answer. R can REMEMBER answers by storing them
# under a name you choose. The arrow  <-  means "save the thing on the
# right under the name on the left."

monthly_rent <- 2000

# Two things just happened:
#   - Nothing printed in the Console. Saving is silent. That is normal.
#   - Look at the Environment pane (top-right): monthly_rent is now listed.
#     A saved value is called an OBJECT.
#
# To see what an object holds, run its name by itself:

monthly_rent

# Let's save one more:

monthly_income <- 5000

# And now the payoff: you can do math with names instead of numbers.

monthly_rent / monthly_income

# That 0.4 means this household spends 40% of its income on rent. You just
# computed RENT BURDEN -- the single most important measure in this course.
# Multiply by 100 if you prefer it as a percent:

100 * monthly_rent / monthly_income

# We can save that result too:

rent_burden_pct <- 100 * monthly_rent / monthly_income
rent_burden_pct

# A note on names: use names that say what the thing IS. monthly_rent tells
# future-you everything; x tells you nothing. Use lowercase letters and
# underscores instead of spaces (R does not allow spaces in names).
#
# Objects can hold TEXT as well as numbers. Text goes in quotes:

my_state <- "CA"
my_state

# The quotes matter: "CA" is text (letters to keep), while CA without
# quotes would make R go looking for an object named CA and complain that
# it does not exist. Forgetting quotes is the #1 beginner error -- when you
# see "object 'CA' not found", you now know exactly what happened.

# YOUR TURN (2): a household pays $1,850 rent on a $3,700 monthly income.
# (a) Save the rent under a name.

# (b) Save the income under a name.

# (c) Use the two names to compute the rent burden as a percent.
#     Is this household above or below the 30% line?


# ==========================================================================
# 3. A few values at once: c()
# ==========================================================================
# So far every object held ONE value. The function c() -- short for
# "combine" -- glues several values into a list called a VECTOR.

rents <- c(1800, 2400, 950)
rents

# A "function" is a verb: a named action that takes inputs in parentheses.
# c() is a function. So is mean(), which averages whatever you hand it:

mean(rents)

# Text works too. Here are three Bay Area counties (note the quotes):

my_counties <- c("Alameda", "San Francisco", "Contra Costa")
my_counties

# Why do we care? Later tonight -- and in Assignment 1 -- you will hand the
# Census a vector exactly like this to say WHICH counties you want data for.

# YOUR TURN (3): make a vector of the monthly rents of three places you
# have lived (estimates are fine), then take its mean.


# ==========================================================================
# 4. Tables: the data frame
# ==========================================================================
# Almost all real data is a TABLE: rows and columns, like a spreadsheet.
# In R a table is called a DATA FRAME. Each row is a case (a county, a
# person, an eviction filing). Each column is a variable (a name, a rent,
# an income). Let's build a tiny one by hand so you see the anatomy:

three_cities <- data.frame(
  city   = c("Oakland", "Fresno", "Chico"),
  rent   = c(2200, 1300, 1400),
  income = c(6100, 4400, 4300)
)

three_cities

# Read the printout: 3 rows (cities), 3 columns (city, rent, income).
#
# The dollar sign $ pulls ONE column out of a table:

three_cities$rent

# And because a column is just a vector, our functions work on it:

mean(three_cities$rent)

# You will almost never build data frames by hand like this. Real tables
# come from data files or -- starting tonight -- straight from the Census.
# But every table you ever meet in R has this same anatomy.

# ==========================================================================
# 5. Packages: R's toolboxes
# ==========================================================================
# R comes with a solid basic toolset, and everything else lives in
# PACKAGES -- free toolboxes written by the R community. Tonight we need
# exactly two:
#
#   - tidyverse : the modern everyday toolkit for working with tables
#   - tidycensus: asks the U.S. Census Bureau for data, politely
#
# Two different actions, and beginners mix them up constantly:
#
#   install.packages("tidycensus")   # BUY the toolbox. Do this ONCE ever.
#   library(tidycensus)              # OPEN the toolbox. Do this EVERY session.
#
# On the DataHub, tidyverse is already installed for you. tidycensus may
# not be. So: run the install line below ONCE tonight. It takes a minute
# and prints a lot of text -- that is normal. You will not need to run it
# again this term (put a # in front of it afterward if you like).

install.packages("tidycensus")

# Now open both toolboxes. These two lines will appear at the top of every
# lab this term -- library() calls are how a script announces its tools:

library(tidyverse)
library(tidycensus)

# IMPORTANT, because it scares everyone the first time: library(tidyverse)
# prints a colorful block of text listing packages and "Conflicts". That is
# NOT an error. It is the toolbox announcing what is inside. A real error
# says "Error:" and stops. Red text alone does not mean something is wrong.
#
# If library() ever tells you "there is no package called ...", the fix is
# one line: install.packages("that-package-name"), then library() again.

# ==========================================================================
# 6. Your Census API key (one-time setup)
# ==========================================================================
# The Census Bureau shares its data through an API -- a door that lets
# programs like R request data over the internet. To use the door you need
# a free KEY (think: a library card). You should have signed up this week;
# if not, do it now -- it takes two minutes:
#
#     https://api.census.gov/data/key_signup.html
#
# The key arrives by EMAIL, and that email contains an ACTIVATION LINK --
# you must click it before the key works. A key that was never activated
# (or was typed with a character missing) fails with the exact same
# "invalid char in json text" error described below, so if you see that
# error later: go back to the email, click the activation link, then
# re-run the key line here.
#
# FIRST paste your key between the quotes below, THEN run the line. (Order
# matters: if you run it while it still says PASTE-YOUR-KEY-HERE, R politely
# saves that nonsense as your key, and every Census request will fail with
# a confusing error about "invalid char in json text". No harm done if so --
# paste your real key and run the line again; it self-corrects.)

census_api_key("PASTE-YOUR-KEY-HERE", overwrite = TRUE, install = TRUE)

# What the three inputs mean:
#   - the text in quotes: your personal key (a long string of letters/numbers)
#   - overwrite = TRUE : if some key is already saved, replace it -- this is
#                        what makes re-running the line fix a bad first try
#   - install = TRUE   : saves the key to your DataHub account permanently,
#                        so future labs find it automatically. Without this,
#                        R would forget your key when you log out.
#
# Then run this line, which wakes the saved key up for TODAY's session
# (from your next login onward, R loads it on its own):

readRenviron("~/.Renviron")

# And CHECK it -- this prints what R will actually send to the Census.
# It should show your key. If it shows PASTE-YOUR-KEY-HERE, redo the
# paste-and-run above:

Sys.getenv("CENSUS_API_KEY")

# Housekeeping notes:
#   - Once the check above shows your real key, put a # in front of the
#     census_api_key(...) line -- same retire-it move as the install line
#     in Section 5. Your key is saved in your account; commenting the line
#     out means re-runs skip it AND your key does not sit in a script you
#     will later share or submit.
#   - Your key is yours: don't post it publicly or share it in screenshots.
#     (If one leaks, you just request a new key -- no harm done.)

# ==========================================================================
# 7. Your first Census pull
# ==========================================================================
# Remember Section 2: you computed rent burden for ONE household. The
# American Community Survey (ACS) -- the Census Bureau's big ongoing
# survey -- asks that of millions of households every year. Variable
# "B25071_001" is: median gross rent as a percentage of household income.
# In plain English: the rent burden of the TYPICAL renter household.
# ("Gross rent" means rent plus basic utilities.)
#
# The function get_acs() (from tidycensus) fetches ACS data. Here it is in
# its most basic usable form -- three inputs, one per line so we can talk
# about each:
#
#   geography = what KIND of places you want (one row per place)
#   variables = which measurement you want, by its Census code
#   state     = which state to look inside
#
# Run it (run the whole chunk from get_acs to the closing parenthesis --
# click the first line and press Cmd+Return / Ctrl+Enter once):

get_acs(
  geography = "county",
  variables = "B25071_001",
  state     = "CA"
)

# It printed a table: every county in California, one row each, with the
# typical renter's rent burden in the "estimate" column. You just queried
# the federal government from a script. That is not a small thing.
#
# Now ONE new input: year. If you don't say a year, tidycensus quietly uses
# its current default and tells you in a message. In research we always say
# the year OUT LOUD so that everyone -- your groupmates, your grader,
# future-you -- gets the same numbers:

get_acs(
  geography = "county",
  variables = "B25071_001",
  state     = "CA",
  year      = 2024
)

# (year = 2024 here means the 2020-2024 five-year ACS: five years of survey
# responses pooled together so that even small counties have enough answers
# to report. Notice R told you that in a message.)
#
# One more step: SAVE the result instead of just printing it. Same code,
# now with a name and the arrow. And look -- my_state from Section 2 can
# stand in for "CA", because that is what objects are for:

rent_burden <- get_acs(
  geography = "county",
  variables = "B25071_001",
  state     = my_state,
  year      = 2024
)

# Silent again -- saving always is. Check the Environment pane: rent_burden
# is there, listed as 58 observations (California has 58 counties, so the
# table has 58 rows). Type its name to see it:

rent_burden

# ==========================================================================
# 8. Meeting your data
# ==========================================================================
# Whenever a new table lands in your Environment, spend a minute meeting
# it. These four are the standard get-acquainted moves:

head(rent_burden)    # the first 6 rows
nrow(rent_burden)    # how many rows (should be 58 -- one per county)
names(rent_burden)   # the column names
View(rent_burden)    # opens the whole table in a spreadsheet-style tab
                     # (note the capital V; close the tab when done)

# The columns, in plain English:
#   GEOID    = the county's federal ID code (text on purpose -- more below)
#   NAME     = the county's name
#   variable = the Census code we asked for (B25071_001)
#   estimate = the answer: rent burden of the typical renter, in percent
#   moe      = margin of error around that answer (Section 11)
#
# A small trap worth knowing on day one: GEOID looks like a number but is
# stored as text. Alameda County's code is "06001" -- if R treated it as a
# number, the leading zero would vanish (6001) and it would stop matching
# other Census files. ID codes are text, not quantities. The same trap
# bites people with ZIP codes ("02115" is Boston).

# The way that a GEIOD is broken up is by state (e.g., "06" for California), 
# county FIPS code (e.g., "001" for Alameda). Combined, they create a complete
# county GEOID. When we get into census tracts, smaller geographic units that 
# are about the size of neighborhoods, an additional 6 digits will be added. 
# Looking at the GEOID, I can tell it's a county one because it only has 5
# digits. 

# ==========================================================================
# 9. Asking questions of your table: the pipe and three verbs
# ==========================================================================
# The tidyverse package gives you a small set of VERBS for working with tables,
# and a symbol %>% called the PIPE. The pipe means "and then": take the
# thing on the left, AND THEN do the next step to it.
#
# Tonight, three verbs. (More next week -- three is plenty to do real work.)
#
# --------------------------------------------------------------------------
# 9.1 filter(): keep only some ROWS
# --------------------------------------------------------------------------
# "Show me the counties where the typical renter pays MORE than 35% of
# their income in rent." filter() keeps the rows where the condition is
# true and drops the rest:

rent_burden %>%
  filter(estimate > 35)

# How it works: for every row, R asks "is 'estimate' bigger than 35?" and
# keeps the rows that answer yes. The original rent_burden is untouched --
# we only printed a filtered view of it, we did not save a new object.
# Notice only a handful of counties clear that 35% bar.

# YOUR TURN (4): our cost-burden line is 30, not 35. Change the number in
# the blank and run it. How many counties cross the 30% line? (The printout
# tells you: "A tibble: __ x 5" at the top. A tibble is just the
# tidyverse's slightly polished data frame.)

rent_burden %>%
  filter(estimate > __)

# --------------------------------------------------------------------------
# 9.2 arrange(): SORT the rows
# --------------------------------------------------------------------------
# Smallest rent burden first:

rent_burden %>%
  arrange(estimate)

# Wrapping the column in desc() -- "descending" -- flips it, so the most
# rent-burdened county comes first:

rent_burden %>%
  arrange(desc(estimate))

# Something you want to notice here is that each function operates by calling
# the function (or verb) and then putting a set of parentheses around what you 
# want it to do (like in line 430)

# In line 436, we have a function within a function so we want to make sure we 
# put parentheses in the appropriate spaces. 

# --------------------------------------------------------------------------
# 9.3 select(): keep only some COLUMNS
# --------------------------------------------------------------------------
# We rarely need every column. Name the ones you want, in the order you
# want them:

rent_burden %>%
  select(NAME, estimate)

# --------------------------------------------------------------------------
# 9.4 Chaining: "and then... and then..."
# --------------------------------------------------------------------------
# The pipe's real power is stringing steps into a sentence. Read %>% as
# "and then": take rent_burden, AND THEN sort it worst-first, AND THEN
# keep the first 10 rows, AND THEN keep just the name and the number.
# (slice_head(n = 10) is a mini-verb: keep the first n rows.)

rent_burden %>%
  arrange(desc(estimate)) %>%
  slice_head(n = 10) %>%
  select(NAME, estimate)

# The 10 most rent-burdened counties in California, four readable lines.
# This is why researchers love the tidyverse: the code reads like the
# question you were asking.

# YOUR TURN (5): flip it -- the 10 LEAST rent-burdened counties. Copy the
# chain above onto the lines below and delete desc() but keep the column name
# inside arrange.


# ==========================================================================
# 10. Your first chart, one layer at a time
# ==========================================================================
# ggplot2 (inside the tidyverse) builds charts the way you build a
# sandwich: start with a base, add one layer at a time with +. We will add
# ONE layer per chunk so you see exactly what each piece does.
#
# First, save the table we want to draw: the top-10 chain from 9.4, minus
# select() (the chart is happy to ignore columns it does not use):

top10 <- rent_burden %>%
  arrange(desc(estimate)) %>%
  slice_head(n = 10)

top10

# --------------------------------------------------------------------------
# 10.1 The base: ggplot() alone
# --------------------------------------------------------------------------

ggplot(top10)

# A blank gray canvas appears in the Plots pane (bottom-right). ggplot()
# has the data but no instructions yet. That is all this layer is: a canvas.

# --------------------------------------------------------------------------
# 10.2 aes(): which columns go where
# --------------------------------------------------------------------------
# aes() is short for "aesthetics" -- the mapping from your table's columns
# to the chart's visual slots. Here: estimate on the x-axis (how long),
# county name on the y-axis (one bar per county):

ggplot(top10, aes(x = estimate, y = NAME))

# Now the canvas has labeled axes -- county names on the left, numbers on
# the bottom -- but still no shapes. We have said WHERE, not WHAT.

# --------------------------------------------------------------------------
# 10.3 geom_col(): the bars
# --------------------------------------------------------------------------
# Layers are added with +. geom_col() draws a bar for each row, as long as
# its x value:

ggplot(top10, aes(x = estimate, y = NAME)) +
  geom_col()

# Bars! But notice the order: R sorted county names alphabetically
# (bottom-up), which scrambles the story. A bar chart should usually be
# sorted by its VALUES.

# --------------------------------------------------------------------------
# 10.4 reorder(): sort the bars by their values
# --------------------------------------------------------------------------
# reorder(NAME, estimate) means "put the NAMEs in order of their estimate."
# It replaces NAME inside aes():

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col()

# Now the longest bar is on top and the story is visible at a glance:
# highest burden to lowest, top to bottom. What reorder did was sort the NAME 
# by the estimate column (the rent burden values). So now, the y axis is ordered
# by the rent burden values, not by the default alphabetical order. You'll get
# familiar with how basic R thinks (e.g., it will try to order characters 
# alphabetically). 

# --------------------------------------------------------------------------
# 10.5 labs(): say what the chart shows
# --------------------------------------------------------------------------
# A chart that needs you standing next to it explaining is not finished.
# labs() adds labels. Start with just a title:

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col() +
  labs(title = "The most rent-burdened counties in California")

# Then clean up the axes. x gets a human name. y = NULL removes the y-axis
# title entirely -- the county names on the bars already explain
# themselves, so a label like "reorder(NAME, estimate)" is just clutter:

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col() +
  labs(
    title = "The most rent-burdened counties in California",
    x     = "Median rent as a share of renter income (%)",
    y     = NULL
  )

# --------------------------------------------------------------------------
# 10.6 geom_vline(): draw the 30% line
# --------------------------------------------------------------------------
# Our threshold deserves to be ON the chart. geom_vline() draws a vertical
# line at a spot you choose on the x-axis:

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col() +
  labs(
    title = "The most rent-burdened counties in California",
    x     = "Median rent as a share of renter income (%)",
    y     = NULL
  ) +
  geom_vline(xintercept = 30)

# A solid line can look like part of the data. One new input,
# linetype = "dashed", makes it read as a reference line instead:

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col() +
  labs(
    title = "The most rent-burdened counties in California",
    x     = "Median rent as a share of renter income (%)",
    y     = NULL
  ) +
  geom_vline(xintercept = 30, linetype = "dashed")

# Every county on this chart is past the 30% cost-burden line -- the
# typical renter household in these places is officially cost-burdened.
#
# Now look at WHO is on the chart. Most people expect San Francisco or
# Los Angeles on top. Instead the leaders are smaller Northern California
# counties -- Humboldt, Butte, Lake -- and San Francisco is not in the
# top 10 at all. Why? Rent burden is a RATIO. Rents are lower in those
# counties, but renter incomes are lower still. Hold that thought for
# discussion -- it is this whole course in miniature: precarity is about
# the relationship between housing costs and income, not just high rents.

# --------------------------------------------------------------------------
# 10.7 Finishing touches: theme and color
# --------------------------------------------------------------------------
# theme_minimal() swaps the gray default for a cleaner look, and
# fill = "steelblue" inside geom_col() colors the bars. (fill is the bar's
# inside; there is a separate "color" for its outline.)

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col(fill = "steelblue") +
  labs(
    title = "The most rent-burdened counties in California",
    x     = "Median rent as a share of renter income (%)",
    y     = NULL
  ) +
  geom_vline(xintercept = 30, linetype = "dashed") +
  theme_minimal()

# R knows hundreds of color names ("steelblue", "tomato", "forestgreen")
# and any hex code (try fill = "#7ECDBB"). Browse palettes here:
#   https://r-charts.com/color-palettes/
#   https://colorbrewer2.org, my favorite!
#
# Two optional labels you will use in assignments -- subtitle (the years,
# so readers know exactly what data this is) and caption (the source):

ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "The most rent-burdened counties in California",
    subtitle = "Median gross rent as a share of income, 2020-2024 ACS",
    x        = "Median rent as a share of renter income (%)",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates. Dashed line = 30% cost-burden threshold."
  ) +
  geom_vline(xintercept = 30, linetype = "dashed") +
  theme_minimal()

# --------------------------------------------------------------------------
# 10.8 Saving your chart to a file
# --------------------------------------------------------------------------
# First save the chart as an object (same arrow as always -- charts are
# objects too):

my_first_chart <- ggplot(top10, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "The most rent-burdened counties in California",
    subtitle = "Median gross rent as a share of income, 2020-2024 ACS",
    x        = "Median rent as a share of renter income (%)",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates. Dashed line = 30% cost-burden threshold."
  ) +
  geom_vline(xintercept = 30, linetype = "dashed") +
  theme_minimal()

# Saving was silent, so show it once (running a chart's name draws it):

my_first_chart

# ggsave() writes the most recent chart to an image file. In its basic
# form it needs only a file name:

ggsave("lab1_rent_burden.png")

# Where did it go? Your HOME folder. Click the little house icon in the
# Files pane (bottom-right) and there it is: lab1_rent_burden.png. Click
# it to admire your work. To download it from
# the DataHub to your own computer: check the box next to the file, then
# More (gear icon) > Export. You will attach charts like this to your
# assignments.
#
# If the shape looks squished, ggsave() accepts size inputs (in inches):

ggsave("lab1_rent_burden.png", width = 8, height = 5)

# ==========================================================================
# 11. Data humility: these are estimates, not facts
# ==========================================================================
# Remember the moe column? The ACS is a SURVEY -- a sample of households,
# not a count of everyone. So every value it reports is an ESTIMATE with a
# margin of error: the Bureau's honest "give or take" number. An estimate
# of 32 with moe of 4 means the true value is plausibly anywhere from
# about 28 to 36.
#
# Which counties have the shakiest estimates? Sort by the moe column:

rent_burden %>%
  arrange(desc(moe)) %>%
  select(NAME, estimate, moe)

# Notice who is at the top: small, rural, lightly-populated counties. Fewer
# households answering the survey means wobblier estimates. Big urban
# counties sit at the bottom with tight margins.
#
# The lesson, which will follow us all term: do not make a big deal of a
# 1-or-2-point gap between two places when the margins of error are wider
# than the gap. Part of being a good analyst is knowing how much NOT to
# trust a number. The Census hands you its uncertainty in plain sight --
# most data sources are not that honest.

# ==========================================================================
# 12. YOUR TURN: your state
# ==========================================================================
# Time to run the whole pipeline yourself, start to finish, for a state
# you care about.
#
# (a) Pull county rent burdens for your state. Replace the blank with its
#     two-letter abbreviation in quotes ("WA", "TX", "NY", "GA", ...):

my_rent_burden <- get_acs(
  geography = "county",
  variables = "B25071_001",
  state     = "__",
  year      = 2024
)

# (b) Meet your data: how many counties does your state have?

nrow(my_rent_burden)

# (c) Make the top-10 table (copy the pattern from Section 10, swapping in
#     my_rent_burden):


# (d) Make the chart (copy your favorite version from Section 10 and change
#     the data name and the title):


# (e) In a comment below, answer in one or two plain sentences: which
#     counties top your chart? Are they the ones you expected, and what do
#     you think is going on there? (There is no wrong answer tonight --
#     this is the sociological muscle we build all term.)
# YOUR ANSWER:
#

# ==========================================================================
# 13. What you can do now (and what's next)
# ==========================================================================
# Tonight you learned to:
#   - run R code a line at a time, and read comments as the lecture
#   - save values as objects with <-  and do math with them
#   - combine values with c() and average them with mean()
#   - read a data frame: rows are cases, columns are variables
#   - install a package once, open it each session with library()
#   - pull real Census data with get_acs()
#   - question a table with filter(), arrange(), select(), and the pipe %>%
#   - build a labeled, sourced chart in layers with ggplot() and save it
#   - read a margin of error and stay humble about estimates
#
# That is a genuinely complete workflow: question -> data -> chart ->
# interpretation. Assignment 1 (due Mon Jul 27) asks for exactly this, for
# a place you choose. You could start it tonight.
#
# NEXT LAB: one variable is never the whole story. We will pull SEVERAL
# variables at once -- rents, incomes, race -- learn to find any variable
# in the Census's giant catalog, and start comparing places properly.
#
# PRACTICE AND HELP BETWEEN LABS
#   - Learn R page on the course site: free tutorials, cheatsheets, and the
#     Walker "Analyzing US Census Data" book (our reference text).
#   - Getting an error? Read it out loud, then ask your AI assistant: paste
#     the FULL red message plus the chunk of code that caused it, and ask
#     "explain what this error means before you fix it." Understanding the
#     explanation is the actual skill. Remember the course AI policy: keep
#     shareable conversation links for anything you use in assignments.
#   - And re-run things! Nothing here breaks. The fastest way to learn R is
#     to change one small thing and see what happens.
# ==========================================================================
