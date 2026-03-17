# Load and deal with the baseline runs for the bc hysteresis model
# These address dynamics with different initial a - for calibration
# models (GAMs)

library(tidyverse)
library(data.table)
library(janitor)

# basically want to plot mean k-a at 50 gens vs n-p-a by scenario
load("ms/data/calibrate/calibrate.RData")

calibrate_sa <- data.table(calibrate$sa)

# scenario labeller
lvl <- levels(calibrate_sa$scenario)
sc_labels <- c("null", "spatial", "social", "spatial+social", "know_move", "spatial+know_move", 
    "social+know_move", "spatial+social+know_move")    

calibrate_sa$scenario_num <- match(calibrate_sa$scenario, lvl)
calibrate_sa$scenario <- sc_labels[calibrate_sa$scenario_num]

# Plot the values and ranges of ka as a function of availability
calibrate_sa35 <- calibrate_sa[gen == 35,
    .(mean_ka = mean(ka), range_ka = mean(ka.range)),
    by = .(scenario, rep, n_p_a)]

c35_gg <- ggplot(data = calibrate_sa35) +
    geom_point(aes(x = n_p_a, y = mean_ka)) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    facet_wrap(~scenario)

c35_range_gg <- ggplot(data = calibrate_sa35) +
    geom_point(aes(x = n_p_a, y = range_ka)) +
    scale_colour_brewer(type = "qual", palette = "Dark2") +
    facet_wrap(~scenario)


# build gams for prediction to other scenarios
# load("ms/data/calibrate/calibrate.RData")
library(broom)
library(purrr)
library(mgcv)

calibrate_gam <- calibrate_sa[gen == 50, c("rep", "ka", "n_p_a", "scenario", "scenario_num")][
    , .(ka_mean = mean(ka)), by = .(rep, scenario, scenario_num, n_p_a)]

# create a GAM for each scenario
df <- data.frame(n_p_a = seq(0.05, 0.75, 0.025))

gam_list <- vector(mode = "list", length = 8)
pred_list <- vector(mode = "list", length = 8)

# loop over the scenarios
for (s in 1:8) {
    x <- cg[scenario_num == s]
    gam_list[[s]] <- gam(ka_mean ~ s(n_p_a), data = x)
    pred_list[[s]] <- predict(gam_list[[s]], newdata = df, se.fit = TRUE) |>
        data.frame() |>
        mutate(n = seq(0.05, 0.75, 0.025))
}

#name the gams list
names(gam_list) <- sc_labels
names(pred_list) <- sc_labels

# bind together
pred_npa_gams <- bind_rows(pred_list, .id = "scenario") |>
    as_tibble()
    
base50 <- filter(pred_npa_gams, n == 0.5 & scenario == "null")$fit

# plot...
calibrate_gams_gg <- ggplot() +
    geom_point(data = calibrate_gam, aes(x = n_p_a, y = ka_mean), col = "dark grey") +
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

svglite(file = "ms/figs/figX_calibrateGAMs.svg", width = 11.5, height = 8.5, fix_text_size = FALSE)
calibrate_gams_gg
dev.off()
