# UC Berkeley DataHub: how to request resources and manage our hub footprint

**Audience:** SOC-N100 course staff / maintainers. Derived from official sources only (linked throughout); local mirrors in [`mirrors/`](mirrors/). Request-history analysis and our measured needs: [`REQUESTS.md`](REQUESTS.md). Student setup: [`../../DATAHUB.md`](../../DATAHUB.md).

Verified against sources: **2026-07-07**.

---

## 1. What "DataHub" is here

UC Berkeley DataHub is the campus **JupyterHub** service run by CDSS (Computing, Data Science, and Society), serving Jupyter and **RStudio** to courses. Infrastructure is public at [berkeley-dsep-infra/datahub](https://github.com/berkeley-dsep-infra/datahub); operator docs at [docs.datahub.berkeley.edu](https://docs.datahub.berkeley.edu/); instructor policy at the [Data Science Curriculum Guide](https://curriculum-guide.datahub.berkeley.edu/). (Not to be confused with the unrelated commercial "DataHub" metadata platform.)

## 2. Hubs relevant to SOC-N100

| Hub | Memory (guarantee / limit) | Access | Notes |
|-----|---------------------------|--------|-------|
| [r.datahub.berkeley.edu](https://r.datahub.berkeley.edu) — **primary** | 512 MB / **1 GB** | `datahub-r-users` Grouper group (open to Berkeley students) | RStudio by default; same image as main datahub ([hub docs](https://docs.datahub.berkeley.edu/hubs/r.html)) |
| [stat20.datahub.berkeley.edu](https://stat20.datahub.berkeley.edu) — optional fallback | 1 GB / 2 GB | **bCourses-gated** to Stat 20 enrollments unless SOC-N100 is allowlisted | rocker/geospatial image |

Source of truth for limits: [`deployments/r/config/common.yaml`](https://github.com/berkeley-dsep-infra/datahub/blob/staging/deployments/r/config/common.yaml) and [`deployments/stat20/config/common.yaml`](https://github.com/berkeley-dsep-infra/datahub/blob/staging/deployments/stat20/config/common.yaml) (mirrored in `mirrors/datahub/`). Per-course RAM overrides appear in the same files as `custom.group_profiles` stanzas keyed by bCourses group (e.g. `course::1548266` for Stat 20) — that is exactly what a granted RAM request adds.

## 3. The memory model (why the laptop frame misleads)

- Each student gets a Kubernetes **pod** with a memory *guarantee* (reserved on the node) and *limit* (hard cap; the kernel/rsession is killed above it).
- The pod runs **only the R session** — no OS, browser, or Zoom competing for it, so hub RAM goes further than the same number on a laptop.
- Pods from many students are packed onto shared nodes. Raising limits reduces students-per-node — that is the cost driver, and why requests are evaluated as **students × RAM × duration**.
- `free -h` inside a session shows the **node's** memory (tens of GB), not your pod quota. RStudio's Environment tab shows actual session consumption ([curriculum guide](https://curriculum-guide.datahub.berkeley.edu/support/memory-cpu/)).
- Both RStudio and any Terminal/Jupyter processes share the **same pod budget** — a batch run in the RStudio Terminal competes with the IDE itself.

## 4. Requesting more RAM (official process)

Policy page: [Memory and CPU Requirements](https://curriculum-guide.datahub.berkeley.edu/support/memory-cpu/). CDSS "recommend[s] instructors to adapt the materials to the 1GB requirement" and asks for compelling rationale otherwise.

1. File the [**Increase RAM Request** template](https://github.com/berkeley-dsep-infra/datahub/issues/new?template=add_memory_config_request.yml) on berkeley-dsep-infra/datahub.
2. Required fields: hub URL, course name, **Academic Guide URL**, **bCourses ID** (7-digit, course must be **Published**), student count, RAM (dropdown, **1–8 GB**), justification, fulfillment date, **end date**.
3. Auto-approval thresholds on students × RAM: 600 GB (<1 week), 400 GB (<1 month), **200 GB (>1 month)**. Above threshold → manual review.
4. You can request for **all students or a bCourses-group subset** (useful for a single heavy assignment).
5. CPU requests always get manual review.

See [`REQUESTS.md`](REQUESTS.md) for what actually happens in practice (approval patterns, the 8 GB ceiling, common friction) and our filled-in draft: [`datahub-resource-request-draft.md`](datahub-resource-request-draft.md).

## 5. Requesting packages and other changes

Separate templates on the [issue tracker](https://github.com/berkeley-dsep-infra/datahub/issues/new/choose):

| Template | Use for |
|----------|---------|
| `package_request.yml` | Adding R/Python packages to a hub image |
| `add_memory_config_request.yml` / `remove_memory_config_request.yml` | RAM up / down |
| `add_admin_config_request.yml` | Instructor/TA elevated privileges (view student servers) |
| `add_shared_directories_request.yml` | Shared read-only data directories (the staff counter-offer when RAM requests are dataset-driven) |
| `resourcescheduler.yml` | Scheduled scaling for exams/deadlines |

For r.datahub image packages, PRs go to [datahub-user-image](https://github.com/berkeley-dsep-infra/datahub-user-image) (`install-r-packages.r`, `environment.yml`) per its CONTRIBUTING.md. Keep **RAM and package requests as separate issues** (staff re-filed corrected issues when combined ones got messy; ESPM's combined issue worked only because they had an established relationship).

## 6. Semester lifecycle

Per [semester start/end tasks](https://docs.datahub.berkeley.edu/tasks/semester-start-end-tasks.html), staff **remove RAM configs, elevated privileges, and shared directories at term end**. Practical consequences:

- Set the end date honestly (course end + grading buffer); don't ask for "indefinitely".
- Expect to **re-file every term** — precedent from a prior term speeds approval but does not carry the config over.
- Package additions to the image can also be dropped at image upgrades; re-request each term ([ESPM #6617 closing comment](https://github.com/berkeley-dsep-infra/datahub/issues/6617)).

## 7. Contacts and escalation

| Channel | Use |
|---------|-----|
| [GitHub issues](https://github.com/berkeley-dsep-infra/datahub/issues) | All formal requests (RAM, packages, admin, shared dirs) |
| balajialwar@berkeley.edu (Balaji Alwar, service lead) | Setup help, repo onboarding ([CDSS DataHub setup](https://cdss.berkeley.edu/dsus/data-science-resources/datahub/setup)) |
| UC Tech Slack `#ucb-datahubs` | Quick questions for Berkeley staff |

## 8. Managing within the allocation (what we already do)

Course-side mitigations in this repo, independent of any grant:

- **`--per-lab` batch mode** ([`run_all_labs.R`](run_all_labs.R)): fresh R process per lab so memory is released between labs — required on 1 GB pods.
- **qs2 + RDS course data** (~6 MB on disk, ~61 MB in memory) instead of larger raw extracts ([`notes.qmd`](notes.qmd)).
- `tigris_use_cache` and restart-R habits documented for students in labs.
- If a project outgrows 4 GB: teach subsetting/sampling, or larger-than-RAM patterns (duckdb/parquet) as ESPM-288 does — before asking for more hardware.

Measured lab memory profile and the capstone-tier projection: [`REQUESTS.md` §4–5](REQUESTS.md).
