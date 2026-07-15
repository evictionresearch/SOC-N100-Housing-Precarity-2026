# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
# SOC-N100 shared course data paths.
# Source after course_paths.R (needs repo_root).
#
# Labs 3–4 load eviction data with read_data() on eviction_data_qs2.
# A matching .rds backup lives at eviction_data_rds (see comments in those labs).
if (!exists("read_data")) for (.p in c("~/git/evictionresearch/library/code/io_helpers.R","~/users/timthomas/git/evictionresearch/library/code/io_helpers.R","/accounts/projects/timthomas/git/evictionresearch/library/code/io_helpers.R")) if (file.exists(.p)) { source(.p); break }

eviction_data_qs2 <- "data/evictions/d5_case_aggregated.qs2"
eviction_data_rds <- "data/evictions/d5_case_aggregated.rds"
