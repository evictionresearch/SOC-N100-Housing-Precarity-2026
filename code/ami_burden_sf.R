# Rent burden by AMI

library(tidycensus)
library(tidyverse)

incomes <- get_acs(
  state = "CA",
  county = "San Francisco",
  table = "B25118", # table pulls in all variables from that table
  geography = "county",
  summary_var = "B25118_001", # creates a denominator to get proportions
  cache_table = TRUE
) %>%
  left_join(vars_2024, by = c("variable" = "name")) %>%
  filter(grepl("Renter", label)) %>%
  mutate(
    label_number = label %>%
      str_extract_all("[0-9,]+") %>%
      map_chr(~ dplyr::last(.x) %||% NA_character_) %>%
      str_remove_all(",") %>%
      as.numeric()
  )

glimpse(incomes)
count(incomes, label)
data.frame(incomes)

med_inc <- get_acs(
  state = "CA",
  county = "San Francisco",
  table = "B25119",
  geography = "county"
) %>%
  mutate(
    ami_30 = estimate * .3,
    ami_50 = estimate * .5,
    ami_80 = estimate * .8
  )

med_inc

ami_30 <- incomes %>%
  filter(label_number <= med_inc$ami_30[1]) %>%
  summarize(eli = sum(estimate))

ami_50 <- incomes %>%
  filter(label_number <= med_inc$ami_50[1]) %>%
  summarize(vli = sum(estimate))

ami_80 <- incomes %>%
  filter(label_number <= med_inc$ami_80[1]) %>%
  summarize(li = sum(estimate))

low_income <- bind_cols(ami_30, ami_50, ami_80) %>%
  pivot_longer(everything(), names_to = "level", values_to = "count") %>%
  mutate(
    renters = incomes$estimate[1],
    p_renter = count/renters
  )

sum(low_income$p_renter)

bay <- c("Alameda", "Contra Costa", "Marin", "Napa", "San Francisco",
         "San Mateo", "Santa Clara", "Solano", "Sonoma")

burden <- get_acs(
  geography = "county",
  state     = "CA",
  county    = bay,
  table     = "B25070",   # gross rent as % of household income
  year      = 2024,
  survey    = "acs5"
) %>%
  mutate(county = str_remove(NAME, " County, California")) %>%
  select(county, variable, estimate) %>%
  pivot_wider(names_from = variable, values_from = estimate) %>%
  transmute(
    county,
    # drop "not computed" (no cash rent / zero or negative income) from the denominator
    denom       = B25070_001 - B25070_011,
    burdened_30 = B25070_007 + B25070_008 + B25070_009 + B25070_010,
    severe_50   = B25070_010,
    p_burden_30 = burdened_30 / denom,
    p_severe_50 = severe_50 / denom
  ) %>%
  arrange(p_burden_30)

burden
