#!/usr/bin/env Rscript
source("code/helper.R")
args <- commandArgs(trailingOnly = TRUE)

message(
  crayon::bold("Running characterization for analysis: "),
  crayon::bold(crayon::italic(args[1]))
  )
covariateData <- FeatureExtraction::loadCovariateData(
  file = file.path(
    "data",
    paste("covariateData", args[1], sep = "_")
  )
)

covariates <- covariateData$covariates |> dplyr::collect()
covariateRef <- covariateData$covariateRef |> dplyr::collect()
analysisRef <- covariateData$analysisRef |> dplyr::collect()

FeatureExtraction::summary(covariateData)

extended_covariates <- covariates |> 
  dplyr::left_join(covariateRef, by = "covariateId") |> 
  dplyr::arrange(rowId, analysisId, covariateId) |> 
  # dplyr::mutate(
  #   covariateName = stringr::str_remove(covariateName, pattern = ".*: ")
  # ) |> 
  dplyr::mutate(
    covariateName = stringr::str_replace(
      covariateName, pattern = "(during).*?:", ":"
    )
  ) |> 
  dplyr::left_join(
    analysisRef |> dplyr::select(analysisId, analysisName),
    by = "analysisId"
  )



# ------------------------------------------------------------------------------
# Overall analyses
# ------------------------------------------------------------------------------

analysis_ids <- analysisRef |> 
  dplyr::filter(isBinary == "Y") |> 
  dplyr::pull(analysisId)

multiple_concept_check <- analysis_ids |> 
  purrr::map_lgl(
    .f = is_multiple_concept,
    data = extended_covariates
  )

analysisRef <- dplyr::tibble(
  analysisId = analysis_ids,
  multipleConceptCheck = multiple_concept_check
) |> 
  dplyr::left_join(analysisRef, by = "analysisId")

save_directory <- file.path(
  "results",
  paste("results", args[1], sep = "_")
)

if (!dir.exists(save_directory)) {
  dir.create(path = save_directory, recursive = TRUE)
  message("Created directory: ", crayon::italic(save_directory))
}

n_total <- length(unique(extended_covariates$rowId))

overall_analysis <- analysis_ids |> 
  purrr::map(
    .f = run_in_analysis,
    data = extended_covariates, 
    fun = function(df, n = n_total) length(unique(df$rowId)) / n * 100,
    file = save_directory,
    analysis_name = args[1],
    analysisRef = analysisRef,
    n_total = n_total
  )


# ------------------------------------------------------------------------------
# Subgroup analyses
# ------------------------------------------------------------------------------

male_patient_ids <- extended_covariates |>
  dplyr::filter(conceptId == 8507) |>
  dplyr::pull(rowId) |>
  unique()
female_patient_ids <- extended_covariates |>
  dplyr::filter(conceptId == 8532) |>
  dplyr::pull(rowId) |>
  unique()
unknown_gender_patient_ids <- extended_covariates |>
  dplyr::filter(conceptId == 4214687) |>
  dplyr::pull(rowId) |>
  unique()

subgroup_settings <- list(
  female = female_patient_ids,
  male = male_patient_ids
)

gender_subgroup_analysis <- analysis_ids |>
  purrr::map(
    .f = run_subgroup_in_analysis,
    data = extended_covariates,
    subgroup_settings = subgroup_settings,
    result_label = "result",
    fun = function(df, n) length(unique(df$rowId)) / n * 100,
    file = save_directory,
    analysis_name = args[1],
    subgroup_label = "gender"
  )




analysisRef |> 
  dplyr::mutate(
    analysisNameShiny = dplyr::case_when(
      stringr::str_detect(analysisName, "ConditionGroup") ~ "Condition groups",
      stringr::str_detect(analysisName, "DrugExposure") ~ "Drugs",
      stringr::str_detect(analysisName, "Gender") ~ "Gender",
      stringr::str_detect(analysisName, "AgeGroup") ~ "Age groups",
      stringr::str_detect(analysisName, "Age") ~ "Age",
      stringr::str_detect(analysisName, "DrugGroup") ~ "Drug groups",
      stringr::str_detect(analysisName, "ProcedureOccurrence") ~ "Procedures",
      stringr::str_detect(analysisName, "ConditionOccurrence") ~ "Conditions",
      stringr::str_detect(analysisName, "MeasurementRange") ~ "Measurement range",
      stringr::str_detect(analysisName, "MeasurementValue") ~ "Measurement value",
      stringr::str_detect(analysisName, "Measurement") ~ "Measurement"
    ),
    analysis = args[1]
  ) |> 
  dplyr::arrange(analysisId) |> 
  readr::write_csv(
    file = file.path(
      "results",
      paste("results", args[1], sep = "_"),
      paste0(paste(args[1], "analysis_ref", sep = "_"), ".csv")
    )
  )
