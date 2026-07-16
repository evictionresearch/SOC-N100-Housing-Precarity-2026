# SOC-N100 Week 2 — Lab 2 run-of-show (Thursday, July 16, 2026)

**Purpose:** teaching notes for tonight's lab. The lab script is the material
(`code/lab2_census_data.R` — comments are the lecture); this sheet is the timing plan,
the numbers you'll say out loud, the YOUR TURN answers, and the likely stumbles.
5–7pm on Zoom, students on r.datahub via the git-pull link on the course site.

**Accuracy note:** every number below was re-verified against **live ACS pulls on
2026-07-16**, and the full script was batch-run end-to-end the same day. Both ggsave
charts were rendered and inspected — sorted bars, dashed HUD line, and the SF locality
flip (Asian households top the homeownership chart) all appear as the comments describe.
The timing plan is a suggestion, not a constraint.

**Vintage bump (3pm Jul 16):** the labs now pull **year = 2024 (2020–2024 ACS)** — Tim's
call, afternoon of the lab. Every narrated number in lab 2 was re-pulled at 2024 and the
comments updated; all story beats still hold (Hinds below SF's very-low line, Latinx and
Black medians below their HUD lines, Asian households top SF homeownership, White median
more than 3× Black). Two claims changed with the vintage: the White–Black income gap is
now "over 121000" (121,348 — it narrowed; Black median income *rose* ~$2.8k) and the
largest moe in the race pull is now "about 8700" (was ~5800). The catalog object is
renamed `vars_2024`.

## Preflight (before 5pm)

- [x] Lab 2 runs end-to-end unpatched at year = 2024 (batch runner `--labs=2`, 2026-07-16)
- [x] Every stated number matches a live 2024 pull (table below)
- [x] Catalog answers verified in the **2024** acs5 catalog: B25064_001 concept is exactly
      "Median Gross Rent (Dollars)"; B19013/B25003 race letters A/B/D/I map as the lab states
- [ ] **Push `main` before class** — students git-pull whatever GitHub has at click time.
      (Local matched `origin/main` as of ~10:15am; tonight's site update + this sheet
      still need a push.)
- [ ] Optional full pass: "Manual test checklist" section in `DATAHUB.md`

## ggplot placement — decided (Jul 16)

Lab 1 §10 stays skipped: do **not** re-teach it tonight. Lab 2 §6 already teaches
charts from zero — nine chunks, one new idea each — and says so to students at its
open ("We skipped lab 1's chart section in class, so tonight is your first chart").
§10's only moves that §6 doesn't cover are the horizontal orientation (`y = NAME`),
`geom_vline`, and saving a chart as an object — which is why lab 2's close names
§10 "the horizontal twin," the at-home practice before A1 (with §11 as the moe
habit in full). Re-running §10 first would double-teach ~25 minutes of identical
skills and push §7 (the A1 seed) or §8 off the table.

## Suggested timing (~110 min + buffer)

| Lab § | Beat | Min |
|---|---|---|
| — | Open: last Thursday ended before charts; tonight = catalog → income tiers → race → your first chart | 5 |
| 1–2 | Setup is two `library()` lines now; the 28k-row catalog, `View()` search, code anatomy (table _ line); **YOUR TURN 1** | 15 |
| 3 | `county =` input; SF county median $140,970 as the yardstick; **the AMI honest footnote** (below); `mutate()` the tiers — "$112,776 is *low income* by the 80% rule" | 15 |
| 4 | Locality lesson: Hinds Co. MS median ($49,402) is *below* SF's very-low line ($70,485); `bind_rows()` | 10 |
| 5 | Named variable vectors; the canyon ($175,732 vs $54,384); the moe habit (largest moe ~$8.7k, gap $121k — real) | 10 |
| 6 | **The payoff**: first chart, one layer per chunk (canvas → aes → geom_col → reorder → fill → hline → labs → theme/dollar → ggsave); file lands in the home folder, Export to download | 25 |
| 7 | **YOUR TURN: their county** — this is the A1 seed; circulate (breakouts or quiet solo time, your call) | 15 |
| 8 | Homeownership gap, `output = "wide"`; the locality flip vs Tuesday's national chart. **Designated cut — "finish at home" if short** (the script says so at §8) | 12 |
| 9 | Close: recap, A1 pitch (due Mon Jul 27), tease next lab (build your own measure: universe, pivot_wider, group_by/summarize) | 3 |

## Numbers you'll say out loud (in the script, verified live 2026-07-16)

