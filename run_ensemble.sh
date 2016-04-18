#!/bin/bash

###################################
## run one-class classifications ##
###################################
WEKA_LIBS=".:manual-classification/lib/*"
ARFF_PATH=segments.arff
TMP_ARFF=ensemble-temp.arff
FILTERED_ARFF=ensemble-all.arff
RESULTS_DIR=results/ensemble/

echo "deleting previous results"
rm -rf $RESULTS_DIR 2> /dev/null
mkdir $RESULTS_DIR

java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$TMP_ARFF"
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.AddID -i "$TMP_ARFF" -o "$FILTERED_ARFF"

echo "splitting databases by classes"
python preparation/split_database_by_class.py "$FILTERED_ARFF" ensemble

##################
##### FOREST #####
##################

echo "executing attribute selection for forest dataset (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection \
    -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" \
    -S "weka.attributeSelection.BestFirst -D 2 -N 5" \
    -i ensemble-forest.arff \
    -o ensemble-forest-cfs.arff

java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.AddID -i ensemble-forest-cfs.arff -o ensemble-forest-temp.arff
mv ensemble-forest-temp.arff ensemble-forest-cfs.arff

java -cp $WEKA_LIBS weka.core.Instances ensemble-forest.arff > $RESULTS_DIR/analysis-forest.txt
java -cp $WEKA_LIBS weka.core.Instances ensemble-forest-cfs.arff > $RESULTS_DIR/analysis-forest-cfs.txt

python preparation/convert_outlier_to_oneclass.py ensemble-forest.arff ensemble-forest2.arff
python preparation/convert_outlier_to_oneclass.py ensemble-forest-cfs.arff ensemble-forest-cfs2.arff

echo "running one-class training for forest"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-forest.arff -d $RESULTS_DIR/model-forest-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-forest.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-forest2.arff -d $RESULTS_DIR/model-forest-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2\
    > $RESULTS_DIR/result-model-forest-ocsvm.txt

echo "running one-class training for forest (CFS)"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-forest-cfs.arff -d $RESULTS_DIR/model-forest-rpt-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-forest-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-forest-cfs2.arff -d $RESULTS_DIR/model-forest-ocsvm-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2\
    > $RESULTS_DIR/result-model-forest-ocsvm-cfs.txt

#################
##### WATER #####
#################

echo "executing attribute selection for water dataset (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection \
    -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" \
    -S "weka.attributeSelection.BestFirst -D 2 -N 5" \
    -i ensemble-water.arff \
    -o ensemble-water-cfs.arff

java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.AddID -i ensemble-water-cfs.arff -o ensemble-water-temp.arff
mv ensemble-water-temp.arff ensemble-water-cfs.arff

java -cp $WEKA_LIBS weka.core.Instances ensemble-water.arff > $RESULTS_DIR/analysis-water.txt
java -cp $WEKA_LIBS weka.core.Instances ensemble-water-cfs.arff > $RESULTS_DIR/analysis-water-cfs.txt

python preparation/convert_outlier_to_oneclass.py ensemble-water.arff ensemble-water2.arff
python preparation/convert_outlier_to_oneclass.py ensemble-water-cfs.arff ensemble-water-cfs2.arff

echo "running one-class training for water"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-water.arff -d $RESULTS_DIR/model-water-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-water.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-water2.arff -d $RESULTS_DIR/model-water-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-water-ocsvm.txt

echo "running one-class training for water (CFS)"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-water-cfs.arff -d $RESULTS_DIR/model-water-rpt-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-water-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-water-cfs2.arff -d $RESULTS_DIR/model-water-ocsvm-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-water-ocsvm-cfs.txt


#################
##### GRASS #####
#################

echo "executing attribute selection for grass dataset (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection \
    -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" \
    -S "weka.attributeSelection.BestFirst -D 2 -N 5" \
    -i ensemble-grass.arff \
    -o ensemble-grass-cfs.arff

java -cp $WEKA_LIBS weka.core.Instances ensemble-grass.arff > $RESULTS_DIR/analysis-grass.txt
java -cp $WEKA_LIBS weka.core.Instances ensemble-grass-cfs.arff > $RESULTS_DIR/analysis-grass-cfs.txt

python preparation/convert_outlier_to_oneclass.py ensemble-grass.arff ensemble-grass2.arff
python preparation/convert_outlier_to_oneclass.py ensemble-grass-cfs.arff ensemble-grass-cfs2.arff

echo "running one class training for grass"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-grass.arff -d $RESULTS_DIR/model-grass-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -E \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-grass.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-grass2.arff -d $RESULTS_DIR/model-grass-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-grass-ocsvm.txt

echo "running one class training for grass (CFS)"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-grass-cfs.arff -d $RESULTS_DIR/model-grass-rpt-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -E \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-grass-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-grass-cfs2.arff -d $RESULTS_DIR/model-grass-ocsvm-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-grass-ocsvm-cfs.txt

################
##### DIRT #####
################

echo "executing attribute selection for dirt dataset (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection \
    -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" \
    -S "weka.attributeSelection.BestFirst -D 2 -N 5" \
    -i ensemble-dirty.arff \
    -o ensemble-dirty-cfs.arff

