#!/bin/bash

if [ $# -eq 0 ]; then
    echo "No arguments. Please provide the weka installation directory"
    exit 1
fi

WEKA_DIR=$1
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
java -cp ".:$WEKA_DIR/weka.jar" weka.filters.unsupervised.attribute.Remove -R 1 -i "$ARFF_PATH" -o "$FILTERED_ARFF"

# split dataset into training and test datasets (66-33 split)
java -cp ".:$WEKA_DIR/weka.jar" weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TRAINING_ARFF"
java -cp ".:$WEKA_DIR/weka.jar" weka.filters.unsupervised.instance.RemovePercentage -P 34 -i "$FILTERED_ARFF"  -o "$TESTING_ARFF" -V

# print complete dataset stats
# java -cp ".:$WEKA_DIR/weka.jar" weka.core.Instances "$FILTERED_ARFF"

# print training dataset stats
# java -cp ".:$WEKA_DIR/weka.jar" weka.core.Instances "$TRAINING_ARFF"

# print testing dataset stats
# java -cp ".:$WEKA_DIR/weka.jar" weka.core.Instances "$TESTING_ARFF"

# run decision tree (J48)
java -cp ".:$WEKA_DIR/weka.jar" weka.classifiers.trees.J48 -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -d results/first-j48.model -C 0.3
# run kNN (IBk)
java -cp ".:$WEKA_DIR/weka.jar" weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -d results/first-knn-1.model -K 1
java -cp ".:$WEKA_DIR/weka.jar" weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -d results/first-knn-2.model -K 2
java -cp ".:$WEKA_DIR/weka.jar" weka.classifiers.lazy.IBk -t "$TRAINING_ARFF" -T "$TESTING_ARFF" -d results/first-knn-3.model -K 3

# remove temporary datasets
rm "$FILTERED_ARFF"
rm "$TRAINING_ARFF"
rm "$TESTING_ARFF"