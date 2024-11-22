
library(tidyverse)
library(data.table)
library(janitor)

source("src/r/fileProcessing/processSimsFuncs.r")

process_bch_sims(base_path = "ms/data/counterpa",
    nl_file_name = "hysteresis counterpa-table",
    save_file = "counterpa")

counter_pa <- sim_all
gdata::keep(counter_pa, sure = TRUE)
save.image("ms/data/counterpa/counterpa.RData")


source("src/r/fileProcessing/processSimsFuncs.r")

tidy_bch_sims(base_path = "ms/data/counterpa",
    zip_file = "counterpa")

save.image("ms/data/counterpa/counterpa.RData")
####

##### Rate return / loss
#loss/return = 3
# scenarios 5 and 7

# Example of how resource preference can counter hysteresis
load("ms/data/counterpa/counterpa.RData")
load("ms/data/calibrate/calibrate.RData")


plot_list <- vector(mode = "list", length = 2)
idx <- 1

for (sc in c(5,7))
{
    x <- counter_pa[scenario == sc] |>
        group_by(gen, scenario, res_a_preference, rep) |>
        summarise(mka = mean(ka), fa = mean(fraction.a), lka = quantile(ka, 0.25), uka = quantile(ka, 0.75)) |>
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
        geom_line(data = y, aes(x = gen, y = fa * 100), col = rgb(27,158,119, maxColorValue = 256)) +
        geom_line(data = y, aes(x = gen, y = pp), col = rgb(128, 128, 128, maxColorValue =  256)) +
        scale_colour_brewer(type = "qual", palette = "Dark2", name = "Preference") +
        scale_fill_brewer(type = "qual", palette = "Dark2", name = "Preference") +
        facet_grid(~scenario) +
        xlim(0,55) +
        theme_bw()

    idx <- idx + 1
}

library(patchwork)
library(svglite)
svglite(file = "counterPA.svg", width = 9, height = 5, fix_text_size = FALSE) 
plot_list[[5]] + plot_list[[7]] +
        plot_layout(guides = "collect")
dev.off()
