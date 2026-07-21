#!/usr/bin/env Rscript
# Maintainer: inventory every function called in the student-facing lab
# scripts (+ a1_example.R), with first appearance and per-file counts.
# Source of truth for the student cheat sheet (code/r_functions_cheatsheet.R)
# -- rerun after lab edits and reconcile that card against the output.
#
#   Rscript website/maintainer/list_lab_functions.R
#
# Bare `__` blanks (in-class fill-ins, live code in lab 1) break parsing;
# they are neutralized in memory before parse. Run from the repo root.

repo <- normalizePath(".", mustWork = TRUE)
if (!file.exists(file.path(repo, "SOC-N100.Rproj"))) {
  stop("Run from the repo root (SOC-N100.Rproj not found).", call. = FALSE)
}

files <- c(
  sort(list.files(file.path(repo, "code"), pattern = "^lab[0-9].*\\.R$",
                  full.names = TRUE)),
  file.path(repo, "code/a1_example.R")
)

inventory <- do.call(rbind, lapply(files, function(f) {
  txt <- readLines(f, warn = FALSE)
  # neutralize bare __ fill-in blanks (not the quoted "__" ones)
  txt <- gsub("> __", "> 0", txt, fixed = TRUE)
  pd <- getParseData(parse(text = txt, keep.source = TRUE))
  keep <- pd$token %in% c("SYMBOL_FUNCTION_CALL", "SPECIAL")
  if (!any(keep)) return(NULL)
  data.frame(file = basename(f), fn = pd$text[keep], token = pd$token[keep])
}))

# first appearance follows lab order; a1_example.R sorts after lab1 wave
order_key <- setNames(seq_along(files), basename(files))
inventory$ord <- order_key[inventory$file]

agg <- aggregate(ord ~ fn, inventory, min)
agg$first_file <- basename(files)[agg$ord]
counts <- as.data.frame(table(inventory$fn), stringsAsFactors = FALSE)
names(counts) <- c("fn", "n_calls")
agg <- merge(agg, counts, by = "fn")
agg$files <- vapply(agg$fn, function(x) {
  paste(sort(unique(inventory$file[inventory$fn == x])), collapse = ", ")
}, character(1))
agg <- agg[order(agg$ord, -agg$n_calls, agg$fn), c("fn", "first_file", "n_calls", "files")]

# full inventory, one row per distinct function
print(agg, row.names = FALSE, right = FALSE)
