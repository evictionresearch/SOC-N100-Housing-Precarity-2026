# DRAFT — not submitted. Package-install request for SOC-N100 on r.datahub

**Status:** DRAFT, lower priority. File **after** the [RAM request](datahub-resource-request-draft.md) is resolved. Do not file until Tim and Aaron approve.

**Where to file:** [Package Addition/Change Request template](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=package_request.yml) on berkeley-dsep-infra/datahub (label `package-request`, auto-assigned to hub staff; allow **two business days**). The template assumes you have already test-installed the package on the hub and identified dependencies — hence the verify-on-hub checklist below.

**Who files it:** Aaron Culich (`@aculich`); mention instructor of record `@timathomas` in the course-name field.

## Why this request exists

Our labs use a two-layer pattern (`code/course_packages.R`: `load_pkg()` / `ensure_pkg()`) that self-installs missing packages into the student's home library at runtime, so nothing is *blocked* today. Pre-installing in the hub image makes first-run setup fast and reliable for ~50 students (no 10-minute compile of `sf`/`arrow` in week 1) and avoids 50 duplicate copies in home directories.

## Verify-on-hub checklist (do this BEFORE filing)

Only request packages that are actually missing from the image. On r.datahub, run:

```r
pkgs <- c("remotes", "tidyverse", "tidycensus", "librarian", "lubridate",
          "janitor", "qs2", "tigris", "sf", "viridis", "tmap",
          "duckdb", "duckdbfs", "arrow")
status <- sapply(pkgs, function(p) {
  if (requireNamespace(p, quietly = TRUE)) as.character(packageVersion(p)) else "MISSING"
})
data.frame(package = pkgs, version = unname(status))
```

- [ ] Run the check above on r.datahub in a **fresh home library** (or ignore `~/R` with `.libPaths(.Library)`) so self-installed copies don't mask what the image ships
- [ ] Delete rows below for anything already in the image; fill in requested versions (current CRAN) for the rest
- [ ] Test-install each remaining package on the hub (`install.packages()`) and note any system-library failures — those are the ones staff really need to handle
- [ ] `evictionresearch/neighborhood` is GitHub-only — note it explicitly (installed via `remotes::install_github`)
- [ ] File one issue listing all packages (staff accept batched R requests) and link it here and in `syllabus_TODO.md`

## Form field answers

**Title:** `Request R packages for class SOC-N100 (Summer 2026) on r.datahub`

**Package Name:**

Course stack (from [`code/course_packages.R`](../../code/course_packages.R) — prune to what the verify step shows missing):

| Package | Purpose | Likely in image? |
|---|---|---|
| `tidyverse` | core data wrangling/plotting | yes — verify |
| `tidycensus` | ACS/Census pulls | verify |
| `tigris` | TIGER shapefiles | verify |
| `sf` | vector geospatial | yes — verify |
| `tmap` | thematic maps | verify |
| `viridis` | color scales | verify |
| `lubridate` | dates (in tidyverse) | yes — verify |
| `janitor` | cleaning helpers | verify |
| `qs2` | fast serialization (course data format) | probably missing |
| `librarian` | package loading helper | probably missing |
| `remotes` | GitHub installs | verify |

Memory-tooling additions (used by the bonus lab [`code/lab6_bonus_memory.R`](../../code/lab6_bonus_memory.R)):

| Package | Purpose |
|---|---|
| `duckdb` | in-process SQL over larger-than-RAM data |
| `duckdbfs` | one-line duckdb over (geo)parquet/CSV, the ESPM-288 pattern |
| `arrow` | parquet read/write, lazy `open_dataset()` pipelines |

GitHub-only: `evictionresearch/neighborhood` (via `remotes::install_github("evictionresearch/neighborhood")`).

**Package Version:** current CRAN releases as of filing (fill exact versions from the verify-on-hub run).

**Hub URL:** `r.datahub.berkeley.edu`

**Reproducible test case:**

```r
# 1. Launch RStudio on r.datahub.berkeley.edu
# 2. Run:
pkgs <- c("tidyverse", "tidycensus", "tigris", "sf", "tmap", "viridis",
          "lubridate", "janitor", "qs2", "librarian", "remotes",
          "duckdb", "duckdbfs", "arrow")
for (p in pkgs) { library(p, character.only = TRUE); message(p, " ", packageVersion(p)) }
# 3. Expected: every package loads and prints a version, no errors.
# Course smoke test (uses the packages together):
con <- DBI::dbConnect(duckdb::duckdb()); DBI::dbGetQuery(con, "SELECT 42 AS ok"); DBI::dbDisconnect(con, shutdown = TRUE)
```

**Course Name:**

`2026 Summer, SOCIOL N100 002 — Housing Precarity and Displacement (https://classes.berkeley.edu/content/2026-summer-sociol-n100-002-lec-002). Instructor: Tim Thomas @timathomas; technical contact: Aaron Culich @aculich. Course repo: https://github.com/evictionresearch/SOC-N100-Housing-Precarity-2026`

**Semester Details:** `2026 Summer Session (course runs 07/07–08/14; packages can be removed after 08/20)`

**Installation Deadline:** `07/30` (before the Week 5 bonus lab and final-project window; not urgent — labs self-install in the meantime)
