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

echo "remove useless attribute (sample id)"
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ORIGINAL_ARFF_PATH" -o "$FILTERED_ARFF"

echo "executing attribute selection (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" -S "weka.attributeSelection.BestFirst -D 2 -N 5" -i "$FILTERED_ARFF" -o "$CFS_ARFF"

echo "splitting databases by classes"
python preparation/split_database_by_class.py $FILTERED_ARFF ensemble
python preparation/split_database_by_class.py $CFS_ARFF ensemble-cfs

#TODO revisar se vale a pena exportar uma analise para cada classe/base
#echo "running complete dataset analysis"
#java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"  > $RESULTS_DIR/analysis-dataset.txt
#java -cp $WEKA_LIBS weka.core.Instances "$CFS_ARFF"  > $RESULTS_DIR/analysis-dataset-cfs.txt

echo "running one class training for forest"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-forest.arff -d $RESULTS_DIR/model-forest.model > /dev/null
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-cfs-forest.arff -d $RESULTS_DIR/model-cfs-forest.model > /dev/null

echo "running one class training for water"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-water.arff -d $RESULTS_DIR/model-water.model > /dev/null
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-cfs-water.arff -d $RESULTS_DIR/model-cfs-water.model > /dev/null

echo "running one class training for grass"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-grass.arff -d $RESULTS_DIR/model-grass.model > /dev/null
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-cfs-grass.arff -d $RESULTS_DIR/model-cfs-grass.model > /dev/null

echo "running one class training for dirty"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-dirty.arff -d $RESULTS_DIR/model-dirty.model > /dev/null
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -t ensemble-cfs-dirty.arff -d $RESULTS_DIR/model-cfs-dirty.model > /dev/null

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-human-made.arff -l $RESULTS_DIR/model-forest.model -p 0 > $RESULTS_DIR/result-forest.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-human-made.arff -l $RESULTS_DIR/model-water.model -p 0 > $RESULTS_DIR/result-water.tx
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-human-made.arff -l $RESULTS_DIR/model-grass.model -p 0 > $RESULTS_DIR/result-grass.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-human-made.arff -l $RESULTS_DIR/model-dirty.model -p 0 > $RESULTS_DIR/result-dirty.txt

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-cfs-human-made.arff -l $RESULTS_DIR/model-cfs-forest.model -p 0 > $RESULTS_DIR/result-cfs-forest.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-cfs-human-made.arff -l $RESULTS_DIR/model-cfs-water.model -p 0 > $RESULTS_DIR/result-cfs-water.tx
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-cfs-human-made.arff -l $RESULTS_DIR/model-cfs-grass.model -p 0 > $RESULTS_DIR/result-cfs-grass.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-cfs-human-made.arff -l $RESULTS_DIR/model-cfs-dirty.model -p 0 > $RESULTS_DIR/result-cfs-dirty.txt

echo "removing temporary datasets"
rm "$ARFF_PATH" 2> /dev/null
rm "$FILTERED_ARFF" 2> /dev/null
rm ensemble-* 2> /dev/null
rm "$CFS_ARFF" 2> /dev/null
