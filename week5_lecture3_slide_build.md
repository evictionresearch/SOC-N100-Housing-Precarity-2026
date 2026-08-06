# Week 5 Lecture — Slide Build Sheet

**Deck:** "20260804 SOC N100 Week 5 Solutions"
`https://docs.google.com/presentation/d/1azi-T_PJZ5NAC_xHtQoBwCmg1apfhcS--7MhoVHMORw/`

Companion to `week5_lecture3_solutions_2026.md` (the spec, with sourcing). This file is the
build sheet: what goes ON each slide, stripped of verification markers, in paste order.

**ON SLIDE** = the text students see. **SAY** = your narration, not on the slide.
**BUILD NOTE** = layout or asset instruction.

**Three slides can be edited from Week 2 rather than built from scratch:** the title, the
MN-vs-IN chart slide (becomes slide 20), and the WA eviction-crisis slide (becomes slide 11, numbers
need replacing). Everything else here is new.

One gotcha from reading the old deck: nearly every slide in it carries a stale speaker note
("At the individual and household level, evictions occur at the intersection of increasing
rent..."). It travels with any slide you reuse. Clear the notes field on the three you keep.

---
## THE DECK, AS BUILT

Slides 1–5 are done in the deck and recorded below as built, not as originally specced.
Slide 6 onward is the work plan. Numbers here match the live deck.

| # | Slide | State |
|---|---|---|
| 1 | Title | built |
| 2 | Agenda | built |
| 3 | The Eviction Process | built |
| 4 | The Data Processing Pipeline | built |
| 5 | State Counts vs. Names & Addresses | built |
| 6 | Gap in eviction data (LSC coverage map) | built |
| 7 | Housing Precarity Risk Model | built |
| 8 | Testimony setup / video | **in progress** |
| 9+ | Testimony debrief through the project handoff | specced below |

**Timing.** Revisit once the deck is finished. The release valve is the video (play 4 minutes
instead of 6); after that, slide 20's data plug drops to one sentence and slide 16 merges
into slide 17. Do not cut slide 7, slide 11, or slide 26.

---

## SLIDES 1–5 — AS BUILT

### 1 — Title
"What actually helps: from eviction to eviction policy" · August 4, 2026 · Week 5.

⚠ Reads "from eviction to eviction policy." The spec line was "from eviction **data** to
eviction policy," and the missing word is the whole thesis of the hour. One-word fix.

### 2 — Agenda
Seven items, matching the sections below. Item 1 now reads "How Data Becomes Policy," which
is a better label than the spec's "The machine."

### 3 — The Eviction Process
Image slide, `output/eviction_process_exits.png`. Five stages, an exit under each, all
draining into DISPLACED; brackets mark where court records begin.

**SAY** "The sheriff at the door is stage five. You can lose your home at stage one, two or
three and the outcome is the same. And a court record only exists from stage four, so
everything left of that line is a real housing loss that leaves no filing behind. Filing data
is the tail of this process, not the whole thing. A floor, not a count."

### 4 — The Data Processing Pipeline
Now a branching slide rather than the spec's linear one, which is the better structure:

```
                        If there's name and address data
State counts:                    Demographics:
show count trends                show disparity
```

**SAY** "Two roads out of the same courthouse. If all you get is a state count, you can show
a trend line: filings going up, filings going down. If you get names and addresses, you can
geocode, estimate who lives there, and show *disparity*. Same crisis, two completely
different questions you're allowed to ask."

### 5 — State Counts vs. Names & Addresses  ·  Washington | Minnesota
The comparison that makes slide 4 concrete. Washington is the names-and-addresses side;
Minnesota is the counts side.

**SAY** "Minnesota gives us counts, so I can tell you filings are above the historical
average. I cannot tell you who. Washington we built ourselves, case by case, so I can tell
you Black women are filed against at five times the rate of white men. That difference is not
a difference in the crisis. It's a difference in the data."

---

## SLIDES 6–8 — THE GAP, THEN THE MODEL

### 6 — Gap in eviction data  ·  BUILT

**AS BUILT** Title "Gap in eviction data," pointing at LSC's own coverage map:
`https://civilcourtdata.lsc.gov/data/eviction`

**BUILD NOTE — screenshot it, don't present it live.** It's an external site on a Zoom share.
Grab the map image before class and keep the URL on the slide as the credit line.

⚠ **Their number and my number disagree, and it's their map on screen.** LSC's site copy
says the tracker covers "1,250 counties and municipalities in 30 states and territories."
Downloading their own `monthly_state_data_download.csv` on 2026-07-17 and listing unique
states returns **34 jurisdictions** (32 states plus Puerto Rico and the Virgin Islands). Their
site text looks stale. **Say "about 30 states, by their count" and you can't be contradicted
by your own slide.** Don't say 32 while their map says 30.

**IF A STUDENT ASKS HOW CURRENT IT IS** The tracker is stamped "Data last updated July 13,
2026," but the downloadable series end September 2025. Good example of a live dashboard
running ahead of its own downloadable data.

⚠ **Red does not mean "no data," and Washington is not covered.** You just spent two slides on
Washington. Say why out loud, because it *is* the argument:

**SAY**
> "This is the Legal Services Corporation's Civil Court Data Initiative, the single largest
> source of eviction filing data in the country. Thirty-two states. Now find Washington.
> It's red. So is California, so is Oregon. LSC doesn't reach them, which is exactly why
> somebody had to go get Washington by hand, four counties at a time, with the pipeline you
> just saw.
>
> Two problems, then. Where LSC does reach, you get counts, not names. Where it doesn't
> reach, you may get nothing at all. Either way you cannot answer the question that matters
> at the neighborhood level. So what do you do about the whole country?"

That last sentence is the handoff to slide 7.

**BACKUPS, if the LSC site is down or you want a cleaner cut.** All in `output/`, transparent,
from `course_infrastructure/make_s4_atlas_maps.R`:
- `s6_lsc_gap.png` — the same LSC point as a 51-tile grid, 32 covered / 19 not
- `s4_simple.png` — three buckets: address level (13), counts only (32), nothing published (6).
  Red here really does mean nothing, so it has less of the Washington ambiguity
- `s4_atlas_tile.png`, `s4_atlas_map.png` — the four-tier publishing view
- `s4_geography_available.png` — statewide vs local address coverage
- `s4_national_programs.png` — LSC / Eviction Lab / EDRN / ERN per state

**FACTS, if asked**
- LSC covers 32 states (34 jurisdictions counting PR and VI); county-level FIPS counts,
  weekly and monthly. Case-level only under a data-sharing agreement.
- Of 200 catalogued sources nationally, 14 carry addresses fully and 11 partially; **6
  publish defendant names.** 49 of the 200 are discontinued.
- Six states publish nothing currently: AL, AR, IA, KS, MT, SD. Of those, AL, IA and SD are
  dark from any source at all.

---

### 7 — Housing Precarity Risk Model  ·  BUILT
*(This answers the question a student asked on July 14. Do not cut it.)*

**AS BUILT** EDR 197 displacement predictors · net migration of low-income households ·
which census variables relate to those moves · EER 184 eviction predictors · 15 states of
court records train the model · what drives evictions at tract level · HPRM = sum score of
EDR and EER · evictionresearch.net/hprm. Footer still 2024.05.26.

🔴 **SAY THIS, IT IS NOT ON THE SLIDE — the eviction clock.** *"One more input, and it's the
strange one: how fast your state's eviction clock runs. The statutory timeline is itself a
predictor, and it ranges tenfold. About five days in Louisiana, fifty-three in
Massachusetts."* Slide 18 opens by calling back to this. Skip it and "your address decides
how long you have" arrives cold.

🔴 **ALSO SAY: the range.** The slide says "sum score" without the numbers. *"Each side scores
zero to four, so the total runs zero to eight, for 64,028 tracts."* The 0–8 range is what
makes the map colors legible later.

**SPEC COPY**, if you want to add either to the slide:
```
So model it.

WHAT GOES IN  (per census tract)
  • Who lives there — ACS: 197 predictors on the displacement side,
    184 on the eviction side
  • Where renters actually move — a national household panel, 5-year net
    migration of low-, very-low- and extremely-low-income renters
  • Where filings concentrate — court records from 15 states train the model
  • How fast the eviction clock runs — the statutory timeline is itself a
    predictor, and it ranges tenfold: ~5 days in Louisiana to ~53 in Massachusetts

WHAT COMES OUT
  • EDR — soft displacement: low-income renters draining out      scored 0–4
  • EER — hard displacement: filing rates above the state norm    scored 0–4
  • HPRM = EDR + EER                                              0–8, every tract

  64,028 tracts · 2019 vintage
  evictionresearch.net/hprm
```

**BUILD NOTE** Two columns, in on the left, out on the right. No equations. Slide 4 already
taught "estimate demographics," so you can move fast through the input side and spend the
time on the output side.

**SAY**
> "Fifteen states' worth of court records go in, and an estimate comes out for tracts all
> over the country, including the states that publish nothing. Two risks, soft and hard,
> each scored zero to four, added up. Zero to eight. Machine learning underneath, a sum a
> fifth-grader can check on top. Pie chart with a Bayesian chaser.
>
> And hold onto that eviction-clock number, because it's the door to the state comparison
> later tonight."

**OPTIONAL 2 min if ahead** Pull up the live map, score a student's county.

---

### 8 — Eviction Data WA  ·  BUILT, MOVE DOWN ONE

**It is currently sitting at position 7, where the HPRM goes.** Drag it below the HPRM slide.

Carries the OCR and NER method: court images → Tesseract → regex and spaCy → geocode →
estimate gender from first name, race from surname and tract. Footer dated 2024.05.26.

**WHY IT READS BETTER AFTER THE HPRM, NOT BEFORE** Slide 7 says: we model the whole country
because the data doesn't exist. This slide then says: and where we need the real thing, this
is what it costs. Nationally we estimate; locally we go get it by hand, one scanned court
image at a time. That contrast is the honest close to the section, and it lands harder after
the model than before it.

**SAY**
> "That's the national answer. Here's the local one. This is what it actually took to get
> Washington: pulling scanned court images, running character recognition over them, teaching
> a parser to find an address in the mess that comes out, geocoding it, then estimating who
> lived there from the name and the tract. Four counties. That's the price of the
> right-hand road on slide four."

⚠ **Verify before showing either way.** The slide says "Currently 2004-2017 have cases for
King, Snohomish, Pierce, and Whatcom" and is dated May 2024. I could not confirm the current
case-level coverage this session. The county-count feed on the WA profile runs January 2016
to April 2026, which is a different product from the case-level collection, so the two are
not in conflict — but the 2004–2017 window and the four-county list need your eyes.

---

### slide 9 — Washington, end to end  ·  NEW

**ON SLIDE**
```
Washington: the whole machine, end to end

  SB 5600 (2019)   pay-or-vacate notice: 3 days → 14 days
                   Sen. Patty Kuderer · Rep. Nicole Macri

  HB 1236 (2021)   statewide just cause
                   Macri

  SB 5160 (2021)   the nation's first statewide tenant right to counsel
                   Kuderer · run by the Office of Civil Legal Aid

UW eScience Institute, on the 2019 law:
"The Washington Evictions Research Project provided groundbreaking empirical evidence
for stakeholders and policymakers to use to get this legislation passed through the
house and senate."

The pipeline is a loop: OCLA and the King County Bar's Housing Justice Project supply
court records — ERN supplies the public analyses.
```

**SAY**
> "Washington is the place where the whole machine has run end to end. The UW eviction study
> fed the 14-day notice law in 2019, then just cause and the nation's first statewide right to
> counsel in 2021. And the exchange never stopped: they send records, we send analysis. So
> when the post-pandemic numbers turned ugly, the Senate Housing Committee asked for the state
> of things. December 2024. Let's watch."

---

### slide 10 — Play the video  ·  NEW

**ON SLIDE**
```
Senate Housing Committee, work session
Friday, December 13, 2024 · TVW

Agenda:
  "Housing cost and impact on supply and stability."
  "Right to counsel."
```

**BUILD NOTE**
- Put **December 13, 2024** on the slide. The TVW URL slug looks like a date and is not one.
- Cue the recording to **40:00** before class. Have it open in a tab, not embedded.
- Recording: `https://tvw.org/video/senate-housing-2024121118/`
- Your testimony deck:
  `https://docs.google.com/presentation/d/1x7SCdTeBdczY5Ga5wvixMxtvTv-a4rTph6LIQWLsIk0/`
- **DECIDE BEFORE 5PM:** where you stop. About 45:00–46:00 keeps the section on time. This is
  your release valve; play 4 minutes instead of 6 if you're running behind.

---

### slide 11 — What five minutes did  ·  REUSE inherited WA slide, replace the numbers

**ON SLIDE**
```
What those five minutes did

THE FORM
  One trend line. A handful of numbers. One map. Explicit asks.
  No jargon. No methods wall.

WHAT THE ROOM HEARD
  Tim Thomas: "The state is in an eviction crisis at this point."
  Chair Patty Kuderer: "The increase in eviction filings is startling and alarming...
  There will be a tsunami of homelessness if we don't handle this correctly."
                                    — Washington State Standard, December 17, 2024

WHERE IT STANDS NOW
  23,913 filings in the 12 months ending April 2026
  ~45% above the pre-pandemic norm
  21 of 39 counties set all-time records in 2024–25
  Hottest on the suburban edge:
      Clark 33.2  ·  Pierce 29.9  ·  statewide 21.5   filings per 1,000 renter households
```

**BUILD NOTE** The inherited slide's record-county lists (Clark, Grant, Jefferson...) are
2024-era. Delete them and paste the block above. Numbers are from the WA profile as updated
July 13, 2026.

⚠ **Two different 45%s tonight.** This one is Washington, *above* baseline. The one on slide 13 is
national, *below predicted*. Keep them on separate slides and say which is which.

**SAY**
> "Notice what those five minutes were: a complex story, told simply, with data underneath,
> and a chair who answered in headlines. The same senator who sponsored the 14-day notice and
> right to counsel is asking the researcher what comes next. That is the job. And it is also,
> precisely, your final project. The syllabus promises an analysis 'that may interest
> governmental stakeholders.' In Week 6 you'll each give a version of this. Steal the form."

---

### slide 12 — The four P's  ·  NEW, built around Figure 5

**ON SLIDE**
```
No single lever stops an eviction — it takes four.

Prevent the filing before it reaches court,
protect tenants once they're in it,
preserve the low-cost homes that already exist,
and produce more.
```

**BUILD NOTE** Drop in **Figure 5** from `https://evictionresearch.net/washington/`.
Screenshot it. Read the graphic aloud: the timeline runs Rent burden → Missed rent → Eviction
notice → Court filing → Judgment & writ → Displacement. Tiers mark documented effect, T1
largest and fastest through T3 structural and slow. A red line marked **STRONGEST TOGETHER**
connects rental assistance to right to counsel.

**SAY** Credit line, worth saying out loud:
> "The last three are the Urban Displacement Project's anti-displacement framework, Cash and
> Zuk. Prevent, placed first, is mine. That's what my research adds to their frame."

---

### slide 13 — Five levers, one build each  ·  NEW

**BUILD NOTE** This is dense. Consider five build-ins on one slide, or five light slides.
Five light slides is faster to make and easier to read.

**ON SLIDE**
```
1. RENTAL ASSISTANCE, PAID TO THE LANDLORD                          Tier 1
   ERA plus the moratoria coincided with roughly 673,000 fewer filings across studied
   counties (about 45% below what pre-pandemic trends would have predicted).
   ERA recipients: about 65% lower odds of street homelessness.        Aiken & Reina, 2022

2. EVICTION DIVERSION AND PRE-FILING MEDIATION                      Tier 1
   Washington ran one and let it expire. The Eviction Resolution Pilot Program
   (RCW 59.18.660, statewide from November 2021) required mediation before a nonpayment
   case could be heard. State evaluation: 78% settlement rate. Ended July 1, 2023.
   The ask: bring it back.

3. RIGHT TO COUNSEL                                                 Tier 1
   SB 5160 (2021), RCW 59.18.640 — first state in the nation, OCLA-administered.
   A 2025 UW study finds it still reaches fewer than half of eligible tenants.

4. STANDING PROTECTIONS                                             Tier 2
   Just cause (RCW 59.18.650)
   Source-of-income protection (RCW 59.18.255) — roughly halves landlord voucher-denial
       rates (Cunningham et al., 2018)
   New in 2025: statewide rent stabilization (HB 1217), annual increases capped at
       7% + CPI, 10% maximum

5. BUILD AND PRESERVE HOMES BELOW MARKET                            Tier 3, the long game
   Washington needs about 1.1 million more homes by 2044, the largest share for its
   lowest-income households.                                   WA Dept. of Commerce
   Today: only 28 affordable, available homes for every 100 of the state's
   lowest-income renters.                                      NLIHC, The Gap
```

**SAY on #3** Callback, don't re-teach. They saw this July 7: 81% of represented tenants
secured permanent housing, 56% stayed in the same home, default rates still above 40%.

---

### slide 14 — Why it takes all four  ·  NEW

**ON SLIDE**
```
Why it takes all four

"Prevent and Protect interrupt the eviction;
 Preserve and Produce ease the rent pressure that starts it."

THE TWO CRISES MOSTLY LIVE IN DIFFERENT NEIGHBORHOODS

     2.1%   of tracts are high on BOTH
     7.0%   displacement-dominant
     6.7%   eviction-dominant

Karen Chapple, on sequencing:
"What seems pretty clear is that you want to make sure you have your tenant protections
and housing preservation policies in place first and then do some building. We should
have learned that years ago from urban renewal programs."
                                        — The Journalist's Resource, May 2, 2023
```

**BUILD NOTE** The three percentages are the 2019 HPRM vintage, matching S5.

**SAY**
> "Prevent and Protect aim at the hard crisis, Preserve and Produce at the soft one. And the
> model says the two crises mostly live in different neighborhoods. Two percent of tracts have
> both at once. Build only housing and you miss one crisis entirely. Pass only court
> protections and you miss the other. That's why it's a set of four, in that order. Chapple's
> point: protections and preservation first, then build."

---

### slide 15 — Seattle, 2017: the first case  ·  NEW

**ON SLIDE**
```
Smith v. Wasatch Property Management
No. 2:17-cv-00501-RAJ (W.D. Wash.)

Nikita Smith, a Black woman, was blocked from even applying to a Renton complex over a
years-old eviction filing that had been resolved WITHOUT an eviction.

The ACLU called it the first case to challenge eviction-record screening under civil
rights law, and the first Fair Housing Act case built on an intersectional
race-and-sex theory.

THE DATA ANCHORING THE COMPLAINT
  In King County, Black tenants were roughly 4x more likely to have an eviction case
  filed against them than white tenants.
  Households headed by Black women: more than 5x the rate of households headed by
  white men.

Filed March 30, 2017 · settled October 2017
```

**SAY**
> "A blanket 'no eviction record' screen sounds neutral. But the filing data it reads is this
> biased, so the screen quietly reproduces the bias, forever, against people like Nikita Smith
> who were never even evicted. One statistic turned that from a story into a federal civil
> rights claim."

---

### slide 16 — Chicago, 2023: the theory travels  ·  NEW

**ON SLIDE**
```
Legal Aid Chicago v. Hunter Properties
No. 1:23-cv-04809 (N.D. Ill.)

Cook County Sheriff data, September 2010 – March 2023:
  Black renters       ~56% of people served or evicted by the Sheriff, vs 33% of renters
  Black women         ~33%, vs roughly 22%

The complaint calls it "an independent analysis."

WHERE IT STANDS, HONESTLY
  Dismissed September 2024 on organizational standing — NOT on the merits of the
  disparate-impact theory. Judgment vacated. Amended complaint filed. The second motion
  to dismiss had no ruling as of early 2026.

THE COMPANION
  HOPE Fair Housing Center v. Mastercare (HUD complaint, Oak Park Apartments) — same
  theory, but here the analysis ran in discovery: matching a produced list of ~2,000
  actual applicants against eviction records.
```

**SAY** Methods beat:
> "Wasatch and Hunter plead with population-level disparities, who gets filed against
> countywide. Oak Park tests the same question inside the landlord's actual applicant pool.
> Population statistics make the case; within-pool analysis tests the policy where it
> operates. You know both moves from lab."

---

### slide 17 — The ripple, and the public record  ·  NEW

**ON SLIDE**
```
The theory spread past the cases

COURTS
  Byrd v. JWB Property Management (M.D. Fla.) — motion to dismiss DENIED June 3, 2024.
  First court to sustain the eviction-screening disparate-impact claim on the merits at
  the pleading stage. Settled November 2024.
  Moore v. Mac Property Management (N.D. Ill., filed December 2024) — the coalition
  returns with individual Black women tenants as plaintiffs.

LEGISLATION
  Baltimore good-cause ordinance (Council Bill 21-0031, enacted June 2021)
  Maryland just-cause bills (SB 504, 2023; HB 477, 2024)
  The campaign record: in Baltimore, Black women were evicted at 3.9x the rate of
  white men; Black households at 3x white households.

THE FEDERAL SHELF
  U.S. Commission on Civil Rights, NY report (March 2022) — cites sworn testimony
      throughout, including that 73% of Black-headed renter households live in
      moderate-to-high eviction-risk neighborhoods
  GAO-24-106637 (2024) — cites the dissertation
  HUD Cityscape 26(1) (2024) — publishes the ERN method, notes it "helped pass several
      tenant protection policies"
  Washington Supreme Court amicus, Sangha v. Keen (2025)
```

**BUILD NOTE** On Baltimore say "the campaign," not "the bill file." A citation inside the
CB 21-0031 legislative file itself has not been located.

**SAY**
> "Two things to notice. First, the same statistic keeps doing the work: courtroom, council,
> Congress-adjacent agencies, a state supreme court. Second, almost none of these documents say
> my name. The complaint says 'an independent analysis.' If you need credit, policy work will
> starve you. If you need the law to move, this is what moving looks like. And your final
> project's report is exactly this kind of citable object."

---

### slide 18 — The clock frame  ·  NEW

**ON SLIDE**
```
Your address decides how long you have

The HPRM uses each state's statutory eviction timeline as a predictor.
The total clock ranges tenfold: ~5 days (Louisiana) to ~53 (Massachusetts).

TONIGHT'S FOUR — the pre-filing clock

  TEXAS         3 days' written notice to vacate — and the lease can make it
                SHORTER or longer                              Prop. Code §24.005(a)

  INDIANA       10 days, pay-or-stay — paying in full within the window defeats the
                notice — but "unless the parties otherwise agreed": the lease can
                waive it down                                  IC §32-31-1-6

  MINNESOTA     14 days' written pre-filing notice before any nonpayment filing,
                by statute since January 1, 2024      Minn. Stat. §504B.321 subd. 1a
```

**BUILD NOTE — DECIDE BEFORE 5PM** California is deliberately absent. The 3-day pay-or-quit
(CCP §1161) went unverified in the build and SB 436 is pending on notice periods. Either
verify it now or leave the CA row off and let California's story run through prevention and
records only on slide 19.

**SAY**
> "Your address decides how long you have. In Texas the default is three days, and your lease
> can take you below that. In Indiana you get ten, and paying in full stops it, unless your
> lease signed that away. In Minnesota, since last year, the law adds fourteen days before the
> courthouse door even opens. Same missed rent check, different clocks. And the model you met
> earlier reads those clocks as data."

---

### slide 19 — The matrix  ·  NEW

**BUILD NOTE** A 4-row grid: **Prevent · In court · The record afterward · After
displacement**, one column per state. California is deepest. If short on time, build it as
four state slides instead of one grid.

**ON SLIDE — CALIFORNIA: prevention plus masking**
```
PREVENT   AB 1482, Tenant Protection Act (2019)
          Statewide rent cap: 5% + CPI, or 10%, whichever is lower   Civ. Code §1947.12
          Statewide just cause after 12 months of occupancy          §1946.2
          Not permanent — both sunset January 1, 2030. AB 1157 (2025–26), which would
          have tightened the cap and removed the sunset, failed in committee January 2026.
          Exempt: newer construction (15-year rolling window), most non-corporate
          single-family homes, owner-occupied duplexes.

THE RECORD   CCP §1161.2 — eviction records are BORN MASKED.
          The clerk gives the general public access only if the landlord wins against all
          defendants within 60 days of filing. (Narrow court-ordered and post-trial
          routes exist.)
          The arc: SB 345 (2003) masked cases 60 days, then public unless the tenant had
          won → AB 2819 (2016) flipped the default → the COVID carve-out
          (§1161.2(a)(1)(G)(ii)) keeps nonpayment cases filed March 4, 2020 – September 30,
          2021 masked permanently, regardless of outcome → AB 2304 (2024, eff. January 1,
          2025) extends masking to mobilehome-park cases.

AFTER     No-fault just-cause terminations require relocation assistance equal to one
          month's rent, or a final-month rent waiver, due within 15 calendar days — or
          the termination notice is void.                        §1946.2(d)(3)(A)
```

**ON SLIDE — MINNESOTA: the record-erasing state**
```
PREVENT   The 14-day pre-filing notice (§504B.321 subd. 1a, eff. January 1, 2024) is
          self-enforcing. File without it and the court "shall dismiss ... and grant an
          expungement of the eviction case court file."

IN COURT  One of five states with statewide eviction right to counsel on NCCRC's
          national list. The others: WA, MD, CT, and NE in limited form.

THE RECORD   Motionless mandatory expungement. The court "shall, without motion by any
          party," expunge when the tenant prevails on the merits or the case is dismissed
          for any reason.                                        §484.014 subd. 3(a)
```

⚠ **Do NOT teach** "MN records auto-expunge after three years." It was refuted in
verification. The clause exists in the statute text but its operation is contested. Stick to
the tenant-prevails and dismissal rules.

**ON SLIDE — INDIANA: the preemption state (your lab-4 state)**
```
PREVENT, LOCALLY ILLEGAL
          IC §32-31-1-20 preempts local rent regulation, and — since SEA 148 (2020),
          vetoed by the governor and overridden February 2021 — local regulation of
          tenant screening, deposits, lease terms, and landlord fees. Any such
          ordinance is "void and unenforceable."

IN COURT  No statewide just cause. No right to counsel (Indiana appears zero times in
          NCCRC's July 2026 national document). But the Indiana Supreme Court's
          Pre-Eviction Diversion Program (order 21S-MS-422, eff. November 1, 2021,
          expanded 2022) gives consenting parties a 90-day stay with court records
          made confidential.

THE RECORD — the big recent move
          HEA 1214 (2022) created sealing (IC ch. 32-31-11, eff. July 1, 2022) —
          mandatory on the tenant's motion where the case was dismissed, the tenant won,
          or the judgment was overturned.
          SEA 142 (2025, eff. July 1, 2025) made that AUTOMATIC ("on its own motion ...
          without holding an additional hearing") and extended mandatory-on-motion
          sealing to satisfied money judgments and 7-year-old possession-only judgments.
          A sealed judgment no longer creates a real-estate lien.
          Held mandatory by the Court of Appeals, Anderson v. Advantix (March 6, 2026).

LAB TIE-IN   Your d5 file covers 2016 – October 2022. Indiana's record rules changed
          TWICE after the data window ends. What a 2016 filing means for a tenant's
          future is different in 2026 than the day it was filed.
```

**ON SLIDE — TEXAS: the open-record state**
```
PREVENT, PREEMPTED
          Local rent control only under a declared disaster housing emergency WITH the
          governor's approval (Local Gov't Code §214.902, 1987). Local voucher
          source-of-income protections barred for cities and counties (§250.007, 2015;
          veteran exception).

IN COURT  No just cause — "Either the landlord or tenant may terminate a lease at the end
          of the term without any reason." No statewide right to counsel.
          After filing, the clock sprints:
              trial 10–21 days from filing                        TRCP 510.8
              S.B. 38 (2025, eff. January 1, 2026) added summary disposition without
                  trial, 4-day response window                    TRCP 510.10
              5 days to appeal                                    510.19(a)
              writ of possession from the 6th day after judgment  510.18(g)(1)

THE RECORD   "Texas does not have a process to remove or seal an eviction from your
          record."                                        Texas State Law Library
          The single exception is closed: the Texas Eviction Diversion Program (Texas
          Supreme Court Twenty-Seventh Emergency Order, September 25, 2020) — both
          parties opt in, 60-day abatement, records confidential; if dismissed,
          confidential forever. Ended June 30, 2023. 25,000+ households, $243M+ in
          assistance. Those records stay sealed. No successor program.

AFTER     Homeless Housing and Services Program (Gov't Code §2306.2585, 2011) funds
          homeless housing and prevention in nine large cities (~$6.2M contracted
          for 2025–26).
```

**SAY** (the payoff, after the grid)
> "Now put Section 4 back on. The screening industry reads eviction records. That's Nikita
> Smith's story. So ask each state: what happens to the record? California, born masked; in
> the main, the public only sees it if the landlord wins within sixty days. Minnesota: if you
> win, or the case is dismissed, the record dies automatically. No motion, no lawyer, no fee.
> Indiana, your data state: since last July, dismissal wipes it automatically, and even a lost
> case can be sealed on request once the money judgment is satisfied, or after seven years if
> there wasn't one. Texas: the record is public, forever. There is no sealing law. The one
> pile of sealed Texas eviction records in existence is the twenty-five thousand households
> from the pandemic diversion program. Four states, four answers to the same question: does
> one bad month follow you for life?"

---

### slide 20 — Minnesota vs Indiana, test it yourself  ·  REUSE inherited MN/IN slide

**ON SLIDE** (add to the existing chart)
```
You saw this July 14. Now you know WHICH protections sit behind it.

And the repo ships the data to test it:
    mn_tract_evictions   statewide, 2017–2025, 1,505 tracts
    Indiana d5 files

THE MEASUREMENT PUNCHLINE
Minnesota's expungement statute reshapes the data itself. The MN feed reflects the
court's tally AFTER expungements, so absolute MN counts read conservative.
Disparity ratios are unaffected.
```

**BUILD NOTE** The inherited slide already carries the chart and the two captions
("Minnesota: strong protections but above historical average after the pandemic." /
"Indiana: Few protections, short drop then back to normal..."). Keep them, add the block above.

**SAY**
> "One last twist that makes this a methods course. Minnesota's expungement law doesn't just
> protect tenants, it edits the dataset. Expunged cases leave the public feed. So when your
> final project compares Minnesota to Indiana, the law itself is part of your measurement
> story. Policy isn't just the thing you study; it decides what you can see. If your group
> wants this comparison, the data is already in the repo."

---

### slide 21 — Hard displacement's bill  ·  NEW

**ON SLIDE**
```
The writ is not the end of the story

COLLINSON et al. (2024), Quarterly Journal of Economics 139(1)
Causal design — random judge assignment, Cook County + NYC
  Emergency-shelter use          +3.4 percentage points in year one
                                 (against a 0.9% non-evicted base)
  Homelessness services, year 2  +200%
      concentrated among women   +467%
      and Black tenants          +307%
  Earnings                       −7% year one, −14% year two
  In NYC: hospital visits        +29%;  mental-health visits more than double
  Credit scores                  −16.5 points

DESMOND & KIMBRO (2015), Social Forces 94(1)
2,676 renting mothers, 20 cities
  About one standard deviation more material hardship
  Depression roughly doubles (.47 vs .26)
  Both still elevated two-plus years later

GRAETZ et al. (2024), Social Science & Medicine 340
6.6M renters linked to 38M eviction records
  A FILING without judgment    19% higher mortality
  A JUDGMENT                   40% higher mortality
  A 70% rent burden vs 30%     12% higher mortality
```

**BUILD NOTE** Say which design is which. Collinson is causal; Graetz is associational.

**SAY**
> "The writ is not the end of the story; it's the start of a different one. Shelter, earnings,
> hospitals, credit, and at the far end, mortality. The court event is one day. The bill runs
> for years."

---

### slide 22 — The gender the title promises  ·  NEW

**ON SLIDE**
```
The gender in the course title is not decoration

ZAPATA et al. (2025), IJERPH 22(8): 1212
1,085 Texas renters — the HPRM was the sampling frame
  A nonpayment violation is associated with about 2.5x the odds of
  intimate partner violence.                    AOR 2.50, CI 2.29–2.73

Cross-sectional design.

THE THREAD
  Collinson's homelessness effect concentrates among women (+467%)
  Wasatch, Hunter, and Baltimore all peak for Black women
```

**SAY**
> "Notice the method: we used the precarity model itself to find renters the courthouse never
> sees. Measurement isn't bookkeeping; it decides who becomes visible, and what gets fixed."

---

### slide 23 — Soft displacement's bill  ·  NEW

**ON SLIDE**
```
Soft displacement sends a bill too

MARCUSE (1985), Wash. U. Journal of Urban and Contemporary Law 28: 195–240
Four forms, his words (p. 208):
  "direct last-resident displacement, direct chain displacement,
   exclusionary displacement, and displacement pressure"

DING, HWANG & DIVRINGI (2016), Regional Science & Urban Economics 61
Philadelphia: vulnerable residents leaving gentrifying tracts are 2.4 to 4.8 points
more likely to land in lower-income neighborhoods than similar movers elsewhere.

DING & HWANG (2016), Cityscape 18(3)
Stayers' credit scores RISE (+11.3; +22.6 under intense gentrification).
Movers who slide down-market lose ground — "their financial health would have been
better off if they were able to remain."

BATES (2013), p. 20
Albina's displaced families landed in outer East Portland — "crowding in schools and
overburdened infrastructure"; p. 57, "residential instability (and even hypermobility)."
```

**BUILD NOTE** Attribute the four forms to **Marcuse**, not to Bates. Bates describes them
but never uses the labels.

**SAY** The honest nuance, worth one sentence:
> "Collinson finds evicted tenants in Chicago and New York don't measurably move to
> higher-poverty tracts, while Philadelphia's gentrification movers do slide down-market.
> Different populations, different designs, both verified. Measurement over vibes."

**IF TIME** Bates p. 13: the church vans that now drive 50 miles to collect the displaced
congregation.

---

### slide 24 — Bates: right tool, right stage  ·  REFRESH from 2025 W3 deck pp.45–48

**ON SLIDE**
```
Bates (2013), City of Portland

SIX NEIGHBORHOOD TYPES, collapsed to three stages
  Susceptible · Early Type 1 · Early Type 2 · Dynamic · Late · Continued Loss
                          →  Early / Mid / Late

VULNERABILITY SCORE, 0–4 — one point each                              (p. 59)
  renters                   > 44.2%
  communities of color      > 26.7%
  no bachelor's degree      > 58.2%
  households ≤ 80% MFI      > 47.0%
  Vulnerable = 3 of 4

  (Your Assignment 2 measures are cousins of exactly this.)

"It is far easier to avoid the harmful effects of these changes than to mitigate them
once they are underway; and far easier to mitigate them at an early stage than to
shoehorn in solutions later in the process."                            (p. 22)

The strategy: "match the tool(s) to specific stages of gentrification and the type of
public investment that is being made."                                  (p. 5)
```

**SAY**
> "Bates is the four P's with a targeting system. The typology tells you which neighborhoods
> get which tools when, before the visible gentrification, not after. Same logic as the HPRM's
> two channels: diagnosis before treatment."

---

### slide 25 — The toolkit, fast  ·  NEW or refresh 2025 W3 p.48

**ON SLIDE**
```
Bates' five key elements                                                (p. 6)

  1. A broad community impacts policy
  2. Community Impact Reports for major projects
  3. Community Benefits Agreements
  4. Inclusionary Zoning
  5. Education and Technical Assistance

THE LATE-STAGE TOOL WORTH KNOWING EXISTS                            (pp. 77, 85)
  A replacement ordinance plus "right to return" — new affordable housing gives
  admissions preference to the displaced.
  Real example (p. 85): Hamtramck, Michigan, won by Black former residents' class
  action; priority runs to children and grandchildren of the displaced.
  Also: the One Hill CBA in Pittsburgh (p. 49).

TIE BACK TO SECTION 5                                              (pp. 9, 51)
  As of 2013, Oregon was "one of only two states (along with Texas)" preempting
  mandatory inclusionary zoning (ORS 197.309).
```

⚠ **Do NOT add** "Oregon later lifted its ban." True-sounding, not verified.

---

### slide 26 — Your turn  ·  NEW

**ON SLIDE**
```
Your turn

Your final project is a small December 13:
    a complex story → told simply → to a stakeholder who can act.

The syllabus promises an analysis "that may interest governmental stakeholders."
Bonus points for well-supported policy recommendations. Tonight was the toolkit.

AT 6:00, YOUR GROUP DRAFTS A PITCH
  1. Area — at least two counties, or a region
  2. Research question — start from your A2
  3. Two hypotheses about disparate impact — who is hit hardest, and why there?
  4. 3–5 data points or plots you'll build
  5. Datasets — ACS via tidycensus; Indiana d5_case_aggregated; statewide
     mn_tract_evictions (2017–2025); Indiana LSC update files
  6. One policy hook — WHICH P does your finding argue for, and to whom?

Get Tim's sign-off before you leave.
```

**SAY** (close)
> "Week 1 promised we'd end at what helps. Here's the honest version of the answer: what helps
> is known. Assistance, counsel, protections, homes. What's scarce is proof someone in the
> room can't ignore, in language they can't misread. That's the skill you're practicing. Go
> form your groups; build me something a senator would underline."

---

## PART 3 — ASSETS TO PULL BEFORE 5PM

| Asset | Where | For |
|---|---|---|
| Figure 5 (four P's graphic) | `evictionresearch.net/washington/` — screenshot | slide 12 |
| TVW recording, cued to 40:00 | `tvw.org/video/senate-housing-2024121118/` | slide 10 |
| Testimony deck, open in a tab | `docs.google.com/presentation/d/1x7SCdTeBdczY5Ga5wvixMxtvTv-a4rTph6LIQWLsIk0/` | slide 10 |
| MN-vs-IN chart | already on the inherited slide | slide 20 |
| Bates typology map | report p. 32, or 2025 W3 deck | slide 24 |
| HPRM live map | `evictionresearch.net/hprm` | S5 optional |

---

## PART 4 — DECIDE BEFORE 5PM

1. **Video end cue.** Suggest 45:00–46:00. Nothing about the segment length is published.
2. **Atlas link on S4.** 404 as of July 30. Check it; if still down, no URL on the slide.
3. **California on slide 18.** Verify CCP §1161 or leave the CA clock row off.
4. **slide 13 layout.** One dense slide with five builds, or five light slides. Five is faster.
5. **slide 19 layout.** One 4-row grid, or four state slides. Four is faster.

## CUT ORDER IF RUNNING LONG

The video is the release valve: play 4 minutes instead of 6.

Then, in order: S4 atlas beat down to one sentence → slide 20 data plug to one sentence →
merge slide 16 into slide 17.

**Do not cut** S5 (explicit student demand), slide 11, or slide 26 (the second hour depends on it).
