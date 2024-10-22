shiny::shinyServer(function(input, output,session) {
    
    current_tab <- shiny::reactive({
      selected_menu1 <- input$menu1
      if (selected_menu1 == "overall") {
        return(input$overall_results)
      } else {
        return(input$subgroup_results)
      }
    })
    
    current_analysis <- shiny::reactive({
      analysis <- analysis_ref |> 
        dplyr::filter(
          analysis == input$analysis_name,
          analysisNameShiny == current_tab()
        )
      result <- list(
        id = analysis |> dplyr::pull(analysisId),
        is_binary = analysis |> dplyr::pull(isBinary) == "Y"
      )
    })
    
    file_name_reactive <- shiny::reactive({
      
    file_name <- input$analysis_name
    
    selected_menu1 <- input$menu1
    if (selected_menu1 == "overall") {
      file_name <- paste(file_name, "overall", sep = "_")
    } else {
      file_name <- paste(file_name, "subgroup", input$subgroup_variable, sep = "_")
    }
    
    file_name <- paste(file_name, "analysis_id", current_analysis()$id, sep = "_")
    
    file.path("data", paste0(file_name, ".csv"))
    
    })
    
    results_file <- shiny::reactive({
      
      if (file.exists(file_name_reactive()))
        readr::read_csv(file.path(file_name_reactive())) |> 
        dplyr::mutate(result = result / 100)
      else NA
      
    })
    
    check_is_subgroup <- shiny::reactive({
      if (input$menu1 == "subgroup_analysis") TRUE
      else FALSE
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
        
        if (current_analysis()$is_binary) {
          output[[current_output()]] <- DT::renderDataTable({
            result <- form_table(results_file(), check_is_subgroup()) |> 
              formattable::as.datatable()
          })
        } else {
          output[[current_output()]] <- shiny::renderPlot({
            result <- plot_density(results_file(), check_is_subgroup()) |> 
              formattable::as.datatable()
          })
        }
      }
    })
  })