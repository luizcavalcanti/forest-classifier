#!/bin/bash

# prepare log files
rm -rf log/
mkdir log

# check database
java -cp ".;lib/weka.jar" weka.core.Instances forest_train.arff
java -cp ".;lib/weka.jar" weka.core.Instances forest_test.arff

# classify with Decision Tree (J48)
java -cp ".;lib/weka.jar" weka.classifiers.trees.J48 -C 0.5  -t forest_train.arff -d j48.model > log/decision_tree_train.log
java -cp ".;lib/weka.jar" weka.classifiers.trees.J48 -T forest_test.arff -l j48.model > log/decision_tree_test.log

# classify with kNN (IBk)
java -cp ".;lib/weka.jar" weka.classifiers.lazy.IBk -K 5 -t forest_train.arff -d knn.model > log/knn_train.log
java -cp ".;lib/weka.jar" weka.classifiers.lazy.IBk -T forest_test.arff -l knn.model > log/knn_test.log

# classify with SVM
java -cp ".;lib/weka.jar;lib/libsvm.jar" weka.classifiers.functions.LibSVM -T forest_test.arff -l svm.model > log/svm_test.log