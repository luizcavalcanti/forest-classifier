#!/bin/bash

WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/

# first classifier config
FIRST_ARFF=first.arff
FIRST_FILTERS="weka.filters.unsupervised.attribute.RemoveType"
FIRST_CLASSIFIER="weka.classifiers.trees.RandomForest -- -K 10 -I 200"
FIRST_OUTPUT=results/second-initial.txt

# run first classifier on the whole dataset
#java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F $FIRST_FILTERS -t $FIRST_ARFF -T $FIRST_ARFF -p 1 -W $FIRST_CLASSIFIER > $FIRST_OUTPUT

# create an ARFF file for each class
python second-classification/separate_arff_by_class.py "$FIRST_OUTPUT"
