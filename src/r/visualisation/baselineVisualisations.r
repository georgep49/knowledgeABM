### Various visualisations

library(tidyverse)
library(data.table)

####
## Baseline
####

load("ms/data/control/control.RData")
###

baseline_control[, n_agents := n_agents_per_unit * n_units]

sim_t_summary <- baseline_control[,
                            .(ka_mean = mean(ka), kb_mean = mean(kb), bimod_a_mean = mean(bimodal.a), bimod_b_mean = mean(bimodal.b)),
                            by = .(tick, unit, scenario, n_agents_per_unit, n_units)] [
                            , n_agents := n_agents_per_unit * n_units]

sim_g_summary <- baseline_control[,
                            .(ka_mean = mean(ka), kb_mean = mean(kb), bimod_a_mean = mean(bimodal.a), bimod_b_mean = mean(bimodal.b)),
                            by = .(gen, unit, scenario, n_agents_per_unit, n_units)] [
                                , n_agents := n_agents_per_unit * n_units]

sim_genbyrep_summary <- baseline_control[,
                            .(ka_mean = mean(ka), kb_mean = mean(kb), bimod_a_mean = mean(bimodal.a), bimod_b_mean = mean(bimodal.b)),
                            by = .(gen, tick, unit, scenario, n_agents_per_unit, n_units)] [
                            , n_agents := n_agents_per_unit * n_units]

sim_final_summary <- baseline_control[gen >= 50]  # gte max_gens


sim_final_agg <- sim_final_summary[,
    .(ka_mean = mean(ka), ka_p10 = quantile(ka, 0.10), ka_p90 = quantile(ka, 0.90),
     bia_mean = mean(bimodal.a), ka_p10 = quantile(bimodal.a, 0.10), ka_p90 = quantile(bimodal.a, 0.90)),
    by = .(rep, gen, sc_tag)] [
        order(rep)
    ]

write_csv(sim_final_summary, "ms/data/derived/controlFinalGen.csv")
write_csv(sim_final_agg, "ms/data/derived/controlFinalGenAgg.csv")

save.image("ms/data/control/control.RData")
####

load("ms/data/control/control.RData")

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
# distribution of final knowledge of 'a' scenario null
base_mean <- mean(sim_final_summary[sc_tag == "a", ]$ka)
base_bi <- mean(sim_final_summary[sc_tag == "a", ]$bimodal.a)

# Boxplot for final k-a and bimodal under baseline (120, 3) conditions
final_units_ka <- ggplot(data = sim_final_summary |> slice_sample(prop = 0.1)) +
    geom_boxplot(aes(x = unit, y = ka, group = unit), outliers = FALSE) +
    geom_jitter(aes(x = unit, y = ka, group = unit), alpha = 0.1, width = 0.1) +
    geom_hline(yintercept = base_mean, col = "red", linetype = 2) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    theme_bw()

final_units_bi <- ggplot(data = sim_final_summary |> slice_sample(prop = 0.1)) +
    geom_boxplot(aes(x = unit, y = bimodal.a, group = unit), outliers = FALSE) +
    geom_jitter(aes(x = unit, y = bimodal.a, group = unit), alpha = 0.1, width = 0.1) +
    geom_hline(yintercept = base_bi, col = "red", linetype = 2) +
    geom_hline(yintercept = 5/9, col = "blue", linetype = 2) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    theme_bw()

###
# median of ka by generation for each scenario
sim_g_summary$sc_tag <- letters[sim_g_summary$scenario]

gen_units_ka <- ggplot(data = sim_g_summary) +
    geom_line(aes(x = gen, y = ka_mean, col = factor(unit), group = unit)) +
    xlim(0, 50) +
    geom_hline(yintercept = base_mean, col = "red", linetype = 2) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    theme_bw()

