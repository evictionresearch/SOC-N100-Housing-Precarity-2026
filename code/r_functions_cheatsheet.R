# ==========================================================================
# R FUNCTIONS CHEAT SHEET -- every function in this course
# SOC-N100: Housing Precarity and Displacement | Summer 2026
# Instructor: Tim Thomas
# ==========================================================================
#
# Every function and symbol that appears in this course's labs, in one
# place. This is a REFERENCE CARD, not a lab: everything below is a
# comment on purpose, so nothing here needs running (and nothing can
# break). Keep it open in a tab while you work, and use Edit > Find
# (Ctrl-F / Cmd-F) to jump to a function the moment a lab line looks
# unfamiliar.
#
# The [lab N] tag says which lab's script a function FIRST appears in --
# most get reused in every lab after that. Functions from labs you have
# not reached yet are a preview, not homework.
#
# Fuller pictures: the Posit cheat sheets (one page per tool) at
#   https://opensource.posit.co/resources/cheatsheets/
# with copies in this repo under docs/cheatsheets/ -- and the Learn R
# page on the course site.
#
# (Maintainers: the inventory below was extracted mechanically from
# code/lab*.R + a1_example.R on 2026-08-06 with
# website/maintainer/list_lab_functions.R. After editing labs, rerun that
# script and reconcile this file against its output. As of that run every
# function called in labs 1-6 and a1_example.R appears here, tagged.)

# ==========================================================================
# 1. SYMBOLS AND EVERYDAY BASICS
# ==========================================================================
#
# <-                save something under a name ("gets")           [lab 1]
#                     rent <- 2200
#
# #                 a comment -- R ignores the rest of the line    [lab 1]
#                     # this is a note to humans
#
# %>%               the pipe: "and then" -- feeds the left side    [lab 1]
#                   into the next step. (Elsewhere you will also
#                   see |> , R's newer built-in pipe: same idea.)
#                     acs %>% filter(estimate > 30)
#
# c()               combine values into a vector                   [lab 1]
#                     c("Alameda", "Solano")
#
# data.frame()      build a small table by hand                    [lab 1]
#                     data.frame(city = c("Oakland", "Chico"),
#                                rent = c(2200, 1400))
#
# $                 grab one column out of a table                 [lab 1]
#                     three_cities$rent
#
# +  -  *  /        arithmetic (and + also stacks ggplot layers)   [lab 1]
#                     estimate * 0.8
#
# >  <  ==  !=      comparisons: greater / less / equal / not    [labs 1-2]
#                     filter(variable != "ami")
#
# - (in select)     drop a column instead of keeping it            [lab 2]
#                     select(-moe)
#
# ::                use one tool from a package without loading    [lab 2]
#                   the whole toolbox
#                     scales::dollar_format()
#
# %in%              is each value one of these?                    [lab 4]
#                     filter(county %in% c("Brown", "Clinton"))
#
# ~                 "goes with" -- writes the rules inside         [lab 5]
#                   case_when()
#                     p_rb > 0.5 ~ "majority burdened"

# ==========================================================================
# 2. SETUP: PACKAGES AND THE CENSUS KEY
# ==========================================================================
#
# install.packages()  buy the toolbox -- run ONCE ever             [lab 1]
#                       install.packages("tidycensus")
#
# library()           open the toolbox -- run EVERY session        [lab 1]
#                       library(tidyverse)
#
# census_api_key()    save your Census key so R remembers it       [lab 1]
#                       census_api_key("KEY", install = TRUE)
#
# Sys.getenv()        check what R has stored (e.g., your key)     [lab 1]
#                       Sys.getenv("CENSUS_API_KEY")
#
# readRenviron()      reload stored settings without restarting    [lab 1]
#                       readRenviron("~/.Renviron")
#
# remotes::install_github()  install a package straight from       [lab 5]
#                            GitHub
#                       remotes::install_github("evictionresearch/neighborhood")
#
# options()           change one of R's settings for this session  [lab 5]
#                       options(tigris_use_cache = TRUE)

