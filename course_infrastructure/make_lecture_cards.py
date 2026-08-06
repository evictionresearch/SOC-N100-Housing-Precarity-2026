#!/usr/bin/env python3
"""Content cards for the Week 5 lecture (spec slides S12-S23).

One card per slide, each with its own accent colour so they read as a set
without blurring together. Cards drop onto a slide as an image; the slide
carries the title and Tim narrates around them.

Content comes from week5_lecture3_solutions_2026.md. Every number, quote and
citation here is copied from that spec, which carries its own sourcing and
honesty flags; the flags travel onto the cards rather than living only in the
notes.

Writes .svg and renders .png via rsvg-convert.
"""

import html
import subprocess
from pathlib import Path

OUT = Path.home() / "git/evictionresearch/SOC-N100-Housing-Precarity-2026/output"

W = 1560          # card width
PAD = 72          # inner left/right padding
BAR = 104         # accent bar height
BORDER = 11

FONT = "'Helvetica Neue', Helvetica, Arial, sans-serif"

# style -> (size, weight, fill, leading, space_before)
STYLES = {
    "eyebrow": (31, 700, "#FFFFFF", 0, 0),
    "title":   (54, 700, "ACCENT",  62, 30),
    "cite":    (28, 400, "#7A828C", 38, 4),
    "body":    (33, 400, "#22282E", 46, 26),
    "label":   (26, 700, "ACCENT",  36, 34),
    "stat":    (34, 400, "#22282E", 48, 6),
    "footer":  (28, 500, "#7A828C", 38, 30),
    "rule":    (0,  0,   "",        0,  30),
}


def esc(t):
    return html.escape(t, quote=False)


def spans(text, accent):
    """Turn **bold** into an accent-coloured bold tspan."""
    out, bold = [], False
    for chunk in text.split("**"):
        if chunk:
            if bold:
                out.append(
                    f'<tspan font-weight="700" fill="{accent}">{esc(chunk)}</tspan>'
                )
            else:
                out.append(esc(chunk))
        bold = not bold
    return "".join(out)


def build(name, accent, eyebrow, lines):
    body, y, prev = [], BAR, None
    for style, text in lines:
        size, weight, fill, lead, before = STYLES[style]
        # `before` opens a new block, so only pay it when the style changes.
        # Consecutive lines of the same style stay tight as a paragraph.
        if style != prev:
            y += before
        prev = style
        if style == "rule":
            body.append(
                f'<line x1="{PAD}" y1="{y}" x2="{W-PAD}" y2="{y}" '
                f'stroke="{accent}" stroke-width="3" opacity="0.35"/>'
            )
            continue
        colour = accent if fill == "ACCENT" else fill
        y += lead - 10
        ls = ' letter-spacing="2.5"' if style == "label" else ""
        style_attr = ' font-style="italic"' if style == "title" else ""
        body.append(
            f'<text x="{PAD}" y="{y}" font-family="{FONT}" font-size="{size}" '
            f'font-weight="{weight}" fill="{colour}"{ls}{style_attr}>'
            f'{spans(text, accent)}</text>'
        )
    height = y + 62

    svg = f'''<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{height}" viewBox="0 0 {W} {height}">
  <rect x="0" y="0" width="{W}" height="{height}" rx="20" fill="{accent}"/>
  <rect x="{BORDER}" y="{BAR}" width="{W-2*BORDER}" height="{height-BAR-BORDER}"
        rx="12" fill="#FFFFFF"/>
  <text x="{PAD}" y="{int(BAR*0.63)}" font-family="{FONT}" font-size="31"
        font-weight="700" fill="#FFFFFF" letter-spacing="4">{esc(eyebrow)}</text>
{chr(10).join("  " + b for b in body)}
</svg>
'''
    svg_path = OUT / f"{name}.svg"
    svg_path.write_text(svg, encoding="utf-8")
    subprocess.run(
        ["rsvg-convert", "-w", str(W * 2), "-f", "png",
         "-o", str(OUT / f"{name}.png"), str(svg_path)], check=True)
    print(f"{name}.png  {W}x{height} -> {W*2}px wide")


