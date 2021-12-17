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


__global__ void isqubitclassical(cuDoubleComplex* __restrict__ vector, int64_t number_of_elements,double eps, bool *haves_out, int64_t offset, int64_t mask) {
    const int64_t thIdx = threadIdx.x;
    const int64_t blockSize = blockDim.x;
    const int64_t gthIdx = thIdx + blockIdx.x*blockSize;
    
    bool have0 = false;
    bool have1 = false;
    const int64_t gridSize = blockSize*gridDim.x;

    for (int64_t elemId = gthIdx; elemId < number_of_elements / 2; elemId += gridSize)
    {
        {
            int64_t j = elemId % offset;
            int64_t i = ((elemId & mask) << 1);
            int64_t pos0 = i + j;
            int64_t pos1 = i + j + offset;
            double value0 = sqrt(vector[pos0].x * vector[pos0].x + vector[pos0].y * vector[pos0].y);
            double value1 = sqrt(vector[pos1].x * vector[pos1].x + vector[pos1].y * vector[pos1].y);

            have0 |= (value0 >= eps);
            have1 |= (value1 >= eps);
        }
    }
    
    __shared__ bool have0s[1024];
    __shared__ bool have1s[1024];
    have0s[thIdx] = have0;
    have1s[thIdx] = have1;
    __syncthreads();
    for (int size = blockSize/2; size>0; size/=2) 
    { //uniform
        if (thIdx<size)
        {
            have0s[thIdx] += have0s[thIdx+size];
            have1s[thIdx] += have1s[thIdx+size];
        }
        __syncthreads();
    }
    if (thIdx == 0)
    {
        haves_out[blockIdx.x * 2] = have0s[0];
        haves_out[blockIdx.x * 2 + 1] = have1s[0];
    }
}

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

