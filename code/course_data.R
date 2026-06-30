# SOC-N100 shared course data paths and loaders.
# Source after course_paths.R (needs repo_root).

eviction_data_qs2 <- "data/evictions/d5_case_aggregated.qs2"
eviction_data_rds <- "data/evictions/d5_case_aggregated.rds"

#' Load Indiana tract-level eviction data (labs 3–4).
#'
#' Prefers qs2 when the file exists and the package is installed; falls back to
#' base R readRDS() so labs still run if qs2 fails to compile on a hub.
read_eviction_data <- function() {
  qs2_path <- file.path(repo_root, eviction_data_qs2)
  rds_path <- file.path(repo_root, eviction_data_rds)

  if (file.exists(qs2_path) && requireNamespace("qs2", quietly = TRUE)) {
    return(qs2::qs_read(qs2_path))
  }

  if (file.exists(qs2_path) && !requireNamespace("qs2", quietly = TRUE)) {
    message(
      "Package 'qs2' not installed; loading ", eviction_data_rds,
      " with readRDS() instead."
    )
  }

  if (file.exists(rds_path)) {
    return(readRDS(rds_path))
  }

  stop(
    "Eviction data not found. Expected:\n  ",
    qs2_path, "\n  ", rds_path,
    call. = FALSE
  )
}
