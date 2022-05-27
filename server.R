library(shiny)
library(purrr)
library(ggplot2)
library(dplyr)
library(tidyr)
require(scales)
library(xgxr)
xgx_theme_set()

source("R/ui_elements_helper.R")
source("R/generate_documentation.R")
source("R/settings_handler.R")
source("R/significance_calculator_module.R")
source("R/analysis_selector_module.R")
source("R/upload_download_handler.R")
source("R/utils.R")

appdir <- "models"
packagename <- "VizInf"


# Update state settings based on user clicking an analysis from the main page.
set_app <- function(app_name, state, output, session) {{
	# Load documentation and settings
	currentdocfilename <- paste0(appdir,'/',app_name,'/','documentation.html')
	settingfilename = paste0(appdir,'/',app_name,'/','settings.R')
	docPanel <- withMathJax(do.call(tabsetPanel, generate_documentation(currentdocfilename)))

	source(settingfilename)
		
	state$app_name <- app_name
	state$app_settings <- app_settings
	
	# Reset UI
	output$documentationUI <- renderUI({docPanel})
	reset_analysis(output, state)
	reset_data_source(state)

	# Switch page to analyze
	updateNavbarPage(session, packagename, selected = "Analyze")
}}

handle_vote_submit <- function(input, output, state) {
	vote <- input$vote
	true <- state$true_index
	n_plots <- input$n_plots
	output$explanationSection <- renderUI(get_vote_explanation_message(vote, true, n_plots))
	output$gotoSignificance <- renderUI(actionButton("gotoSignificance", "Calculate Significance"))
}

load_vignette <- function(input, output, state) {
	reset_analysis(output, state)

	state$will_upload <- FALSE
	state$uploading_shared <- FALSE
	state$preload_vignette <- TRUE
	
	set_preload_column_inputs <- function(row) {
		state$input_overrides[[row["shortname"]]] = row["preload_columns"]
	}
	
	state$input_overrides[["plotToggleSettings"]] = state$app_settings$preload_plot_settings
	
	apply(state$app_settings$toRegister, 1, set_preload_column_inputs)

	state$data <- load_data(state$app_settings$preload_file, state)
	modified_inputs <- overwrite_list(input, state$input_overrides)

	generate_lineup_test(modified_inputs, output, state)
}

will_upload_data <- function(output, state) {
	reset_analysis(output, state)
	state$will_upload <- TRUE
	state$uploading_shared <- FALSE
	state$preload_vignette <- FALSE
	
}

will_upload_shared <- function(output, state) {
	reset_analysis(output, state)
	state$will_upload <- FALSE
	state$uploading_shared <- TRUE
	state$preload_vignette <- FALSE
}

submit_data <- function(input, output, state) {
	reset_analysis(output, state)
	load_data(input$uploaded_data, state)
}

go_to_significance_tab <- function(session) {
	updateNavbarPage(session, packagename, selected = "Calculate")
}

# Reset state variables from an old analysis and clear any outputs 
# from the left pane (lineup). Does not reset the "will_upload", "uploading_shared"
# or "preload_vignette" flags to avoid re-rendering of settings panel UI.
reset_analysis <- function(output, state) {
	state$data_current <- FALSE
	state$data <- NULL
	state$input_overrides <- list()
	state$error_state <- NULL

	output$instructionBar <- NULL
	output$outputPane <- NULL
	output$enterVote <- NULL
	output$submitVote <- NULL
	output$explanationSection <- NULL
	output$gotoSignificance <- NULL
}

# Reset data choice state.
reset_data_source <- function(state) {
	state$preload_vignette = FALSE
	state$will_upload = FALSE
	state$uploading_shared = FALSE
}

shinyServer(function(input, output, session) {
	state <- reactiveValues(
		app_name = NULL,
		app_settings = NULL,
		data_current = FALSE,
		data = NULL,
		preload_vignette = FALSE,
		will_upload = FALSE,
		uploading_shared = FALSE,
		input_overrides = list(),
		error_state = NULL)

	module_link <- reactiveValues(
		app_name = NULL,
		call_counter = NULL
	)

	###### Main page
	callModule(analysis_selection_server, "main_page", module_link)
	observeEvent(module_link$call_counter, {set_app(module_link$app_name, state, output, session)}) # handle app setting from module callback

	###### Analysis page
	callModule(analysis_selection_server, "analysis_page", module_link)
	
	# event handlers
	observeEvent(input[["load_vignette"]], {load_vignette(input, output, state)})	  # handle "load vignette" button
	observeEvent(input[["will_upload_data"]], {will_upload_data(output, state)})	  # handle "upload data" button which prompts file selection.
	observeEvent(input[["will_upload_shared"]], {will_upload_shared(output, state)})  # handle "upload shared analysis" button which prompts file selection.
	observeEvent(input[["uploaded_data"]], {submit_data(input, output, state)})   	  # handle user choosing input file from file explorer
	observeEvent(input[["uploaded_analysis"]], {load_shared_analysis(input, output, state)})   # handle user choosing input file from file explorer
	observeEvent(input[["submit_setup"]], generate_lineup_test(input, output, state)) # handle user submitting analysis settings, triggers running analysis
	observeEvent(input[["gotoSignificance"]], go_to_significance_tab(session)) 		  # handle user going to significance tab
	observeEvent(input[["submitVote"]],{handle_vote_submit(input, output, state)})	  # handle lineup vote submission

	
	# setting panel ui elements
    output$dataChooser <- renderUI({get_data_chooser_element(state)})
    output$inputColumns <- renderUI({get_column_picker_ui(state)})
    output$n_plots <- renderUI({get_n_plots()})
    output$plotSettings <- renderUI({get_plot_settings_panel(app_settings, state)})
    output$submitSetup <- renderUI({get_submit_settings_button(state)})
    output$saveSetup <- renderUI({get_download_setup_button(state)})

    callModule(significance_calculator_server, "significance")
    
    output$downloadAnalysis <- get_setup_download_handler(input, state)

    output$analysis_selected <- reactive(!(is.null(state$app_name)))
    outputOptions(output, "analysis_selected", suspendWhenHidden = FALSE)

    ## Walkthrough
	output$walkthroughText <- get_walkthrough_text()
})