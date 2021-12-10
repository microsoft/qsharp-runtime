#  
# Copyright (c) Microsoft. All Rights Reserved.

CUDA_TOOLKIT    := $(shell dirname $$(command -v nvcc))/..
CUSTATEVEC_ROOT ?= ${CUDA_TOOLKIT}

INC             := -I$(CUSTATEVEC_ROOT)/include
LIBS            := -L$(CUSTATEVEC_ROOT)/lib64 -lcudart -lcustatevec

CXX_FLAGS= -std=c++11 $(INC) $(LIBS)

all:
	nvcc hgate.cu  -o hgate  ${CXX_FLAGS}

clean:
	rm -f hgate 