java -cp $WEKA_LIBS weka.core.Instances ensemble-dirty.arff > $RESULTS_DIR/analysis-dirty.txt
java -cp $WEKA_LIBS weka.core.Instances ensemble-dirty-cfs.arff > $RESULTS_DIR/analysis-dirty-cfs.txt

python preparation/convert_outlier_to_oneclass.py ensemble-dirty.arff ensemble-dirty2.arff
python preparation/convert_outlier_to_oneclass.py ensemble-dirty-cfs.arff ensemble-dirty-cfs2.arff

echo "running one class training for dirt"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-dirty.arff -d $RESULTS_DIR/model-dirty-rpt.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -P 0.35 \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-dirty.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-dirty2.arff -d $RESULTS_DIR/model-dirty-ocsvm.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-dirty-ocsvm.txt

echo "running one class training for dirt (CFS)"
java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-dirty-cfs.arff -d $RESULTS_DIR/model-dirty-rpt-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.meta.OneClassClassifier -- -P 0.35 \
    -W weka.classifiers.meta.Bagging -- \
    -W weka.classifiers.trees.REPTree -- \
    > $RESULTS_DIR/result-model-dirty-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.FilteredClassifier \
    -t ensemble-dirty-cfs2.arff -d $RESULTS_DIR/model-dirty-ocsvm-cfs.model \
    -F weka.filters.unsupervised.attribute.RemoveType \
    -W weka.classifiers.functions.LibSVM -- -S 2 \
    > $RESULTS_DIR/result-model-dirty-ocsvm-cfs.txt


echo "classifying samples from orginal database"
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest2.arff -l $RESULTS_DIR/model-forest-ocsvm.model -p 1 > $RESULTS_DIR/results-forest-ocsvm.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest.arff -l $RESULTS_DIR/model-forest-rpt.model -p 1 > $RESULTS_DIR/results-forest-rpt.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest-cfs2.arff -l $RESULTS_DIR/model-forest-ocsvm-cfs.model -p 1 > $RESULTS_DIR/results-forest-ocsvm-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-forest-cfs.arff -l $RESULTS_DIR/model-forest-rpt-cfs.model -p 1 > $RESULTS_DIR/results-forest-rpt-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water2.arff -l $RESULTS_DIR/model-water-ocsvm.model -p 1 > $RESULTS_DIR/results-water-ocsvm.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water.arff -l $RESULTS_DIR/model-water-rpt.model -p 1 > $RESULTS_DIR/results-water-rpt.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water-cfs2.arff -l $RESULTS_DIR/model-water-ocsvm-cfs.model -p 1 > $RESULTS_DIR/results-water-ocsvm-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-water-cfs.arff -l $RESULTS_DIR/model-water-rpt-cfs.model -p 1 > $RESULTS_DIR/results-water-rpt-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass2.arff -l $RESULTS_DIR/model-grass-ocsvm.model -p 1 > $RESULTS_DIR/results-grass-ocsvm.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass.arff -l $RESULTS_DIR/model-grass-rpt.model -p 1 > $RESULTS_DIR/results-grass-rpt.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass-cfs2.arff -l $RESULTS_DIR/model-grass-ocsvm-cfs.model -p 1 > $RESULTS_DIR/results-grass-ocsvm-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-grass-cfs.arff -l $RESULTS_DIR/model-grass-rpt-cfs.model -p 1 > $RESULTS_DIR/results-grass-rpt-cfs.txt

java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty2.arff -l $RESULTS_DIR/model-dirty-ocsvm.model -p 1 > $RESULTS_DIR/results-dirty-ocsvm.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty.arff -l $RESULTS_DIR/model-dirty-rpt.model -p 1 > $RESULTS_DIR/results-dirty-rpt.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty-cfs2.arff -l $RESULTS_DIR/model-dirty-ocsvm-cfs.model -p 1 > $RESULTS_DIR/results-dirty-ocsvm-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.meta.OneClassClassifier -T ensemble-dirty-cfs.arff -l $RESULTS_DIR/model-dirty-rpt-cfs.model -p 1 > $RESULTS_DIR/results-dirty-rpt-cfs.txt

echo "gathering ensemble results"
python preparation/gather_ensemble_bruteforce.py $FILTERED_ARFF $RESULTS_DIR/voting.csv \
    $RESULTS_DIR/results-forest-ocsvm.txt \
    $RESULTS_DIR/results-forest-rpt.txt \
    $RESULTS_DIR/results-forest-ocsvm-cfs.txt \
    $RESULTS_DIR/results-forest-rpt-cfs.txt \
    $RESULTS_DIR/results-water-ocsvm.txt \
    $RESULTS_DIR/results-water-rpt.txt \
    $RESULTS_DIR/results-water-ocsvm-cfs.txt \
    $RESULTS_DIR/results-water-rpt-cfs.txt \
    $RESULTS_DIR/results-grass-ocsvm.txt \
    $RESULTS_DIR/results-grass-rpt.txt \
    $RESULTS_DIR/results-grass-ocsvm-cfs.txt \
    $RESULTS_DIR/results-grass-rpt-cfs.txt \
    $RESULTS_DIR/results-dirty-ocsvm.txt \
    $RESULTS_DIR/results-dirty-rpt.txt \
    $RESULTS_DIR/results-dirty-ocsvm-cfs.txt \
    $RESULTS_DIR/results-dirty-rpt-cfs.txt

echo "removing temporary datasets"
rm ensemble-* 2> /dev/null