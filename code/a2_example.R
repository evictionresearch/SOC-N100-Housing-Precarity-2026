# ==========================================================================
# Assignment 2 -- a complete worked example
# A three-ingredient housing-precarity score for five Washington counties
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# ==========================================================================
#
# WHAT THIS FILE IS: a model Assignment 2 submission, start to finish.
# The assignment: stay with your Assignment 1 area, add two or three more
# ACS variables, combine them into a measure of displacement risk or
# housing precarity, show descriptive statistics and plots with
# interpretation, and end with a draft research question plus at least
# two hypotheses for your final project. Due Monday August 3 at 5pm on
# bCourses, with ASA citations and your AI share links.
#
# HOW TO USE IT: same rules as the A1 example. Read it top to bottom, run
# it, study the SHAPE -- then close it and write a FRESH script about
# YOUR area (File > New File > R Script, saved in your HOME folder, never
# inside this class folder). Your graders know this example line by line.
#
# THE THREAD: my A1 ended by saying that to know who is actually
# burdened, I would need rent RELATIVE to income -- and that is where A2
# picks up. A1 compared five counties on one variable. A2 goes one level
# down, to census tracts (lab 3's neighborhoods), and swaps the single
# variable for a MEASURE built from three.

library(tidyverse)
library(tidycensus)

# --------------------------------------------------------------------------
# 1. The plan: from one variable to a measure
# --------------------------------------------------------------------------
# A single variable describes; a MEASURE argues. The recipe here is the
# oldest one in the displacement literature: pick a few ingredients that
# each mark vulnerability, flag the neighborhoods where each runs above
# typical, and add up the flags. Portland's planning bureau scored its
# tracts almost exactly this way -- one point each for renters,
# communities of color, lower education, lower income (Bates 2013) --
# and the national precarity model you saw in lecture has the same
# flag-and-sum shape. Sophisticated idea, fifth-grade arithmetic.
#
# My three ingredients, for the same five counties as A1 (King, Pierce,
# Snohomish, Spokane, Yakima):
#
#   1. Share of households that RENT        -- who is exposed at all
#   2. Share of renters who are BURDENED    -- who is already stretched
#   3. Share of residents who are people    -- who history has piled the
#      of color                                risk on (Weeks 1-2)
#
# A tract that runs above typical on all three is where displacement
# pressure and disparate impact stack on top of each other.

# --------------------------------------------------------------------------
# 2. Find the variables (the lab 2 catalog move, every time)
# --------------------------------------------------------------------------

vars_2024 <- load_variables(2024, "acs5")
View(vars_2024)

# My searches and what they led me to -- note every table's UNIVERSE
# before you use it (lab 3's universe rule):
#
#   search  tenure  ->  B25003, "Tenure" (universe: occupied households)
#     B25003_001  all occupied households   <- denominator for ingredient 1
#     B25003_003  renter-occupied
#   search  gross rent as a percentage  ->  B25070 (lab 3's table;
#     universe: renter households)
#     B25070_001  all renter households     <- denominator for ingredient 2
#     B25070_007 .. _010  paying 30-34.9%, 35-39.9%, 40-49.9%, 50%+
#   search  hispanic or latino origin by race  ->  B03002 (universe:
#     everyone; the A1 example suggested this exact search)
#     B03002_001  total population          <- denominator for ingredient 3
#     B03002_003  white alone, not Hispanic or Latino
#   and one STOWAWAY, lab 3 style: B25064_001, median gross rent --
#     A1's variable, riding along so we can ask what rents look like in
#     the tracts the score flags.
#
# That is three new TABLES (the assignment asks for two or three new
# variables) plus an old friend for context.

a2_vars <- c(
  "B25003_001",  # all occupied households (universe, ingredient 1)
  "B25003_003",  # renter-occupied households
  "B25070_001",  # all renter households (universe, ingredient 2)
  "B25070_007",  # paying 30.0 - 34.9% of income on rent
  "B25070_008",  # paying 35.0 - 39.9%
  "B25070_009",  # paying 40.0 - 49.9%
  "B25070_010",  # paying 50% or more
  "B03002_001",  # total population (universe, ingredient 3)
  "B03002_003",  # white alone, not Hispanic or Latino
  "B25064_001"   # median gross rent -- the A1 stowaway
)

# --------------------------------------------------------------------------
# 3. Pull tracts for the same five counties
# --------------------------------------------------------------------------
# Same get_acs() shape as lab 3, with lab 2's county vector swapped in.

