# SOC-N100 Week 3 — Lab 3 run-of-show (Tue July 21 + Thu July 23, 2026)

**Purpose:** teaching notes for lab 3, now a TWO-SESSION lab (Tim's call, morning of Jul
21: Tuesday's lecture slot becomes lab, ggplot gets the slow re-teach it needed). The
script is the material (`code/lab3_rent_burden.R`); this sheet is the timing plan, the
numbers you'll say out loud, and the likely stumbles. 5–7pm on Zoom, students on
r.datahub via the git-pull link on the course site.

**What changed in the Jul 21 rewrite** (vs. the version verified Jul 16):

- New §1 **geography ladder** — bridges straight from the Social Explorer opener into
  `geography =` (state 1 row → county 58 → tract 379), GEOID anatomy (06 + 001 + 400100),
  and the detail-vs-reliability trade-off. Teases lab 4's GEOID joins + maps.
- §2 table anatomy now uses **B19013 as the example** so §3 can make students FIND
  B25070 themselves in the `View()` catalog (search: "gross rent as a percentage").
- `rb_vars` gains a sixth entry: **B19013_001 as a commented "stowaway"** for the Part B
  scatter (universe rule explicitly restated — it never enters the burden formula).
  Row-count narrations updated: raw pull **2,274** (was 1,895), messy pivot **2,169**
  (was 1,790). All other §4–§6 numbers unchanged and re-verified.
- Old §7 histogram is now **§7.2**, preceded by §7's "which chart answers which
  question" framing (Posit ggplot2 cheat-sheet URL embedded, verified live Jul 21) and
  **§7.1, a new bar-chart build** (5 Bay counties, horizontal bars, `percent_format()`).
- New **§9 boxplot** (3 counties of tracts, stamp-and-stack) and **§10 scatter**
  (income vs. burden, `geom_smooth()`, the $250,001 top-code beat). §11 = chart-picker
  card. YOUR TURN gains step (e): build one more chart shape of their choosing.
- Old §11 time tail is now **§15**; content unchanged except renumbered references and
  the Solano intro (Solano is no longer "new" — it anchors 7.1 and 9 first).
- New **§16 optional tail: burden by income group (B25074)** — added midday Jul 21 at
  Tim's request. See its own answers block below.
- Afternoon adds (Tim-approved after feedback round): **§5 "pivot in pictures"** — tract
  4002's real six rows drawn long → wide ("nothing lost, nothing computed"), the
  fear-reducer for pivot_wider; **§17 optional tail** — severe burden + A2 menu (block
  below); site Week 4 bullets now name lab 4's eviction parts A/B explicitly.
- **Thursday reality (set Tue night):** class ended at §6, so **Thursday starts at §7**
  — see the reworked Part B table below. The A1 bCourses description (task + the full
  save-on-DataHub / download / upload-to-bCourses how-to) is drafted at
  `website/maintainer/a1_bcourses_description.html` — paste it via the assignment
  editor's `</>` (raw HTML) button; set due date + File Uploads submission type in the
  Canvas fields. Push the lab 4/5 seam fixes + this sheet before Thursday.
- Pre-class add (Tim's call): **§5 now succeeds BEFORE it fails** — `three_cities_long`
  (lab 1's hand-built table, melted) pivots cleanly back to the lab-1 original, so
  students' first-ever pivot works; the 2,169-row moe accident follows unchanged. Tim's
  own midday comment polishes (spelled-out formula codes in §3; "by default" in §4) are
  in place; commit 35a6630 "lab 3 push" predates the toy-pivot add — **push again
  before 5pm**.
- Same-named sections renumbered: group_by/summarize is **§8** (opens Part B), YOUR
  TURN **§12**, A1 **§13**, recap **§14**. YT numbering 1–5 unchanged.

**Walker reading alignment (whole book reviewed Jul 21, chapter contents verified
against walker-data.com/census-r):** students were assigned Preface + Ch 1–2 due Jul 16;
**Ch 3–4 are due Thursday Jul 23** — so Tuesday runs slightly ahead of the reading, and
the lab's header says so. The fit is exact, and the lab now cites each piece in place:
Ch 1 §1.2 "Census hierarchies" (nesting diagram) = §1's geography ladder; Ch 3 = the
wrangling sections (§3.3 group-wise = lab §8; §3.4 time series + cautions = lab §15;
§3.5 margins of error = the moe-humility beat); Ch 4 = the chart sections (histograms,
bars, boxplots, scatters with trend lines; §4.3's moe error bars deferred to the book).
Per Tim's keep-mapping-simple call, Week 4's assignment is now scoped to **Ch 5
§§5.1–5.2 + Ch 6 §§6.1–6.3** (shapes, then geom_sf/tmap choropleths — matching lab 4)
with the CRS math (§5.4) and advanced maps (§6.6) marked optional; Week 5 gained an
*optional* §8.1 (segregation/diversity indices) for lab 5. Unassigned and rightly so:
Ch 7 (spatial analysis), Ch 8.2+ (regression/GWR/clustering), Ch 9–12 (microdata,
other/international sources) — beyond a 6-week intro.

**Accuracy note:** every number below was verified against **live ACS pulls at
year = 2024 on 2026-07-21**, the full script batch-ran clean the same morning
(`--labs=3`, 12.7s), and all five ggsave charts were rendered and visually inspected
(bar sorted Solano-on-top, boxplot Solano-highest/SF-tightest, scatter downhill with
the top-code stripe, histogram median line just above 0.47). Timing is a suggestion.

## Preflight (before TONIGHT, Tue 5pm)

- [ ] **Push `main` before class** — students git-pull at click time and need tonight's
      rewritten lab + updated site (Tuesday now says Lab, part A / Thursday part B).
- [ ] Social Explorer open and logged in for the warm-up tour (nation → state → county →
      tract → block group → block over the East Bay works well; the lab's §1 assumes
      only that they SAW nested polygons of different sizes).
- [x] Lab 3 batch-runs end-to-end after the rewrite (2026-07-21, exit OK)
- [x] Opening recap recalibrated: lab no longer claims they "built a labeled bar chart"
      — it says charts were seen "once, quickly" and re-teaches from the canvas up
- [x] `code/a1_example.R` in place — §13's "open the model answer" pointer is true
- [x] Cheat-sheet URL resolves (opensource.posit.co) + repo copy exists
      (`docs/cheatsheets/data-visualization.pdf`)

## Suggested timing — PART A, Tuesday (~110 min + buffer)

| Lab § | Beat | Min |
|---|---|---|
| — | Social Explorer tour: the polygon ladder, tract ≈ neighborhood | 15 |
| — | Open the lab: two jobs (a real measure + charts done right); A1 due Monday | 3 |
| 1 | The ladder in get_acs(): 1 → 58 → 379 rows; **CA median renter burden 32.8%** (read aloud); GEOID anatomy; detail-vs-reliability | 12 |
| 2 | Table anatomy: dollars vs counts; **THE UNIVERSE RULE** box (read aloud); YT1 (B25064 = dollar) | 10 |
| 3 | The hunt: they find B25070 in View() ("gross rent as a percentage"); buckets 007–010; the measure | 8 |
| 4 | The pull: 6 vars × 379 tracts = 2,274 rows; the income stowaway; long data | 7 |
| 5 | pivot_wider: **success first** — melt lab 1's three_cities by hand, pivot it back (6 rows → 3, checkable by eye); THEN the real table → the **2,169-row accident** (designed); select(-moe) → 379; YT2 | 14 |
| 6 | mutate the measure; summary(): median ~0.47; the 2 NA tracts; if_else() | 12 |
| 7 | The four questions + cheat sheet + 60-second ggplot recap | 5 |
| 7.1 | Bar: county build "in one breath," label collision → horizontal swap → reorder → percent_format; **read the ranking against rents** | 14 |
| 7.2 | Histogram, layer by layer; computed median line; data-humility beat | 12 |

Designated cut if long: 7.2 slides to Thursday (Part B still fits — 8/9/10 compress).

## Suggested timing — PART B, Thursday (starts at §7 — Tuesday ended at §6)

**Tuesday actual (Jul 21): class reached the end of §6** — the measure is built, no
charts yet. Thursday is the whole chart arc plus A1, so it runs tight. Designated cuts,
in order: YT4 steps (d)–(f) become homework; §10's read-it compresses; §8 shrinks to
the 158-of-379 beat with YT3 as homework. Protect §13 — A1 is due Monday, and the
save/download/upload how-to now lives on the bCourses assignment page itself.

| Lab § | Beat | Min |
|---|---|---|
| — | Reboot: fresh sessions run §1–§6 top to bottom (pulls take <1 min); recap the measure in one breath | 8 |
| 7 | Which chart answers which question + cheat sheet + 60-second grammar recap | 5 |
| 7.1 | Bar: county build "in one breath"; label collision → horizontal swap → reorder → percent_format; **read the ranking against rents** | 15 |
| 7.2 | Histogram, layer by layer; computed median line; moe-humility beat | 12 |
| 8 | summarize() + group_by(); **158 of 379 majority-burdened** — "two of every five neighborhoods"; YT3 | 10 |
| 9 | Boxplot: stamp-and-stack 3 counties (723 tracts); box anatomy; the **8-rows warning is designed**; read vs 7.1's bars | 15 |
| 10 | Scatter: hypothesis first; 4-row warning; **$250,001 top-code stripe**; geom_smooth; poorer-half 53% vs richer-half 40% | 15 |
| 11 | The chart-picker card (steal it for A1/A2) | 3 |
| 12 | YOUR TURN: start (a)–(c) in class, (d)–(f) at home — circulate | 15 |
| 13–14 | A1 walkthrough — open `code/a1_example.R` live ("model, not template"); then TEACH the first-ever save-a-script move (File > New File > R Script → save to HOME, **never the class folder** — it refreshes from GitHub) using the bCourses page's Steps 2–5 as the script (demo file: a1_thomas.R; naming = a1_[yourlastname].R; submission = exactly two files, .R + Word doc with chart pasted in); pitch §15–§17 as optional | 12 |

## Numbers you'll say out loud (live-verified 2026-07-21, year = 2024)

### Part A

| Figure | Value |
|---|---|
| Ladder: state / county / Alameda-tract rows | 1 / 58 / 379 |
| CA median renter burden (B25071_001, state) | **32.8%** (moe 0.2) — the typical CA renter is burdened |
| First tract GEOID read-aloud | 06001400100 = 06 + 001 + 400100 ("Census Tract 4001; Alameda County; California") |
| Raw pull | **2,274** rows = 379 tracts × 6 variables |
| Messy pivot (moe kept) | **2,169** rows, NA-riddled |
| Clean pivot | 379 rows (B19013_001 lands first alphabetically — say column order means nothing) |
| summary(p_rb) | median 0.4734 ("about 0.47"), mean 0.4624, 2 NAs |
| The 2 NA tracts | 4443.03 and 9900 — both zero renter households (9900 is the open-water tract) |
| Bar chart p_rb | Solano **.572**, Contra Costa **.534**, Alameda **.482**, San Mateo **.464**, SF **.378** |
| 2024 median gross rent (B25064), same five | San Mateo $2,922 > SF $2,476 > CoCo $2,375 > Alameda $2,357 > **Solano $2,163** |
| The 7.1 punchline | cheapest rent (Solano) ↔ heaviest burden; priciest (San Mateo) near the bottom; SF lightest |

### Part B

| Figure | Value |
|---|---|
| Majority-burdened (p_rb > 0.5) | **158** of 379 |
| YT3 instructor answer (p_rb > 0.3) | 334 of 379 |
| Alameda quartiles | 0.366 / 0.473 / 0.570; max 1.0 |
| three_counties_rb | **723** rows = 379 + 244 (SF) + 100 (Solano) |
| Boxplot warning | "Removed 8 rows" = zero-renter tracts: 2 Alameda + 4 SF + 2 Solano (all B25070_001 = 0, checked) |
| Boxplot medians (q1–q3) | Alameda .473 (.367–.571) / SF .367 (.301–.458) / Solano **.564** (.429–.648) |
| Boxplot beats | Solano's median > SF's 75th percentile; SF box tightest; Alameda spans 0→1 |
| Scatter warning | "Removed 4 rows" = tracts with no published median income |
| Top-code stripe | tract medians above $250k all reported as **$250,001** — 22 Alameda tracts stacked at the right edge |
| Correlation (not in script; if asked) | r ≈ −0.52 |
| Halves beat | below-median-income tracts: median p_rb **53%**; above: **40%** (187 vs 188 tracts) |

## §15 optional tail — instructor answers (verified 2026-07-16; function re-ran clean 2026-07-21)

New ideas taught from zero: `function()` as a recipe, `map()` + `list_rbind()`,
`geom_line()`, and color inside `aes()` (the last two repeat lab 2 §10 for anyone who
did it). The income stowaway rides through the county pulls harmlessly (the script says
"ignore it here").

| County | 2016 | 2020 | 2024 |
|---|---|---|---|
| Alameda | 0.496 | 0.463 | 0.482 |
| San Francisco | 0.407 | 0.353 | 0.378 |
| Solano | 0.541 | 0.507 | 0.572 |

Beats that check out: Solano — cheapest median rent of the three (2024: $2,163 vs
Alameda $2,357, SF $2,476) — highest burdened share in all three years; SF lowest
throughout; every county dipped into 2020; only Solano now sits above its 2016 level.

## §16 optional tail — burden by INCOME group (added Jul 21; all numbers live-verified)

Optional homework like §15, not class time. It is the trimmed teaching cut of the exact
table ERN registers in `evictionresearch/library/code/Variables.R` (`ir_var17`, all 64
B25074 lines); the lab says so. **True AMI-tier burden stays out of the course** — the
in-house attempt (`library/code/d_calc_ami_incomplete.R`) is itself unfinished, because
mapping Census dollar buckets onto HUD HAMFI tiers takes CHAS special tabs or
interpolation. The lab's caveat tells students to caption "by household income," never
"by AMI," and places lab 2's Alameda very-low line ($64,684) mid-bucket as proof.

New ideas taught: systematic variable naming (names-as-documentation), universe
cross-check against a known table, a denominator decision (subtract "not computed"),
and `reorder()` by a hand-written order column.

| Alameda 2024, share burdened (of computable) | Value |
|---|---|
| Under $10k | **94.6%** ("nineteen of every twenty") |
| $10k–20k | 84.4% (the DIP — see below) |
| $20k–35k | 87.8% |
| $35k–50k | 90.1% |
| $50k–75k | 79.5% |
| $75k–100k | 60.0% |
| $100k+ | **14.8%** (the cliff) |

Say-aloud beats, all verified: universe check **272,737 = 272,737** (seven B25074 group
totals vs `bay_rb`'s Alameda B25070_001 — the ten-second habit); not-computed = 5,360
of 17,992 in the poorest group (~30%) vs ~4% county-wide (11,916/272,737), and leaving
them in drags the poorest bar to 66% — the artifact the denominator decision avoids.
The $10k–20k dip vs its neighbors is presented as an open research question with
subsidized housing (rent capped near 30% of income) as a *labeled hypothesis* — the
A2 "draft a research question" beat. YT6: their county; watch for students captioning
it "by AMI."

## §17 optional tail — severe burden + the A2 menu (added Jul 21 pm; live-verified)

**17.1 severe burden (50%+)** is one mutate on `bay_rb` — zero new pulls. Say-aloud
numbers: statewide **27.3%** of California renter households pay half or more of income
in rent; counties Solano **.294** / Contra Costa **.268** / Alameda **.251** / San
Mateo .239 / SF .189 — same ordering as the 30% ranking ("widespread and deep travel
together"). Alameda tract-median severe share ≈ 23% if anyone asks. Teaching beat:
report BOTH lines in A2 — 30%+ = how widespread, 50%+ = how deep.

**17.2 menu is deliberately comments-only** (overcrowding B25014 with the
owner/renter-branch universe warning; B25064 rents over time via the §15 pattern;
B25003 renter share = exposure vs pressure) — it adds reading, not doing, per Tim's
"lab is pretty thick." Watch for A2 students grabbing B25014's owner branch — that's
the universe stumble it warns about. Deliberately excluded: mobility/churn tables,
owner burden, HPRM-style indicator stacks.

## YOUR TURN answers

1. **B25064** → dollar table, "Median Gross Rent (Dollars)" — the typical rent, in
   dollars (verified in the 2024 acs5 catalog Jul 21).
2. Read off their screen: first row = **Census Tract 4001**; the B25070_001 value is
   whatever their View shows (spot-check a couple of students aloud).
3. **334** of 379 tracts above 0.3 — the story shifts from "two in five neighborhoods
   are majority-burdened" to "burden is nearly universal; 9 in 10 neighborhoods have at
   least 30% of renters burdened."
4. Their county — walk the room; watch for universe-rule violations in (b).
5. Their three counties over time — strong A1/A2 fuel.

## Likely stumbles

- **The §5 accident is the lesson** — resist fixing it preemptively; let the 2,169
  rows land, then ask "what did we ignore?"
- **The §9 and §10 warnings are designed.** "Removed 8 rows" / "Removed 4 rows" =
  ggplot telling the truth. If someone panics: warning ≠ error, and the script explains
  each one. Same for the §7.2 "pick better bins" message and §10's "method = 'loess'".
- **Stuck `+` in the Console** (guaranteed tonight — every chart ends in `+`) → Escape.
  Red text isn't always an error.
- **Universe rule violations**: dividing by another table's total. Repeat the box.
- **The horizontal-bar swap** (x↔y in 7.1) is the one genuinely new ggplot move of the
  night — have students say out loud what moved where.
- `filter(NAME == "Alameda County, California")` in §15 needs the FULL string —
  partial names silently return zero rows. (County NAMEs use commas; tract NAMEs use
  semicolons — comes up if anyone filters tracts by name.)
- **Thursday reboot**: fresh sessions must re-run §1–§7 before Part B (the script's
  Part B banner says how). Budget the 8 minutes; it doubles as review.
- Fresh accounts / key failures: same drill as always (lab 1 §6; redo with
  `overwrite = TRUE`).

## After class

- A1 due **Monday July 27, 5pm**; model answer `code/a1_example.R`, walked in §13.
  After 7.1, expect (and encourage) horizontal bars in submissions.
- §15 (burden over time) and lab 2 §10 (temporal charts) both remain optional extras —
  either one is strong A1/A2 material.
- Next lab (Tue Jul 28): `code/lab4_evictions_mapping.R` — ERN eviction filings, GEOID
  joins, rates, then maps Thursday. The Social Explorer polygons come back as tmap
  choropleths — call back to tonight's tour when you open it.
