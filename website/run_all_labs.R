#!/usr/bin/env Rscript
# Maintainer: run all SOC-N100 lab scripts end-to-end (batch / non-interactive).
#
# Usage (from repo root):
#   Rscript website/run_all_labs.R
#   Rscript website/run_all_labs.R --install    # install packages first
#   Rscript website/run_all_labs.R --labs=1,3     # subset only
#   Rscript website/run_all_labs.R --per-lab        # fresh R per lab (DataHub)
#
# Requires: network for tidycensus/tigris labs (2–5). Census API key in
#   ~/.Renviron (set once via census_api_key(..., install = TRUE) in lab 2).
#
# Plots: ggplot/tmap code executes; graphics go to a null PDF device (nothing
# opens on screen). ggsave() in labs still writes files under output/.
# Interactive tmap ("view" mode) is forced to static "plot" mode here.
#
# Lab 3 includes an intentional in-class error (BATCH-SKIP block). Before
# sourcing labs, this script comments that block out and restores the file on
# exit (even if a lab fails).

args <- commandArgs(trailingOnly = TRUE)

#' Comment lines between # BATCH-SKIP-BEGIN and # BATCH-SKIP-END (inclusive markers stay).
comment_batch_skip_block <- function(lines) {
  begin <- grep("^# BATCH-SKIP-BEGIN", lines)
  end <- grep("^# BATCH-SKIP-END", lines)
  if (length(begin) != 1L || length(end) != 1L || end <= begin) {
    return(lines)
  }
  for (i in (begin + 1L):(end - 1L)) {
    if (!grepl("^[[:space:]]*#", lines[i])) {
      lines[i] <- paste0("# ", lines[i])
    }
  }
  lines
}

#' Write patched lab files for batch run; returns originals for restore on exit.
apply_maintainer_lab_patches <- function(repo_root, lab_ids) {
  originals <- list()
  if (!"3" %in% as.character(lab_ids)) {
    return(originals)
  }
  lab3_path <- file.path(repo_root, "code/lab3_evictions.R")
  original <- readLines(lab3_path, warn = FALSE)
  originals[[lab3_path]] <- original
  writeLines(comment_batch_skip_block(original), lab3_path)
  message("Maintainer patch: commented BATCH-SKIP block in lab3_evictions.R")
  originals
}

restore_maintainer_lab_patches <- function(originals) {
  for (path in names(originals)) {
    writeLines(originals[[path]], path)
  }
  if (length(originals) > 0) {
    message("Maintainer patch: restored ", length(originals), " lab file(s)")
  }
}

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

# --per-lab: spawn a separate Rscript per lab so memory is released between labs.
# Recommended on r.datahub (1GB pod limit) and when running inside RStudio Terminal.
if ("--per-lab" %in% args) {
  lab_ids <- parse_labs_flag(args)
  lab_ids <- lab_ids[as.character(lab_ids) %in% names(lab_scripts)]
  if (length(lab_ids) == 0) {
    stop("No valid labs selected. Use --labs=1,2,3,4,5", call. = FALSE)
  }

  runner <- normalizePath(file.path(repo_root, "website/run_all_labs.R"), mustWork = TRUE)
  message("Per-lab mode: fresh R process for each of: ", paste(lab_ids, collapse = ", "))

  results <- do.call(
    rbind,
    lapply(seq_along(lab_ids), function(i) {
      id <- as.character(lab_ids[[i]])
      child_args <- c(runner, paste0("--labs=", id))
      if ("--install" %in% args && i == 1L) {
        child_args <- c(child_args, "--install")
      }
      t0 <- proc.time()[["elapsed"]]
      exit_code <- system2("Rscript", child_args)
      elapsed <- proc.time()[["elapsed"]] - t0
      data.frame(
        lab = id,
        script = lab_scripts[[id]],
        status = if (identical(exit_code, 0L)) "OK" else "FAIL",
        seconds = round(elapsed, 1),
        message = if (identical(exit_code, 0L)) "" else paste0("Rscript exit code ", exit_code),
        stringsAsFactors = FALSE
      )
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
}

if ("--install" %in% args) {
  message("Installing course packages...")
  source("code/install_course_packages.R", local = new.env(parent = globalenv()))
}

lab_ids <- parse_labs_flag(args)
lab_ids <- lab_ids[as.character(lab_ids) %in% names(lab_scripts)]
if (length(lab_ids) == 0) {
  stop("No valid labs selected. Use --labs=1,2,3,4,5", call. = FALSE)
}

patched_originals <- apply_maintainer_lab_patches(repo_root, lab_ids)
on.exit(restore_maintainer_lab_patches(patched_originals), add = TRUE)

needs_census <- any(as.character(lab_ids) %in% c("2", "3", "4", "5"))
if (needs_census) {
  source("code/course_paths.R")
  source("code/course_secrets.R")
  tryCatch(
    ensure_census_api_key(),
    error = function(e) {
      stop(
        conditionMessage(e),
        "\nBatch runs are non-interactive: run census_api_key('YOUR_KEY', install = TRUE) once in RStudio first.",
        call. = FALSE
      )
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

results <- do.call(
  rbind,
  lapply(as.character(lab_ids), function(id) {
    res <- run_lab(id, lab_scripts[[id]])
    gc(verbose = FALSE)
    res
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
