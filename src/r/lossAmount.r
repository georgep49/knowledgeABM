
library(tidyverse)
library(data.table)
library(janitor)

f <- list.files("output/data/amount-loss-return", pattern = "_gen", full.names = TRUE)

p <- read_csv("output/data/amount-loss-return/hysteresis-amount-loss-return-table.csv", skip = 6) |>
    janitor::clean_names()

amt_loss_return <- lapply(f, fread) |>    # data.table
    bind_rows(.id = "id") |>
    mutate(id = f[as.numeric(id)],
           id <- gsub(pattern = "output/data/amount-loss-return/", "", id) ) 

pp <- select(p, run_number, n_p_a, rate_loss, rate_return, start_loss, 
    end_loss, start_return, end_return, spatial_learn, social_learn, know_move)

amt_loss_return <- amt_loss_return |>
    left_join(pp, by = c("rep" = "run_number"))

amt_loss_return <- amt_loss_return |>
    mutate(scenario = case_when(
        spatial_learn == FALSE & social_learn == FALSE & know_move == FALSE ~ 1,
        spatial_learn == TRUE & social_learn == FALSE & know_move == FALSE ~ 2,
        spatial_learn == FALSE & social_learn == TRUE & know_move == FALSE ~ 3,
        spatial_learn == TRUE & social_learn == TRUE & know_move == FALSE ~ 4,
        spatial_learn == FALSE & social_learn == FALSE & know_move == TRUE ~ 5,
        spatial_learn == TRUE & social_learn == FALSE & know_move == TRUE ~ 6,
        spatial_learn == FALSE & social_learn == TRUE & know_move == TRUE ~ 7,
        spatial_learn == TRUE & social_learn == TRUE & know_move == TRUE ~ 8,
    )) |>
    mutate(sc_tag = letters[scenario])