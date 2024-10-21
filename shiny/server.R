shiny::shinyServer(
  function(
    input,
    output,
    session
  ) {
    
    current_tab <- shiny::reactive({
      selected_menu1 <- input$menu1
      if (selected_menu1 == "overall") {
        return(input$overall_results)
      } else {
        return(input$subgroup_results)
      }
    })
    
    current_analysis_id <- shiny::reactive({
      
      analysis_ref |> 
        dplyr::filter(
          analysis == input$analysis_name,
          analysisNameShiny == current_tab()
        ) |> 
        dplyr::pull(analysisId)
      
    })
  
    file_name_reactive <- shiny::reactive({
      
    file_name <- input$analysis_name
    
    selected_menu1 <- input$menu1
    if (selected_menu1 == "overall") {
      file_name <- paste(file_name, "overall", sep = "_")
    } else {
      file_name <- paste(file_name, "subgroup", input$subgroup_variable, sep = "_")
    }
    
    file_name <- paste(file_name, "analysis_id", current_analysis_id(), sep = "_")
    
    file.path("data", paste0(file_name, ".csv"))
    
    })
    
    results_file <- shiny::reactive({
      
      if (file.exists(file_name_reactive()))
        readr::read_csv(file.path(file_name_reactive())) |> 
        dplyr::mutate(result = result / 100)
      else
        NA
      
    })
    
    current_output <- shiny::reactive({
      result <- paste(
        input$menu1,
        tolower(current_tab()),
        sep = "_"
      )
      
      stringr::str_replace_all(result, " ", "_")
    })
    
    shiny::observe({
      
      if (dplyr::is.tbl(results_file())) {
        output[[current_output()]] <- DT::renderDataTable({
          result <- form_table(results_file(), is_subgroup = F) |> 
            formattable::as.datatable()
          
        })
      }
    })
    
    
    shiny::observe(print(file_name_reactive()))
    
  })