# ==========================================================================
# 3. MEET YOUR DATA (INSPECTING)
# ==========================================================================
#
# View()            open a table in a spreadsheet-style tab        [lab 1]
#                   (with a search box, top right)
#                     View(vars_2024)
#
# head()            show the first few rows                        [lab 1]
#                     head(acs)
#
# nrow() / ncol()   count rows / columns                       [labs 1, 4]
#                     nrow(alameda_raw)
#
# dim()             rows and columns at once                       [lab 5]
#                     dim(ces)   # 9106 x 70
#
# names()           list a table's column names                    [lab 1]
#                     names(alameda_wide)
#
# slice_head()      keep just the first n rows                     [lab 1]
#                     slice_head(n = 10)
#
# glimpse()         one line per column, with type and first       [lab 2]
#                   values -- the first move on any new dataset
#                     glimpse(indiana_evictions)
#
# summary()         min, quartiles, median, mean, max (and NA      [lab 3]
#                   count) of a column
#                     summary(alameda_rb$p_rb)
#
# class()           what kind of object is this?                   [lab 4]
#                     class(flat_join)
#
# levels()          the categories a FACTOR can take, in their     [lab 5]
#                   stored order -- including ones your data has
#                   none of. Compare against count() to find what
#                   is MISSING from your area
#                     levels(seg$nt_conc)
#
# object.size()     how much memory an object uses                 [lab 6]
#                     object.size(evictions) %>% format(units = "MB")
#
# file.exists()     is this file there?                            [lab 6]
#                     file.exists("~/data/cache/acs.rds")

# ==========================================================================
# 4. GETTING DATA
# ==========================================================================
#
# get_acs()         pull American Community Survey data from       [lab 1]
#                   the Census
#                     get_acs(geography = "county",
#                             variables = "B25071_001",
#                             state = "CA", year = 2024)
#
# load_variables()  download the Census's variable catalog         [lab 2]
#                   (then View() it and search)
#                     vars_2024 <- load_variables(2024, "acs5")
#
# readRDS()         read an R data file someone hands you          [lab 4]
#                     readRDS("~/SOC-N100-Housing-Precarity-2026/data/evictions/d5_case_aggregated.rds")
#
# read_rds()        tidyverse spelling of readRDS()                [lab 6]
#                     read_rds("~/.../data/hprm/hprm_tract_2022.rds")
#
# read_csv()        read a CSV -- from a file OR straight from     [lab 5]
#                   a web address. How data you DOWNLOAD yourself
#                   gets into R
#                     read_csv("~/.../data/calenviroscreen50_070126.csv")
#
# tracts()          download census-tract map outlines (tigris)    [lab 4]
#                     tracts(state = "IN", county = "Marion", year = 2022)
#
# ntdf()            build neighborhood racial-composition types    [lab 5]
#                   (my neighborhood package)
#                     ntdf(state = "CA", county = "Alameda", year = 2024)
#
# get_flows()       county-to-county migration -- the one source   [lab 5]
#                   that reports who moved OUT, not just in.
#                   Counties/metros only, never tracts; county-to-
#                   county tops out at year = 2020
#                     get_flows(geography = "county", state = "CA",
#                               county = "Alameda", year = 2020)
#
# open_dataset()    point at a parquet file WITHOUT loading it     [lab 6]
#                   into memory (arrow)
#                     open_dataset("data/evictions.parquet")
#
# collect()         actually pull a lazy query's result into       [lab 6]
#                   memory
#                     big %>% filter(state == "IN") %>% collect()

# ==========================================================================
# 5. DATA MANIPULATION: ROWS AND COLUMNS
# ==========================================================================
#
# filter()          keep rows that pass a test                     [lab 1]
#                     filter(p_rb > 0.5)
#
# arrange()         sort rows (ascending)                          [lab 1]
#                     arrange(estimate)
#
# desc()            ...flip the sort to descending                 [lab 1]
#                     arrange(desc(estimate))
#
# select()          keep (or with - , drop) columns                [lab 1]
#                     select(NAME, estimate)
#
# mutate()          add a new column computed from others          [lab 2]
#                     mutate(low_income = estimate * 0.8)
#
# if_else()         pick between two values by a yes/no test       [lab 3]
#                     if_else(is.na(p_rb), 0, p_rb)
#
# case_when()       if_else's big sibling: many tests, first       [lab 5]
#                   match wins
#                     case_when(p_rb > 0.5 ~ "high",
#                               .default = "lower")
#
# group_by()        tag a table: "do what comes next PER GROUP"    [lab 3]
#                     group_by(county)
#
# summarize()       collapse many rows into summary rows           [lab 3]
#                     summarize(tracts = n(), avg = mean(p_rb))
#
# n()               count rows (inside summarize)                  [lab 3]
#                     summarize(tracts = n())
#
# count()           shortcut: group and tally in one move          [lab 5]
#                     count(nt_conc, sort = TRUE)
#
# distinct()        keep only unique rows                          [lab 4]
#                     distinct(county_geoid)
#
# factor()          fix a category order (charts alphabetize   [labs 5, 6]
#                   text labels unless you say otherwise)
#                     factor(tier, levels = c("Low", "Med", "High"))
#
# first()           grab a group's first value (for a number       [lab 4]
#                   repeated on every row)
#                     summarize(renters = first(co_totrent))
#
# ungroup()         pull up group_by()'s flags (summarize() only   [lab 4]
#                   removes the last one)
#                     rates_2019 %>% ungroup() %>% summarize(...)

