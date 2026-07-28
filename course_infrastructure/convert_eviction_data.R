# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
# Maintainer utility: rebuild d5_case_aggregated.rds from the legacy .qs.
# The .qs/.qs2 copies were removed from the repo 2026-07-28; git history
# keeps them (`git show aa79c2a:data/evictions/d5_case_aggregated.qs`).
# Restore one there, or point repo_root at a maintainer copy, before running.
#
#   Rscript course_infrastructure/convert_eviction_data.R [repo_root]
#
# Requires qs 0.27.3 (CRAN Archive) to read the legacy file. Writes .rds only.
if (!exists("read_data")) for (.p in c("~/git/evictionresearch/library/code/io_helpers.R","~/users/timthomas/git/evictionresearch/library/code/io_helpers.R","/accounts/projects/timthomas/git/evictionresearch/library/code/io_helpers.R")) if (file.exists(.p)) { source(.p); break }

args <- commandArgs(trailingOnly = TRUE)
repo_root <- if (length(args)) {
  normalizePath(args[[1]], mustWork = TRUE)
} else {
  normalizePath(".", mustWork = TRUE)
}

qs_path <- file.path(repo_root, "data/evictions/d5_case_aggregated.qs")
rds_path <- file.path(repo_root, "data/evictions/d5_case_aggregated.rds")

if (!file.exists(qs_path)) {
  stop("Missing ", qs_path, call. = FALSE)
}

if (!requireNamespace("qs", quietly = TRUE)) {
  if (!requireNamespace("remotes", quietly = TRUE)) {
    install.packages("remotes", repos = "https://cloud.r-project.org")
  }
  remotes::install_version(
    "qs",
    version = "0.27.3",
    repos = "https://cloud.r-project.org",
    upgrade = "never"
  )
}

obj <- read_data(qs_path)
saveRDS(obj, rds_path)

message("Wrote ", rds_path, " (", nrow(obj), " x ", ncol(obj), ")")
message("Size (MB): rds=", round(file.info(rds_path)$size / 1024^2, 2))
