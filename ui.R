#
# This is the user-interface definition of a Shiny web application. You can
# run the application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)

source("R/analysis_selector_module.R")
source("R/significance_calculator_module.R")
source("R/ui_elements_helper.R")

packagename = "VizInf"

landing_page <- {
  tabPanel(title = "Menu",
    div(
      intro_text(),
      analysis_selection_ui("main_page"),
  class="main-page-container") #close container                
 ) #close "Menu" tabPanel tab
}

analyze_page <- {
  tabPanel("Analyze",
    conditionalPanel(
      condition = "!output.analysis_selected",
      h2("Choose an analysis to get started"),
      analysis_selection_ui("analysis_page")
    ),

    conditionalPanel(
      condition = "output.analysis_selected",
      sidebarLayout(
        sidebarPanel(
          uiOutput("dataChooser"),
          uiOutput("inputColumns"),
          uiOutput("plotSettings"),
          uiOutput("submitSetup"),
          uiOutput("saveSetup"),
          textOutput("debug")
        ),
        mainPanel(
          uiOutput("instructionBar"),
          plotOutput("outputPane"),
          uiOutput("enterVote"),
          uiOutput("submitVote"),
          uiOutput("explanationSection"),
          uiOutput("gotoSignificance")
        )
      ),
      uiOutput("documentationUI")
    )
  ) #close "Analyze" tab
}

learn_page <- {
  tabPanel("Learn",
    div(p("Topic Explanations"))
  ) #close "Learn" tab
}

walkthrough_page <- {
  tabPanel("Walkthrough",
    uiOutput("walkthroughText")
  )
}

calculate_page <- {
  tabPanel("Calculate",
    significance_calculator_ui("significance")
  ) #close "Calculate" tab
}

shinyUI(fluidPage(
  theme = "style.css",
  navbarPage(title = packagename, id = packagename, selected = 'Menu',
      landing_page,
      analyze_page,
      walkthrough_page,
      calculate_page
  ),
))

