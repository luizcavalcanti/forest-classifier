#!/bin/bash

RUN_MSEG=true
RUN_JSEG=false
RUN_MEANSHIFT=false
RUN_SRM=false
RUN_LEARNING=false

IMAGES_DIR=$1

if [ "$RUN_MSEG" = true ] ; then
    # Run MSEG
    pwd
    echo Running MSEG experiment...
    STARTTIME=$(date +%s)
    cd segmentation/mseg
    pwd
    ./mseg.sh "../../$IMAGES_DIR"
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi

if [ "$RUN_JSEG" = true ] ; then
    # Run JSEG
    echo Running JSEG experiment...
    STARTTIME=$(date +%s)
    cd segmentation/jseg
    ./jseg.sh
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi

if [ "$RUN_MEANSHIFT" = true ] ; then
    # Run meanshif
    echo Running meanshift experiment...
    STARTTIME=$(date +%s)
    cd segmentation/meanshift
    ./meanshift.sh out
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi

if [ "$RUN_SRM" = true ] ; then
    # Run SRM
    echo Running SRM experiment...
    STARTTIME=$(date +%s)
    cd segmentation/srm
    ./srm.sh
    cd ../..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
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
