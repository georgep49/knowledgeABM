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


readwrite_multi_csv <- function(f, out_file, remove_out = TRUE) {
    
    require(progressr)

    if (remove_out == TRUE && file.exists(out_file)) { file.remove(out_file) }
    
    with_progress({
        
        p <- progressor(along = f)

        for (i in seq_along(f)) {
            dt <- fread(f[i], showProgress = FALSE)
            fwrite(dt, out_file, append = i != 1)
            rm(dt); gc()
            p(sprintf("Processed %s", basename(f[i])))
        }
    })
}

####

process_sa <- function(csv_path, prm_file, out_file, save_file, prm_cols, delta_sim = FALSE)
{
    # load individual csv files, combine, write
    
    f <- list.files(csv_path, pattern = "_gen", full.names = TRUE)

    cat(paste("Loading", length(f),  "csv files \n"))
    prm <- fread(paste0(csv_path, "/", prm_file), skip = 6) |>
        janitor::clean_names()

    readwrite_multi_csv(f, paste0(csv_path, "/", out_file))
    sa <- fread(paste0(csv_path, "/", out_file))

    save.image(paste0(csv_path, "/", save_file))

    # joining prm and time-series files
    cat("Joining prm and time-series files \n")
    prm <- prm[, ..prm_cols]
    prm <- setnames(prm, old = "run_number", new = "rep")

    
    summ_cols <- c("ka", "ka.var", "ka.range", "ka.lt50", "ka.lt5", "bimodal.a")
    if (delta_sim == TRUE) { summ_cols <- c(summ_cols, "fraction.a") }

    sa <- sa[,
        lapply(.SD, mean, na.rm = TRUE),
        by = .(rep, gen),
        .SDcols = summ_cols # c("ka", "ka.var", "ka.range", "ka.lt50", "ka.lt5", "bimodal.a")
        ]

    sa <- prm[sa, on = "rep"]

# bitwise encoding + labels (for facets, etc.)
    sa <- sa[, scenario := factor(
        1L +
        spatial_learn * 1L +
        social_learn  * 2L +
        know_move     * 4L,
    levels = 1:8,
    labels = c("null",  "spatial", "social", "spatial+social",
        "know_move", "spatial+knowmove", "social+know_move", "spatial+social+know_move")
    )]

    cat("Saving RData... \n")
    save.image(paste0(csv_path, "/", save_file))
    list(prm = prm, sa = sa)
}

