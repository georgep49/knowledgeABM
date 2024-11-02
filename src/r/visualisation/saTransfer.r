# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

######################### 
## Parent transfer
#########################

f <- list.files("ms/data/sa-parenttransfer", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-parenttransfer/hysteresis sa-parenttransfer-table.csv", skip = 6) |>
    janitor::clean_names()

sa_parent_transfer <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, transfer_function, parent_transfer)

sa_parent_transfer <- sa_parent_transfer |>
    left_join(pp, by = c("rep" = "run_number"))

sa_parent_transfer <- sa_parent_transfer |>
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

# zip and remove
f <- list.files("ms/data/sa-parenttransfer", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-parenttransfer/sa-parenttransfer.zip", files = f)
file.remove(f)

save.image("ms/data/sa-parenttransfer/saParentTransfer.RData")

#########################
## Spatial transfer
#########################
rm(list = ls())

f <- list.files("ms/data/sa-spatialtransfer", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-spatialtransfer/hysteresis sa-spatialtransfer-table.csv", skip = 6) |>
    janitor::clean_names()

sa_spatial_transfer <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, transfer_function, transfer_fraction)

sa_spatial_transfer <- sa_spatial_transfer |>
    left_join(pp, by = c("rep" = "run_number"))

sa_spatial_transfer <- sa_spatial_transfer |>
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

# zip and remove
f <- list.files("ms/data/sa-spatialtransfer", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-spatialtransfer/sa-spatialtransfer.zip", files = f)
file.remove(f)

save.image("ms/data/sa-spatialtransfer/saSpatialTransfer.RData")
#