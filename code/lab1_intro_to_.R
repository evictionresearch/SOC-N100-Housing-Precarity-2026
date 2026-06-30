# =============================================================================
# Lab 1 — Intro to R, using the Census from line one
# Course: SOC-N100, Housing Precarity and Displacement
# =============================================================================
#
# Welcome to your first coding lab! We start by getting you set up in RStudio on
# the DataHub and connected to the Census, then you learn the basics of R *while*
# working with real housing data. By the end you will have made your first
# chart: how rent-burdened are the counties of a state you care about.
#
# +-------------------------------------------------------------------------+
# | FOUNDATIONS (the coding ideas hiding in today's lab)                     |
# |   - Console vs. script: experiment in the Console; save the recipe here. |
# |   - Objects & assignment: <- stores a value under a name you choose.     |
# |   - Packages: install once, library() every session.                    |
# |   - A data frame is a table: rows = cases, columns = variables.          |
# +-------------------------------------------------------------------------+
#
# +-------------------------------------------------------------------------+
# | DATA HUMILITY (the measurement idea hiding in today's lab)              |
# |   The Census surveys a *sample*, not everyone, so every value is an     |
# |   ESTIMATE, not an exact count. Each estimate carries a margin of error |
# |   (the `moe` column). We'll see it at the end.                          |
# +-------------------------------------------------------------------------+

# =============================================================================
# 0. First-time setup — do this once
# -----------------------------------------------------------------------------
# Two quick things before any R: (A) get oriented in RStudio on the DataHub, and
# (B) get a free Census API key so R can talk to the Census.
#
# (A) RStudio on the DataHub
#   Click the DataHub link on the course website. It logs in with your CalNet,
#   copies the class materials into your account, and opens RStudio in your
#   browser — nothing to install. Open this file (lab1_intro_to_.R) in RStudio.
#   Run a line of code by clicking it and pressing:
#       Cmd + Return   (Mac)          Ctrl + Enter   (Windows)
#   Try it on the line below:

1 + 1   # the answer (2) appears in the Console, the panel below

#   Anything after a "#" is a comment — a note for humans that R ignores.
#
# (B) Your Census API key (one-time)
#   The Census lets anyone download its data with a free "API key" — think of it
#   as a password that lets R talk to the Census. Request one here (2 minutes):
#       https://api.census.gov/data/key_signup.html
#   Check your email for the key, paste it between the quotes below, and run the
#   line. You only do this ONCE — install = TRUE remembers it for next time.

library(tidycensus)
census_api_key("PASTE-YOUR-KEY-HERE", install = TRUE)

#   If R asks you to restart, do it: Session > Restart R. Then keep going.

# =============================================================================
# 1. Running code, the Console, and comments
# -----------------------------------------------------------------------------
# Click a line and press Cmd+Return (Mac) / Ctrl+Enter (Windows) to run it.

2 * 5    # R is a calculator
10 / 2
2^3      # 2 to the power of 3

# A "#" makes a comment — notes for humans, ignored by R. Shortcut to toggle a
# comment on the current line: Cmd+Shift+C (Mac) / Ctrl+Shift+C (Windows).

# =============================================================================
# 2. Objects and assignment ( <- )
# -----------------------------------------------------------------------------
# Store a value under a name with the assignment arrow "<-". Then reuse it.

my_state <- "CA"   # a piece of text (in quotes)
threshold <- 30    # a number: the rent-burden line, in percent

# Type a name to see what it holds:
my_state
threshold

# Tip: name things clearly. `my_state` tells future-you what it is; `x` doesn't.

# =============================================================================
# 3. Packages: load the tools we need
# -----------------------------------------------------------------------------
# A package is a toolbox. You INSTALL it once (already done for you on DataHub),
# and you LOAD it with library() every time you start R.
#   - tidyverse: tools for wrangling and plotting data
#   - tidycensus: tools for downloading Census data

library(tidyverse)
library(tidycensus)

# (Only if working on your own computer, not DataHub, you'd first run once:
#  install.packages(c("tidyverse", "tidycensus"))  )

# =============================================================================
# 4. Your first Census pull: a data frame
# -----------------------------------------------------------------------------
# get_acs() downloads American Community Survey data. We ask for the rent burden
# (median gross rent as a % of household income) for every county in a state.

rent_burden <- get_acs(
  geography = "county",
  variables = "B25071_001",  # median gross rent as a % of household income
  state     = my_state,       # we stored "CA" above; reuse it here
  year      = 2023
)

# What came back is a DATA FRAME — a table. Each row is one county.
rent_burden

# =============================================================================
# 5. Looking at your data
# -----------------------------------------------------------------------------
head(rent_burden)        # the first few rows
dim(rent_burden)         # how many rows (counties) and columns
names(rent_burden)       # the column names
summary(rent_burden)     # quick summary of each column
View(rent_burden)        # opens a spreadsheet-style viewer in RStudio

