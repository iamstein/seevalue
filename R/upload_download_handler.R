source("R/utils.R")

get_setup_download_handler <- function(input, state) {
	downloadHandler(
		filename <- function(){
		   	datestr <- format(Sys.time(),'_%Y%m%d_%H%M%S')
		    paste0("Visual_Lineup_Setup",datestr,".RData")
		},

		content = function(file) {
		    saved_input <- reactiveValuesToList(input)
		    saved_state <- reactiveValuesToList(state)
		    save(saved_input, saved_state, file = file)
		}
	)
}

load_shared_analysis <- function(input, output, state) {
	analysis_file <- input$uploaded_analysis
	load(analysis_file$datapath) # loads "saved_state" and "saved_input" objects
	
	state$input_overrides <- saved_state$input_overrides
	state$input_overrides$plotToggleSettings <- saved_input$plotToggleSettings

	get_column_registration_override <- function(row) {
		shortname <- row["shortname"]
		state$input_overrides[[shortname]] <- saved_input[[shortname]]
	}

	apply(saved_state$app_settings$toRegister, 1, get_column_registration_override)

	state$app_name <- saved_state$app_name
	state$app_settings <- saved_state$app_settings
	state$data_current <- TRUE
	state$data <- saved_state$data

	#modified_inputs <- overwrite_list(input, state$input_overrides)

	generate_lineup_test(saved_input, output, state)
}