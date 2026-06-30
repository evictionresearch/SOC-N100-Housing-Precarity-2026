# One-time (or occasional) package setup for SOC-N100 on DataHub or local R.
#
# Run from repo root after opening SOC-N100.Rproj:
#   source("code/install_course_packages.R")
#
# See code/README.md for the two-layer package pattern used in lab scripts.

source("code/course_paths.R")
source("code/course_packages.R")

install_all_course_packages()
