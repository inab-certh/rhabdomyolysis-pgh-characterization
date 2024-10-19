#!/usr/bin/env Rscript

result_files <- list.files("results", recursive = TRUE, full.names = TRUE)

if (!dir.exists("shiny/data")) {
  dir.create("shiny/data")
  message("Created directory: ", crayon::italic("shiny/data"))
}

file.copy(result_files, "shiny/data")

sapply(
  result_files,
  function(file, directory) file.copy(from = file, to = file.path(directory, basename(file))),
  directory = "shiny/data"
)
