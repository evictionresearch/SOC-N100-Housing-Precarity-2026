# How I Use AI — class discussion, lecture outline & tutorial

*Draft for Tim's review, 2026-06-29. Grounded in a deep dive across your repos, configs,
research workflows, and 73 locally-transcribed meetings (Jan–Jun 2026). Quotes are tagged
by source so you know what is verbatim-yours vs. paraphrase. Written answer-first, light on
em-dashes, no chatty filler, so it models the "strip the AI tells" lesson it teaches.*

---

## A. Where this fits in the course

**Recommendation: Week 1, as two short segments. Do not give it a standalone session.**
AI literacy sticks better when it is distributed and applied than when it is a one-off lecture.

1. **Tuesday (Lecture), ~15–20 min, at the end of the intro session.**
   The "How I Use AI" narrative + a 5-minute live demo + the class policy. This is the
   big-picture, you-talking slot. It sets the norm *before* anyone writes code.

2. **Thursday (Lab), ~20–30 min, woven into Lab 1.**
   The hands-on tutorial. Students hit real R errors in Lab 1 anyway. That is the honest
   moment to practice "ask the AI, then verify." It connects directly to the line already
   in `lab1_intro_to_.R:218`: *"Errors are normal. Read them, search them, ask a neighbor
   or the AI, then keep going."*

3. **Reinforce, don't repeat.** Lean on the existing "let's ask perplexity!" beats in later
   labs, and re-state the attribution rule when Assignment 1 is assigned (Week 5).

**One setup change:** list the AI-account setup under Week 1 (the first lab is the live RStudio
walkthrough), so students have a working, shareable AI account in hand for the Thursday tutorial.

**Why Week 1 and not later**
- It lands before Assignment 1 (due start of Week 5), which already requires AI attribution.
- It pairs with the moment students set up tools and hit their first errors, when AI is most useful.
- The lecture/lab split matches your Tue/Th rhythm and keeps each piece short.

**Alternative considered and rejected:** a full standalone "AI session." Cut because you asked
it not to eat a whole class, and because a single lecture teaches *about* AI without building
the habit of *using it well*.

---

## B. Lecture outline — "How I Use AI" (~15–20 min)

*Spine: AI is an earnest sophomore / a bright intern. Fast, eager, widely read, genuinely
helpful, and wrong often enough that you check everything. Every section returns to that.*

### 0. Hook (1 min)
- Open honest and meta: *"I used AI to help me figure out how I use AI for this talk. Then I
  checked all of it. That loop is the whole lecture."*
- Or open with a real artifact: the overnight Business Insider study. A reporter asked whether
  the AI / IPO wealth boom would displace San Franciscans. By morning I had a bibliography, a
  fact-check log, and a briefing. Here is how, and here is everything I did to make sure it was true.
- Thesis: *AI did not write my research. It changed how fast I can think, and how hard I check myself.*

### 1. The one mental model that matters (2 min)
- *"I call it an earnest sophomore. We think of it like an intern at work. Very helpful tool,
  but check everything."* [spoken, 03-13]
- It **synthesizes what is already known. It does not create new knowledge** and it does not
  know what is true. [syllabus AI Policy]
- So: **you are the domain expert.** The AI works for you, not the other way around. [syllabus]

### 2. What it is good at, and where it fails (3 min)
- **Good at:** explaining error messages, drafting boilerplate, translating formats (notes to
  draft, text to table), summarizing, scaffolding a literature search, "what am I missing?",
  getting unstuck.
- **Fails at:** facts and citations (hallucination), anything genuinely novel, anything that
  needs *your* data it has never seen, and knowing the limits of its own knowledge.
- **The tell:** *"That shit looks like AI."* [spoken, 03-24] Generic voice, em-dashes, chatty
  filler. If the output reads like AI, it is not finished.

### 3. How I actually use it: concrete stories (4 min)
*Show, don't lecture. Pick 3–4 of these.*
- **Real pipelines.** Claude Code helps me navigate a 16-state eviction-data pipeline (HUD-ERA:
  BART models, record linkage). I say what I want, it writes code, I review the *structure*,
  then I verify the *numbers*.
