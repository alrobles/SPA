#' get SPA (Suitability prevalence Area)
#'
#' @param spatRaster a raster stack of environmental suitabilities along time
#' @param mean Type of mean to calculate. Could be arithmetic or geometric
#'
#' @return a raster with SPA values
#' @export
#'
#' @examples
#' rasterProjectionPresent <- terra::rast("data-raw/raster/rasterProjectionPresent.tif")
#' get_SPA(rasterProjectionPresent)
get_SPA <- function(spatRaster, mean = "arithmetic"){
  nlayers <- dim(spatRaster)[3]
  if(mean == "arithmetic"){
    SPA <- sum(spatRaster)/(nlayers)
  } else if (mean == "harmonic") {
    inverse_SPA <- sum(1/( (spatRaster+ 0.001))/(nlayers) )
    SPA <- 1/inverse_SPA

  }
  names(SPA) <- "SPA"
  return(SPA)
}
