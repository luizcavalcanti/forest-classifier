#!/bin/bash

# go to subproject dir
cd manual-classification

# make all stuff
ant build

# call GUI for dataset classification tool
java -cp dist/forestclassifier.jar br.edu.ufam.icomp.ammd.VisualClassifier
