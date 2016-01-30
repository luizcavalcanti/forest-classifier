#!/bin/bash

###################################
## run one-class classifications ##
###################################
WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_ARFF_PATH=segments.arff
ARFF_PATH=segments-ensemble.arff
RESULTS_DIR=results/ensemble/
FILTERED_ARFF=filtered_$ARFF_PATH
CFS_ARFF=cfs_$ARFF_PATH

ARFF_OPTIONS="-t $FILTERED_ARFF"
ARFF_OPTIONS_CFS="-t $CFS_ARFF"

echo "deleting previous results"
rm -rf $RESULTS_DIR 2> /dev/null
mkdir $RESULTS_DIR
rm $ARFF_PATH 2> /dev/null

echo "splitting databases by classes"
python preparation/split_database_by_class.py $ORIGINAL_ARFF_PATH ensemble

#TODO revisar se vale a pena exportar uma analise para cada classe/base
#echo "running complete dataset analysis"
#java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"  > $RESULTS_DIR/analysis-dataset.txt

echo "running one class training for forest"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F weka.filters.unsupervised.attribute.RemoveType -W weka.classifiers.meta.OneClassClassifier -t ensemble-forest.arff -d $RESULTS_DIR/model-forest.model > /dev/null

echo "running one class training for water"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F weka.filters.unsupervised.attribute.RemoveType -W weka.classifiers.meta.OneClassClassifier -t ensemble-water.arff -d $RESULTS_DIR/model-water.model > /dev/null

echo "running one class training for grass"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F weka.filters.unsupervised.attribute.RemoveType -W weka.classifiers.meta.OneClassClassifier -t ensemble-grass.arff -d $RESULTS_DIR/model-grass.model > /dev/null

echo "running one class training for dirty"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F weka.filters.unsupervised.attribute.RemoveType -W weka.classifiers.meta.OneClassClassifier -t ensemble-dirty.arff -d $RESULTS_DIR/model-dirty.model > /dev/null

echo "running one class training for human-made"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier -F weka.filters.unsupervised.attribute.RemoveType -W weka.classifiers.meta.OneClassClassifier -t ensemble-human-made.arff -d $RESULTS_DIR/model-human-made.model > /dev/null

echo "classifying samples from orginal database"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest.arff -l $RESULTS_DIR/model-forest.model -p 1 > $RESULTS_DIR/results-forest.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water.arff -l $RESULTS_DIR/model-water.model -p 1 > $RESULTS_DIR/results-water.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass.arff -l $RESULTS_DIR/model-grass.model -p 1 > $RESULTS_DIR/results-grass.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty.arff -l $RESULTS_DIR/model-dirty.model -p 1 > $RESULTS_DIR/results-dirty.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-human-made.arff -l $RESULTS_DIR/model-human-made.model -p 1 > $RESULTS_DIR/results-human-made.txt

echo "removing temporary datasets"
rm "$ARFF_PATH" 2> /dev/null
rm "$FILTERED_ARFF" 2> /dev/null
rm ensemble-* 2> /dev/null
rm "$CFS_ARFF" 2> /dev/null
