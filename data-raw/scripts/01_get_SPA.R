if (!require("terra")) install.packages("terra")
if (!require("tidyverse")) install.packages("tidyverse")

# This table contains pairwise georeferenced Fst values
# for 10 populations of Sciurus aberti.
# It's a modification from Bono et al (2019).
# The original paper url is:
# https://doi.org/10.1186/s12862-018-1248-4
# The original data can be downloaded from:
# https://static-content.springer.com/esm/art%3A10.1186%2Fs12862-018-1248-4/MediaObjects/12862_2018_1248_MOESM1_ESM.xlsx

aberti_pops <- readr::read_csv("data-raw/tables/abertiFSTallCoordinates.csv")

# This raster layer contains the present species distribution model
# and the projections to the past climate scenarios.
# The input data for ENM is in data-raw/input_layers

rasterProjectionPresent <- terra::rast("data-raw/raster/rasterProjectionPresent.tif")

nlayers <- dim(rasterProjectionPresent)[3]

SPA <- sum(rasterProjectionPresent)/(nlayers)
names(SPA) <- "SPA"
terra::writeRaster(SPA, filename = "data-raw/raster/SPA.tif")

aberti_pops_sf <- aberti_pops %>%
  sf::st_as_sf(coords = c("longitude", "latitude"))

SPA_points <- terra::extract(SPA, aberti_pops_sf)
aberti_fst_SPA_df <- cbind(aberti_pops, SPA_points ) %>%
  as_tibble()

aberti_fst_SPA_df %>%
  write_csv("data-raw/tables/abertiFstSPA.csv")

