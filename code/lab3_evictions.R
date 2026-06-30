# -----------------------------------------------------------------------------
# Before we start, we need to install and load the necessary packages for this
# exercise. See code/README.md for the two-layer package pattern.
source("code/course_paths.R")
source("code/course_packages.R")
source("code/course_data.R")
source("code/course_secrets.R")
load_pkgs("tidyverse", "tidycensus", "lubridate", "janitor", "qs2")
# Key from ~/.Renviron (set in lab 2 via census_api_key(..., install = TRUE))
ensure_census_api_key()

# ==========================================================================
# Over the past couple weeks, we've been working with tidycensus to get data
# from the US Census Bureau. Now, we're going to work with data from the
# The Eviction Research Network (ERN) at the University of California,
# Berkeley and link it to census conditions.
# ==========================================================================

# Course eviction data (Indiana tract-level filings).
#
# We load the ERN extract with qs2::qs_read() — a fast way to save and reload
# large R objects (.qs2 files). qs2 is the maintained CRAN package for this job
# (successor to the older qs package).
#
# If qs2::qs_read() fails on your computer — for example, the qs2 package did not
# install when you ran install_course_packages.R — use the backup instead:
#   1. Put a # at the start of the qs2::qs_read() line below (to comment it out)
#   2. Remove the # from the readRDS() line
# The .rds file in data/evictions/ is the same table in base R format; it does
# not require the qs2 package.
indiana_evictions <- qs2::qs_read(file.path(repo_root, eviction_data_qs2))
# indiana_evictions <- readRDS(file.path(repo_root, eviction_data_rds))

glimpse(indiana_evictions)
summary(indiana_evictions)

# Lets calculate overall eviction rates at the county level
# These data are at the census tract level and need to be aggregated to the
# county level.

# This sums evictions
indiana_evictions %>%
  select(county, year, plot_date, filings) %>%
  group_by(county, year) %>% 
  # mutate(evictions = sum(filings))
  summarize(
    evictions = sum(filings)
  )

indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    renters = co_totrent
  )

indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    renters = first(co_totrent) # use first() to get the first value in the group
  )

# now we can calculate eviction rates
in_rates <- 
  indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    renters = first(co_totrent),
    county_geoid = first(paste(state_code, county_code, sep = "")) # use first() to get the first value in the group
  ) %>%
  mutate(
    eviction_rate = evictions / renters
  )

in_rates

in_rates %>% filter(eviction_rate == max(in_rates$eviction_rate))
summary(in_rates)

in_rates %>% arrange(desc(eviction_rate))

# Now lets attach percent black renters and total renters by
# county from the census to the eviction rates.
# First we have to get the table numbers from the census
vars_acs5_2022 <- load_variables(2022, 'acs5', cache = TRUE)
View(vars_acs5_2022)
# search for "Tenure (Black" to find the right table.

co_census <- get_acs(
  geography = "county",
  variables = c("black_renters" = "B25003B_003", "total_renters" = "B25003_003"),
  state = "IN"
) %>%
pivot_wider(
    names_from = variable,
    values_from = estimate
)

co_census

#### Why did it give us NA's? ####
# Because the MOE also has unique values for each estimate and therefore takes 
# account for these unique values when pivoting wider.

# Let's do this again and remove these unique values before we pivot wider. 

co_census <- get_acs(
  geography = "county",
  variables = c("black_renters" = "B25003B_003", "total_renters" = "B25003_003"),
  state = "IN"
) %>%
select(-NAME, -moe) %>%
pivot_wider(
    names_from = variable,
    values_from = estimate
)

co_census

# Now let's save this file. 
# We can save it in several different ways — pick based on who needs the file next:
# 1. CSV (comma separated values): readable by Excel, Python, Stata, etc. — best for
#    *sharing* across tools. Large tables can get big; types (dates, categories) may
#    not round-trip perfectly.
# 2. RDS (below): base R — reliable fallback if qs2 is unavailable; also fine for
#    small objects you may share with non-qs2 workflows (qs2 can convert to RDS).
# 3. qs2: qs2::qs_save() / qs2::qs_read() on .qs2 files — default for large ERN
#    extracts in R; see the eviction load block at the top of this lab.
getwd() # shows me where R's working directory is currently pointing. 
write_csv(co_census, file.path(repo_root, "data/in_co_renters.csv"))

