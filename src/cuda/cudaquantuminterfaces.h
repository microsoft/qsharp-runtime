/*
Copyright (c) Microsoft. All Rights Reserved.
 */

extern "C"
{
    void* create_cuquantum_context();
    void  free_cuquantum_context(void* handle);
    void apply_cuquantum_gate(const void* handle, const double* matrix, int nControls, int nTargets, const int* targets, const int* controls);
    void create_cuquantum_bits(void* handle, int num_qubits);
    void increase_cuquantum_bit(void* handle);
    void meansure_cuquantum_zbasis(void* handle, int32_t *parity, const int32_t *basis_bits, uint32_t nbasis_bits, double randnum, bool collapse);
    void collapse_cuquantum(void* handle, uint64_t mask, uint64_t state);
    void apply_cuquantum_controlled_exp(void* handle, double theta, const int* paulis, const int32_t *targets, 
        const uint32_t nTargets, const int32_t *controls, const int32_t *controlBitValues, const uint32_t nControls);
}