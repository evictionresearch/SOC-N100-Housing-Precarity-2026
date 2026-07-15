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
  regenerate both with `Rscript course_infrastructure/convert_eviction_data.R`.

DataHub caveat (unchanged): hub administrators can access user home
directories. A free, rate-limited, revocable Census key is safe enough for
this course; don't use `~/.Renviron` on shared infrastructure for
high-value secrets.

Key signup: [api.census.gov/data/key_signup.html](https://api.census.gov/data/key_signup.html)

## Maintainer-only helpers (not used by student labs)

Moved to [`../course_infrastructure/`](../course_infrastructure/) on
2026-07-14 so this folder holds only what students open — see its README
for the file list. Students never `source()` any of them.

Batch smoke-testing of all labs: [`website/maintainer/run_all_labs.R`](../website/maintainer/run_all_labs.R)
(applies patches from `website/maintainer/patches/` to fill in-class `__`
blanks, then reverses them). **Note:** patches must be regenerated after the
2026-07 lab rewrites — see the maintainer notes.

**Students never need to open the `.Rproj`** (dropped from the lab flow
2026-07-09 to remove setup friction): labs 1–3 and 5 are
working-directory-independent, and lab 4 reads the eviction file via the
full home path `~/SOC-N100-Housing-Precarity-2026/...` (every DataHub
clone lands there). Lab outputs (`ggsave`, `write_csv`) land in the
session's working directory — the home folder on a fresh hub session.
Maintainer scripts and the batch runner still assume the repo root (open
`SOC-N100.Rproj`).
