#!/bin/bash
# A script to initialize the directory for a new model for the visual inference RShiny app.

echo -e "Enter the 'human-readable' name of the new model:"
read longname

echo -e "Enter a short name for the new model (no spaces or special characters):"
read shortname

MODEL_DIR=../models/$shortname

if [[ -d "$MODEL_DIR" ]]
then
    echo "$MODEL_DIR exists, pick another shortname."
else
	mkdir $MODEL_DIR
	cp documentation.html $MODEL_DIR
	cp documentation.Rmd $MODEL_DIR
	cp settings.R $MODEL_DIR

	settings_file=$MODEL_DIR/settings.R
	sed -i "s/LONGTITLE/$longname/g" $settings_file
	sed -i "s/SHORTTITLE/$shortname/g" $settings_file

	echo "Directory $MODEL_DIR created and initialized with starter code."
fi