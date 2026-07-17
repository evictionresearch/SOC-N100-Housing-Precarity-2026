#!/usr/bin/env Rscript
# Maintainer: regenerate website/maintainer/patches/*.patch from the CURRENT
# lab files. Run from the repo root after ANY edit near a patched region --
# a stale patch fails the batch runner, and worse, the runner's exit-time
# reverse (patch -R) can silently clobber manual edits to those same lines.
#
#   Rscript website/maintainer/make_patches.R
#
# Each patch comments out (a) in-class `__` blanks and (b) RUN-ONCE
# install/key lines, plus lab 4's on-purpose summarize() error demo, so
# run_all_labs.R can smoke-test labs non-interactively. Lab 2 runs
# unpatched; lab 6 needs no patch (its install line ships commented). If a
# block below no longer matches its lab (stopifnot fires), update the block
# text here to the lab's current wording first.

repo <- normalizePath(".", mustWork = TRUE)
if (!file.exists(file.path(repo, "SOC-N100.Rproj"))) {
  stop("Run from the repo root (SOC-N100.Rproj not found).", call. = FALSE)
}

comment_blocks <- function(rel_src, blocks) {
  src <- file.path(repo, rel_src)
  txt <- readChar(src, file.size(src), useBytes = TRUE)
  for (b in blocks) {
    stopifnot(grepl(b, txt, fixed = TRUE))
    txt <- sub(b, gsub("\n", "\n# ", b, fixed = TRUE), txt, fixed = TRUE)
  }
  dst <- file.path(tempdir(), basename(rel_src))
  writeChar(txt, dst, eos = NULL, useBytes = TRUE)
  dst
}

specs <- list(
  list(
    rel = "code/lab1_intro_to_.R", patch = "lab1-batch.patch",
    blocks = c(
      '\ninstall.packages("tidycensus")\n',
      '\ncensus_api_key("PASTE-YOUR-KEY-HERE", overwrite = TRUE, install = TRUE)\n',
      '\nSys.getenv("CENSUS_API_KEY")\n',
      '\nrent_burden %>%\n  filter(estimate > __)\n',
      '\nmy_rent_burden <- get_acs(\n  geography = "county",\n  variables = "B25071_001",\n  state     = "__",\n  year      = 2024\n)\n',
      '\nnrow(my_rent_burden)\n'
    )
  ),
  list(
    rel = "code/lab3_rent_burden.R", patch = "lab3-batch.patch",
    blocks = c(
      '\nmy_county_raw <- get_acs(\n  geography = "tract",\n  variables = rb_vars,     # the same commented vector -- reuse is the point\n  state     = "__",\n  county    = "__",\n  year      = 2024\n)\n'
    )
  ),
  list(
    rel = "code/lab4_evictions_mapping.R", patch = "lab4-batch.patch",
    blocks = c(
      # the on-purpose summarize() mistake: fatal (not a warning) on R >= 4.6
      '\nindiana_evictions %>%\n  group_by(county, year) %>%\n  summarize(\n    evictions = sum(filings),\n    renters   = co_totrent\n  )\n'
    )
  ),
  list(
    rel = "code/lab5_rb_seg.R", patch = "lab5-batch.patch",
    blocks = c(
      '\ninstall.packages("remotes")\n',
      '\nremotes::install_github("evictionresearch/neighborhood")\n',
      '\nmy_seg <- ntdf(\n  state  = "__",\n  county = "__",\n  year   = 2024\n) %>%\n  mutate(nt_conc = as.character(nt_conc))\n\nmy_seg %>%\n  count(nt_conc, sort = TRUE)\n'
    )
  )
)

for (s in specs) {
  patched <- comment_blocks(s$rel, s$blocks)
  out <- file.path(repo, "website/maintainer/patches", s$patch)
  lab <- paste0("a/", s$rel)
  cmd <- sprintf('diff -u -L %s -L %s "%s" "%s" > "%s"',
                 shQuote(lab), shQuote(sub("^a/", "b/", lab)),
                 file.path(repo, s$rel), patched, out)
  status <- system(cmd)
  # diff exit 1 = differences found and written; 0/2 mean something is wrong
  stopifnot(status == 1)
  fwd <- system(paste("patch --dry-run -p1 <", shQuote(out)))
  stopifnot(fwd == 0)
  message("Regenerated + dry-ran ", s$patch)
}
