# SOC-N100 shared course data paths.
# Source after course_paths.R (needs repo_root).
#
# Labs 3–4 load eviction data with qs2::qs_read() on eviction_data_qs2.
# A matching .rds backup lives at eviction_data_rds (see comments in those labs).

eviction_data_qs2 <- "data/evictions/d5_case_aggregated.qs2"
eviction_data_rds <- "data/evictions/d5_case_aggregated.rds"
