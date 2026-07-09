# R lab scripts — how packages and data work

## Student labs use plain base patterns (deliberate pedagogy)

The `lab*.R` scripts teach and use only the standard, universal R idioms —
no course-specific helper functions. Decided 2026-07-09: many students are
new to (and nervous about) coding, so labs must read like every R book and
tutorial they will ever see.

- **Install once:** `install.packages("tidycensus")` — lab 1 teaches this
  (tidyverse is pre-installed on the DataHub image). Labs that need a new
  package (e.g., tmap) carry their own clearly marked RUN-ONCE install line.
- **Load each session:** `library(tidyverse)`, `library(tidycensus)`, etc.
  at the top of every lab.
- **Census API key:** set up once in lab 1 §6 with tidycensus's built-in
  `census_api_key("KEY", install = TRUE)` (saved to `~/.Renviron`; labs 2+
  rely on it). Students are told to put the placeholder text back after the
  line runs so keys don't linger in scripts. **Never commit a key to git.**
  If one is committed accidentally: revoke it at Census and request a new one.
- **Eviction data (lab 4):** loaded with base
  `readRDS("data/evictions/d5_case_aggregated.rds")`. The `.qs2` file next
  to it is the same table in a faster format (maintainer/ERN default);
  regenerate both with `Rscript code/convert_eviction_data.R`.

DataHub caveat (unchanged): hub administrators can access user home
directories. A free, rate-limited, revocable Census key is safe enough for
this course; don't use `~/.Renviron` on shared infrastructure for
high-value secrets.

Key signup: [api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html)

## Maintainer-only helpers (not used by student labs)

These support maintenance scripts and batch testing — students never
`source()` them:

| File | Used by |
|------|---------|
| `course_paths.R` (`repo_root`) | `convert_eviction_data.R`, batch runner |
| `course_packages.R` (`ensure_pkg`, `load_pkg`, `ensure_github`) | bulk installer, batch runner |
| `course_data.R` (eviction path constants) | conversion + batch scripts |
| `install_course_packages.R` | optional one-shot bulk install on a fresh DataHub account (a speed-up, not a prerequisite) |

Batch smoke-testing of all labs: [`website/maintainer/run_all_labs.R`](../website/maintainer/run_all_labs.R)
(applies patches from `website/maintainer/patches/` to fill in-class `__`
blanks, then reverses them). **Note:** patches must be regenerated after the
2026-07 lab rewrites — see the maintainer notes.

Run everything from the repo root (`SOC-N100.Rproj` open) so relative paths
like `data/evictions/...` resolve.
