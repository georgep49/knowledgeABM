
# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

######################### 
## Defect
#########################

f <- list.files("ms/data/sa-defect", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-defect/hysteresis baseline-defect-table.csv", skip = 6) |>
    janitor::clean_names()

sa_defect <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, defect_unit)

sa_defect <- sa_defect |>
    left_join(pp, by = c("rep" = "run_number"))

sa_defect <- sa_defect |>
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
f <- list.files("ms/data/sa-defect", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-defect/sa-defect.zip", files = f)
file.remove(f)
#

save.image("ms/data/sa-defect/saDefect.RData")
####


######################### 
## Asymm
#########################
f <- list.files("ms/data/sa-asymm", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-asymm/hysteresis sa-asymm-table.csv", skip = 6) |>
    janitor::clean_names()

sa_asymm <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, res_a_preference)

sa_asymm <- sa_asymm |>
    left_join(pp, by = c("rep" = "run_number"))

sa_asymm <- sa_asymm |>
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
f <- list.files("ms/data/sa-asymm", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-asymm/sa-asymm.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-asymm/saAsymm.RData")
####



#########################
## Spatial nhb
#########################
f <- list.files("ms/data/sa-spatial-nhb", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-spatial-nhb/hysteresis spatial-nhb-size-table.csv", skip = 6) |>
    janitor::clean_names()

sa_spatial <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, spatial_nhb)

sa_spatial <- sa_spatial |>
    left_join(pp, by = c("rep" = "run_number"))

sa_spatial <- sa_spatial |>
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
f <- list.files("ms/data/sa-spatial-nhb", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-spatial-nhb/sa-spatial-nhb.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-spatial-nhb/saSpatialNhb.RData")
####



#########################
## Cognitive proximity
#########################
f <- list.files("ms/data/sa-cogproximity", pattern = "_gen", full.names = TRUE)

p <- read_csv("ms/data/sa-cogproximity/hysteresis sa-cogproximity-table.csv", skip = 6) |>
    janitor::clean_names()

sa_cogprox <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move, cognitive_proximity)

sa_cogprox <- sa_cogprox |>
    left_join(pp, by = c("rep" = "run_number"))

sa_cogprox <- sa_cogprox |>
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
f <- list.files("ms/data/sa-cogproximity", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-cogproximity/sa-cogproximity.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-cogproximity/saCogProximity.RData")
####