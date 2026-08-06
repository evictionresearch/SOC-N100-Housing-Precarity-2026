#!/usr/bin/env python3
"""Week 5 lecture figures for spec slides S15-S23.

Replaces the uniform card treatment with a form chosen per slide, so eight
slides in a row don't all look alike:

  S15  horizontal bar chart   the clock, to scale against the national range
  S17  funnel                 how expungement edits the dataset
  S18  itemized ledger        "the bill" as a bill
  S19  hero statistic         one number, given room
  S20  quadrant grid          Marcuse's four forms
  S21  stage arrow + scorecard the typology and the 0-4 vulnerability score
  S22  tool chips             five elements, plus the late-stage tool
  S23  numbered step path     the pitch template

Numbers and quotes come from week5_lecture3_solutions_2026.md, which carries
the sourcing. Transparent background, sized to drop onto a slide.
"""

import html
import subprocess
from pathlib import Path

OUT = Path.home() / "git/evictionresearch/SOC-N100-Housing-Precarity-2026/output"
W = 1560
FONT = "'Helvetica Neue', Helvetica, Arial, sans-serif"

INK = "#22282E"
MUTE = "#7A828C"


def esc(t):
    return html.escape(t, quote=False)


def txt(x, y, s, size=32, weight=400, fill=INK, anchor="start",
        italic=False, ls=None, family=FONT):
    a = f' text-anchor="{anchor}"' if anchor != "start" else ""
    i = ' font-style="italic"' if italic else ""
    l = f' letter-spacing="{ls}"' if ls else ""
    return (f'<text x="{x}" y="{y}" font-family="{family}" font-size="{size}" '
            f'font-weight="{weight}" fill="{fill}"{a}{i}{l}>{esc(s)}</text>')


def head(y, title, accent, sub=None):
    """Slide-figure heading: accent rule, title, optional subtitle."""
    out = [f'<rect x="0" y="{y}" width="96" height="8" fill="{accent}"/>',
           txt(0, y + 74, title, 50, 700, accent)]
    yy = y + 74
    if sub:
        yy += 44
        out.append(txt(0, yy, sub, 29, 400, MUTE))
    return out, yy


def render(name, height, body, pad=48):
    svg = (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" '
           f'height="{height}" viewBox="0 0 {W} {height}">\n'
           f'<g transform="translate({pad},{pad})">\n'
           + "\n".join("  " + b for b in body) + "\n</g>\n</svg>\n")
    p = OUT / f"{name}.svg"
    p.write_text(svg, encoding="utf-8")
    subprocess.run(["rsvg-convert", "-w", str(W * 2), "-f", "png",
                    "-o", str(OUT / f"{name}.png"), str(p)], check=True)
    # white-background twin, for checking legibility before it goes on a slide
    subprocess.run(["rsvg-convert", "-w", str(W), "-f", "png", "-b", "white",
                    "-o", str(OUT / f"{name}_preview.png"), str(p)], check=True)
    print(f"{name}.png  {W}x{height}")


IW = W - 96          # inner width after padding


# ============================================================ S15  BARS ======
# The clock, drawn to scale. Texas being visibly stubby against Massachusetts
# is the whole argument, so the bars share one axis.

A = "#5C4B8A"
b, y = head(0, "Your address decides how long you have", A,
            "Days of notice before a nonpayment case can be filed")
# leave room to the right of the longest bar for its label and note
SCALE = IW - 620
MAXD = 53

rows = [("MASSACHUSETTS", 53, "longest statutory clock in the country", "#C9C3D6"),
        ("MINNESOTA", 14, "pre-filing notice, by statute since Jan 1 2024", A),
        ("INDIANA", 10, "pay-or-stay; a lease can waive it down", A),
        ("TEXAS", 3, "and the lease can make it shorter", A),
        ("LOUISIANA", 5, "shortest statutory clock", "#C9C3D6")]

y += 76
for label, days, note, col in rows:
    bw = max(10, int(SCALE * days / MAXD))
    b.append(txt(0, y + 4, label, 26, 700, INK if col == A else MUTE, ls=1.6))
    b.append(f'<rect x="0" y="{y+22}" width="{bw}" height="46" rx="5" fill="{col}"/>')
    # long bars carry their own label inside so the note still fits alongside
    if bw > 400:
        b.append(txt(bw - 22, y + 56, f"{days} days", 34, 700, "#FFFFFF",
                     anchor="end"))
        note_x = bw + 24
    else:
        b.append(txt(bw + 22, y + 56, f"{days} days", 34, 700,
                     A if col == A else MUTE))
        note_x = bw + 170
    b.append(txt(note_x, y + 55, note, 27, 400, MUTE))
    y += 104

