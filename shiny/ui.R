shiny::shinyUI(
  shinydashboardPlus::dashboardPage(
    skin                 = "black",
    title                = "Simulations",
    shinydashboard::dashboardHeader(
      title = "Characterization"
    ),
    shinydashboard::dashboardSidebar(
      shinydashboard::sidebarMenu(
        id = "menu1",
        shinydashboard::menuItem(
          tabName = "overall",
          text    = "Overall",
          icon    = icon("file-alt")
        ),
        shinydashboard::menuItem(
          tabName = "subgroup_analysis",
          text    = "Subgroup analysis",
          icon    = icon("cogs")
        )
      ),
      shinydashboard::sidebarMenu(
        id = "menu2",
        shiny::selectInput(
          inputId  = "analysis_name",
          label    = "Analysis",
          choices  = c("short_term", "medium_term", "any_time_prior"),
          selected = "short_term"
        ),
        shiny::conditionalPanel(
          condition = "input.menu1 == 'subgroup_analysis'",
          shiny::selectInput(
            inputId  = "subgroup_variable",
            label    = "Subgroup variable",
            choices  = c("gender"),
            selected = "absent"
          )
        )
      )
    ),
    shinydashboard::dashboardBody(
      shinydashboard::tabItems(
        shinydashboard::tabItem(
          tabName = "overall",
          shiny::tabsetPanel(
            id = "overall_results",
            shiny::tabPanel(
              title = "Age",
              DT::dataTableOutput("overall_age")
            ),
            shiny::tabPanel(
              title = "Drugs",
              DT::dataTableOutput("overall_drugs")
            ),
            shiny::tabPanel(
              title = "Conditions",
              DT::dataTableOutput("overall_conditions")
            ),
            shiny::tabPanel(
              title = "Procedures",
              DT::dataTableOutput("overall_procedures")
            ),
            shiny::tabPanel(
              title = "Drug groups",
              DT::dataTableOutput("overall_drug_groups")
            ),
            shiny::tabPanel(
              title = "Condition groups",
              DT::dataTableOutput("overall_condition_groups")
            )
          )
        ),
        shinydashboard::tabItem(
          tabName = "subgroup_analysis",
          shiny::tabsetPanel(
            id = "subgroup_results",
            shiny::tabPanel(
              title = "Age"
            ),
            shiny::tabPanel(
              title = "Drugs",
              DT::dataTableOutput("subgroup_analysis_drugs")
            ),
            shiny::tabPanel(
              title = "Conditions"
            ),
            shiny::tabPanel(
              title = "Procedures"
            ),
            shiny::tabPanel(
              title = "Drug groups"
            ),
            shiny::tabPanel(
              title = "Condition groups"
            )
          )
        )
      )
    )
  )
)