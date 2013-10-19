#!/bin/bash

# run build
ant build

# execute image preprocessing (segmentation and feature retrieval)
java -cp forestclassifier.jar br.edu.ufam.icomp.ammd.ImagePreprocessor

# call GUI for dataset classification tool
java -cp forestclassifier.jar br.edu.ufam.icomp.ammd.VisualClassifier
