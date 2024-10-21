### Various visualisations

####
## Baseline
####

load("ms/data/baseline-control/baselineControl.RData")

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






2. Effects of different proximities

- scenario 1 with cognitive distance (10, 20, 30, 60) and credibility threshold (on-off)

3. Effects of different transfer types

4. Effects of different resource preferences
	 - scenario 1 w/ res-a-preference from 1 to 1.5, 0.05, n = 30