# The columns you'll use most:
#   NAME     = the county's name
#   estimate = the rent-burden value (a percent)
#   moe      = the margin of error around that estimate (more on this below)

# =============================================================================
# 6. Data types — and the leading-zero trap
# -----------------------------------------------------------------------------
# Every column has a TYPE. Numbers are "numeric"; text is "character".
class(rent_burden$estimate)   # numeric — we can do math on it
class(rent_burden$GEOID)      # character — it's an ID code, not a quantity

# Why is GEOID text and not a number? It's the county's Census ID (a "FIPS"
# code). Alameda County is "06075" — that leading zero MATTERS. If R treated it
# as a number it would become 6075 and no longer match the real code. Keep ID
# codes as text. You'll meet this trap again with ZIP codes.

# =============================================================================
# 7. The tidyverse verbs: reshaping data, one step at a time
# -----------------------------------------------------------------------------
# The "pipe" %>% means "and then": take the data, AND THEN do the next step.
# Five verbs do most of the work: select, filter, arrange, mutate, summarise.

# ---- 7.1 select(): keep only some columns ----
rent_burden %>%
  select(NAME, estimate, moe)

# ---- 7.2 filter(): keep only some rows ----
# Only counties where renters pay MORE than 35% of income on rent:
rent_burden %>%
  filter(estimate > 35)

# YOUR TURN: change 35 to the cost-burden line of 30. How many counties appear?
rent_burden %>%
  filter(estimate > __)

# ---- 7.3 arrange(): sort the rows ----
# Most rent-burdened counties at the top (desc = descending):
rent_burden %>%
  arrange(desc(estimate))

# YOUR TURN: sort from LEAST to MOST rent-burdened (delete desc()):
rent_burden %>%
  arrange(________)

# ---- 7.4 mutate(): add or change a column ----
# Flag whether each county's typical renter is cost-burdened (over 30%):
rent_burden %>%
  mutate(cost_burdened = estimate > 30) %>%
  select(NAME, estimate, cost_burdened)

# ---- 7.5 summarise() + group_by(): collapse to a summary ----
# The average rent burden across all counties in the state:
rent_burden %>%
  summarise(avg_burden = mean(estimate, na.rm = TRUE))
# (na.rm = TRUE tells R to ignore missing values when averaging.)

# ---- 7.6 Chaining steps together ----
# The 10 most rent-burdened counties, just the columns we care about:
rent_burden %>%
  arrange(desc(estimate)) %>%
  slice_head(n = 10) %>%
  select(NAME, estimate)

# =============================================================================
# 8. Your first chart
# -----------------------------------------------------------------------------
# ggplot builds a plot in layers, joined by "+". We plot the 10 most
# rent-burdened counties as a bar chart, with a dashed line at the 30% line.

rent_burden %>%
  arrange(desc(estimate)) %>%
  slice_head(n = 10) %>%
  ggplot(aes(x = estimate, y = reorder(NAME, estimate))) +
  geom_col(fill = "#7ECDBB") +
  geom_vline(xintercept = 30, linetype = "dashed") +
  labs(
    title = "The most rent-burdened counties",
    subtitle = "Median rent as a share of renter income, 2019–2023",
    x = "Rent burden (% of income)",
    y = NULL,
    caption = "Source: ACS 5-year. Dashed line = 30% cost-burden threshold."
  ) +
  theme_minimal()

# Save your plot to a file (optional):
# ggsave("rent_burden_plot.png", width = 8, height = 5)

# =============================================================================
# 9. Data humility: these are estimates, not facts
# -----------------------------------------------------------------------------
# The `moe` column is the margin of error. A burden of 32 with an moe of 4 means
# the true value could plausibly be anywhere from 28 to 36. The smallest, least-
# populated counties usually have the SHAKIEST estimates — big margins of error:

rent_burden %>%
  arrange(desc(moe)) %>%
  select(NAME, estimate, moe) %>%
  slice_head(n = 10)

# Lesson: don't make a big deal of a 1- or 2-point gap between two counties.
# Part of being a good analyst is knowing how much *not* to trust a number.

# =============================================================================
# 10. Your turn
# -----------------------------------------------------------------------------
# (a) Pull rent burden for a state you care about. Change "__" to its two-letter
#     abbreviation (e.g., "NY", "TX", "GA").

my_rent_burden <- get_acs(
  geography = "county",
  variables = "B25071_001",
  state     = "__",
  year      = 2023
)

# (b) Make a bar chart of its 10 most rent-burdened counties (copy from §8 and
#     swap in `my_rent_burden`).

# (c) In one sentence (as a comment), describe what you see. Are these counties
#     you'd expect? What might explain it?
# YOUR SENTENCE:

# =============================================================================
# Next week (Lab 2): we'll pull several variables at once and COMPUTE rent
# burden ourselves — rent, income, who rents vs. owns — and compare places.
#
# Remember: coding is a skill you build by practice. Errors are normal. Read
# them, search them, ask a neighbor or the AI — then keep going.
# =============================================================================
