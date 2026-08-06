# Eviction Data Atlas maps — SOC-N100 Week 5 lecture, slide S4.
#
# Two views of the same verified data:
#   1. a tile grid, where every state is the same size, so the COUNT is honest
#   2. a geographic map, where you can see WHERE the gaps actually sit
#
# The tile grid exists because a geographic map lies about counts: Montana is
# enormous and Delaware is a speck, so a real map makes empty western states
# look like most of the country. Showing both is the point.
#
# Source of truth: evictionresearch/library data/eviction_data_atlas/atlas.json
# (evidence-only sweep dated 2026-07-17, 373 URLs link-checked).
# Nothing here is hardcoded — if the atlas is rebuilt, rerun this and the
# figures follow.

library(sf)
library(ggplot2)
library(dplyr)
library(jsonlite)
library(tigris)

options(tigris_use_cache = TRUE)

atlas_path <- path.expand(
  "~/git/evictionresearch/library/data/eviction_data_atlas/atlas.json"
)
out_dir <- path.expand(
  "~/git/evictionresearch/SOC-N100-Housing-Precarity-2026/output"
)

atlas <- fromJSON(atlas_path, simplifyVector = FALSE)

# ---- 1. flatten the per-state records -------------------------------------

# `tile` is a [column, row] coordinate pair the atlas already carries for a
# tile-grid layout: column 0 is the west edge, row 0 is the north edge.
prog_keys <- c(lsc = "LSC", ets = "ETS", edrn = "EDRN", ern = "ERN")

# which of the four national programs touch a state, as a printable tag string
# wrap to two lines past two programs, or "LSC ETS EDRN ERN" runs off the tile
prog_tags <- function(s) {
  p <- s$programs
  on <- names(prog_keys)[vapply(names(prog_keys),
                                function(k) isTRUE(p[[k]]), logical(1))]
  if (!length(on)) return("")
  tags <- unname(prog_keys[on])
  if (length(tags) <= 2) paste(tags, collapse = " ")
  else paste(paste(tags[1:2], collapse = " "),
             paste(tags[-(1:2)], collapse = " "), sep = "\n")
}

atlas_df <- tibble(
  abbr = vapply(atlas$states, function(s) s$abbr, character(1)),
  name = vapply(atlas$states, function(s) s$name, character(1)),
  fips = vapply(atlas$states, function(s) s$fips, character(1)),
  tier = vapply(atlas$states, function(s) s$tier_public, character(1)),
  col  = vapply(atlas$states, function(s) s$tile[[1]], integer(1)),
  row  = vapply(atlas$states, function(s) s$tile[[2]], integer(1)),
  tags = vapply(atlas$states, prog_tags, character(1)),
  n_prog = vapply(atlas$states,
                  function(s) sum(vapply(names(prog_keys),
                                         function(k) isTRUE(s$programs[[k]]),
                                         logical(1))), integer(1))
)

stopifnot(nrow(atlas_df) == 51)

# Guard: the slide copy names these sets out loud, so fail loudly if the atlas
# moves underneath the lecture.
stopifnot(
  identical(sort(atlas_df$abbr[atlas_df$tier == "case_public_statewide"]),
            c("AK", "CT", "DC", "MD", "NY", "VA")),
  identical(sort(atlas_df$abbr[atlas_df$tier == "local_public_only"]),
            c("LA", "MS", "TN")),
  identical(sort(atlas_df$abbr[atlas_df$tier == "none_public"]),
            c("AL", "AR", "IA", "KS", "MT", "SD"))
)

# tier counts, for the legend labels
tier_n <- table(atlas_df$tier)

tier_levels <- c("case_public_statewide", "counts_public_statewide",
                 "local_public_only", "none_public")

tier_labels <- c(
  case_public_statewide   = sprintf("Case-level, statewide  (%d)",
                                    tier_n[["case_public_statewide"]]),
  counts_public_statewide = sprintf("Counts only  (%d)",
                                    tier_n[["counts_public_statewide"]]),
  local_public_only       = sprintf("Local data only  (%d)",
                                    tier_n[["local_public_only"]]),
  none_public             = sprintf("Nothing published currently  (%d)",
                                    tier_n[["none_public"]])
)

