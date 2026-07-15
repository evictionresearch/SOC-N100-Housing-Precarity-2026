# [qs->parquet migration] read_data()/write_data() — see library/code/io_helpers.R
# Maintainer utility: build course eviction files from legacy .qs
#
#   Rscript course_infrastructure/convert_eviction_data.R
#
# Requires qs 0.27.3 (CRAN Archive) to read the legacy file.
# Writes .rds (base R) and .qs2 (CRAN successor to qs).
if (!exists("read_data")) for (.p in c("~/git/evictionresearch/library/code/io_helpers.R","~/users/timthomas/git/evictionresearch/library/code/io_helpers.R","/accounts/projects/timthomas/git/evictionresearch/library/code/io_helpers.R")) if (file.exists(.p)) { source(.p); break }

args <- commandArgs(trailingOnly = TRUE)
repo_root <- if (length(args)) {
  normalizePath(args[[1]], mustWork = TRUE)
} else {
  normalizePath(".", mustWork = TRUE)
}

qs_path <- file.path(repo_root, "data/evictions/d5_case_aggregated.qs")
rds_path <- file.path(repo_root, "data/evictions/d5_case_aggregated.rds")
qs2_path <- file.path(repo_root, "data/evictions/d5_case_aggregated.qs2")

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

if (!requireNamespace("qs2", quietly = TRUE)) {
#   install.packages("qs2", repos = "https://cloud.r-project.org")   # [qs deprecated]
}

obj <- read_data(qs_path)
saveRDS(obj, rds_path)
write_data(obj, qs2_path)

message("Wrote ", rds_path, " (", nrow(obj), " x ", ncol(obj), ")")
message("Wrote ", qs2_path)
message("Sizes (MB): rds=", round(file.info(rds_path)$size / 1024^2, 2),
        " qs2=", round(file.info(qs2_path)$size / 1024^2, 2))
