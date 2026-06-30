# Shared path helper for SOC-N100 labs.
# Source from repo root after opening SOC-N100.Rproj:
#   source("code/course_paths.R")

if (file.exists("SOC-N100.Rproj")) {
  repo_root <- normalizePath(getwd())
} else if (file.exists(file.path("..", "SOC-N100.Rproj"))) {
  repo_root <- normalizePath("..")
} else {
  repo_root <- normalizePath(
    Sys.getenv("REPO_ROOT", unset = "~/SOC-N100-Housing-Precarity-2026"),
    mustWork = FALSE
  )
}
