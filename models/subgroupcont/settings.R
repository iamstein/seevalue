############################################################
# This is a settings file for the Continuous Response by Subgroup model.
# it contains the information necessary for lineup generation
# and plot illustration.
############################################################
app_settings = list()
app_settings$apptitle = "subgroupcont" # Title of app, to be displayed on top of analyze tab


### IMPORTS
library(nullabor)

get_subgroup_continuous_response_lineup <- function(data, input) {
	lineup(null_permute(input$Z), data)
}

show_subgroup_continuous_lineup <- function(lineup_data, input) {
	lineup_data[,input$Z] <- factor(lineup_data[,input$Z])
	ggplot(data=lineup_data, aes_string(x=input$X, y=input$Y, color=input$Z)) +
	    facet_wrap(~ .sample) +
	    geom_point() +
	    scale_fill_discrete() 
}

## COLUMN REGISTRATION
app_settings$toRegister = data.frame(	
	"longname" = c("Exposure", "Response", "Subgroup"), 
	"shortname" = c("X","Y","Z")
)


## PLOT SETTING OPTIONS
app_settings$plotOptions = list("Log X"="logx", "Log Y"="logy") # TODO 4: Enter the toggled plot settings in the form of "display_name = function_name"


## ADDITIONAL SETTTINGS
app_settings$othersettings = list( 
  # TODO 5: add any additional settings that you may need elsewhere.
)


## LINEUP AND PLOT GENERATION FUNCTIONALITY

app_settings$lineup_generation_fn = get_subgroup_continuous_response_lineup
app_settings$plot_generation_fn = show_subgroup_continuous_lineup


## Preload settings
app_settings$preload_file = list("datapath"="vignette_data/fake_continuous_subgroup_data.csv")
app_settings$toRegister$preload_columns = c("X", "Y", "Group") 
app_settings$preload_plot_settings = c()