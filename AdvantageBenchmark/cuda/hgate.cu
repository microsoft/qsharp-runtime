/*
Copyright (c) Microsoft. All Rights Reserved.
 */

#include <cuda_runtime_api.h> // cudaMalloc, cudaMemcpy, etc.
#include <cuComplex.h>        // cuDoubleComplex
#include <custatevec.h>       // custatevecApplyMatrix
#include <stdio.h>            // printf
#include <stdlib.h> 
#include <cstdlib>

#include <math.h>
#include <time.h>
#include <numeric>
#include <sstream>
#include <iostream>

#include <chrono>

#include "helper.hpp"         // HANDLE_ERROR, HANDLE_CUDA_ERROR
#include <memory>

__global__ void my_custom_init(cuDoubleComplex* __restrict__ vector, int64_t number_of_elements, int64_t bit_value) {
	int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
	if(i < number_of_elements) 
    {
        if (i == bit_value)
        {
            vector[i] = make_cuDoubleComplex( 1., 0.);
        }
        else
        {
            vector[i] = make_cuDoubleComplex( 0., 0.);
        }
	}
}

__global__ void my_maxtrix_init(cuDoubleComplex* __restrict__ vector, int64_t number_of_elements) {
	int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
	if(i < number_of_elements) 
    {
        vector[i] = make_cuDoubleComplex( (double)i, 0.);
	}
}

void run_gate(const cuDoubleComplex* matrix, int nControls, int nTargets, int adjoint, const int* targets, const int* controls, int nIndexBits)
{
    const int64_t nSvSize    = (1LL << nIndexBits);
    const int loops = 3;

    cuDoubleComplex *d_sv;
    HANDLE_CUDA_ERROR(cudaMalloc((void**)&d_sv, nSvSize * sizeof(cuDoubleComplex)));

    my_custom_init<<<84, 128>>>(d_sv, nSvSize, 0) ;

    cuDoubleComplex *d_matrix = nullptr;
    if (matrix == nullptr)
    {
        const int64_t nMSize    = (1LL << nTargets);
        HANDLE_CUDA_ERROR(cudaMalloc((void**)&d_matrix, nMSize * nMSize * sizeof(cuDoubleComplex)));
        my_maxtrix_init<<<84, 128>>>(d_matrix, nMSize) ;
    }

    //----------------------------------------------------------------------------------------------

    // custatevec handle initialization
    custatevecHandle_t handle;
    HANDLE_ERROR( custatevecCreate(&handle) );

    void* extraWorkspace = nullptr;
    size_t extraWorkspaceSizeInBytes = 0;

    // check the size of external workspace
    HANDLE_ERROR( custatevecApplyMatrix_bufferSize(
                  handle, CUDA_C_64F, nIndexBits, matrix == nullptr ? d_matrix : matrix, CUDA_C_64F, CUSTATEVEC_MATRIX_LAYOUT_ROW,
                  adjoint, nTargets, nControls, CUSTATEVEC_COMPUTE_64F, &extraWorkspaceSizeInBytes) );

    // allocate external workspace if necessary
    if (extraWorkspaceSizeInBytes > 0)
        HANDLE_CUDA_ERROR( cudaMalloc(&extraWorkspace, extraWorkspaceSizeInBytes) );

    for(int i = 0; i < loops; i++)
    {
        // apply gate
        HANDLE_ERROR( custatevecApplyMatrix(
                    handle, d_sv, CUDA_C_64F, nIndexBits, matrix == nullptr ? d_matrix : matrix, CUDA_C_64F,
                    CUSTATEVEC_MATRIX_LAYOUT_ROW, adjoint, targets, nTargets, controls, nControls, 
                    nullptr, CUSTATEVEC_COMPUTE_64F, extraWorkspace, extraWorkspaceSizeInBytes) );
    }
    // destroy handle
    HANDLE_ERROR( custatevecDestroy(handle) );

    //----------------------------------------------------------------------------------------------


    HANDLE_CUDA_ERROR( cudaFree(d_sv) );
    if (extraWorkspaceSizeInBytes)
        HANDLE_CUDA_ERROR( cudaFree(extraWorkspace) );

    if (d_matrix != nullptr)
    {
        HANDLE_CUDA_ERROR( cudaFree(d_matrix) );
    }
}

class Timing
{
    public:
        Timing(std::string name, uint32_t times = 1): name_(name), times_(times)
        {
            start_ = std::chrono::duration_cast<std::chrono::microseconds>(
                     std::chrono::high_resolution_clock::now().time_since_epoch())
                     .count();
        }

        ~Timing()
        {
            auto end = std::chrono::duration_cast<std::chrono::microseconds>(
                     std::chrono::high_resolution_clock::now().time_since_epoch())
                     .count();
            std::cout<<name_<<" average: "<< ((end - start_) / times_) / 1000 << " ms"<<std::endl;
            
        }

