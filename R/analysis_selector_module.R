analysis_selection_ui <- function(id) {
  ns <- NS(id)
  div(
    tags$div(class='mainsectionheader', h3('Exposure-Response')),
    fluidRow(
      analysisButton(ns("exposurecont"), "exposurecont", "Continuous response vs exposure"),
      analysisButton(ns("exposurebinary"), "exposurebinary", "Binary response rate vs exposure"),
      analysisButton(ns("exposuresurvival"), "exposuresurvival", "Survival time vs exposure"),
      class = "mainmenurow"
    ), #close fluidRow structure for exposure-response
    tags$div(class='mainsectionheader', h3('Subgroup Analysis')),
    fluidRow(
      analysisButton(ns("subgroupcont"), "subgroupcont", "Continuous response by subgroup"),
      analysisButton(ns("subgroupbinary"), "subgroupbinary", "Binary response rate by subgroup"),
      analysisButton(ns("subgroupsurvival"), "subgroupsurvival", "Survival time by subgroup"),
      class = "mainmenurow"
    ), #close fluidRow structure for subgroup analysis
    tags$div(class='mainsectionheader', h3('Multiple Comparison Analysis')),
    fluidRow(
      analysisButton(ns("linregmc"), "linregmc", "Linear Regression Multiple Comparison"),
      analysisButton(ns("scatterplot"), "scatterplot", "Scatterplot"),
      class = "mainmenurow"
    ) #close fluidRow structure for subgroup analysis
  , class="analysis-selection-container")
}


analysis_selection_server <- function(input, output, session, module_link) {
  appdir <- "models"
  supported <- list.files(appdir)
  
  lapply(supported, function(app_name)  {
    observeEvent(input[[app_name]],{
        module_link$app_name <- app_name
        if (is.null(module_link$call_counter)) {
          module_link$call_counter = 1
        }
        else {
          module_link$call_counter <- (module_link$call_counter + 1)
        }
      }
    )
  })

}
  
