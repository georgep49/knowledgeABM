
file_name <- "src/nlogo/sa-cogproximity/saCogProximity.RData"
load(file_name)
source("src/r/processSimsFuncs.r", encoding = "UTF-8")
sort(sapply(ls(), function(x) format(object.size(get(x)), unit = "Mi")))
ls()
sa_cogproximity <- sim_all
gdata::keep(sa_cogproximity, file_name, sure = TRUE)
save.image(file_name)

file_name <- "src/nlogo/sa-defect/saDefect.RData"
load(file_name)
source("src/r/processSimsFuncs.r", encoding = "UTF-8")
sort(sapply(ls(), function(x) format(object.size(get(x)), unit = "Mi")))
ls()
sa_defect <- sim_all
gdata::keep(sa_defect, file_name, sure = TRUE)
save.image(file_name)


file_name <- "src/nlogo/sa-parenttransfer/saParentTransfer.RData"
load(file_name)
source("src/r/processSimsFuncs.r", encoding = "UTF-8")
sort(sapply(ls(), function(x) format(object.size(get(x)), unit = "Mi")))
ls()
sa_parent_transfer <- sim_all
gdata::keep(sa_parent_transfer, file_name, sure = TRUE)
save.image(file_name)

file_name <- "src/nlogo/sa-spatial-nhb/saSpatialNhb.RData"
load(file_name)
source("src/r/processSimsFuncs.r", encoding = "UTF-8")
sort(sapply(ls(), function(x) format(object.size(get(x)), unit = "Mi")))
ls()
sa_spatial_nhb <- sim_all
gdata::keep(sa_spatial_nhb, file_name, sure = TRUE)
save.image(file_name)
