# ==========================================================================
# Lab 6 (bonus): Reading a real risk model -- the Housing Precarity Risk Model
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# This lab is optional and self-study. We do not walk through it in class.
#
# All term you have BUILT measures. This lab has you READ one: the Housing
# Precarity Risk Model (HPRM), the model behind the map in the August 4
# lecture and behind testimony to the Washington State Senate. Every census
# tract in the country carries a score from 0 to 8.
#
# There are two ways to work through this, and you should pick one on
# purpose:
#
#   THE SHORT PATH (sections 1-6). Load the scores, find your county, chart
#   what you see, and read the model's answer for a place you know. Every
#   line uses verbs you already own from labs 1 through 3. If code has felt
#   like a fight this term, this path is the whole lab. It is enough.
#
#   THE LONG PATH (sections 1-10). Everything above, plus: take the score
#   apart into its two channels, put the model's numbers next to the ones
#   YOU built in lab 3, and find where the model and your own measure
#   disagree. Section 10 turns the disagreement into a final-project angle.
#
# WHERE THIS SITS IN THE COURSE
#   Lab 3 gave you rent burden. Lab 4 gave you evictions and maps. Lab 5
#   gave you segregation. The HPRM is what happens when someone spends
#   several years combining all three, plus court records and a big
#   national survey that tracks where people move, into one number per
#   neighborhood. You are about to look under its hood.
#
# A NOTE ON DIFFICULTY. This lab uses a few functions you have not seen
# before. Every one of them is explained where it appears, in one or two
# plain sentences, and none of them are hard. Where something is genuinely
# a topic for a later course, it is marked FURTHER TRAINING and you can
# skip it without losing the thread.

library(tidyverse)

# ==========================================================================
# 1. Open the data and look at it
# ==========================================================================
# One file, one line. (The full path works from any folder.)

hprm <- read_rds("~/SOC-N100-Housing-Precarity-2026/data/hprm/hprm_tract_2022.rds")

# The lab 1 habit: before you do anything, look.

glimpse(hprm)

# 83,507 rows -- one per census tract -- and 24 columns. Every state except
# Alaska and Hawaii, plus DC. (If your project area is in AK or HI, this
# lab still teaches the ideas, but you will not find your tracts. Pick a
# comparison area you are curious about instead.)
#
# The vintage is 2022, which matters for one practical reason: it is built
# on the SAME census tract boundaries as the 2024 ACS data you have been
# pulling all term. Your GEOIDs will line up. (This is not automatic. Tract
# boundaries were redrawn for the 2020 Census, so a 2019-vintage file would
# NOT join cleanly to your 2024 pulls.)

# ==========================================================================
# 2. Two kinds of columns (three, really) -- and why every chart depends on it
# ==========================================================================
# We have been using this distinction all term without naming it. Name it
# now, because the rest of the lab leans on it and so does your final
# project.
#
# CONTINUOUS -- a number where the arithmetic means something.
#   p_hh_rent_burden (0.374), med_rent (2335), medinc (164000).
#   You can average it, subtract it, and put it on an axis with a scale.
#   "The average rent burden across these tracts is 38%" is a sentence.
#
# CATEGORICAL -- a label that sorts each row into a bucket.
#   neigh_type ("Black-White", "Latine-White"), state, county.
#   You can count it and you can group by it. You cannot average it.
#   "The average of Black-White and Latine-White" is not a thing.
#
# ORDINAL -- categories that have an ORDER but no guaranteed spacing.
#   edr_risk and eer_risk run "At Risk" < "Elevated" < "High" < "Extreme".
#   data_reliability runs "Good" < "Fair" < "Caution" < "Unreliable".
#   You know which is worse. You do NOT know that the step from High to
#   Extreme is the same size as the step from At Risk to Elevated.
#   Treat ordinal as categorical unless you have a reason not to -- and if
#   you do treat it as a number, say so out loud in your writeup.
#
# WHY THIS IS THE WHOLE GAME FOR CHARTS
#
# Look at lab 3's chart-picker card again with these words in hand:
#
#   one continuous variable                 -> histogram
#   one continuous, split by a categorical  -> bar chart, or boxplot
#   two continuous variables                -> scatter plot
#   one continuous, across time             -> line chart
#
# You do not memorize that card. You read the types off your columns and
# the right chart falls out. Every plot in section 5 below is labeled with
# the pairing it answers, so you can watch the rule work.
#
# Ask R what it thinks a column is:

