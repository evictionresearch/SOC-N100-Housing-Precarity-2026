# SOC-N100 shared package helpers
#
# Two-layer pattern (use both):
#   1. Once per account: source("code/install_course_packages.R")
#   2. Each lab script:  source("code/course_packages.R") then load_pkg() / load_pkgs()
#
# Labs stay self-contained if a student opens one file without running the bulk
# installer first. Installs are skipped when requireNamespace() already succeeds.

#' Install legacy `qs` (archived from CRAN 2026-01-17).
#'
#' Course data uses `.qs` files written with the original `qs` package. The
#' successor `qs2` cannot read them. Last CRAN release: 0.27.3.
ensure_qs <- function() {
  if (requireNamespace("qs", quietly = TRUE)) {
    return(invisible(TRUE))
  }

  message(
    "Package 'qs' was removed from CRAN (2026-01-17). ",
    "Installing last release (0.27.3) from CRAN Archive..."
  )
  ensure_pkg("remotes")
  tryCatch(
    remotes::install_version(
      "qs",
      version = "0.27.3",
      repos = "https://cloud.r-project.org",
      upgrade = "never",
      quiet = TRUE
    ),
    error = function(e) invisible(NULL)
  )

  if (requireNamespace("qs", quietly = TRUE)) {
    return(invisible(TRUE))
  }

  message("CRAN Archive install failed; retrying from GitHub (qsbase/qs)...")
  tryCatch(
    remotes::install_github("qsbase/qs", upgrade = "never", quiet = TRUE),
    error = function(e) invisible(NULL)
  )

  if (!requireNamespace("qs", quietly = TRUE)) {
    stop(
      "Could not install legacy package 'qs' (archived from CRAN 2026-01-17). ",
      "Ask course staff or CDSS to pre-install qs 0.27.3 from the CRAN Archive.",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Install a CRAN package if missing; fall back to cloud.r-project.org.
#'
#' Posit Package Manager (used on Berkeley DataHub) does not mirror every CRAN
#' package for every Linux + R combo. Use `ensure_qs()` for the archived `qs`
#' package.
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
  if (identical(pkg, "qs")) {
    return(ensure_qs())
  }
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
  "remotes", # needed for qs CRAN Archive + GitHub installs
  "tidyverse",
  "tidycensus",
  "librarian",
  "lubridate",
  "janitor",
  "qs", # archived CRAN — installed via ensure_qs() from CRAN Archive
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
