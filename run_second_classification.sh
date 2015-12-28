#!/bin/bash

WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
ARFF_PATH=first.arff

python second-classification/separate_arff_by_class.py "$ARFF_PATH"
