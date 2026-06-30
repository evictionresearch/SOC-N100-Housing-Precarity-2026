#!/usr/bin/env Rscript
# Maintainer: run all SOC-N100 lab scripts end-to-end (batch / non-interactive).
#
# Usage (from repo root):
#   Rscript website/run_all_labs.R
#   Rscript website/run_all_labs.R --install    # install packages first
#   Rscript website/run_all_labs.R --labs=1,3     # subset only
#
# Requires: network for tidycensus/tigris labs (2–5); Census API key in
#   Sys.getenv("CENSUS_API_KEY") or the course key in lab2.
#
# Plots: ggplot/tmap code executes; graphics go to a null PDF device (nothing
# opens on screen). ggsave() in labs still writes files under output/.
# Interactive tmap ("view" mode) is forced to static "plot" mode here.

args <- commandArgs(trailingOnly = TRUE)

parse_labs_flag <- function(args) {
  flag <- grep("^--labs=", args, value = TRUE)
  if (length(flag) == 0) {
    return(1:5)
  }
  nums <- strsplit(sub("^--labs=", "", flag[[1]]), ",", fixed = TRUE)[[1]]
  as.integer(nums)
}

find_repo_root <- function() {
  candidates <- c(
    getwd(),
    normalizePath(file.path(getwd(), ".."), mustWork = FALSE),
    Sys.getenv("REPO_ROOT", unset = "")
  )
  for (cand in candidates) {
    if (nzchar(cand) && file.exists(file.path(cand, "SOC-N100.Rproj"))) {
      return(normalizePath(cand, mustWork = TRUE))
    }
  }
  stop(
    "Could not find repo root (SOC-N100.Rproj). ",
    "Run from the clone root or set REPO_ROOT.",
    call. = FALSE
  )
}

lab_scripts <- c(
  "1" = "code/lab1_intro_to_.R",
  "2" = "code/lab2_census_data.R",
  "3" = "code/lab3_evictions.R",
  "4" = "code/lab4_li_renters_mapping.R",
  "5" = "code/lab5_rb_seg.R"
)

repo_root <- find_repo_root()
setwd(repo_root)
message("Repo root: ", repo_root)

if ("--install" %in% args) {
  message("Installing course packages...")
  source("code/install_course_packages.R", local = new.env(parent = globalenv()))
}

census_key <- Sys.getenv("CENSUS_API_KEY", unset = "")
if (nzchar(census_key) && requireNamespace("tidycensus", quietly = TRUE)) {
  tryCatch(
    tidycensus::census_api_key(census_key, overwrite = TRUE, install = TRUE),
    error = function(e) {
      message("Note: could not set CENSUS_API_KEY from environment: ", conditionMessage(e))
    }
  )
}

dir.create(file.path(repo_root, "output", "plots"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(repo_root, "output"), recursive = TRUE, showWarnings = FALSE)

# Capture plots without opening a GUI viewer.
pdf(file = nullfile())
on.exit(grDevices::dev.off(), add = TRUE)

if (requireNamespace("tmap", quietly = TRUE)) {
  tmap::tmap_mode("plot")
}

run_lab <- function(lab_id, script_path) {
  label <- sprintf("lab%s (%s)", lab_id, basename(script_path))
  message("\n", strrep("=", 60), "\n", "Running ", label, "\n", strrep("=", 60))

  if (!file.exists(script_path)) {
    return(data.frame(
      lab = lab_id,
      script = script_path,
      status = "MISSING",
      seconds = NA_real_,
      message = "file not found",
      stringsAsFactors = FALSE
    ))
  }

  env <- new.env(parent = globalenv())
  env$repo_root <- repo_root
  env$View <- function(x, ...) {
    message("[", label, "] View() skipped in batch run")
    invisible(x)
  }
  env$tmap_mode <- function(mode = "plot", ...) {
    message("[", label, "] tmap_mode('", mode, "') -> plot (batch run)")
    if (requireNamespace("tmap", quietly = TRUE)) {
      tmap::tmap_mode("plot")
    }
    invisible()
  }

  t0 <- proc.time()[["elapsed"]]
  err <- NULL
  tryCatch(
    sys.source(script_path, envir = env, keep.source = FALSE),
    error = function(e) {
      err <<- conditionMessage(e)
    }
  )
  elapsed <- proc.time()[["elapsed"]] - t0

  data.frame(
    lab = lab_id,
    script = script_path,
    status = if (is.null(err)) "OK" else "FAIL",
    seconds = round(elapsed, 1),
    message = if (is.null(err)) "" else err,
    stringsAsFactors = FALSE
  )
}

lab_ids <- parse_labs_flag(args)
lab_ids <- lab_ids[as.character(lab_ids) %in% names(lab_scripts)]
if (length(lab_ids) == 0) {
  stop("No valid labs selected. Use --labs=1,2,3,4,5", call. = FALSE)
}

results <- do.call(
  rbind,
  lapply(as.character(lab_ids), function(id) {
    run_lab(id, lab_scripts[[id]])
  })
)

message("\n", strrep("=", 60), "\nSummary\n", strrep("=", 60))
print(results, row.names = FALSE)

n_fail <- sum(results$status == "FAIL")
if (n_fail > 0) {
  message("\n", n_fail, " lab(s) failed.")
  quit(status = 1)
}

message("\nAll requested labs completed without errors.")
quit(status = 0)
