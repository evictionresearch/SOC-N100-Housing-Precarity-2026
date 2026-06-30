# Eviction course data

| File | Format | Used when |
|------|--------|-----------|
| **`d5_case_aggregated.qs2`** | [qs2](https://cran.r-project.org/package=qs2) | **Primary in labs 3–4** (`qs2::qs_read` via `read_eviction_data()`) |
| `d5_case_aggregated.rds` | base R | **Fallback** if `qs2` is not installed on a hub |
| `d5_case_aggregated.qs` | legacy qs (archived CRAN) | Provenance only; maintainer conversion source |

## Regenerate `.rds` and `.qs2` from legacy `.qs`

On a maintainer machine (needs archived `qs` 0.27.3 + `qs2`):

```bash
Rscript code/convert_eviction_data.R
```

Background: [`website/maintainer-notes.qmd`](../../website/maintainer-notes.qmd).

## DataHub smoke test

```r
source("code/course_paths.R")
source("code/course_data.R")
requireNamespace("qs2")          # TRUE after install_course_packages
read_eviction_data()             # uses .qs2 when available
```