wa_raw <- get_acs(
  geography = "tract",
  variables = a2_vars,
  state     = "WA",
  county    = c("King", "Pierce", "Snohomish", "Spokane", "Yakima"),
  year      = 2024
)

# Meet the data before touching it:

wa_raw
nrow(wa_raw)

# Long data again: about a thousand tracts times ten variables. Each
# tract-variable pair has its own row, so the row count is huge and that
# is fine -- pivot_wider() is about to fix the shape.

# --------------------------------------------------------------------------
# 4. Reshape: one row per tract (lab 3, section 5)
# --------------------------------------------------------------------------

wa_wide <- wa_raw %>%
  select(GEOID, NAME, variable, estimate) %>%   # drop moe before widening
  pivot_wider(
    names_from  = variable,
    values_from = estimate
  )

wa_wide

# One row per tract, variables side by side as columns -- the shape that
# lets us do math BETWEEN variables.

# --------------------------------------------------------------------------
# 5. Which county is each tract in? (GEOID anatomy + a lab 4 join)
# --------------------------------------------------------------------------
# Lab 4 taught the anatomy: a county GEOID is state code + county code
# glued together ("53" for Washington + "033" for King = "53033"), and a
# TRACT's GEOID starts with those same five characters. Lab 4 used
# paste0() to GLUE codes together; str_sub() (tidyverse) is the reverse
# -- it CLIPS characters out, from position 1 to position 5:

wa_wide <- wa_wide %>%
  mutate(county_geoid = str_sub(GEOID, 1, 5))

# Now a tiny county-level pull just for the names, and lab 4's
# left_join() to attach them. (Any variable works; we only keep NAME.)

county_names <- get_acs(
  geography = "county",
  variables = "B25003_001",
  state     = "WA",
  county    = c("King", "Pierce", "Snohomish", "Spokane", "Yakima"),
  year      = 2024
) %>%
  select(county_geoid = GEOID, county = NAME)

county_names

wa_wide <- wa_wide %>%
  left_join(county_names, by = "county_geoid")

# Spot-check the join the lab 4 way: anti_join() shows the rows that
# FAILED to match -- zero rows here means every tract found its county.

anti_join(wa_wide, county_names, by = "county_geoid")

wa_wide %>% select(NAME, county)

# --------------------------------------------------------------------------
# 6. The three ingredients, with mutate() (lab 3, section 6)
# --------------------------------------------------------------------------
# Each share divides by ITS OWN table's universe -- the universe rule.

wa_shares <- wa_wide %>%
  filter(B25070_001 >= 50) %>%     # see note below
  mutate(
    p_renter = B25003_003 / B25003_001,   # households that rent
    rb_count = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    p_rb     = rb_count / B25070_001,     # renters who are burdened
    p_poc    = 1 - (B03002_003 / B03002_001)  # everyone except white,
                                              # non-Hispanic residents
  )

glimpse(wa_shares)

# Why the filter? Walker's chapter 3 lesson: tract estimates come with
# margins of error, and a share computed from a handful of households is
# mostly noise. Keeping tracts with at least 50 renter households means
# every share below stands on something. Honest work says what it
# dropped, so count both sides -- here it costs 15 of 1,050 tracts,
# leaving 1,035:

nrow(wa_wide)
nrow(wa_shares)

# Always inspect a new measure before you use it (lab 3's habit):

summary(wa_shares$p_rb)

# Proportions between 0 and 1, no NAs after the filter -- ready to
# score. And pause on that median: in the typical tract here, about 47%
# of renter households are burdened -- nearly the same number lab 3
# found for Alameda County, CA. Two regions, one story.

# --------------------------------------------------------------------------
# 7. The score: flag what runs above typical, then add up the flags
# --------------------------------------------------------------------------
# For each ingredient, a tract earns one point if it sits ABOVE the
# median tract in the five-county region -- "above typical," the same
# above-the-average logic Bates used for Portland. median() inside
# mutate() sees the whole column, so each comparison is against the
# regional typical tract. if_else() is lab 3's yes/no tool.

wa_scored <- wa_shares %>%
  mutate(
    flag_renter = if_else(p_renter > median(p_renter), 1, 0),
    flag_rb     = if_else(p_rb     > median(p_rb),     1, 0),
    flag_poc    = if_else(p_poc    > median(p_poc),    1, 0),
    score       = flag_renter + flag_rb + flag_poc
  )

# The score runs 0 (below typical on every ingredient) to 3 (above
# typical on all three -- the stacked-risk tracts).

