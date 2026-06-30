Quarto **source** for the course website. Rendered output goes to `../docs` for GitHub Pages.

**Maintainers only:** open `SOC-N100-website-for-maintainers.Rproj` in this folder to edit `.qmd` files and render.

Students use the published site in `docs/` and run labs from the repo root via `SOC-N100.Rproj` — not this folder.

## Maintainer documentation

| Doc | Purpose |
|-----|---------|
| [`maintainer-notes.qmd`](maintainer-notes.qmd) | **Staff only** (`draft: true` — not published to GitHub Pages). Data formats, lesson impact, batch lab runner. |
| [`run_all_labs.R`](run_all_labs.R) | **Batch-run labs 1–5** from the terminal (`Rscript website/run_all_labs.R`) |
| [`../DATAHUB.md`](../DATAHUB.md) | Berkeley DataHub setup, package installs, testing |
| [`../code/README.md`](../code/README.md) | R package two-layer pattern for labs |
| [`../data/evictions/README.md`](../data/evictions/README.md) | Regenerating `d5_case_aggregated.rds` from legacy `.qs` |
