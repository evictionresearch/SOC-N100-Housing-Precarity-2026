# CLAUDE.md

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
- `lab3_evictions.R` — eviction data analysis
- `lab4_li_renters_mapping.R` — low-income renter mapping
- `lab5_rb_seg.R` — rent burden and segregation

Labs use **tidyverse**, **tidycensus**, **ggplot2**, **sf**, and related packages. Students run these via Berkeley DataHub (not locally).

## Student Environment

Students access RStudio via Berkeley DataHub — **not** local installs. The primary hub is **r.datahub.berkeley.edu** (general R hub; RStudio default). Stat20 hub is optional (higher RAM but bCourses-gated to Stat 20 unless SOC-N100 is allowlisted).

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

AI policy: students must use **Perplexity.ai only** and provide URLs to all AI usage inline in code and writeups.

## Updating for a New Term

When updating `website/index.qmd` for a new semester:
- Update the dates/times at the top
- Update/replace Zoom link and bCourses link
- Add new weekly entries (keep old weeks for reference or archive them)
- Assignment due dates and group project prompts are in `index.qmd` and `syllabus.qmd`
- The syllabus structure is stable; typically only the term date and instructor contact info change in `syllabus.qmd`
