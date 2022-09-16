// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#include <bitset>
#include <cassert>
#include <fstream>
#include <iostream>
#include <vector>
#include <climits>

#include "capi.hpp"
#include "qir.hpp"

unsigned SimId()
{
    // Using `thread_local` ensures each thread gets a unique simulator instance. This matches
    // expected QIR usage where multithreaded program execution is not supported.
    thread_local unsigned _sim = init();
    return _sim;
}

// Pauli consts are {i2} in QIR, likely stored as {i8} in arrays, but we are using the standard C++ enum type based on
// {i32} so cannot pass through the buffer and have to allocate a new one instead and copy.
std::vector<PauliId> ExtractPauliIds(QirArray* paulis)
{
    const auto count = __quantum__rt__array_get_size_1d(paulis);
    std::vector<PauliId> pauliIds;
    pauliIds.reserve(count);
    for (auto i = 0; i < count; i++)
    {
        pauliIds.push_back(static_cast<PauliId>(*__quantum__rt__array_get_element_ptr_1d(paulis, i)));
    }
    return pauliIds;
}

std::vector<unsigned> GetQubitIds(long num, QubitIdType* qubits)
{
    std::vector<unsigned> ids;
    ids.reserve((size_t)num);
    for (long i = 0; i < num; i++)
    {
        ids.push_back(static_cast<unsigned>(qubits[i]));
    }
    return ids;
}

std::vector<unsigned> GetBases(long num, PauliId* paulis)
{
    std::vector<unsigned> convertedBases;
    convertedBases.reserve((size_t)num);
    for (auto i = 0; i < num; i++)
    {
        convertedBases.push_back(static_cast<unsigned>(paulis[i]));
    }
    return convertedBases;
}

// Comparing floating point values with `==` or `!=` is not reliable.
// The values can be extremely close but still not exactly equal.
// It is more reliable to check if one value is within certain small tolerance near the other value.
// This template function is for comparing two floating point values.
template <typename TFloat>
inline bool Close(TFloat val1, TFloat val2)
{
    assert(
        std::is_floating_point_v<std::remove_reference_t<TFloat>> &&
        "Unexpected type is passed as a template argument");

    constexpr TFloat tolerance = 1e-10;

    // Both val1 and val2 can be close (or equal) to the maximum (or minimum) value representable with its type.
    // Adding to (or subtracting from) such a value can cause overflow (or underflow).
    // To avoid the overflow (or underflow) we don't add to the greater value (and don't sutract from a lesser value).
    if (val1 < val2)
    {
        return (val2 - val1) <= tolerance;
    }
    return (val1 - val2) <= tolerance;
}

std::ostream& GetOutStream(void* location, std::ofstream& outFileStream)
{
    // If the location is not nullptr and not empty string then dump to a file:
    if ((location != nullptr) && ((__quantum__rt__string_get_length(static_cast<QirString*>(location))) != 0))
    {
        // Open the file for appending:
        const std::string& filePath = __quantum__rt__string_get_data(static_cast<QirString*>(location));

        bool openException = false;
        try
        {
            outFileStream.open(filePath, std::ofstream::out | std::ofstream::app);
        }
        catch (const std::ofstream::failure& e)
        {
            openException = true;
            std::cerr << "Exception caught: \"" << e.what() << "\".\n";
        }

        if (((outFileStream.rdstate() & std::ofstream::failbit) != 0) || openException)
        {
            std::cerr << "Failed to open dump file \"" + filePath + "\".\n";
            return std::cout;
        }

        return outFileStream;
    }

    // Otherwise dump to std::cout:
    return std::cout;
}

TDumpToLocationCallback const dumpToLocationCallback =
    [](size_t idx, double re, double im, TDumpLocation location) -> bool
{
    std::ostream& outStream = *reinterpret_cast<std::ostream*>(location);

    if (!Close(re, 0.0) || !Close(im, 0.0))
    {
        outStream << "|" << std::bitset<8>(idx) << ">: " << re << "+" << im << "i" << std::endl;
    }
    return true;
};

void DumpMachineImpl(std::ostream& outStream)
{
    outStream << "# wave function for qubits (least to most significant qubit ids):" << std::endl;
    DumpToLocation(SimId(), dumpToLocationCallback, (TDumpLocation)&outStream);
    outStream.flush();
}

void DumpRegisterImpl(std::ostream& outStream, QirArray* qubits)
{
    outStream << "# wave function for qubits with ids (least to most significant): ";

    auto count = __quantum__rt__array_get_size_1d(qubits);
    std::vector<unsigned> ids =
        GetQubitIds(count, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)));
    for (auto idx = 0; idx < ids.size(); ++idx)
    {
        if (idx != 0)
        {
            outStream << "; ";
        }
        outStream << ids[idx];
    }
    outStream << ':' << std::endl;

    if (!DumpQubitsToLocation(SimId(), ids.size(), ids.data(), dumpToLocationCallback, (TDumpLocation)&outStream))
    {
        outStream << "## Qubits were entangled with an external qubit. Cannot dump corresponding wave function. ##"
                  << std::endl;
    }
    outStream.flush();
}

