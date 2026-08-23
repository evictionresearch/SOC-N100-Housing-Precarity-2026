# CLAUDE.md

If this repo has an `AGENTS.md`, read it before substantive work — it complements this file.

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Repo Is

Course materials for **SOC-N100: Housing Precarity and Displacement** (Racial and Gender Inequality in Gentrification and Eviction) — a UC Berkeley summer course taught by Tim Thomas. The course covers eviction, displacement, and gentrification using R/tidycensus data analysis.

## Website

The course website is built with **Quarto** and deployed to GitHub Pages from the `/docs` directory.

**To rebuild the site:**
Open `website/SOC-N100.Rproj` in RStudio, then render via Quarto. The output directory is set to `../docs` in `website/_quarto.yml`.

**Key website files:**
- `website/_quarto.yml` — site config, navbar structure, theme
- `website/index.qmd` — home page (weekly schedule, links, assignments)
- `website/syllabus.qmd` — full syllabus
- `website/resources.qmd` — supplementary resources
- `website/styles.css` — custom CSS (cosmo theme base)

**GitHub Pages setup:** Repo → Settings → Pages → Source: `/docs` branch `main`.

## R Lab Code

Lab scripts live in `code/`:
- `lab1_intro_to_.R` — intro to R
- `lab2_census_data.R` — tidycensus / ACS data
- `lab3_rent_burden.R` — census table literacy, the rent-burden measure & the core chart types (two-session lab)
- `lab4_evictions_mapping.R` — ERN eviction data, rates, and maps
- `lab5_rb_seg.R` — rent burden, segregation, outside data, and a migration brief (`get_flows()`)
- `lab6_hprm.R` — bonus self-study: reading the Housing Precarity Risk Model (short path §1–6, long path §7–10)
- `lab6_bonus_memory.R` — retired predecessor (memory constraints); superseded by `lab6_hprm.R`, kept pending Tim's call
- `r_functions_cheatsheet.R` — student reference card: every function in the labs, grouped by task (regenerate inventory with `website/maintainer/list_lab_functions.R`)

Labs use **tidyverse**, **tidycensus**, **ggplot2**, **sf**, and related packages. Students run these via Berkeley DataHub (not locally).

## Student Environment

Students access RStudio via Berkeley DataHub — **not** local installs. The primary hub is **r.datahub.berkeley.edu** (general R hub; RStudio default). The Stat20 hub is optional (higher RAM but bCourses-gated to Stat 20 enrollments unless SOC-N100 is allowlisted).

The DataHub link automatically git-pulls the repo and opens RStudio:
```
https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F
```

