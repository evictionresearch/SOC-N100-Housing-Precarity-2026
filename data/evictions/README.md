# Eviction course data

| File | Format | Used when |
|------|--------|-----------|
| **`d5_case_aggregated.qs2`** | [qs2](https://cran.r-project.org/package=qs2) | **Default in labs 3–4** (`qs2::qs_read`) |
| `d5_case_aggregated.rds` | base R | **Backup** if qs2 fails — uncomment `readRDS()` in the lab |
| `d5_case_aggregated.qs` | legacy qs (archived CRAN) | Provenance only; maintainer conversion source |

## Regenerate `.rds` and `.qs2` from legacy `.qs`

```bash
Rscript code/convert_eviction_data.R
```

Background: [`website/maintainer-notes.qmd`](../../website/maintainer-notes.qmd).

## Verify on DataHub (after install_course_packages)

```r
requireNamespace("qs2")
source("code/course_paths.R")
source("code/course_data.R")
d <- qs2::qs_read(file.path(repo_root, eviction_data_qs2))
nrow(d)   # 139072
```