# --------------------------------------------------------------------------
# 8. Descriptive statistics (the part the assignment grades)
# --------------------------------------------------------------------------
# Table 1: what kind of places did each score catch? group_by() +
# summarize() from lab 3 part B; n() counts the rows in each group.
# (median rent needs na.rm = TRUE: a few tracts have renters but no
# published median rent.)

score_table <- wa_scored %>%
  group_by(score) %>%
  summarize(
    tracts      = n(),
    median_rb   = median(p_rb),
    median_poc  = median(p_poc),
    median_rent = median(B25064_001, na.rm = TRUE)
  )

score_table

# Table 2: where do the stacked-risk tracts sit? (score == 3 is a yes/no
# question, and R counts a yes as 1 -- so sum() counts the yeses.)

county_table <- wa_scored %>%
  group_by(county) %>%
  summarize(
    tracts = n(),
    high   = sum(score == 3),
    p_high = high / tracts
  )

county_table

# --------------------------------------------------------------------------
# 9. Three charts, lab 3 patterns throughout
# --------------------------------------------------------------------------

# Chart 1 -- how the region distributes across the score. It draws
# Table 1's tracts column, so the chart and table must agree -- a free
# sanity check. factor() tells ggplot the score is four labeled groups,
# not a number line.

a2_chart1 <- ggplot(score_table, aes(x = factor(score), y = tracts)) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "One tract in five stacks all three risk factors",
    subtitle = "Census tracts by precarity score: one point each for above-typical renter share, rent burden, and share of residents of color",
    x        = "Precarity score (0 = none above typical, 3 = all three)",
    y        = "Number of census tracts",
    caption  = "Source: ACS 5-year estimates, 2020-2024, tables B25003, B25070, B03002."
  ) +
  theme_minimal()

a2_chart1

ggsave("~/a2_example_chart1.png", a2_chart1, width = 8, height = 5)

# Chart 2 -- the A1 bar-chart pattern (horizontal, sorted, title states
# the finding), now carrying a computed measure instead of a raw pull.

a2_chart2 <- ggplot(county_table, aes(x = p_high, y = reorder(county, p_high))) +
  geom_col(fill = "steelblue") +
  labs(
    title    = "Stacked risk spans four of the five counties -- Spokane is the outlier",
    subtitle = "Share of a county's tracts scoring 3 of 3 on the precarity score",
    x        = "Share of tracts at score 3",
    y        = NULL,
    caption  = "Source: ACS 5-year estimates, 2020-2024, tables B25003, B25070, B03002."
  ) +
  theme_minimal()

a2_chart2

ggsave("~/a2_example_chart2.png", a2_chart2, width = 8, height = 5)

# Chart 3 -- the disparate-impact picture the hypotheses grow from:
# every tract as one dot, race composition against rent burden. A cloud
# of a thousand dots hides its own average, so two helpers carry the
# story. alpha makes dots see-through so the cloud stays readable. And
# geom_smooth() -- lab 3's trend line, ribbon and all -- with ONE new
# argument: method = "lm" asks for a STRAIGHT line (one average slope
# for the whole cloud) instead of the flexible curve lab 3 let R pick.
# (The Console note about formula = 'y ~ x' is R confirming the recipe
# -- a message, not an error.) The axes get lab 3's percent dress code,
# since both are shares.

a2_chart3 <- ggplot(wa_shares, aes(x = p_poc, y = p_rb)) +
  geom_point(color = "steelblue", alpha = 0.4) +
  geom_smooth(method = "lm", color = "firebrick") +
  labs(
    title    = "Rent burden tilts upward with a tract's share of residents of color",
    subtitle = "Each dot is one census tract in the five-county area, 2020-2024 ACS",
    x        = "Share of residents who are people of color",
    y        = "Share of renter households that are rent-burdened",
    caption  = "Source: ACS 5-year estimates, 2020-2024, tables B25070, B03002."
  ) +
  theme_minimal() +
  scale_x_continuous(labels = scales::percent_format()) +
  scale_y_continuous(labels = scales::percent_format())

a2_chart3

ggsave("~/a2_example_chart3.png", a2_chart3, width = 8, height = 5)