class(hprm$p_hh_rent_burden)   # "numeric"  -> continuous
class(hprm$neigh_type)         # "character" -> categorical
class(hprm$edr_risk)           # "character" -> ordinal, but R cannot tell

# That last line is the catch worth remembering. R sees "High" and
# "Extreme" as plain text with no order at all, which is why a chart of
# risk levels comes out alphabetized unless you tell R the order yourself.
# Section 5.2 shows the fix.
#
# ONE MORE TRAP, and it is the one that bites hardest. hprm_score looks
# continuous -- it is 0 through 8 and you can average it. It is really
# ordinal: a tract scoring 8 is not "twice as precarious" as one scoring 4.
# Averaging it is a reasonable summary. Saying "twice as bad" is not.

# ==========================================================================
# 3. Your county
# ==========================================================================
# Lab 1's filter(), on a table 83,507 rows long. Swap in your own area.

alameda <- hprm %>%
  filter(state == "CA", county == "Alameda County")

nrow(alameda)

# The highest-scoring tracts, most precarious first. arrange() + desc()
# from lab 1, then a small select() so the result fits on screen.

alameda %>%
  arrange(desc(hprm_score)) %>%
  select(tract, hprm_score, edr_risk, eer_risk, p_hh_rent_burden, med_rent) %>%
  head(10)

# YOUR TURN (1): change the filter above to your project area and re-run.
# Which tract scores highest? Do you know anything about that neighborhood
# from outside this dataset -- news, family, a place you have lived?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 4. What the score is made of: two channels
# ==========================================================================
# The 0-8 score is not one thing. It is two risks added together, and they
# mean opposite halves of this course:
#
#   edr_score (0-4): DISPLACEMENT risk. The SOFT displacement of week 2 --
#     low-income renters draining out of a neighborhood over time. Nobody
#     gets served papers; the neighborhood simply stops being affordable.
#
#   eer_score (0-4): EVICTION risk. HARD displacement -- court filing rates
#     running above what that state's norm would predict.
#
#   hprm_score = edr_score + eer_score, which is why it runs 0 to 8.
#
# So a 6 can mean very different things. A tract at edr 4 / eer 2 has a
# rent problem. A tract at edr 2 / eer 4 has a courtroom problem. Same
# score, different policy, and the four P's from the August 4 lecture
# split exactly along this line: Prevent and Protect aim at the eviction
# channel, Preserve and Produce at the displacement channel.
#
# NOW A WARNING, because this one catches everybody. If a tract was not
# flagged on a channel, that channel is not 0. It is NA, R's word for
# "missing." The total score still treats it as a zero, but the channel
# column itself says NA. Watch what that does:

mean(alameda$eer_score)                 # NA -- one missing value ruins the whole answer
mean(alameda$eer_score, na.rm = TRUE)   # a number, but read the next paragraph

# na.rm = TRUE means "ignore the missing ones." That is not wrong, but
# notice what you just asked for. You threw away every unflagged tract, so
# the answer is "among tracts that WERE flagged, how bad is it?" -- not
# "how bad is this county?"
#
# If you want all tracts counted, turn the missing values into real zeros
# first. coalesce() does exactly that, and it is worth learning because you
# will need it constantly:
#
#   coalesce(eer_score, 0)  =  "use eer_score, but where it is NA, use 0"

