/*
Copyright (c) Microsoft. All Rights Reserved.
 */

#include <cuda_runtime_api.h> // cudaMalloc, cudaMemcpy, etc.
#include <cuComplex.h>        // cuDoubleComplex
#include <custatevec.h>       // custatevecApplyMatrix
#include <stdio.h>            // printf
#include <stdlib.h> 
#include <cstdlib>
#include <cstdint>
#include <vector>

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

__global__ void collapse_one_bit(cuDoubleComplex* __restrict__ vector, int64_t number_of_elements, uint64_t state, uint64_t mask) {
	int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
	if(i < number_of_elements) 
    {
        if ((((uint64_t)i) & mask) != state) vector[i] = make_cuDoubleComplex( 0., 0.);
	}
}

static custatevecPauli_t  E_Paulis[4] = {CUSTATEVEC_PAULI_I, CUSTATEVEC_PAULI_X, CUSTATEVEC_PAULI_Z, CUSTATEVEC_PAULI_Y};

class CudaContext
{
    public:
        CudaContext(int nQubits): nQubits_(0), handle_(0), wfn_(nullptr)
        {
            if (nQubits >0)
            {
                create_qubits(nQubits);
            }

            HANDLE_ERROR( custatevecCreate(&handle_) );
        }

        ~CudaContext()
        {
            if (handle_ != 0)
            {
                HANDLE_ERROR( custatevecDestroy(handle_) );
            }
            
            if (wfn_ != nullptr)
            {
                HANDLE_CUDA_ERROR( cudaFree(wfn_) );
            }
        }
        inline int num_qubits() const
        {
            return nQubits_;
        }

        inline custatevecHandle_t handle() const
        {
            return handle_;
        }

        inline cuDoubleComplex* wfn() const
        {
            return wfn_;
        }

        inline void create_qubits(int num_qubits)
        {
            if (num_qubits != nQubits_)
            {
                if (nQubits_ != 0)
                {
                    HANDLE_CUDA_ERROR( cudaFree(wfn_) );
                    wfn_ = nullptr;
                }
                nQubits_ = num_qubits;

                if (num_qubits > 0)
                {
                    const int64_t nSvSize    = (1LL << num_qubits);
                    HANDLE_CUDA_ERROR(cudaMalloc((void**)&wfn_, nSvSize * sizeof(cuDoubleComplex)));
                    const int64_t blockSize = 1024;
                    const int64_t gridSize = (nSvSize + blockSize - 1) / blockSize;

                    my_custom_init<<<gridSize, blockSize>>>(wfn_, nSvSize, 0);
                }
            }
        }

        inline void collapse(uint64_t mask, uint64_t state)
        {
            const int64_t nSvSize    = (1LL << nQubits_);
            const int64_t blockSize = 1024;
            const int64_t gridSize = (nSvSize + blockSize - 1) / blockSize;

            collapse_one_bit<<<gridSize, blockSize>>>(wfn_, nSvSize, state, mask);
        }

        inline void increase_one_qubit()
        {
            create_qubits(nQubits_ + 1);
        }

        inline void apply_controlled_exp(double theta, const int* paulis, const int32_t *targets, 
        const uint32_t nTargets, const int32_t *controls, const int32_t *controlBitValues, const uint32_t nControls)
        {
            std::vector<custatevecPauli_t> e_paulis(nTargets);
            for (uint32_t i = 0; i < nTargets; i++)
            {
                e_paulis[i] = E_Paulis[paulis[i]];
            }
            HANDLE_ERROR(custatevecApplyExp(handle_, wfn_, CUDA_C_64F, (uint32_t)nQubits_, 
            theta, e_paulis.data(), targets, nTargets, controls, controlBitValues, nControls));
        }
    private:
        int nQubits_;
        custatevecHandle_t handle_;
        cuDoubleComplex *wfn_;
};

