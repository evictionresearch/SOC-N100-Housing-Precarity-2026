# =============================================================================
# Bonus Lab: Working with data under memory constraints
#
# On DataHub your RStudio session runs in the cloud with a FIXED memory
# budget (see the number in the Environment tab). Unlike your laptop, there
# is no swap to bail you out: exceed the limit and your R session dies with
# a gray screen, losing anything you have not saved.
#
# This lab shows the survival kit for the final group project, where you'll
# pull tract-level Census data WITH geometry for multiple counties or states
# and join it against eviction data -- the biggest workloads of the course.
#
# What you'll learn:
#   1. How to see what memory you are using (before it's too late)
#   2. Free memory fast: rm() + gc(), and dropping geometry you don't need
#   3. Work in chunks: pull big ACS queries one state at a time
#   4. Cache to disk with qs2 so you never re-download or re-compute
#   5. duckdb + arrow: query data that is BIGGER than your memory limit
#      (the approach used by ESPM-288, Berkeley's spatial data science course)
# =============================================================================

# Open the toolboxes. Three old friends plus qs2, the fast save-to-disk
# format from Part 4. (If any library() line says "there is no package",
# run install.packages("that-name") once, then the library() line again.)

library(tidyverse)
library(tidycensus)
library(sf)
library(qs2)

# =============================================================================
# Part 1: Know your budget -- watching memory in RStudio
# =============================================================================

# In RStudio, look at the *Environment* tab: the small gauge shows how much
# of your session's memory you are using. Click it > "Memory Usage Report"
# for a breakdown. On r.datahub your budget is the class limit -- when the
# gauge nears it, it is time to clean up (Part 2) or restructure (Parts 3-5).

# Ask R how big an object is. (Same eviction file as lab 4, in its qs2
# form -- the full path works no matter which folder you are sitting in:)
evictions <- qs2::qs_read("~/SOC-N100-Housing-Precarity-2026/data/evictions/d5_case_aggregated.qs2")
object.size(evictions) %>% format(units = "MB")

# The file is ~6 MB on disk but tens of MB in memory -- compression on disk
# hides the true in-memory cost. Geometry columns are the biggest offenders:
# an sf data frame of tracts can be 10-50x the size of the same data without
# geometry.

# YOUR TURN: run sort(sapply(ls(), function(x) object.size(get(x))),
# decreasing = TRUE) after loading your project data. Which object is your
# biggest? Is it one you're actually still using?

# =============================================================================
# Part 2: Free memory fast -- rm(), gc(), and st_drop_geometry()
# =============================================================================

# (a) Remove objects you no longer need, then garbage-collect:
big_copy <- evictions           # pretend this is a stale intermediate result
rm(big_copy)
gc()                            # returns memory to the system; watch the gauge drop

# (b) The single biggest win for Census work: DROP GEOMETRY when you don't
# need a map. Joins, summaries, and models don't need polygon boundaries.

# Example: pull tract-level median gross rent for Alameda County WITH
# geometry (as you would for a map)...
alameda_rent <- get_acs(
  geography = "tract",
  variables = "B25064_001",     # median gross rent
  state = "CA", county = "Alameda",
  year = 2024,
  geometry = TRUE
)
object.size(alameda_rent) %>% format(units = "MB")

# ...and the same table with geometry dropped for analysis:
alameda_rent_tbl <- alameda_rent %>% sf::st_drop_geometry()
object.size(alameda_rent_tbl) %>% format(units = "MB")

# Rule of thumb for the final project:
#   - Do all your joins/summaries on geometry-free tables.
#   - Keep ONE sf object with geometry, and join your finished numbers onto
#     it right before mapping.

# =============================================================================
# Part 3: Work in chunks -- one state (or county) at a time
# =============================================================================

# Asking get_acs() for many states at once with geometry = TRUE can blow the
# memory budget in a single call. Instead: loop, keep only the columns you
# need, and combine the small results.

states_of_interest <- c("CA", "WA")   # swap in your project states

rent_by_state <- map(states_of_interest, function(st) {
  get_acs(
    geography = "county",
    variables = "B25064_001",
    state = st,
    year = 2024
    # note: no geometry here -- add it later, only for the final map
  ) %>%
    mutate(state = st)
}) %>%
  list_rbind()

# YOUR TURN: adapt the loop for your project geography. If you need tracts
# for several counties, loop over counties instead of states.

# =============================================================================
# Part 4: Cache to disk with qs2 -- never download twice
# =============================================================================

# Census pulls are slow and re-running them wastes both time and memory.
# Save intermediate results to disk and reload instantly on the next session.

dir.create("data/cache", showWarnings = FALSE, recursive = TRUE)

cache_file <- "data/cache/rent_by_state.qs2"
if (file.exists(cache_file)) {
  rent_by_state <- qs2::qs_read(cache_file)     # instant reload
} else {
  # (the expensive get_acs() work from Part 3 goes here)
  qs2::qs_save(rent_by_state, cache_file)
}

# This "compute once, cache, reload" pattern also protects you from session
# crashes: if RStudio dies, your downloaded data survives on disk.

# =============================================================================
# Part 5: Bigger than memory -- duckdb and arrow
# =============================================================================

# Sometimes the data simply does not fit, no matter how tidy you are.
# The trick used by Berkeley's ESPM-288 (Environmental Data Science) course:
# leave the data ON DISK and send the *computation* to it with DuckDB --
# an in-process SQL engine that streams through files without loading them.

# These packages are NOT part of the core course install. Install them ONCE
# (a few minutes -- then put a # in front, like lab 1's install line):

install.packages(c("arrow", "duckdb", "duckdbfs"))

# And open them (every session):

library(arrow)
library(duckdb)
library(duckdbfs)

# (a) Write our eviction data to parquet, a columnar on-disk format:
parquet_file <- "data/cache/evictions.parquet"
evictions %>%
  sf::st_drop_geometry() %>%      # no-op if there is no geometry column
  arrow::write_parquet(parquet_file)

# (b) Open it WITHOUT loading it -- this is a lazy handle, ~0 MB of memory:
ev <- duckdbfs::open_dataset(parquet_file)
ev    # prints the schema, not the data

# (c) Use normal dplyr verbs; duckdb runs them on disk and only the final
# small result enters R's memory:
ev %>%
  group_by(county, year) %>%
  summarize(filings = sum(filings), .groups = "drop") %>%
  arrange(desc(filings)) %>%
  collect()                       # collect() = "now bring the answer into R"

# The same works on files far larger than your memory limit -- 10 GB of
# parquet on a 4 GB session is fine, because only the grouped summary ever
# materializes. arrow::open_dataset() offers the same lazy pattern, and both
# can read many files at once (e.g. one parquet per state from Part 3).

# YOUR TURN: rewrite one group_by/summarize from lab 3 to run through
# duckdbfs::open_dataset() + collect(). Compare the Environment gauge
# before and after against the in-memory version.

# =============================================================================
# Recap -- your memory survival kit for the final project
# =============================================================================
# 1. Watch the Environment gauge; object.size() to find the hogs
# 2. rm() + gc() stale objects; st_drop_geometry() unless you're mapping
# 3. Chunk big ACS pulls (one state/county per call, no geometry until the map)
# 4. Cache with qs2::qs_save() / qs_read() -- compute once, reload instantly
# 5. Too big anyway? parquet + duckdb/arrow: query on disk, collect() the answer