alameda %>%
  summarize(
    flagged_tracts_only = mean(eer_score, na.rm = TRUE),
    all_tracts          = mean(coalesce(eer_score, 0))
  )

# Two honest numbers. Two different questions. Whichever you report, say in
# words which one it is.

# ==========================================================================
# 5. Charts, chosen by variable type
# ==========================================================================
# Each chart below names its pairing from section 2. Watch the rule work.

# --------------------------------------------------------------------------
# 5.1 One continuous variable -> histogram
# --------------------------------------------------------------------------
# How is rent burden spread across this county's tracts?

ggplot(alameda, aes(x = p_hh_rent_burden)) +
  geom_histogram(bins = 30, fill = "steelblue", color = "white") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(
    title = "Rent burden across Alameda County tracts",
    x = "Share of renter households paying 30%+ of income to rent",
    y = "Number of tracts"
  ) +
  theme_minimal()

# --------------------------------------------------------------------------
# 5.2 One continuous, split by a categorical -> boxplot
# --------------------------------------------------------------------------
# Does rent burden differ by displacement-risk level? Same shape as lab 5's
# question: one continuous column, split by one categorical column.
#
# But first we have to fix the order. R stores "High" and "Extreme" as
# plain text and has no idea one is worse than the other, so it falls back
# on alphabetical and the chart comes out scrambled. The fix is to hand R
# the order yourself. Write the levels out in the order you want, then wrap
# the column in factor():

risk_order <- c("At Risk/Early", "Elevated", "High", "Extreme")

alameda_ranked <- alameda %>%
  filter(!is.na(edr_risk)) %>%
  mutate(edr_risk = factor(edr_risk, levels = risk_order))

ggplot(alameda_ranked, aes(x = edr_risk, y = p_hh_rent_burden)) +
  geom_boxplot(fill = "steelblue", alpha = 0.6) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Rent burden rises with displacement risk",
    x = "Displacement risk level",
    y = "Share of renter households rent-burdened"
  ) +
  theme_minimal()

# Remember factor(). Any time a chart puts your categories in a silly
# order -- alphabetical when they should run low to high, or months
# starting with April -- this is the fix, and it is always this short.

# --------------------------------------------------------------------------
# 5.3 Two continuous variables -> scatter plot
# --------------------------------------------------------------------------
# Do income and rent burden move together across tracts?

ggplot(alameda, aes(x = medinc, y = p_hh_rent_burden)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, color = "darkred") +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Lower-income tracts carry more rent burden",
    x = "Median household income",
    y = "Share of renter households rent-burdened"
  ) +
  theme_minimal()

# --------------------------------------------------------------------------
# 5.4 One categorical -> a count, and a bar chart
# --------------------------------------------------------------------------
# Categorical variables get counted, not averaged. neigh_type is lab 5's
# segregation typology, already computed for every tract in the country.

alameda %>%
  count(neigh_type, sort = TRUE)

