# ==========================================================================
# Assignment 1 -- a complete worked example
# Median gross rent across five Washington counties
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# ==========================================================================
#
# WHAT THIS FILE IS: a model Assignment 1 submission, start to finish.
# The assignment: pick a county or set of counties you care about, pull
# ONE ACS variable that says something about housing precarity, make ONE
# chart, write 2-3 sentences, and include AI share links. Due Monday
# July 27 at 5pm on bCourses.
#
# HOW TO USE IT: read it top to bottom, run it, study the SHAPE of it --
# then close it and start your own FRESH script (File > New File >
# R Script), saved in your HOME folder, never inside this class folder
# (the class folder refreshes from GitHub and can lose your additions).
# This file is a model, not a template: your submission is about YOUR
# place, in YOUR words, and your graders know this example line by line.
# Full save/download/upload steps are on the bCourses assignment page.
#
# I know Washington State well from years of eviction research there, so
# my example area is five Washington counties -- three in the Seattle
# metro (King, Snohomish, Pierce) and two east of the Cascades (Spokane,
# Yakima). Pick places YOU know: it makes the interpretation part easy,
# because you can sanity-check the numbers against lived experience.

library(tidyverse)
library(tidycensus)

# --------------------------------------------------------------------------
# 1. FIRST STEP: find your variable in the Census catalog
# --------------------------------------------------------------------------
# Before you can pull anything you need a variable code, and you find
# those by looking, not by memorizing. Load the catalog and open it --
# lab 2's move:

vars_2024 <- load_variables(2024, "acs5")
View(vars_2024)

# In the View tab's search box (top right), type words for your topic
# and read the label and concept columns until one says what you mean.
# My search was  median gross rent , which leads to B25064_001 --
# "Median Gross Rent (Dollars)", the typical renter's monthly rent plus
# basic utilities. For your own hunt, try searches like
#   gross rent as a percentage   (rent burden, lab 3's table)
#   tenure                       (who owns vs. who rents)
#   hispanic or latino origin by race   (racial/ethnic composition)
# Write down the code you pick and what it measures in plain English --
# that sentence becomes your chart's subtitle and caption.

# --------------------------------------------------------------------------
# 2. Pull my variable for my counties
# --------------------------------------------------------------------------
# New trick worth copying: name the code INSIDE c() and tidycensus uses
# your name in the variable column instead of the raw code.

wa_rent <- get_acs(
  geography = "county",
  variables = c(median_rent = "B25064_001"),
  state     = "WA",
  county    = c("King", "Pierce", "Snohomish", "Spokane", "Yakima"),
  year      = 2024
)

# Always look before you plot:

wa_rent

# Five rows, one per county, estimates in dollars, county-level margins
# of error of only $13-30 -- tight enough to compare counties honestly.

# --------------------------------------------------------------------------
# 3. One clear chart
# --------------------------------------------------------------------------
# The lab-3 bar chart pattern (section 7.1): horizontal bars so the
# county names stay readable, sorted by value, a title that states the
# finding, the source in the caption, saved to a file.

a1_chart <- ggplot(wa_rent, aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col(fill = "steelblue") +                       # one bar per county
  labs(
    title    = "The typical rent differs by almost $1,000 across Washington",
    subtitle = "Median gross rent by county, 2020-2024 ACS",
    x        = "Median gross rent (dollars per month)",
    y        = NULL,                                   # county names speak for themselves
    caption  = "Source: ACS 5-year estimates, table B25064."
  ) +
  theme_minimal()

a1_chart

# (~ = your home folder, so the file lands somewhere safe no matter how
# you opened RStudio -- same habit as every lab.)
ggsave("~/a1_example_chart.png", a1_chart, width = 8, height = 5)

# --------------------------------------------------------------------------
# 4. My write-up paragraph (this is the part graders read first)
# --------------------------------------------------------------------------
# The pattern to imitate: first DESCRIBE what the chart shows, then
# INTERPRET or note a surprise. Honest and plain beats fancy. (In your
# submission, these sentences go in a Word doc, written under your
# pasted-in chart image -- see the bCourses page for the full steps.)
#
#   "Median gross rent in King County ($2,092) is nearly double Yakima
#   County's ($1,109), and the three Puget Sound metro counties all sit
#   far above the two Eastern Washington counties. What surprised me is
#   the size of the within-metro gap: Pierce County renters pay about
#   $300 less than King County renters despite being part of the same
#   commute shed, which hints at where cost pressure pushes people. To
#   know who is actually burdened, though, I would need rent RELATIVE to
#   income -- rent burden, which is where I want to take Assignment 2."
#
# (Notice the last sentence sets up the next assignment. Graders love a
# thread they can follow across your work.)

# --------------------------------------------------------------------------
# 5. Citing your AI use (required -- see the syllabus AI policy)
# --------------------------------------------------------------------------
# Paste the PUBLIC share link as a comment right next to the code it
# helped with, plus a few words on what you asked. Model:
#
# AI help: https://www.perplexity.ai/search/your-share-link-here
#   -- asked why my bars were out of order; it explained reorder().
#
# If you used no AI, say so in one comment line. Both are fine; silent
# use is not.

# --------------------------------------------------------------------------
# 6. Submission checklist
# --------------------------------------------------------------------------
#   [ ] A FRESH script named a1_yourlastname.R (not an edited copy of
#       this file), saved in your HOME folder, runnable top to bottom
#       on the DataHub with no edits
#   [ ] The chart has a title, labeled axes, and a source caption, and
#       is saved with ggsave()
#   [ ] The write-up doc (Word or PDF) has the chart image pasted in,
#       with your short paragraph under it (minimum 2-3 sentences --
#       describe first, then interpret the plot like you are explaining
#       it to someone)
#   [ ] AI share links as comments next to the relevant code and near
#       your sentences in the doc, or a one-line "no AI used" note
#   [ ] BOTH files -- the .R script and the write-up doc -- uploaded to
#       bCourses by Monday July 27, 5pm (click-by-click steps are on
#       the bCourses assignment page)
# ==========================================================================
