# ==========================================================================
# Maintainer: build the multi-state eviction files in data/evictions/
#
#   Rscript course_infrastructure/build_eviction_data_updates.R
#
# Sources live on the maintainer machine, NOT in this repo:
#   1. Minnesota tract-month aggregate — the MN pipeline's d6 stage
#      (~/git/evictionresearch/minnesota/data/d6_tract_agg_202512.parquet;
#      "use the latest one," Tim, 2026-07-23; cleared for public).
#   2. Indiana LSC update — tract-month and county-month filing counts
#      from the 2026-05-01 LSC drop's d0 output
#      (~/data/evictionresearch/lsc/output/in_20260501_ud_data_full.parquet),
#      extending the classroom d5 file's 2016–2022 window through 2026-04.
#      Counts only: the d5 file remains the classroom source for the
#      race/sex estimated columns.
#
# Counting rule for the IN update (mirrors the MN d3 aggregation stage):
# one row per case = the head defendant (first_defendant, else the first
# defendant row); filings = n(). Tract table keeps only good_geo rows
# with a 2020-tract GEOID; the county table keeps every case, so county
# totals are the true totals and tract sums land ~9% under them (cases
# whose address only geocodes to a zip/county centroid cannot be placed
# in a tract).
# ==========================================================================

suppressPackageStartupMessages({
  library(tidyverse)
  library(arrow)
})

repo <- normalizePath(".", mustWork = TRUE)
if (!file.exists(file.path(repo, "SOC-N100.Rproj"))) {
  stop("Run from the repo root (SOC-N100.Rproj not found).", call. = FALSE)
}
out_dir <- file.path(repo, "data/evictions")

# --------------------------------------------------------------------------
# 1. Minnesota: repackage the d6 tract-month aggregate for the course
# --------------------------------------------------------------------------
mn_src <- "~/git/evictionresearch/minnesota/data/d6_tract_agg_202512.parquet"
mn <- read_parquet(mn_src) %>%
  rename(tract_geoid = geoid) %>%
  mutate(state = "MN", state_code = "27", state_name = "Minnesota")

stopifnot(
  mn_has_expected_grain = nrow(mn) == nrow(distinct(mn, tract_geoid, year, month)),
  mn_statewide          = n_distinct(mn$county_code) == 87,
  mn_tract_geoid_11     = all(nchar(mn$tract_geoid) == 11),
  mn_years_2017_2025    = min(mn$year) == 2017 && max(mn$year) == 2025
)

saveRDS(mn, file.path(out_dir, "mn_tract_evictions.rds"))
write_parquet(mn, file.path(out_dir, "mn_tract_evictions.parquet"))
message("MN: ", format(nrow(mn), big.mark = ","), " rows, ",
        n_distinct(mn$tract_geoid), " tracts, years ",
        paste(range(mn$year), collapse = "-"))

# --------------------------------------------------------------------------
# 2. Indiana LSC update: one head row per case, then aggregate
# --------------------------------------------------------------------------
in_src <- "~/data/evictionresearch/lsc/output/in_20260501_ud_data_full.parquet"
in_d0 <- open_dataset(in_src) %>%
  select(case_key, party_type, first_defendant, date_filed,
         good_geo, geoid_2020, county) %>%
  collect()

in_heads <- in_d0 %>%
  filter(party_type == "defendant") %>%
  arrange(case_key, desc(first_defendant)) %>%
  distinct(case_key, .keep_all = TRUE) %>%
  mutate(
    date_filed = as.Date(date_filed),
    year  = as.integer(format(date_filed, "%Y")),
    month = as.integer(format(date_filed, "%m")),
    county = str_to_title(county)
  ) %>%
  filter(!is.na(date_filed))

# total unique eviction cases in the drop (availability report: 706,437)
message("IN: unique cases with a defendant head row: ",
        format(nrow(in_heads), big.mark = ","))

# the 93-county question: list anything that is not one of IN's 92
data(fips_codes, package = "tidycensus")
in_fips <- fips_codes %>%
  filter(state == "IN") %>%
  mutate(county = str_to_title(str_remove(county, " County$")))
odd_counties <- setdiff(unique(in_heads$county), in_fips$county)
message("IN: county labels not matching the 92 official counties: ",
        if (length(odd_counties)) paste(odd_counties, collapse = ", ") else "none")

in_county <- in_heads %>%
  count(county, year, month, name = "filings") %>%
  mutate(state = "IN")

in_tract <- in_heads %>%
  filter(good_geo, !is.na(geoid_2020)) %>%
  count(tract_geoid = geoid_2020, county, year, month, name = "filings") %>%
  mutate(state = "IN")

stopifnot(
  in_tract_geoid_11   = all(nchar(in_tract$tract_geoid) == 11),
  in_tract_is_indiana = all(startsWith(in_tract$tract_geoid, "18")),
  in_dates_span       = min(in_heads$year) == 2016 && max(in_heads$year) == 2026
)

tract_share <- sum(in_tract$filings) / sum(in_county$filings)
message("IN: share of cases placed in a tract: ", round(tract_share, 3))
if (tract_share < 0.85) warning("Tract-placement share below 0.85 — inspect addr quality")

saveRDS(in_tract,  file.path(out_dir, "in_lsc_tract_filings.rds"))
write_parquet(in_tract,  file.path(out_dir, "in_lsc_tract_filings.parquet"))
saveRDS(in_county, file.path(out_dir, "in_lsc_county_filings.rds"))
write_parquet(in_county, file.path(out_dir, "in_lsc_county_filings.parquet"))

# --------------------------------------------------------------------------
# 3. QA: LSC yearly totals vs the classroom d5 file (overlap 2016-2022)
# --------------------------------------------------------------------------
d5 <- readRDS(file.path(out_dir, "d5_case_aggregated.rds"))
d5_yearly <- d5 %>% group_by(year) %>% summarize(d5 = sum(filings))
lsc_yearly <- in_county %>%
  filter(year <= 2022, !(year == 2022 & month > 10)) %>%   # d5 ends 2022-10
  group_by(year) %>% summarize(lsc = sum(filings))
# side-by-side with percent difference -- eyeball before shipping
left_join(d5_yearly, lsc_yearly, by = "year") %>%
  mutate(pct_diff = round(100 * (lsc - d5) / d5, 1)) %>%
  as.data.frame()