gen_units_bi <- ggplot(data = sim_g_summary) +
    geom_line(aes(x = gen, y = bimod_a_mean, col = factor(unit), group = unit)) +
    xlim(0, 50) +
    geom_hline(yintercept = base_bi, col = "red", linetype = 2) +
    geom_hline(yintercept = 5/9, col = "blue", linetype = 2) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    theme_bw()

###
# Unit 1 for eight reps for each scenario (mean k-a and bimodal-a)
sample_reps <- baseline_control[
        order(scenario, rep)][
        , sc_rep := .GRP, by = .(scenario, rep)][
        , sc_rep := (sc_rep %% 50) + 1][
        , .(ka_mean = mean(ka), bimod_a_mean = mean(bimodal.a), sc_tag = letters[scenario]), 
        by = .(scenario, rep, sc_rep, gen, unit)]

sr <- sample(1:50, 8)

sample_scen_ka_gg <- ggplot(sample_reps[sc_rep %in% sr & unit == 1]) +
    geom_line(aes(x = gen, y = ka_mean, col = factor(sc_rep), group = sc_rep)) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    geom_hline(yintercept = base_mean, col = "red", linetype = 2) +
    xlim(c(0, 50)) +
    theme_bw() +
    theme(legend.position = "none")


sample_scen_bi_gg <- ggplot(sample_reps[sc_rep %in% sr & unit == 1]) +
    geom_line(aes(x = gen, y = bimod_a_mean, col = factor(sc_rep), group = sc_rep)) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels)) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    geom_hline(yintercept = base_bi, col = "red", linetype = 2) +
    geom_hline(yintercept = 5/9, col = "blue", linetype = 2) +
    xlim(c(0, 50)) +
    theme_bw() +
    theme(legend.position = "none")


###
# Each unit for nine reps of scenario 5
sample_s5_reps <- sample_reps[scenario == 5 & sc_rep %in% sample(1:50, 9)]

s5_ka_gg <- ggplot(data = sample_s5_reps) +
    geom_line(aes(x = gen, y = ka_mean, col = factor(unit), group = unit)) +
    xlim(c(0, 50)) +
    ylim(c(0, 100)) +
    facet_wrap(~sc_rep) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    geom_hline(yintercept = base_mean, col = "red", linetype = 2) +
    theme_bw()

s5_ba_gg <- ggplot(data = sample_s5_reps) +
    geom_line(aes(x = gen, y = bimod_a_mean, col = factor(unit), group = unit)) +
    xlim(c(0, 50)) +
    facet_wrap(~sc_rep) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    geom_hline(yintercept = base_bi, col = "red", linetype = 2) +
    geom_hline(yintercept = 5/9, col = "blue", linetype = 2) +
    theme_bw()


###
# Need to show distribution of turtles for each gen for k-a
# Scenario 5
f <- fread("ms/data/one-run/hysteresis_one_inds_1.csv")
one_run <- f[, m := mean(ka), by = .(gen, unit, lineage)]

one_run <- one_run |>
    group_by(lineage) |>
    mutate(low = m[gen == 50 & age == 0] < 20) |>
    ungroup()

library(paletteer)

lineage_gg <- ggplot(one_run) +
    geom_line(aes(x = gen, y = m, group = lineage, col = low), alpha = 0.6) +
    facet_wrap(~unit) +
    paletteer::scale_colour_paletteer_d("suffrager::classic", direction = -1) +
    theme_bw() +
    theme(legend.position = "none")


##
library(svglite)

svglite(file = "ms/figs/figX_finalUnitsKa.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
final_units_ka
dev.off()

svglite(file = "ms/figs/figX_finalUnitsBi.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
final_units_bi
dev.off()

svglite(file = "ms/figs/figX_sampleScenKa.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
sample_scen_ka_gg
dev.off()

svglite(file = "ms/figs/figX_sampleScenBi.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
sample_scen_bi_gg
dev.off()



svglite(file = "ms/figs/figX_sampleScen.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
sample_scen_gg
dev.off()

