#!/usr/bin/env Rscript

cdmDatabaseSchema <- "omop"
resultsDatabaseSchema <- "results"
databaseId <- "papag"
databaseName <- "Papageorgiou General Hospital"
databaseDescription <- "Papageorgiou General Hospital"

connectionDetails <- DatabaseConnector::createConnectionDetails(
  dbms = Sys.getenv("omop_db_dbms"),
  server = Sys.getenv("omop_db_server"),
  port = Sys.getenv("omop_db_port"),
  user = Sys.getenv("omop_db_user"),
  password = Sys.getenv("omop_db_password"),
  pathToDriver = Sys.getenv("omop_db_driver")
)


covariate_settings_list <- list(
  short_term = FeatureExtraction::createCovariateSettings(
    useDemographicsAge = TRUE,
    useDemographicsAgeGroup = TRUE,
    useDemographicsGender = TRUE,
    useConditionOccurrenceShortTerm = TRUE,
    useConditionGroupEraShortTerm = TRUE,
    useDrugExposureShortTerm = TRUE,
    useDrugGroupEraShortTerm = TRUE,
    useProcedureOccurrenceShortTerm = TRUE,
    shortTermStartDays = -14,
    endDays = 14
  ),
  medium_term = FeatureExtraction::createCovariateSettings(
    useDemographicsAge = TRUE,
    useDemographicsAgeGroup = TRUE,
    useDemographicsGender = TRUE,
    useConditionOccurrenceShortTerm = TRUE,
    useConditionGroupEraShortTerm = TRUE,
    useDrugExposureShortTerm = TRUE,
    useDrugGroupEraShortTerm = TRUE,
    useProcedureOccurrenceShortTerm = TRUE,
    shortTermStartDays = -30,
    endDays = 30
  ),
  any_time_prior = FeatureExtraction::createCovariateSettings(
    useDemographicsAge = TRUE,
    useDemographicsAgeGroup = TRUE,
    useDemographicsGender = TRUE,
    useConditionOccurrenceAnyTimePrior = TRUE,
    useConditionGroupEraAnyTimePrior = TRUE,
    useDrugExposureAnyTimePrior = TRUE,
    useDrugGroupEraAnyTimePrior = TRUE,
    useProcedureOccurrenceAnyTimePrior = TRUE,
    endDays = 30
  )
)

covariate_settings_names <- names(covariate_settings_list)

if (!dir.exists("data")){
  dir.create("data")
  message("Created directory: ", crayon::italic("data"))
}

for (i in seq_along(covariate_settings_list)) {
  
  message(
    crayon::bold("Extracting covariates for analysis: "),
    crayon::bold(crayon::italic(covariate_settings_names[i]))
  )
  
  covariateData <- FeatureExtraction::getDbCovariateData(
    connectionDetails = connectionDetails,
    cdmDatabaseSchema = cdmDatabaseSchema,
    cohortDatabaseSchema = resultsDatabaseSchema,
    covariateSettings = covariate_settings_list[[i]],
    cohortIds = 5
  )
  
  FeatureExtraction::saveCovariateData(
    covariateData = covariateData,
    file = file.path(
      "data",
      paste("covariateData", covariate_settings_names[i], sep = "_")
    )
  )
  
  message(
    "Saved covariateData for analysis: ", 
    crayon::style(covariate_settings_names[i], crayon::italic)
  )
}

