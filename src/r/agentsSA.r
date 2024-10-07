library(data.table)
library(tidyverse)
library(patchwork)

load("output/data/baseline/baseline.RData")

X <- baseline_units_agents[,
                            .(mean_ka = mean(ka), mean_range = mean(ka.range)),
                            by = .(gen, unit, scenario, n_units, n_agents)] [
                            gen == 50 & unit == 1]

Xm <- melt(X, id.vars = 1:5, measure.vars = 6:8)

a <- ggplot(Xm[variable == "mean_ka"]) +
    geom_tile(aes(x = factor(n_agents), y = n_units, fill = value)) +
    facet_grid(scenario ~ variable) +
    labs(x = "No. of agents", y = "No. of units") +
    coord_equal()

b <- ggplot(Xm[variable == "mean_range"]) +
    geom_tile(aes(x = factor(n_agents), y = n_units, fill = value)) +
    labs(x = "No. of agents", y = "No. of units") +
    facet_grid(scenario ~ variable) +
    coord_equal()

a + b
