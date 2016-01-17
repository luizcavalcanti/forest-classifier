#!/bin/bash

WEKA_LIBS=".:manual-classification/lib/*"
SAMPLES_PATH=tmp
ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
ARFF_PATH=first.arff
SPLIT_DATASET=false

# Uncomment if need to run segmentation all over again
# ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"

# Uncomment if need to generate samples for labeling
# rm -rf "$SAMPLES_PATH"
# mkdir "$SAMPLES_PATH"
# python first-classification/generate_samples.py "$ORIGINAL_IMAGES" "$SEGMENTED_IMAGES" "$SAMPLES_PATH"

# Uncomment if need to generate initial arff file
# python first-classification/generate_arff_file.py "$SAMPLES_PATH" "$ARFF_PATH"

# Uncomment if need to label samples
# python first-classification/label_samples.py "$ORIGINAL_IMAGES" "$SAMPLES_PATH" "$ARFF_PATH"

# Uncomment if need to update arff attributes (it spares id and class only)
#python first-classification/generate_arff_attributes.py "$SAMPLES_PATH" "$ARFF_PATH"

####################################
## run classification experiments ##
####################################
FILTERED_ARFF=filtered_$ARFF_PATH
CFS_ARFF=cfs_$ARFF_PATH
TRAINING_ARFF=train_$ARFF_PATH
TESTING_ARFF=test_$ARFF_PATH
TRAINING_CFS_ARFF=train_$ARFF_PATH
TESTING_CFS_ARFF=test_$ARFF_PATH

echo "deleting previous results"
rm results/first-* 2> /dev/null

echo "remove useless attribute (sample id)"
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$FILTERED_ARFF"

echo "executing attribute selection (CFS & BestFirst)"
java -cp $WEKA_LIBS weka.filters.supervised.attribute.AttributeSelection -E "weka.attributeSelection.CfsSubsetEval -P 4 -E 4" -S "weka.attributeSelection.BestFirst -D 2 -N 5" -i "$FILTERED_ARFF" -o "$CFS_ARFF"

echo "running complete dataset analysis"
java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"  > results/first-analysis-dataset.txt
java -cp $WEKA_LIBS weka.core.Instances "$CFS_ARFF"  > results/first-analysis-dataset-cfs.txt

# enabled training/test dataset split?
if $SPLIT_DATASET; then
    echo "splitling dataset into training and test datasets (66-33 split)"
    java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TRAINING_ARFF"
    java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TESTING_ARFF" -V

    java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$CFS_ARFF"  -o "$TRAINING_CFS_ARFF"
    java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$CFS_ARFF"  -o "$TESTING_CFS_ARFF" -V

    echo "running training dataset analysis"
    java -cp $WEKA_LIBS weka.core.Instances "$TRAINING_ARFF" > results/first-analysis-training.txt
    java -cp $WEKA_LIBS weka.core.Instances "$TRAINING_CFS_ARFF" > results/first-analysis-training-cfs.txt

    echo "running testing dataset analysis"
    java -cp $WEKA_LIBS weka.core.Instances "$TESTING_ARFF" > results/first-analysis-testing.txt
    java -cp $WEKA_LIBS weka.core.Instances "$TESTING_CFS_ARFF" > results/first-analysis-testing-cfs.txt

    ARFF_OPTIONS="-t $TRAINING_ARFF -T $TESTING_ARFF"
    ARFF_OPTIONS_CFS="-t $TRAINING_CFS_ARFF -T $TESTING_CFS_ARFF"
else
    ARFF_OPTIONS="-t $FILTERED_ARFF"
    ARFF_OPTIONS_CFS="-t $CFS_ARFF"
fi

echo "running decision tree (J48)"
java -cp $WEKA_LIBS weka.classifiers.trees.J48 $ARFF_OPTIONS -C 0.3 -i -d results/first-model-j48.model > results/first-result-j48.txt
java -cp $WEKA_LIBS weka.classifiers.trees.J48 $ARFF_OPTIONS_CFS -C 0.3 -i -d results/first-model-j48-cfs.model > results/first-result-j48-cfs.txt

echo "running random forest"
java -cp $WEKA_LIBS weka.classifiers.trees.RandomForest $ARFF_OPTIONS -K 10 -I 200 -i -d results/first-model-randomforest.model > results/first-result-randomforest.txt
java -cp $WEKA_LIBS weka.classifiers.trees.RandomForest $ARFF_OPTIONS_CFS -K 10 -I 200 -i -d results/first-model-randomforest-cfs.model > results/first-result-randomforest-cfs.txt

echo "running kNN (IBk)"
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 1 -i -d results/first-model-knn1.model > results/first-result-knn1.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 2 -i -d results/first-model-knn2.model > results/first-result-knn2.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS -K 3 -i -d results/first-model-knn3.model > results/first-result-knn3.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 1 -i -d results/first-model-knn1-cfs.model > results/first-result-knn1-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 2 -i -d results/first-model-knn2-cfs.model > results/first-result-knn2-cfs.txt
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk $ARFF_OPTIONS_CFS -K 3 -i -d results/first-model-knn3-cfs.model > results/first-result-knn3-cfs.txt

echo "running SVM"
java -cp $WEKA_LIBS weka.classifiers.functions.LibSVM $ARFF_OPTIONS -i -d results/first-model-svm.model > results/first-result-svm.txt
java -cp $WEKA_LIBS weka.classifiers.functions.LibSVM $ARFF_OPTIONS -i -d results/first-model-svm-cfs.model > results/first-result-svm-cfs.txt

echo "running naive bayes"
java -cp $WEKA_LIBS weka.classifiers.bayes.NaiveBayes $ARFF_OPTIONS -i -d results/first-model-naive.model > results/first-result-naive.txt
java -cp $WEKA_LIBS weka.classifiers.bayes.NaiveBayes $ARFF_OPTIONS -i -d results/first-model-naive-cfs.model > results/first-result-naive-cfs.txt

echo "removing temporary datasets"
rm "$FILTERED_ARFF" 2> /dev/null
rm "$CFS_ARFF" 2> /dev/null
rm "$TRAINING_ARFF" 2> /dev/null
rm "$TESTING_ARFF" 2> /dev/null
rm "$TRAINING_CFS_ARFF" 2> /dev/null
rm "$TESTING_CFS_ARFF" 2> /dev/null