# ==========================================================================
# 6. DATA MANIPULATION: RESHAPING, STACKING, JOINING
# ==========================================================================
#
# bind_rows()       stack tables with the same columns             [lab 2]
#                     bind_rows(sf_ami, hinds_ami)
#
# pivot_wider()     reshape long -> wide: one column per           [lab 3]
#                   variable
#                     pivot_wider(names_from  = variable,
#                                 values_from = estimate)
#
# pivot_longer()    the return trip: wide -> long, for multi-line  [lab 4]
#                   charts (one row per year-group pair)
#                     pivot_longer(-year, names_to = "group",
#                                  values_to = "filings")
#
# left_join()       glue matching columns from a second table      [lab 4]
#                   onto the first
#                     left_join(co_census_wide,
#                               by = c("county_geoid" = "GEOID"))
#
# anti_join()       show rows that did NOT find a match -- the     [lab 4]
#                   join check, every time you join
#                     anti_join(county_year, co_census_wide,
#                               by = c("county_geoid" = "GEOID"))
#
# paste0()          glue text together (e.g., building GEOIDs)     [lab 4]
#                     paste0(state_code, county_code)
#
# str_pad()         pad a value to a fixed width -- the fix for    [lab 5]
#                   outside data whose ID column lost a leading
#                   zero (6001400100 -> "06001400100")
#                     str_pad(tract, width = 11, side = "left", pad = "0")
#
# nchar()           how many characters is this value? An ID's     [lab 5]
#                   length tells you what kind of place it is
#                   (5 digits = a county, 10 = a Connecticut town)
#                     filter(nchar(GEOID2) == 5)
#
# mean() / median() average / middle value                     [labs 1, 3]
#                     median(alameda_rb_clean$p_rb)
#
# sum()             add values up                                  [lab 4]
#                     summarize(evictions = sum(filings))
#
# round()           round numbers                                  [lab 5]
#                     round(p_rb, 2)
#
# abs()             drop the minus sign -- lets you sort by SIZE   [lab 5]
#                   when a column runs both negative and positive
#                     arrange(desc(abs(estimate)))
#
# is.na()           is this value missing?                         [lab 3]
#                     filter(is.na(p_rb))
#
# coalesce()        first non-missing value of those given --      [lab 6]
#                   the tidy way to fill in NAs
#                     coalesce(rate, 0)
#
# cor()             correlation: do two numbers move together?     [lab 6]
#                   +1 lockstep up, 0 no relation, -1 opposite
#                     cor(hprm, p_rb, use = "complete.obs")
#
# is.finite() /     catch the results of dividing by zero          [lab 4]
# is.infinite()
#                     filter(is.finite(rate))
#
# format()          pretty-print a value                           [lab 6]
#                     format(units = "MB")

