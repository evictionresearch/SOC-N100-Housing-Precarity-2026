# R lab scripts — package practices

## Two layers (best of both worlds)

| Layer | When | What |
|-------|------|------|
| **Bulk install** | Once per DataHub account (start of term) | `source("code/install_course_packages.R")` |
| **Per-lab guards** | Top of each `lab*.R` | `source("code/course_packages.R")` then `load_pkg()` / `load_pkgs()` |

**Why both?**

- Bulk install gets students through lab 1 faster and avoids repeating large downloads.
- Per-lab `load_pkg()` calls keep each script **self-contained** and **idempotent**: re-running a lab does not reinstall packages that are already present (`requireNamespace()` check first).
- Pedagogically, labs still show *which* packages each lesson uses.

## Standard header for lab scripts

```r
source("code/course_paths.R")
source("code/course_packages.R")
source("code/course_secrets.R")   # labs 2–5 (Census API)

load_pkgs("tidyverse", "tidycensus")   # example
ensure_census_api_key()                # labs 2–5 (reads ~/.Renviron)
```

Labs 3–4 also `source("code/course_data.R")` for eviction file paths, then `qs2::qs_read()`.

Always run from repo root (`SOC-N100.Rproj` open) so `source("code/...")` resolves.

## Census API key (security)

We teach **tidycensus's built-in method** — not a custom `.env` file. tidycensus documents this workflow; it keeps keys out of git.

**One-time setup (lab 2, in RStudio):** run the lab script (or `ensure_census_api_key()`). On first use, RStudio shows a dialog to paste your key; tidycensus saves it to `~/.Renviron`. Later labs load it with no prompt.

Manual alternative in the Console: `census_api_key("YOUR_KEY", install = TRUE)`

**DataHub caveat:** hub administrators can access user home directories for operations and support. That is a different threat than scraping a public repo, but it is not zero trust. A free, rate-limited, revocable Census key is **safe enough** for this course. Do not use `~/.Renviron` on shared infrastructure for high-value secrets.

**If a key is accidentally committed to git:** revoke it at Census and request a new one.

Sign up: [api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html)

## Helper functions

### `course_packages.R`

| Function | Purpose |
|----------|---------|
| `ensure_pkg("pkg")` | Install from CRAN if missing; optional `min_version` |
| `load_pkg("pkg")` | `ensure_pkg` + `library()` |
| `load_pkgs(...)` | Multiple packages |
| `ensure_github("org/repo")` | GitHub install if namespace missing |
| `install_all_course_packages()` | Used by `install_course_packages.R` |

### `course_data.R`

Path constants: `eviction_data_qs2`, `eviction_data_rds` (labs 3–4).

### `course_secrets.R`

| Function | Purpose |
|----------|---------|
| `ensure_census_api_key()` | Prompt once in RStudio if missing; else reload `~/.Renviron` |
| `prompt_for_census_api_key()` | RStudio password dialog (or `readline` fallback) |

See file header for why we use tidycensus's `census_api_key(..., install = TRUE)` and DataHub security notes.

Installs use the session default repos (Posit PM on DataHub). If a package is missing from that mirror, helpers retry [cloud.r-project.org](https://cloud.r-project.org).

## Course eviction data: `qs2` + `.rds` backup

| File | Use |
|------|-----|
| `data/evictions/d5_case_aggregated.qs2` | **Default in labs 3–4** — `qs2::qs_read()` |
| `data/evictions/d5_case_aggregated.rds` | **Backup** — `readRDS()` if qs2 fails (comment swap in lab) |

Legacy `.qs` is provenance only. Regenerate course files: `Rscript code/convert_eviction_data.R`.

**Maintainers:** [`website/maintainer-notes.qmd`](../website/maintainer-notes.qmd).

## `librarian` in lab 4

Lab 4 teaches `librarian::shelf()` as a convenience wrapper. Under the hood it is similar to our pattern (install if missing, then load). We still call `load_pkg("librarian")` first so the demo does not unconditionally run `install.packages("librarian")`.

## RStudio "restart R before install?"

If RStudio prompts to restart before updating loaded packages, click **Yes** once, then re-run `source("code/install_course_packages.R")`. Bulk install is easiest on a **fresh R session** before opening lab scripts.