###############################################################################
# Paths and Directories in R
# 
# When you save a file in R, you need to tell your computer where you want that 
# file to go. Computers organize files in folders, which we call directories in
# coding. A path is just the “address” that tells R how to find a specific file 
# or folder.
# 
# A directory is like a folder on your computer.
# 
# A path shows the route to a file or folder. For example, the path
# ~/SOC-N100-Housing-Precarity-2026/data/in_co_renters.csv
# tells R to look inside several folders, one inside another, until it finds 
# (or creates) the file called in_co_renters.csv.
# 
# R always “starts” in a certain directory called the working directory. You can
# see what that is by using:
#   
# getwd()
# 
# If you give a path that starts with ~, it means “start at my home directory” 
# (the main folder for your user account).
###############################################################################

# You can also save R objects to disk so you can reload them without re-running
# expensive queries. Base R provides saveRDS() / readRDS() for this.
#
# As a researcher, treat the file format as part of your methods: note in your
# README or appendix which format you used (.rds, .csv, .qs2, etc.) and which
# R package versions produced the file. Collaborators — and you, years later —
# need that metadata to reopen your objects reproducibly.
saveRDS(co_census, file.path(repo_root, "data/in_co_renters.rds"))

# Now lets merge the census data to the eviction rates
in_rates <- 
  in_rates %>%
  left_join(co_census, by = c("county_geoid" = "GEOID"))

in_rates

# we can use glimpse to get a better view of the variables
glimpse(in_rates)

# This is interesting, but what's the rate of Black evictions?
# To do this, we need the number of Black evictions and black renters.
# We can get the number of Black evictions from the evictions data.

in_rates <- 
  indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    black_evictions = sum(black_head),
    renters = first(co_totrent),
    county_geoid = first(paste(state_code, county_code, sep = "")) # use first() to get the first value in the group
  ) %>%
  mutate(
    eviction_rate = evictions / renters
  ) %>%
  left_join(co_census, by = c("county_geoid" = "GEOID")) %>% 
  mutate(
    eviction_rate = evictions / renters,
    black_eviction_rate = black_evictions / black_renters,
    p_black_renters = black_renters / total_renters
  )

glimpse(in_rates)
# Notice that renters is higher than total_renters. This is because renters
# is summed from tract estimates while total_renters is the number of
# renters in the county. This shows differences in how census data is estimated.

# Let's now clean up the data a little.
in_rates_clean_2019 <- in_rates %>%
  select(
    county,
    year,
    eviction_rate,
    black_eviction_rate,
    p_black_renters
  ) %>%
  filter(year == 2019)

in_rates_clean_2019

# How can we compare the eviction rate to the Black eviction rate?
# We can make a scatter plot of the two variables.
ggplot(
  in_rates_clean_2019, 
  aes(x = eviction_rate, y = black_eviction_rate)
  ) +
  geom_point() +
  theme_minimal() +
  geom_smooth(method = "loess") +
  # geom_smooth(method = "lm", se = FALSE) +
  # geom_smooth(method = "gam", se = FALSE) +
  # geom_smooth(method = "glm", se = FALSE) +
  labs(
    title = "Eviction Rate vs Black Eviction Rate in Indiana",
    x = "Eviction Rate",
    y = "Black Eviction Rate"
  )

in_rates %>% summary()
in_rates %>% glimpse()
in_rates %>% filter(is.infinite(black_eviction_rate)) %>% data.frame() %>% head()
in_rates %>% filter(is.infinite(black_eviction_rate)) %>% summary()

# Let's make an adjustment to there being zero black renters in some counties by making the black eviction count zero as well. I'll first copy the code from above and manipulate it here. 