bool ArraysContainEqualResults(QirArray* rs1, QirArray* rs2)
{
    assert(
        rs1 != nullptr && rs2 != nullptr &&
        __quantum__rt__array_get_size_1d(rs1) == __quantum__rt__array_get_size_1d(rs2));

    RESULT** results1 = reinterpret_cast<RESULT**>(__quantum__rt__array_get_element_ptr_1d(rs1, 0));
    RESULT** results2 = reinterpret_cast<RESULT**>(__quantum__rt__array_get_element_ptr_1d(rs2, 0));
    for (auto i = 0; i < __quantum__rt__array_get_size_1d(rs1); i++)
    {
        if (!__quantum__rt__result_equal(results1[i], results2[i]))
        {
            return false;
        }
    }
    return true;
}

extern "C"
{
    QUBIT* __quantum__rt__qubit_allocate()
    {
        return reinterpret_cast<QUBIT*>(allocate(SimId()));
    }

    QirArray* __quantum__rt__qubit_allocate_array(int64_t count)
    {
        QirArray* array = __quantum__rt__array_create_1d(sizeof(intptr_t), count);
        for (auto i = 0; i < count; i++)
        {
            *reinterpret_cast<QUBIT**>(__quantum__rt__array_get_element_ptr_1d(array, i)) =
                __quantum__rt__qubit_allocate();
        }
        return array;
    }

    void __quantum__rt__qubit_release(QUBIT* qubit)
    {
        release(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__rt__qubit_release_array(QirArray* array)
    {
        auto count = __quantum__rt__array_get_size_1d(array);
        for (auto i = 0; i < count; i++)
        {
            __quantum__rt__qubit_release(*reinterpret_cast<QUBIT**>(__quantum__rt__array_get_element_ptr_1d(array, i)));
        }
        __quantum__rt__array_update_reference_count(array, -1);
    }

    QirString* __quantum__rt__qubit_to_string(QUBIT* qubit)
    {
        return __quantum__rt__string_create(std::to_string(reinterpret_cast<QubitIdType>(qubit)).c_str());
    }

    RESULT* __quantum__rt__result_get_one()
    {
        return reinterpret_cast<RESULT*>(1);
    }

    RESULT* __quantum__rt__result_get_zero()
    {
        return reinterpret_cast<RESULT*>(0);
    }

    bool __quantum__rt__result_equal(RESULT* r1, RESULT* r2)
    {
        return r1 == r2;
    }

    void __quantum__rt__result_update_reference_count(RESULT* r, int32_t increment)
    {
        // No-op
    }

    QirString* __quantum__rt__result_to_string(RESULT* result)
    {
        return __quantum__rt__result_equal(result, __quantum__rt__result_get_zero())
                   ? __quantum__rt__string_create("Zero")
                   : __quantum__rt__string_create("One");
    }

    void __quantum__rt__result_record_output(RESULT* res)
    {
        if (__quantum__rt__result_equal(res, __quantum__rt__result_get_zero()))
        {
            __quantum__rt__message(__quantum__rt__string_create("RESULT\t0\n"));
        }
        else
        {
            __quantum__rt__message(__quantum__rt__string_create("RESULT\t1\n"));
        }
    }

    void __quantum__qis__exp__body(QirArray* paulis, double angle, QirArray* qubits)
    {
        assert(__quantum__rt__array_get_size_1d(paulis) == __quantum__rt__array_get_size_1d(qubits));
        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        auto numTargets = pauliIds.size();
        auto targets = reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0));
        std::vector<unsigned> ids = GetQubitIds(numTargets, targets);
        std::vector<unsigned> convertedBases = GetBases(numTargets, pauliIds.data());
        Exp(SimId(), (unsigned)numTargets, convertedBases.data(), angle, ids.data());
    }

    void __quantum__qis__exp__adj(QirArray* paulis, double angle, QirArray* qubits)
    {
        __quantum__qis__exp__body(paulis, -angle, qubits);
    }

    void __quantum__qis__exp__ctl(QirArray* ctls, QirExpTuple* args)
    {
        assert(__quantum__rt__array_get_size_1d(args->paulis) == __quantum__rt__array_get_size_1d(args->targets));

        std::vector<PauliId> pauliIds = ExtractPauliIds(args->paulis);
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        auto numTargets = pauliIds.size();
        auto controls = reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0));
        auto targets = reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(args->targets, 0));
        std::vector<unsigned> idsTargets = GetQubitIds(numTargets, targets);
        std::vector<unsigned> idsControls = GetQubitIds(numControls, controls);
        std::vector<unsigned> convertedBases = GetBases(numTargets, pauliIds.data());
        MCExp(
            SimId(), (unsigned)numTargets, convertedBases.data(), args->angle, (unsigned)numControls, idsControls.data(),
            idsTargets.data());
    }

    void __quantum__qis__exp__ctladj(QirArray* ctls, QirExpTuple* args)
    {
        assert(__quantum__rt__array_get_size_1d(args->paulis) == __quantum__rt__array_get_size_1d(args->targets));

        QirExpTuple updatedArgs = {args->paulis, -(args->angle), args->targets};

        __quantum__qis__exp__ctl(ctls, &updatedArgs);
    }

    void __quantum__qis__h__body(QUBIT* qubit)
    {
        H(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__h__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCH(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    RESULT* __quantum__qis__measure__body(QirArray* paulis, QirArray* qubits)
    {
        assert(__quantum__rt__array_get_size_1d(qubits) == __quantum__rt__array_get_size_1d(paulis));

        std::vector<PauliId> pauliIds = ExtractPauliIds(paulis);
        auto count = pauliIds.size();
        std::vector<unsigned> convertedBases = GetBases(count, pauliIds.data());
        std::vector<unsigned> ids =
            GetQubitIds(count, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)));
        return Measure(SimId(), count, convertedBases.data(), ids.data()) ? __quantum__rt__result_get_one()
                                                                         : __quantum__rt__result_get_zero();
    }

    void __quantum__qis__r__body(PauliId axis, double angle, QUBIT* qubit)
    {
        R(SimId(), static_cast<unsigned>(axis), angle, reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__r__adj(PauliId axis, double angle, QUBIT* qubit)
    {
        __quantum__qis__r__body(axis, -angle, qubit);
    }

    void __quantum__qis__r__ctl(QirArray* ctls, QirRTuple* args)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> controls =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCR(SimId(), static_cast<unsigned>(args->pauli), args->angle, numControls, controls.data(),
            reinterpret_cast<QubitIdType>(args->target));
    }

    void __quantum__qis__r__ctladj(QirArray* ctls, QirRTuple* args)
    {
        QirRTuple updated = {args->pauli, -args->angle, args->target};
        __quantum__qis__r__ctl(ctls, &updated);
    }

    void __quantum__qis__s__body(QUBIT* qubit)
    {
        S(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__adj(QUBIT* qubit)
    {
        AdjS(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCS(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__s__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCAdjS(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__body(QUBIT* qubit)
    {
        T(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__adj(QUBIT* qubit)
    {
        AdjT(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCT(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__t__ctladj(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCAdjT(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__body(QUBIT* qubit)
    {
        X(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__x__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCX(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__body(QUBIT* qubit)
    {
        Y(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__y__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCY(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__body(QUBIT* qubit)
    {
        Z(SimId(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__z__ctl(QirArray* ctls, QUBIT* qubit)
    {
        auto numControls = __quantum__rt__array_get_size_1d(ctls);
        std::vector<unsigned> ids =
            GetQubitIds(numControls, reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(ctls, 0)));
        MCZ(SimId(), numControls, ids.data(), reinterpret_cast<QubitIdType>(qubit));
    }

    void __quantum__qis__dumpmachine__body(uint8_t* location)
    {
        std::ofstream outFileStream;
        std::ostream& outStream = GetOutStream(location, outFileStream);
        DumpMachineImpl(outStream);
    }

    void __quantum__qis__dumpregister__body(uint8_t* location, QirArray* qubits)
    {
        std::ofstream outFileStream;
        std::ostream& outStream = GetOutStream(location, outFileStream);
        DumpRegisterImpl(outStream, qubits);
    }

    void __quantum__qis__assertmeasurementprobability__body(
        QirArray* bases,
        QirArray* qubits,
        RESULT* result,
        double prob,
        QirString* msg,
        double tol)
    {
        if (__quantum__rt__array_get_size_1d(bases) != __quantum__rt__array_get_size_1d(qubits))
        {
            __quantum__rt__fail(
                __quantum__rt__string_create("Both input arrays - bases, qubits - for AssertMeasurementProbability(), "
                                             "must be of same size."));
        }

        if (__quantum__rt__result_equal(result, __quantum__rt__result_get_one()))
        {
            prob = 1.0 - prob;
        }

        // Convert paulis from sequence of bytes to sequence of PauliId:
        std::vector<PauliId> paulis((uint64_t)__quantum__rt__array_get_size_1d(bases));
        for (auto i = 0; i < __quantum__rt__array_get_size_1d(bases); ++i)
        {
            paulis[i] = (PauliId)*__quantum__rt__array_get_element_ptr_1d(bases, i);
        }

        std::vector<unsigned> ids = GetQubitIds(
            paulis.size(), reinterpret_cast<QubitIdType*>(__quantum__rt__array_get_element_ptr_1d(qubits, 0)));
        std::vector<unsigned> convertedBases = GetBases(paulis.size(), paulis.data());
        double actualProbability =
            1.0 - JointEnsembleProbability(
                      SimId(), (unsigned)paulis.size(), reinterpret_cast<int*>(convertedBases.data()), ids.data());

        if (!(std::abs(actualProbability - prob) < 1e-10))
        {
            __quantum__rt__fail(msg);
        }
    }

    void __quantum__qis__assertmeasurementprobability__ctl(
        QirArray* /* ctls */,
        QirAssertMeasurementProbabilityTuple* args)
    {
        // Controlled AssertMeasurementProbability ignores control bits. See the discussion on
        // https://github.com/microsoft/qsharp-runtime/pull/450 for more details.
        __quantum__qis__assertmeasurementprobability__body(
            args->bases, args->qubits, args->result, args->prob, args->msg, args->tol);
    }
}
