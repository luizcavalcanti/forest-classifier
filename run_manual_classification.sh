#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments. Please provide the image database location as argument"
    exit 1
fi

IMAGES_DIR=$1

# go to subproject dir
cd manual-classification

# make all stuff
ant build

# call GUI for dataset classification tool
java -cp dist/forestclassifier.jar br.edu.ufam.icomp.ammd.VisualClassifier "../$IMAGES_DIR"