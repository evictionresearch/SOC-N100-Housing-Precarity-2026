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

#' Temporarily set or clear GITHUB_PAT / GITHUB_TOKEN for remotes::install_github().
with_github_pat <- function(pat, code) {
  old <- list(
    GITHUB_PAT = Sys.getenv("GITHUB_PAT", unset = NA_character_),
    GITHUB_TOKEN = Sys.getenv("GITHUB_TOKEN", unset = NA_character_)
  )
  on.exit({
    for (nm in names(old)) {
      if (is.na(old[[nm]])) {
        Sys.unsetenv(nm)
      } else {
        do.call(Sys.setenv, setNames(list(old[[nm]]), nm))
      }
    }
  }, add = TRUE)
  Sys.unsetenv("GITHUB_PAT")
  Sys.unsetenv("GITHUB_TOKEN")
  if (!is.null(pat) && nzchar(pat)) {
    Sys.setenv(GITHUB_PAT = pat)
  }
  force(code)
}

#' Token from GitHub CLI when available (DataHub maintainers).
github_cli_token <- function() {
  if (!nzchar(Sys.which("gh"))) {
    return(NA_character_)
  }
  out <- tryCatch(
    system2("gh", c("auth", "token"), stdout = TRUE, stderr = FALSE),
    error = function(e) character(0)
  )
  if (length(out) < 1L || !nzchar(out[[1L]])) {
    return(NA_character_)
  }
  trimws(out[[1L]])
}

#' Install a GitHub package if its namespace is not available.
ensure_github <- function(repo) {
  pkg <- basename(repo)
  if (requireNamespace(pkg, quietly = TRUE)) {
    return(invisible(TRUE))
  }
  ensure_pkg("remotes")

  install_once <- function(pat) {
    with_github_pat(pat, {
      remotes::install_github(repo, upgrade = "never", quiet = TRUE)
    })
  }

  err <- NULL
  pat <- github_cli_token()
  if (!is.na(pat)) {
    tryCatch(install_once(pat), error = function(e) err <<- conditionMessage(e))
  }
  if (!requireNamespace(pkg, quietly = TRUE) && is.null(err)) {
    pat_env <- Sys.getenv("GITHUB_PAT", unset = "")
    if (!nzchar(pat_env)) {
      pat_env <- Sys.getenv("GITHUB_TOKEN", unset = "")
    }
    if (nzchar(pat_env)) {
      tryCatch(install_once(pat_env), error = function(e) err <<- conditionMessage(e))
    }
  }
  if (!requireNamespace(pkg, quietly = TRUE)) {
    if (!is.null(err) && grepl("401|Bad credentials", err, ignore.case = TRUE)) {
      message(
        "GitHub returned 401 (stale PAT or credentials). ",
        "Retrying public install of ", repo, " without a token..."
      )
      err <- NULL
      tryCatch(install_once(NULL), error = function(e) err <<- conditionMessage(e))
    } else if (is.null(err)) {
      tryCatch(install_once(NULL), error = function(e) err <<- conditionMessage(e))
    }
  }
  if (!requireNamespace(pkg, quietly = TRUE)) {
    stop(
      "Could not install GitHub package: ", repo,
      if (!is.null(err)) paste0("\n", err) else "",
      "\nOn DataHub: run `gh auth login`, then `export GITHUB_PAT=$(gh auth token)` ",
      "or `unset GITHUB_PAT GITHUB_TOKEN` if the repo is public.",
      call. = FALSE
    )
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
  "qs2",
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
