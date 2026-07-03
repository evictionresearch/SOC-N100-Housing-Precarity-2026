# Lab 1 merge proposal: Tim’s pedagogy + DataHub infrastructure

**Status:** proposed (branch `lab1-datahub-merge`)  
**Author:** maintainer merge (Aaron / CiDR)  
**For review by:** Tim Thomas  

## Summary

Keep **Tim’s census-first Lab 1** on `main` (intro, `get_acs`, tidyverse verbs, data humility, student `__` exercises). Wire it to the **same DataHub patterns** already used in labs 2–5 so students, batch tests, and docs stay consistent.

Labs 2–5 on `main` already match `datahub-rstudio-2026`; **only Lab 1 diverged** after Tim’s `414a4c5` (*init major setup*).

## What we keep from Tim (unchanged pedagogy)

- Census-from-line-one narrative and section structure (§0–§10)
- `my_state <- "CA"`, rent burden by county, MOE / data humility
- YOUR TURN exercises with `__` blanks (in-class only)
- §10 open-ended state comparison (student fills in)

## What we add from DataHub work

| Tim’s `main` lab 1 | Merged lab 1 |
|--------------------|--------------|
| `library(tidycensus)` + `census_api_key("PASTE-YOUR-KEY-HERE")` in script | `source("code/course_*.R")`, `load_pkgs()`, inline `askForPassword` + `census_api_key(..., install = TRUE)` → `~/.Renviron` |
| `library(tidyverse)` / `library(tidycensus)` twice | Single `load_pkgs("tidyverse", "tidycensus")` at top |
| No `repo_root` | `ggsave()` → `output/plots/rent_burden_plot.png` via `repo_root` |
| `ggsave` commented out | Active save for batch smoke test |
| `__` blanks break `run_all_labs.R` | Maintainer `.patch` files (lab scripts stay clean) |

## Security / consistency

- **No API key in committed source.** Tim’s placeholder `PASTE-YOUR-KEY-HERE` encouraged pasting secrets into a file students commit; merged version uses an inline RStudio dialog in lab 1 only (labs 2–5 read `~/.Renviron`).
- **Package pattern** matches `code/README.md`: bulk `install_course_packages.R` once, `load_pkgs()` per lab.

## Batch testing

`website/maintainer/run_all_labs.R` applies `website/maintainer/patches/lab1-batch.patch` and `lab3-batch.patch` via `/usr/bin/patch`, then reverses on exit.

```bash
Rscript website/maintainer/run_all_labs.R --per-lab   # recommended on DataHub
```

## Files changed

- `code/lab1_intro_to_.R` — merged content
- `website/maintainer/run_all_labs.R` — batch runner + patch apply/restore
- `website/maintainer/patches/` — unified diffs (not shown to students)
- `website/maintainer/notes.qmd` — short cross-reference (this proposal)

## Suggested PR title

**Merge Lab 1: keep census-first intro, align with DataHub package/API patterns**

## Test plan

- [ ] DataHub: open `SOC-N100.Rproj`, run lab 1 line-by-line; dialog saves Census key
- [ ] `Rscript website/maintainer/run_all_labs.R --per-lab` → 5/5 OK
- [ ] Confirm `output/plots/rent_burden_plot.png` exists after lab 1
- [ ] Confirm lab 1 file on disk still has uncommented `__` exercises after batch run

## Not in scope

- Reverting Tim’s syllabus / website changes on `main`
- Changing labs 2–5 (already aligned)
