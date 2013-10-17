#!/bin/bash
ant
cp dist/preprocessor.jar .
chmod +x preprocessor.jar
java -cp preprocessor.jar br.edu.ufam.icomp.ammd.ImagePreprocessor
java -cp preprocessor.jar br.edu.ufam.icomp.ammd.VisualClassifier
