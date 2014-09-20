#!/bin/bash

# Run learning-based segmentaiton experiment
echo Running segmentation. This may take a while \(no kidding\)...
java -cp forestclassifier.jar:lib/* br.edu.ufam.icomp.ammd.ImageSegmentationExperiment
echo Running overlay on output
java -cp forestclassifier.jar:lib/* br.edu.ufam.icomp.ammd.SegmentationOverlay