# ---------------------------------------------------------------- card 1 ----

build(
    "s12_card_wasatch", "#003262", "SEATTLE  ·  2017  ·  THE FIRST CASE",
    [
        ("title", "Smith v. Wasatch Property Management"),
        ("cite",  "No. 2:17-cv-00501-RAJ (W.D. Wash.)"),
        ("rule",  ""),
        ("body",  "Nikita Smith, a Black woman, was blocked from even applying"),
        ("body",  "to a Renton complex over a years-old eviction filing that had"),
        ("body",  "been resolved **without** an eviction."),
        ("label", "WHY IT MATTERED  ·  ACLU"),
        ("stat",  "First case to challenge eviction-record screening under civil"),
        ("stat",  "rights law. First Fair Housing Act case built on an"),
        ("stat",  "intersectional race-and-sex theory."),
        ("label", "THE DATA IN THE COMPLAINT  ·  KING COUNTY"),
        ("stat",  "**4x**   Black tenants filed against vs. white tenants"),
        ("stat",  "**5x+**  Black-woman-headed households vs. white-man-headed"),
        ("footer", "Filed March 30, 2017  ·  Settled October 2017"),
    ])

# ---------------------------------------------------------------- card 2 ----

build(
    "s13_card_hunter", "#B07406", "CHICAGO  ·  2023  ·  THE THEORY TRAVELS",
    [
        ("title", "Legal Aid Chicago v. Hunter Properties"),
        ("cite",  "No. 1:23-cv-04809 (N.D. Ill.)"),
        ("rule",  ""),
        ("label", "COOK COUNTY SHERIFF DATA  ·  SEPT 2010 – MAR 2023"),
        ("stat",  "**56%**  of people served or evicted were Black renters,"),
        ("stat",  "         against **33%** of renters"),
        ("stat",  "**33%**  were Black women, against roughly **22%**"),
        ("body",  "The complaint calls it “an independent analysis.”"),
        ("label", "WHERE IT STANDS, HONESTLY"),
        ("stat",  "Dismissed Sept 2024 on **organizational standing** — not on the"),
        ("stat",  "merits of the disparate-impact theory. Judgment vacated,"),
        ("stat",  "amended complaint filed, no ruling as of early 2026."),
        ("label", "THE COMPANION"),
        ("stat",  "HOPE Fair Housing Center v. Mastercare (Oak Park) tested the"),
        ("stat",  "same theory inside the landlord’s own **~2,000-applicant pool**."),
        ("footer", "Population disparity makes the case. Within-pool analysis tests the policy."),
    ])

# ---------------------------------------------------------------- card 3 ----

build(
    "s14_card_ripple", "#2D6A4F", "THE RIPPLE  ·  AND THE PUBLIC RECORD",
    [
        ("title", "The theory spreads past the cases"),
        ("rule",  ""),
        ("label", "COURTS"),
        ("stat",  "**Byrd v. JWB Property Management** (M.D. Fla.) — motion to dismiss"),
        ("stat",  "denied June 3, 2024. First court to sustain the claim **on the merits**"),
        ("stat",  "at the pleading stage. Settled November 2024."),
        ("stat",  "**Moore v. Mac Property Management** (N.D. Ill., Dec 2024) — the"),
        ("stat",  "coalition returns with individual Black women as plaintiffs."),
        ("label", "LEGISLATION  ·  BALTIMORE AND MARYLAND"),
        ("stat",  "Good-cause ordinance CB 21-0031 (2021); MD SB 504 (2023), HB 477 (2024)."),
        ("stat",  "Campaign record: Black women evicted at **3.9x** the rate of white men;"),
        ("stat",  "Black households at **3x** white households."),
        ("label", "THE FEDERAL SHELF"),
        ("stat",  "U.S. Commission on Civil Rights, NY (2022) — **73%** of Black-headed"),
        ("stat",  "renter households sit in moderate-to-high eviction-risk neighborhoods."),
        ("stat",  "GAO-24-106637 (2024)  ·  HUD Cityscape 26(1) (2024)"),
        ("stat",  "Washington Supreme Court amicus, Sangha v. Keen (2025)"),
        ("footer", "The same statistic, in four different rooms. Almost none of them say my name."),
    ])

