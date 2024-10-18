#!/usr/bin/env Rscript
source("code/helper.R")

covariateData <- FeatureExtraction::loadCovariateData("covariateData")

covariates <- covariateData$covariates |> dplyr::collect()
covariateRef <- covariateData$covariateRef |> dplyr::collect()
analysisRef <- covariateData$analysisRef |> dplyr::collect()

FeatureExtraction::summary(covariateData)

extended_covariates <- covariates |> 
  dplyr::left_join(covariateRef, by = "covariateId") |> 
  dplyr::arrange(rowId, analysisId, covariateId) |> 
  dplyr::mutate(
    covariateName = stringr::str_remove(covariateName, pattern = ".*: ")
  ) |> 
  dplyr::left_join(
    analysisRef |> dplyr::select(analysisId, analysisName),
    by = "analysisId"
  )

# ------------------------------------------------------------------------------
# Overall analyses
# ------------------------------------------------------------------------------

analysis_ids_any_time <- c(
  gender = 1,
  conditions = 101, 
  drugs = 301,
  procedures = 501
)
analysis_ids_short_term <- c(
  gender = 1,
  conditions = 104, 
  drugs = 304,
  drug_groups = 412,
  procedures = 504
)

overall_analysis_any_time <- analysis_ids_any_time |> 
  purrr::map(
    .f = run_in_analysis,
    data = extended_covariates, 
    fun = function(df, n = 320) length(unique(df$rowId)) / n * 100,
    file = "results"
  )
overall_analysis_short_term <- analysis_ids_short_term |> 
  purrr::map(
    .f = run_in_analysis,
    data = extended_covariates, 
    fun = function(df, n = 320) length(unique(df$rowId)) / n * 100,
    file = "results"
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

gender_subgroup_analysis_any_time <- analysis_ids_any_time |> 
  purrr::map(
    .f = run_subgroup_in_analysis,
    data = extended_covariates, 
    subgroup_settings = subgroup_settings,
    result_label = "percent",
    fun = function(df, n) length(unique(df$rowId)) / n * 100,
    file = "results"
  )

gender_subgroup_analysis_short_term <- analysis_ids_short_term |> 
  purrr::map(
    .f = run_subgroup_in_analysis,
    data = extended_covariates, 
    subgroup_settings = subgroup_settings,
    result_label = "percent",
    fun = function(df, n) length(unique(df$rowId)) / n * 100,
    file = "results"
  )