pal <- c(
  case_public_statewide   = "#003262",  # Berkeley blue — we can see the cases
  counts_public_statewide = "#A8C4DA",  # pale — a number, not people
  local_public_only       = "#E8A33D",  # amber — patchy
  none_public             = "#A83232"   # red — dark
)

# label ink that survives each fill
ink <- c(
  case_public_statewide   = "#FFFFFF",
  counts_public_statewide = "#123A56",
  local_public_only       = "#3D2A08",
  none_public             = "#FFFFFF"
)

atlas_df <- atlas_df |>
  mutate(tier = factor(tier, levels = tier_levels))

cap <- paste0(
  "Eviction Research Network, Eviction Data Atlas — 50 states + DC, July 2026 census.\n",
  "Of the six publishing nothing, AR, KS and MT still appear in Legal Services Corporation files.\n",
  "AL, IA and SD are dark from any source."
)

base_theme <- theme_void(base_size = 22) +
  theme(
    legend.position   = "top",
    legend.title      = element_blank(),
    legend.text       = element_text(size = 19, margin = margin(r = 22)),
    legend.key.size   = unit(1.1, "lines"),
    plot.caption      = element_text(size = 16, hjust = 0, colour = "#5A6570",
                                     lineheight = 1.35,
                                     margin = margin(t = 18)),
    plot.margin       = margin(18, 26, 14, 26)
  )

# two rows keeps the four labels inside the canvas at slide scale
legend_two_rows <- guides(fill = guide_legend(nrow = 2, byrow = TRUE))

# ---- 2. the tile grid ------------------------------------------------------

# y is negated so row 0 lands at the top of the plot
p_tile <- ggplot(atlas_df, aes(x = col, y = -row)) +
  geom_tile(aes(fill = tier), width = 0.9, height = 0.9) +
  geom_text(aes(label = abbr, colour = tier),
            size = 8, fontface = "bold", show.legend = FALSE) +
  scale_fill_manual(values = pal, labels = tier_labels, drop = FALSE) +
  scale_colour_manual(values = ink, guide = "none") +
  coord_equal(clip = "off") +
  labs(caption = cap) +
  legend_two_rows +
  base_theme

ggsave(file.path(out_dir, "s4_atlas_tile.png"), p_tile,
       width = 13, height = 9.2, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s4_atlas_tile_preview.png"), p_tile,
       width = 13, height = 9.2, dpi = 150, bg = "white")

# ---- 3. the geographic map -------------------------------------------------

# cb_2020_us_state_20m is already in the tigris cache; shift_geometry moves
# Alaska and Hawaii under the lower 48 at a readable scale.
us <- states(cb = TRUE, resolution = "20m", year = 2020, progress_bar = FALSE) |>
  filter(!STATEFP %in% c("60", "66", "69", "72", "78")) |>   # drop territories
  shift_geometry() |>
  left_join(atlas_df, by = c("STATEFP" = "fips"))

stopifnot(!any(is.na(us$tier)))

# DC is ~68 square miles and vanishes at this scale, but it is one of the six
# case-level jurisdictions, so it gets an explicit marker rather than silence.
dc <- us |> filter(abbr == "DC") |> st_centroid()
dc_xy <- st_coordinates(dc)

p_geo <- ggplot(us) +
  geom_sf(aes(fill = tier), colour = "#FFFFFF", linewidth = 0.45) +
  geom_segment(x = dc_xy[1], y = dc_xy[2],
               xend = dc_xy[1] + 330000, yend = dc_xy[2] - 300000,
               colour = "#003262", linewidth = 0.8) +
  geom_point(x = dc_xy[1], y = dc_xy[2],
             size = 3.4, colour = "#003262") +
  annotate("point", x = dc_xy[1] + 400000, y = dc_xy[2] - 330000,
           size = 13, shape = 22, colour = "#003262", fill = "#003262") +
  annotate("text", x = dc_xy[1] + 400000, y = dc_xy[2] - 330000,
           label = "DC", size = 6, fontface = "bold", colour = "#FFFFFF") +
  scale_fill_manual(values = pal, labels = tier_labels, drop = FALSE) +
  coord_sf(clip = "off") +
  labs(caption = cap) +
  legend_two_rows +
  base_theme

