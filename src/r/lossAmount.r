
library(tidyverse)
library(data.table)
library(janitor)

source("src/r/processSimsFuncs.r")

process_bch_sims(base_path = "ms/data/amt-loss-return",
    nl_file_name = "hysteresis amount-of-loss-return-table",
    save_file = "amtLossReturn")

amt_loss_return <- sim_all
gdata::keep(amt_loss_return, sure = TRUE)
save.image("ms/data/amt-loss-return/amtLossReturn.RData")


source("src/r/processSimsFuncs.r")

tidy_bch_sims(base_path = "ms/data/amt-loss-return",
    zip_file = "amtLossReturn")


####
library(tidyverse)
library(data.table)
library(janitor)

source("src/r/processSimsFuncs.r")

process_bch_sims(base_path = "ms/data/rate-loss-return",
    nl_file_name = "hysteresis rate-of-loss-return-table",
    save_file = "rateLossReturn")

rate_loss_return <- sim_all
gdata::keep(rate_loss_return, sure = TRUE)
save.image("ms/data/amt-loss-return/rateLossReturn.RData")

source("src/r/processSimsFuncs.r")

tidy_bch_sims(base_path = "ms/data/rate-loss-return",
    zip_file = "rateLossReturn")

####
