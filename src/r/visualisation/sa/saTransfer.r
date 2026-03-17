# Load and deal with the baseline runs for the bc hysteresis model
# Code to deal with trasfer SA: spatial and parent

library(tidyverse)
library(data.table)
library(janitor)

### Control values
control <- read.csv("ms/data/derived/controlFinalGenAgg.csv") |>
    data.table()

control_summ <- control[,
    .(ka_mean = mean(ka_mean), ka_p10 = mean(ka_p10), ka_p90 = mean(ka_p90)),
    by = sc_tag]

write_csv(file = "ms/data/derived/controlGrandSumm.csv", control_summ)

###### Spatial transfer - amount and function
# netlogo param table

control_summ <- read.csv(file = "ms/data/derived/controlGrandSumm.csv") |>
    data.table()

spattransf_prm <- read.csv("ms/data/sa-spatialtransfer/sa-spatialtransfer-table.csv", skip = 6) |>
    janitor::clean_names()

# get summary stats for gens >+ max_gen
spattransf_summ <- sa_spatialtransfer[gen >= 50,
    .(ka_mean = mean(ka), ka_p10 = quantile(ka, 0.10), ka_p90 = quantile(ka, 0.90)),
    by = .(rep, sc_tag)] [
        order(rep)]

spattransf_summ <- spattransf_summ |>
    left_join(spattransf_prm |> select(x_run_number, transfer_function, transfer_fraction), by = c("rep" = "x_run_number"))

##
ggplot(spattransf_summ) +
    geom_boxplot(aes(x = transfer_fraction, y = ka_mean, group = transfer_fraction), outlier.shape = NA) +
    geom_jitter(aes(x = transfer_fraction, y = ka_mean, group = transfer_fraction), width = 0.25, alpha = 0.25) +
    geom_hline(data = control_summ, aes(yintercept = ka_mean), col = "blue") +    
    facet_grid(sc_tag ~ transfer_function) +
    theme_bw() +
    labs(x = "Transfer fraction (spatial)", y = "Mean knowledge of 'a'")


###### Parent transfer - amount and function
load("ms/data/sa-parenttransfer/saParentTransfer.RData")
control_summ <- read.csv(file = "ms/data/derived/controlGrandSumm.csv")

# netlogo param table
prttransf_prm <- read.csv("ms/data/sa-parenttransfer/sa-parenttransfer-table.csv", skip = 6) |>
    janitor::clean_names()

# get summary stats for gens >+ max_gen
prttransf_summ <- sa_parenttransfer[gen >= 50,
    .(ka_mean = mean(ka), ka_p10 = quantile(ka, 0.10), ka_p90 = quantile(ka, 0.90)),
    by = .(rep, sc_tag)] [
        order(rep)]

prttransf_summ <- prttransf_summ |>
    left_join(prttransf_prm |> select(x_run_number, transfer_function, parent_transfer), by = c("rep" = "x_run_number"))

##
ggplot(prttransf_summ) +
    geom_boxplot(aes(x = parent_transfer, y = ka_mean, group = parent_transfer), outlier.shape = NA) +
    geom_jitter(aes(x = parent_transfer, y = ka_mean, group = parent_transfer), width = 0.25, alpha = 0.25) +
    geom_hline(data = control_summ, aes(yintercept = ka_mean), col = "blue") +    
    facet_grid(sc_tag ~ parent_transfer) +
    theme_bw() +
    labs(x = "Transfer fraction (parent)", y = "Mean knowledge of 'a'")
