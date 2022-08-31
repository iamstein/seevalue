# Create a list that combines lists 'original' and 'overwriting'.
# Resulting list has all named elements found in either list.
# In cases where original and overwriting share a named element, 
# the value from 'overwriting' appears in the result.
overwrite_list <- function(original, overwriting) {
	combined <- append(overwriting, original) # combine lists
	combined[!duplicated(names(combined))] # remove duplicate keys
}

# Populate right panel with lineup test and vote UI based on the state and input.
# Uses the lineup generation and plot generation functions from the settings file
# for the model.
generate_lineup_test <- function(input, output, state) {
	data <- state$data
	app_settings <- state$app_settings
	lineup_data <- app_settings$lineup_generation_fn(data, input)
	#print("Finished drawing null datasets!")
	
	state$true_index <- attr(lineup_data, "pos")
	if(app_settings$apptitle == "Binary response vs binary exposure"){
	  #print("Hooray got the app title right!")
	  # eventually find the duplicates and create a state$true_duplicate
	  n_plots <- input$n_plots
	  
	  tmp_data <- lineup_data[lineup_data[,".sample"] == state$true_index,]
	  true_summary <- c(sum(tmp_data[tmp_data[,"X"] == 0, "Y"]),
	                    sum(tmp_data[tmp_data[,"X"] == 1, "Y"]))
	  true_duplicate <- c()
	  for(s in 1:n_plots){
	    tmp_data <- lineup_data[lineup_data[,".sample"] == s,]
	    tmp_summary <- c(sum(tmp_data[tmp_data[,"X"] == 0, "Y"]),
	                     sum(tmp_data[tmp_data[,"X"] == 1, "Y"]))
	    if(identical(tmp_summary, true_summary)){
	      true_duplicate <- c(true_duplicate, s)
	    }
	  }
	  state$true_duplicate <- true_duplicate
	}
	# this assumes that lineup_data was returned by nullabor::lineup
	# any subsequent post-processing should be done in the plot_generation function 
	
	output$instructionBar <- renderUI(get_instruction_bar(state))
	
	if(app_settings$apptitle %in% c("exposuresurvival", "subgroupsurvival", "subgroupreg")){
	 
	  output$outputPane <- renderPlot({
	    tmp_plot_list <- app_settings$plot_generation_fn(lineup_data, input)
	    plot_list <- list()
	    n_plots <- length(tmp_plot_list)
	    
	    for(i in 1:n_plots){
	     plot <- tmp_plot_list[[i]]
	     for(setting in input$plotToggleSettings){
	       plot <- do.call(setting, list(plot))
	     }
	     plot_list[[i]] <- plot
	    }
	    
	    gridExtra::grid.arrange(grobs = plot_list,
	                            ncol = ceiling(sqrt(input$n_plots)),
	                            nrow = floor(sqrt(input$n_plots)))
	  })
	} else{
	  plot <- app_settings$plot_generation_fn(lineup_data, input)
	  for (setting in input$plotToggleSettings) {
	    plot <- do.call(setting, list(plot))
	  }
	  output$outputPane <- renderPlot({plot})
	}
	output$enterVote <- renderUI({get_vote_input()})
	output$submitVote <- renderUI(actionButton("submitVote", "Submit Vote"))
}

## Load data from datafile object returned by input object, and update state accordingly.
load_data <- function(datafile, state) {
	req(datafile)
	tryCatch(
    {
    	data <- read.csv(datafile$datapath)
    	state$data_current <- TRUE
    	state$data <- data
    },
      error = function(e) {
      	state$data_current <- FALSE
      	state$data <- NULL
      	state$error <- TRUE
      }
    )
}
