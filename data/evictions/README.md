# Eviction course data

| File | Unit of observation | Coverage | Used when |
|------|-------|----------|-----------|
| **`d5_case_aggregated.rds`** | Indiana, tract × month, with race/sex estimated columns | 2016 – 2022-10 | **Default in labs 4 & 6** (`readRDS()`) — the classroom file |
| `mn_tract_evictions.rds` / `.parquet` | Minnesota, tract × month, with race filings, race denominators, and precomputed rates | 2017 – 2025 | Final projects; state comparisons (MN vs IN protections) |
| `in_lsc_tract_filings.rds` / `.parquet` | Indiana, tract × month, filing **counts only** | 2016 – 2026-04 | Final projects needing recent Indiana filings |
| `in_lsc_county_filings.rds` / `.parquet` | Indiana, county × month, filing **counts only** | 2016 – 2026-04 | True county totals (see note 3) |

## Reading the newer files

```r
mn <- readRDS("data/evictions/mn_tract_evictions.rds")        # or read_parquet()
in_new <- readRDS("data/evictions/in_lsc_tract_filings.rds")
```

## Methodology notes (read before citing numbers)

1. **Schemas differ across states.** The Indiana classroom file (`d5_*`) uses
   `tr_totrent` / `black_head`-style names and carries sex breakdowns; the
   Minnesota file uses `tr_renters` / `filings_black`-style names, carries no
   sex columns, and includes precomputed `filings_*_rate` columns. Column
   names are documented in each file; don't assume one state's names on the
   other's table.
2. **Minnesota counts are post-cleanup totals.** MN sources from the LSC feed,
   which reflects the court's persistent tally *after* dismissals and
   expungements (Minnesota's motion-less expungement statute, effective
   2024-01-01, removes cases from the public feed). Absolute MN counts are
   therefore conservative vs. raw-filing trackers; **ratios (e.g., race
   disparity) are unaffected.**
3. **Indiana LSC update: tract sums run under county totals.** Only cases
   whose defendant address geocodes to street/point precision can be placed
   in a tract (95.2% of cases in this build). The county file counts every
   case and is the authoritative total; expect tract sums ≈ 5% under it.
4. **The classroom `d5_*` file remains the source for race/sex analysis of
   Indiana.** The LSC update is counts-only. On their 2016 – 2022-10 overlap,
   LSC yearly totals sit 0.1–5.5% below `d5` (LSC is a post-cleanup tally;
   `d5` is ERN's earlier extract) — cite whichever you used, by name.

## Regenerate

```bash
Rscript course_infrastructure/convert_eviction_data.R        # d5 .rds from the legacy .qs (removed from the repo 2026-07-28; retrieve from git history)
Rscript course_infrastructure/build_eviction_data_updates.R  # MN + IN LSC updates (maintainer machine only)
```

Sources for the update script live on the maintainer machine (the MN
pipeline's d6 stage; the 2026-05-01 LSC drop's Indiana d0 output), not in
this repo. Background: `website/maintainer/notes.qmd`.

## Verify on DataHub

```r
nrow(readRDS("data/evictions/d5_case_aggregated.rds"))    # 139072
nrow(readRDS("data/evictions/mn_tract_evictions.rds"))    # 159530
```