# YOUR TURN (2): pick one of the four chart shapes above, swap in a
# different column of the matching type, and re-run it for your own area.
# Which pairing did you use, and what did the chart tell you?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 6. The rent gap, explained
# ==========================================================================
# rent_gap is the one column in this file whose name will not tell you what
# it means, so here is the whole idea before any code.
#
# WHY WE WANT THIS MEASURE AT ALL. We are trying to spot neighborhoods that
# may be next. If the blocks all around a neighborhood have gotten
# expensive and that one neighborhood is still cheap, it stands out. Renters
# priced out of the surrounding area start looking at it. Landlords and
# buyers notice the same thing. Over time the cheaper neighborhood can get
# bought up and its current residents replaced -- one group of people
# steadily giving way to another. Sociologists call that SUCCESSION.
#
# So the rent gap is an early-warning measure. It does not say a
# neighborhood is being displaced right now. It says the pressure to change
# is sitting right next door.
#
# THE IDEA BEHIND IT. Neil Smith argued in the late 1970s that
# neighborhoods get money poured into them not when they are doing well,
# but when there is a GAP between what the land earns now and what it COULD
# earn given where it sits. A cheap block surrounded by expensive blocks is
# an opportunity, and eventually somebody acts on it.
#
# AND THE IMPORTANT CATCH, which you should carry into your final project.
# A rent gap tells you a neighborhood is cheap relative to its neighbors.
# It does NOT tell you why. Sometimes the answer really is "nobody has
# gotten around to it yet." But sometimes a place stays cheap because
# better-off newcomers do not actually want to move there -- a freeway or
# rail yard next door, polluted land, poor transit, few services, or plain
# old racist reputation. Those neighborhoods can carry a big rent gap for
# decades and never gentrify at all.
#
# That means a rent gap is a QUESTION, not a verdict. When you find one,
# the honest next move is to go find out what else is true about that
# place. That is where your sociology does work no column can do for you.
#
# THE MEASURE, second. The HPRM builds it by comparing each tract to its
# own neighbors:
#
#   rent_gap = (rent nearby) - (rent here)
#
# "Nearby" means the tracts around this one, with closer tracts counting
# for more than farther ones.
#
# [FURTHER TRAINING] The technical name for a "what is going on around me"
# column is a spatial lag. Skip it -- you do not need it for this lab. If
# you take a mapping or spatial statistics course later, it is one of the
# first ideas you will meet, and you will already know what it does.
#
# So:
#
#   POSITIVE rent_gap -> this tract is CHEAPER than its surroundings.
#     That is the gap Smith was describing: upgrade pressure, and a reason
#     to watch the neighborhood.
#
#   NEGATIVE rent_gap -> this tract is MORE expensive than its surroundings.
#     Often an already-wealthy pocket.
#
# It is measured in dollars per month, so dollar_format() on the axis.

alameda %>%
  arrange(desc(rent_gap)) %>%
  select(tract, med_rent, rent_gap, hprm_score, edr_risk) %>%
  head(10)

# Read that table slowly. These are the tracts renting well below their own
# neighborhood. Now see whether the gap tracks the model's displacement
# channel -- two continuous variables, so section 2 says scatter:

ggplot(alameda, aes(x = rent_gap, y = p_hh_rent_burden)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey40") +
  scale_x_continuous(labels = scales::dollar_format()) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Rent gap and rent burden",
    subtitle = "Right of the dashed line: cheaper than the neighborhood around it",
    x = "Rent gap (nearby rent minus this tract's rent)",
    y = "Share of renter households rent-burdened"
  ) +
  theme_minimal()

# One last caution, and it is the one Marcuse made in the August 4 lecture.
# Everyone in this dataset still lives here. The households hit hardest by
# a neighborhood getting expensive are often the ones who ALREADY left, and
# they are not in any of these rows. A tract can look calm precisely
# because the people under the most pressure are already gone.

# ==========================================================================
# 7. The eviction clock
# ==========================================================================
# tte_total_period is the number of days a tenant has, start to finish,
# under that state's eviction statute. It is one of the model's inputs --
# not an outcome, an INPUT -- which is the whole argument of the August 4
# lecture in one column: where you live decides how much time you get.

hprm %>%
  group_by(state) %>%
  summarize(days = first(tte_total_period)) %>%
  arrange(days) %>%
  head(10)

hprm %>%
  group_by(state) %>%
  summarize(days = first(tte_total_period)) %>%
  arrange(desc(days)) %>%
  head(10)

