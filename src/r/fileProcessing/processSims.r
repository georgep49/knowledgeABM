library(tidyverse)
library(data.table)
library(janitor)


# process_bch_sims <- function(base_path, nl_file_name, save_file) 
# {   
#     p_name <- paste0(base_path, "/", nl_file_name, ".csv")
#     s_name <- paste0(base_path, "/", save_file, ".RData")
#     z_name <- paste0(base_path, "/", save_file, ".zip")

#     # custom netlogo file output
#     f <- list.files(base_path, pattern = "_gen", full.names = TRUE)
    
#     cat(paste("Loading", length(f), "csv files...", "\n"))
    
#     # netlogo bhs output
#     p <- fread(p_name, skip = 6) |>
#         janitor::clean_names()

#     ff <- lapply(f, fread) |>    # data.table::
#         bind_rows()

#     cat(paste("Joining and tagging data-tables...", "\n"))

#     sim_all <- ff |>
#         left_join(p, by = c("rep" = "run_number")) |>
#         mutate(scenario = case_when(
#             spatial_learn == FALSE & social_learn == FALSE & know_move == FALSE ~ 1,
#             spatial_learn == TRUE & social_learn == FALSE & know_move == FALSE ~ 2,
#             spatial_learn == FALSE & social_learn == TRUE & know_move == FALSE ~ 3,
#             spatial_learn == TRUE & social_learn == TRUE & know_move == FALSE ~ 4,
#             spatial_learn == FALSE & social_learn == FALSE & know_move == TRUE ~ 5,
#             spatial_learn == TRUE & social_learn == FALSE & know_move == TRUE ~ 6,
#             spatial_learn == FALSE & social_learn == TRUE & know_move == TRUE ~ 7,
#             spatial_learn == TRUE & social_learn == TRUE & know_move == TRUE ~ 8,
#         )) |>
#         mutate(sc_tag = letters[scenario])

#     cat(paste("Saving R image...", "\n"))
#     save(list = ls(all.names = TRUE), file = s_name, envir = environment())
#     # https://stackoverflow.com/questions/49013427/r-saving-image-within-function-is-not-loading
# }

# tidy_bch_sims <- function(base_path, zip_file)
# {
#     z_name <- paste0(base_path, "/", zip_file, ".zip")

    
#     # zip and remove
#     cat(paste("Zipping and removing csv files...", "\n"))
#     f <- list.files(base_path, pattern = "_gen|_time", full.names = TRUE)
    
#     if (!file.exists(z_name)) {zip::zip(zipfile = z_name, files = f) }

#     file.remove(f)
# }



###############################################
process_bch_sims(base_path = "src/nlogo/baseline-nunits",
    nl_file_name = "hysteresis baseline-agents-units-table",
    save_file = "baselineControl")
    
process_bch_sims(base_path = "src/nlogo/calibrate",
    nl_file_name = "hysteresis calibrate-table",
    save_file = "calibrate")

process_bch_sims(base_path = "src/nlogo/amt-loss-return",
    nl_file_name = "hysteresis amount-of-loss-return-table",
    save_file = "amtLossReturn")

process_bch_sims(base_path = "src/nlogo/rate-loss-return",
    nl_file_name = "hysteresis rate-of-loss-return-table",
    save_file = "rateLossReturn")

process_bch_sims(base_path = "src/nlogo/sa-asymm",
    nl_file_name = "hysteresis sa-asymm-table",
    save_file = "saAsymm")

process_bch_sims(base_path = "src/nlogo/sa-cogproximity",
    nl_file_name = "hysteresis sa-cogproximity-table",
    save_file = "saCogProximity")

process_bch_sims(base_path = "src/nlogo/sa-defect",
    nl_file_name = "hysteresis baseline-defect-table",
    save_file = "saDefect")

process_bch_sims(base_path = "src/nlogo/sa-parenttransfer",
    nl_file_name = "hysteresis sa-parenttransfer-table",
    save_file = "saParentTransfer")

process_bch_sims(base_path = "src/nlogo/sa-spatial-nhb",
    nl_file_name = "hysteresis spatial-nhb-size-table",
    save_file = "saSpatialNhb")



################################################################
# Unzip them all if needs be (*much* quicker than WinZip)
zip::unzip(zipfile = "src/nlogo/baseline-nunits/baselineControl.zip",
    exdir = "src/nlogo/baseline-nunits",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/calibrate/calibrate.zip",
    exdir = "src/nlogo/calibrate",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/amt-loss-return/amtLossReturn.zip",
    exdir = "src/nlogo/amt-loss-return",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/rate-loss-return/rateLossReturn.zip",
    exdir = "src/nlogo/rate-loss-return",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/sa-asymm/saAsymm.zip",
    exdir = "src/nlogo/sa-asymm",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/sa-cogproximity/saCogProximity.zip",
    exdir = "src/nlogo/sa-cogproximity",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/sa-defect/saDefect.zip",
    exdir = "src/nlogo/sa-defect",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/sa-parenttransfer/saParentTransfer.zip",
    exdir = "src/nlogo/sa-parenttransfer",
    junkpaths = TRUE)

zip::unzip(zipfile = "src/nlogo/sa-spatial-nhb/saSpatialNhb.zip",
    exdir = "src/nlogo/sa-spatial-nhb",
    junkpaths = TRUE)

#########################################################
tidy_bch_sims(base_path = "src/nlogo/baseline-nunits",
    zip_file = "baselineControl")

tidy_bch_sims(base_path = "src/nlogo/calibrate",
    zip_file = "calibrate")

tidy_bch_sims(base_path = "src/nlogo/amt-loss-return",
    zip_file = "amtLossReturn")

tidy_bch_sims(base_path = "src/nlogo/rate-loss-return",
    zip_file = "rateLossReturn")

tidy_bch_sims(base_path = "src/nlogo/sa-asymm",
    zip_file = "saAsymm")

tidy_bch_sims(base_path = "src/nlogo/sa-cogproximity",
    zip_file = "saCogProximity")

tidy_bch_sims(base_path = "src/nlogo/sa-defect",
    zip_file = "saDefect")

tidy_bch_sims(base_path = "src/nlogo/sa-parenttransfer",
    zip_file = "saParentTransfer")

tidy_bch_sims(base_path = "src/nlogo/sa-spatial-nhb",
    zip_file = "saSpatialNhb")
