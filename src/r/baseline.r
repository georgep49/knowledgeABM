# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)

source("src/r/processSimsFuncs.r")

process_bch_sims(base_path = "ms/data/control/", nl_file_name = "hysteresis baseline-control-table", save_file = "control")
tidy_bch_sims(base_path = "ms/data/control/", zip_file = "control")

save.image("output/data/baseline/baseline.RData")

# zip and remove
# zip::zip(zipfile = "baseline_units_agents.zip", files = f)
# file.remove(list.files("output/data/baseline", pattern = ".csv", full.names = TRUE)
# )

######
