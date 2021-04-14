// Copyright (c) Microsoft Corporation.

// Bridge for connecting C++ to the Quantum Driver Rust Implimentaiton Project (QDRIP)

#include <cassert>
#include <string>

#include "QirContext.hpp"
#include "QirRuntimeApi_I.hpp"

using namespace std;
using namespace Microsoft::Quantum;
typedef long long int i64;

// External functions implemented in Rust
extern "C" 
{
    size_t init(size_t initialcapacity);
    i64 destroy(size_t sim_id);
    void set_noise_model(size_t sim_id, const char* model);

    unsigned get_qubit_id(Qubit qubit); //NOLINT
    Qubit allocate_qubit(); //NOLINT
    void release_qubit(Qubit q); //NOLINT
    void release_result(Result r); //NOLINT
    Result use_zero(); //NOLINT
    Result use_one(); //NOLINT
    bool are_equal_results(Result r1, Result r2); //NOLINT
}

class COpenSimDriver : public IRuntimeDriver
{
    unsigned GetQubitId(Qubit qubit) const
    {
        return get_qubit_id(qubit);
    }

public:
    COpenSimDriver()
    {
        assert(init(3) == 1);
    }
    ~COpenSimDriver()
    {
        assert(destroy(1) == 0);
    }

    void SetNoiseModel(string model)
    {
        set_noise_model(1, model.c_str());
    }

    string QubitToString(Qubit qubit) override
    {
        return to_string(GetQubitId(qubit));
    }

    Qubit AllocateQubit() override
    {
        return allocate_qubit();
    }

    void ReleaseQubit(Qubit q) override
    {
        release_qubit(q);
    }

    void ReleaseResult(Result r) override
    {
        release_result(r);
    }

    ResultValue GetResultValue(Result r) override
    {
        return (AreEqualResults(r, UseZero())) ? Result_Zero : Result_One;
    }

    Result UseZero() override
    {
        return use_zero();
    }

    Result UseOne() override
    {
        return use_one();
    }

    bool AreEqualResults(Result r1, Result r2) override
    {
        return are_equal_results(r1, r2);
    }
};