# SOC-N100 shared course data paths and loaders.
# Source after course_paths.R (needs repo_root).

eviction_data_qs2 <- "data/evictions/d5_case_aggregated.qs2"
eviction_data_rds <- "data/evictions/d5_case_aggregated.rds"

#' Load Indiana tract-level eviction data (labs 3–4).
#'
#' Same logic as the inline blocks in lab3_evictions.R and lab4_li_renters_mapping.R:
#' qs2::qs_read(.qs2) by default, readRDS(.rds) fallback.
read_eviction_data <- function() {
  eviction_qs2_path <- file.path(repo_root, eviction_data_qs2)
  eviction_rds_path <- file.path(repo_root, eviction_data_rds)

  if (requireNamespace("qs2", quietly = TRUE) && file.exists(eviction_qs2_path)) {
    return(qs2::qs_read(eviction_qs2_path))
  }

  if (file.exists(eviction_qs2_path) && !requireNamespace("qs2", quietly = TRUE)) {
    message(
      "Package 'qs2' not installed; loading ", eviction_data_rds,
      " with readRDS() instead."
    )
  }

  if (file.exists(eviction_rds_path)) {
    return(readRDS(eviction_rds_path))
  }

  stop(
    "Eviction data not found. Expected:\n  ",
    eviction_qs2_path, "\n  ", eviction_rds_path,
    call. = FALSE
  )
}