# ================================================================ SECTION 5 ==

build(
    "s15_card_clock", "#5C4B8A", "SECTION 5  ·  YOUR ADDRESS DECIDES HOW LONG YOU HAVE",
    [
        # Three, not four: California's CCP §1161 3-day notice went unverified
        # in the 2026-07-30 build (SB 436 pending), so it stays off the clock.
        ("title", "Three states, three clocks"),
        ("cite",  "The statutory timeline is itself a predictor in the HPRM."),
        ("cite",  "Nationally it ranges tenfold: ~5 days in Louisiana to ~53 in Massachusetts."),
        ("rule",  ""),
        ("label", "TEXAS  ·  3 DAYS"),
        ("stat",  "Written notice to vacate. And the lease can make it **shorter**."),
        ("stat",  "Prop. Code §24.005(a)"),
        ("label", "INDIANA  ·  10 DAYS"),
        ("stat",  "Pay-or-stay: paying in full within the window **defeats the notice**."),
        ("stat",  "But “unless the parties otherwise agreed” — a lease can waive it down."),
        ("stat",  "IC §32-31-1-6"),
        ("label", "MINNESOTA  ·  14 DAYS"),
        ("stat",  "Written pre-filing notice before **any** nonpayment filing."),
        ("stat",  "By statute since January 1, 2024.   Minn. Stat. §504B.321 subd. 1a"),
        ("footer", "Same missed rent check. Different clocks. The model reads those clocks as data."),
    ])

build(
    "s17_card_measurement", "#1F7A6E", "SECTION 5  ·  MINNESOTA VS INDIANA",
    [
        ("title", "Policy decides what you can see"),
        ("rule",  ""),
        ("label", "YOU SAW THE CHART ON JULY 14. NOW YOU KNOW WHY."),
        ("stat",  "Minnesota: strong protections, still above its historical average."),
        ("stat",  "Indiana: few protections, many neighborhoods above **50%** filing rates,"),
        ("stat",  "a few above **80%**."),
        ("label", "THE TWIST THAT MAKES THIS A METHODS COURSE"),
        ("stat",  "Minnesota’s expungement statute does not just protect tenants."),
        ("stat",  "It **edits the dataset**. Expunged cases leave the public feed, so the"),
        ("stat",  "Minnesota counts you download are the court’s tally **after** expungement."),
        ("stat",  "Absolute MN counts read **conservative**. Disparity ratios are **unaffected**."),
        ("label", "IN THE COURSE REPO, READY TO TEST"),
        ("stat",  "mn_tract_evictions  ·  statewide, 2017–2025, 1,505 tracts"),
        ("stat",  "Indiana d5 and LSC tract files  ·  2016–2026"),
        ("footer", "Policy isn’t only the thing you study. It decides what you’re able to measure."),
    ])

# ================================================================ SECTION 6 ==

