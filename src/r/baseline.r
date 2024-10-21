# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

f <- list.files("ms/data/baseline-control", pattern = "_gen", full.names = TRUE)
p <- read_csv("ms/data/baseline-nunits/hysteresis baseline-control-table.csv", skip = 6) |>
    janitor::clean_names()

ff <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_units, n_agents, spatial_learn, social_learn, know_move)

ff <- ff |>
    left_join(pp, by = c("rep" = "run_number"))

baseline_control <- ff

save.image("ms/data/baseline-control/baselineControl.RData")


### tag and subset

baseline_control <- baseline_control |>
    mutate(scenario = case_when(
        spatial_learn == FALSE & social_learn == FALSE & know_move == FALSE ~ 1,
        spatial_learn == TRUE & social_learn == FALSE & know_move == FALSE ~ 2,
        spatial_learn == FALSE & social_learn == TRUE & know_move == FALSE ~ 3,
        spatial_learn == TRUE & social_learn == TRUE & know_move == FALSE ~ 4,
        spatial_learn == FALSE & social_learn == FALSE & know_move == TRUE ~ 5,
        spatial_learn == TRUE & social_learn == FALSE & know_move == TRUE ~ 6,
        spatial_learn == FALSE & social_learn == TRUE & know_move == TRUE ~ 7,
        spatial_learn == TRUE & social_learn == TRUE & know_move == TRUE ~ 8,
    )) |>
    mutate(sc_tag = letters[scenario])

baseline <- baseline_control[n_units == 3 & n_agents == 120]

save.image("output/data/baseline/baseline.RData")

# zip and remove
# zip::zip(zipfile = "baseline_units_agents.zip", files = f)
# file.remove(list.files("output/data/baseline", pattern = ".csv", full.names = TRUE)
# )

######
