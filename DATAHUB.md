# Course Datahubs

**Primary hub for SOC-N100:** use the [General R datahub](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F) (`r.datahub.berkeley.edu`). It launches RStudio by default and is open to Berkeley students in the `datahub-r-users` Grouper group.

**Optional (higher RAM, restricted access):** the [Stat20 datahub](https://stat20.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F) has 1GB guarantee / 2GB limit but is **limited to Stat 20 bCourses enrollments** unless CDSS adds SOC-N100 to the allowlist.

- [R datahub + clone repo link (primary)](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F)
- [Stat20 datahub + clone repo link (optional)](https://stat20.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F)

Note: Your file changes DO NOT automatically sync between different datahubs! If you start on one datahub, but then switch to another, they are separate systems and cannot see files from the other.

Student work under `~/` persists between sessions on each hub (NFS-backed home directory).

## **RStudio-Enabled Deployments and Package Sets**

### **1. R Deployment** (Primary for SOC-N100)
- **URL**: [r.datahub.berkeley.edu](https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F)
- **Memory**: `guarantee: 512M, limit: 1G` (512MB guarantee, 1GB limit)
- **RStudio**: Available (`defaultUrl: "/rstudio"`)
- **Image**: Default datahub image with R support
- **Config**: [berkeley-dsep-infra/datahub/deployments/r](https://github.com/berkeley-dsep-infra/datahub/tree/staging/deployments/r)
- **Package manifest**: [datahub-user-image/install-r-packages.r](https://github.com/berkeley-dsep-infra/datahub-user-image/blob/main/install-r-packages.r)

**Key R Packages Available:**
- **Core Data Science**: `tidyverse@2.0.0`, `dplyr@1.1.4`, `ggplot2@3.5.1`
- **Statistics**: `broom@1.0.7`, `stats@4.5.0`, `lmtest@0.9-40`, `sandwich@3.1-1`
- **Economics**: `AER@1.2-14`, `estimatr@1.0.4`, `wooldridge@1.4-3`, `stargazer@5.2.3`
- **Geospatial**: `leaflet@2.2.2`, `sf`, `stars@0.6-7`, `tmap@3.3-4`
- **Databases**: `DBI@1.2.3`, `RSQLite@2.3.9`, `RPostgres@1.4.7`
- **Machine Learning**: `scikit-learn` (via reticulate), `e1071@1.7-16`
- **Interactive**: `plotly@4.10.4`, `DT@0.33`, `shiny@1.4.0`
- **Data Sources**: `nycflights13@1.0.2`, `Lahman@12.0-0`, `ipumsr@0.8.1`

**SOC-N100 packages requested for image (may require session `install.packages()` until CDSS merges):**
`tidycensus`, `tigris`, `janitor`, `qs`, `librarian`, `evictionresearch/neighborhood`

### **2. STAT20 Deployment** (Optional — bCourses-gated)
- **URL**: [stat20.datahub.berkeley.edu](https://stat20.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F)
- **Memory**: `guarantee: 1024M, limit: 2048M` (1GB guarantee, 2GB limit)
- **RStudio**: Available (`defaultUrl: /rstudio`)
- **Image**: `rocker/geospatial:4.5.0` + custom packages
- **Config**: [berkeley-dsep-infra/datahub/deployments/stat20](https://github.com/berkeley-dsep-infra/datahub/tree/staging/deployments/stat20)
- **Package manifest**: [stat20-user-image/install.r](https://github.com/berkeley-dsep-infra/stat20-user-image/blob/main/install.r)
- **Access**: Stat 20 bCourses enrollments only unless SOC-N100 course ID is added to allowlist

**Key R Packages Available:**
- **Core Statistics**: `infer@1.0.8`, `openintro@2.5.0`, `palmerpenguins@0.1.1`
- **Data Visualization**: `ggplot2`, `ggrepel@0.9.6`, `ggthemes@5.1.0`, `patchwork@1.3.0`
- **Data Manipulation**: `tidyverse`, `janitor@2.2.1`, `reshape2@1.4.4`, `tidycensus@1.7.1`, `tigris@2.2.1`
- **Reporting**: `gt@0.11.1`, `kableExtra@1.4.0`, `quarto@1.4.4`, `pagedown@0.22`
- **Interactive**: `plotly@4.10.4`, `countdown@0.4.0`
- **Datasets**: `fivethirtyeight@0.6.2`, `gapminder@1.0.0`, `unvotes@0.3.0`
- **Special**: `swirl@2.4.5` (interactive R tutorials)
- **Custom**: Course-specific packages from GitHub (`stat20/stat20data`, `andrewpbray/boxofdata`)


## **Common Packages Across All RStudio Deployments**

### **Core Data Science Stack:**
- `tidyverse` (dplyr, ggplot2, tidyr, readr, purrr)
- `ggplot2` for visualization
- `dplyr` for data manipulation
- `readr` for data import
- `purrr` for functional programming

### **Statistics & Modeling:**
- `stats` (base R statistics)
- `broom` for model tidying
- `lmtest` for linear model tests
- `sandwich` for robust standard errors

### **Interactive & Reporting:**
- `plotly` for interactive plots
- `DT` for interactive tables
- `shiny` for web applications
- `quarto` for document generation

### **Python Integration:**
- `reticulate` for Python integration
- Access to Python packages like `pandas`, `numpy`, `scikit-learn`

## Datahub Link Generator
To generate the links to the datahubs above, here are the instructions to follow:

1. Use the Chrome extension [DataHub Link Generator](https://chromewebstore.google.com/detail/datahub-link-generator/ijbgangngghdanhcnaliiobbiffocahf?hl=en)
2. Navigate to the course repo: https://github.com/evictionresearch/SOC-N100-Housing-Precarity-2026/
3. Click the Link Generator extension (orange bear icon in Chrome that you just installed)
4. Enter one of these as the **JupyterHub URL**:
   - `https://r.datahub.berkeley.edu` (primary)
   - `https://stat20.datahub.berkeley.edu` (optional)
5. Click **Copy nbgitpuller link**
- R datahub + clone repo link: https://r.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F
- Stat20 datahub + clone repo link: https://stat20.datahub.berkeley.edu/hub/user-redirect/git-pull?repo=https%3A%2F%2Fgithub.com%2Fevictionresearch%2FSOC-N100-Housing-Precarity-2026&urlpath=rstudio%2F

See the [CDSS datahub link generator instructions](https://cdss.berkeley.edu/dsus/data-science-resources/datahub/setup) for more information.

## Requesting package or hub updates (CDSS)

To add packages for all students on r.datahub, open an issue on [berkeley-dsep-infra/datahub](https://github.com/berkeley-dsep-infra/datahub/issues) or email **balajialwar@berkeley.edu**. For r.datahub, propose changes to [datahub-user-image/install-r-packages.r](https://github.com/berkeley-dsep-infra/datahub-user-image/blob/main/install-r-packages.r) per [CONTRIBUTING.md](https://github.com/berkeley-dsep-infra/datahub-user-image/blob/main/CONTRIBUTING.md).

**Draft issue for Tim to file:**

> **Title:** SOC-N100 Summer 2026: request r.datahub packages (tidycensus, janitor, qs, librarian, sf, evictionresearch/neighborhood)
>
> **Course:** SOC-N100 Housing Precarity and Displacement, Summer 2026 (~50 seats)
> **Hub:** r.datahub.berkeley.edu (primary)
> **Repo:** https://github.com/evictionresearch/SOC-N100-Housing-Precarity-2026
>
> Please add to `datahub-user-image`: `tidycensus`, `tigris`, `janitor`, `qs`, `librarian`, `sf`, and GitHub package `evictionresearch/neighborhood`.
>
> Optional: add SOC-N100 bCourses course ID to stat20.datahub allowlist for higher-RAM fallback.

## Manual test checklist (before publishing links to students)

Run on **r.datahub** with a Berkeley CalNet account after the repo is pushable and cloneable:

1. [ ] Open primary git-pull link → RStudio launches
2. [ ] Repo clones to `~/SOC-N100-Housing-Precarity-2026`
3. [ ] Lab 1 runs through tidyverse section
4. [ ] Lab 2: `tidycensus` loads; census API key works
5. [ ] Lab 3: `data/evictions/d5_case_aggregated.qs` reads successfully
6. [ ] Labs 4–5: geospatial packages and `evictionresearch/neighborhood` load
7. [ ] Save a file under `~/` and confirm it persists after stopping and restarting the server

Record results and any package gaps in this file after testing.
