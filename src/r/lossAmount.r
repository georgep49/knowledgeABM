
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



##### Rate return / loss
# [["end-loss" 150]["rate-loss" 5]["start-return" 600]["end-return" 650]["rate-return" 0 5]]
#[["end-loss" 200]["rate-loss" 4]["start-return" 650]["end-return" 750]["rate-return" 0 4]]
#[["end-loss" 300]["rate-loss" 2]["start-return" 750]["end-return" 950]["rate-return" 0 2]]# 
# [["end-loss" 350]["rate-loss" 1]["start-return" 800]["end-return" 1050]["rate-return" 0 1]]
####
sim_t_summary <- amt_loss_return[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(tick, scenario, rate_loss, rate_return)] [
                            , no_return := rate_return == 0]

sim_g_summary <- amt_loss_return[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(gen, unit, scenario, n_agents_per_unit, n_units, unit)] [
                                , n_agents := n_agents_per_unit * n_units]

sim_genbyrep_summary <- amt_loss_return[,
                            .(mean_ka = mean(ka), mean_kb = mean(kb)),
                            by = .(gen, tick, unit, scenario, n_agents_per_unit, n_units)] [
                            , n_agents := n_agents_per_unit * n_units]

sim_final_summary <- amt_loss_return[gen == 55]

npa_t_summary <- amt_loss_return[, c("rep", "tick", "scenario", "rate_loss", "rate_return", "fraction.a")] [,
                            .(mean_fa = mean(fraction.a)),
                            by = .(tick, scenario, rate_loss, rate_return)] [
                            , no_return := rate_return == 0]

npa_g_summary <- amt_loss_return[, c("rep", "gen", "scenario", "rate_loss", "rate_return", "n_p_a")] [,
                            .(mean_npa = mean(n_p_a)),
                            by = .(gen, scenario, rate_loss, rate_return)] [
                            , no_return := rate_return == 0]                            

                            ###
ggplot(npa_t_summary[no_return == TRUE]) +
    geom_line(aes(x = tick, y = mean_fa, col = rate_loss)) +
    facet_wrap(scenario ~ rate_return) +
    xlim(0, 1005)
