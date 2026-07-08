# REQUESTS.md — DataHub resource requests: history, evidence, and strategy

**Audience:** course staff / maintainers. Companion to [`DATAHUB.md`](../../DATAHUB.md) (student setup) and [`datahub-official-guide.md`](datahub-official-guide.md) (process guide).

**Evidence base:** all 60 issues matching `"Request more RAM"` in [berkeley-dsep-infra/datahub](https://github.com/berkeley-dsep-infra/datahub/issues?q=%22Request+more+RAM%22), dumped with full comment threads to [`mirrors/datahub-ram-issues.json`](mirrors/datahub-ram-issues.json) on 2026-07-07, plus local lab profiling (see §4).

---

## 1. How requests actually get decided

Mechanics observed across the issue corpus:

1. Instructor files the [Increase RAM Request template](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=add_memory_config_request.yml) (fields: hub, course, Academic Guide URL, **bCourses ID**, student count, RAM 1–8 GB dropdown, justification, fulfillment date, **end date**).
2. Staff (historically Balaji Alwar, `balajialg`) triages — usually same or next business day in term time.
3. A config PR adds a `group_profiles` stanza keyed to the bCourses course group (e.g. `course::1555635`) in the hub's `config/common.yaml`; merged to staging, then prod.
4. Instructor logs out/in and verifies; issue closed. Configs are **removed at semester end** ([semester start/end tasks](https://docs.datahub.berkeley.edu/tasks/semester-start-end-tasks.html)) — hence the required end date.

Policy ([curriculum guide, Memory and CPU](https://curriculum-guide.datahub.berkeley.edu/support/memory-cpu/)): decision weighs **students × RAM × duration**. Auto-approval thresholds for the product of student count × RAM:

| Duration | Auto-approval threshold |
|----------|------------------------|
| < 1 week | 600 GB |
| < 1 month | 400 GB |
| > 1 month | 200 GB |

SOC-N100 at **4 GB × ~50 students = 200 GB for ~5.5 weeks** — exactly at the >1-month line, so approval is plausible but not automatic; the justification matters.

## 2. Outcome taxonomy (from the 60-issue corpus)

### Sailed through (≤2 comments, closed in days)

| Issue | Course | Ask | Days | Note |
|-------|--------|-----|------|------|
| [#7843](https://github.com/berkeley-dsep-infra/datahub/issues/7843) | **LEGALST 123** | **4 GB × 50** | 5 | **Our twin** — same RAM, same class size. "Changes were merged… log out and back in." |
| [#7833](https://github.com/berkeley-dsep-infra/datahub/issues/7833) | Econ 148 | 4 GB × 225 | 9 | Only friction: "input bCourses **ID**, not the URL" |
| [#8150](https://github.com/berkeley-dsep-infra/datahub/issues/8150) | PS 3 | 2 GB × 230 | 3 | **On r.datahub** — our hub |
| [#7521](https://github.com/berkeley-dsep-infra/datahub/issues/7521) | Data C100 | 6 GB × 1100 | 1 | Scale is not the blocker when justified |
| [#7554](https://github.com/berkeley-dsep-infra/datahub/issues/7554) | DEMOG-180 | 4 GB × 60 | 1 | |
| [#7305](https://github.com/berkeley-dsep-infra/datahub/issues/7305) | Data 6 | 2 GB × 40 | 1 | |
| [#6978](https://github.com/berkeley-dsep-infra/datahub/issues/6978) | Astro 128 | **8 GB × 23** | 4 | Approved because **date-bounded**: final lab only (CNN training), explicit 4/18–5/16 window |

### Successful but with back-and-forth

| Issue | Course | Friction | Lesson |
|-------|--------|----------|--------|
| [#6725](https://github.com/berkeley-dsep-infra/datahub/issues/6725) | Demog/Econ 175 | 7 comments | Missing bCourses ID — staff had to ask. **#1 delay cause across the corpus.** |
| [#7778](https://github.com/berkeley-dsep-infra/datahub/issues/7778) | ENVECON 153 | 14 comments, **101 days** | Filed Dec 28 over winter break; multiple verification rounds |
| [#7656](https://github.com/berkeley-dsep-infra/datahub/issues/7656) | CE103N | 9 comments, 12 days | Scope clarifications |
| [#5153](https://github.com/berkeley-dsep-infra/datahub/issues/5153) | Music 30 | "I'm not sure exactly" how much RAM | Vague asks trigger diagnostic rounds |
| [#7898](https://github.com/berkeley-dsep-infra/datahub/issues/7898) / [#7902](https://github.com/berkeley-dsep-infra/datahub/issues/7902) | Envecon 153 / Econ 148 | Staff filed **"(Corrected Issue)"** duplicates themselves | Malformed submissions get re-filed by staff — avoidable |

### Denied, redirected, or withdrawn

| Issue | Course | Ask | Outcome |
|-------|--------|-----|---------|
| [#6875](https://github.com/berkeley-dsep-infra/datahub/issues/6875) | PS231D | **16 GB** × 6 | Not granted. Staff stated the ceiling — "highest RAM allocated across all the instructional hubs is **8 GB for instructors and 12 GB for staff**" — and redirected to a shared directory + dataset splicing. Closed without a RAM grant. |
| [#8193](https://github.com/berkeley-dsep-infra/datahub/issues/8193) | Data 8 | 2 GB × 1400 | Self-withdrawn same day: "most of it runs just fine under current settings" |

### Constraints learned (the hard rules)

- **8 GB per-student ceiling** (12 GB staff) across all instructional hubs — a 16 GB ask is dead on arrival ([#6875](https://github.com/berkeley-dsep-infra/datahub/issues/6875)).
- **bCourses course must be Published** and given as the 7-digit **ID**, not a URL.
- **End date is mandatory**; semester cleanup deletes the config regardless.
- The RAM dropdown on the current template tops out at **8 GB**.
- When the driver is one large dataset, staff will counter-offer **shared directories** instead of RAM.
- Timing matters: requests filed over breaks ([#7778](https://github.com/berkeley-dsep-infra/datahub/issues/7778)) languish; term-time requests close in ≤1 week.
- Trivia: the **oldest still-open RAM issue** in the tracker is [#2231](https://github.com/berkeley-dsep-infra/datahub/issues/2231), filed by Aaron Culich in Feb 2021 for D-Lab.

## 3. What requests-that-succeed have in common

1. Filled template completely (hub, published bCourses ID, dates).
2. A **one-to-two-sentence concrete justification** naming the libraries or workload — e.g. ESPM-288's entire justification was "Required by the libraries we are using for spatial data."
3. RAM ask ≤ 4 GB for term-length requests, ≤ 8 GB only when date-bounded to a specific assignment.
4. Filed by (or clearly on behalf of) the instructor of record.

## 4. SOC-N100 measured in-class needs

Measured 2026-07-07 on maintainer laptop (macOS, R 4.4.2, `/usr/bin/time -l`, peak RSS per fresh `Rscript` running `website/maintainer/run_all_labs.R`):

| Run | Peak RSS | Status |
|-----|----------|--------|
| Lab 1 (intro, get_acs county) | 484 MB | OK |
| Lab 2 (ACS variables, income/race) | 770 MB | OK |
| Lab 3 (evictions, qs2 load, joins) | 726 MB | OK |
| Lab 4 (mapping: sf, tigris, tmap) | **874 MB** | OK |
| Lab 5 (rent burden, segregation, neighborhood) | 597 MB | OK |
| **All five labs, one R process** | **1,006 MB** | OK locally; **exceeds the 1 GB r.datahub pod limit** |

Interpretation:

- Every individual lab fits under 1 GB — **barely**. Lab 4 peaks within ~150 MB of the limit, before any student experimentation (extra objects, re-runs, `View()` copies, RStudio session overhead sharing the same pod).
- A student who works through more than one lab in a session — or re-runs chunks while keeping earlier objects — crosses 1 GB. This matches the observed DataHub failures (hung terminals, dead sessions mid–lab 4; documented in [`notes.qmd`](notes.qmd)).
- The eviction course dataset is small on disk (6.3 MB `.qs2`) but ~61 MB in memory; it is not the driver. The driver is the **geospatial stack**: `sf` geometries, `tigris` shapefile caches, tmap rendering copies, plus ~400–500 MB baseline for R + tidyverse + sf loaded.

## 5. Projected needs when students pivot to their own projects

The final group project asks students to apply lab patterns to places they care about. Hot spots we can anticipate (first row measured, rest inferred from it):

| Workload | Evidence | Tier |
|----------|----------|------|
| Single-state tract pull with geometry (CA, 9,129 tracts, 2 ACS variables, wide) | **Measured:** 13.5 MB sf object, 257 MB peak RSS in a bare process (with warm tigris cache) | Fits 1 GB alone |
| Same, stacked on a live lab session (packages + prior objects + tmap) | Lab 4 already peaks at 874 MB before this | **Crosses 1 GB** |
| Multiple states or multiple years held simultaneously for comparison (the natural final-project move) | Inferred: each additional state-year adds its own sf frame + join copies | 2–4 GB |
| Block-group geometries (CA has ~25k block groups vs 9k tracts) | Inferred ~3× tract object sizes plus heavier tigris downloads | 2–4 GB |
| Eviction data joined onto tract sf + choropleth iterations | dplyr joins and tmap each copy the frame | 2–4 GB |
| National-scale or raster work | — | Out of scope for the hub; redirect to sampling/subsetting |

**Bottom line:** guided labs are survivable at 1 GB one-at-a-time with zero headroom; realistic student project work lands in the **2–4 GB** tier. **4 GB per student** covers the term including final projects, sits within the corpus's normal approval range, and matches the LEGALST 123 precedent exactly (4 GB × 50).

## 6. ESPM-288 deep dive (the precedent course)

**Instructor:** Carl Boettiger ([cboettig](https://github.com/cboettig), UC Berkeley ESPM) — confirmed via GitHub; course site [espm-288.github.io mirror](mirrors/espm-288-website/) / [repo](https://github.com/espm-288/website). "Reproducible & Collaborative Data Science," Spring terms.

**Their requests:**
- [#6617](https://github.com/berkeley-dsep-infra/datahub/issues/6617) (Spring 2025): 4 GB × 24 + packages, on **nature.datahub** — a dedicated hub where staff replied "Nature Hub already provides 4 GB RAM for all users." Combined RAM+packages issue; staff prefer consolidated per-course threads but ask for fresh issues each semester.
- [#5914](https://github.com/berkeley-dsep-infra/datahub/issues/5914) (ESPM-157, Fall 2024): 4 GB × 120, closed in 7 days.
- [#5827](https://github.com/berkeley-dsep-infra/datahub/issues/5827) (ESPM-157 packages): **100 comments over 201 days** — the long-running per-course infrastructure thread pattern.

**Their stack (2026 site):** R ecosystem with `duckdbfs`, `tidyverse`, `mapgl`, `gdalcubes`, `ellmer`, `vitals`, `mcptools`, `ragnar`, `shiny`; explicitly **larger-than-RAM workflows** (parquet/geoparquet, cloud-optimized GeoTIFFs), VS Code + Copilot, docker/kubernetes deployment. 2025 request also listed `sf`, `stars`, `terra`, `rstac`, `minioclient` and code-server extensions.

**Comparison to SOC-N100:**

| | ESPM-288 | SOC-N100 |
|---|---|---|
| Spatial data model | Raster + vector, cloud-native (STAC, COG, geoparquet) | Vector only (tracts, counties) |
| Heavy libraries | terra, stars, gdalcubes, duckdb | sf, tigris, tmap, tidycensus |
| Data scale | Larger-than-RAM by design | ≤ state-level ACS + 6 MB course data |
| Hub | Dedicated nature.datahub (4 GB baseline) | Shared r.datahub (1 GB baseline) |
| RAM ask | 4 GB (granted / already baseline) | 4 GB (this request) |

**What transfers to our request:**
1. **4 GB is the established baseline for spatial teaching at Berkeley** — nature.datahub grants it to *all* users; ESPM-157 got it for 120 students on the main hub. We are asking for the same number for a lighter stack, which is an easy story.
2. Their one-line justification style ("required by the libraries we are using for spatial data") is what sailed; ours adds measured numbers on top.
3. Their consolidated per-course issue pattern (one thread per course per term) is what staff prefer — our RAM request should stay a single issue, with the package request kept separate per current template guidance.
4. What we should *not* copy: their dedicated-hub arrangement and cloud-native tooling are overkill for tract-level vector work. If SOC-N100 ever outgrows r.datahub, their duckdb/parquet larger-than-RAM patterns are the escape hatch to teach *before* asking for more RAM.

## 7. Recommendation

File the [Increase RAM Request](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=add_memory_config_request.yml) as drafted in [`datahub-resource-request-draft.md`](datahub-resource-request-draft.md):

- **4 GB × ~50 students on r.datahub**, end date 2026-08-20 (course ends Aug 13–14 + grading buffer)
- Justification: measured lab peaks (874 MB–1 GB), geospatial stack, final-project tier, LEGALST 123 + ESPM precedents
- Filed by Tim (instructor of record) or Aaron with Tim cc'd; bCourses **1555635** must be Published
- If staff push back on the 200 GB threshold: fallback offers are (a) 2 GB for the term + a date-bounded 4 GB window for the final-project weeks (Astro 128 pattern), or (b) bCourses project-group subset targeting
