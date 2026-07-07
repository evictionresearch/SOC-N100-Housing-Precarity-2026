# Maintainer tooling (staff only)

Everything in this folder is for **course staff and repo maintainers** — not students. Student-facing materials live at the repo root (`code/`, `data/`, `SOC-N100.Rproj`).

| Path | Purpose |
|------|---------|
| [`notes.qmd`](notes.qmd) | Staff notes (`draft: true` — not published to GitHub Pages) |
| [`run_all_labs.R`](run_all_labs.R) | Batch smoke-test labs 1–5 from the terminal |
| [`patches/`](patches/) | Unified diffs for batch runs (comment in-class blanks / intentional errors) |
| [`lab1-merge-proposal.md`](lab1-merge-proposal.md) | Lab 1 merge rationale (Tim pedagogy + DataHub infra) |

## Batch lab runner

From the **repo root**:

```bash
Rscript website/maintainer/run_all_labs.R --per-lab    # recommended on DataHub
Rscript website/maintainer/run_all_labs.R --labs=1,3
```

See [`notes.qmd`](notes.qmd) for Census key, memory limits, and patch behavior.

Also: [`../../DATAHUB.md`](../../DATAHUB.md), [`../../code/README.md`](../../code/README.md).
