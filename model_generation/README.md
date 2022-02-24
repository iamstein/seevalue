## Running the generation script
It might be necessary to do "chmod u+x generate_model.sh" to give yourself run permissions for the model generator.

Run ./generate_model.sh

It will prompt you first for a human readable name for the model, then for a short name for the model that has no special characters. This shortname is used for naming the code directory.

The tool will create a model directory for this model and initialize the documentation and settings files with some boilerplate.

## Further Steps
0. Run the model creation script. This will create a new directory containing the model's resources.
1. Write lineup generation and plot generation functions. This can be done in settings.R or in a separate file that is imported into settings.R, depending on the complexity of the function.
2. Fill in the to-dos in settings.R according to the instructions (7 total)
3. Fill in the user documentation in documentation.Rmd
4. Knit the .Rmd into .html
5. Add any new plot settings to R/settings_handler.R
6. Add the button to the main tab UI in ui.R