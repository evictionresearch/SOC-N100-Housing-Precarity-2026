Quarto **source** for the course website. Rendered output goes to `../docs` for GitHub Pages.

**Maintainers only:** open `SOC-N100-website-for-maintainers.Rproj` in this folder to edit `.qmd` files and render.

Students use the published site in `docs/` and run labs from the repo root via `SOC-N100.Rproj` — not this folder.

## Maintainer documentation

Staff-only tooling lives in **[`maintainer/`](maintainer/)** (batch runner, patches, notes) — kept out of the student repo surface at the top level.

| Doc | Purpose |
|-----|---------|
| [`maintainer/notes.qmd`](maintainer/notes.qmd) | Data formats, lesson impact, batch lab runner |
| [`maintainer/run_all_labs.R`](maintainer/run_all_labs.R) | `Rscript website/maintainer/run_all_labs.R` |
| [`../DATAHUB.md`](../DATAHUB.md) | Berkeley DataHub setup, package installs, testing |
| [`../code/README.md`](../code/README.md) | R package two-layer pattern for labs |
| [`../data/evictions/README.md`](../data/evictions/README.md) | Regenerating eviction course files |
