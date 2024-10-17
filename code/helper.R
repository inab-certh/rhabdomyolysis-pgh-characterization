run_in_subgroups <- function(data, subgroup_settings, target, fun, ...) {
  
 result <- list()
  
  for (i in seq_along(subgroup_settings)) {
    tmp <- data |> 
      dplyr::filter(rowId %in% subgroup_settings[[i]]) |> 
      dplyr::filter(conceptId == target) |> 
      dplyr::pull(covariateValue)
    
    result[i] <-fun(tmp, ...)
  }
 
 names(result) <- names(subgroup_settings)

 return(result)
}

run_in_analysis <- function(data, analysis_id, fun, ...) {
  data |> 
    dplyr::filter(analysisId == analysis_id) |> 
    dplyr::group_by(covariateName) |> 
    dplyr::summarise(result = fun(covariateValue, ...)) |> 
    dplyr::arrange(dplyr::desc(result))
}

run_subgroup_in_analysis <- function(data, subgroup_settings, 
                                     target, result_label = "result", fun, ...) {
  result <- list()
  
  for (i in seq_along(subgroup_settings)) {
    tmp <- data |> 
      dplyr::filter(rowId %in% subgroup_settings[[i]]) |> 
      dplyr::filter(analysisId == target) |> 
      dplyr::group_by(covariateName) |> 
      tidyr::nest() |> 
      dplyr::mutate(
        result = sapply(data, fun, n = length(subgroup_settings[[i]]))
      ) |> 
      dplyr::select(-data) |> 
      dplyr::ungroup() |> 
      dplyr::arrange(dplyr::desc(result)) |> 
      dplyr::rename("{result_label}" := "result")
    
    result[[i]] <- tmp
  }
  
  names(result) <- names(subgroup_settings)
  
  return(result)
}
