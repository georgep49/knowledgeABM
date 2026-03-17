
# Code to analyse and visualise loss of resource access

library(tidyverse)
library(data.table)
library(janitor)
library(mgcv)

load("ms/data/calibrate/calibrate.RData")
source("src/r/fileProcessing/processSimsFuncs.r")

########
amt_loss_return <- process_sa(csv_path = "ms/data/amt-loss-return",
    prm_file = "hysteresis amount-of-loss-return-table.csv",
    out_file = "amtLossReturn.csv",
    save_file = "amtLossReturn.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn", "know_move", 
                "rate_return", "rate_loss"),
    delta_sim = TRUE)

# zip and remove from directory
f <- list.files("ms/data/sa-asymm", pattern = "_gen|_time", full.names = TRUE)
#zip::zip(zipfile = "ms/data/sa-asymm/sa-asymm.zip", files = f)
file.remove(f, full.names = TRUE)
save.image("ms/data/amt-loss-return/amtLossReturn.RData")

##
rate_loss <- process_sa(csv_path = "ms/data/rate-loss-return",
    prm_file = "hysteresis_v7 rate-of-loss-return-table.csv",
    out_file = "rateOfLoss.csv",
    save_file = "rateOfLoss.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn", "know_move", 
                "end_loss", "rate_return", "rate_loss", "start_return", "end_return"),
    delta_sim = TRUE)

# zip and remove from directory
f <- list.files("ms/data/rate-loss-return", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/rate-loss-return/rateOfLoss.zip", files = f)
file.remove(f, full.names = TRUE)
save.image("ms/data/rate-loss-return/rateOfLoss.RData")

## 

counter_pref_a <- process_sa(csv_path = "ms/data/counterpa",
    prm_file = "hysteresis counterpa-table.csv",
    out_file = "counterLoss.csv",
    save_file = "counterLoss.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn", "know_move", 
                "rate_return", "rate_loss", "res_a_preference"),
    delta_sim = TRUE)

