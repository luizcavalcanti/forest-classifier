#!/bin/bash
# check database
java -cp lib/weka.jar weka.core.Instances forest.arff

# remove non-numeric parameters
java -cp lib/weka.jar weka.filters.unsupervised.attribute.Remove -R 1,2 -i forest.arff -o forest_train.arff

# classify with Decision Tree (J48)
java -cp lib/weka.jar weka.classifiers.trees.J48 -t forest_train.arff

# classify with kNN (IBk)
java -cp lib/weka.jar weka.classifiers.lazy.IBk -K 1 -t forest_train.arff
java -cp lib/weka.jar weka.classifiers.lazy.IBk -K 2 -t forest_train.arff

# classify with SVM
java -cp lib/weka.jar:lib/libsvm.jar weka.classifiers.functions.LibSVM -t forest_train.arff
