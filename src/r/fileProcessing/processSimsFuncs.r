library(tidyverse)
library(data.table)
library(janitor)


process_bch_sims <- function(base_path, nl_file_name, save_file) 
{   
    p_name <- paste0(base_path, "/", nl_file_name, ".csv")
    s_name <- paste0(base_path, "/", save_file, ".RData")
    z_name <- paste0(base_path, "/", save_file, ".zip")

    # custom netlogo file output
    nl_files <- list.files(base_path, pattern = "_gen", full.names = TRUE)
    
    cat(paste("Loading", length(nl_files), "csv files...", "\n"))
    bhs_file <- fread(file = p_name, skip = 6) |>
        janitor::clean_names()

    # netlogo bhs output
    nl_files_all <- lapply(nl_files, fread) |>    # data.table::
        bind_rows()

    cat(paste("Joining and tagging data-tables...", "\n"))

    sim_all <- nl_files_all |>
        left_join(bhs_file, by = c("rep" = "run_number")) |>
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

    cat(paste("Saving R image...", "\n"))

    save(list = ls(all.names = TRUE), file = s_name, envir = environment())
    # https://stackoverflow.com/questions/49013427/r-saving-image-within-function-is-not-loading
}

tidy_bch_sims <- function(base_path, zip_file)
{
    z_name <- paste0(base_path, "/", zip_file, ".zip")

    
    # zip and remove
    cat(paste("Zipping and removing csv files...", "\n"))
    f <- list.files(base_path, pattern = "_gen|_time", full.names = TRUE)
    
    if (!file.exists(z_name)) {zip::zip(zipfile = z_name, files = f) }

    file.remove(f)
}

list_obj_sizes <- function()
{
    sort( sapply(mget(ls()), object.size) )
}   
