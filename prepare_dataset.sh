#!/bin/bash

# run build
ant build

# execute image preprocessing (segmentation and feature retrieval)
#java -cp forestclassifier.jar br.edu.ufam.icomp.ammd.ImagePreprocessor

# call GUI for dataset classification tool
java -cp forestclassifier.jar br.edu.ufam.icomp.ammd.VisualClassifier

# call for dat converter
java -cp forestclassifier.jar br.edu.ufam.icomp.ammd.ARFFGenerator forest.arff

# remove non-numeric parameters
#java -cp lib/weka.jar weka.filters.unsupervised.attribute.Remove -R 1,2 -i forest.arff -o forest_.arff
#mv forest_.arff forest.arff

# randomize order
java -cp lib/weka.jar weka.filters.unsupervised.instance.Randomize -i forest.arff -o forest_.arff
mv forest_.arff forest.arff

# once the whole dataset is classified,
# we should split it into training and test datasets
java -cp lib/weka.jar weka.filters.unsupervised.instance.RemovePercentage -P 20 -i forest.arff  -o  forest_train.arff
java -cp lib/weka.jar weka.filters.unsupervised.instance.RemovePercentage -P 20 -i forest.arff  -o  forest_test.arff -V