void apply_gate(const CudaContext* pContext, const cuDoubleComplex* matrix, int nControls, int nTargets, const int* targets, const int* controls)
{
    custatevecHandle_t handle = pContext->handle();
    int adjoint = 0;

    void* extraWorkspace = nullptr;
    size_t extraWorkspaceSizeInBytes = 0;

    // check the size of external workspace
    HANDLE_ERROR( custatevecApplyMatrix_bufferSize(
                  handle, CUDA_C_64F, pContext->num_qubits(), matrix, CUDA_C_64F, CUSTATEVEC_MATRIX_LAYOUT_ROW,
                  adjoint, nTargets, nControls, CUSTATEVEC_COMPUTE_64F, &extraWorkspaceSizeInBytes) );

    // allocate external workspace if necessary
    if (extraWorkspaceSizeInBytes > 0)
        HANDLE_CUDA_ERROR( cudaMalloc(&extraWorkspace, extraWorkspaceSizeInBytes) );


    // apply gate
    HANDLE_ERROR( custatevecApplyMatrix(
                handle, pContext->wfn(), CUDA_C_64F, pContext->num_qubits(), matrix, CUDA_C_64F,
                CUSTATEVEC_MATRIX_LAYOUT_ROW, adjoint, targets, nTargets, controls, nControls, 
                nullptr, CUSTATEVEC_COMPUTE_64F, extraWorkspace, extraWorkspaceSizeInBytes) );

    if (extraWorkspaceSizeInBytes)
        HANDLE_CUDA_ERROR( cudaFree(extraWorkspace) );
}

void meansure_zbasis(const CudaContext* p_context, int32_t *parity, const int32_t *basis_bits, uint32_t nbasis_bits, double randnum, bool collapse)
{
    custatevecHandle_t handle = p_context->handle();
    HANDLE_ERROR(custatevecMeasureOnZBasis(handle, p_context->wfn(), CUDA_C_64F, p_context->num_qubits(), parity, basis_bits, nbasis_bits, randnum, 
    collapse ? CUSTATEVEC_COLLAPSE_NORMALIZE_AND_ZERO : CUSTATEVEC_COLLAPSE_NONE));
}

extern "C"
{
    void* create_cuquantum_context()
    {
        void* pInstance = new CudaContext(0);
        return pInstance;
    }
    void  free_cuquantum_context(void* handle)
    {
        if (handle != nullptr)
        {
            CudaContext* pContext = reinterpret_cast<CudaContext*>(handle);
            delete pContext;
        }
    }
    void apply_cuquantum_gate(const void* handle, const double* matrix, int nControls, int nTargets, const int* targets, const int* controls)
    {
        const CudaContext* pContext = reinterpret_cast<const CudaContext*>(handle);
        const cuDoubleComplex* pMatrix = reinterpret_cast<const cuDoubleComplex*>(matrix);
        apply_gate(pContext, pMatrix, nControls, nTargets, targets, controls);
    }
    void create_cuquantum_bits(void* handle, int num_qubits)
    {
        CudaContext* pContext = reinterpret_cast<CudaContext*>(handle);
        pContext->create_qubits(num_qubits);
    }

    void increase_cuquantum_bit(void* handle)
    {
        CudaContext* pContext = reinterpret_cast<CudaContext*>(handle);
        pContext->increase_one_qubit();
    }

    void meansure_cuquantum_zbasis(void* handle, int32_t *parity, const int32_t *basis_bits, uint32_t nbasis_bits, double randnum, bool collapse)
    {
        CudaContext* pContext = reinterpret_cast<CudaContext*>(handle);
        meansure_zbasis(pContext, parity, basis_bits, nbasis_bits, randnum, collapse);
    }

    void collapse_cuquantum(void* handle, uint64_t mask, uint64_t state)
    {
        CudaContext* p_context = reinterpret_cast<CudaContext*>(handle);
        p_context->collapse(mask, state);
    }

    void apply_cuquantum_controlled_exp(void* handle, double theta, const int* paulis, const int32_t *targets, 
        const uint32_t nTargets, const int32_t *controls, const int32_t *controlBitValues, const uint32_t nControls)
    {
        CudaContext* p_context = reinterpret_cast<CudaContext*>(handle);
        p_context->apply_controlled_exp(theta, paulis, targets, nTargets, controls, controlBitValues, nControls);
    }
}

