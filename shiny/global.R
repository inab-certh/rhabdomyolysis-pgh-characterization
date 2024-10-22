analysis_ref <- readr::read_csv("data/analysis_ref.csv")

form_table <- function(data, is_subgroup = FALSE) {
  formattable_options <- list()
  
  if (!is_subgroup) {
    result <- formattable::formattable(
      data |> 
        dplyr::mutate(result = formattable::percent(result)),
      list(result = formattable::color_bar(fun = "identity", color = "lightblue"))
    )
  } else {
    for (i in seq_along(unique(data$subgroup_value))) {
      formattable_options[[i]] <- formattable::color_bar(fun = "identity", color = "lightblue")
    }
    names(formattable_options) <- unique(data$subgroup_value)
    result <- formattable::formattable(
      data |> 
        dplyr::mutate(result = formattable::percent(result)) |> 
        tidyr::pivot_wider(names_from = subgroup_value, values_from = result),
      formattable_options
    )
  }
}
