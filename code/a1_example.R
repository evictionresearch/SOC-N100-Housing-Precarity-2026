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
# 1. Pull one variable for my counties
# --------------------------------------------------------------------------
# My variable: B25064_001, "Median gross rent" -- the typical renter's
# monthly rent plus basic utilities, in dollars. (Found it by searching
# "median gross rent" in load_variables(2024, "acs5") %>% View().)
#
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
# 2. One clear chart
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
# 3. My 2-3 sentences (this is the part graders read first)
# --------------------------------------------------------------------------
# The pattern to imitate: first DESCRIBE what the chart shows, then
# INTERPRET or note a surprise. Honest and plain beats fancy.
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
# 4. Citing your AI use (required -- see the syllabus AI policy)
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
# 5. Submission checklist
# --------------------------------------------------------------------------
#   [ ] A FRESH script written by you (not an edited copy of this file),
#       saved in your home folder, runnable top to bottom with no edits
#   [ ] The saved chart image (a1_example_chart.png -> yours will differ)
#   [ ] Your 2-3 sentences (as comments in your script, in the bCourses
#       comment box, or in a small write-up file -- any of those is fine)
#   [ ] AI share links as comments next to the relevant code, or a
#       one-line "no AI used" note
#   [ ] Uploaded to bCourses by Monday July 27, 5pm
# ==========================================================================
