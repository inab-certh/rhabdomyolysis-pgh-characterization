shiny::shinyServer(
  function(
    input,
    output,
    session
  ) {
    # shiny::observe(print(input$menu1))
    file_name_reactive <- shiny::reactive({
      
    file_name <- input$analysis_name
    
    selected_menu1 <- input$menu1
    if (selected_menu1 == "overall") {
      file_name <- paste(file_name, "overall", "analysis_id", sep = "_")
    } else {
      file_name <- paste(file_name, "subgroup", sep = "_")
    }
    
    })
    shiny::observe(print(file_name_reactive()))
    # output$overall_drugs <- formattable::renderFormattable({
    #   
    #   formattable::formattable(test)
    # })
    
  })