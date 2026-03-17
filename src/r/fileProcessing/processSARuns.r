
# Load and deal with the baseline  runs for the bc hysteresis model
# These address dynamics with no change but variable number of agents, units, and different learnings

library(tidyverse)
library(data.table)
library(janitor)
library(progressr)

source("src/r/fileProcessing/processSimsFuncs.r")

#########################
## Defect
#########################

sa_defect <- process_sa(csv_path = "ms/data/sa-defect",
    prm_file = "hysteresis_v7 sa-defect-table.csv",
    out_file = "sa_defect.csv",
    save_file = "sadefect.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
         "know_move", "defect_unit"))


# zip and remove from director
f <- list.files("ms/data/sa-asymm", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-asymm/sa-asymm.zip", files = f)
file.remove(f, full.names = TRUE)

######################### 
## Asymm
#########################

# process individual model replicate files
sa_asymm <- process_sa(csv_path = "ms/data/sa-asymm",
    prm_file = "hysteresis_v7 sa-asymm-",
    out_file = "sa_asymm.csv",
    save_file = "saAsymm.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
        "know_move", "res_a_preference"))


# zip and remove from director
f <- list.files("ms/data/sa-asymm", pattern = "_gen|_time", full.names = TRUE)
zip::zip(zipfile = "ms/data/sa-asymm/sa-asymm.zip", files = f)
file.remove(f, full.names = TRUE)

#########################
## Spatial nhb
#########################

# process individual model replicate files
sa_spatialnhb <- process_sa(csv_path = "ms/data/sa-spatial-nhb",
    prm_file = "spatial-nhb-size-",
    out_file = "sa_spatial_nhb.csv",
    save_file = "saSpatialNhb.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
        "know_move", "spatial_nhb"))

# zip and remove, quicker via system
f <- list.files("ms/data/sa-spatial-nhb", pattern = "_gen|_time", full.names = TRUE)
# zip::zip(zipfile = "ms/data/sa-spatial-nhb/sa-spatial-nhb.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-spatial-nhb/saSpatialNhb.RData")
####


#########################
## Cognitive proximity
#########################
# process individual model replicate files

sa_cogproximity <- process_sa(csv_path = "ms/data/sa-cogproximity",
    prm_file = "sa-cogproximity-",
    out_file = "sa_cogproximity.csv",
    save_file = "saCogProximity.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
        "know_move", "cognitive_proximity"))

# zip and remove, quicker via system
f <- list.files("ms/data/sa-cogproximity", pattern = "_gen|_time", full.names = TRUE)
# zip::zip(zipfile = "ms/data/sa-spatial-nhb/sa-spatial-nhb.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-spatial-nhb/saSpatialNhb.RData")

# zip and remove
f <- list.files("ms/data/sa-cogproximity", pattern = "_gen|_time", full.names = TRUE)
#zip::zip(zipfile = "ms/data/sa-cogproximity/sa-cogproximity.zip", files = f)
file.remove(f, full.names = TRUE)
#

save.image("ms/data/sa-cogproximity/saCogProximity.RData")
####

#########################
## Spatial transfer
#########################

# process individual model replicate files

sa_spatialtransfer <- process_sa(csv_path = "ms/data/sa-spatialtransfer",
    prm_file = "sa-spatialtransfer-",
    out_file = "sa_spatialtransfer.csv",
    save_file = "saSpatialTransfer.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
        "know_move", "transfer_function", "transfer_fraction"))

# zip and remove, quicker via system
f <- list.files("ms/data/sa-spatialtransfer", pattern = "_gen|_time", full.names = TRUE)
# zip::zip(zipfile = "ms/data/sa-spatial-nhb/sa-spatial-nhb.zip", files = f)
file.remove(f, full.names = TRUE)
#

#########################
## Parent transfer
#########################


# process individual model replicate files

sa_parenttransfer <- process_sa(csv_path = "ms/data/sa-parenttransfer",
    prm_file = "sa-parenttransfer-table.csv",
    out_file = "sa_parenttransfer.csv",
    save_file = "saParentTransfer.RData",
    prm_cols = c("run_number", "n_p_a", "spatial_learn", "social_learn",
        "know_move", "transfer_function", "parent_transfer"))

# zip and remove, quicker via system
f <- list.files("ms/data/sa-parenttransfer", pattern = "_gen|_time", full.names = TRUE)
# zip::zip(zipfile = "ms/data/sa-spatial-nhb/sa-spatial-nhb.zip", files = f)
file.remove(f, full.names = TRUE)
#
