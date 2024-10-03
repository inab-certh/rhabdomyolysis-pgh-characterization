covariateData <- FeatureExtraction::loadCovariateData("covariateData")

summary(covariateData)

covariates <- covariateData$covariates |> dplyr::collect()
covariateRef <- covariateData$covariateRef |> dplyr::collect()
analysisRef <- covariateData$analysisRef |> dplyr::collect()

FeatureExtraction::summary(covariateData)

aggregate <- FeatureExtraction::aggregateCovariates(covariateData)

pp <- aggregate$covariates |> dplyr::collect()
pp |> dplyr::arrange(desc(sumValue))


statinIds <- c(
  1545958, 21601860, 1592180,
  21601861, 1549686, 21601859,
  1592085, 21601857, 40165636,
  21601863, 1551860, 21601858,
  1510813, 21601862,1539403,
  21601856
)

statins <- covariates |> 
  dplyr::left_join(covariateRef, by = "covariateId") |> 
  dplyr::filter(conceptId %in% statinIds, analysisId == 301)


# Statin users overall
statins |> 
  dplyr::group_by(covariateName) |> 
  dplyr::summarise(n = n()) |> 
  dplyr::mutate(
    covariateName = stringr::str_remove(covariateName,pattern = ".*: ")
  ) |> 
  dplyr::arrange(desc(n))


multipleStatinsPatients <- statins |>
  dplyr::group_by(rowId) |>
  dplyr::summarise(n = n()) |> 
  # dplyr::arrange(desc(n)) |> 
  dplyr::filter(n > 1) |> 
  dplyr::arrange(rowId) |> 
  dplyr::pull(rowId)

statins |> 
  dplyr::filter(rowId %in% multipleStatinsPatients) |> 
  dplyr::select(rowId, covariateName, covariateValue) |> 
  dplyr::mutate(
    covariateName = stringr::str_remove(covariateName,pattern = ".*: ")
  ) |> 
  dplyr::arrange(rowId) |> 
  tidyr::pivot_wider(
    names_from = covariateName,
    values_from = covariateValue
  ) |> 
  dplyr::rowwise() |> 
  dplyr::mutate(
    sum = sum(
      simvastatin,
      atorvastatin,
      rosuvastatin,
      lovastatin,
      pravastatin,
      na.rm = TRUE
    )
  ) |> 
  dplyr::arrange(desc(sum))
  



covariateDataStatins <- FeatureExtraction::loadCovariateData("covariateDataStatins")

summary(covariateDataStatins)

covariates <- covariateDataStatins$covariates |> dplyr::collect()
covariateRef <- covariateDataStatins$covariateRef |> dplyr::collect()
analysisRef <- covariateDataStatins$analysisRef |> dplyr::collect()

FeatureExtraction::summary(covariateData)

aggregate <- FeatureExtraction::aggregateCovariates(covariateData)

pp <- aggregate$covariates |> dplyr::collect()
pp |> dplyr::arrange(desc(sumValue))

covariates |> 
  dplyr::left_join(covariateRef, by = "covariateId") |> 
  dplyr::glimpse()



