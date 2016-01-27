#!/bin/bash

####################################
## run multiclass classifications ##
####################################
WEKA_LIBS=".:manual-classification/lib/*"
ORIGINAL_ARFF_PATH=segments.arff
ARFF_PATH=segments-biclass.arff
RESULTS_DIR=results/biclass/
FILTERED_ARFF=filtered_$ARFF_PATH
CFS_ARFF=cfs_$ARFF_PATH

ARFF_OPTIONS="-t $FILTERED_ARFF"
ARFF_OPTIONS_CFS="-t $CFS_ARFF"

echo "deleting previous results"
rm -rf $RESULTS_DIR
mkdir $RESULTS_DIR

rm $ARFF_PATH
python biclass/convert_multi_to_biclass.py $ORIGINAL_ARFF_PATH $ARFF_PATH

echo "remove useless attribute (sample id)"
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$FILTERED_ARFF"

echo "executing attribute selection (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" -S "weka.attributeSelection.BestFirst -D 2 -N 5" -i "$FILTERED_ARFF" -o "$CFS_ARFF"

echo "running complete dataset analysis"
java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"  > $RESULTS_DIR/analysis-dataset.txt
java -cp $WEKA_LIBS weka.core.Instances "$CFS_ARFF"  > $RESULTS_DIR/analysis-dataset-cfs.txt

echo "running decision tree (J48)"
java -cp $WEKA_LIBS weka.classifiers.trees.J48 $ARFF_OPTIONS -C 0.3 -i -d $RESULTS_DIR/model-j48.model > $RESULTS_DIR/result-j48.txt
java -cp $WEKA_LIBS weka.classifiers.trees.J48 $ARFF_OPTIONS_CFS -C 0.3 -i -d $RESULTS_DIR/model-j48-cfs.model > $RESULTS_DIR/result-j48-cfs.txt

echo "running random forest"
java -cp $WEKA_LIBS weka.classifiers.trees.RandomForest $ARFF_OPTIONS -K 10 -I 200 -i -d $RESULTS_DIR/model-randomforest.model > $RESULTS_DIR/result-randomforest.txt
java -cp $WEKA_LIBS weka.classifiers.trees.RandomForest $ARFF_OPTIONS_CFS -K 10 -I 200 -i -d $RESULTS_DIR/model-randomforest-cfs.model > $RESULTS_DIR/result-randomforest-cfs.txt

echo "running kNN (IBk)"
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 1 -i -d $RESULTS_DIR/model-knn1.model > $RESULTS_DIR/result-knn1.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 2 -i -d $RESULTS_DIR/model-knn2.model > $RESULTS_DIR/result-knn2.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 3 -i -d $RESULTS_DIR/model-knn3.model > $RESULTS_DIR/result-knn3.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 1 -i -d $RESULTS_DIR/model-knn1-cfs.model > $RESULTS_DIR/result-knn1-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 2 -i -d $RESULTS_DIR/model-knn2-cfs.model > $RESULTS_DIR/result-knn2-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 3 -i -d $RESULTS_DIR/model-knn3-cfs.model > $RESULTS_DIR/result-knn3-cfs.txt

echo "running SVM"
java -cp $WEKA_LIBS weka.classifiers.functions.LibSVM $ARFF_OPTIONS -i -d $RESULTS_DIR/model-svm.model > $RESULTS_DIR/result-svm.txt
java -cp $WEKA_LIBS weka.classifiers.functions.LibSVM $ARFF_OPTIONS_CFS -i -d $RESULTS_DIR/model-svm-cfs.model > $RESULTS_DIR/result-svm-cfs.txt

echo "running naive bayes"
java -cp $WEKA_LIBS weka.classifiers.bayes.NaiveBayes $ARFF_OPTIONS -i -d $RESULTS_DIR/model-naive.model > $RESULTS_DIR/result-naive.txt
java -cp $WEKA_LIBS weka.classifiers.bayes.NaiveBayes $ARFF_OPTIONS_CFS -i -d $RESULTS_DIR/model-naive-cfs.model > $RESULTS_DIR/result-naive-cfs.txt

echo "removing temporary datasets"
rm "$ARFF_PATH" 2> /dev/null
rm "$FILTERED_ARFF" 2> /dev/null
rm "$CFS_ARFF" 2> /dev/null