# --------------------------------------------------------------------------
# 10. The model write-up (in your Word doc, charts pasted in)
# --------------------------------------------------------------------------
# Same pattern as A1 -- DESCRIBE, then INTERPRET -- but now one
# paragraph per chart plus an intro. Mine, with the numbers my run
# produced:
#
#   INTRO. "This assignment builds a three-ingredient housing-precarity
#   score for census tracts in five Washington counties, extending my
#   Assignment 1 look at median rent. Following the flag-and-sum logic
#   of Portland's gentrification risk analysis (Bates 2013), each tract
#   earns a point for an above-typical share of renter households, of
#   rent-burdened renters, and of residents of color -- three
#   characteristics that research links to displacement risk and its
#   unequal fallout (Desmond and Kimbro 2015). Across 1,035 tracts, one
#   in five (200) runs above the regional typical on all three at once
#   -- and those stacked-risk tracts have the region's LOWEST median
#   rents, which means cheap rent and high precarity often share an
#   address."
#
#   CHART 1. "Chart 1 shows how the region's 1,035 tracts spread across
#   the score. Half of them (508) sit above typical on at least two
#   ingredients, and 200 -- about one in five -- on all three. Read
#   with Table 1, the pattern completes my Assignment 1: the burdened
#   share climbs from 31% of renters in score-0 tracts to 58% in
#   score-3 tracts, while median rent is LOWEST in the score-3 tracts
#   ($1,795, roughly $300 below the score-1 tracts' $2,093). The
#   cheapest rents in the region do not buy safety from burden, because
#   burden is rent relative to income."
#
#   CHART 2. "Chart 2 asks where the 200 stacked-risk tracts sit. King
#   County leads, with about a quarter of its tracts (24%) scoring 3,
#   and Pierce, Snohomish, and Yakima cluster together at 18-20%.
#   Yakima is the surprise: it had the region's cheapest median rent in
#   my Assignment 1, yet nearly a fifth of its tracts stack all three
#   risks. Spokane sits at almost zero -- one tract of 127 -- and part
#   of that is the measure's own construction: its tracts rarely rise
#   above the REGIONAL people-of-color median, so they rarely earn that
#   flag. A score is an argument, and its thresholds decide what it can
#   see."
#
#   CHART 3. "Chart 3 puts every tract on one canvas: share of
#   residents of color against share of renters burdened, with a
#   best-fit line summarizing the cloud's average. Read the line left
#   to right: a tract at 10% residents of color averages about 43% of
#   renters burdened; at 90%, about 51% -- an eight-point climb inside
#   the same five counties. The cloud stays wide around the line
#   (high-burden, mostly-white tracts exist too), so the line is an
#   average tendency, not a rule -- which is exactly why my first
#   hypothesis commits to testing the gap within counties instead of
#   eyeballing the cloud."
#
# Notice the moves the graders look for: every number in the text is
# visible in a table or chart; description comes before interpretation;
# and the interpretation admits what the data CANNOT say (these are
# estimates with margins of error, and a cross-section, not proof of
# who moves next).

# --------------------------------------------------------------------------
# 11. Draft research question + two hypotheses (required)
# --------------------------------------------------------------------------
# The assignment asks you to end with where this is GOING. Mine:
#
#   RESEARCH QUESTION. Within the five-county area, which neighborhoods
#   carry the most stacked housing precarity, and does that precarity
#   fall disproportionately on communities of color?
#
#   H1 (disparate impact). Tracts with above-typical shares of residents
#   of color have higher rent-burden rates than tracts below typical,
#   and the gap survives comparing tracts within the same county.
#
#   H2 (severity sharpens the disparity). The relationship strengthens
#   with severity: the share of renters paying 50% or more of income
#   (B25070_010, severe burden) rises faster with a tract's share of
#   residents of color than moderate burden (30-49.9%) does.
#
# Both are testable with exactly the tables already in this script --
# that is what makes them WORKABLE hypotheses rather than wishes. If
# your group's final project lands on Indiana or Minnesota, the class
# eviction files let you push the same question into hard displacement:
# do the tracts your score flags also carry the highest filing rates?

# --------------------------------------------------------------------------
# 12. Bibliography (ASA format -- required this time)
# --------------------------------------------------------------------------
# In your Word doc these go under a "References" heading, alphabetical
# by last name, hanging indent, journal and book titles in italics.
# Inline, cite as (Bates 2013) or (Desmond and Kimbro 2015) -- you saw
# both in the model intro paragraph above.
#
#   Bates, Lisa K. 2013. Gentrification and Displacement Study:
#     Implementing an Equitable Inclusive Development Strategy in the
#     Context of Gentrification. Portland, OR: City of Portland Bureau
#     of Planning and Sustainability.
#
#   Desmond, Matthew and Rachel Tolbert Kimbro. 2015. "Eviction's
#     Fallout: Housing, Hardship, and Health." Social Forces
#     94(1):295-324.
#
#   U.S. Census Bureau. 2020-2024 American Community Survey 5-Year
#     Estimates, tables B25003, B25064, B25070, and B03002. Retrieved
#     via the tidycensus R package.
#
# (ASA's full rulebook is linked from the assignment page; these three
# entries model the shapes you need -- a report, a journal article, and
# a dataset.)

