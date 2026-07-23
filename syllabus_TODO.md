# Course Site Prep - TODO (Summer 2026)

Status of updating the SOC-N100 course website for Summer 2026.
Amended 2026-06-29 after a full-site review (all tabs).

## DONE (this pass)
- [x] Syllabus term -> Summer 2026 (front matter `published`, and title is now "Sociology N100 Syllabus, Summer 2026"). NOTE: the `published`/"Term" field does not render in this theme, so the year lives in the title.
- [x] AI policy rewritten: approved-menu (Perplexity / ChatGPT / Gemini / Claude). Hard rule = submit a public shareable conversation link the instructor can open without logging in. Added personal-account + incognito-test guidance and a "Free AI access through Berkeley" note.
- [x] Syllabus downloadable as PDF (`format: pdf` added; "Other Formats -> PDF" link appears on the page; `docs/syllabus.pdf`).
- [x] Late-work policy reconciled: syllabus now matches index (no late work except documented DSP accommodations / prior arrangements).
- [x] Syllabus logistics block + Course Schedule table added (2026 dates + topics; flows into the PDF).
- [x] Home page rebuilt for 2026: header now Tu/Th 5-7pm, July 7 to Aug 13, Session D, Online, Class #13195; all weekly dates corrected; setup (census key + AI account) listed under Week 1 (no Week 0; first lab is the live RStudio walkthrough); AI discussion placed in Wk1 Tue, AI tutorial in Wk1 Thu; 2025 Zoom recordings + old Slides links stripped; Assignment 1 due Mon Aug 3 @5pm; final due Fri Aug 14.
- [x] Resources tab: fixed broken "The Color of Law" link (was empty); bumped HUD FMR to FY2026.
- [x] Merged `lab0_setup.R` into `lab1`: the RStudio-on-DataHub walkthrough + one-time Census API key setup now open Lab 1 (new Section 0). Removed `lab0_setup.R`. No more Week 0.
- [x] Reworked assignments into a building ladder (both 20%, grading unchanged): NEW simple Assignment 1 (solo `get_acs` + one chart, due Mon Jul 27); the old involved assignment is now Assignment 2 (same area, deeper, ends with a draft research question + 2 hypotheses, due Mon Aug 3) and seeds the final. Updated home page + syllabus schedule.
- [x] Final project framed as public scholarship: syllabus abstract now names the goal of using data + sociology/theory to help a policymaker or stakeholder understand a trend and inform legislation; final-project description adds "choose (or be assigned)" and bonus points for a strong set of policy recommendations.
- [x] GitHub Pages is LIVE at https://evictionresearch.net/SOC-N100-Housing-Precarity-2026/. Fixed the deploy (Pages source was pointed at the repo root, so Jekyll choked on the .qmd/.R files; repointed it at `/docs` and added the missing `.nojekyll`). Added a Course Site link to the syllabus logistics block.

## NEEDS YOUR INPUT / ACTION (I cannot do these)
- [x] **DATAHUB CLONE LINKS.** Resolved; verified 2026-07-07. All student-facing links (`_quarto.yml` navbar + tools + repo-url, `syllabus.qmd`, `DATAHUB.md`) point to the public `SOC-N100-Housing-Precarity-2026` repo via **r.datahub**; grep found zero remaining year-less or `-2025` references. Live site serves the correct navbar link, and an anonymous HTTPS clone (what nbgitpuller runs) succeeds with all `data/` files present. STILL OPEN: Tim click-tests the DataHub link with a CalNet login (only doable from a Berkeley account).
- [x] All 2026 term links in place: Class Zoom (standard join link `https://berkeley.zoom.us/j/92041866237`; Tim posts join instructions on bCourses), bCourses (course 1555635), Discussion. Home header + syllabus logistics block.
- [ ] Official listing confirmed (no action, just FYI): Tu/Th 5-7pm, Summer Session D, first class Tue Jul 7, last class Thu Aug 13, Class #13195, 2 units, Online. https://classes.berkeley.edu/content/2026-summer-sociol-n100-002-lec-002

## REMAINING CLEANUP (optional)
- [ ] Strip the commented-out Stat 20 boilerplate in `syllabus.qmd` (mode of instruction, plenary, tutoring, quizzes, exam, collaboration policy, FAQ, campus comms). Invisible in the render; housekeeping only. I deferred this to avoid a large risky deletion - say the word and I'll do it.
- [ ] Add per-lecture Slides links and class recordings to the home page week-by-week as the term runs.
- [ ] `learn_r.qmd` is only reachable from the Resources tab (not in the navbar). Add it to the navbar if you want it discoverable.

## DATAHUB RAM (opened 2026-07-07, from Tim's "Ram upgrade" email)
- [x] Repo-local git identity set to `Aaron Culich <aculich@berkeley.edu>` (2026-07-08; global config untouched) so commits/issues match `@aculich`'s Berkeley identity
- [ ] Aaron reviews + sends reply to Tim: `website/maintainer/tim-ram-email-draft.md` (reframes 16 GB laptop-ask to 4 GB hub request) — optional now that grant landed
- [x] Filed + **granted**: [berkeley-dsep-infra/datahub#8335](https://github.com/berkeley-dsep-infra/datahub/issues/8335) → PR [#8336](https://github.com/berkeley-dsep-infra/datahub/pull/8336) deployed to prod 2026-07-13 (issue closed 2026-07-17). Students **4G**; Teacher/TA **8G** via `enrollment_type` — no custom staff group.
- [x] ~~Create instructional-staff bCourses group~~ — superseded by enrollment_type keys (see `bcourses-staff-group-primer.md`)
- [ ] Confirm Aaron’s bCourses 1555635 role is **Teacher or TA** (required for 8G tier)
- [ ] After login: verify 4 GB (student) / 8 GB (Teacher/TA) in RStudio Environment tab on r.datahub

## DATAHUB PACKAGES (lower priority — after RAM resolves)
- [ ] Run the verify-on-hub check from `website/maintainer/datahub-package-request-draft.md` on r.datahub; prune the package list to what's actually missing (incl. `duckdb`/`duckdbfs`/`arrow` for the Week 5 bonus lab `code/lab6_bonus_memory.R`)
- [ ] File the package issue (template: package_request.yml); record issue URL in the draft and here

## SEND
- [x] Render/push verified live 2026-07-07: index + syllabus HTML match the latest sources (new abstract present), `syllabus.pdf` serves HTTP 200, `maintainer-notes.html` correctly 404s. Still open: the CalNet click-test of the DataHub link (above).
- [ ] Export syllabus to PDF -> send to Sociology (or send the published URL: https://evictionresearch.net/SOC-N100-Housing-Precarity-2026/syllabus.pdf).
