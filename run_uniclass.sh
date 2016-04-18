#!/bin/bash

###################################
## run one-class classifications ##
###################################
WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_ARFF_PATH=segments.arff
ARFF_PATH=segments-uniclass.arff
RESULTS_DIR=results/uniclass/
FILTERED_ARFF=filtered_$ARFF_PATH
CFS_ARFF=cfs_$ARFF_PATH

ARFF_OPTIONS="-t $FILTERED_ARFF"
ARFF_OPTIONS_CFS="-t $CFS_ARFF"

echo "deleting previous results"
rm -rf $RESULTS_DIR 2> /dev/null
mkdir $RESULTS_DIR
rm $ARFF_PATH 2> /dev/null

echo "converting muticlass dataset to uniclass"
python preparation/convert_multi_to_uniclass.py $ORIGINAL_ARFF_PATH $ARFF_PATH

echo "remove useless attribute (sample id)"
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$FILTERED_ARFF"

echo "executing attribute selection (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" -S "weka.attributeSelection.BestFirst -D 2 -N 5" -i "$FILTERED_ARFF" -o "$CFS_ARFF"

echo "running complete dataset analysis"
java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"  > $RESULTS_DIR/analysis-dataset.txt
java -cp $WEKA_LIBS weka.core.Instances "$CFS_ARFF"  > $RESULTS_DIR/analysis-dataset-cfs.txt

echo "running one class training - REPTree"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier $ARFF_OPTIONS -d $RESULTS_DIR/model-reptree.model > $RESULTS_DIR/result-reptree.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier $ARFF_OPTIONS_CFS -d $RESULTS_DIR/model-reptree-cfs.model > $RESULTS_DIR/result-reptree-cfs.txt

python preparation/convert_outlier_to_oneclass.py $FILTERED_ARFF $FILTERED_ARFF
python preparation/convert_outlier_to_oneclass.py $CFS_ARFF $CFS_ARFF

echo "running one class training - OCSVM"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier $ARFF_OPTIONS -d $RESULTS_DIR/model-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 > $RESULTS_DIR/result-ocsvm.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier $ARFF_OPTIONS_CFS -d $RESULTS_DIR/model-ocsvm-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 > $RESULTS_DIR/result-ocsvm-cfs.txt

echo "removing temporary datasets"
rm "$ARFF_PATH" 2> /dev/null
rm "$FILTERED_ARFF" 2> /dev/null
rm "$CFS_ARFF" 2> /dev/null
