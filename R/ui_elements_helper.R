intro_text <- function() {
	div(
		h2("'See'-Value App: Facilitating Visual Inference in Pharmacology"),
		p(HTML("This tool is intended to help you intuitively evaluate the presence of trends in your data.  Rather than relying on standard measures of statistical significance, this tool is meant to help you gain visual intuition for the information contained in the data by asking the user whether they can pick the true data out of a <b>lineup</b> plot.")),
		p("Start by uploading an analysis shared with you or selecting your analysis type below. You will be able to create a lineup plot from your own uploaded data or view lineups from preloaded example data.")
	)
}

analysisButton <- function(id, shortname, displayname) {
	#actionButton("exposurecont", "Continuous response vs exposure", class="mainbutton"),
 	tags$button(
      id = id,
      class = "btn btn-default action-button mainbutton shiny-bound-input",
      tags$div(p(displayname),
      tags$img(src = paste0(shortname, ".png"),
               height = "150px"))
    )
}


data_input_object <- function() {
    fileInput("uploaded_data", "Upload Data",
              accept = c(
                  "text/csv",
                  "text/comma-separated-values,text/plain",
                  ".csv"))
}

analysis_input_object <- function() {
    fileInput("uploaded_analysis", "Upload Analysis .Rdata")
}

get_data_chooser_element <- function(state) {
	if (!is.null(state$app_settings$preload_file)) {
		preload_class = if (state$preload_vignette) "btn-primary" else NULL
		will_upload_class = if (state$will_upload) "btn-primary" else NULL
		uploading_shared_class = if (state$uploading_shared) "btn-primary" else NULL

		file_upload_element = NULL
		if (state$will_upload) {
			file_upload_element = data_input_object()
		}
		else if (state$uploading_shared) {
			file_upload_element = analysis_input_object()
		}

		div(
			actionButton("load_vignette", "Load Vignette", class = preload_class),
			actionButton("will_upload_data", "Upload Data", class = will_upload_class),
			actionButton("will_upload_shared", "Upload Shared Analysis", class = uploading_shared_class),
			
			br(), br(),
			file_upload_element,
			class = "dataSourceContainer"
		)
	}

	else{
		div(
			data_input_object()
		)
	}
}


get_column_picker_ui <- function(state) {
	data <- state$data

	if (state$preload_vignette) {
		get_column_picker_ui_preload(state)
	}

	else if (state$uploading_shared & state$data_current) {
		get_column_picker_ui_saved_analysis(state)
	}

	else{
		get_column_picker_ui_nopreload(data, state)
	}
}

get_column_picker_ui_nopreload <- function(data, state) {
	data_current <- state$data_current
	settings <- state$app_settings

	if (data_current) {
		headers <- names(data)
	}
	else{
		headers <- c("--")
	}

	# Create column dropdown for a single row
	column_register <- function(row) {
		selectInput(row["shortname"], row["longname"], headers)
	}

	# Create dropdown for each row in the toRegister setting
	column_reg_inputs <- apply(settings$toRegister, 1, column_register)
	do.call(div, column_reg_inputs)
}

get_column_picker_ui_preload <- function(state) {
	settings <- state$app_settings

	# Create column dropdown for a single row with only "preloaded column" available
	column_register <- function(row) {
		selectInput(row["shortname"], row["longname"], c(row[["preload_columns"]]))
	}

	# Create dropdown for each row in the toRegister setting
	column_reg_inputs <- apply(settings$toRegister, 1, column_register)
	do.call(div, column_reg_inputs)
}

get_column_picker_ui_saved_analysis <- function(state) {
	settings <- state$app_settings

	# Create column dropdown for a single row with only "preloaded column" available
	column_register <- function(row) {
		shortname <- row["shortname"]
		selected <- state$input_overrides[[shortname]]
		selectInput(shortname, row["longname"], c(selected))
	}

	# Create dropdown for each row in the toRegister setting
	column_reg_inputs <- apply(settings$toRegister, 1, column_register)
	do.call(div, column_reg_inputs)
}

get_vote_explanation_message <- function(voted, true, n_plots = 20) {
	if (voted == true) {
	  message <- paste0("You selected plot ", voted, ", which was the true data.
	                    The probability of randomly guessing correctly was ", round(100/n_plots, digits = 2), "%.")
	  
		#message <- paste0("You selected plot ", voted,
		#	", which was the true data. This suggests that the visual test statistic was more extreme that 95% of the null plots.",
		#	" This may be a reason to believe the data is significant.")
	}
	else {
		message <- paste0("You selected plot ", voted,
			", but the true data was in plot ", true,
			". This suggests that it is difficult to visually distinguish your data from data generated under the null hypothesis.",
			" This might mean your data cannot rule out the null hypothesis.")
	}

	p(message)
}

get_instruction_bar <- function(state) {
	message = p("Your goal is to try to identify your data among similar plots containing data from the null distribution.
		 Look for the plot with the data that looks most different from the other plots and enter its index below.")

	if (state$app_name == "linregmc") {
		message = p("For this lineup, each row should be considered together as a unit. One row represents the real data, and the other rows represent the permuted data.
			Each row contains the 5 subgroups with the most significant linear regressions. In this case, a significant result is a low p-value for the null hypothesis that the slope is zero.
			Vote for the row that has the most 'distinct' results using the index on the left.")
	}

	message
}

get_vote_input <- function() {
	numericInput("vote",
	 "Which plot do you think contains the real data?",
	 1, min = 1, max = 20, step = 1)
}

get_n_plots <- function(){
  numericInput(inputId = "n_plots", 
               label = "Number of plots in lineup", 
               value = 20,
               min = 2, max = 25)
}

get_plot_settings_panel <- function(app_settings, state) {
	selected = NULL
	if (state$preload_vignette) {
		selected = app_settings$preload_plot_settings
	}

	else if (state$uploading_shared & state$data_current) {
		selected = state$input_overrides$plotToggleSettings
	}
	
	checkboxGroupInput("plotToggleSettings", "Plot Settings",
		choices=app_settings$plotOptions,
		selected=selected)
}

get_submit_settings_button <- function(state) {
    if (state$data_current & !state$preload_vignette) {
    	actionButton("submit_setup", "Generate Lineup")
    }
}

get_download_setup_button <- function(state) {
	if (state$data_current & !state$preload_vignette) {
		div(
			br(),
			p("Save your analysis setup to share with team members (file includes your uploaded data)."),
			downloadButton("downloadAnalysis", "Download Analysis Setup")
		)
    }
}

get_walkthrough_text <- function() {
	docPanel <- withMathJax(do.call(tabsetPanel, generate_documentation("walkthrough/documentation.html", is_walkthrough=TRUE)))
	renderUI({docPanel})
}