# Course infrastructure (staff only)

Maintainer scripts that support the course but are **never opened or
`source()`d by students**. Moved out of `code/` on 2026-07-14 so that
students browsing the Files pane on DataHub see only the lab scripts.

| File | Purpose |
|------|---------|
| `course_paths.R` | shared `repo_root` helper |
| `course_packages.R` | `ensure_pkg()` / `load_pkg()` / bulk-install helpers with CRAN fallback |
| `course_data.R` | eviction file path constants (`eviction_data_qs2`, `eviction_data_rds`) |
| `install_course_packages.R` | optional one-shot bulk install on a fresh DataHub account (a speed-up for staff/testing, **not** a student prerequisite) — sources `course_paths.R` + `course_packages.R` |
| `convert_eviction_data.R` | rebuilds `data/evictions/` files from the legacy `.qs` (writes `.rds` + `.qs2`); standalone `Rscript`, needs qs 0.27.3 from the CRAN Archive on a maintainer machine |
| `convert_qs_to_rds.R` | deprecated wrapper — runs `convert_eviction_data.R` |

Run the converter from the repo root:

```bash
Rscript course_infrastructure/convert_eviction_data.R
```

The batch lab runner (`run_all_labs.R`, with its `patches/`) and the
data-format/maintainer notes live in
[`website/maintainer/`](../website/maintainer/); the runner's `--install`
flag sources `install_course_packages.R` from here. Student-facing lab
conventions are documented in [`code/README.md`](../code/README.md).