in_rates_adj <- 
  indiana_evictions %>%
  group_by(county, year) %>%
  summarize(
    evictions = sum(filings),
    black_evictions = sum(black_head),
    renters = first(co_totrent),
    county_geoid = first(paste(state_code, county_code, sep = "")) # use first() to get the first value in the group
  ) %>%
  mutate(
    eviction_rate = evictions / renters
  ) %>%
  left_join(co_census, by = c("county_geoid" = "GEOID")) %>%
  mutate(
    black_evictions = if_else(black_renters == 0, 0, black_evictions),
    eviction_rate = evictions / renters,
    black_eviction_rate = black_evictions / black_renters,
    p_black_renters = black_renters / total_renters
  )

in_rates_adj %>% filter(is.infinite(black_eviction_rate)) %>% data.frame() %>% head()
in_rates_adj %>% filter(is.infinite(black_eviction_rate)) %>%summary()

clean_in_rates_adj_2019 <- 
  in_rates_adj %>% 
  select(
    county,
    year,
    eviction_rate,
    black_eviction_rate,
    p_black_renters
  ) %>%
  filter(year == 2019)

ggplot(
  clean_in_rates_adj_2019, 
  aes(x = eviction_rate, y = black_eviction_rate)
) +
  geom_point() +
  theme_minimal() +
  geom_smooth(method = "loess") +
  # geom_smooth(method = "lm", se = FALSE) +
  # geom_smooth(method = "gam", se = FALSE) +
  # geom_smooth(method = "glm", se = FALSE) +
  labs(
    title = "Eviction Rate vs Black Eviction Rate in Indiana",
    x = "Eviction Rate",
    y = "Black Eviction Rate"
  )

# We could also look at black evictions relative to the black population.

# How can we compare the eviction rate to the Black eviction rate?
# We can make a scatter plot of the two variables.
ggplot(clean_in_rates_adj_2019, aes(x = p_black_renters, y = black_eviction_rate)) +
  geom_point() +
  geom_smooth(method = "loess", se = FALSE) +
  # geom_smooth(method = "lm", se = FALSE) +
  # geom_smooth(method = "gam", se = FALSE) +
  # geom_smooth(method = "glm", se = FALSE) +
  theme_minimal() +
  labs(
    title = "Neighborhood Percent Black vs Black Eviction Rate in Indiana",
    x = "Percent Black Renters",
    y = "Black Eviction Rate"
  )




# summarize() vs reframe()
# -----------------------------------------------------------------------------
# summarize() and reframe() are both used to aggregate data, but they have key differences:

# summarize():
# - Returns exactly one row per group
# - Best for calculating single summary statistics per group
# - Automatically drops grouping levels after summarizing
# Example: Getting average evictions per county
avg_evictions_county <-
  indiana_evictions %>%
  group_by(county) %>%
  summarize(
    avg_evictions = mean(filings, na.rm = TRUE),
    total_evictions = sum(filings)
  ) # Returns one row per county

avg_evictions_county

# Plot average evictions per county
ggplot(avg_evictions_county, aes(x = reorder(county, avg_evictions), y = avg_evictions)) +
  geom_col(fill = "steelblue") +
  coord_flip() +
  theme_minimal() +
  labs(
    title = "Average Evictions per County in Indiana",
    x = "County",
    y = "Average Evictions"
  )

# reframe():
# - Can return any number of rows per group
# - Better for calculations that may produce multiple rows
# - Preserves grouping structure
# Example: Getting quarterly eviction counts


# Add quarter and year columns based on plot_date
indiana_evictions %>%
  group_by(county, year) %>%
  reframe(
    quarter = 1:4,
    evictions = rep(sum(filings)/4, 4) # Simplified example dividing yearly total into quarters
  )


# Key takeaway:
# - Use summarize() when you want one summary row per group
# - Use reframe() when your calculation might return multiple rows per group

######################################################################
######################################################################
######################################################################
# END CODE
######################################################################
######################################################################
######################################################################