| Figure | 2020–2024 ACS (tonight) | was, 2019–2023 |
|---|---|---|
| Variable catalog rows | "about 28,000" (28,437) | 28,261 |
| SF median household income (B19013_001) | 140,970 | 141,446 |
| SF low income (80% AMI) | 112,776 | 113,157 |
| SF very low income (50% AMI) | 70,485 | 70,723 |
| Hinds County, MS median income | 49,402 | 49,966 |
| SF White median (B19013A) | 175,732 | 177,030 |
| SF Black median (B19013B) | 54,384 | 51,610 |
| SF Asian median (B19013D — not printed in script) | 124,172 | 123,757 |
| SF Latinx median (B19013I) | 102,392 | 99,984 |
| White–Black gap ("over 121000") | 121,348 | 125,420 |
| Largest moe in the race pull ("about 8700") | 8,657 | 5,778 |
| Homeownership % (Asian / White / Latinx / Black) | 47.3 / 37.6 / 25.6 / 21.6 | 48.7 / 36.8 / 26.4 / 22.4 |

If someone compares against last week's handout or the lecture chart: the 2024 5-year
dropped in Dec 2025; estimates re-baseline every release — that's the "say the year out
loud" habit, live.

## YOUR TURN answers

1. **Median Gross Rent** → `B25064_001`, concept exactly "Median Gross Rent (Dollars)"
   (verified in the 2024 acs5 catalog today).
2. **Another Bay Area county + tiers** — worked example, Alameda 2024: median **129,367**
   → low income **103,494** / very low **64,684** / extremely low **38,810** (live pull
   2026-07-16; tiers are 0.8/0.5/0.3 arithmetic).
3. **Their homeownership chart** — same §8 code, three edits: `state`, `county`, title.

## The AMI honest footnote (added ~4:30pm) — what's verified

Lab 2 §3 now distinguishes our **county median household income** yardstick from the
**official AMI**. The verified facts behind it, in case students push:

- **Official AMI is HUD's number, not the Census's.** HUD publishes income limits for
  *FMR areas*: metropolitan areas (OMB draws those), HUD-carved subareas ("HUD Metro
  FMR Areas"), and **each non-metropolitan county** — so outside metros, the county
  literally is the official area. Benchmark = ACS median **family** income, updated by
  HUD, 4-person base, family-size + other adjustments (FY25/FY26 methodology PDFs at
  huduser.gov/portal/datasets/il.html).
- **San Francisco's official area** is the San Francisco HMFA = **SF + Marin + San
  Mateo counties** (per HUD's FMR schedules; SF MOHCD and Marin Housing both operate
  on it). One-click primary check if you want it airtight before saying it live: the
  "San Francisco, CA HMFA" row of HUD's FY2026 FMR Schedule PDF.
- **FY2026 SF HMFA published schedule** (effective 5/1/2026, via marinhousing.org
  quoting HUD): 4-person median family income **$200,800**; tiers 30/50/80% =
  **$63,050 / $105,050 / $168,100**. Note $168,100 ≠ 0.8 × 200,800 ($160,640) — HUD's
  high-housing-cost adjustment, live proof the official tiers aren't literal
  percentages of the median.
- **Family vs household, verified live today** (2024 ACS, SF County): median household
  income **$140,970** vs median *family* income **$171,141** (B19113). Families skew
  higher even inside one county; the rest of the gap to $200,800 is the richer
  three-county geography, the 4-person base, and HUD's update factor.
- Teaching beat: our $112,776 "low income" line already shocks — then tell them the
  *official* bar for a family of four in SF is **$168,100**.

## Likely stumbles (from lab 1 night)

- **Fresh account / new hub server** → `install.packages("tidycensus")` once, then
  `library()` again — the script's §1 comment walks them through it.
- **Key failures** (`invalid char in json text`, HTML in the error) → the key was never
  activated (email link) or never saved. Fix: redo lab 1 §6 —
  `census_api_key("KEY", install = TRUE, overwrite = TRUE)`, then restart R.
- **Stuck `+` in the Console** (very likely tonight — ggplot lines end in `+`) → press
  Escape. Reassure: red text isn't always an error.
- **`View()` search box** is the small box at the top **right** of the View tab.
- Lookalike tables (B19019, B25119 near B19013) — that's the deliberate §2 lesson, let
  them hit it.

## After class

- If §8 got cut: remind students it's self-contained homework (two known moves + one new
  input), and lab 1 §§10–11 are the extra-practice path before A1.
- A1 (due **Mon Jul 27, 5pm**): one variable, one chart, 2–3 sentences — tonight's §7 is
  the template. Tell them to pick their place this week; they keep it through A2 and the
  final project.
