# DRAFT — email reply to Tim re: "Ram upgrade" (for Aaron's review; do not send as-is)

**In reply to:** Tim Thomas, "Ram upgrade," Tue Jul 7 2026 12:32 PM ("can you bump my RStudio memory to about 16gb of Ram per user?")
**From:** aculich@berkeley.edu
**To:** timthomas@berkeley.edu
**Subject:** Re: Ram upgrade

---

Hi Tim,

On it — request is drafted and ready to file. One adjustment first: I'm going to ask for **4 GB per student, not 16**, and I want to give you the quick math on why, because hub memory works differently from a laptop.

**The multiplication is the whole story.** On your laptop, 16 GB is one machine you own — and macOS, Chrome, Zoom, and Slack are eating most of it before RStudio gets a byte. On DataHub, whatever number we ask for is a **per-student reservation, multiplied across the class, held for the whole term**:

- 16 GB × 50 students = **800 GB** of RAM the university has to keep provisioned for us
- 4 GB × 50 students = 200 GB — which is exactly the auto-approval ceiling for requests longer than a month

And a hub session goes further per GB than a laptop: each student's pod runs *only their R session* — no OS, no browser, no Zoom. A "16 GB laptop" is realistically giving R maybe 2–4 GB.

**The track record backs this up.** I went through every RAM request ever filed with the DataHub team (~60 issues):

- A 16 GB ask was refused outright — staff stated the ceiling is **8 GB for instructors, 12 GB for staff**, and redirected the instructor to restructure their data instead.
- **LEGALST 123 asked for exactly what we need — 4 GB × 50 students — and was approved in 5 days.**
- Carl Boettiger's spatial courses (ESPM-157/288) run on 4 GB. That's the established baseline for geospatial teaching here, and their stack is heavier than ours.

**Our actual numbers:** I profiled all five labs. Each lab alone peaks at 484–874 MB; running more than one in a session hits ~1 GB — which is the current cap, and why students were dying mid-lab-4. Final projects (students pulling tract-level Census data with geometry for their own states) land in the 2–4 GB range. So 4 GB covers everything with headroom, and it's a number that sails through.

**If a specific assignment ever genuinely needs more,** there's a clean path: date-bounded bumps for a single assignment window (Astro 128 got 8 GB for just their final lab), or extra RAM for only a project-group subset. We don't need to pay the big-number tax all term.

The GitHub issue draft is ready in the course repo (`website/maintainer/datahub-resource-request-draft.md`) — it includes your original email for context. Two things I need from you:

1. Confirm expected enrollment (~50?)
2. Confirm bCourses course 1555635 is set to **Published** (the hub reads enrollment from it)

Say the word and I'll file it — with luck it's live before Thursday's lab.

Best,

Aaron Culich
Data Science Director, Eviction Research Network <https://evictionresearch.net/>
