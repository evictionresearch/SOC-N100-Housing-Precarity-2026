# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
# SOC-N100 shared course data paths.
# Source after course_paths.R (needs repo_root).
#
# Labs 4 & 6 read data/evictions/d5_case_aggregated.rds directly via readRDS();
# this constant serves maintainer tooling only (qs/qs2 removed from the repo
# 2026-07-28 — students see .rds, .csv, and parquet).
if (!exists("read_data")) for (.p in c("~/git/evictionresearch/library/code/io_helpers.R","~/users/timthomas/git/evictionresearch/library/code/io_helpers.R","/accounts/projects/timthomas/git/evictionresearch/library/code/io_helpers.R")) if (file.exists(.p)) { source(.p); break }

eviction_data_rds <- "data/evictions/d5_case_aggregated.rds"
