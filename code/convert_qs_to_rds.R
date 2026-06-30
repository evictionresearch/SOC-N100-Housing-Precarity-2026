# Maintainer utility: convert legacy .qs course data to .rds for DataHub.
# Requires qs 0.27.3 (CRAN Archive) on the machine running this script.
#
#   cd /path/to/SOC-N100-Housing-Precarity-2026
#   Rscript code/convert_qs_to_rds.R

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

obj <- qs::qread(qs_path)
saveRDS(obj, rds_path)
message("Wrote ", rds_path, " (", nrow(obj), " rows, ", ncol(obj), " cols)")
