if (!require("tidyverse")) install.packages("tidyverse")
if (!require("pastclim")) install.packages("pastclim")

dir.create("data-raw/raster/pastclim")
bioVars <- get_vars_for_dataset(dataset = "Beyer2020") %>%
  grep("bio\\d\\d", ., value = TRUE)


tsteps <- get_time_steps("Beyer2020")
tsteps <- tsteps[tsteps %% 2000 == 0]

# filtering only 2000 tsteps to remain systematic in the SPA


# Using this M (sensu BAM diagram) accesibility area mask
shp <- terra::vect("data-raw/shp/NA_Eco_Level1_5_6_9_10_12_13_4326.shp")

#getAllLayers
bioLayersTime <- tsteps %>%
  purrr::map(function(time){
    bio <- pastclim::region_slice(
      time_bp = time,
      bio_variables = bioVars,
      dataset = "Beyer2020"
    )
  terra::crop(bio, shp, mask = TRUE)
  })


dir.create(path = "data-raw/raster/input_layers")
outputPath <- "data-raw/raster/input_layers/"

purrr::map2(bioLayersTime, tsteps, function(x, y){
  filename <- paste0(outputPath, as.character(abs(y)), "_BCE.tif")
  terra::writeRaster(x, filename, overwrite = TRUE)
})

#Create layers for maxent analysis
dir.create(path = "data-raw/raster/input_layers_maxent")
outputPath <- "data-raw/raster/input_layers_maxent/"


bioLayersMaxent <- purrr::map2(bioLayersTime, tsteps, function(x, y){
  dirName <-  paste0(outputPath, as.character(abs(y)), "_BCE/" )
  if(!dir.exists(dirName)) {
    dir.create(dirName)
  }
   purrr::map(bioVars, function(BIO){
     filename <- paste0(dirName, BIO, ".asc")
     terra::writeRaster(x[[BIO]], filename, overwrite = TRUE, NAflag = -9999)
   })
}, .progress = TRUE)

