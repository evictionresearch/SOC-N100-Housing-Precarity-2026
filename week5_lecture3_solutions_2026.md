# SOC-N100 Lecture 3 (Tuesday, August 4, 2026, 5:00–6:00pm) — What Actually Helps: From Eviction Data to Eviction Policy

**Status:** build-ready spec (2026-07-30). This file previously held the seed note (2026-07-14);
the seed is superseded and preserved in git history. Hour 2 (6:00–7:00) is project-group
formation; run-of-show in Appendix B. Site alignment shipped 2026-07-30: `website/index.qmd`
(new Aug 4 two-part entry, A2 pointer to the group pitch, Week 6 cross-reference) and
`website/syllabus.qmd` (week table, final-project pointer to this lecture).

**What changed from the seed:**

- Reordered around the Jul 29 student conversation: data→policy opening, testimony moved up
  (was beat 4, now §2), legal cases added (§4, from the library repo's `legal_impact/` memo),
  four-state policy comparison added (§5), post-displacement outcomes added (§6).
- HPRM block compressed: methods beat (student demand) now opens the lecture in §1; the
  two-crises numbers moved into the 4 P's argument (S11); HPRM-5 (gender) became S19.
  HPRM-1/-3/-4 cut or absorbed — see Appendix C.
- All seed [CONFIRM]s resolved except those listed in Appendix C: testimony date is
  **Dec 13, 2024** (not Dec 11 — see S7), Chapple quote re-fetched verbatim, HPRM methods
  verified from the hprm repo + live explainer, WA stats refreshed from the Jul 13, 2026
  profile.
- §5 (four states) patched 2026-07-30: CA/MN from an adversarial deep-research run (22
  claims confirmed 3-0 against official statute sites; 3 plausible-sounding claims
  refuted and flagged), IN/TX from enrolled-act/statute verification agents. S15–S17 are
  now build-ready; guardrails at the end of §5.

**The student asks this lecture answers** (logged Jul 14, plus the Jul 29 conversation):
"How was the HPRM actually done?" → S5. "What are some ways we can make change?" → the whole
hour. The testimony doubles as the final-project model, per the Jul 29 ask.

**Accuracy legend.** ✅ = verified against a source fetched or read 2026-07-30 (this build;
Appendix A has every URL). ✅ᵇ = carried from an earlier dated verification (seed note or week
bank; date shown). 📎 = real quote, attribute to its source on the slide. 🚫 = do not claim.
[CONFIRM] = needs Tim. *(chart read)* = describe the visual, no precise figure.

## AS-BUILT SLIDE MAP (deck read 2026-08-04, ~4:50pm)

Deck: "20260804 SOC N100 Week 5 Solutions". **Slides 1–7 are built.** Section 1 was
restructured during the build and no longer matches the S3–S5 spec below; the as-built
version is better and is recorded here. Slide-by-slide paste copy lives in
`week5_lecture3_slide_build.md`.

| Deck # | Slide, as built | Spec origin |
|---|---|---|
| 1 | Title — "What actually helps: from eviction to eviction policy" | S1 |
| 2 | Agenda | S2 |
| 3 | The Eviction Process (exits at every stage) | new this build |
| 4 | The Data Processing Pipeline (branching: counts → trends; names+addresses → disparity) | S3, restructured |
| 5 | State Counts vs. Names & Addresses — Washington \| Minnesota | new this build |
| 6 | Gap in eviction data (LSC coverage map) | S4, replaced by LSC's own map |
| 7 | Housing Precarity Risk Model | S5 |
| 8+ | Testimony section begins | S6 onward, unchanged below |

**Cut during the build:** the eviction-data-atlas beat as specced in S4 (replaced by the LSC
map, which sidesteps the atlas-page 404); an "Eviction Data WA" OCR/NER method slide that
briefly sat at 6–7.

**Timing:** re-derive when the deck is finished. Release valve is still the video.

**Timing as originally specced (60 min):**

| § | Beat | Slides | Min |
|---|---|---|---|
| 0 | Open: the promise from Week 1 | S1–S2 | 2 |
| 1 | How data becomes policy: pipeline, atlas, HPRM methods | S3–S5 | 8 |
| 2 | The Washington testimony: setup, video, debrief | S6–S8 | 10 |
| 3 | The four P's, each element described | S9–S11 | 10 |
| 4 | Eviction data in the courtroom | S12–S14 | 8 |
| 5 | Four states, four rulebooks | S15–S17 | 8 |
| 6 | After displacement, hard and soft | S18–S20 | 8 |
| 7 | Bates' toolkit and your project | S21–S23 | 6 |

The video clip (S7) is the release valve: play 4 minutes instead of 6 if behind. Cut order if
still long: S4 atlas beat down to one sentence → S17 data plug to one sentence → merge S13
into S14. Do not cut S5 (explicit student demand) or S8/S23 (the assignment tie the second
hour depends on).

Legend: 🎤 = what to say.

---

## SECTION 0 — OPEN (2 min)

### S1 — Title **NEW**
"What Actually Helps" · SOC-N100 Week 5 · August 4, 2026 · subtitle: how eviction data becomes
eviction policy.

### S2 — Agenda **NEW**
- The machine: data → courtroom, capitol, agency
- Watch: five minutes in front of the people who write the laws
- The four P's, and the evidence behind each lever
- The civil rights cases built on this data
- Four states, four rulebooks — and what happens to people after displacement
- 6:00: your final project groups form tonight

🎤 "Week 1 ended on a promise: we ask what actually helps. Weeks 1 and 2 gave you two crises —
the soft one, where the market moves you, and the hard one, where the court does. Tonight is
the rest of the promise: what helps, who decides, and how measurement gets a seat in that
room. And at 6 o'clock you form your project groups. Everything in this hour is a template
for what your group is about to build."

---

## SECTION 1 — HOW DATA BECOMES POLICY (8 min)

### S3 — The pipeline **NEW**
Five boxes, left to right: **court + sheriff records → clean & geocode → estimate
demographics → one disparity statistic → three rooms** (courtroom · capitol · agency).
- The method in one sentence ✅ (ERN legal-impact memo, library repo, July 2026): filing
  records are "linked to demographic estimates, then read as a disparate-impact measure."
- The statistic students already know from Week 2: Black renters, and Black women especially,
  filed against far above their renter share.

🎤 "Here is the whole machine on one slide. Courts produce paper. We turn the paper into
data, the data into one honest statistic, and tonight you'll watch that same statistic work
in three different rooms: a federal courtroom, a state senate, and the agencies that run the
programs. Nothing tonight is a different method. It is this slide, over and over."

### S4 — You can't fix what you can't see **NEW**
- July 2026: ERN finished a census of who collects and publishes eviction court data in all
  50 states + DC ✅ (library repo, `data/eviction_data_atlas/`, evidence-only sweep dated
  2026-07-17, 373 sources link-checked).
- The result: only **6 of 51** publish statewide case-level data (AK, CT, DC, MD, NY, VA);
  **36** publish counts only; **3** have local data only.
- [CONFIRM] the public atlas page (evictionresearch.net/eviction-data-atlas/) is a 404 as of
  2026-07-30 ✅ — deploy before giving students the URL; until then say "we just finished
  this census" with no link.

🎤 "Before any of that can happen you need the records, and here's the dirty secret of my
field: most states cannot see their own eviction crisis. We just finished a fifty-state
census of eviction data. Six states publish case-level records statewide. Most publish
counts, or nothing. That's why this work involves records requests, scraping, and cleaning —
and it's why the skills you're building in lab are not clerical. They are the difference
between a crisis that's visible and one that isn't."

### S5 — "How was the HPRM actually done?" **NEW** *(promised after the Jul 14 question)*

> **BUILT as deck slide 7, "Housing Precarity Risk Model."** As built it carries: EDR 197
> displacement predictors · net migration of low-income households · which census variables
> relate to those moves · EER 184 eviction predictors · 15 states of court records train the
> model · what drives evictions at tract level · HPRM = sum score of EDR and EER · the
> evictionresearch.net/hprm link.
>
> ⚠ **THE EVICTION CLOCK IS NOT ON THE SLIDE.** It is a model input *and* it is the hinge
> to Section 5 — S15 opens by calling back to it, and the 🎤 below ends on "hold onto that
> eviction-clock fact." Either add a line to the slide or say it out loud: *the statutory
> timeline is itself a predictor, and it ranges tenfold, about 5 days in Louisiana to 53 in
> Massachusetts.* Without it, S15's "your address decides how long you have" arrives cold.
>
> ⚠ Also absent from the slide: the **0–4 / 0–4 → 0–8** scoring and **64,028 tracts, 2019
> vintage**. "Sum score of EDR and EER" implies the arithmetic without giving the range;
> worth saying the range aloud so the 0–8 map colors make sense later.
>
> Footer still reads 2024.05.26.
One inputs→outputs slide, no math wall:
- **What goes in** (per census tract): who lives there (ACS — 197 predictors on the
  displacement side, 184 on the eviction side ✅); where renters actually move (a national
  household panel → five-year net migration of low-, very-low-, and extremely-low-income
  renters); where filings concentrate (court records from 15 states train the model ✅); and
  how fast each state's eviction clock runs — the statutory timeline is itself a predictor,
  and it ranges tenfold, about 5 days in Louisiana to 53 in Massachusetts ✅.
- **What comes out**: two risks — **EDR** (soft: low-income renters draining out) and **EER**
  (hard: filing rates above the state norm) — each binned None→Extreme, scored 0–4, then
  **summed to the 0–8 score across 64,028 tracts; 2019 is the native vintage** ✅ + ✅ᵇ
  (2026-07-07 bank).
- Public methods writeup, live ✅: <https://evictionresearch.net/hprm/>.
- Optional live beat (2 min if ahead): pull the map from Jul 14 and score a student's county.

🎤 "Two weeks ago someone asked exactly the right question: how was this actually done? Here
is the honest version. In: who lives in a tract, what rents and moves are doing, how courts
behave, and even how fast your state's eviction clock runs — that last one matters, because
your address decides how long you have. Out: two risks, soft and hard, each scored zero to
four, added up. Zero to eight, every tract in America. Machine learning underneath, a sum a
fifth-grader can check on top. That's the house style: pie chart with a Bayesian chaser —
and hold onto that eviction-clock fact, because it's the door to the state comparison later
tonight."

---

## SECTION 2 — THE WASHINGTON TESTIMONY (10 min)

### S6 — Washington, end to end **NEW** *(all facts: legal-impact memo §6 ✅)*
- **SB 5600 (2019)**: pay-or-vacate notice extended 3 → 14 days (prime sponsor Sen. Patty
  Kuderer; House lead Rep. Nicole Macri).
- **HB 1236 (2021)**: statewide just cause (Macri).
- **SB 5160 (2021)**: the nation's first statewide tenant right to counsel, run by the
  Office of Civil Legal Aid (Kuderer).
- UW eScience Institute, on the 2019 law 📎: "The Washington Evictions Research Project
  provided groundbreaking empirical evidence for stakeholders and policymakers to use to get
  this legislation passed through the house and senate."
- The pipeline is a loop: OCLA and the King County Bar's Housing Justice Project supply
  court records; ERN supplies the public Washington analyses.

🎤 "Washington is the place where the whole machine has run end to end: the UW eviction
study fed the 14-day notice law in 2019, then just cause and the nation's first statewide
right to counsel in 2021. And the exchange never stopped — they send records, we send
analysis. So when the post-pandemic numbers turned ugly, the Senate Housing Committee asked
for the state of things. December 2024. Let's watch."

### S7 — Play the video (≈6 min of playback)
- **TVW, Senate Housing Committee work session, Friday, December 13, 2024** ✅. Agenda,
  verbatim: "Housing cost and impact on supply and stability." · "Right to counsel."
- Date provenance: TVW's own metadata says Dec 13, 2024, 10:30am, and press coverage
  describes Tim addressing the committee "on Friday" (Dec 13, 2024 was a Friday). The URL
  slug reads like "2024-12-11" — it is not a date; TVW slugs don't encode dates ✅. The CV
  lists this under 2025 because TVW tags it to the 2025 legislative session ✅. **Put
  December 13, 2024 on the slide.**
- Cue: testimony starts at **40:00** ✅ᵇ (per the course site). [CONFIRM] pick the end cue in
  advance (≈45:00–46:00 keeps §2 on time).
- Links (both already on `index.qmd`, Aug 4 + Week 6):
  [deck](https://docs.google.com/presentation/d/1x7SCdTeBdczY5Ga5wvixMxtvTv-a4rTph6LIQWLsIk0/edit?pli=1&slide=id.g32100058b3b_1_1#slide=id.g32100058b3b_1_1) ·
  [recording](https://tvw.org/video/senate-housing-2024121118/).

### S8 — Debrief: what five minutes did **NEW**
- The form: one trend line, a handful of numbers, one map, explicit asks. No jargon, no
  methods wall.
- What the room heard ✅ 📎 (Washington State Standard reporting, syndicated in the Yakima
  Herald, Dec 17, 2024): Tim — "The state is in an eviction crisis at this point." Committee
  Chair Patty Kuderer — "The increase in eviction filings is startling and alarming... There
  will be a tsunami of homelessness if we don't handle this correctly."
- Where it stands now, refreshed from the WA profile ✅ (page updated July 13, 2026): 23,913
  filings in the 12 months ending April 2026; about 45% above the pre-pandemic norm; 21 of
  39 counties set all-time records in 2024–25; and eviction now runs hottest on the suburban
  edge — Clark 33.2 and Pierce 29.9 filings per 1,000 renter households against 21.5
  statewide.

🎤 "Notice what those five minutes were: a complex story, told simply, with data underneath —
and a chair who answered in headlines. The same senator who sponsored the 14-day notice and
right to counsel is asking the researcher what comes next. That is the job. And it is also,
precisely, your final project: the syllabus promises an analysis 'that may interest
governmental stakeholders.' In Week 6 you'll each give a version of this. Steal the form."

---

## SECTION 3 — THE FOUR P'S, EACH ELEMENT DESCRIBED (10 min)

### S11 - The framework *(asset: WA profile **Figure 5** ✅ — reuse the graphic directly)*
- Title, verbatim: **"No single lever stops an eviction — it takes four."**
- The framework sentence, verbatim: "Prevent the filing before it reaches court, protect
  tenants once they're in it, preserve the low-cost homes that already exist, and produce
  more."
- Credit, verbatim from the page: "The last three are the Urban Displacement Project's
  anti-displacement framework (Cash & Zuk, Investment Without Displacement)." **Prevent,
  placed first, is Tim's addition** ✅ᵇ (Tim, 2026-07-23) — say so; it's a legitimate "here
  is what my research adds" beat.
- Read the graphic aloud: the timeline runs Rent burden → Missed rent → Eviction notice →
  Court filing → Judgment & writ → Displacement; tiers mark documented effect (T1 largest &
  fastest → T3 structural & slow); a red line marked **"STRONGEST TOGETHER"** connects rental
  assistance to right to counsel.

### Five levers, one build each *(walk Figure 5's numbered list; all quotes ✅ from the page)*
1. **Rental assistance, paid to the landlord (Tier 1).** ERA plus the moratoria "coincided
   with roughly 673,000 fewer filings across studied counties (about 45% below what
   pre-pandemic trends would have predicted)," and ERA recipients saw "about 65% lower odds
   of street homelessness" (Aiken & Reina, 2022). ⚠ Two different 45%s tonight: this one is
   national, *below predicted*; S8's is Washington, *above baseline*. Keep them on separate
   slides.
2. **Eviction diversion and pre-filing mediation (Tier 1).** Washington ran one and let it
   expire: the Eviction Resolution Pilot Program (RCW 59.18.660, statewide from November
   2021) required mediation before a nonpayment case could be heard; the state evaluation
   found a 78% settlement rate; it ended July 1, 2023. The page's ask: bring it back.
3. **Right to counsel (Tier 1).** SB 5160 (2021), RCW 59.18.640 — first state in the nation,
   OCLA-administered; a 2025 UW study finds it still reaches fewer than half of eligible
   tenants ✅. Callback, don't re-teach ✅ᵇ (2026 W1 deck p.20, shown Jul 7): 81% of
   represented tenants secured permanent housing; 56% stayed in the same home; default rates
   still above 40%.
4. **Standing protections (Tier 2).** Just cause (RCW 59.18.650); source-of-income
   protection (RCW 59.18.255), which "roughly halves landlord voucher-denial rates"
   (Cunningham et al., 2018); and new in 2025: statewide rent stabilization (HB 1217),
   capping annual increases at 7% + CPI, 10% max ✅.
5. **Build and preserve homes below market (Tier 3, the long game).** Washington "needs
   about 1.1 million more [homes] by 2044, the largest share for its lowest-income
   households" (WA Dept. of Commerce) ✅; today there are "only 28 affordable, available
   homes for every 100 of the state's lowest-income renters" (NLIHC, The Gap) ✅.

### Why it takes all four **NEW**
- Sequencing 📎 ✅ (Karen Chapple, in The Journalist's Resource, Clark Merrefield, May 2,
  2023): "What seems pretty clear is that you want to make sure you have your tenant
  protections and housing preservation policies in place first and then do some building.
  We should have learned that years ago from urban renewal programs."
- The mapping, verbatim from the page ✅: "Prevent and Protect interrupt the eviction;
  Preserve and Produce ease the rent pressure that starts it."
- The two-crises numbers ✅ᵇ (HPRM 2019, verified 2026-07-07): only **2.1%** of tracts are
  high on both crises; **7.0%** are displacement-dominant; **6.7%** eviction-dominant.

🎤 "Prevent and Protect aim at the hard crisis; Preserve and Produce at the soft one. And
the model says the two crises mostly live in *different neighborhoods* — two percent of
tracts have both at once. Build only housing and you miss one crisis entirely. Pass only
court protections and you miss the other. That's why it's a set of four, in that order —
Chapple's point: protections and preservation first, then build."

---

## SECTION 4 — EVICTION DATA IN THE COURTROOM (8 min)
*(Every fact in this section comes from the ERN legal-impact memo ✅ — library repo,
`legal_impact/README.md`, compiled July 2026 with primary-source verification. Its honesty
flags are carried onto the slides. Tim has confirmed his role in Wasatch and Hunter.)*

### S12 — Seattle, 2017: the first case **NEW**
- ***Smith v. Wasatch Property Management***, No. 2:17-cv-00501-RAJ (W.D. Wash., Seattle).
  Nikita Smith, a Black woman, blocked from even applying to a Renton complex over a
  years-old eviction filing that had been resolved *without* an eviction.
- The ACLU called it the first case to challenge eviction-record screening under civil
  rights law, and the first Fair Housing Act case built on an intersectional race-and-sex
  theory.
- The data anchoring the complaint — produced by Tim: in King County, Black tenants were
  roughly **4x** more likely to have an eviction case filed against them than white tenants;
  households headed by Black women, more than **5x** the rate of households headed by white
  men.
- Filed March 30, 2017; settled October 2017.

🎤 "A blanket 'no eviction record' screen sounds neutral. But the filing data it reads is
this biased — so the screen quietly reproduces the bias, forever, against people like Nikita
Smith who were never even evicted. One statistic turned that from a story into a federal
civil rights claim."

### S13 — Chicago, 2023: the theory travels **NEW**
- ***Legal Aid Chicago v. Hunter Properties***, No. 1:23-cv-04809 (N.D. Ill.): Cook County
  Sheriff data, Sept 2010–Mar 2023 — Black renters were about **56%** of people served with
  an eviction or evicted by the Sheriff, against **33%** of renters; Black women about
  **33%** against roughly **22%**. The complaint calls it "an independent analysis." It's
  Tim's (built in early 2022 with Legal Aid Chicago and the National Housing Law Project;
  ERN's Illinois profile carries the credit line).
- Procedure, honestly told: dismissed September 2024 **on organizational standing, not on
  the merits of the disparate-impact theory**; judgment vacated; amended complaint filed;
  the second motion to dismiss had no ruling on the free docket as of early 2026.
- The companion: ***HOPE Fair Housing Center v. Mastercare*** (HUD complaint, Oak Park
  Apartments) — same theory; here Tim's role came in **discovery**, matching a produced list
  of ~2,000 actual applicants against eviction records to test disparate impact inside the
  real applicant pool.

🎤 "Methods beat, because you now know enough to see it: Wasatch and Hunter plead with
population-level disparities — who gets filed against, countywide. Oak Park tests the same
question inside the landlord's actual applicant pool. Population statistics make the case;
within-pool analysis tests the policy where it operates. You know both moves from lab."

### S14 — The ripple, and the public record **NEW**
- The theory spread past the cases: ***Byrd v. JWB Property Management*** (M.D. Fla.) —
  motion to dismiss **denied June 3, 2024**, the first court to sustain the
  eviction-screening disparate-impact claim on the merits at the pleading stage; settled
  November 2024. ***Moore v. Mac Property Management*** (N.D. Ill., filed Dec 2024): the
  coalition returns with individual Black women tenants as plaintiffs.
- Legislation: Baltimore's good-cause ordinance (Council Bill 21-0031, enacted June 2021)
  and Maryland's just-cause bills (SB 504, 2023; HB 477, 2024). The campaign record carries
  the numbers: in Baltimore, Black women were evicted at **3.9x** the rate of white men;
  Black households at **3x** white households. (Memo flag, keep it honest: Tim's research is
  verified across the campaign record; a citation inside the CB 21-0031 legislative file
  itself has not been located — say "the campaign," not "the bill file.")
- The federal shelf: **U.S. Commission on Civil Rights** NY report (March 2022) cites his
  sworn testimony throughout, including that **73% of Black-headed renter households** live
  in moderate-to-high eviction-risk neighborhoods (HPRM); **GAO**-24-106637 (2024) cites the
  dissertation; **HUD Cityscape** 26(1) (2024) publishes the ERN method and notes it "helped
  pass several tenant protection policies"; and a **Washington Supreme Court** amicus
  (*Sangha v. Keen*, 2025) cites "Tim Thomas and Mia Schwinghammer, Washington State
  Eviction Filings (Oct. 10, 2024)."

🎤 "Two things to notice. First, the same statistic keeps doing the work — courtroom,
council, Congress-adjacent agencies, a state supreme court. Second: almost none of these
documents say my name. The complaint says 'an independent analysis.' If you need credit,
policy work will starve you. If you need the law to move, this is what moving looks like —
and your final project's report is exactly this kind of citable object."

---

## SECTION 5 — FOUR STATES, FOUR RULEBOOKS (8 min)

*(Patched 2026-07-30. CA + MN facts: adversarial deep-research run — 22 claims confirmed
3-0 against leginfo.legislature.ca.gov / revisor.mn.gov; IN + TX: dedicated verification
agents against enrolled acts, current code, court orders, and official legal-help sources.
Every cite carries bill number, year, and mid-2026 status. Guardrails close the section.)*

### S15 — The clock frame **NEW**
- Callback to S5: the HPRM uses each state's statutory eviction timeline as a predictor —
  the total statutory clock ranges tenfold, ≈5 days (Louisiana) to ≈53 (Massachusetts) ✅.
- Tonight's four, the pre-filing clock ✅:
  - **Texas:** 3 days' written notice to vacate — and the lease can make it *shorter* or
    longer (Prop. Code §24.005(a)).
  - **Indiana:** 10 days, pay-or-stay — paying in full within the window defeats the
    notice — but "unless the parties otherwise agreed": the lease can waive it down
    (IC §32-31-1-6).
  - **Minnesota:** 14 days' written pre-filing notice before any nonpayment filing, by
    statute since Jan 1, 2024 (Minn. Stat. §504B.321, subd. 1a).
  - **California:** [CONFIRM] the 3-day pay-or-quit (CCP §1161) is the commonly cited
    baseline but went *unverified* this build (SB 436, pending, would touch notice
    periods) — leave the CA clock cell off the slide or verify before Tuesday.

🎤 "Your address decides how long you have. In Texas the default is three days, and your
lease can take you below that. In Indiana you get ten, and paying in full stops it —
unless your lease signed that away. In Minnesota, since last year, the law adds fourteen
days before the courthouse door even opens. Same missed rent check, different clocks —
and the model you met earlier reads those clocks as data."

### S16 — The matrix **NEW** *(a 4-row grid: Prevent → In court → The record afterward →
After displacement; walk it state by state, California deepest)*

**CALIFORNIA — prevention plus masking:**
- Prevent ✅: **AB 1482, the Tenant Protection Act (2019)** — statewide rent cap of 5% +
  CPI or 10%, whichever is lower (Civ. Code §1947.12), and statewide **just cause** after
  12 months of occupancy (§1946.2). Not permanent: both **sunset January 1, 2030**;
  AB 1157 (2025–26), which would have tightened the cap and removed the sunset, failed in
  committee January 2026. Coverage caveat for honesty: newer construction (15-year rolling
  window), most non-corporate single-family homes, and owner-occupied duplexes are exempt.
- The record ✅: **CCP §1161.2** — eviction records are **born masked**: the clerk gives
  the general public access only if the landlord wins against all defendants within 60
  days of filing (narrow court-ordered and post-trial routes exist). The arc: SB 345
  (2003) masked cases 60 days, then public unless the tenant had won → **AB 2819 (2016)
  flipped the default** → the COVID carve-out (§1161.2(a)(1)(G)(ii)) keeps nonpayment
  cases filed Mar 4, 2020 – Sep 30, 2021 masked *permanently, regardless of outcome* →
  AB 2304 (2024, eff. Jan 1, 2025) extends masking to mobilehome-park cases.
- After displacement ✅: no-fault just-cause terminations require **relocation assistance
  equal to one month's rent** (or a final-month rent waiver), due within 15 calendar days,
  or the termination notice is void (§1946.2(d)(3)(A)).

**MINNESOTA — the record-erasing state:**
- Prevent ✅: the **14-day pre-filing notice** (§504B.321 subd. 1a; Laws 2023, ch. 52,
  art. 19, §105, eff. Jan 1, 2024) is self-enforcing — file without it and the court
  "shall dismiss ... and grant an expungement of the eviction case court file"
  (subd. 1(d)).
- In court ✅: one of five states with statewide eviction **right to counsel** on NCCRC's
  national list (July 2026 edition; the others: WA, MD, CT, and NE in limited form).
- The record ✅: **motionless mandatory expungement** — the court "shall, without motion
  by any party," expunge when the tenant prevails on the merits or the case is dismissed
  *for any reason* (§484.014 subd. 3(a); Laws 2023 ch. 52 art. 19 §§117–118, refined by
  Laws 2024 ch. 118).
- 🚫 Do NOT teach "MN records auto-expunge after three years" — refuted 0–3 in
  verification. The clause exists in the statute text but its operation is contested (a
  reported Feb 2026 Court of Appeals case, *Weidner v. B.F.*, is itself unverified).
  Stick to the tenant-prevails / dismissal rules above.

**INDIANA — the preemption state (your lab-4 state):**
- Prevent, locally illegal ✅: **IC §32-31-1-20** preempts local rent regulation
  (subsec. b) and — since **SEA 148 (2020)**, vetoed by the governor and overridden
  Feb 2021 — local regulation of tenant screening, deposits, lease terms, and landlord
  fees (subsec. c): any such ordinance is "void and unenforceable."
- In court ✅: no statewide just cause (Urban Institute survey); no right to counsel
  (Indiana appears zero times in NCCRC's July 2026 national document). But the **Indiana
  Supreme Court's Pre-Eviction Diversion Program** (order 21S-MS-422, eff. Nov 1, 2021;
  expanded 2022; still operating per in.gov/courts) gives consenting parties a 90-day
  stay with the court records made confidential.
- The record ✅ — the big recent move: **HEA 1214 (2022)** created sealing (IC ch.
  32-31-11, eff. July 1, 2022) — mandatory on the tenant's motion where the case was
  dismissed, the tenant won, or the judgment was overturned. **SEA 142 (2025, eff.
  July 1, 2025)** made that **automatic** ("on its own motion ... without holding an
  additional hearing") and extended mandatory-on-motion sealing to satisfied money
  judgments and 7-year-old possession-only judgments; a sealed judgment no longer creates
  a real-estate lien. Held mandatory by the Court of Appeals, *Anderson v. Advantix*
  (Mar. 6, 2026).
- Lab tie-in: the `d5` file covers 2016 – Oct 2022 — **Indiana's record rules changed
  twice after the data window ends.** What a 2016 filing means for a tenant's future is
  different in 2026 than the day it was filed.

**TEXAS — the open-record state:**
- Prevent, preempted ✅: local rent control only under a declared disaster housing
  emergency **with the governor's approval** (Local Gov't Code §214.902, 1987); local
  voucher source-of-income protections barred for cities and counties (§250.007, 2015;
  veteran exception).
- In court ✅: no just cause — "Either the landlord or tenant may terminate a lease at
  the end of the term without any reason" (TexasLawHelp) — and no statewide right to
  counsel (the only eviction-specific provision is discretionary appeal-stage appointment,
  Gov't Code §25.0020, per the State Law Library). After filing, the clock sprints: trial
  10–21 days from filing (TRCP 510.8); **S.B. 38 (2025, eff. Jan 1, 2026)** added summary
  disposition without trial with a 4-day response window (TRCP 510.10); 5 days to appeal
  (510.19(a)); writ of possession from the 6th day after judgment (510.18(g)(1)).
- The record ✅: "Texas does not have a process to remove or seal an eviction from your
  record" (Texas State Law Library). The single exception is closed: the **Texas Eviction
  Diversion Program**, created by the Texas Supreme Court's Twenty-Seventh Emergency Order
  (Sept. 25, 2020) — both parties opt in → 60-day abatement with records confidential;
  if dismissed, confidential forever. Ended **June 30, 2023** (TDHCA); 25,000+ households,
  $243M+ in assistance; those records stay sealed. No successor program.
- After displacement ✅: the Homeless Housing and Services Program (Gov't Code §2306.2585,
  2011) funds homeless housing and prevention in nine large cities (~$6.2M contracted for
  2025–26).

🎤 "Now put Section 4 back on. The screening industry reads eviction records — that's
Nikita Smith's story. So ask each state: what happens to the record? California: born
masked — in the main, the public only sees it if the landlord wins within sixty days.
Minnesota: if you win, or the case is dismissed, the record dies automatically. No motion,
no lawyer, no fee. Indiana — your data state — since last July, dismissal wipes it
automatically, and even a lost case can be sealed on request once the money judgment is
satisfied, or after seven years if there wasn't one. Texas: the record is public, forever.
There is no sealing law. The one pile of sealed Texas eviction records in existence is the
twenty-five thousand households from the pandemic diversion program. Four states, four
answers to the same question: does one bad month follow you for life?"

### S17 — Minnesota vs Indiana, test it yourself
- The chart students saw Jul 14 ✅ᵇ (2025 W2 deck p.57): Minnesota (strong protections) vs
  Indiana (few; neighborhoods above 50%, some 80%+ filing rates).
- Now they know *which* protections sit behind that chart (S16) — and the course repo
  ships the data to test it: statewide **`mn_tract_evictions`** (2017–2025, 1,505 tracts)
  alongside the Indiana files ✅ (built 2026-07-23, `data/evictions/`).
- The measurement punchline ✅ (data README, note 2): Minnesota's expungement statute
  *reshapes the data itself* — the MN feed reflects the court's tally after expungements,
  so absolute MN counts read conservative; **disparity ratios are unaffected.**

🎤 "One last twist that makes this a methods course: Minnesota's expungement law doesn't
just protect tenants — it edits the dataset. Expunged cases leave the public feed. So when
your final project compares Minnesota to Indiana, the law itself is part of your
measurement story. Policy isn't just the thing you study; it decides what you can see.
If your group wants this comparison, the data is already in the repo."

**§5 guardrails (do not slide without a fresh check):** California's baseline 3-day
notice (CCP §1161) and the current status of CA emergency rental assistance, right to
counsel, and source-of-income law went unverified this build (SB 436 pending on notice
periods). The MN three-year auto-expungement is refuted-as-taught (above). Indiana's
exact veto date (March 2020) is news-sourced only — say "spring 2020." TX Gov't Code
§25.0020 is cited via the State Law Library; statute text not fetched. For CCP §1161.2
use the scoped phrasing above — a looser "landlord doesn't win in 60 days = sealed
forever" version was refuted because non-clerk access routes exist.

---

## SECTION 6 — AFTER DISPLACEMENT, HARD AND SOFT (8 min)

### S18 — Hard displacement's bill **NEW**
- **Collinson, Humphries, Mader, Reed, Tannenbaum & van Dijk (2024)** ✅, *QJE* 139(1):
  57–120 — the causal design (random judge assignment, Cook County + NYC): an eviction
  order raises emergency-shelter use by **3.4 percentage points** in year one, against a
  0.9% non-evicted base; homelessness-services use in year two rises **+200%** — and the
  effect concentrates among **women (+467%)** and **Black tenants (+307%)**. Earnings fall
  **7%** in year one, **14%** in year two. In NYC, hospital visits rise **29%**,
  mental-health visits more than double. Credit scores drop 16.5 points.
- **Desmond & Kimbro (2015)** ✅, *Social Forces* 94(1): 295–324 — 2,676 renting mothers,
  20 cities: eviction means about **one standard deviation more material hardship**;
  depression roughly **doubles (.47 vs .26)**; both still elevated **two-plus years later**.
- **Graetz, Gershenson, Porter, Sandler, Lemmerman & Desmond (2024)** ✅, *Social Science &
  Medicine* 340: 116398 — 6.6M renters linked to 38M eviction records: an eviction **filing**
  without judgment is associated with **19% higher mortality**; a **judgment**, **40%**;
  even a 70% rent burden (vs 30%) associates with 12% higher mortality. (Associational
  design; Collinson is the causal one — say which is which.)

🎤 "The writ is not the end of the story; it's the start of a different one. Shelter,
earnings, hospitals, credit, and at the far end, mortality. The court event is one day.
The bill runs for years."

### S19 — The gender the title promises *(reuse the seed's HPRM-5 spec)*
- **Zapata et al. (2025)** ✅ᵇ (seed, verified 2026-07-07), *IJERPH* 22(8): 1212 — 1,085
  Texas renters, HPRM as the sampling frame: a nonpayment violation associated with about
  **2.5x the odds of intimate partner violence** (AOR 2.50, CI 2.29–2.73; cross-sectional;
  Tim co-author).
- Tie the thread: Collinson's homelessness effect concentrates among women; Wasatch,
  Hunter, and Baltimore all peak for Black women. The course title's "gender" is not
  decoration; it is the through-line of tonight's numbers.

🎤 (seed's close, keep) "Notice the method: we used the precarity model itself to find
renters the courthouse never sees. Measurement isn't bookkeeping; it decides who becomes
visible — and what gets fixed."

### S20 — Soft displacement's bill **NEW**
- **Marcuse (1985)** ✅, *Washington University Journal of Urban and Contemporary Law* 28:
  195–240 — the four forms, his words (p. 208): "direct last-resident displacement, direct
  chain displacement, exclusionary displacement, and displacement pressure." (Bates
  describes these but never uses the labels — attribute to Marcuse, not to her ✅.)
- **Ding, Hwang & Divringi (2016)** ✅, *Regional Science & Urban Economics* 61: 38–51 —
  Philadelphia: vulnerable residents leaving gentrifying tracts are **2.4 to 4.8 points
  more likely to land in lower-income neighborhoods** than similar movers elsewhere. The
  companion (**Ding & Hwang**, *Cityscape* 18(3), 2016 ✅): stayers' credit scores *rise*
  (+11.3, +22.6 under intense gentrification); movers who slide down-market lose ground —
  "their financial health would have been better off if they were able to remain."
- **Bates (2013)** ✅ p. 20: Albina's displaced families landed in outer East Portland —
  "crowding in schools and overburdened infrastructure," and on p. 57, "residential
  instability (and even hypermobility)." (If time, p. 13: the church vans that now drive
  50 miles to collect the displaced congregation.)
- One-sentence nuance beat, because it's true: Collinson finds evicted tenants in
  Chicago/NYC don't measurably move to *higher-poverty* tracts, while Philadelphia's
  gentrification movers do slide down-market. Different populations, different designs,
  both verified — measurement over vibes.
- Callback: the Jul 14 mobility curve. Soft displacement is the market choosing for you;
  what it chooses is usually a poorer neighborhood, farther out.

---

## SECTION 7 — BATES' TOOLKIT AND YOUR PROJECT (6 min)
*(Reading due today. Reuse 2025 W3 deck pp.45–48 ✅ᵇ where they match; refresh numbers to
the page-verified ones below.)*

### S21 — Bates: right tool, right stage
- The Portland study ✅ (Bates 2013, City of Portland Bureau of Planning and Sustainability,
  updated 05/18/13): six neighborhood types — **Susceptible, Early Type 1, Early Type 2,
  Dynamic, Late, Continued Loss** — collapsed to **Early / Mid / Late** (pp. 29–31, 76).
- Vulnerability score, 0–4, one point each (p. 59): renters >44.2%; communities of color
  >26.7%; no bachelor's degree >58.2%; households ≤80% MFI >47.0%. Vulnerable = 3 of 4.
  (Your Assignment 2 measures are cousins of exactly this.)
- The timing sentence 📎 ✅ (p. 22): "It is far easier to avoid the harmful effects of these
  changes than to mitigate them once they are underway; and far easier to mitigate them at
  an early stage than to shoehorn in solutions later in the process."
- The strategy (p. 5): "match the tool(s) to specific stages of gentrification and the type
  of public investment that is being made."

🎤 "Bates is the four P's with a targeting system. The typology tells you *which*
neighborhoods get *which* tools *when* — before the visible gentrification, not after. Same
logic as the HPRM's two channels: diagnosis before treatment."

### S22 — The toolkit, fast **NEW or refresh W3-25 p.48**
- Her five key elements (p. 6): a broad **community impacts policy** · **Community Impact
  Reports** for major projects · **Community Benefits Agreements** · **Inclusionary
  Zoning** · **Education and Technical Assistance**.
- The Late-stage tool students should know exists (pp. 77, 85): a **replacement ordinance
  plus "right to return"** — new affordable housing gives admissions preference to the
  displaced. Real example on p. 85: Hamtramck, Michigan, won by Black former residents'
  class action, priority running to children and grandchildren of the displaced. (Also the
  One Hill CBA in Pittsburgh, p. 49.)
- The tie to Section 5, from her p. 9 and p. 51: as of 2013, Oregon was "one of only two
  states (along with Texas)" preempting mandatory inclusionary zoning (ORS 197.309). 🚫
  Don't add "Oregon later lifted its ban" on a slide — true-sounding but not verified this
  build.

### S23 — Your turn **NEW**
- Final project = a small December 13: complex story → simple telling → a stakeholder who
  can act. Syllabus promise: an analysis "that may interest governmental stakeholders";
  **bonus points** for well-supported policy recommendations — tonight was the toolkit.
- The pitch your group drafts at 6:00 (template in Appendix B): area (2+ counties or a
  region) · question · two hypotheses (start from your A2s, due yesterday) · 3–5 data
  points/plots · datasets · one policy hook — *which P does your finding argue for?*
- Get Tim's sign-off before you leave.

🎤 close: "Week 1 promised we'd end at what helps. Here's the honest version of the answer:
what helps is known — assistance, counsel, protections, homes. What's scarce is proof
someone in the room can't ignore, in language they can't misread. That's the skill you're
practicing. Go form your groups; build me something a senator would underline."

---

## APPENDIX A — Verified citation bank (build of 2026-07-30)

**Fetched/read this build (✅):**

- ERN Washington profile (figures, levers, statutes, WA stats; "Updated July 13, 2026"):
  <https://evictionresearch.net/washington/>
- HPRM public methods explainer: <https://evictionresearch.net/hprm/> · internal methods:
  hprm repo `manuscripts/journal_article/paper1/HPRM_manuscript_v3.md` (working draft — quote
  facts, don't cite as published) and `code/o1_create_hprm_2019.R` (score construction);
  time-to-evict range at manuscript §4 ("tenfold range from Louisiana (5 days total) to
  Massachusetts (53)").
- TVW hearing page + metadata (title "Senate Housing"; date 2024-12-13T10:30; work-session
  agenda): <https://tvw.org/video/senate-housing-2024121118/> and
  `tvw.org/wp-json/wp/v2/invintus_video/70221`. Press corroboration (quotes S8):
  Washington State Standard via Yakima Herald, "Evictions around Washington soar to record
  high levels," Dec 17, 2024:
  <https://www.yakimaherald.com/news/northwest/evictions-around-washington-soar-to-record-high-levels/article_2f5f35ae-bca8-11ef-a028-a35dfbdcad62.html>.
  CV entry (2025 listing): <https://timathomas.github.io/thomas_cv/thomas_cv.pdf> p. 4.
- Chapple sequencing quote: Merrefield, C., "Preventing housing displacement: What works and
  where more research is needed," The Journalist's Resource, May 2, 2023:
  <https://journalistsresource.org/economics/displacement-policy-what-works/>
- Bates, L. K. (2013). *Gentrification and Displacement Study: implementing an equitable
  inclusive development strategy in the context of gentrification.* City of Portland Bureau
  of Planning and Sustainability. Read in full (95 pp.):
  <https://www.portland.gov/sites/default/files/2020-01/2-gentrification-and-displacement-study-05.18.13.pdf>
  (typology pp. 29–31; vulnerability p. 59; toolkit pp. 6, 76–92; timing p. 22; Albina
  p. 20; right to return p. 85; IZ preemption pp. 9, 51).
- Desmond, M., & Kimbro, R. T. (2015). Eviction's Fallout: Housing, Hardship, and Health.
  *Social Forces* 94(1), 295–324. doi:10.1093/sf/sov044 (findings pp. 310–313).
- Collinson, R., Humphries, J. E., Mader, N., Reed, D., Tannenbaum, D., & van Dijk, W.
  (2024). Eviction and Poverty in American Cities. *Quarterly Journal of Economics* 139(1),
  57–120. doi:10.1093/qje/qjad042 (findings pp. 96–110).
- Marcuse, P. (1985). Gentrification, Abandonment, and Displacement: Connections, Causes,
  and Policy Responses in New York City. *Washington University Journal of Urban and
  Contemporary Law* 28, 195–240 (typology pp. 204–208; summary sentence p. 208):
  <https://openscholarship.wustl.edu/law_urbanlaw/vol28/iss1/4/>
- Ding, L., Hwang, J., & Divringi, E. (2016). Gentrification and residential mobility in
  Philadelphia. *Regional Science and Urban Economics* 61, 38–51.
  doi:10.1016/j.regsciurbeco.2016.09.004 (magnitudes §5.2–5.3, PMC version). Companion:
  Ding, L., & Hwang, J. (2016). The Consequences of Gentrification: A Focus on Residents'
  Financial Health in Philadelphia. *Cityscape* 18(3), 27–55 (pp. 28–29):
  <https://www.huduser.gov/portal/periodicals/cityscpe/vol18num3/ch2.pdf>
- Graetz, N., Gershenson, C., Porter, S. R., Sandler, D. H., Lemmerman, E., & Desmond, M.
  (2024). The impacts of rent burden and eviction on mortality in the United States,
  2000–2019. *Social Science & Medicine* 340, 116398. doi:10.1016/j.socscimed.2023.116398
  (PMID 38007965; abstract effect sizes).
- ERN legal-impact memo (all §4 facts + honesty flags): library repo
  `legal_impact/README.md`, "Eviction disparate-impact data in litigation and policy,"
  compiled July 2026.
- Eviction Data Atlas (S4 counts): library repo `data/eviction_data_atlas/README.md`
  (July 17, 2026 sweep; 6 case-level statewide / 36 counts / 3 local-only). Public page
  404 as of 2026-07-30.

**Four-state policy bank (§5, patched 2026-07-30):**

- **CA** (deep-research run, 22 claims confirmed 3-0): AB 1482 (Ch. 597, Stats. 2019) —
  chaptered text + current Civ. Code §§1946.2, 1947.12 at leginfo.legislature.ca.gov;
  sf.gov AB 1482 explainer; CCP §1161.2 masking regime — AB 2819 (Ch. 336, Stats. 2016)
  Assembly Judiciary analysis, AB 2304 (Ch. 711, Stats. 2024) Senate Judiciary analysis
  (sjud.senate.ca.gov), current code text. Sunset + AB 1157 failure: verifier
  cross-checks on leginfo.
- **MN** (same run): Minn. Stat. §504B.321 subds. 1a, 1(d) and §484.014 subd. 3(a) at
  revisor.mn.gov (history lines: Laws 2023 ch. 52 art. 19 §§105, 117–118; ch. 63 art. 6
  §54; Laws 2024 ch. 118); MN Judicial Branch libguide (updated Jul 14, 2026); HOME Line
  session-law reproduction. RTC: NCCRC, "Enacted Eviction Right to Counsel and Eviction
  Defense Programs" (July 2026 PDF, civilrighttocounsel.org).
- **IN** (verification agent, 2026-07-30): IC §32-31-1-6 and §32-31-1-20 (FindLaw code
  current as of Jan 1, 2026, cross-checked against iga.in.gov enrolled acts SB0148
  2020 / HB1541 2021); HEA 1214 (2022) = P.L.164-2022 (enrolled act + courts.in.gov
  legislative update); SEA 142 (2025) = P.L.128-2025 (enrolled act; eff. Jul 1, 2025);
  *Anderson v. Advantix Development Corp.*, No. 25A-EV-1738 (Ind. Ct. App. Mar. 6, 2026),
  public.courts.in.gov; diversion orders 21S-MS-422 (2021) + 22S-MS-308 (2022) at
  in.gov/courts, program current per in.gov/courts/housing; absences: Urban Institute
  just-cause page, NCCRC July 2026 (zero IN mentions).
- **TX** (verification agent, 2026-07-30): Prop. Code §24.005 (as amended by S.B. 38,
  ch. 960, 2025, eff. Jan 1, 2026) and Gov't Code §2306.2585 via the Legislative
  Council's file server behind statutes.capitol.texas.gov; TRCP 510.8 / 510.10 /
  510.18(g)(1) / 510.19(a) (July 1, 2026 compilation, txcourts.gov); Local Gov't Code
  §§214.902, 250.007; Twenty-Seventh Emergency Order, Misc. Docket No. 20-9113
  (Sept. 25, 2020, txcourts.gov PDF); TDHCA TEDP overview (Jan. 31, 2024: ran through
  June 30, 2023; 25,000+ households, $243M+) + tdhca.state.tx.us program page; Texas
  State Law Library FAQ "Eviction Record Removal"; TexasLawHelp "Myths of Renting in
  Texas" + "Impact of Eviction on Credit and Future Housing." Note: TRCP eviction rules
  were renumbered in the current compilation (old 510.4 content now in 510.8) — cite the
  new numbers.

**Carried from earlier verified banks (✅ᵇ, date shown):**

- HPRM two-crises shares (2.1% / 7.0% / 6.7%), 0–8 score, 64,028 tracts, 2019 vintage —
  2026-07-07 bank (re-confirmed against manuscript this build).
- Right-to-counsel outcome trio (81% / 56% / >40% defaults) — 2026 W1 deck p.20, verified
  2026-07-07; shown in class Jul 7.
- MN-vs-IN protections chart — 2025 W2 deck p.57, verified for the Jul 14 lecture.
- Moratoria natural-experiment chart — 2025 W2 deck p.56, same bank.
- Zapata, J., et al. (2025), *IJERPH* 22(8):1212 (AOR 2.50, CI 2.29–2.73) — seed §6,
  verified 2026-07-07.
- Testimony starts at 40:00 — course site (`index.qmd`), carried from 2025-era setup.
- Bates slides exist at 2025 W3 deck pp.45–48; UDP typology p.49 — seed §1 table.

## APPENDIX B — Hour 2 run-of-show (6:00–7:00, project groups)

| Time | Beat |
|---|---|
| 6:00–6:05 | Logistics: randomly assigned groups of 2–3 (Zoom breakout auto-assign); each room names a note-taker; template dropped in chat |
| 6:05–6:30 | Breakout drafting with the pitch template; Tim circulates rooms |
| 6:30–6:50 | Reconvene; each group pitches 2–3 min; live feedback |
| 6:50–7:00 | Sign-offs from Tim; unresolved groups schedule follow-up; remind Thursday lab + Week 6 dates |

**Pitch template (mirror of the `index.qmd` bullets + syllabus requirements):**

1. Area: at least two counties or a region — whose A2 area are you adopting, or which new one?
2. Research question (draft from the A2s in the room)
3. Two hypotheses about disparate impact (who is hit hardest, and why there?)
4. 3–5 data points/plots you'll build
5. Datasets: ACS via tidycensus; Indiana `d5_case_aggregated`; statewide `mn_tract_evictions`
   (2017–2025); Indiana LSC update files
6. Policy hook: which of the four P's would your finding argue for, and to whom?

Groups leave with: a named area, a question, owners for each data element, and Tim's sign-off.

## APPENDIX C — Build checklist and open items

**Slides to build NEW:** S2–S5, S8, S11–S16, S20, S22–S23 (§5 patch landed 2026-07-30 —
S15/S16 are fully specified above).
**Reuse/adapt:** S1 (title template), S6 (testimony-deck opener or new), S9–S10 (Figure 5
graphic from the WA page + numbered-list builds), S17 (2025 W2 p.57 chart + the
expungement-measurement line), S18–S19 (S19 from seed HPRM-5 spec), S21 (2025 W3
pp.45–48, refresh numbers to the page-verified ones in S21).

**Assets to pull before Tuesday:**
- Figure 5 image from <https://evictionresearch.net/washington/> (screenshot or SVG grab)
- TVW recording cued to 40:00; deck link open in a tab
- MN-vs-IN chart (2025 W2 p.57); moratoria chart (p.56) if wanted as an S11 aside
- Bates typology map (report p. 32, or the 2025 W3 slides)
- HPRM map link for the optional S5 live beat

**Open [CONFIRM]s for Tim:**
1. Video end cue (suggest ≈45:00–46:00; nothing verified about segment length — runtime not
   published on the TVW page).
2. Deploy the eviction-data-atlas page before linking it to students (404 as of 2026-07-30);
   until then S4 stays URL-less.
3. Site inconsistency found during alignment: `index.qmd` Week 5 Thursday (Aug 6) bullet says
   the **bonus memory lab (lab 6)** while the Week 5 reading note ("for Thursday's
   segregation lab") and the syllabus week table both say **segregation/rent-burden lab
   (lab 5)**. Decide which runs Aug 6 and I'll align both files.
4. Slide-count guidance differs: syllabus final project says "no longer than 10 slides";
   `index.qmd` Week 6 says "No more than 15 slides and aim for 5." Unify?
5. Optional flex slide (cut by default): HPRM "your backyard" — Richmond's 13 max-score
   tracts is verified ✅ᵇ (model count; book draft's "15" is wrong), but the Bay Area
   "~91% of Black renters" map vintage is still unconfirmed 🚫 — don't use until vintage
   is pinned.
6. CA clock cell (S15): verify the CCP §1161 3-day pay-or-quit (and check SB 436's
   status) if you want California on the clock slide; otherwise it stays off, and
   California's story runs through prevention + records only.

**Deliberately cut from the seed:** HPRM-1 scale-ladder slide (its job is done by S3+S5);
HPRM-3 demographic table (S11 keeps only the three headline shares); the Zuk et al. and
Baltimore case-study beats (Zuk stays an optional site reading; Baltimore's facts moved
into S14); the "survey Bates now, depth later" question (moot — this IS the Aug 4 session,
so Bates gets its depth here, §7).