# Run both and compare the two lists. The slowest states give a tenant
# something like ten times as many days as the fastest ones. That is not a
# small difference. Two renters with the same income, the same rent, and
# the same landlord get wildly different amounts of time to find the money,
# find a lawyer, or find a new apartment, purely because of which side of a
# state line they sleep on.
#
# YOUR TURN (3): find your state's number. Then find a neighboring state's.
# What would those extra (or missing) days mean for a household trying to
# find rent money, a lawyer, or a new apartment?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 8. LONG PATH: your measure, the model's input, and the model's answer
# ==========================================================================
# This is the section worth the price of the lab, and it runs in two steps.
#
# Step one checks your work. You built a rent-burden measure from raw
# Census tables in lab 3; the model has its own. Do they agree?
#
# Step two is the real lesson. Rent burden is ONE INPUT to the HPRM. The
# score is the model's ANSWER. Comparing the two shows you what a model
# adds over any single indicator -- which is the difference between a
# statistic and an argument.
#
# Pull your lab 3 measure again for the same county. This is lab 3's build,
# unchanged, except we ask for 2022 to match the HPRM's vintage.

library(tidycensus)

rb_raw <- get_acs(
  geography = "tract",
  table     = "B25070",
  state     = "CA",
  county    = "Alameda",
  year      = 2022,
  survey    = "acs5"
)

# Lab 3's reshape and build: drop moe, widen, then divide the burdened
# categories by the universe.

rb_mine <- rb_raw %>%
  select(-moe, -NAME) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  mutate(
    burdened = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    universe = B25070_001,
    my_rb    = burdened / universe
  ) %>%
  select(GEOID, my_rb)

# Lab 4's join, on GEOID. The HPRM calls it geoid, lowercase, so name both
# sides of the by = argument.

compare <- alameda %>%
  left_join(rb_mine, by = c("geoid" = "GEOID"))

# Did every tract match? An unmatched join shows up as NA.

sum(is.na(compare$my_rb))

# Expect one or two. The Census publishes a few tracts the model has no
# score for -- typically tracts with almost nobody living in them.

# --------------------------------------------------------------------------
# 8.1 Step one: your measure vs. the model's input
# --------------------------------------------------------------------------
# Two continuous variables, so section 2 says: scatter.

ggplot(compare, aes(x = my_rb, y = p_hh_rent_burden)) +
  geom_point(alpha = 0.5, color = "steelblue") +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "darkred") +
  scale_x_continuous(labels = scales::percent_format()) +
  scale_y_continuous(labels = scales::percent_format()) +
  labs(
    title = "Your measure vs. the model's",
    subtitle = "Dashed line = perfect agreement",
    x = "Rent burden, your lab 3 build",
    y = "Rent burden, HPRM"
  ) +
  theme_minimal()

# The points sit right on the dashed line. Put a number on it with cor():

cor(compare$my_rb, compare$p_hh_rent_burden, use = "complete.obs")

# cor() is new, and it is the easiest new thing in this lab. It gives ONE
# number for "do these two columns move together?"
#
#    1  = they move in perfect lockstep
#    0  = knowing one tells you nothing about the other
#   -1  = when one goes up, the other goes down, perfectly
#
# (The use = "complete.obs" part just says "skip rows with missing values.")
#
# This comes back at essentially 1.00, and that is a good result: the
# measure you built by hand in a summer lab is the same measure a research
# team put in a national model. Nothing mystical happened inside the HPRM
# at this step. It read the same table you did.

# --------------------------------------------------------------------------
# 8.2 Step two: your measure vs. the model's ANSWER
# --------------------------------------------------------------------------
# Now swap the y-axis for the 0-8 score and watch the tight line fall apart.

ggplot(compare, aes(x = my_rb, y = hprm_score)) +
  geom_jitter(height = 0.2, alpha = 0.5, color = "steelblue") +
  geom_smooth(method = "lm", se = TRUE, color = "darkred") +
  scale_x_continuous(labels = scales::percent_format()) +
  labs(
    title = "Rent burden is one input, not the answer",
    x = "Rent burden, your lab 3 build",
    y = "HPRM score (0-8)"
  ) +
  theme_minimal()

cor(compare$my_rb, compare$hprm_score, use = "complete.obs")

