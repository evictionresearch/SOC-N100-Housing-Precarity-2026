# Eviction course data

**Canonical file for labs:** `d5_case_aggregated.rds` (base R `readRDS()`).

**Legacy:** `d5_case_aggregated.qs` (original ERN extract; requires archived `qs` 0.27.3).

## Regenerate `.rds` from `.qs`

```bash
Rscript code/convert_qs_to_rds.R
```

Requires `qs` 0.27.3 on the maintainer machine (CRAN Archive). See [`website/maintainer-notes.qmd`](../../website/maintainer-notes.qmd) for why we migrated and how qs / qs2 / RDS compare.
