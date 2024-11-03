
library(tidyverse)
library(data.table)
library(janitor)

# source("src/r/processSimsFuncs.r")

# process_bch_sims(base_path = "ms/data/amt-loss-return",
#     nl_file_name = "hysteresis amount-of-loss-return-table",
#     save_file = "amtLossReturn")

# amt_loss_return <- sim_all
# gdata::keep(amt_loss_return, sure = TRUE)
# save.image("ms/data/amt-loss-return/amtLossReturn.RData")


# source("src/r/processSimsFuncs.r")

# tidy_bch_sims(base_path = "ms/data/amt-loss-return",
#     zip_file = "amtLossReturn")


# ####
# library(tidyverse)
# library(data.table)
# library(janitor)

# source("src/r/processSimsFuncs.r")

# process_bch_sims(base_path = "ms/data/rate-loss-return",
#     nl_file_name = "hysteresis rate-of-loss-return-table",
#     save_file = "rateLossReturn")

# rate_loss_return <- sim_all
# gdata::keep(rate_loss_return, sure = TRUE)
# save.image("ms/data/amt-loss-return/rateLossReturn.RData")

# source("src/r/processSimsFuncs.r")

# tidy_bch_sims(base_path = "ms/data/rate-loss-return",
#     zip_file = "rateLossReturn")

####
# [["rate-return" 0 1]["rate-loss" 1]]
# [["rate-return" 0 2]["rate-loss" 2]]
# [["rate-return" 0 3]["rate-loss" 3]]
# [["rate-return" 0 4]["rate-loss" 4]]
# [["rate-return" 0 5]["rate-loss" 5]]

load("ms/data/amt-loss-return/amtLossReturn.RData")

amt_loss_return[, no_return := rate_return == 0]

sc <- 5
x <- amt_loss_return[scenario == sc]|>
    group_by(gen, rate_loss, rate_return, no_return, rep) |>
    summarise(mka = mean(ka), fa = mean(fraction.a)) |>
    ungroup()

df <- data.frame(n_p_a = x$fa)
x$pp <- predict(object = s, newdata = df, type = "response")

y <- x |>
    group_by(gen, rate_loss, rate_return, no_return) |>
    summarise(fa = mean(fa), pp = mean(pp)) |>
    ungroup()

ggplot() +
    geom_line(data = x, aes(x = gen, y = mka, col = as.factor(rate_return), group = rep),alpha = 0.5) +
    geom_line(data = y, aes(x = gen, y = fa * 100)) +
    geom_line(data = y, aes(x = gen, y = pp), linetype = 2) +
    facet_grid(no_return ~ rate_loss) +
    scale_colour_brewer(type = "qual", palette = "Dark2", name = "Return rate") +
    xlim(0,55) +
    theme_bw()