# (geom_jitter() is geom_point() with a nudge: it scoots points a hair
# apart so you can see how many sit at each score. Plain points would
# stack on top of each other in nine flat rows.)
#
# Last time cor() gave us 1.00. This time it is far lower. The two things
# are related, but rent burden is nowhere near the whole story, because
# the model also knows things your one measure cannot see: where
# low-income renters actually MOVED, how often courts in that county
# issue filings, and how many days the state gives a tenant before the
# clock runs out.
#
# The interesting tracts are the ones that break the pattern. Here are the
# neighborhoods where more than half of renters are rent-burdened and the
# model STILL says risk is low:

compare %>%
  filter(my_rb >= 0.5, hprm_score <= 1) %>%
  select(tract, my_rb, hprm_score, medinc, rent_gap, data_reliability) %>%
  arrange(desc(my_rb))

# These are neighborhoods where lots of renters are stretched thin and the
# model still says risk is low. The model is not contradicting you. It is
# saying: expensive, yes, but these renters are not being pushed out and
# they are not being hauled into court.
#
# That is the difference in one line. Your rent-burden number says how hard
# things are RIGHT NOW. The score is a guess about what happens NEXT.
#
# YOUR TURN (4): run the block above for your own area, then flip it --
# find tracts with LOW rent burden and a HIGH score. What could make a
# neighborhood risky that a rent-burden number would never reveal?
# [PUT YOUR ANSWER BELOW]


# ==========================================================================
# 9. LONG PATH: how much should you trust any one tract?
# ==========================================================================
# All term you have been told that tract-level Census estimates are shaky
# and that the honest move is to use tracts for PATTERNS, not for ranking
# individual neighborhoods. This file ships that warning as a column.

hprm %>%
  count(data_reliability)

# Four levels, ordinal: Good, Fair, Caution, Unreliable. It summarizes how
# much survey noise sits under a tract's numbers -- driven mostly by how
# few households were actually sampled there.
#
# The practical rule for your final project: you may chart every tract, but
# do not name a single tract in a policy recommendation unless its
# reliability is Good or Fair. See what dropping the shaky ones does:

alameda %>%
  filter(data_reliability %in% c("Good", "Fair")) %>%
  arrange(desc(hprm_score)) %>%
  select(tract, hprm_score, data_reliability, p_hh_rent_burden) %>%
  head(10)

# Compare that list to section 3's. If a tract fell off, it was never
# solid enough to build an argument on.
#
# A KNOWN ISSUE, disclosed rather than hidden, because you may well find
# it: there are tracts carrying a displacement-risk LABEL (edr_risk) while
# their edr_score is NA, which means the 0-8 total counts that channel as
# zero. Nationally that affects about 4,600 tracts. If you hit one, you
# have found a real inconsistency in a working research dataset, not a
# mistake of your own. Flag it in your writeup and move on. Finding this
# kind of thing is what reading someone else's data actually looks like.

# ==========================================================================
# 10. Where this goes in your final project
# ==========================================================================
# Three ways groups have used a model like this:
#
#   AS A COMPARISON. Build your own measure, then show where the
#   professional model agrees and disagrees. Disagreement is a finding.
#
#   AS A TARGETING TOOL. Bates (2013) argued the tool has to match the
#   stage. Split your area's high-scoring tracts by CHANNEL -- displacement
#   dominant vs. eviction dominant -- and recommend a different P for each.
#   That is a policy recommendation with evidence under it, which is where
#   the bonus points live.
#
#   AS A DISPARATE-IMPACT TEST. The file carries p_black, p_latine,
#   p_white, p_asian, and neigh_type. Group the score by neighborhood type
#   and you are testing the course's central claim directly.
#
# WHAT TO CARRY OUT OF THIS LAB, whichever path you took:
#   1. Continuous, categorical, ordinal -- and the chart each pairing wants
#   2. A score can be a SUM of channels that mean different things
#   3. NA is not zero, and which one you use changes the sentence
#   4. A rent gap is pressure, not proof
#   5. Somebody's statute is somebody else's model input
#   6. Real research data has open problems in it, and saying so is the job
