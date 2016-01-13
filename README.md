ForestClassifier
================

Experiment on a multi-level machine learning solution to detect signs of environmental crime on aerial images of the Amazon rain forest.

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

<b>Running first classification experiment</b>

    $ ./run_first_segmentation