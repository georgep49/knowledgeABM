# Load and deal with the baseline runs for the bc hysteresis model
# These address dynamics with different initial a - for calibration
# models (GAMs)

library(tidyverse)
library(data.table)

library(janitor)

source("src/r/processSimsFuncs.r")

process_bch_sims(
    base_path = "ms/data/calibrate",
    nl_file_name = "hysteresis calibrate-table",
    save_file = "calibrate"
)

save.image("ms/data/calibrate/calibrate.RData")

tidy_bch_sims(
    base_path = "ms/data/calibrate",
    zip_file = "calibrate"
)

save.image("ms/data/calibrate/calibrate.RData")
####

# basically want to plot mean k-a at 50 gens vs n-p-a by scenario
load("ms/data/calibrate/calibrate.RData")

# scenario labeller
sc_labels <- c(
    "a" = "null",
    "b" = "spatial",
    "c" = "social",
    "d" = "spatial + social",
    "e" = "pref move",
    "f" = "spatial + pref move",
    "g" = "social + pref move",
    "h" = "spatial + social + pref-move"
)

calibrate_sc35 <- calibrate[gen == 35,
    .(mean_ka = mean(ka), range_ka = mean(ka.range)),
    by = .(scenario, sc_tag, rep, unit, n_p_a)
]

c35_gg <- ggplot(data = calibrate_sc35) +
    geom_point(aes(x = n_p_a, y = mean_ka, col = factor(unit))) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    # geom_smooth(aes(x = n_p_a, y = mean_ka)) +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels))

c35_range_gg <- ggplot(data = calibrate_sc35) +
    geom_point(aes(x = n_p_a, y = range_ka, col = factor(unit))) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    facet_wrap(~sc_tag, labeller = labeller(sc_tag = sc_labels))


# build gams for prediction to other scenarios
load("ms/data/calibrate/calibrate.RData")
library(broom)
library(purrr)
library(mgcv)

calibrate_gam <- calibrate[gen == 35, c("rep", "ka", "n_p_a", "unit", "scenario")][, .(mean(ka)), by = .(rep, scenario, n_p_a)]

calibrate_gam$sc_tag <- letters[scenario]
# create a GAM for each scenario
df <- data.frame(n_p_a = seq(0.05, 0.75, 0.025))

gam_list <- vector(mode = "list", length = 8)
pred_list <- vector(mode = "list", length = 8)

# loop over the scenarios
for (s in 1:8) {
    x <- calibrate_gam[scenario == s]
    gam_list[[s]] <- gam(V1 ~ s(n_p_a), data = x)
    pred_list[[s]] <- predict(gam_list[[s]], newdata = df, se.fit = TRUE) |>
        data.frame() |>
        mutate(n = seq(0.05, 0.75, 0.025))
}

# bind together
pred_npa_gams <- bind_rows(pred_list, .id = "scenario") |>
    as_tibble()
base50 <- filter(pred_npa_gams, n == 0.5 & scenario == 1)$fit

# plot...
# scenario labeller
sc_labels <- c("a" = "null",
    "b" = "spatial",
    "c" = "social",
    "d" = "spatial + social",
    "e" = "pref move",
    "f" = "spatial + pref move",
    "g" = "social + pref move",
    "h" = "spatial + social + pref-move")


calibrate_gams_gg <- ggplot() +
    geom_point(data = calibrate_gam, aes(x = n_p_a, y = V1), col = "dark grey") +
    geom_line(data = pred_npa_gams, aes(x = n, y = fit), col = "red") +
    geom_hline(yintercept = base50, linetype = 2) +
    geom_vline(xintercept = 0.5, linetype = 2) +
    labs(x = "Abundance of resource 'a'",
         y = "Knowledge of resource 'a'") +
    facet_wrap(~scenario) +
    theme_bw()

save.image("ms/data/calibrate/calibrate.RData")

##
library(svglite)

svglite(file = "calibrateGAMs.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)  
calibrate_gams_gg
dev.off()