- **Overnight turnaround.** The IPO mini-study: AI research agents drafted a bibliography and
  briefing, then a *second* set of skeptical agents re-checked every one of ~110 citations,
  told to assume errors exist. Speed plus a verification harness.
- **Draft, then own.** I had AI draft a Marin County courts scope-of-work from meeting notes,
  then edited it into the final and kept a log of what I changed. AI gets me to a first draft.
  The judgment stays mine.
- **Structure out of mess.** Pulling addresses off *photographed* eviction dockets; turning
  court PDFs into a sequential timeline of what happened in each case. (I explained this one to
  the WA Attorney General's office.) [spoken, 02-06 / 02-23]
- **Meeting memory.** Every meeting transcribed and summarized locally. This lecture was built
  from six months of those notes.

### 4. My stack, and the local-vs-cloud decision (3 min)
- The spectrum: **cloud** (Perplexity, Claude) on one end, **local** on the other (Ollama +
  DeepSeek on my own machines, self-hosted search, local meeting transcription).
- **The decision rule:** *sensitive data or PII stays local and offline. Quick public lookups,
  cloud is fine.* *"I have a lot of names and PII that needs to be protected offline."* [typed,
  03-10] *"That is the one thing I am not putting anywhere near"* the cloud. [spoken, 03-31]
- Why local: privacy (we handle real people's eviction records), and *"local models are getting
  good enough that it totally makes sense."* [spoken, 04-21]
- **Cost is real too.** AI cuts the hours a study takes, but you still pay, in dollars or in
  your own verification time.
- For students: you will use the cloud slice (Perplexity). The *principles* are identical.

### 5. The discipline that makes it safe (4 min) — the real lesson
*The tools are easy. The discipline is the skill. This is the part employers actually want.*
- **Verify with a check, never assert.** A number's trustworthiness is *built by a check.*
  Triangulate every headline number against an independent source. [CODE_PHILOSOPHY.md]
- **Separate fact-checking from writing.** Make the AI list every number and where it came from
  *before* it writes a word of prose. [research_pedagogy.md]
- **Make it grade its own work.** *"Make sure there are no hallucinations."* [typed, 04-23]
  *"Give me a percentage of how certain you are that this is accurate."* [typed]
- **Keep a human in the middle.** *"There definitely needs to be a human in the middle to
  validate."* [spoken, 03-17]
- **Red-team before you publish.** Read your own draft as your harshest critic and answer the
  two best objections inside your text. [adversarial_review.md]
- **Make it your voice.** Strip the AI tells. Templates plus editing turn the AI's voice into
  *"your voice instead of AI's voice."* [spoken, 03-24]
- **Iterate.** Draft, refine, refine. The first answer is a starting point, not the deliverable.

### 6. What this means for you in this class (2 min)
- The one rule: use any AI tool that can produce a **public shareable link** to the conversation,
  and **hand me the link** (in code comments and writeup footnotes). Perplexity is the easy default
  (web + citations + one-click Thread sharing); ChatGPT, Gemini, and Claude also work. Free accounts
  are enough. Sign in with a *personal* account, not CalNet, so sharing works. [syllabus]
- Why disclosure: not to police you. So we can *see your process* and help you get better at it.
  Learning to use AI well is the job skill.
- The bar: AI helps you **learn faster, not skip the learning.** If you cannot explain what your
  code does, you are not done. Ask AI to *teach* you, not to *do it for you.*

### 7. Close (1 min)
- *AI is the most powerful intern you will ever manage. It will make you faster and braver. It
  will also be wrong with a straight face. Your job, in this class and after, is to be the
  expert who knows the difference.*

---

## C. Hands-on tutorial (~20–30 min, in Thursday's Lab 1)

*Goal: build three habits: ask well, verify, attribute. Students work in their chosen AI tool + RStudio.*

- **Setup (2 min).** Everyone has a free AI account that can share a public link (Perplexity is the
  easy default), signed in with a *personal* account (not CalNet), and Lab 1 open in RStudio.

- **Exercise 1: Debug a real error (8 min).**
  Give them a line of R that breaks (e.g., a `tidycensus` call with `library()` not loaded, or a
  misspelled variable). They: (a) read the error out loud, (b) paste it into their AI tool *with
  context* ("I'm new to R, using tidycensus, here's my code and the exact error"), (c) apply the
  fix, (d) paste the conversation's **share link** into a `#` comment next to the fix.
  *Lesson: AI as debugging companion + attribution as muscle memory.*

- **Exercise 2: Trust, then verify (8 min).**
  Ask the AI a domain question from the course, e.g. *"What is the difference between race
  and ethnicity in the U.S. Census?"* (the Lab 4 question) or *"What rent-burden threshold do
  housing researchers use, and why 30%?"* Then verify the answer against the primary source
  (Census documentation or the Walker book). Where was it right? Where did it hedge or overreach?
  *Lesson: AI synthesizes; you confirm. This is the hallucination check in miniature.*

- **Exercise 3: Prompt craft, before and after (6 min).**
  Run a vague prompt ("explain this code") and a sharp one ("explain what each line of this
  tidycensus call does, assume I am new to R, and flag anything that could break"). Compare.
  *Lesson: output quality tracks input quality.*

- **Wrap (3 min).** The attribution checklist for assignments, plus the link test: open your
  share link in an incognito window to confirm I can actually read it. And the one line to
  remember: *if you can't explain it, you don't understand it yet. Use AI to close that gap, not
  hide it.*

- **Optional 2-min demo (don't require):** show your local stack or Claude Code on a real repo,
  so students see where this goes professionally. Frame it as horizon, not homework.

---

## D. One judgment call for you: the attribution "double standard"

The research surfaced a real tension worth deciding deliberately:
- **Students** must disclose *every* AI use with a URL (learning integrity, we want to see process).
- **Your finished research** is deliberately de-fingerprinted: you delete `+ Claude`, avoid
  em-dashes, rewrite to your own voice. *"I had Claude create"* it, then made it yours. [spoken, 05-18]

These are not in conflict, but students will notice. The clean teaching resolution: **context sets
the norm.** In a *class*, disclosure shows your learning. In *professional authorship*, you take full
ownership and responsibility for the final product, which is exactly why it must read in your voice
and be verified by you, not the AI's. Both are about responsibility, at different stages.

**Your call:** teach this tension openly (I think it is a great, honest teaching moment and fits your
transparency ethos), or keep the lecture simple and only state the student rule. I drafted it as the
former in §6; easy to cut.

---

## E. Sourced quotes you can drop into slides

Verbatim-yours, with provenance, so you can trust them on a slide:
- *"I call it an earnest sophomore... an intern at work... very helpful tool, but check everything."* [spoken, 03-13]
- *"I call it the Pie Chart with a Bayesian Chaser... we use massive models to create simple and easily readable results."* [typed, 03-15]
- *"Doing local large language models is kind of our jam because of the privacy issue."* [spoken, 03-17]
- *"There definitely needs to be a human in the middle to validate."* [spoken, 03-17]
- *"I have a lot of names and PII that needs to be protected offline."* [typed, 03-10]
- *"Make sure there are not hallucinations."* [typed, 04-23]
- *"Templates help things become more like your voice instead of AI's voice."* [spoken, 03-24]
- *"I've guided Claude to where I want it to go... it's more of a pedagogy rather than exact content."* [typed, 05-11]

From your syllabus AI Policy (your teaching voice, ready to quote):
- *"AI excels at synthesizing information but does not create new knowledge."*
- *"You are the domain expert. Ensure that AI is working for you."*
- *"Always critically evaluate and verify AI-generated content."*

---

## Notes for your edit pass
- The lecture is built to run ~15–20 min spoken. If you want a tight 10, cut §2 and §4 to one line each.
- Everything in §3 is a real, checkable example from your own work; swap in whichever 3–4 you tell best.
- If you want, next step I can turn §B into a slide deck (Quarto/Google Slides) and §C into a one-page
  student lab handout.