__global__ void get_qubit_value(cuDoubleComplex* __restrict__ vector, const int64_t number_of_elements, int64_t mask, double eps, int* result)
{
    int64_t i = static_cast<int64_t>(blockIdx.x) * blockDim.x + threadIdx.x;
    if(i < number_of_elements) 
    {
        double value = sqrt(vector[i].x * vector[i].x + vector[i].y * vector[i].y);
        if (value > eps) 
        {
            // only one thread shall hit this
            result[0] = (i & mask ? 1 : 0);
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


class CTiming
{
  public:
    CTiming(int64_t& totalIn) : total_(totalIn)
    {
        start_ = std::chrono::duration_cast<std::chrono::microseconds>(
                    std::chrono::high_resolution_clock::now().time_since_epoch())
                    .count();
    }

    ~CTiming()
    {
        auto end = std::chrono::duration_cast<std::chrono::microseconds>(
                       std::chrono::high_resolution_clock::now().time_since_epoch())
                       .count();
        total_ += (end - start_) / 1000;
    }
private:
    int64_t start_;
    int64_t& total_;
};

class AutoHandle
{
    public:
        AutoHandle(custatevecHandle_t& handle): handle_(handle)
        {
            if (handle_ == 0)
            {
                HANDLE_ERROR( custatevecCreate(&handle_) );
            }
        }
        ~AutoHandle()
        {
            if (handle_ != 0)
            {
                HANDLE_ERROR( custatevecDestroy(handle_) );
                handle_ = 0;
            }
        }
    private:
        custatevecHandle_t& handle_;
};

class CudaContext
{
    public:
        CudaContext(int nQubits): nQubits_(0), handle_(0), wfn_(nullptr)
        , measure_ms_(0), apply_ms_(0), create_ms_(0), exp_ms_(0), release_ms_(0), collapse_ms_(0), classical_ms_(0), get_ms_(0), applys_(0), measures_(0)
        {
            if (nQubits >0)
            {
                create_qubits(nQubits);
            }

            //HANDLE_ERROR( custatevecCreate(&handle_) );
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

            std::cout<<"measure:"<<measure_ms_<<", apply:"<<apply_ms_<<", create:"<<create_ms_<<", exp:"<<exp_ms_<<", release:"<<release_ms_<<", collapse:"<<collapse_ms_<<", classical:"<<classical_ms_<<", get:"<<get_ms_<<std::endl;
            std::cout<<"measure count: "<<measures_<<", apply count:"<<applys_<<std::endl;
        }

        inline void release_qubits()
        {
            if (wfn_ != nullptr)
            {
                CTiming timer(release_ms_);
                HANDLE_CUDA_ERROR( cudaFree(wfn_) );
                wfn_ = nullptr;
                nQubits_ = 0;
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
                CTiming timer(create_ms_);
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

        inline int get_value(int64_t mask, double eps)
        {
            const int64_t nSvSize    = (1LL << nQubits_);
            const int64_t blockSize = 1024;
            const int64_t gridSize = (nSvSize + blockSize - 1) / blockSize;
            int * device_out;
            HANDLE_CUDA_ERROR(cudaMalloc((void**)&device_out, sizeof(int)));
            get_qubit_value<<<gridSize, blockSize>>>(wfn_, nSvSize, (int64_t)mask, eps, device_out);
            int result;
            HANDLE_CUDA_ERROR(cudaMemcpy(&result, device_out, sizeof(int), cudaMemcpyDeviceToHost));
            HANDLE_CUDA_ERROR(cudaFree(device_out));
            return (result == 1 || result == 0) ? result : 2;
        }

        inline void collapse(uint64_t mask, uint64_t state)
        {
            CTiming timer(collapse_ms_);
            const int64_t nSvSize    = (1LL << nQubits_);
            const int64_t blockSize = 1024;
            const int64_t gridSize = (nSvSize + blockSize - 1) / blockSize;

            collapse_one_bit<<<gridSize, blockSize>>>(wfn_, nSvSize, state, mask);
        }

        inline void isclassical(double eps, bool *haves_out, int64_t offset, int64_t mask, int64_t num_blocks)
        {
            CTiming timer(classical_ms_);
            const int64_t nSvSize    = (1LL << nQubits_);
            const int64_t blockSize = 1024;
            bool *out_buf_device = nullptr;
            const size_t output_size = num_blocks * sizeof(bool) * 2;
            HANDLE_CUDA_ERROR(cudaMalloc((void**)&out_buf_device, output_size));
            isqubitclassical<<<num_blocks, blockSize>>>(wfn_, nSvSize, eps, out_buf_device, offset, mask);
            HANDLE_CUDA_ERROR(cudaMemcpy(haves_out, out_buf_device, output_size, cudaMemcpyDeviceToHost));
            HANDLE_CUDA_ERROR(cudaFree(out_buf_device));
        }

        inline void increase_one_qubit()
        {
            create_qubits(nQubits_ + 1);
        }

        inline void apply_controlled_exp(double theta, const int* paulis, const int32_t *targets, 
        const uint32_t nTargets, const int32_t *controls, const int32_t *controlBitValues, const uint32_t nControls)
        {
            CTiming timer(exp_ms_);
            std::vector<custatevecPauli_t> e_paulis(nTargets);
            for (uint32_t i = 0; i < nTargets; i++)
            {
                e_paulis[i] = E_Paulis[paulis[i]];
            }
            AutoHandle autohandle(handle_);
            HANDLE_ERROR(custatevecApplyExp(handle_, wfn_, CUDA_C_64F, (uint32_t)nQubits_, 
            theta, e_paulis.data(), targets, nTargets, controls, controlBitValues, nControls));
        }

        inline void meansure_zbasis(int32_t *parity, const int32_t *basis_bits, uint32_t nbasis_bits, double randnum, bool collapse)
        {
            CTiming timer(measure_ms_);
            measures_++;
            AutoHandle autohandle(handle_);
            custatevecHandle_t handle = handle_;
            HANDLE_ERROR(custatevecMeasureOnZBasis(handle, wfn(), CUDA_C_64F, num_qubits(), parity, basis_bits, nbasis_bits, randnum, 
            collapse ? CUSTATEVEC_COLLAPSE_NORMALIZE_AND_ZERO : CUSTATEVEC_COLLAPSE_NONE));
        }

        inline void apply_gate(const cuDoubleComplex* matrix, int nControls, int nTargets, const int* targets, const int* controls)
        {
            CTiming timer(apply_ms_);
            applys_++;
            size_t extraWorkspaceSizeInBytes = 0;
            void* extraWorkspace = nullptr;
            {
            AutoHandle autohandle(handle_);
            custatevecHandle_t handle = handle_;
            int adjoint = 0;

            // check the size of external workspace
            HANDLE_ERROR( custatevecApplyMatrix_bufferSize(
                        handle, CUDA_C_64F, num_qubits(), matrix, CUDA_C_64F, CUSTATEVEC_MATRIX_LAYOUT_ROW,
                        adjoint, nTargets, nControls, CUSTATEVEC_COMPUTE_64F, &extraWorkspaceSizeInBytes) );

            // allocate external workspace if necessary
            if (extraWorkspaceSizeInBytes > 0)
                HANDLE_CUDA_ERROR( cudaMalloc(&extraWorkspace, extraWorkspaceSizeInBytes) );

            //auto start_ms = std::chrono::duration_cast<std::chrono::microseconds>(
            //         std::chrono::high_resolution_clock::now().time_since_epoch())
            //         .count();

            // apply gate
            HANDLE_ERROR( custatevecApplyMatrix(
                        handle, wfn(), CUDA_C_64F, num_qubits(), matrix, CUDA_C_64F,
                        CUSTATEVEC_MATRIX_LAYOUT_ROW, adjoint, targets, nTargets, controls, nControls, 
                        nullptr, CUSTATEVEC_COMPUTE_64F, extraWorkspace, extraWorkspaceSizeInBytes) );

            //auto end_ms = std::chrono::duration_cast<std::chrono::microseconds>(
            //         std::chrono::high_resolution_clock::now().time_since_epoch())
			//			.count();
		    // std::cout<<"custatevecApplyMatrix time:"<<(end_ms - start_ms)/1000.<<std::endl;
            }
            if (extraWorkspaceSizeInBytes)
                HANDLE_CUDA_ERROR( cudaFree(extraWorkspace) );
        }

    private:
        int nQubits_;
        custatevecHandle_t handle_;
        cuDoubleComplex *wfn_;
        int64_t measure_ms_;
        int64_t apply_ms_;
        int64_t create_ms_;
        int64_t exp_ms_;
        int64_t release_ms_;
        int64_t collapse_ms_;
        int64_t classical_ms_;
        int64_t get_ms_;
        int64_t applys_;
        int64_t measures_;
};


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
    void apply_cuquantum_gate(void* handle, const double* matrix, int nControls, int nTargets, const int* targets, const int* controls)
    {
        CudaContext* pContext = reinterpret_cast<CudaContext*>(handle);
        const cuDoubleComplex* pMatrix = reinterpret_cast<const cuDoubleComplex*>(matrix);
        pContext->apply_gate(pMatrix, nControls, nTargets, targets, controls);
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
        pContext->meansure_zbasis(parity, basis_bits, nbasis_bits, randnum, collapse);
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

    void release_cuquantum_bits(void* handle)
    {
        CudaContext* p_context = reinterpret_cast<CudaContext*>(handle);
        p_context->release_qubits();
    }

    void is_cuquantum_classical(void* handle, double eps, bool *haves_out, int64_t offset, int64_t mask, int64_t num_blocks)
    {
        CudaContext* p_context = reinterpret_cast<CudaContext*>(handle);
        p_context->isclassical(eps, haves_out, offset, mask, num_blocks);
    }

    int get_cuquantum_value(void* handle, int64_t mask, double eps)
    {
        CudaContext* p_context = reinterpret_cast<CudaContext*>(handle);
        return p_context->get_value(mask, eps);
    }
}

