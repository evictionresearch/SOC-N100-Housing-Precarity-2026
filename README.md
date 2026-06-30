# SOC-N100-Housing-Precarity-2026

Housing Precarity and Displacement: Racial and Gender Inequality in Gentrification and Eviction — UC Berkeley SOC-N100 course materials.

## Start here

| Role | What to open |
|------|----------------|
| **Students (labs on DataHub)** | [`SOC-N100.Rproj`](SOC-N100.Rproj) at repo root → scripts in [`code/`](code/) ([package practices](code/README.md)) |
| **Course site (browser)** | GitHub Pages from [`docs/`](docs/) (syllabus, schedule, resources) |
| **Maintainers (edit site)** | [`website/SOC-N100-website-for-maintainers.Rproj`](website/SOC-N100-website-for-maintainers.Rproj) → render to `docs/` |
| **DataHub setup** | [`DATAHUB.md`](DATAHUB.md) |

## Repository layout

- **`code/`** — R lab scripts (`lab1` … `lab5`)
- **`data/`** — datasets used in labs
- **`docs/`** — built course website (published; do not hand-edit HTML)
- **`website/`** — Quarto source for the site (maintainers only)

### `website/` vs `docs/` (and the old `gh-pages` branch)

Historically, many repos published GitHub Pages from a separate **`gh-pages` branch**. This repo uses the current pattern: **Quarto source in `website/`**, **built HTML in `docs/`**, and GitHub Pages configured to serve **`/docs` on `main`**.

Think of `website/` as the authoring tree and `docs/` as the deployable artifact — students read `docs/` in the browser; they do not need to open `website/` for labs.

## AGENTS.md (for AI assistants)

This repo uses [`AGENTS.md`](AGENTS.md) instead of tool-specific files like `CLAUDE.md`. A single, tool-neutral agents file is an emerging convention so Cursor, Claude Code, Copilot, and other assistants share the same project context:

- [AGENTS.md](https://agents.md/) — open format for agent instructions
- [GitHub Copilot: AGENTS.md](https://docs.github.com/en/copilot/concepts/agents/about-agents) — Copilot coding agent context
- [OpenAI Codex: AGENTS.md](https://developers.openai.com/codex/guides/agents-md/) — repository guidance for Codex

## Website build (maintainers)

The site is built with Quarto from `website/`:

1. Open `website/SOC-N100-website-for-maintainers.Rproj` in RStudio
2. Render the Quarto website (output goes to `../docs` per `website/_quarto.yml`)
3. Commit updated `docs/` when publishing

GitHub Pages: Repo → Settings → Pages → Source: **`/docs`** on branch **`main`**.
