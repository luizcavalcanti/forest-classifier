#Makefile for Edge Detection Image SegmentatiON (EDISON) System
#Robust Image Understanding Laboratory
#by Chris M. Christoudias

#define compiler
CC		= g++

#define executable name
EXENAME		= edison

#define dependents
COMMAND_SOURCE	= src/prompt/main.cpp src/prompt/parser.cpp src/prompt/globalFnc.cpp src/prompt/edison.cpp
COMMAND_INCLUDES	= src/prompt/parser.h src/prompt/defs.h src/prompt/error.h src/prompt/flags.h src/prompt/edison.h
IMAGE_SOURCE	= src/prompt/libppm.cpp
IMAGE_INCLUDES	= src/prompt/imfilt.h src/prompt/libppm.h
SEGM_SOURCE     = src/segm/ms.cpp src/segm/msSysPrompt.cpp src/segm/msImageProcessor.cpp src/segm/RAList.cpp src/segm/rlist.cpp
SEGM_INCLUDES   = src/segm/tdef.h src/segm/RAList.h src/segm/ms.h src/segm/msImageProcessor.h src/segm/msSys.h src/segm/rlist.h
EDGE_SOURCE     = src/edge/BgEdge.cpp src/edge/BgEdgeDetect.cpp src/edge/BgEdgeList.cpp src/edge/BgGlobalFc.cpp src/edge/BgImage.cpp
EDGE_INCLUDES	= src/edge/BgDefaults.h src/edge/BgEdge.h src/edge/BgEdgeDetect.h src/edge/BgImage.h

#define targets
all: EDISON

EDISON	: $(COMMAND_SOURCE) $(COMMAND_INCLUDES) $(IMAGE_SOURCE) $(IMAGE_INCLUDES) $(SEGM_SOURCE) $(SEGM_INCLUDES) $(EDGE_SOURCE) $(EDGE_INCLUDES)
	$(CC) -o $(EXENAME) $(COMMAND_SOURCE) $(IMAGE_SOURCE) $(SEGM_SOURCE) $(EDGE_SOURCE) -w





