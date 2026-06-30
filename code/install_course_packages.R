# One-time (or occasional) package setup for SOC-N100 on DataHub or local R.
# Run from repo root after opening SOC-N100.Rproj:
#   source("code/install_course_packages.R")

source("code/course_paths.R")

cran_packages <- c(
  "tidyverse",
  "tidycensus",
  "librarian",
  "lubridate",
  "janitor",
  "qs",
  "tigris",
  "sf",
  "viridis",
  "tmap"
)

for (pkg in cran_packages) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install.packages(pkg)
  }
}

if (!requireNamespace("librarian", quietly = TRUE)) {
  install.packages("librarian")
}

librarian::shelf(evictionresearch/neighborhood)

message("SOC-N100 packages installed. repo_root = ", repo_root)