ggsave(file.path(out_dir, "s4_atlas_map.png"), p_geo,
       width = 13, height = 8.6, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s4_atlas_map_preview.png"), p_geo,
       width = 13, height = 8.6, dpi = 150, bg = "white")

# ---- 4. who actually publishes: national program coverage ------------------

# A different question from "what tier is the state." Four national programs
# reach across state lines:
#   LSC  — Legal Services Corporation, Civil Court Data Initiative
#   ETS  — Eviction Lab (Princeton), Eviction Tracking System
#   EDRN — New America, Eviction Data Response Network (funder cohort, 2026-28)
#   ERN  — Eviction Research Network (this course's own shop)
# Everything else in the atlas is a single-state or single-city effort.

prog_pal <- c("0" = "#B0362F", "1" = "#E0A458", "2" = "#A8C4DA",
              "3" = "#4F81A8", "4" = "#003262")
prog_ink <- c("0" = "#FFFFFF", "1" = "#3D2A08", "2" = "#123A56",
              "3" = "#FFFFFF", "4" = "#FFFFFF")

prog_df <- atlas_df |>
  mutate(nf = factor(n_prog, levels = 0:4))

n_none <- sum(prog_df$n_prog == 0)

cap2 <- paste0(
  "LSC = Legal Services Corporation, Civil Court Data Initiative (32 states).\n",
  "ETS = Eviction Lab, Princeton — tracking system (11 states + 42 cities).\n",
  "EDRN = New America Eviction Data Response Network, 2026-28 cohort (11 states).\n",
  "ERN = Eviction Research Network, UC Berkeley (8 state and city profiles).\n",
  "A state with no national program may still publish its own data — DC does."
)

p_prog <- ggplot(prog_df, aes(x = col, y = -row)) +
  geom_tile(aes(fill = nf), width = 0.9, height = 0.9) +
  geom_text(aes(label = abbr, colour = nf),
            nudge_y = 0.13, size = 7, fontface = "bold", show.legend = FALSE) +
  geom_text(aes(label = tags, colour = nf),
            nudge_y = -0.19, size = 3.1, show.legend = FALSE) +
  scale_fill_manual(
    values = prog_pal, drop = FALSE,
    labels = c("No national program", "One", "Two", "Three", "All four")
  ) +
  scale_colour_manual(values = prog_ink, guide = "none") +
  coord_equal(clip = "off") +
  labs(caption = cap2) +
  guides(fill = guide_legend(nrow = 1)) +
  base_theme

ggsave(file.path(out_dir, "s4_national_programs.png"), p_prog,
       width = 13, height = 9.2, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s4_national_programs_preview.png"), p_prog,
       width = 13, height = 9.2, dpi = 150, bg = "white")

# ---- 5. what geography can you actually analyze? ---------------------------

# The tier map answers "does the state publish anything." This answers the
# question a student actually hits in week one of a project: how small a
# geography can I get to?
#
# The hinge is ADDRESSES. If a source carries defendant addresses you can
# geocode and aggregate to any geography you like — tract, neighborhood,
# council district. If it doesn't, you are stuck with whatever the publisher
# chose to aggregate to, and that is usually the county.

src <- read.csv(
  file.path(dirname(atlas_path), "eviction_data_atlas.csv"),
  stringsAsFactors = FALSE
)

rank_geo <- c(address = 1, parcel = 1, tract = 2, zip = 3, city = 4,
              "judicial district" = 4, county = 5, state = 6)

