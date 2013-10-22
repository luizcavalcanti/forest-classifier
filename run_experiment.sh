#!/bin/bash

# prepare log files
rm -rf log/
mkdir log

# check database
java -cp lib/weka.jar weka.core.Instances forest_train.arff
java -cp lib/weka.jar weka.core.Instances forest_test.arff

# classify with Decision Tree (J48)
 # 2>&1 | tee -a example.txt
java -cp lib/weka.jar weka.classifiers.trees.J48 -t forest_train.arff -T forest_test.arff > log/decision_tree.log

# classify with kNN (IBk)
java -cp lib/weka.jar weka.classifiers.lazy.IBk -K 1 -t forest_train.arff -T forest_test.arff > log/knn_1.log
java -cp lib/weka.jar weka.classifiers.lazy.IBk -K 3 -t forest_train.arff -T forest_test.arff > log/knn_3.log

# classify with SVM
# java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -t forest_train.arff -T forest_test.arff > log/svm.log
java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -K 0 -G 0.1 -t forest_train.arff -T forest_test.arff > log/svm.log
java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -K 1 -G 0.1 -t forest_train.arff -T forest_test.arff >> log/svm.log
java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -K 2 -G 0.1 -t forest_train.arff -T forest_test.arff >> log/svm.log
java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -K 3 -G 0.1 -t forest_train.arff -T forest_test.arff >> log/svm.log