build(
    "s18_card_hard", "#8C2B2B", "SECTION 6  ·  HARD DISPLACEMENT’S BILL",
    [
        ("title", "The writ is not the end of the story"),
        ("rule",  ""),
        ("label", "COLLINSON ET AL. (2024)  ·  QJE 139(1)  ·  CAUSAL"),
        ("cite",  "Random judge assignment, Cook County + New York City"),
        ("stat",  "Emergency shelter use  **+3.4 points** in year one, against a 0.9% base"),
        ("stat",  "Homelessness services, year two  **+200%**"),
        ("stat",  "      concentrated among women **+467%**, Black tenants **+307%**"),
        ("stat",  "Earnings  **−7%** year one, **−14%** year two"),
        ("stat",  "In NYC: hospital visits **+29%**, mental-health visits more than double"),
        ("stat",  "Credit scores  **−16.5 points**"),
        ("label", "DESMOND & KIMBRO (2015)  ·  SOCIAL FORCES 94(1)"),
        ("stat",  "2,676 renting mothers, 20 cities. About **one standard deviation** more"),
        ("stat",  "material hardship. Depression roughly doubles (**.47 vs .26**)."),
        ("stat",  "Both still elevated **two-plus years** later."),
        ("label", "GRAETZ ET AL. (2024)  ·  SSM 340  ·  ASSOCIATIONAL"),
        ("stat",  "6.6M renters linked to 38M eviction records."),
        ("stat",  "A **filing** without judgment: **19%** higher mortality. A **judgment**: **40%**."),
        ("footer", "The court event is one day. The bill runs for years."),
    ])

build(
    "s19_card_gender", "#7A2E5C", "SECTION 6  ·  THE GENDER IN THE COURSE TITLE",
    [
        ("title", "Not decoration"),
        ("rule",  ""),
        ("label", "ZAPATA ET AL. (2025)  ·  IJERPH 22(8): 1212"),
        ("stat",  "1,085 Texas renters. **The HPRM was the sampling frame.**"),
        ("stat",  "A nonpayment violation is associated with about **2.5x the odds**"),
        ("stat",  "of intimate partner violence.   AOR 2.50, CI 2.29–2.73"),
        ("stat",  "Cross-sectional design."),
        ("label", "THE THREAD RUNNING THROUGH TONIGHT"),
        ("stat",  "Collinson’s homelessness effect concentrates among **women (+467%)**."),
        ("stat",  "Wasatch, Hunter and Baltimore all peak for **Black women**."),
        ("footer", "We used the precarity model to find renters the courthouse never sees."),
    ])

build(
    "s20_card_soft", "#B0621A", "SECTION 6  ·  SOFT DISPLACEMENT’S BILL",
    [
        ("title", "The market sends a bill too"),
        ("rule",  ""),
        ("label", "MARCUSE (1985)  ·  WASH. U. J. URBAN & CONTEMP. LAW 28, p. 208"),
        ("stat",  "Four forms, in his words: “direct last-resident displacement, direct"),
        ("stat",  "chain displacement, exclusionary displacement, and displacement pressure.”"),
        ("cite",  "Bates describes these but never uses the labels. Attribute to Marcuse."),
        ("label", "DING, HWANG & DIVRINGI (2016)  ·  REG. SCI. URBAN ECON. 61"),
        ("stat",  "Philadelphia: vulnerable residents leaving gentrifying tracts are"),
        ("stat",  "**2.4 to 4.8 points** more likely to land in a lower-income neighborhood."),
        ("stat",  "Companion (Cityscape 18(3)): stayers’ credit scores **rise** (+11.3;"),
        ("stat",  "+22.6 under intense gentrification). Movers who slide down-market lose ground."),
        ("label", "BATES (2013), p. 20 AND p. 57"),
        ("stat",  "Albina’s displaced families landed in outer East Portland: “crowding in"),
        ("stat",  "schools and overburdened infrastructure,” “residential instability"),
        ("stat",  "(and even hypermobility).”"),
        ("footer", "Chicago and NYC evictees don’t measurably move to poorer tracts. Philadelphia’s"),
        ("footer", "gentrification movers do. Different populations, different designs. Measurement over vibes."),
    ])

# ================================================================ SECTION 7 ==

