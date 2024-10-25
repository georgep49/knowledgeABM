
# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

f <- list.files("output/data/calibrate", pattern = "_gen", full.names = TRUE)

p <- read_csv("output/data/calibrate/hysteresis-calibrate-table.csv", skip = 6) |>
    janitor::clean_names()

calibrate <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_p_a, spatial_learn, social_learn, know_move)

calibrate <- calibrate |>
    left_join(pp, by = c("rep" = "run_number"))

calibrate <- calibrate |>
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

    
save.image("output/data/calibrate/calibrate.RData")

# zip and remove
f <- list.files("output/data/calibrate", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "output/data/calibrate/calibrate.zip", files = f)
file.remove(list.files("output/data/calibrate", pattern = ".csv", full.names = TRUE))
#

save.image("output/data/calibrate/calibrate.RData")
####

# basically want to plot mean k-a at 50 gens vs n-p-a by scenario
load("ms/data/calibrate/calibrate.RData")

# scenario labeller
sc_labels <- c("a" = "null",
    "b" = "spatial",
    "c" = "social",
    "d" = "spatial + social",
    "e" = "pref move",
    "f" = "spatial + pref move",
    "g" = "social + pref move",
    "h" = "spatial + social + pref-move")

X <- calibrate[gen == 25, 
        .(mean_ka = mean(ka), range_ka = mean(ka.range)), 
        by = .(scenario, sc_tag, rep, unit, n_p_a)]

ggplot(data = X) +
    geom_point(aes(x = n_p_a, y = mean_ka, col = factor(unit))) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    geom_smooth(aes(x = n_p_a, y = mean_ka)) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels))

ggplot(data = X) +
    geom_point(aes(x = n_p_a, y = range_ka, col = factor(unit))) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels))
