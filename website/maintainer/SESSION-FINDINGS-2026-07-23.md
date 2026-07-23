# Session findings — DataHub RAM, bCal clutter, bCourses (2026-07-23)

**Audience:** course staff / future agents on `resource-request`.  
**Branch:** keep local/remote `resource-request`; **do not merge to `main`** until end-of-course decision.  
**Companion tooling:** controller skill `bcal-declutter` + probe script in `~/tools/google-workspace-tools`.

---

## 1. DataHub RAM — what we found

| Fact | Detail |
|------|--------|
| Issue | [berkeley-dsep-infra/datahub#8335](https://github.com/berkeley-dsep-infra/datahub/issues/8335) — filed 2026-07-10, **closed** 2026-07-17 |
| Config PR | [#8336](https://github.com/berkeley-dsep-infra/datahub/pull/8336) — merged; **prod** on `r.datahub` 2026-07-13 |
| Mechanism | **`enrollment_type` keys**, not a custom bCourses group |

```yaml
course::1555635::enrollment_type::student:  # 4G
course::1555635::enrollment_type::teacher:  # 8G
course::1555635::enrollment_type::ta:       # 8G
```

**Implications**

- Planned group `DataHub RAM tiers / SOC-N100 Staff 8GB` is **obsolete** for this term ([`bcourses-staff-group-primer.md`](bcourses-staff-group-primer.md) marked superseded).
- Aaron gets **8G** only with a **Teacher or TA** enrollment in bCourses **1555635**; Student role → 4G.
- Still open: log out/in on r.datahub and confirm Environment-tab memory; confirm Aaron’s bCourses role via API once a Canvas token exists (below).

Package-install request remains **unfiled** (lower priority; deferred).

---

## 2. Two overlapping class calendar invites — what we found

Tim (`timthomas@berkeley.edu`) sent **two** Tu/Th 17:00–19:00 series through ~Aug 14 onto Aaron’s **primary** bCal. Both were **Busy** (`opaque`) with RSVP `needsAction`:

| Title | Role (inferred) | Parent event id |
|-------|-----------------|-----------------|
| SOC-N100: Housing Precarity — Teaching | Staff-oriented invite (Zoom + course links in body) | `_611jie9p8go3iba66cqj6b9k8p0k4ba1651j8ba474p3ce2668p3cd9l6k` |
| Housing Precarity and Displacement Class Zoom Meeting | Student Zoom series | `_8h344d9j68o32ba66ko3cb9k8d346b9p8l13ab9k8l130gq26go3ic9m8k` |

They double-blocked the same slot on the main calendar.

**What we did (2026-07-23)**

1. Copied each series onto **Aaron misc** as owned **Free** (`transparent`) events, with resuscitation metadata in the description.
2. Declined both **parent** series on primary via Calendar API `events.patch` + **`sendUpdates=none`** (Tim not notified).

| Series | Aaron misc archive id |
|--------|------------------------|
| Teaching | `m71b8t0d5h73h2ctdfqlmtf1h0` |
| Class Zoom Meeting | `02j48nqsdcl976he2hq0pftch8` |

Aaron misc calendar id: `berkeley.edu_afiqse0vg2tlac6jqp3qgvcnj8@group.calendar.google.com`.

**UI note:** declined events disappear from the main grid only if Calendar → Settings → **Show declined events** is off (usual default).

**Reusable skill:** `bcal-declutter` in the controller (`just bcal-declutter-install`). Do not use `gog calendar respond` for declutter — it cannot set `sendUpdates=none`.

---

## 3. bCourses API — what we found

- Anonymous/unauthenticated `GET /api/v1/courses/1555635` → **401** (Bearer required).
- No Canvas token in 1Password `develop` yet.
- Probe path documented: controller `docs/CREDENTIALS.md` § bCourses; script `just bcourses-soc-n100-probe` (expects `op://develop/bCourses API — aculich@berkeley.edu/credential`).
- Settings to mint token: https://bcourses.berkeley.edu/profile/settings (opened once via `browse berkeley`).

Until the token exists and the probe shows Teacher/TA, treat 8G hub access as **unverified**.

---

## 4. Earlier DataHub runtime note (lab batch)

Running `Rscript website/maintainer/run_all_labs.R --per-lab` inside **RStudio Terminal** on a 1G (pre-grant) or busy pod can surface RStudio Server **403** on `start_terminal` / `get_memory_usage_report` during heavy installs (e.g. lab 5 → `evictionresearch/neighborhood` deps), without a clean OOM message. Prefer pre-install packages, `--labs=N` one at a time, or a non-RStudio shell when smoke-testing. See [`notes.qmd`](notes.qmd).

---

## 5. Repo state

- Branch **`resource-request`** holds maintainer DataHub materials + this briefing; pushed to `origin`; **not** merged to `main`.
- Live student site / Quarto `docs/` remain Tim’s responsibility on `main`.
- Revisit merge-or-archive of `resource-request` after the course ends (~Aug 2026).
