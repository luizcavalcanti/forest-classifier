#!/bin/bash

if [ $# -lt 2 ]; then
    echo "Not enough arguments. Please provide path to MATLAB home directory and images directory, in that order"
    exit 1
fi

RUN_MSEG=true
RUN_JSEG=true
RUN_MEANSHIFT=true
RUN_SRM=true
RUN_LEARNING=false

MATLAB_HOME=$1
IMAGES_DIR=$2

if [ "$RUN_MSEG" = true ] ; then
    # Run MSEG
    echo Running MSEG experiment...
    STARTTIME=$(date +%s)
    cd segmentation/mseg
    ./mseg.sh "../../$IMAGES_DIR"
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo
    echo =============================================
    echo "Running benchmark..."
    python segmentation/benchmark/mseg_benchmark.py "$IMAGES_DIR" > benchmark_mseg.log
    echo "done."
    echo =============================================
    echo
fi

if [ "$RUN_JSEG" = true ] ; then
    # Run JSEG
    echo Running JSEG experiment...
    STARTTIME=$(date +%s)
    cd segmentation/jseg
    ./jseg.sh "../../$IMAGES_DIR"
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo
    echo =============================================
    echo "Running benchmark..."
    python segmentation/benchmark/jseg_benchmark.py "$IMAGES_DIR" > benchmark_jseg.log
    echo "done."
    echo =============================================
    echo
fi

if [ "$RUN_MEANSHIFT" = true ] ; then
    # Run meanshift
    echo Running meanshift experiment...
    STARTTIME=$(date +%s)
    cd segmentation/meanshift
    ./meanshift.sh "../../$IMAGES_DIR"
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo
    echo =============================================
    echo "Running benchmark..."
    python segmentation/benchmark/meanshift_benchmark.py "$IMAGES_DIR" > benchmark_meanshift.log
    echo "done."
    echo =============================================
    echo
fi

if [ "$RUN_SRM" = true ] ; then
    # Run SRM
    echo Running SRM experiment...
    STARTTIME=$(date +%s)
    cd segmentation/srm
    ./srm.sh "$MATLAB_HOME" "../../$IMAGES_DIR"
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo
    echo =============================================
    echo "Running benchmark..."
    python segmentation/benchmark/srm_benchmark.py "$IMAGES_DIR" > benchmark_srm.log
    echo "done."
    echo =============================================
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
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi
