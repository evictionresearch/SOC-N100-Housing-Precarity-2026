# SOC-N100 Week 1 — Rebuilt Lecture (Tuesday, July 7, 2026)

**Purpose:** Build-ready slide spec for the Week 1 Tuesday lecture, rebuilt around one arc —
*the old story of gentrification → why it broke → Chapple's reframe → your HPRM*, with
hard/soft displacement as the spine and the AI segment folded in.

**Accuracy note:** Every number and quote below was verified against a source read on
2026-07-07 (Chapple 2017 PDF; Hwang & Sampson 2014 JSTOR PDF; HPRM `section6_2019_primary_results.md`;
`bay/index.qmd`; the IPV blog). Items needing *your* confirmation are tagged **[CONFIRM]**.
Do-not-claim items are in the Guardrails section at the end.

**Timing (Tuesday, ~2 hr):** Intro/syllabus (~15) → Displacement arc, Acts 1–4 (~50) →
AI discussion + live demo (~15–20, full script in `ai_lecture_draft.md`) → set Week-1 setup
as homework. **Thursday = tools** (RStudio/GitHub/Census key + AI hands-on).

Legend: 🎤 = what to say. ✅ = verified this session. 📎 = real but cite to its source. 🚫 = do not claim.

---

## SECTION 0 — OPEN

### S1 — Title
- Housing Precarity and Displacement: Racial and Gender Inequality in Gentrification and Eviction
- Tim Thomas, Ph.D. · SOC N100 · July 7, 2026

### S2 — Agenda (revised: ideas today, tools Thursday)
- Introductions
- How we'll build this class (the arc)
- Displacement: the old story → today
- How I use AI (and how you will)
- Set-up for Thursday's lab
🎤 "Tonight is ideas. Thursday is tools — we'll get RStudio, GitHub, and your Census key working then."

---

## SECTION 1 — THE DISPLACEMENT ARC (Acts 1–4)

### S3 — ACT 1: How we used to explain neighborhood change
- The popular image: an influx of "gentry" turning a working-class area into a middle-class enclave *(Chapple 2017, p. 84)*
- **Demand school** (geographers, sociologists): white-collar job growth + an urban aesthetic pioneered by artists → "back to the city"
- **Supply school** (Marxist geographers; Neil Smith): capital exploits the **"rent gap"** — disinvest, then reinvest *(Smith 1979)*
- Both assumed **gentrification = displacement**, one **neighborhood** at a time
🎤 "For thirty years two camps argued about *why* neighborhoods change — demand vs. capital. But they shared one assumption: that gentrification and displacement are the same thing, studied one block at a time. That's the assumption that broke."

### S4 — ACT 2a: Then sociologists measured it — Freeman
- **Freeman & Braconi (2004)**, *JAPA* 70(1): 7 gentrifying NYC neighborhoods, 1991–1999 — poor renters there were **less** likely to move than similar renters elsewhere ✅
- **Freeman (2005)**, "Displacement or Succession?", *Urban Affairs Review* 40(4):463–491 — displacement/mobility played only a **minor** role; change came more from *who moves in* (succession) ✅
- The decoupling: **rent burden predicts displacement; "gentrification per se does not"** *(Chapple 2017, p. 86)*
🎤 "Lance Freeman actually followed households. In gentrifying New York, poor renters were *less* likely to move. That cracked the automatic equation. It's also the root of my method — Freeman followed *individual households*; the HPRM scales that idea to the whole country." *(Note honestly: Freeman's finding is contested — Newman & Wyly 2006 — a good lesson that findings get revisited.)*

### S5 — ACT 2b: Race runs the pathways — Hwang & Sampson
- **Hwang & Sampson (2014)**, "Divergent Pathways of Gentrification," *ASR* 79(4):726–751 — Google Street View to observe change block by block ✅
- *"a durable racial hierarchy governs residential selection and, in turn, gentrifying neighborhoods"* (abstract) ✅
- Gentrification's pace was **negatively associated with the concentration of Blacks and Latinos**; a **threshold effect — gentrification attenuates once a neighborhood is >40% Black** ✅
- It's **perceived** disorder (higher in poor minority areas) that deters reinvestment — not *observed* disorder ✅
- Backdrop: **Sampson**, *Great American City* (2012) — neighborhood inequality is durable and structural
🎤 "The rent gap isn't colorblind. Hwang and Sampson show capital flows to the biggest gap that's *white enough* — gentrification stalls past about 40% Black. And what deters it is *perceived* disorder, not actual disorder. That's your course's racial-inequality theme, from inside the gentrification literature."

### S6 — ACT 3a: Chapple 2017 — it's an income crisis
> *"What is widely viewed as a housing crisis, then, is actually an income crisis."* — Chapple 2017, p. 85 ✅
- Driver: **income inequality and declining real wages** — a *labor* question
- Scale shifts from **neighborhood succession → metro-wide income sorting**
- **"the working class of today includes the middle class"** — the *new* gentrification *(p. 87)* ✅
🎤 "Chapple's the hinge. Quit calling it a housing crisis — it's an income crisis in a housing costume. When wages fall behind rents across a whole region, displacement isn't one block, it's everywhere. And it's climbing into the middle class."

### S7 — ACT 3b: Displacement isn't where you think it is
- Chapple's Bay Area evidence (UDP typology): displacement risk is *"not just in low-income neighborhoods, but in moderate- to high-income neighborhoods as well"* *(p. 88)* ✅
- 2000–2013: the region lost ~105,900 affordable units and ~49,000 low-income households — but **only ~12–13% of that loss was in gentrifying neighborhoods** *(p. 88)* ✅
- Net loss of **36,000 moderate-income households** — the loss of the middle *(p. 88)* ✅
🎤 "This is Chapple's map of my backyard — the same Bay Area we'll analyze in lab. Only about one in eight of the actual losses happened in the gentrifying neighborhoods everyone studies. The spotlight was on the wrong part of the stage."

---

## SECTION 2 — HARD/SOFT, FEATURED (your sequence: definition → drivers → ladder → payoff)

### S8 — Two kinds of losing your home *(your framing — kept)*
- **Soft (economic) displacement:** low-income households **priced out** — pressure, but a *choice* to move
- **Hard (legal) displacement:** **eviction** — *no choice*, removal by legal force
🎤 "Two ways to lose your home. Soft: you're priced out — technically you 'choose' to leave, but the market chose for you. Hard: the sheriff. Keep these two apart; the whole course hangs on the difference." **[CONFIRM]** *your current deck lists "rapid rent increases" under HARD — with this framing, pricing-out belongs on the SOFT side; want me to move it?*

### S9 — What drives both *(your diagram from last year — kept)*
- Housing burden + inadequate welfare + rising rent → **Hard & Soft Displacement**
- Individual-level dynamics — **Desmond (2012)**, "Eviction and the Reproduction of Urban Poverty," *AJS* 118(1):88–133 (Milwaukee)
🎤 "The pressures are shared — rent, thin safety nets, wages. Desmond showed at the individual level in Milwaukee how eviction doesn't just result from poverty, it *deepens* it."

### S10 — The scale ladder *(the centerpiece — one graphic, hard/soft on the left edge of each rung)*
- **Individual** → Desmond (2012): eviction reproduces poverty
- **Metro** → Chapple (2017): an income crisis, displacement region-wide
- **National** → **HPRM (your work):** measure *both* channels, every tract
🎤 "Three rungs, same two crises running up the side. Desmond gave us the household. Chapple gave us the metro. What was missing was the whole country, measured directly — so I built it."

### S11 — Two crises, not one *(HPRM divergence payoff)* ✅
- HPRM scores every U.S. tract 0–8: **64,028** map-eligible tracts
- Soft (EDR) and hard (EER) rarely coincide: **only 2.1% of tracts are high on both; 7.0% displacement-dominant, 6.7% eviction-dominant** *(§6.3, 2019)*
🎤 "When you measure both nationally, they split apart. Two percent of neighborhoods have both crises at once; seven percent are pure market displacement; about seven percent are pure eviction. Build only housing and you miss one of them entirely."

### S12 — Confirming Chapple with the HPRM ✅
*Where the soft crisis lives, by neighborhood income (§6.3, 2019):*
- **Soft-displacement-dominant tracts: median income $61,029** — at/above the national median ($61,016); only 10% Black; **highest rents** ($1,132)
- **Eviction-dominant tracts: $45,795 median; 35.6% Black**
- **Both at once (convergence): $39,181; 43.5% Black** — concentrated poverty
🎤 "Chapple predicted displacement would show up in moderate- and high-income neighborhoods. My model confirms it: the *soft* crisis sits in middle-income, high-rent, whiter neighborhoods. The *eviction* crisis concentrates in poorer, Blacker ones. Only where both hit at once is it deep, concentrated poverty."

### S13 — The map has a race ✅
- Highest-risk tracts (score ≥6): **42% Black on average vs. 14% nationally**; **37.9% are majority-Black** *(§6.2)*
- Richmond, VA: **13 tracts score the maximum 8, averaging 76% Black** *(§6.1)* **[CONFIRM]** *your book draft says "15 neighborhoods" — the verified model count is 13 score-8 tracts; pick one*
🎤 "Hwang and Sampson said race structures gentrification. Here's what it looks like when you measure precarity: the worst-off neighborhoods in America are 42% Black against a 14% baseline."

### S14 — Your backyard: the Bay ✅
- **~91% of all Black renters in the Bay Area live in precarious neighborhoods**
- **~73% of all Bay Area renters** face some displacement risk
- *(Eviction Research Network / HPRM Bay Area report)* **[CONFIRM]** *date the map vintage before it goes up*
🎤 "Ninety-one percent of Black renters in this region live in a neighborhood our model flags as precarious. You're sitting inside the case study — and you'll pull numbers like these yourself in lab."

### S15 — The gender the title promises 📎
- Housing precarity is not gender-neutral
- Among 1,085 Texas renters, a non-payment lease violation was **associated with ~2.5× the odds of intimate-partner violence** (AOR 2.50, 95% CI 2.29–2.73; cross-sectional) *(Zapata et al. 2025, IJERPH — your co-authored paper)* ✅
- The HPRM was the **sampling frame** — it reached renters who never appear in court records
🎤 "Our title says *gender*. In a study I co-authored, renters facing a nonpayment violation had about two-and-a-half times the odds of intimate-partner violence — an association, not a cause, but a stark one. And we used the precarity model itself to *find* renters the courthouse never sees."

### S16 — Close the arc
- Old story: gentrification = displacement, one block at a time
- Now: two crises, metro-wide, racialized, measurable — and an **income** problem as much as a housing one
🎤 "That's the class. We measure displacement, not just gentrification; we take race and gender seriously because the data forces us to; and we ask what actually helps."

---

## SECTION 3 — HOW I USE AI (~15–20 min; full script in `ai_lecture_draft.md`)

### S17 — Hook
🎤 "I used AI to help figure out how I use AI for this talk — then I checked all of it. That loop is the whole lesson."

### S18 — One mental model
- AI is an **earnest sophomore / a bright intern**: fast, eager, well-read, and wrong often enough that you check everything
- It **synthesizes what's known; it does not create knowledge or know what's true**

### S19 — Good at / fails at
- **Good:** explaining errors, boilerplate, translating formats, "what am I missing?", getting unstuck
- **Fails:** facts & citations (hallucination), anything genuinely novel, anything needing *your* data, knowing its own limits

### S20 — The discipline (the real skill)
- Verify with an independent check — never assert
- Separate fact-checking from writing; make it grade its own work
- Keep a human in the middle; make it your voice

### S21 — The rule for this class
- Use any AI that can produce a **public shareable link**; hand me the link (code comments + writeup footnotes)
- Perplexity is the easy default; personal account, not CalNet
- The bar: **learn faster, not skip the learning.** If you can't explain it, you're not done.

---

## SECTION 4 — CLOSE / HOMEWORK

### S22 — Before Thursday
- Read **Chapple (2017)** "The New Gentrification" (10 pp., linked on the course site)
- Get a free **Census API key**
- Set up a free **AI account** that shares public links (personal login)
🎤 "Thursday we turn all of this into code."

---

## APPENDIX A — Verified quote & number bank (with sources)

**Chapple, K. (2017). "Income Inequality and Urban Displacement: The New Gentrification." *New Labor Forum* 26(1):84–93.** (read in full 2026-07-07)
- p. 85 "What is widely viewed as a housing crisis, then, is actually an income crisis."
- p. 86 rent appreciation and rent burden "predict displacement, but … gentrification per se does not."
- p. 86 "by focusing only on gentrification, it offers a narrow lens that misses the bigger displacement crisis."
- p. 88 displacement risk "not just in low-income neighborhoods, but in moderate- to high-income neighborhoods as well."
- p. 88 Bay 2000–2013: ~105,900 affordable units lost (12% in gentrifying); 49,000 low-income households lost (13% in gentrified); 36,000 net moderate-income loss.
- p. 91 "It makes little sense to dedicate resources to saving housing without also ensuring the buying power of workers."

**Hwang, J., & Sampson, R. J. (2014). "Divergent Pathways of Gentrification." *ASR* 79(4):726–751.** (abstract read from JSTOR PDF 2026-07-07)
- "the pace of gentrification in Chicago from 2007 to 2009 was negatively associated with the concentration of blacks and Latinos…"
- "Racial composition has a threshold effect, however, attenuating gentrification when the share of blacks in a neighborhood is greater than 40 percent."
- "a durable racial hierarchy governs residential selection and, in turn, gentrifying neighborhoods."

**Freeman, L. (2005). "Displacement or Succession?" *Urban Affairs Review* 40(4):463–491.** doi:10.1177/1078087404273341
**Freeman, L., & Braconi, F. (2004). "Gentrification and Displacement: New York City in the 1990s." *JAPA* 70(1).** *(exact pages not re-verified this session; cite vol/issue/year)*
**Sampson, R. J. (2012). *Great American City*.** / **Sampson (2008), *AJS* 114(1).** *(title not re-verified this session; cite year/journal)*
**Smith, N. (1979). "Toward a Theory of Gentrification…" *JAPA* 45(4):538–48.** *(via Chapple 2017, note 3)*
**Desmond, M. (2012). "Eviction and the Reproduction of Urban Poverty." *AJS* 118(1):88–133.** *(from your prior deck)*

**HPRM (2019 headline, `section6_2019_primary_results.md`, read 2026-07-07):**
- 64,028 map-eligible tracts, 0–8; 4.1% score ≥6; 17.8% score 0; 10.4% score ≥5; 97 score 8.
- High-risk (≥6): 42.4% Black, 62.5% renter, $39,515 median income, 51.3% rent-burdened, 60.7% <80% AMI; 37.9% majority-Black.
- Divergence: 77.9% low, 7.0% EDR-dom, 6.7% EER-dom, 6.3% mixed, 2.1% convergence.
- Divergence income/race: EDR-dom $61,029 / 10.0% Black / $1,132 rent; EER-dom $45,795 / 35.6% Black; convergence $39,181 / 43.5% Black.
- Richmond metro: 13 score-8 tracts, mean 76.0% Black.

**Bay report (`bay/index.qmd`):** 91% of Black renters in precarious neighborhoods; ~73% of all renters at some risk. *(verbatim; vintage undated in file)*
**IPV (`blog/2025-08-...ipv.qmd`):** Non-payment violation AOR 2.50 (2.29–2.73); n=1,085 Harris & Travis Co.; Zapata et al. 2025, IJERPH 22(8):1212; cross-sectional; Thomas is co-author.

---

## APPENDIX B — 🚫 Guardrails (do NOT present as HPRM findings)

- **AMI-tier ordering** (eviction risk rising with the 50–80% AMI share) — you flagged it provisional/mis-specified (2026-06-23).
- **The SDI (Structural Disadvantage Index)** — on hold after the Chapple review (2026-05-20).
- **San Mateo / Redwood City numbers** — templates, no computed statistics.
- **Bay "$5M / 15 tracts / 25,000 households / 65% of color"** — an explicit *hypothetical example* in the report, not a result.
- **Cited stats** (Census Pulse "44%", HUD homeless counts, Finland/veterans) — attribute to source and refresh to the latest release before presenting.
- **Data-vintage flag:** a fresh 2022 recompute of the income cut agrees on the *soft* side (soft-dominant tracts ~ national median income) but the 2022 *eviction* side behaved oddly (EER-dominant median income came out *higher* than 2019's, likely because 2022 EER is pure-prediction / pandemic-trough). Use the **2019 headline** numbers on S12; do not mix vintages.