act <- src |>
  filter(status == "active") |>
  mutate(
    has_addr   = addresses %in% c("yes", "partial"),
    is_statewide = grepl("statewide|district-wide", coverage,
                         ignore.case = TRUE),
    geo_rank   = unname(ifelse(is.na(rank_geo[smallest_geography]), 7L,
                               rank_geo[smallest_geography]))
  )

geo_df <- act |>
  group_by(state) |>
  summarise(
    addr_sw    = any(has_addr & is_statewide),
    addr_any   = any(has_addr),
    best_geo   = min(geo_rank),
    .groups = "drop"
  ) |>
  mutate(geo_cat = case_when(
    addr_sw            ~ "addr_statewide",
    addr_any           ~ "addr_local",
    best_geo <= 3      ~ "subcounty_only",
    TRUE               ~ "county_coarser"
  ))

geo_levels <- c("addr_statewide", "addr_local", "subcounty_only",
                "county_coarser")

geo_plot <- atlas_df |>
  left_join(geo_df, by = c("abbr" = "state")) |>
  mutate(
    geo_cat = factor(ifelse(is.na(geo_cat), "county_coarser", geo_cat),
                     levels = geo_levels)
  )

geo_n <- table(geo_plot$geo_cat)

geo_pal <- c(addr_statewide = "#003262", addr_local = "#4F81A8",
             subcounty_only = "#A8C4DA", county_coarser = "#B0362F")
geo_ink <- c(addr_statewide = "#FFFFFF", addr_local = "#FFFFFF",
             subcounty_only = "#123A56", county_coarser = "#FFFFFF")

geo_labs <- c(
  addr_statewide = sprintf("Addresses, statewide  (%d)", geo_n[["addr_statewide"]]),
  addr_local     = sprintf("Addresses, one city or county  (%d)", geo_n[["addr_local"]]),
  subcounty_only = sprintf("Tract or ZIP published, no addresses  (%d)",
                           geo_n[["subcounty_only"]]),
  county_coarser = sprintf("County or coarser only  (%d)", geo_n[["county_coarser"]])
)

n_addr <- sum(src$addresses %in% c("yes", "partial"))
n_addr_yes <- sum(src$addresses == "yes")
n_names <- sum(src$names == "yes")

cap3 <- sprintf(paste0(
  "Addresses are what let you geocode a filing to a tract.\n",
  "Without them you are stuck with whatever geography the publisher chose.\n",
  "Of %d sources, %d carry addresses (%d fully, %d partially); %d publish defendant names.\n",
  "Access varies: Connecticut on request, New Jersey paid, California dashboard-only."),
  nrow(src), n_addr, n_addr_yes, n_addr - n_addr_yes, n_names)

p_geo_cat <- ggplot(geo_plot, aes(x = col, y = -row)) +
  geom_tile(aes(fill = geo_cat), width = 0.9, height = 0.9) +
  geom_text(aes(label = abbr, colour = geo_cat),
            size = 8, fontface = "bold", show.legend = FALSE) +
  scale_fill_manual(values = geo_pal, labels = geo_labs, drop = FALSE) +
  scale_colour_manual(values = geo_ink, guide = "none") +
  coord_equal(clip = "off") +
  labs(caption = cap3) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
  base_theme

ggsave(file.path(out_dir, "s4_geography_available.png"), p_geo_cat,
       width = 13, height = 9.4, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s4_geography_available_preview.png"), p_geo_cat,
       width = 13, height = 9.4, dpi = 150, bg = "white")

# ---- 6. the slide version: three buckets ----------------------------------

# Sections 3-5 are the working maps. This is the one that goes on a slide.
# Three questions, three colors:
#   can you get to an address (so, any geography you want)?
#   can you at least see counts?
#   or is there nothing to see?

simple_df <- geo_plot |>
  mutate(simple = case_when(
    tier == "none_public"                            ~ "none",
    geo_cat %in% c("addr_statewide", "addr_local")   ~ "address",
    TRUE                                             ~ "counts"
  )) |>
  mutate(simple = factor(simple, levels = c("address", "counts", "none")))

simple_n <- table(simple_df$simple)
stopifnot(sum(simple_n) == 51)

