#!/bin/bash

###################################
## run one-class classifications ##
###################################
WEKA_LIBS=".:manual-classification/lib/*"
ARFF_PATH=segments.arff
RESULTS_DIR=results/ensemble/

echo "deleting previous results"
rm -rf $RESULTS_DIR 2> /dev/null
mkdir $RESULTS_DIR

echo "splitting databases by classes"
python preparation/split_database_by_class.py $ARFF_PATH ensemble

# #TODO revisar se vale a pena exportar uma analise para cada classe/base
# echo "running complete dataset analysis"
# java -cp $WEKA_LIBS weka.core.Instances "$ARFF_PATH" > $RESULTS_DIR/analysis-dataset.txt

echo "running one class training for forest"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-forest.arff -d $RESULTS_DIR/model-forest-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-forest.txt
# java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
#     -t ensemble-forest.arff -d $RESULTS_DIR/model-forest-ocsvm.model \
#     -F weka.filters.unsupervised.attribute.RemoveType \
#     -W weka.classifiers.functions.LibSVM -- -S 2\
#     > $RESULTS_DIR/result-model-forest-ocsvm.txt

echo "running one class training for water"
# java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
#     -t ensemble-water.arff -d $RESULTS_DIR/model-water-rpt.model \
#     -F weka.filters.unsupervised.attribute.RemoveType \
#     -W weka.classifiers.meta.OneClassClassifier -- \
#     -W weka.classifiers.meta.Bagging -- \
#     -W weka.classifiers.trees.REPTree -- \
#     > $RESULTS_DIR/result-model-water.txt
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-water.arff -d $RESULTS_DIR/model-water-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-water-ocsvm.txt

echo "running one class training for grass"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-grass.arff -d $RESULTS_DIR/model-grass-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -E \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-grass.txt
# java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
#     -t ensemble-grass.arff -d $RESULTS_DIR/model-grass-ocsvm.model \
#     -F weka.filters.unsupervised.attribute.RemoveType \
#     -W weka.classifiers.functions.LibSVM -- -S 2 \
#     > $RESULTS_DIR/result-model-grass-ocsvm.txt

echo "running one class training for dirty"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-dirty.arff -d $RESULTS_DIR/model-dirty-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -P 0.35 \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-dirty.txt
# java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
#     -t ensemble-dirty.arff -d $RESULTS_DIR/model-dirty-ocsvm.model \
#     -F weka.filters.unsupervised.attribute.RemoveType \
#     -W weka.classifiers.functions.LibSVM -- -S 2 \
#     > $RESULTS_DIR/result-model-dirty-ocsvm.txt

echo "classifying samples from orginal database"
# java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest.arff -l $RESULTS_DIR/model-forest-ocsvm.model -p 1 > $RESULTS_DIR/results-forest.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest.arff -l $RESULTS_DIR/model-forest-rpt.model -p 1 > $RESULTS_DIR/results-forest.txt

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water.arff -l $RESULTS_DIR/model-water-ocsvm.model -p 1 > $RESULTS_DIR/results-water.txt
# java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water.arff -l $RESULTS_DIR/model-water-rpt.model -p 1 > $RESULTS_DIR/results-water.txt

# java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass.arff -l $RESULTS_DIR/model-grass-ocsvm.model -p 1 > $RESULTS_DIR/results-grass.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass.arff -l $RESULTS_DIR/model-grass-rpt.model -p 1 > $RESULTS_DIR/results-grass.txt

# java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty.arff -l $RESULTS_DIR/model-dirty-ocsvm.model -p 1 > $RESULTS_DIR/results-dirty.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty.arff -l $RESULTS_DIR/model-dirty-rpt.model -p 1 > $RESULTS_DIR/results-dirty.txt

echo "gathering ensemble results"
python preparation/gather_ensemble_results.py $ARFF_PATH $RESULTS_DIR/voting.csv $RESULTS_DIR/results-forest.txt $RESULTS_DIR/results-water.txt $RESULTS_DIR/results-grass.txt $RESULTS_DIR/results-dirty.txt

echo "removing temporary datasets"
rm ensemble-* 2> /dev/null