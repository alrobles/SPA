if (!require("tidyverse")) install.packages("tidyverse")
if (!require("terra")) install.packages("terra")

root <- getwd()
outputPath <- paste0(root, "/", "data-raw/output")
mapfiles <- list.files(path = outputPath, recursive = TRUE, full.names = TRUE)

mapFiles <- mapfiles %>%
  enframe() %>%
  filter(grepl("BCE_avg.asc$", value)) %>%
  pull(value)

mapPresent <- list.files(path = outputPath,
                         pattern = "sciurus_aberti_avg.asc$",
                         recursive = TRUE,
                         full.names = TRUE)

rastPresent <- terra::rast(mapPresent)
rastPresent <- mean(rastPresent)
rasterProjection <- terra::rast(mapFiles)
rasterProjectionPresent <- c(rasterProjection, rastPresent)
terra::writeRaster(rasterProjectionPresent, "data-raw/raster/rasterProjectionPresent.tif")

rasterProjectionPresentBin <- rasterProjectionPresent > 0.9
terra::writeRaster(rasterProjectionPresentBin, "data-raw/raster/rasterProjectionPresentBin_90.tif")



