# Census API key helper for SOC-N100 labs 2–5.
#
# We use tidycensus::census_api_key() — the package's built-in method — rather
# than a custom .env file. tidycensus is designed for this workflow.
#
# FIRST TIME in RStudio: ensure_census_api_key() opens a dialog to paste your
# key; tidycensus saves it to ~/.Renviron (install = TRUE). Later runs load
# from ~/.Renviron with no prompt.
#
# With install = TRUE, tidycensus writes CENSUS_API_KEY=... to ~/.Renviron on
# your account. That file lives in your DataHub *home directory*, not in the
# git repo, so the key is not pushed to GitHub.
#
# On DataHub, ~/.Renviron is on the hub server's filesystem under your user
# account. CDSS/DataHub administrators can access user home directories for
# support and operations — this is a different risk than publishing a key in a
# public repo, but it is not zero trust. For this course, a free Census API key
# (rate-limited, revocable, no billing) is "safe enough" on DataHub. Do not use
# this pattern for high-value secrets (passwords, paid API keys, private tokens).
#
# Never paste API keys into lab scripts that get committed to git.

if (!exists("repo_root", inherits = TRUE)) {
  stop("Source code/course_paths.R before code/course_secrets.R", call. = FALSE)
}

#' Prompt for a Census API key in RStudio (masked input), or readline fallback.
prompt_for_census_api_key <- function() {
  signup <- "https://api.census.gov/data/key_signup.html"
  prompt <- paste0(
    "Census API key (free signup: ", signup, ")\n",
    "Paste your key — it will be saved to ~/.Renviron, not this repo."
  )
  if (requireNamespace("rstudioapi", quietly = TRUE) && rstudioapi::isAvailable()) {
    return(trimws(rstudioapi::askForPassword(prompt)))
  }
  if (interactive()) {
    message(prompt)
    return(trimws(readline("Census API key: ")))
  }
  ""
}

#' Load Census API key from ~/.Renviron and register it with tidycensus.
#'
#' Call after load_pkgs("tidycensus"). On first use in RStudio, prompts once and
#' saves to ~/.Renviron via census_api_key(..., install = TRUE).
ensure_census_api_key <- function() {
  if (!requireNamespace("tidycensus", quietly = TRUE)) {
    stop("Load tidycensus first: load_pkgs('tidycensus')", call. = FALSE)
  }

  renviron_user <- path.expand("~/.Renviron")
  if (file.exists(renviron_user)) {
    readRenviron(renviron_user)
  }
  key <- trimws(Sys.getenv("CENSUS_API_KEY", unset = ""))

  if (!nzchar(key)) {
    key <- prompt_for_census_api_key()
    if (!nzchar(key)) {
      stop(
        "No Census API key provided.\n",
        "Sign up (free): https://api.census.gov/data/key_signup.html\n",
        "Re-run ensure_census_api_key() and paste your key in the dialog.",
        call. = FALSE
      )
    }
    tidycensus::census_api_key(key, overwrite = TRUE, install = TRUE)
    message("Census API key saved to ~/.Renviron for future sessions.")
    return(invisible(key))
  }

  tidycensus::census_api_key(key, overwrite = TRUE, install = FALSE)
  invisible(key)
}