b.append(f'<line x1="0" y1="{y}" x2="{IW}" y2="{y}" stroke="{A}" '
         f'stroke-width="2" opacity="0.3"/>')
b.append(txt(0, y + 46, "Same missed rent check. The model reads these clocks "
                        "as a predictor.", 29, 500, MUTE))
b.append(txt(0, y + 86, "California is not shown: CCP §1161 went unverified "
                        "this build, SB 436 pending.", 24, 400, "#A8AEB6"))
render("s15_fig_clocks", y + 86 + 60, b)


# =========================================================== S17  FUNNEL =====
# Expungement as a filter on the data, not just on the tenant.

A = "#1F7A6E"
b, y = head(0, "Policy decides what you can see", A,
            "Minnesota's expungement statute edits the dataset itself")
y += 60
# The flow sits left so the expungement branch has room on the right; that
# branch is the point of the figure, not a footnote.
BOXW, BOXH = 560, 96
CX = BOXW // 2


def stage(yy, w, label, fill, ink="#FFFFFF"):
    return [f'<rect x="0" y="{yy}" width="{w}" height="{BOXH}" rx="10" fill="{fill}"/>',
            txt(w / 2, yy + 56, label, 32, 700, ink, anchor="middle")]


def arrow(yy, h=52):
    return [f'<line x1="{CX}" y1="{yy}" x2="{CX}" y2="{yy+h-14}" stroke="{A}" '
            f'stroke-width="4"/>',
            f'<path d="M {CX-13} {yy+h-16} L {CX} {yy+h} L {CX+13} {yy+h-16} z" '
            f'fill="{A}"/>']


b += stage(y, BOXW, "Every eviction case filed", A)
y += BOXH
b += arrow(y)
y += 52
b += stage(y, BOXW, "The court's running tally", A)

mid = y + BOXH // 2
b.append(f'<line x1="{BOXW}" y1="{mid}" x2="{BOXW+112}" y2="{mid}" '
         f'stroke="#B0362F" stroke-width="4"/>')
b.append(f'<path d="M {BOXW+110} {mid-13} L {BOXW+140} {mid} '
         f'L {BOXW+110} {mid+13} z" fill="#B0362F"/>')
b.append(txt(BOXW + 160, mid - 14, "EXPUNGED CASES LEAVE", 25, 700,
             "#B0362F", ls=1.4))
b.append(txt(BOXW + 160, mid + 22, "tenant wins, or the case is dismissed",
             26, 400, MUTE))
b.append(txt(BOXW + 160, mid + 54, "for any reason", 26, 400, MUTE))
y += BOXH
b += arrow(y)
y += 52
b += stage(y, 420, "What you download", "#0E4F47")
y += BOXH + 66

b.append(f'<rect x="0" y="{y}" width="{IW//2-16}" height="128" rx="10" '
         f'fill="#F1F6F5" stroke="{A}" stroke-width="2"/>')
b.append(txt(28, y + 50, "Absolute counts", 28, 700, A))
b.append(txt(28, y + 92, "read conservative", 32, 400, INK))
b.append(f'<rect x="{IW//2+16}" y="{y}" width="{IW//2-16}" height="128" rx="10" '
         f'fill="#F1F6F5" stroke="{A}" stroke-width="2"/>')
