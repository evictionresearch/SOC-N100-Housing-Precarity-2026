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

load_pkgs("tidyverse", "tidycensus")   # example
```

Always run from repo root (`SOC-N100.Rproj` open) so `source("code/...")` resolves.

## Helper functions (`course_packages.R`)

| Function | Purpose |
|----------|---------|
| `ensure_pkg("pkg")` | Install from CRAN if missing; optional `min_version` |
| `ensure_pkgs(...)` | Same for multiple packages |
| `load_pkg("pkg")` | `ensure_pkg` + `library()` |
| `load_pkgs(...)` | Multiple packages |
| `ensure_github("org/repo")` | GitHub install if namespace missing |
| `ensure_qs()` | Legacy `qs` 0.27.3 from CRAN Archive (used by `ensure_pkg("qs")`) |
| `install_all_course_packages()` | Used by `install_course_packages.R` |

Installs use the session default repos (Posit PM on DataHub). If a package is missing from that mirror, helpers retry [cloud.r-project.org](https://cloud.r-project.org). The archived `qs` package uses `ensure_qs()` (CRAN Archive 0.27.3).

## `qs` on Berkeley DataHub

**Not an R 4.4.2 problem.** The original [`qs` package was archived from CRAN on 2026-01-17](https://cran.r-project.org/package=qs). Labs 3 and 4 read `.qs` files via `qread()`. The successor [`qs2`](https://cran.r-project.org/package=qs2) cannot read legacy `.qs` course files.

The warning:

```text
package 'qs' is not available for this version of R
```

means **CRAN no longer distributes `qs`**, not that your R version is too old.

`ensure_qs()` installs **0.27.3** from the [CRAN Archive](https://cran.r-project.org/src/contrib/Archive/qs/) (source compile on Linux may take a few minutes). If compilation fails, ask CDSS to pre-install that tarball (see [qsbase/qs#88](https://github.com/qsbase/qs/issues/88)).

## `librarian` in lab 4

Lab 4 teaches `librarian::shelf()` as a convenience wrapper. Under the hood it is similar to our pattern (install if missing, then load). We still call `load_pkg("librarian")` first so the demo does not unconditionally run `install.packages("librarian")`.

## RStudio "restart R before install?"

If RStudio prompts to restart before updating loaded packages, click **Yes** once, then re-run `source("code/install_course_packages.R")`. Bulk install is easiest on a **fresh R session** before opening lab scripts.
