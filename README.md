# Housing Precarity and Displacement

**Racial and Gender Inequality in Gentrification and Eviction**
UC Berkeley · Sociology N100 · Summer 2026 · Tim Thomas, Ph.D.

Welcome! This repository holds everything you need for the hands-on side of the course: the R lab scripts we work through together, the datasets they use, and the RStudio project that ties them together.

## Course website

Start at the course site — it has the schedule, syllabus, readings, and assignment details:

**<https://evictionresearch.net/SOC-N100-Housing-Precarity-2026/>**

## Launch RStudio (one click)

You do not need to install anything on your computer. Click the badge below and Berkeley DataHub will open RStudio in your browser with this repository already cloned and kept up to date (sign in with your CalNet ID):

[![Launch on Berkeley DataHub](https://img.shields.io/badge/Launch-Berkeley%20DataHub-003262?logo=jupyter&logoColor=FDB515)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F)

Once RStudio opens:

1. In the **Files** pane, open the `SOC-N100-Housing-Precarity-2026` folder and click **`SOC-N100.Rproj`** (say yes when RStudio asks to open the project).
2. Open the lab of the week from the **`code/`** folder (for example `code/lab1_intro_to_.R`).
3. Run the script top to bottom, reading the comments as you go — the labs are written to be read, not just executed.

If anything looks stuck or confusing, see [`DATAHUB.md`](DATAHUB.md) for setup help, or ask in class — getting unstuck quickly is part of the course.

## What's in here for you

| Where | What |
|-------|------|
| [`SOC-N100.Rproj`](SOC-N100.Rproj) | The RStudio project — always open this first |
| [`code/`](code/) | Weekly lab scripts (`lab1` … `lab5`, plus a bonus lab on working with big data under memory limits) |
| [`data/`](data/) | Course datasets (eviction filings and more) |
| [`DATAHUB.md`](DATAHUB.md) | DataHub how-to: first-time setup, package installs, troubleshooting |
| [`code/README.md`](code/README.md) | How package installs work in the labs |

A few tips for success:

- **Run labs on DataHub**, not a local install — everyone in class is then on the same setup, and help is easier to give.
- **Labs build on each other.** Lab 1 sets up your (free) Census API key that every later lab uses.
- **Save your own work under new file names** — the git-pull link updates course files, and edits to the originals can create conflicts.
- The final project pulls together everything from the labs; the bonus lab (`code/lab6_hprm.R`) has you read a real risk model, the Housing Precarity Risk Model, instead of building one.

## Course staff and maintainers

Everything about editing the course website, batch-testing labs, and DataHub resource requests lives in [`website/readme.md`](website/readme.md) — students never need it.
