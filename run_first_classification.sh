#!/bin/bash

WEKA_LIBS=".:manual-classification/lib/*"
SAMPLES_PATH=tmp
ORIGINAL_IMAGES=database/ptv-mao
SEGMENTED_IMAGES=segmentation/srm/out/
ARFF_PATH=first.arff

# Uncomment if need to run segmentation all over again
# ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"

# Uncomment if need to generate samples for labeling
# rm -rf "$SAMPLES_PATH"
# mkdir "$SAMPLES_PATH"
# python first-classification/generate_samples.py "$ORIGINAL_IMAGES" "$SEGMENTED_IMAGES" "$SAMPLES_PATH"

# Uncomment if need to generate initial arff file
# python first-classification/generate_arff_database.py "$SAMPLES_PATH" "$ARFF_PATH"

# Uncomment if need to label samples
# python first-classification/label_samples.py "$ORIGINAL_IMAGES" "$SAMPLES_PATH" "$ARFF_PATH"

####################################
## run classification experiments ##
####################################
FILTERED_ARFF=filtered_$ARFF_PATH
TRAINING_ARFF=train_$ARFF_PATH
TESTING_ARFF=test_$ARFF_PATH

# remove useless attribute (sample id)
java -cp $WEKA_LIBS weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$FILTERED_ARFF"

# split dataset into training and test datasets (66-33 split)
java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TRAINING_ARFF"
java -cp $WEKA_LIBS weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TESTING_ARFF" -V

# print complete dataset stats
# java -cp $WEKA_LIBS weka.core.Instances "$FILTERED_ARFF"

# print training dataset stats
# java -cp $WEKA_LIBS weka.core.Instances "$TRAINING_ARFF"

# print testing dataset stats
# java -cp $WEKA_LIBS weka.core.Instances "$TESTING_ARFF"

# run decision tree (J48)
java -cp $WEKA_LIBS weka.classifiers.trees.J48 -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -C 0.3 -i #-d results/first-j48.model

# run random forest
java -cp $WEKA_LIBS weka.classifiers.trees.RandomForest -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -K 10 -I 200 -i #-d results/first-randomforest.model

# run kNN (IBk)
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -K 1 -i #-d results/first-knn-1.model
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -K 2 -i #-d results/first-knn-2.model
java -cp $WEKA_LIBS weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -K 3 -i #-d results/first-knn-3.model

# run SVM
java -cp $WEKA_LIBS weka.classifiers.functions.LibSVM -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -i #-d results/first-svm.model

# remove temporary datasets
# rm "$FILTERED_ARFF"
# rm "$TRAINING_ARFF"
# rm "$TESTING_ARFF"