# ==========================================================================
# 8. PLOTTING (GGPLOT2)
# ==========================================================================
#
# ggplot()          start a chart canvas from a table              [lab 1]
#                     ggplot(bay_rb)
#
# aes()             MAP columns to visual slots (x, y, color...)   [lab 1]
#                     aes(x = p_rb, y = NAME)
#
# geom_col()        bars -- compare a few places or groups         [lab 1]
#                     + geom_col(fill = "steelblue")
#                   two measures per group, side by side: map      [lab 5]
#                   fill = inside aes(), then dodge the bars
#                     + geom_col(position = "dodge")
#
# geom_histogram()  one number's spread across many rows           [lab 3]
#                     + geom_histogram(bins = 25)
#
# geom_boxplot()    compare whole spreads across groups            [lab 3]
#                     + geom_boxplot()
#
# geom_point()      scatter -- do two numbers move together?       [lab 3]
#                     + geom_point()
#
# geom_jitter()     scatter with points nudged apart so            [lab 6]
#                   overlapping dots stop hiding each other
#                     + geom_jitter(width = 0.2)
#
# geom_smooth()     drape a trend line (with uncertainty ribbon)   [lab 3]
#                   over a scatter
#                     + geom_smooth()
#
# geom_line()       connect points -- the shape of change over     [lab 2]
#                   time
#                     + geom_line()
#
# geom_vline() /    vertical / horizontal reference line       [labs 1, 2]
# geom_hline()
#                     + geom_vline(xintercept = 0.3, linetype = "dashed")
#
# geom_abline()     reference line with any slope (e.g., the       [lab 4]
#                   equality line y = x)
#                     + geom_abline(slope = 1, intercept = 0)
#
# reorder()         sort a chart's categories by a value (or by    [lab 1]
#                   your own order column)
#                     aes(y = reorder(NAME, p_rb))
#
# labs()            title, subtitle, axis labels, caption --       [lab 1]
#                   the words that let a chart stand alone
#                     + labs(title = "...", x = NULL)
#
# theme_minimal()   swap the gray default for a clean look         [lab 1]
#                     + theme_minimal()
#
# scale_x_continuous() /  dress an axis -- e.g., with the      [labs 3, 2]
# scale_y_continuous()    money/percent formats below
#                     + scale_x_continuous(labels = scales::percent_format())
#
# scales::dollar_format() /  print axis numbers as $, %, or    [labs 2, 3]
# scales::percent_format() /  1,000s. House rule: every axis       [lab 5]
# scales::comma_format()      names its units
#                     labels = scales::comma_format()
#
# scale_fill_manual()  choose which category gets which color      [lab 5]
#                    -- so a chart about loss and gain never
#                    scrambles red and blue
#                     + scale_fill_manual(values = c("Alameda lost" = "firebrick",
#                                                    "Alameda gained" = "steelblue"))
#
# ggsave()          save the chart to an image file (inches)       [lab 1]
#                     ggsave("~/my_chart.png", width = 8, height = 5)

# ==========================================================================
# 9. MAPS (TMAP, TIGRIS, SF) -- LABS 4-5
# ==========================================================================
#
# tm_shape()        declare which spatial object to draw           [lab 4]
#                   (tmap's ggplot())
#                     tm_shape(marion_map_data)
#
# tm_polygons()     draw the polygons, colored by a column         [lab 4]
#                     + tm_polygons(col = "eviction_rate")
#
# tm_fill()         like tm_polygons(), without the borders        [lab 5]
#                     + tm_fill(col = "p_rb")
#
# tmap_mode()       switch between static ("plot") and             [lab 4]
#                   interactive ("view") maps
#                     tmap_mode("view")
#
# tmap_arrange()    show several saved maps side by side;          [lab 5]
#                   sync = TRUE links their pan and zoom so you
#                   are always comparing the same view
#                     tmap_arrange(map_black, map_white,
#                                  ncol = 2, sync = TRUE)
#
# tmap_save()       save a map to a file                           [lab 4]
#                     tmap_save(my_map, "~/eviction_map.png")
#
# st_drop_geometry()  peel the shapes off a spatial table to       [lab 4]
#                     get a plain table
#                     st_drop_geometry(marion_tracts)
#
# st_crs()          check (or set) a spatial object's coordinate   [lab 4]
#                   reference system -- two layers must share one
#                   before they can be drawn together
#                     st_crs(marion_tracts)

# ==========================================================================
# 10. WRITING YOUR OWN RECIPES (ITERATION)
# ==========================================================================
#
# function()        write your own reusable recipe                 [lab 3]
#                     burden_one_year <- function(y) { ... }
#
# map()             run a recipe once per value in a vector        [lab 3]
#                     map(c(2016, 2020, 2024), burden_one_year)
#
# list_rbind()      stack map()'s list of tables into one table    [lab 3]
#                     burden_list %>% list_rbind()

# ==========================================================================
# 11. SAVING FILES AND MANAGING MEMORY -- LABS 5-6
# ==========================================================================
#
# write_csv()       save a table as a CSV anyone can open          [lab 5]
#                     write_csv(rb_table, "~/output/rb_table.csv")
#
# saveRDS()         cache an R object to a file (private, exact)   [lab 6]
#                     saveRDS(acs, "~/data/cache/acs.rds")
#
# write_parquet()   save a table in the big-data-friendly          [lab 6]
#                   parquet format
#                     write_parquet(evictions, "evictions.parquet")
#
# dir.create()      make a folder                                  [lab 5]
#                     dir.create("~/output")
#
# rm()              delete an object from memory                   [lab 6]
#                     rm(big_table)
#
# gc()              ask R to hand freed memory back                [lab 6]
#                   ("garbage collection")
#                     gc()

# ==========================================================================
# Built from the actual lab scripts (labs 1-6 and the A1 example) -- if
# you have run a lab, you have run these. Spot a function in a lab that
# is not on this card? Tell me; the list is regenerated from the code.
# ==========================================================================
