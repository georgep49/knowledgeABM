# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

f <- list.files("ms/data/baseline-nunits", pattern = "_gen", full.names = TRUE)
p <- read_csv("ms/data/baseline-nunits/hysteresis baseline-agents-units-table.csv", skip = 6) |>
    janitor::clean_names()

ff <- lapply(f, fread) |>    # data.table::
    bind_rows()

pp <- select(p, run_number, n_units, n_agents, spatial_learn, social_learn, know_move)

ff <- ff |>
    left_join(pp, by = c("rep" = "run_number"))

baseline_nunits <- ff
rm(ff)
rm(p)

save.image("ms/data/baseline-nunits/baselineNAgentsUnits.RData")


### tag and subset

baseline_nunits <- baseline_nunits |>
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

baseline_control <- baseline_nunits[n_units == 3 & n_agents == 120]

save.image("ms/data/baseline-nunits/baselineNAgentsUnits.RData")

# zip and remove
f <- list.files("ms/data/baseline-nunits", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/baseline_units_agents.zip", files = f)
file.remove(f)

######
load("output/data/baseline/baseline.RData")

###

baseline_units_agents <- baseline_units_agents[, baseline := ifelse(n_units == 3 & n_agents == 120, TRUE, FALSE)]

sim_t_summary <- baseline_units_agents[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(tick, unit, scenario, n_units, n_agents, baseline)]

sim_g_summary <- baseline_units_agents[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(gen, unit, scenario, n_units, n_agents, baseline)]

sim_genbyrep_summary <- baseline_units_agents[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(gen, unit, rep, scenario, n_units, n_agents, baseline)]

save.image("output/data/baseline/baseline.RData")
####


load("output/data/baseline/baseline.RData")

# scenario labeller
sc_labels <- c("a" = "null",
    "b" = "spatial",
    "c" = "social",
    "d" = "spatial + social",
    "e" = "pref move",
    "f" = "spatial + pref move",
    "g" = "social + pref move",
    "h" = "spatial + social + pref-move")

###
# distribution of final knowledge of  'a'
base_mean <- sim_g_summary[gen == 50 & scenario == 1 & baseline == TRUE]$mean_ka

# boxplot for final k-a under baseline (60, 3) conditions
ggplot(data = baseline %>% filter(gen == 50) %>% slice_sample(prop = 0.1)) +
    geom_boxplot(aes(x = unit, y = ka, group = unit), outliers = FALSE) +
    geom_jitter(aes(x = unit, y = ka, group = unit), alpha = 0.1, width = 0.1) +
    geom_hline(yintercept = median(base_mean), col = "red") +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    theme_bw()

###
# median of ka by generation for each scenario
sim_g_summary$sc_tag <- letters[sim_g_summary$scenario]

ggplot(data = sim_g_summary %>% filter(baseline == TRUE)) +
    geom_line(aes(x = gen, y = mean_ka, col = factor(unit), group = unit)) +
    xlim(0, 50) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels))

###
# Unit 1 for eight reps for each scenario (mean k-a)
sample_reps <- baseline[order(scenario, rep)][
        , sc_rep := .GRP, by = .(scenario, rep)][
        , sc_rep := (sc_rep %% 30) + 1][
        , .(mean_ka = mean(ka), sc_tag = letters[scenario]), by = .(scenario, rep, sc_rep, gen, unit)]

sr <- sample(1:30, 8)
ggplot(sample_reps[sc_rep %in% sr & unit == 1]) +
    geom_line(aes(x = gen, y = mean_ka, col = factor(sc_rep), group = sc_rep)) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    xlim(c(0, 50))

###
# Each unit for nine reps of scenario 5
sample_s5_reps <- sample_reps[scenario == 5 & sc_rep %in% sample(1:30, 9)]

ggplot(data = sample_s5_reps) +
    geom_line(aes(x = gen, y = mean_ka, col = factor(unit), group = unit)) +
    xlim(c(0, 50)) +
    ylim(c(0, 100)) +
    facet_wrap(~sc_rep) +
    scale_colour_brewer(type = "qual", palette = "Dark2") 

###
# Need to show distribution of turtles for each gen for k-a
# Scenario 5
f <- fread("output/data/one-run/hysteresis_one_inds_1.csv")
one_run <- f[, m := mean(ka), by = .(gen, unit, lineage)]


ggplot(one_run ) +
    geom_line(aes(x = gen, y = m, group = lineage, col = factor(lineage))) +
    facet_wrap(~unit) +
    theme(legend.position = "none")