# zip and remove from director
f <- list.files("ms/data/counterpa", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/counterpa/counterLoss.zip", files = f)
file.remove(f, full.names = TRUE)
save.image("ms/data/rate-loss-return/counterLoss.RData")


#####################################
### Rate of loss, with return

load("ms/data/rate-loss-return/rateofLoss.RData")
load("ms/data/calibrate/calibrate.RData")

rate_loss_return <- as.data.table(rate_loss$sa) |>
    janitor::clean_names()

sc_labels <- c("null", "spatial", "social", "spatial+social", "know_move", "spatial+know_move", 
    "social+know_move", "spatial+social+know_move")

rate_loss_return$scenario_num <- match(rate_loss_return$scenario, lvl)
rate_loss_return$scenario <- sc_labels[rate_loss_return$scenario_num]

rate_loss_return[, no_return := rate_return != 0]

plot_list <- vector(mode = "list", length = 8)
names(plot_list) <- sc_labels

xmn <- 0; xmx <-  c(110, 70, 60, 55, 55)

xax <- list(scale_x_continuous(limits = c(0, 100)),
    scale_x_continuous(limits = c(0, 60)),
    scale_x_continuous(limits = c(0, 50)),
    scale_x_continuous(limits = c(0, 50)),
    scale_x_continuous(limits = c(0, 50)))

for (sc in sc_labels)
{
    x <- rate_loss_return[scenario == sc,
        .(mka = mean(ka), fa = mean(fraction_a)),
        by = .(gen, rate_loss, rate_return, no_return, rep)]

    df <- data.frame(n_p_a = x$fa)
    x$pp <- predict(object = gam_list[[sc]], newdata = df, type = "response")

    y <- x [,
            .(fa = mean(fa), pp = mean(pp)),
            by = .(gen, rate_loss, rate_return, no_return)]
    
    plot_list[[sc]] <- ggplot() +
        geom_line(data = x, aes(x = gen, y = mka, col = as.factor(rate_return), group = rep), alpha = 0.5) +
        geom_line(data = y, aes(x = gen, y = fa * 100)) +
        geom_line(data = y, aes(x = gen, y = pp), linetype = 2) +
        facet_grid(no_return ~ rate_loss, scales = "free_x") +
        scale_colour_brewer(type = "qual", palette = "Dark2", name = "Return rate") +
        ggh4x::facetted_pos_scales(x = xax) +
        labs(y = "Mean knowledge of 'a'", x = "Generation")
        theme_bw()
}


save.image("ms/data/rate-loss-return/rateOfLoss.RData")

library(svglite)
library(patchwork)
svglite(file = "ms/figs/figX_rateOfLoss.svg", width = 11.5, height = 8.5, fix_text_size = FALSE) 
plot_list[[5]] / plot_list[[7]] +
    plot_layout(guides = "collect", axes = "collect", axis_titles = "collect") +
    plot_annotation(tag_levels = "a", tag_suffix = ")")
dev.off()

####
### Amount of loss with return (vary time period at constant <<rate>>)

load("ms/data/amt-loss-return/amtLossReturn.RData")
load("ms/data/calibrate/calibrate.RData")

amt_loss_return <- as.data.table(amt_loss_return$sa) |>
    janitor::clean_names()

sc_labels <- c("null", "spatial", "social", "spatial+social", "know_move", "spatial+know_move", 
    "social+know_move", "spatial+social+know_move")
amt_loss_return$scenario_num <- match(amt_loss_return$scenario, lvl)
amt_loss_return$scenario <- sc_labels[amt_loss_return$scenario_num]

amt_loss_return[, no_return := (rate_return == 0)] # t-f flag for return

plot_list <- vector(mode = "list", length = 8)
names(plot_list) <- sc_labels

# Iterating over the scenarios, plotting loss and return
for (sc in sc_labels)
{
    x <- amt_loss_return[scenario == sc,
        .(mka = mean(ka), fa = mean(fraction_a)),
        by = .(gen, rate_loss, rate_return, no_return, rep)]

    df <- data.frame(n_p_a = x$fa)
    x$pp <- predict(object = gam_list[[sc]], newdata = df, type = "response")

    y <- x [,
            .(fa = mean(fa), pp = mean(pp)),
            by = .(gen, rate_loss, rate_return, no_return)]

    plot_list[[sc]] <- ggplot() +
        geom_line(data = x, aes(x = gen, y = mka, col = as.factor(rate_return), group = rep),alpha = 0.5) +
        geom_line(data = y, aes(x = gen, y = fa * 100)) +
        geom_line(data = y, aes(x = gen, y = pp), linetype = 2) +
        facet_grid(no_return ~ rate_loss) +
        scale_colour_brewer(type = "qual", palette = "Dark2", name = "Return rate") +
        xlim(0, 55) +
        theme_bw()
}

save.image("ms/data/amt-loss-return/amtLossReturn.RData")

library(svglite)
library(patchwork)
svglite(file = "ms/figs/figX_amountOfLoss.svg", width = 11.5, height = 8.5, fix_text_size = FALSE) 
plot_list[[5]] / plot_list[[7]] +
    plot_layout(guides = "collect", axes = "collect", axis_titles = "collect") +
    plot_annotation(tag_levels = "a", tag_suffix = ")")
dev.off()

###################################################
####

load("ms/data/counterpa/counterLoss.RData")
load("ms/data/calibrate/calibrate.RData")


plot_list <- vector(mode = "list", length = 2)
names(plot_list) <- c("know_move", "social+know_move")
idx <- 1

for (sc in c("know_move", "social+know_move"))
{
    x <- counter_pref_a$sa[scenario == sc] |>
        group_by(gen, scenario, res_a_preference) |>
        summarise(mka = mean(ka), fa = mean(fraction.a), lka = quantile(ka, 0.05), uka = quantile(ka, 0.95)) |>
        ungroup() |>
        filter(res_a_preference %in% seq(1, 1.25, 0.05))

    df <- data.frame(n_p_a = x$fa)
    x$pp <- predict(object = gam_list[[sc]], newdata = df, type = "response")

    y <- x |>
        group_by(gen, scenario, res_a_preference) |>
        summarise(mka = mean(mka), fa = mean(fa), pp = mean(pp), lka = mean(lka), uka = mean(uka)) |>
        ungroup()

    plot_list[[idx]] <- ggplot() +
        geom_line(data = y, aes(x = gen, y = mka, col = as.factor(res_a_preference)), alpha = 1) +
        geom_ribbon(data = y, aes(x = gen, ymin = lka, ymax = uka, fill = as.factor(res_a_preference)), alpha = 0.2) +
        geom_line(data = y |> filter (res_a_preference == 1), aes(x = gen, y = fa * 100), col = rgb(27,158,119, maxColorValue = 256)) +
        geom_line(data = y |> filter (res_a_preference == 1), aes(x = gen, y = pp), col = rgb(128, 128, 128, maxColorValue =  256)) +
        scale_colour_brewer(type = "qual", palette = "Dark2", name = "Preference") +
        scale_fill_brewer(type = "qual", palette = "Dark2", name = "Preference") +
        facet_grid(~scenario) +
        xlim(0, 55) +
        theme_bw()

    idx <- idx + 1
}

library(patchwork)
library(svglite)
svglite(file = "counterPA.svg", width = 9, height = 5, fix_text_size = FALSE) 
plot_list[[1]] + plot_list[[2]] +
        plot_layout(guides = "collect")
dev.off()
