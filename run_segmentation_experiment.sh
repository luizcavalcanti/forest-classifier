#!/bin/bash


RUN_MEANSHIFT=true
RUN_SRM=true
RUN_LEARNING=true


if [ "$RUN_MEANSHIFT" = true ] ; then
    # Run meanshif
    echo Running meanshift experiment...
    STARTTIME=$(date +%s)
    cd meanshift
    ./meanshift.sh
    cd ..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi


if [ "$RUN_SRM" = true ] ; then
    # Run SRM
    echo Running SRM experiment...
    STARTTIME=$(date +%s)
    cd srm
    ./srm.sh
    cd ..
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi


if [ "$RUN_LEARNING" = true ] ; then
    # Run learning-based segmentaiton experiment
    echo Running learning-based experiment. This may take a while \(no kidding\)...
    STARTTIME=$(date +%s)
    java -cp ".:forestclassifier.jar:lib/*" br.edu.ufam.icomp.ammd.ImageSegmentationExperiment
    echo Running overlay on output
    java -cp ".:forestclassifier.jar:lib/*" br.edu.ufam.icomp.ammd.SegmentationOverlay
    ENDTIME=$(date +%s)
    echo "done in $(($ENDTIME - $STARTTIME)) seconds."
    echo =============================================
fi