    private:
        uint64_t start_;
        std::string name_;
        uint32_t times_;
};

std::unique_ptr<cuDoubleComplex []> create_random_matrix(unsigned nqubits)
{
    uint64_t size = (1ULL << nqubits);
    size = size * size;
    std::unique_ptr<cuDoubleComplex []> matrix(new cuDoubleComplex[size]);
    for (uint64_t i = 0; i < size; i++)
    {
        matrix[i].x = drand48();
        matrix[i].y = 0;
    }
    return matrix;
}

void run_random_gates(
    std::string title,
    unsigned nqubits, 
    int nIndexBits,
    const int * random_targets,
    const int * random_controls,
    int random_nTargets,
    int random_nControls  = 0,
    int random_adjoint    = 0)
{
    std::unique_ptr<cuDoubleComplex[]> random3_matrix = create_random_matrix(nqubits);
    std::stringstream ss;
    ss<<"Random"<<title<<nqubits;
    Timing timer(ss.str(), 5);
    for(int i = 0; i < 5; i++)
    {
        run_gate(random3_matrix.get(), random_nControls, random_nTargets, random_adjoint, random_targets, random_controls, nIndexBits);
    }
}

void run_null_gates(
    std::string title,
    unsigned nqubits, 
    int nIndexBits,
    const int * random_targets,
    const int * random_controls,
    int random_nTargets,
    int random_nControls  = 0,
    int random_adjoint    = 0)
{
    std::stringstream ss;
    ss<<"Random"<<title<<nqubits;
    Timing timer(ss.str(), 5);
    for(int i = 0; i < 5; i++)
    {
        run_gate(nullptr, random_nControls, random_nTargets, random_adjoint, random_targets, random_controls, nIndexBits);
    }
}


int main(int argc, char* argv[]) {

    int nIndexBits = 20;
    if (argc >= 2)
    {
        nIndexBits = atoi(argv[1]);
    }
    const double sqrt2_reverse = 1.0/sqrt(2.);
    

    const int h_targets[]  = {0};
    const int h_controls[] = {};
    const int h_nTargets   = 1;
    const int h_nControls  = 0;
    const int h_adjoint    = 0;
    cuDoubleComplex h_matrix[] = {{sqrt2_reverse, 0.0}, {sqrt2_reverse, 0.0},
                                {sqrt2_reverse, 0.0}, {-sqrt2_reverse, 0.0}};
    {
        Timing timer("HGate", 5);
        for (int i = 0; i < 5; i++)
        {
        run_gate(h_matrix, h_nControls, h_nTargets, h_adjoint, h_targets, h_controls, nIndexBits);
        }
    }

    const int cnot_targets[]  = {0};
    const int cnot_controls[] = {1};
    const int cnot_nTargets   = 1;
    const int cnot_nControls  = 1;
    const int cnot_adjoint    = 0;
    cuDoubleComplex not_matrix[] = {{0., 0.0}, {1., 0.0},
                                {1., 0.0}, {0., 0.0}};
    {
        Timing timer("CNOTGate");
        run_gate(not_matrix, cnot_nControls, cnot_nTargets, cnot_adjoint, cnot_targets, cnot_controls, nIndexBits);
    }

    const int ccnot_targets[]  = {0};
    const int ccnot_controls[] = {1, 2};
    const int ccnot_nTargets   = 1;
    const int ccnot_nControls  = 2;
    const int ccnot_adjoint    = 0;

    {
        Timing timer("CCNOTGate");
        run_gate(not_matrix, ccnot_nControls, ccnot_nTargets, ccnot_adjoint, ccnot_targets, ccnot_controls, nIndexBits);
    }

    int random_controls [] ={};
    for (unsigned nqubits = 1; nqubits <= 7; nqubits++)
    {
        int random_nTargets   = (int)nqubits;
        std::unique_ptr<int[]> random_targets (new int[random_nTargets]);
        for(int i = 0; i < (int)nqubits; i++)
        {
            random_targets[i] = nIndexBits -1 - i;
        }

        run_random_gates("High", nqubits, nIndexBits, random_targets.get(), random_controls, random_nTargets);
        run_null_gates("HighNull", nqubits, nIndexBits, random_targets.get(), random_controls, random_nTargets);
    }

    for (unsigned nqubits = 1; nqubits <= 7; nqubits++)
    {
        int random_nTargets   = (int)nqubits;
        std::unique_ptr<int[]> random_targets (new int[random_nTargets]);
        for(int i = 0; i < (int)nqubits; i++)
        {
            random_targets[i] = i;
        }

        run_random_gates("Low", nqubits, nIndexBits, random_targets.get(), random_controls, random_nTargets);
        run_null_gates("LowNull", nqubits, nIndexBits, random_targets.get(), random_controls, random_nTargets);
    }
}
