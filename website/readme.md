# Maintainer guide (course staff only)

Quarto **source** for the course website plus all staff-facing tooling. Students work at the repo root (`SOC-N100.Rproj`, `code/`, `data/`) and read the published site — they never need this folder.

Published site (GitHub Pages, `/docs` on `main`): **<https://evictionresearch.net/SOC-N100-Housing-Precarity-2026/>**

## Launch on DataHub (per branch)

Same one-click git-pull links students get, but for each active branch — useful for testing work in progress on the hub before merging. nbgitpuller checks out the given branch in the student-identical environment.

| Branch | Launch | Purpose |
|--------|--------|---------|
| `main` | [![main on DataHub](https://img.shields.io/badge/DataHub-main-003262?logo=jupyter&logoColor=FDB515)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F&branch=main) | What students run (default) |
| `resource-request` | [![resource-request on DataHub](https://img.shields.io/badge/DataHub-resource--request-5B7F95?logo=jupyter&logoColor=FDB515)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F&branch=resource-request) | DataHub RAM/package request drafts + bonus memory lab |
| `lab1-datahub-merge` | [![lab1-datahub-merge on DataHub](https://img.shields.io/badge/DataHub-lab1--datahub--merge-5B7F95?logo=jupyter&logoColor=FDB515)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F&branch=lab1-datahub-merge) | Lab 1 merge work (merged to main) |
| `datahub-rstudio-2026` | [![datahub-rstudio-2026 on DataHub](https://img.shields.io/badge/DataHub-datahub--rstudio--2026-5B7F95?logo=jupyter&logoColor=FDB515)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F&branch=datahub-rstudio-2026) | Earlier DataHub batch-mode work (behind main) |

**Caution:** nbgitpuller merges upstream into the student's working copy — switching branches on the *same* hub account can leave a mixed state. Prefer testing branches on a spare account, or `git checkout` manually in the hub terminal. Regenerate links with the [DataHub Link Generator extension](https://chromewebstore.google.com/detail/datahub-link-generator/ijbgangngghdanhcnaliiobbiffocahf) (see `../DATAHUB.md`).

## Editing and publishing the website

1. Open [`SOC-N100-website-for-maintainers.Rproj`](SOC-N100-website-for-maintainers.Rproj) (this folder) in RStudio
2. Edit `.qmd` files (`index.qmd` home/schedule, `syllabus.qmd`, `resources.qmd`, `learn_r.qmd`)
3. Render the Quarto website — output goes to `../docs` per [`_quarto.yml`](_quarto.yml)
4. Commit updated `docs/` on `main` to publish

**GitHub Pages config:** Repo → Settings → Pages → Source: **`/docs`** on branch **`main`**. Canonical URL above (custom domain `evictionresearch.net`). The repo's About/homepage URL is set to the same address.

### `website/` vs `docs/` (and the old `gh-pages` branch)

Historically, many repos published GitHub Pages from a separate **`gh-pages` branch**. This repo uses the current pattern: **Quarto source in `website/`**, **built HTML in `docs/`**, and Pages serving `/docs` on `main`. Think of `website/` as the authoring tree and `docs/` as the deployable artifact — do not hand-edit HTML in `docs/`.

## Staff tooling

Staff-only tooling lives in **[`maintainer/`](maintainer/)** (batch runner, patches, request drafts, notes) — kept out of the student repo surface at the top level.

| Doc | Purpose |
|-----|---------|
| [`maintainer/README.md`](maintainer/README.md) | Index of all staff tooling and DataHub request drafts |
| [`maintainer/notes.qmd`](maintainer/notes.qmd) | Data formats, lesson impact, batch lab runner |
| [`maintainer/run_all_labs.R`](maintainer/run_all_labs.R) | `Rscript website/maintainer/run_all_labs.R` — smoke-test labs 1–6 |
| [`../DATAHUB.md`](../DATAHUB.md) | Berkeley DataHub setup, package installs, testing |
| [`../code/README.md`](../code/README.md) | R package two-layer pattern for labs |
| [`../data/evictions/README.md`](../data/evictions/README.md) | Regenerating eviction course files |

## AGENTS.md (for AI assistants)

The repo uses [`AGENTS.md`](../AGENTS.md) instead of tool-specific files like `CLAUDE.md`. A single, tool-neutral agents file is an emerging convention so Cursor, Claude Code, Copilot, and other assistants share the same project context:

- [AGENTS.md](https://agents.md/) — open format for agent instructions
- [GitHub Copilot: AGENTS.md](https://docs.github.com/en/copilot/concepts/agents/about-agents) — Copilot coding agent context
- [OpenAI Codex: AGENTS.md](https://developers.openai.com/codex/guides/agents-md/) — repository guidance for Codex