simple_pal <- c(address = "#003262", counts = "#A8C4DA", none = "#B0362F")
simple_ink <- c(address = "#FFFFFF", counts = "#123A56", none = "#FFFFFF")

simple_labs <- c(
  address = sprintf("Address level  (%d)", simple_n[["address"]]),
  counts  = sprintf("Counts only  (%d)",   simple_n[["counts"]]),
  none    = sprintf("Nothing published  (%d)", simple_n[["none"]])
)

cap4 <- paste0(
  "Address level means you can geocode a filing and build any geography you want.\n",
  "Counts only means someone publishes totals, usually by county, and that is your floor.\n",
  "Most of the counts-only states are published by the Legal Services Corporation."
)

p_simple <- ggplot(simple_df, aes(x = col, y = -row)) +
  geom_tile(aes(fill = simple), width = 0.9, height = 0.9) +
  geom_text(aes(label = abbr, colour = simple),
            size = 9, fontface = "bold", show.legend = FALSE) +
  scale_fill_manual(values = simple_pal, labels = simple_labs, drop = FALSE) +
  scale_colour_manual(values = simple_ink, guide = "none") +
  coord_equal(clip = "off") +
  labs(caption = cap4) +
  guides(fill = guide_legend(nrow = 1)) +
  base_theme

ggsave(file.path(out_dir, "s4_simple.png"), p_simple,
       width = 13, height = 9, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s4_simple_preview.png"), p_simple,
       width = 13, height = 9, dpi = 150, bg = "white")

# ---- 7. the gap slide: LSC coverage, two colors ----------------------------

# The single largest source of US eviction filing data, and what it misses.
# This is the setup for the HPRM: the gap is the reason you model.

lsc_df <- atlas_df |>
  mutate(lsc = factor(ifelse(grepl("\\bLSC\\b", tags), "yes", "no"),
                      levels = c("yes", "no")))

lsc_n <- table(lsc_df$lsc)
stopifnot(lsc_n[["yes"]] == 32, sum(lsc_n) == 51)

lsc_pal <- c(yes = "#003262", no = "#B0362F")
lsc_ink <- c(yes = "#FFFFFF", no = "#FFFFFF")
lsc_labs <- c(
  yes = sprintf("LSC publishes county filing counts  (%d)", lsc_n[["yes"]]),
  no  = sprintf("No LSC coverage  (%d)", lsc_n[["no"]])
)

cap5 <- paste0(
  "The Legal Services Corporation's Civil Court Data Initiative is the single largest\n",
  "source of U.S. eviction filing data. It still misses 19 states.\n",
  "That gap is why we model: the HPRM trains on court records from 15 states\n",
  "and estimates risk for tracts nationwide."
)

p_lsc <- ggplot(lsc_df, aes(x = col, y = -row)) +
  geom_tile(aes(fill = lsc), width = 0.9, height = 0.9) +
  geom_text(aes(label = abbr, colour = lsc),
            size = 9, fontface = "bold", show.legend = FALSE) +
  scale_fill_manual(values = lsc_pal, labels = lsc_labs, drop = FALSE) +
  scale_colour_manual(values = lsc_ink, guide = "none") +
  coord_equal(clip = "off") +
  labs(caption = cap5) +
  guides(fill = guide_legend(nrow = 1)) +
  base_theme

ggsave(file.path(out_dir, "s6_lsc_gap.png"), p_lsc,
       width = 13, height = 9, dpi = 220, bg = "transparent")
ggsave(file.path(out_dir, "s6_lsc_gap_preview.png"), p_lsc,
       width = 13, height = 9, dpi = 150, bg = "white")

# counts as built, for cross-checking the slide copy
tier_n
table(atlas_df$n_prog)
sort(atlas_df$abbr[atlas_df$n_prog == 0])
geo_n
sort(geo_plot$abbr[geo_plot$geo_cat == "addr_statewide"])
simple_n
sort(simple_df$abbr[simple_df$simple == "address"])
lsc_n
sort(lsc_df$abbr[lsc_df$lsc == "no"])
