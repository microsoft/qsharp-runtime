#  
# Copyright (c) Microsoft. All Rights Reserved.

CUDA_TOOLKIT    := $(shell dirname $$(command -v nvcc))/..
CUSTATEVEC_ROOT := /opt/cuquantum

INC             := -I$(CUSTATEVEC_ROOT)/include
LIBS            := -L$(CUSTATEVEC_ROOT)/lib64 -lcudart -lcustatevec

CXX_FLAGS= -std=c++11 $(INC) $(LIBS)

all:
	nvcc --shared --compiler-options '-fPIC'  -o libcudaquantumgates.so cudaquantumgates.cu  ${CXX_FLAGS}
	cp libcudaquantumgates.so ../Qir/Runtime/bin/Release/bin/

clean:
	rm -f cudaquantumgates.so
