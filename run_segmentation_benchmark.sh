#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Not enough arguments. Please provide path to MATLAB home directory and images directory, in that order"
    exit 1
fi

RUN_MSEG=true
RUN_JSEG=true
RUN_MEANSHIFT=true
RUN_SRM=true
RUN_FSEG=true
RUN_GPB=true
RUN_LEARNING=false

MATLAB_HOME=$1
IMAGES_DIR=$2
LOG_DIR=logs
RESULTS_DIR=results

rm -rf $LOG_DIR
mkdir $LOG_DIR
rm -rf $RESULTS_DIR
mkdir $RESULTS_DIR

if [ "$RUN_MSEG" = true ] ; then
    # Run MSEG
    echo "Running MSEG experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/mseg
    ./mseg.sh "../../$IMAGES_DIR" > "../../$LOG_DIR"/mseg.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_JSEG" = true ] ; then
    # Run JSEG
    echo "Running JSEG experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/jseg
    ./jseg.sh "../../$IMAGES_DIR" > "../../$LOG_DIR"/jseg.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_MEANSHIFT" = true ] ; then
    # Run meanshift
    echo "Running meanshift experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/meanshift
    ./meanshift.sh "../../$IMAGES_DIR" > "../../$LOG_DIR"/meanshift.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_SRM" = true ] ; then
    # Run SRM
    echo "Running SRM experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/srm
    ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR" > "../../$LOG_DIR"/srm.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_FSEG" = true ] ; then
    # Run SRM
    echo "Running FSEG experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/fseg
    ./fseg.sh "$MATLAB_HOME" "../../$IMAGES_DIR" > "../../$LOG_DIR"/fseg.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_GPB" = true ] ; then
    # Run SRM
    echo "Running gPb experiment..."
    STARTTIME=$(date +%s)
    cd segmentation/gpb
    ./gpb.sh "$MATLAB_HOME" "../../$IMAGES_DIR" > "../../$LOG_DIR"/gpb.log
    cd ../..
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

if [ "$RUN_LEARNING" = true ] ; then
    # Run learning-based segmentation experiment
    echo Running learning-based experiment. This may take a while \(no kidding\)...
    STARTTIME=$(date +%s)
    cd segmentation/learning
    ant
    java -cp ".:learning-segmentation.jar:../../lib/*" br.edu.ufam.icomp.ammd.ImageSegmentationExperiment
    echo Running overlay on output
    java -cp ".:learning-segmentation.jar:../../lib/*" br.edu.ufam.icomp.ammd.SegmentationOverlay
    ENDTIME=$(date +%s)
    echo "done"
    echo "took $(($ENDTIME - $STARTTIME)) seconds"
    echo
fi

echo "Running benchmark"
STARTTIME=$(date +%s)
python segmentation/benchmark/benchmark.py "$IMAGES_DIR"
ENDTIME=$(date +%s)
echo "done"
echo "took $(($ENDTIME - $STARTTIME)) seconds"
echo ""