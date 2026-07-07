#!/usr/bin/env Rscript
# Maintainer: run all SOC-N100 lab scripts end-to-end (batch / non-interactive).
#
# Usage (from repo root):
#   Rscript website/maintainer/run_all_labs.R
#   Rscript website/maintainer/run_all_labs.R --install
#   Rscript website/maintainer/run_all_labs.R --labs=1,3
#   Rscript website/maintainer/run_all_labs.R --per-lab
#
# Requires: network for tidycensus/tigris labs (1–5). Census API key in
#   ~/.Renviron (set once via census_api_key(..., install = TRUE) in lab 1).
#
# Plots: ggplot/tmap code executes; graphics go to a null PDF device (nothing
# opens on screen). ggsave() in labs still writes files under output/.
# Interactive tmap ("view" mode) is forced to static "plot" mode here.
#
# Maintainer-only: website/maintainer/patches/*.patch comments in-class blanks
# and intentional errors (lab 1, lab 3) via /usr/bin/patch, then reverses on exit.

args <- commandArgs(trailingOnly = TRUE)

lab_batch_patches <- list(
  "1" = "website/maintainer/patches/lab1-batch.patch",
  "3" = "website/maintainer/patches/lab3-batch.patch"
)

run_system_patch <- function(patch_path, reverse = FALSE, strict = TRUE) {
  if (!nzchar(Sys.which("patch"))) {
    stop("patch command not found (need /usr/bin/patch for batch lab tests)", call. = FALSE)
  }
  reject_file <- file.path(
    repo_root, "website/maintainer/patches",
    paste0(tools::file_path_sans_ext(basename(patch_path)), ".rej")
  )
  patch_args <- c("-p1", "--batch", "--forward", "-r", reject_file)
  if (reverse) {
    patch_args <- c("-R", patch_args)
  }
  status <- system2("patch", patch_args, stdin = patch_path)
  if (!identical(as.integer(status), 0L)) {
    if (!strict) {
      return(invisible(FALSE))
    }
    action <- if (reverse) "reverse" else "apply"
    stop(
      "Failed to ", action, " maintainer patch: ", patch_path,
      " (lab file may have changed — regenerate the .patch)",
      call. = FALSE
    )
  }
  invisible(TRUE)
}

#' Best-effort reverse of all maintainer patches (e.g. after a crashed prior run).
revert_all_maintainer_lab_patches <- function(repo_root) {
  for (rel in rev(unlist(lab_batch_patches, use.names = FALSE))) {
    patch_path <- file.path(repo_root, rel)
    if (file.exists(patch_path)) {
      run_system_patch(patch_path, reverse = TRUE, strict = FALSE)
    }
  }
  invisible(NULL)
}

#' Apply maintainer .patch files for selected labs; updates `applied_ref$paths` after each.
apply_maintainer_lab_patches <- function(repo_root, lab_ids, applied_ref = NULL) {
  applied <- character()
  for (id in as.character(lab_ids)) {
    if (!id %in% names(lab_batch_patches)) next
    rel <- lab_batch_patches[[id]]
    patch_path <- file.path(repo_root, rel)
    if (!file.exists(patch_path)) next
    run_system_patch(patch_path, reverse = FALSE)
    applied <- c(applied, patch_path)
    if (!is.null(applied_ref)) {
      applied_ref$paths <- applied
    }
    message("Maintainer patch: applied ", basename(patch_path))
  }
  applied
}

restore_maintainer_lab_patches <- function(applied) {
  if (length(applied) == 0) return(invisible(NULL))
  for (patch_path in rev(applied)) {
    run_system_patch(patch_path, reverse = TRUE)
  }
  message("Maintainer patch: restored ", length(applied), " lab file(s)")
  invisible(NULL)
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

  runner <- normalizePath(file.path(repo_root, "website/maintainer/run_all_labs.R"), mustWork = TRUE)
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

run_batch_labs <- function(repo_root, lab_ids, args) {
  # on.exit only runs inside a function — not at top-level Rscript.
  patch_state <- list(paths = character())
  on.exit(restore_maintainer_lab_patches(patch_state$paths), add = TRUE)
  revert_all_maintainer_lab_patches(repo_root)
  patch_state$paths <- apply_maintainer_lab_patches(repo_root, lab_ids, applied_ref = patch_state)

  if ("--install" %in% args) {
    message("Installing course packages...")
    source("code/install_course_packages.R", local = new.env(parent = globalenv()))
  }

  needs_census <- any(as.character(lab_ids) %in% c("1", "2", "3", "4", "5"))
  if (needs_census) {
    renviron <- path.expand("~/.Renviron")
    if (file.exists(renviron)) readRenviron(renviron)
    if (!nzchar(Sys.getenv("CENSUS_API_KEY", unset = ""))) {
      stop(
        "Census API key missing. Run lab 1 in RStudio once (dialog saves to ~/.Renviron), ",
        "or census_api_key('YOUR_KEY', install = TRUE) in the Console.",
        call. = FALSE
      )
    }
  }

  dir.create(file.path(repo_root, "output", "plots"), recursive = TRUE, showWarnings = FALSE)
  dir.create(file.path(repo_root, "output"), recursive = TRUE, showWarnings = FALSE)

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
    return(1L)
  }

  message("\nAll requested labs completed without errors.")
  0L
}

lab_ids <- parse_labs_flag(args)
lab_ids <- lab_ids[as.character(lab_ids) %in% names(lab_scripts)]
if (length(lab_ids) == 0) {
  stop("No valid labs selected. Use --labs=1,2,3,4,5", call. = FALSE)
}

exit_code <- tryCatch(
  run_batch_labs(repo_root, lab_ids, args),
  error = function(e) {
    message(conditionMessage(e))
    1L
  }
)
quit(status = exit_code)