build(
    "s21_card_bates", "#2E4372", "SECTION 7  ·  RIGHT TOOL, RIGHT STAGE",
    [
        ("title", "Bates (2013), City of Portland"),
        ("rule",  ""),
        ("label", "SIX NEIGHBORHOOD TYPES, COLLAPSED TO THREE STAGES"),
        ("stat",  "Susceptible · Early Type 1 · Early Type 2 · Dynamic · Late · Continued Loss"),
        ("stat",  "**Early  /  Mid  /  Late**      pp. 29–31, 76"),
        ("label", "VULNERABILITY SCORE, 0–4  ·  ONE POINT EACH  ·  p. 59"),
        ("stat",  "renters  **> 44.2%**          communities of color  **> 26.7%**"),
        ("stat",  "no bachelor’s degree  **> 58.2%**    households ≤ 80% MFI  **> 47.0%**"),
        ("stat",  "**Vulnerable = 3 of 4.**  Your Assignment 2 measures are cousins of this."),
        ("label", "THE TIMING ARGUMENT  ·  p. 22"),
        ("stat",  "“It is far easier to avoid the harmful effects of these changes than to"),
        ("stat",  "mitigate them once they are underway; and far easier to mitigate them at an"),
        ("stat",  "early stage than to shoehorn in solutions later in the process.”"),
        ("footer", "Diagnosis before treatment. Same logic as the HPRM’s two channels."),
    ])

build(
    "s22_card_toolkit", "#4A6741", "SECTION 7  ·  THE TOOLKIT",
    [
        ("title", "Five elements, and one late-stage tool"),
        ("rule",  ""),
        ("label", "BATES’ FIVE KEY ELEMENTS  ·  p. 6"),
        ("stat",  "**1.**  A broad community impacts policy"),
        ("stat",  "**2.**  Community Impact Reports for major projects"),
        ("stat",  "**3.**  Community Benefits Agreements"),
        ("stat",  "**4.**  Inclusionary Zoning"),
        ("stat",  "**5.**  Education and Technical Assistance"),
        ("label", "THE LATE-STAGE TOOL WORTH KNOWING EXISTS  ·  pp. 77, 85"),
        ("stat",  "A **replacement ordinance plus “right to return”**: new affordable housing"),
        ("stat",  "gives admissions preference to the displaced."),
        ("stat",  "Hamtramck, Michigan, won by Black former residents’ class action, with"),
        ("stat",  "priority running to **children and grandchildren** of the displaced."),
        ("label", "AND BACK TO SECTION 5  ·  pp. 9, 51"),
        ("stat",  "As of 2013, Oregon was “one of only two states (along with Texas)”"),
        ("stat",  "preempting mandatory inclusionary zoning.   ORS 197.309"),
        ("footer", "Preemption isn’t an abstraction. It decides which tools a city is allowed to pick up."),
    ])

build(
    "s23_card_yourturn", "#003262", "SECTION 7  ·  YOUR TURN",
    [
        ("title", "Your final project is a small December 13"),
        ("cite",  "A complex story, told simply, to a stakeholder who can act."),
        ("rule",  ""),
        ("label", "WHAT THE SYLLABUS PROMISES"),
        ("stat",  "An analysis “that may interest governmental stakeholders.”"),
        ("stat",  "**Bonus points** for well-supported policy recommendations."),
        ("stat",  "Tonight was the toolkit."),
        ("label", "THE PITCH YOUR GROUP DRAFTS AT 6:00"),
        ("stat",  "**1.**  Area — at least two counties, or a region"),
        ("stat",  "**2.**  Research question — start from your A2"),
        ("stat",  "**3.**  Two hypotheses about disparate impact: who is hit hardest, and why there?"),
        ("stat",  "**4.**  Three to five data points or plots you’ll build"),
        ("stat",  "**5.**  Datasets — ACS via tidycensus; Indiana d5; Minnesota tract file"),
        ("stat",  "**6.**  One policy hook — **which P** does your finding argue for, and to whom?"),
        ("footer", "Get sign-off before you leave. Build me something a senator would underline."),
    ])
