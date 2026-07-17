# SOC-N100 Week 3 — Lab 3 run-of-show (Thursday, July 23, 2026)

**Purpose:** teaching notes for lab 3. The script is the material
(`code/lab3_rent_burden.R` — **renamed from `lab3_evictions.R` on 2026-07-16** to match its
content; say so in class in case anyone bookmarked the old name). 5–7pm on Zoom, students on
r.datahub via the git-pull link on the course site.

**Accuracy note:** every number below was verified against **live ACS pulls at year = 2024 on
2026-07-16**, and the full script (including the new §11 tail) batch-runs clean. The timing
plan is a suggestion.

## Preflight (before Thursday 5pm)

- [ ] **Recalibrate Thursday morning:** lab 3's opening recap assumes lab 2's core landed
      (catalog, mutate, race pulls, the §6 geom_col charts). If Wednesday's class reality
      differed, adjust the recap the way lab 2 §6 handled lab 1's skipped charts. The §11
      tail already assumes NOBODY did lab 2's optional §10 — no adjustment needed there.
- [ ] **Push before class** — students git-pull the renamed file at click time (unmodified
      old copies rename cleanly on their machines).
- [x] Lab 3 batch-runs end-to-end after the rename + new §11 (2026-07-16)
- [x] `a1_example.R` restored to `code/` — lab 3 §9's "open the model answer" pointer is true

## Suggested timing (~110 min + buffer)

| Lab § | Beat | Min |
|---|---|---|
| — | Open: tonight we go from COPYING numbers to BUILDING one; A1 due Monday | 5 |
| 1 | Table anatomy: dollars vs counts; **THE UNIVERSE RULE** box (read it aloud); YT1 (B25064 = a dollar table) | 12 |
| 2 | Tonight's question: what SHARE of renters are burdened; B25070's buckets; tracts = neighborhoods (~4,000 people) | 10 |
| 3 | The pull: 5 variables × 379 Alameda tracts = 1,895 rows; long data | 8 |
| 4 | pivot_wider — let them hit the **1,790-row accident** (it is designed); then select(-moe) → 379 clean rows | 15 |
| 5 | mutate the measure; summary(): median ~0.47 — "in the typical tract, nearly half of renters are burdened"; the 2 NA tracts; if_else() fix | 15 |
| 6 | group_by + summarize: mean ~46%; **158 of 379 tracts majority-burdened** — "two of every five neighborhoods"; YT3 | 15 |
| 7 | The histogram, one layer at a time; computed median line; data-humility beat (tract moes are big — shapes, not rankings) | 15 |
| 8 | YOUR TURN: the whole pipeline for their county (A1/A2 seed) | 15 |
| 9–10 | A1 walkthrough — open `code/a1_example.R` live; recap; pitch §11 as optional homework | 5 |

## Numbers you'll say out loud (live-verified 2026-07-16, year = 2024)

| Figure | Value |
|---|---|
| Raw pull | 1,895 rows = 379 tracts × 5 variables |
| Messy pivot (moe kept) | 1,790 rows, NA-riddled |
| Clean pivot | 379 rows |
| summary(p_rb) | median 0.4734 ("about 0.47"), mean 0.4599 ("around 46%"), 2 NAs |
| The 2 NA tracts | 4443.03 and 9900 — both zero renter households (9900 is the open-water tract) |
| Majority-burdened (p_rb > 0.5) | **158** of 379 |
| YT3 instructor answer (p_rb > 0.3) | 334 of 379 |
| Quartiles | 0.366 / 0.473 / 0.570; max 1.0 |

## §11 optional tail — instructor answers (all live-verified 2026-07-16)

New ideas it teaches from zero: `function()` as a recipe, `map()` + `list_rbind()`,
`geom_line()`, and color inside `aes()` (the last two repeat lab 2 §10 for anyone who did it).

| County | 2016 | 2020 | 2024 |
|---|---|---|---|
| Alameda | 0.496 | 0.463 | 0.482 |
| San Francisco | 0.407 | 0.353 | 0.378 |
| Solano | 0.541 | 0.507 | 0.572 |

Beats that check out: Solano — the cheapest median rent of the three (2024: $2,163 vs
Alameda $2,357, SF $2,476) — carries the highest burdened share in all three years; SF is
lowest throughout; every county dipped into 2020; only Solano now sits above its 2016 level.
The Humboldt lesson, moving through time — and a preview of lab 5's nine-county ranking.

## Likely stumbles

- **The §4 accident is the lesson** — resist fixing it preemptively; let the 1,790 rows land.
- **Universe rule violations**: dividing by another table's total. Repeat the box; it is the
  one rule to never break.
- `filter(NAME == "Alameda County, California")` needs the FULL name string — partial names
  silently return zero rows.
- Fresh accounts / key failures: same drill as always (lab 1 §6; redo with overwrite = TRUE).
- "Why did the file name change?" — renamed 2026-07-16 to match content; the old name
  belonged to the pre-rewrite plan.

## After class

- A1 due **Monday July 27, 5pm**; the model answer is `code/a1_example.R`, walked through in §9.
- §11 (burden over time) and lab 2 §10 (temporal charts) are both optional extras — either
  one is strong A1/A2 material.
- Next lab (Tue Jul 28): `code/lab4_evictions_mapping.R` — ERN eviction filings, joins,
  rates, and maps. Hard displacement meets soft displacement.
