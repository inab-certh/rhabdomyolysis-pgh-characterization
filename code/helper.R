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


run_in_analysis <- function(data, analysis_name, analysis_id, fun, file = NULL, ...) {
  result_to_return <- data |> 
    dplyr::filter(analysisId == analysis_id) |> 
    dplyr::group_by(covariateName) |> 
    tidyr::nest() |> 
    dplyr::mutate(result = unlist(purrr::map(.x = data, .f = fun, ...))) |> 
    dplyr::select(-data) |> 
    dplyr::arrange(dplyr::desc(result)) |> 
    dplyr::ungroup()
  
  if (!is.null(file)) {
    save_location <- file.path(
      file,
      paste0(analysis_name, "_", paste("overall_analysis_id", analysis_id, sep = "_"), ".csv")
    )
    readr::write_csv(
      x = result_to_return,
      file = save_location
    )
    message(paste("Wrote result in", save_location))
  }
  
  return(result_to_return)
}

run_subgroup_in_analysis <- function(data, subgroup_settings, analysis_name,
                                     subgroup_label, analysis_id, result_label = "result",
                                     file = NULL, fun, ...) {
  result_to_return <- list()
  subgroup_names <- names(subgroup_settings)
  for (i in seq_along(subgroup_settings)) {
    tmp <- data |> 
      dplyr::filter(rowId %in% subgroup_settings[[i]]) |> 
      dplyr::filter(analysisId == analysis_id) |> 
      dplyr::group_by(covariateName) |> 
      tidyr::nest() |> 
      dplyr::mutate(
        result = sapply(data, fun, n = length(subgroup_settings[[i]]))
      ) |> 
      dplyr::select(-data) |> 
      dplyr::ungroup() |> 
      dplyr::arrange(dplyr::desc(result)) |> 
      dplyr::rename("{result_label}" := "result") |> 
      dplyr::mutate(subgroup_value = subgroup_names[i])
    
    result_to_return[[i]] <- tmp
    
  }
  
  names(result_to_return) <- subgroup_names
  
  
  if (!is.null(file)) {
    save_location <- file.path(
      file,
      paste0(
        analysis_name, "_",
        paste("subgroup", subgroup_label,
              "analysis_id", analysis_id, sep = "_"),
        ".csv"
      )
    )
    readr::write_csv(
      x = dplyr::bind_rows(result_to_return),
      file = save_location
    )
    message(paste("Wrote result in", save_location))
  }
  
  return(result_to_return)
}