# --------------------------------------------------------------------------
# 13. Citing your AI use (required -- see the syllabus AI policy)
# --------------------------------------------------------------------------
# Exactly as in A1: paste the PUBLIC share link as a comment next to the
# code it helped with, plus a few words on what you asked. Model:
#
# AI help: https://www.perplexity.ai/search/your-share-link-here
#   -- asked how to get the county out of a tract GEOID; it suggested
#   substr(); I used str_sub() to stay in the tidyverse.
#
# In the Word doc, the same links go in footnotes near the text they
# helped with. No AI used? Say so in one line. Silent use is the only
# wrong answer.

# --------------------------------------------------------------------------
# 14. Submission checklist
# --------------------------------------------------------------------------
#   [ ] A FRESH script named a2_yourlastname.R, saved in your HOME
#       folder, runnable top to bottom on the DataHub with no edits
#   [ ] Your area = your A1 area (that continuity is the point; the
#       final project grows from this exact analysis)
#   [ ] Two or three NEW ACS variables combined into a real MEASURE --
#       not three disconnected charts
#   [ ] Descriptive statistics (tables count!) plus plots, each with a
#       title that states the finding, labeled axes, source caption,
#       and a ggsave() line
#   [ ] The write-up doc: intro paragraph(s) summarizing what you
#       analyzed and found, then text walking through EVERY plot,
#       describing before interpreting
#   [ ] A draft research question and at least TWO hypotheses at the
#       end -- these seed your group's pitch in class on Tuesday Aug 4
#   [ ] ASA-format bibliography + inline citations in the doc
#   [ ] AI share links in code comments AND doc footnotes, or a
#       one-line "no AI used" note
#   [ ] BOTH files -- .R script and write-up doc -- on bCourses by
#       Monday August 3, 5pm

# --------------------------------------------------------------------------
# 15. OPTIONAL extra: put the score on a map (lab 4 part B's moves)
# --------------------------------------------------------------------------
# Not required for A2. But your final project will want a map, and a
# score you can SEE argues harder than a score in a table. Everything
# here is lab 4 part B, reused: tracts() for the shapes, the
# shapes-on-the-LEFT join, tm_shape() + tm_polygons(). Three moves.

library(tigris)
library(sf)
library(tmap)

# Shapes for ONE county -- start small, swap in yours. The year matches
# the ACS endpoint so boundaries line up (lab 4's rule):

king_tracts <- tracts(state = "WA", county = "King", year = 2024)

# The lab 4 trap, remembered: the SHAPES go on the LEFT of the join so
# the result keeps its geometry. Both sides call their key GEOID here,
# so by = needs no translation. factor() again: four labeled groups.

king_map_data <- king_tracts %>%
  left_join(wa_scored, by = "GEOID") %>%
  mutate(score_group = factor(score))

# The map, with exactly the tm_polygons() arguments lab 4 taught:

a2_map <- tm_shape(king_map_data) +
  tm_polygons(
    col     = "score_group",
    title   = "Precarity score (3 = all three flags)",
    palette = "Reds"
  )

a2_map

tmap_save(a2_map, "~/a2_example_map.png", width = 7, height = 7)

# Reading it: the score-3 tracts run in a corridor down the county's
# urban western spine -- thickest across south King County, where south
# Seattle gives way to SeaTac, Kent, Auburn, and Federal Way, with a
# second knot in Seattle's north end -- while the county's eastern
# two-thirds barely flags at all. Neighborhood-scale structure that
# chart 2's single county bar had no way to show, drawn by three Census
# tables and a sum. One footnote for honest maps: the grey "Missing"
# areas are tracts our 50-renter filter set aside -- mostly open water
# (lab 3's Alameda lesson: the Census keeps tracts for the Bay, and for
# Puget Sound too).
#
# Try next: swap "King" for "Yakima" and re-run the three moves -- 57
# tracts, one valley, and chart 2's surprise drawn on the ground. And
# tmap_mode("view") makes any of these pannable, exactly as in lab.
# ==========================================================================
