ForestClassifier
================

Experiment on an image processing and machine learning solution to detect signs of human activity on aerial images of the Amazon Rain Forest.
The main goal is to test several state-of-the-art algorithms and find out the most adequate ones to the problem.
This is also my ongoing master degree work.

Image database used in this experiment is hosted <a href="https://github.com/luizcavalcanti/geoma-database">here</a>

<b>Required tools:</b>
* JDK 7+
* Apache Ant
* Weka 3.7
* Python + OpenCV 3 + scipy + scikit-image
* Matlab + Image processing toolkit + stattistics toolkit (not sure what's the minimum version)
* ImageMagick

<b>Benchmarked segmentation algorithms:</b>
* MSEG
* JSEG
* Meanshift
* SRM
* FSEG
* gPb-owt-ucm
* Manual segmentation

<b>Running segmentation benchmark</b>

    $ ./run_segmentation_benchmark.sh <MATLAB home> <image database folder>

<b>Running multiclass experiment</b>

    $ ./run_multiclass.sh

<b>Running binary classification experiment</b>

    $ ./run_biclass.sh

<b>Running one class classification experiment</b>

    $ ./run_uniclass.sh

<b>Running ensemble of one class classifiers experiment</b>

    $ ./run_ensemble.sh


<h1>THIS IS WORK IN PROGRESS</h1>
(but it works well enough so you can test it, I'll try not to break it as I go)