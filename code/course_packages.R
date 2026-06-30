# SOC-N100 shared package helpers
#
# Two-layer pattern (use both):
#   1. Once per account: source("code/install_course_packages.R")
#   2. Each lab script:  source("code/course_packages.R") then load_pkg() / load_pkgs()
#
# Labs stay self-contained if a student opens one file without running the bulk
# installer first. Installs are skipped when requireNamespace() already succeeds.

#' Install a CRAN package if missing; fall back to cloud.r-project.org.
#'
#' Posit Package Manager (used on Berkeley DataHub) does not mirror every CRAN
#' package for every Linux + R combo — helpers retry cloud.r-project.org.
install_pkg_with_cran_fallback <- function(pkg) {
  repos <- getOption("repos")
  suppressWarnings(
    try(install.packages(pkg, repos = repos, quiet = TRUE), silent = TRUE)
  )
  if (requireNamespace(pkg, quietly = TRUE)) {
    return(invisible(TRUE))
  }

  message(
    "Package '", pkg, "' not found via default repos; ",
    "retrying from https://cloud.r-project.org (source on Linux)..."
  )
  install.packages(
    pkg,
    repos = "https://cloud.r-project.org",
    type = if (.Platform$OS.type == "unix") "source" else "both"
  )

  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      "Could not install package '", pkg, "'. ",
      "Run source('code/install_course_packages.R') or ask course staff.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Ensure a CRAN package is installed (idempotent; optional minimum version).
ensure_pkg <- function(pkg, min_version = NULL) {
  if (!requireNamespace(pkg, quietly = TRUE)) {
    install_pkg_with_cran_fallback(pkg)
  } else if (!is.null(min_version) && packageVersion(pkg) < min_version) {
    message(
      "Package '", pkg, "' ", packageVersion(pkg),
      " is older than required ", min_version, "; reinstalling..."
    )
    install_pkg_with_cran_fallback(pkg)
  }
  invisible(TRUE)
}

#' Ensure multiple CRAN packages are installed.
ensure_pkgs <- function(...) {
  for (pkg in c(...)) {
    ensure_pkg(pkg)
  }
  invisible(TRUE)
}

#' Load a package after ensuring it is installed.
load_pkg <- function(pkg) {
  ensure_pkg(pkg)
  library(pkg, character.only = TRUE)
}

#' Load multiple packages after ensuring they are installed.
load_pkgs <- function(...) {
  for (pkg in c(...)) {
    load_pkg(pkg)
  }
  invisible(TRUE)
}

#' Install a GitHub package if its namespace is not available.
ensure_github <- function(repo) {
  pkg <- basename(repo)
  if (requireNamespace(pkg, quietly = TRUE)) {
    return(invisible(TRUE))
  }
  ensure_pkg("remotes")
  remotes::install_github(repo, upgrade = "never", quiet = TRUE)
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop("Could not install GitHub package: ", repo, call. = FALSE)
  }
  invisible(TRUE)
}

#' Course CRAN dependencies (also listed in install_course_packages.R).
course_cran_packages <- c(
  "remotes",
  "tidyverse",
  "tidycensus",
  "librarian",
  "lubridate",
  "janitor",
  "tigris",
  "sf",
  "viridis",
  "tmap"
)

course_github_packages <- c(
  "evictionresearch/neighborhood"
)

#' Install all course packages (used by install_course_packages.R).
install_all_course_packages <- function() {
  for (pkg in course_cran_packages) {
    ensure_pkg(pkg)
  }
  for (repo in course_github_packages) {
    ensure_github(repo)
  }
  message("SOC-N100 packages ready. repo_root = ", get("repo_root", envir = .GlobalEnv))
  invisible(TRUE)
}
