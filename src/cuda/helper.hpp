/*  
Copyright (c) Microsoft. All Rights Reserved.
 */

#define HANDLE_ERROR(x)                                                        \
{   const auto err = x;                                                        \
    if (err != CUSTATEVEC_STATUS_SUCCESS ) {                                   \
        printf("Error: %s in line %d\n",                                       \
               custatevecGetErrorString(err), __LINE__); exit(EXIT_FAILURE); } \
};

#define HANDLE_CUDA_ERROR(x)                                                   \
{   const auto err = x;                                                        \
    if (err != cudaSuccess ) {                                                 \
        printf("Error: %s in line %d\n",                                       \
               cudaGetErrorString(err), __LINE__); exit(EXIT_FAILURE); }       \
};

bool almost_equal(cuDoubleComplex x, cuDoubleComplex y) {
    const double eps = 1.0e-5;
    const cuDoubleComplex diff = cuCsub(x, y);
    return (cuCabs(diff) < eps);
}
