### function for semi-autocontro maxent
### please don't share this code until release of the paper
if (!require("tidyverse")) install.packages("tidyverse")
if (!require("pastclim")) install.packages("pastclim")


maxent_control <- function(
    maxentPath = "data-raw/maxentSoftware/maxent.jar",
    presentPath = "data-raw/raster/input_layers_maxent/0_BCE",
    projectionPath = "data-raw/raster/input_layers_maxent/120000_BCE",
    samplefilePath = "data-raw/tables/sciurusAbertiTrain.csv",
    outputPath = "data-raw/output/2000_BCE",
    n_replicates = 2,
    n_threads = 15){
  root <- getwd()

  ### maxent command
  maxent_path <- maxentPath
  root_maxent <- paste0(root, "/", maxent_path)
  root_maxent <- str_replace_all(string = root_maxent, pattern = "\\/",replacement =  "\\\\")
  command_maxent <- paste0("java -mx1200m -jar ",
                           "\"", root_maxent, "\"")

  ### environmental layers of the present
  present_path <- presentPath
  root_present <- paste0(root, "/", present_path)
  root_present <- str_replace_all(string = root_present,
                                  pattern = "\\/",replacement =  "\\\\")

  command_environmentallayers <-
    paste0("environmentallayers=",
           "\"", root_present, "\""
    )

  ### environmental layers of the projection
  projection_path <- projectionPath
  root_projection <- paste0(root, "/", projection_path)
  root_projection <- str_replace_all(string = root_projection,
                                     pattern = "\\/",
                                     replacement =  "\\\\")
  command_projection <-
    paste0("projectionlayers=",
           "\"", root_projection, "\""
    )


  #### present point command
  samplesfile_path <- samplefilePath
  root_samplesfile <- paste0(root, "/", samplesfile_path)
  root_samplesfile <- str_replace_all(string = root_samplesfile,
                                      pattern = "\\/",replacement =  "\\\\")

  command_samplesfile <-
    paste0("samplesfile=",
           "\"", root_samplesfile, "\""
    )

  #### output command
  output_path <- outputPath
  root_output <- paste0(root, "/", output_path)
  if(!dir.exists(root_output)){
    dir.create(root_output)
  }
  root_output <- str_replace_all(string = root_output,
                                 pattern = "\\/",
                                 replacement =  "\\\\")
  command_output <-
    paste0("outputdirectory=",
           "\"", root_output, "\""
    )

  #### rest of flags
  command_replicates <- paste0("replicates=", n_replicates)
  command_threads <- paste0("threads=", n_threads)
  command_autocontrol <- "jackknife=true responsecurves=true extrapolate=false doclamp=false writeplotdata=true plots=true redoifexists autorun"

  command <- paste0(command_maxent, " ",
                    command_environmentallayers, " ",
                    command_samplesfile, " ",
                    command_projection, " ",
                    command_output, " ",
                    command_replicates, " ",
                    command_threads, " ",
                    command_autocontrol)

  system(command)
}

# Here we show the automatization of the modelling for 15 layers and
# 4 repetitions due the computation time.
# The complete set for the analysis was computed in the file:
# data-raw/raster/rasterProjectionPresent.tif

inputPath <- "data-raw/raster/input_layers_maxent/"
outputPath <- "data-raw/output/"

tsteps <- pastclim::get_time_steps("Beyer2020")
tsteps <- tsteps[tsteps %% 5000 == 0]

projectLayersList <- purrr::map_chr(tsteps, function(x){
  dirName <- paste0(inputPath, str_remove(as.character(x), "-"), "_BCE")
  return(dirName)
})

outputModelsList <- purrr::map_chr(tsteps, function(x){
  dirName <- paste0(outputPath, str_remove(as.character(x), "-"), "_BCE")
  return(dirName)
})

# apply the function to the input and output layers

# Warning, this take computation time
# we only show  replications for 15 layers
purrr::map2(projectLayersList,
            outputModelsList,
            function(input, output){
  maxent_control(projectionPath = input, outputPath = output, n_replicates = 4)
})



