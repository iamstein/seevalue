############################################################
#This is a file for the Exposure-Binary Response setup.
#it contains additional information that helps properly process it
############################################################
library(nullabor)

get_exposure_binary_response_lineup <- function(data, input) {
  
  return(nullabor::lineup(method = nullabor::null_permute(input$Y),
                          true = data,
                          n = input$n_plots))
  
	#lineup(null_permute(input$Y), data)
}

show_exposure_binary_lineup <- function(lineup_data, input) {
  ggplot(data=lineup_data, aes_string(x=input$X, y=input$Y)) +
    facet_wrap(~ .sample) +
    geom_point()
}

app_settings = list()

#Title of app, to be displayed on top of analyze tab
app_settings$apptitle = "Exposure-Binary"

#Name of columns to register
app_settings$toRegister = data.frame(	
	"longname" =c("Exposure", "Outcome"),
	"shortname" = c("X", "Y")
)

# Plot settings options: maps setting name to function in settings_handler
app_settings$plotOptions = list("Log X"="logx", "Log Y"="logy", "Logistic Overlay"="overlay_logistic_binary")

#additional input elements for app that are shown on UI
app_settings$othersettings = list(
  #shiny::selectInput("modeltype", "Models to run ",c("ODE" = '_ode_', 'discrete' = '_discrete_', 'both' = '_ode_and_discrete_'), selected = '_ode_'),
  #shiny::selectInput("plotscale", "log-scale for plot ",c("none" = "none", 'x-axis' = "x", 'y-axis' = "y", 'both axes' = "both")),
  #shiny::selectInput("plotengine", "plot engine",c("ggplot" = "ggplot", "plotly" = "plotly"))
) #end list

app_settings$lineup_generation_fn = get_exposure_binary_response_lineup
app_settings$plot_generation_fn = show_exposure_binary_lineup

## Preload
app_settings$preload_file = list("datapath"="vignette_data/fake_continuous_exposure_binary_response.csv")
app_settings$toRegister$preload_columns = c("measured_plasma_conc", "outcome") 
app_settings$preload_plot_settings = c("logx", "overlay_logistic_binary")