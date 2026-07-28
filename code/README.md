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
- **Eviction data (labs 4 & 6):** loaded with base
  `readRDS("data/evictions/d5_case_aggregated.rds")`. The newer datasets in
  that folder ship as `.rds` + `.parquet` pairs; labs teach
  `saveRDS()`/`readRDS()` for private caches, `write_csv()` for sharing, and
  parquet for big or Python-bound tables. (The legacy `.qs`/`.qs2` conversion
  artifacts were removed 2026-07-28; git history keeps them.) To regenerate
  data files, see `data/evictions/README.md`.

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
(applies patches from `website/maintainer/patches/` — they comment in-class
`__` blanks and RUN-ONCE install/key lines — then reverses them; regenerated
2026-07-16, covering labs 1/3/5/6).

**Students never need to open the `.Rproj`** (dropped from the lab flow
2026-07-09 to remove setup friction): labs 1–3 and 5 are
working-directory-independent, and lab 4 reads the eviction file via the
full home path `~/SOC-N100-Housing-Precarity-2026/...` (every DataHub
clone lands there). Lab outputs (`ggsave`, `write_csv`, `tmap_save`) are
written explicitly to `~` (the home folder) so the save location never
depends on the working directory (2026-07-16; a proper file-path lesson
comes later in the course). Maintainer scripts and the batch runner still
assume the repo root (open `SOC-N100.Rproj`); the batch runner redirects
the labs' `~` writes into `output/`.
