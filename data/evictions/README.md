data/evictions/d5_case_aggregated.rds

Maintainers: regenerate from the legacy `.qs` file (requires archived `qs` 0.27.3):

```r
saveRDS(qs::qread("data/evictions/d5_case_aggregated.qs"),
        "data/evictions/d5_case_aggregated.rds")
```

Or run `Rscript code/convert_qs_to_rds.R` on a machine where `qs` installs.
