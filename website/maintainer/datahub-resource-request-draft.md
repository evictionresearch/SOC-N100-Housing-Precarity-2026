# DRAFT — not submitted. RAM request for SOC-N100 on r.datahub

**Status:** DRAFT pending review by Tim Thomas and Aaron Culich. Do not file until both approve.

**Where to file:** [Increase RAM Request template](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=add_memory_config_request.yml) on berkeley-dsep-infra/datahub. The template is a form — paste each answer below into the matching field. Background and evidence: [`REQUESTS.md`](REQUESTS.md); process: [`datahub-official-guide.md`](datahub-official-guide.md).

## How to submit (checklist)

- [ ] Tim confirms enrollment count (~50 assumed below)
- [ ] Verify bCourses course **1555635** is set to **Published** (required for the hub to assign privileges)
- [ ] Tim approves this draft (or files it himself as instructor of record)
- [ ] Open the [template](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=add_memory_config_request.yml), paste field answers below
- [ ] Do not assign anyone; labels (`support`, `add memory config`) apply automatically
- [ ] After staff merge: log out of r.datahub, log back in, verify with RStudio Environment tab
- [ ] Note the issue URL in `REQUESTS.md` and `syllabus_TODO.md`

---

## Form field answers

**Title:** `Request more RAM for class SOC-N100 (Summer 2026)`

**Hub URL:** `r.datahub.berkeley.edu`

**Affiliated Course Name:**
`2026 Summer, SOCIOL N100 002 — Housing Precarity and Displacement: Racial and Gender Inequality in Gentrification and Eviction`

**Academic Guide URL:**
`https://classes.berkeley.edu/content/2026-summer-sociol-n100-002-lec-002`

**bCourses ID(s):** `1555635`

**How many students do you expect in this class?** `~50`

**How much RAM per user is needed?** `4 GB`

**Why does this class need this much RAM?**

> This is an R/RStudio course teaching Census and eviction data analysis with a geospatial stack (tidycensus, tigris, sf, tmap). We profiled the course labs with `/usr/bin/time`: individual labs peak at 484–874 MB RSS, and a session covering more than one lab peaks at ~1.0 GB — at or over the current 1 GB pod limit before any student experimentation. Students have already hit dead sessions and hung terminals on r.datahub during the mapping lab. The final group project has students pull tract-level ACS data with geometry for states they choose and join it against eviction data — multi-state/multi-year sf workloads that land in the 2–4 GB range. 4 GB matches what comparable courses run with (LEGALST 123, 4 GB × 50, [#7843](https://github.com/berkeley-dsep-infra/datahub/issues/7843); ESPM spatial courses at 4 GB, [#6617](https://github.com/berkeley-dsep-infra/datahub/issues/6617), [#5914](https://github.com/berkeley-dsep-infra/datahub/issues/5914)).
>
> Course repo (public): https://github.com/evictionresearch/SOC-N100-Housing-Precarity-2026 — lab memory profile documented in `website/maintainer/REQUESTS.md`.

**By what date (MM/DD/YYYY) do you want this request to be fulfilled?**
`07/09/2026` (first lab session; course is already running)

**End Date:** `08/20/2026` (last class Aug 13; buffer for final project grading)

**Any additional information we should know about?**

> Instructor of record: Tim Thomas (timthomas@berkeley.edu, Sociology). Technical contact: Aaron Culich (aculich@berkeley.edu), Data Science Director, Eviction Research Network.
>
> The instructor's original request to course staff is forwarded below for context. He initially asked for 16 GB in a personal-laptop frame of reference; after profiling the labs (numbers above) we are requesting 4 GB, which covers measured lab peaks plus final-project headroom within the documented instructional ceiling.
>
> ---------- Forwarded message ---------
> From: Tim Thomas \<timthomas@berkeley.edu\>
> Date: Tue, Jul 7, 2026 at 12:32 PM
> Subject: Ram upgrade
> To: Aaron Culich \<aculich@berkeley.edu\>
>
> Hi Aaron,
>
> For the course I'm teaching SOC N100 - Housing Precarity and Displacement in the Sociology Department, can you bump my RStudio memory to about 16gb of Ram per user? My first lab is Thursday but the class runs from July 7 through August 14.
>
> Thanks so much!
> Tim
> \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_
>
> Tim Thomas, PhD
> Director Eviction Research Network \<https://evictionresearch.net/\>
> Professional Researcher
> Department of Sociology
> University of California, Berkeley
> Schedule a meeting \<https://cal.com/timthomas\>
> \_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_\_

---

## Fallback positions (if staff push back)

Our ask (4 GB × 50 × ~6 weeks = 200 GB aggregate) sits exactly at the >1-month auto-approval threshold. If staff hesitate:

1. **Split-duration:** 2 GB for the full term + a date-bounded bump to 4 GB for the final-project window (Weeks 4–6, ~07/28–08/20) — the [Astro 128 pattern](https://github.com/berkeley-dsep-infra/datahub/issues/6978).
2. **Subset targeting:** 4 GB for a bCourses project-group subset during finals only.
3. **Shared directory** for the eviction dataset if staff raise data duplication (though our data is only ~6 MB — the driver is the geospatial stack, not the dataset).

## Optional companion request (separate issue, lower priority)

stat20.datahub allowlist addition for SOC-N100 bCourses 1555635 as a 2 GB fallback hub — only worth filing if the r.datahub RAM request stalls.