To regenerate hub links, use the [DataHub Link Generator Chrome extension](https://chromewebstore.google.com/detail/datahub-link-generator/ijbgangngghdanhcnaliiobbiffocahf) with the repo URL. See `DATAHUB.md` for full details on available hubs and their package sets.

## Course Structure (Summer 2025 Reference)

6-week summer course (July 8 – August 14), fully online via Zoom. Two 2-hour sessions/week:
- **Tuesdays** — lecture
- **Thursdays** — lab (coding in R)

Grading: 20% participation, 40% assignments (2 × 20%), 40% final group project.

AI policy: students may use any AI tool that can produce a **public shareable conversation link** (Perplexity is the recommended default; ChatGPT, Gemini, and Claude also qualify). They must submit those links inline (code comments + writeup footnotes). Free tiers suffice; students sign in with personal accounts, not CalNet, because Berkeley's enterprise Gemini/Copilot run in a data-protected mode that disables public sharing. (The 2024 free-Perplexity-Pro-for-Berkeley promo ended Dec 2024; free-tier sharing still works.)

## Updating for a New Term

When updating `website/index.qmd` for a new semester:
- Update the dates/times at the top
- Update/replace Zoom link and bCourses link
- Add new weekly entries (keep old weeks for reference or archive them)
- Assignment due dates and group project prompts are in `index.qmd` and `syllabus.qmd`
- The syllabus structure is stable; typically only the term date and instructor contact info change in `syllabus.qmd`

<!-- BEGIN hprm-lineage (synced from evictionresearch/library/standards/claude-md-hprm-lineage.md — edit there, then run library/scripts/sync_claude_md_standard.py) -->
## HPRM lineage

When introducing the HPRM in any prose: decades of scholarship on displacement,
gentrification, segregation, urban planning, and demography, operationalized with
modern Bayesian tools (BART); developed by Tim Thomas and collaborators at UC
Berkeley's Urban Displacement Project during the pandemic, carried forward by ERN.
Public theory families (four only): place stratification and discrimination,
economic/affordability, household preference, and network theories of neighborhood
change. "Highways of migration" and ranking superlatives stay internal. Canonical
narrative: `cidrlab/library/ORG.md → HPRM Lineage`.
<!-- END hprm-lineage -->

<!-- BEGIN eviction-measurement (synced from evictionresearch/library/standards/claude-md-eviction-measurement.md — edit there, then run library/scripts/sync_claude_md_standard.py) -->
## What an eviction filing count does and does not measure

Court records are what the ERN mostly holds, and a filing count is the weakest
of the numbers we publish. Every rate built on one undercounts displacement,
by a factor that varies by place. State it on any page that reports filing
rates, and never let a low filing rate be read as housing security.

**Most forced moves never reach a court.** The 2017 American Housing Survey
puts the national ratio at **5.5 informal evictions for every formal one**.
Informal evictions were 72.3% of forced moves and formal evictions 13.1%; the
rest were fear of eviction after a missed payment (6.4%), landlord foreclosure
(5.0%), and condemnation (3.2%). The AHS national formal eviction rate of 0.8%
runs 65% below the 2.3% produced from court records.
— Gromis & Desmond (2021), *Estimating the Prevalence of Eviction in the
United States: New Data from the 2017 American Housing Survey*, Cityscape
23(2), pp. 279–290.
<https://www.huduser.gov/portal/periodicals/cityscpe/vol23num2/ch15.pdf>

**The ratio is not a constant, and that is the useful part.** Milwaukee ran at
2:1 informal-to-formal; the New York City/Newark MSA at 2.5:1 by one measure,
while a second NYC source found formal evictions almost twice as common as
informal. Gromis and Desmond attribute the reversal to "New York City's
uniquely robust tenant protections, which incentivize tenants threatened with
eviction to defend their case in court." **Where tenants have counsel and
protections, more displacement passes through the court and the filing count
measures more of it. Where they do not, the count measures less.** A
cross-place comparison of filing rates is therefore partly a comparison of
tenant-protection regimes, not only of housing precarity.

**The Milwaukee survey figures**, for the version that counts moves rather
than cases: 48% of forced moves were informal evictions, 24% formal, 23%
landlord foreclosure, 5% condemnation. Its authors concluded that estimates
built on eviction court records "are considerable underestimates."
— Desmond (2015), *Unaffordable America: Poverty, housing, and eviction*, IRP
Fast Focus 22-2015, p. 3.
<https://www.irp.wisc.edu/publications/fastfocus/pdfs/FF22-2015.pdf>

**Who this undercount falls on.** Renters without a written lease, and renters
for whom the courts carry immigration risk, are least likely to appear in a
court record at all. That is why Latine filing rates commonly read at or below
white rates in court data while displacement runs the other way. The full
treatment, with verified quotations and the countervailing evidence that some
of the gap is protective rather than hidden, is in
`library/standards/latine-filing-rates-note.md`. Read it before writing any
profile section that reports rates by race.

**How to write it.** Filings, judgments, notices, and lockouts are separate
stages and are not interchangeable. A rate per 1,000 renter households counts
filings and not households, so a unit filed on repeatedly counts each time.
Say what the number counts, say what it misses, and give the reader the ratio
rather than leaving the undercount implicit.
<!-- END eviction-measurement -->

<!-- BEGIN factual-accuracy (synced from evictionresearch/library/standards/claude-md-factual-accuracy.md — edit there, then run library/scripts/sync_claude_md_standard.py) -->
## Factual accuracy — non-negotiable

Everything must be factually true. This overrides helpfulness, completeness, and the urge to sound finished.

- **Never fabricate** — no invented numbers, citations, file paths, function names, API behaviors, or results. If you don't know, say so.
- **Verify before asserting** — ground every factual claim in something checked this session (a file read, a command run, a source fetched). Don't assert from memory when the answer is checkable.
- **Label thought exercises** — open any speculation or hypothetical with an explicit **[Thought exercise]** marker so it's never mistaken for fact.
- **Mark confidence when it matters** — for consequential claims you couldn't fully verify, flag the uncertainty and how to confirm it. Distinguish *verified* (checked) from *inferred* (reasoned) from *assumed* (unchecked).
- **Build only on solid ground** — analysis must rest on prior facts or analysis already established correct; flag unverified dependencies before building on them.
- **Report outcomes honestly** — failures, skipped steps, and partial results get stated plainly with evidence. Never round a partial result up to "done."
<!-- END factual-accuracy -->
