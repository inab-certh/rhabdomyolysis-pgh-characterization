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

covariateSettings <- FeatureExtraction::createCovariateSettings(
  useDemographicsAge = TRUE,
  useDemographicsGender = TRUE,
  useConditionOccurrenceAnyTimePrior = TRUE,
  useConditionOccurrenceLongTerm = TRUE,
  useConditionOccurrenceMediumTerm = TRUE,
  useConditionOccurrenceShortTerm = TRUE,
  useDrugExposureAnyTimePrior = TRUE,
  useDrugExposureLongTerm = TRUE,
  useDrugExposureMediumTerm = TRUE,
  useDrugExposureShortTerm = TRUE,
  useDrugGroupEraShortTerm = TRUE,
  useProcedureOccurrenceAnyTimePrior = TRUE,
  useProcedureOccurrenceLongTerm = TRUE,
  useProcedureOccurrenceMediumTerm = TRUE,
  useProcedureOccurrenceShortTerm = TRUE,
  shortTermStartDays = -14,
  endDays = 14
)

covariateData <- FeatureExtraction::getDbCovariateData(
  connectionDetails = connectionDetails,
  cdmDatabaseSchema = cdmDatabaseSchema,
  cohortDatabaseSchema = resultsDatabaseSchema,
  covariateSettings = covariateSettings,
  cohortIds = 5
)

FeatureExtraction::saveCovariateData(
  covariateData = covariateData,
  file = "covariateData"
)
