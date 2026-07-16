# Eviction course data

| File | Format | Used when |
|------|--------|-----------|
| **`d5_case_aggregated.rds`** | base R | **Default in labs 4 & 6** (`readRDS()`) |
| `d5_case_aggregated.qs2` | [qs2](https://cran.r-project.org/package=qs2) | Maintainer conversion artifact — **deprecated for teaching (2026-07-16)** |
| `d5_case_aggregated.qs` | legacy qs (archived CRAN) | Provenance only; maintainer conversion source |

## Regenerate `.rds` and `.qs2` from legacy `.qs`

```bash
Rscript course_infrastructure/convert_eviction_data.R
```

Background: [`website/maintainer/notes.qmd`](../../website/maintainer/notes.qmd).

## Verify on DataHub

```r
d <- readRDS("data/evictions/d5_case_aggregated.rds")
nrow(d)   # 139072
```