b.append(txt(IW // 2 + 44, y + 50, "Disparity ratios", 28, 700, A))
b.append(txt(IW // 2 + 44, y + 92, "are unaffected", 32, 400, INK))
y += 128
b.append(txt(0, y + 52, "Policy isn't only the thing you study. It decides what "
                        "you're able to measure.", 29, 500, MUTE))
render("s17_fig_funnel", y + 52 + 60, b)


# =========================================================== S18  LEDGER =====
# "The bill" rendered as an itemized bill.

A = "#8C2B2B"
b, y = head(0, "The writ is not the end of the story", A,
            "What an eviction order costs, after the court date")
y += 64
b.append(txt(0, y, "ITEMIZED", 25, 700, A, ls=3))
b.append(txt(IW, y, "CHANGE", 25, 700, A, ls=3, anchor="end"))
y += 18
b.append(f'<line x1="0" y1="{y}" x2="{IW}" y2="{y}" stroke="{A}" stroke-width="3"/>')

LEDGER = [
    ("src", "COLLINSON ET AL. 2024 · QJE 139(1) · causal, random judge assignment", ""),
    ("row", "Emergency shelter use, year one", "+3.4 pts"),
    ("row", "Homelessness services, year two", "+200%"),
    ("sub", "among women", "+467%"),
    ("sub", "among Black tenants", "+307%"),
    ("row", "Earnings, year one", "−7%"),
    ("row", "Earnings, year two", "−14%"),
    ("row", "Hospital visits (NYC)", "+29%"),
    ("row", "Credit score", "−16.5 pts"),
    ("src", "DESMOND & KIMBRO 2015 · SOCIAL FORCES 94(1) · 2,676 renting mothers", ""),
    ("row", "Material hardship", "+1 SD"),
    ("row", "Depression rate", ".26 → .47"),
    ("src", "GRAETZ ET AL. 2024 · SSM 340 · associational, 6.6M renters", ""),
    ("row", "Mortality, after a filing alone", "+19%"),
    ("row", "Mortality, after a judgment", "+40%"),
]

for kind, label, amount in LEDGER:
    if kind == "src":
        y += 54
        b.append(txt(0, y, label, 23, 700, A, ls=1.2))
        y += 12
    elif kind == "sub":
        y += 44
        b.append(txt(36, y, label, 29, 400, MUTE))
        b.append(txt(IW, y, amount, 31, 700, MUTE, anchor="end"))
    else:
        y += 48
        b.append(txt(0, y, label, 31, 400, INK))
        b.append(txt(IW, y, amount, 33, 700, A, anchor="end"))

y += 26
b.append(f'<line x1="0" y1="{y}" x2="{IW}" y2="{y}" stroke="{A}" stroke-width="3"/>')
b.append(txt(0, y + 50, "The court event is one day. The bill runs for years.",
             30, 500, MUTE))
render("s18_fig_ledger", y + 50 + 60, b)


# ============================================================= S19  HERO =====

A = "#7A2E5C"
b, y = head(0, "The gender in the title is not decoration", A)
y += 90
b.append(txt(0, y + 120, "2.5×", 200, 700, A))
b.append(txt(500, y + 56, "the odds of intimate partner violence,", 40, 400, INK))
b.append(txt(500, y + 108, "where a nonpayment violation is present", 40, 400, INK))
b.append(txt(500, y + 162, "AOR 2.50 · CI 2.29–2.73 · cross-sectional", 27, 400, MUTE))
y += 210
b.append(txt(0, y + 44, "ZAPATA ET AL. 2025 · IJERPH 22(8): 1212 · 1,085 TEXAS "
                        "RENTERS", 24, 700, A, ls=1.4))
b.append(txt(0, y + 84, "The HPRM was the sampling frame — the model found renters "
                        "the courthouse never sees.", 29, 400, MUTE))
y += 140

b.append(txt(0, y + 40, "THE SAME THREAD, ALL NIGHT", 25, 700, A, ls=2.6))
y += 76
chips = [("Collinson", "homelessness effect\n+467% among women"),
         ("Wasatch", "5×\nBlack women vs white men"),
         ("Hunter", "33% vs 22%\nBlack women"),
         ("Baltimore", "3.9×\nBlack women vs white men")]
cw = (IW - 3 * 20) // 4
for i, (t, s) in enumerate(chips):
    x = i * (cw + 20)
    b.append(f'<rect x="{x}" y="{y}" width="{cw}" height="132" rx="10" '
             f'fill="#F7F1F5" stroke="{A}" stroke-width="2"/>')
    b.append(txt(x + cw / 2, y + 44, t, 28, 700, A, anchor="middle"))
    for j, line in enumerate(s.split("\n")):
        b.append(txt(x + cw / 2, y + 80 + j * 32, line, 25, 400, INK,
                     anchor="middle"))
render("s19_fig_hero", y + 132 + 60, b)


# ========================================================= S20  QUADRANT =====

A = "#B0621A"
b, y = head(0, "The market sends a bill too", A,
            "Marcuse (1985), p. 208 — four forms of displacement, in his words")
y += 66
QW, QH = (IW - 24) // 2, 168
quads = [("Direct last-resident", "the household living there when the\nchange arrives is pushed out"),
         ("Direct chain", "earlier residents were already pushed\nout by the same process"),
         ("Exclusionary", "the household that can no longer\nmove in at all"),
         ("Displacement pressure", "the neighborhood changes around\nyou until staying is untenable")]
for i, (t, s) in enumerate(quads):
    x = (i % 2) * (QW + 24)
    yy = y + (i // 2) * (QH + 24)
    b.append(f'<rect x="{x}" y="{yy}" width="{QW}" height="{QH}" rx="10" '
             f'fill="#FDF4EC" stroke="{A}" stroke-width="3"/>')
    b.append(txt(x + 30, yy + 54, t, 33, 700, A))
    for j, line in enumerate(s.split("\n")):
        b.append(txt(x + 30, yy + 100 + j * 34, line, 26, 400, INK))
y += 2 * QH + 24 + 66

b.append(txt(0, y, "AND WHERE PEOPLE LAND", 25, 700, A, ls=2.6))
y += 52
b.append(txt(0, y, "Philadelphia: vulnerable residents leaving gentrifying tracts "
                   "are", 30, 400, INK))
b.append(txt(0, y + 40, "2.4 to 4.8 points more likely to land in a lower-income "
                        "neighborhood.", 30, 400, INK))
b.append(txt(0, y + 78, "Ding, Hwang & Divringi 2016 · Reg. Sci. Urban Econ. 61",
             25, 400, MUTE))
y += 118
b.append(txt(0, y + 40, "Stayers' credit scores rise. Movers who slide down-market "
                        "lose ground.", 29, 500, MUTE))
b.append(txt(0, y + 78, "Chicago and NYC evictees don't measurably move to poorer "
                        "tracts; Philadelphia's gentrification", 24, 400, "#A8AEB6"))
b.append(txt(0, y + 108, "movers do. Different populations, different designs. "
                         "Measurement over vibes.", 24, 400, "#A8AEB6"))
render("s20_fig_quadrant", y + 108 + 60, b)


# ================================================ S21  STAGES + SCORECARD ====

A = "#2E4372"
b, y = head(0, "Right tool, right stage", A,
            "Bates (2013), City of Portland — six types collapsed to three stages")
y += 70
SW = (IW - 2 * 18) // 3
for i, (stg, types) in enumerate([("EARLY", "Susceptible · Early Type 1"),
                                  ("MID", "Early Type 2 · Dynamic"),
                                  ("LATE", "Late · Continued Loss")]):
    x = i * (SW + 18)
    shade = ["#DCE3EF", "#8FA3C4", "#2E4372"][i]
    ink = INK if i < 2 else "#FFFFFF"
    b.append(f'<rect x="{x}" y="{y}" width="{SW}" height="118" rx="10" fill="{shade}"/>')
    b.append(txt(x + SW / 2, y + 52, stg, 36, 700, ink, anchor="middle", ls=3))
    b.append(txt(x + SW / 2, y + 92, types, 24, 400, ink, anchor="middle"))
    if i < 2:
        cx = x + SW + 9
        b.append(f'<path d="M {cx-9} {y+45} L {cx+9} {y+59} L {cx-9} {y+73} z" fill="{A}"/>')
y += 118
b.append(txt(0, y + 46, "“Far easier to avoid the harmful effects than to mitigate "
                        "them once underway; far easier", 27, 400, MUTE))
b.append(txt(0, y + 80, "at an early stage than to shoehorn in solutions later.”  "
                        "— p. 22", 27, 400, MUTE))
y += 138

b.append(txt(0, y, "VULNERABILITY SCORE · 0–4 · ONE POINT EACH · p. 59", 25, 700,
             A, ls=2.2))
y += 46
BW = (IW - 3 * 16) // 4
for i, (lab, thr) in enumerate([("Renters", "> 44.2%"),
                                ("Communities of color", "> 26.7%"),
                                ("No bachelor's degree", "> 58.2%"),
                                ("Households ≤ 80% MFI", "> 47.0%")]):
    x = i * (BW + 16)
    b.append(f'<rect x="{x}" y="{y}" width="{BW}" height="126" rx="10" '
             f'fill="#FFFFFF" stroke="{A}" stroke-width="3"/>')
    b.append(txt(x + BW / 2, y + 50, lab, 24, 500, INK, anchor="middle"))
    b.append(txt(x + BW / 2, y + 98, thr, 36, 700, A, anchor="middle"))
y += 126
b.append(txt(0, y + 52, "3 of 4 = vulnerable.  Your Assignment 2 measures are "
                        "cousins of exactly this.", 30, 500, A))
render("s21_fig_stages", y + 52 + 60, b)


# ============================================================ S22  TOOLS =====

A = "#4A6741"
b, y = head(0, "The toolkit", A, "Bates (2013), p. 6 — five key elements")
y += 66
TW = (IW - 4 * 14) // 5
tools = ["Community\nimpacts policy", "Community\nImpact Reports",
         "Community\nBenefits Agreements", "Inclusionary\nZoning",
         "Education &\nTechnical Assistance"]
for i, t in enumerate(tools):
    x = i * (TW + 14)
    b.append(f'<rect x="{x}" y="{y}" width="{TW}" height="176" rx="10" '
             f'fill="#F2F6F1" stroke="{A}" stroke-width="3"/>')
    b.append(f'<circle cx="{x+TW/2}" cy="{y+46}" r="27" fill="{A}"/>')
    b.append(txt(x + TW / 2, y + 56, str(i + 1), 30, 700, "#FFFFFF", anchor="middle"))
    for j, line in enumerate(t.split("\n")):
        b.append(txt(x + TW / 2, y + 108 + j * 32, line, 24, 500, INK,
                     anchor="middle"))
y += 176 + 60

b.append(f'<rect x="0" y="{y}" width="{IW}" height="192" rx="10" fill="{A}"/>')
b.append(txt(34, y + 48, "THE LATE-STAGE TOOL WORTH KNOWING EXISTS · pp. 77, 85",
             24, 700, "#D6E2D2", ls=2))
b.append(txt(34, y + 100, "Replacement ordinance plus “right to return”", 38, 700,
             "#FFFFFF"))
b.append(txt(34, y + 144, "New affordable housing gives admissions preference to "
                          "the displaced. Hamtramck, Michigan:", 26, 400, "#D6E2D2"))
b.append(txt(34, y + 176, "won by a class action, priority running to children and "
                          "grandchildren of the displaced.", 26, 400, "#D6E2D2"))
y += 192
b.append(txt(0, y + 48, "As of 2013, Oregon was “one of only two states (along with "
                        "Texas)” preempting", 27, 400, MUTE))
b.append(txt(0, y + 82, "mandatory inclusionary zoning.  ORS 197.309 · pp. 9, 51",
             27, 400, MUTE))
render("s22_fig_tools", y + 82 + 60, b)


# ============================================================ S23  STEPS =====

A = "#003262"
b, y = head(0, "Your turn", A,
            "Your final project is a small December 13: a complex story, told "
            "simply, to someone who can act")
y += 70
steps = [("Area", "at least two counties, or a region"),
         ("Research question", "start from your A2"),
         ("Two hypotheses", "who is hit hardest, and why there?"),
         ("3–5 data points", "the plots you'll actually build"),
         ("Datasets", "ACS via tidycensus · Indiana d5 · Minnesota tracts"),
         ("One policy hook", "which P does your finding argue for, and to whom?")]
for i, (t, s) in enumerate(steps):
    b.append(f'<circle cx="34" cy="{y+34}" r="34" fill="{A}"/>')
    b.append(txt(34, y + 46, str(i + 1), 34, 700, "#FFFFFF", anchor="middle"))
    b.append(txt(92, y + 26, t, 34, 700, INK))
    b.append(txt(92, y + 62, s, 27, 400, MUTE))
    if i < len(steps) - 1:
        b.append(f'<line x1="34" y1="{y+72}" x2="34" y2="{y+96}" stroke="{A}" '
                 f'stroke-width="3" opacity="0.35"/>')
    y += 100

y += 26
b.append(f'<rect x="0" y="{y}" width="{IW}" height="104" rx="10" fill="{A}"/>')
b.append(txt(IW / 2, y + 46, "Get sign-off before you leave.", 34, 700,
             "#FFFFFF", anchor="middle"))
b.append(txt(IW / 2, y + 84, "Build me something a senator would underline.",
             28, 400, "#BFD0E0", anchor="middle"))
render("s23_fig_steps", y + 104 + 60, b)
