// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    open Microsoft.Quantum.Intrinsic;

    operation Gate(gateId : Int, qubits : Qubit[], paulis : Pauli[], longs : Int[], doubles : Double[], bools : Bool[], results : Result[], strings : String[]) : Unit is Ctl {
        body intrinsic;
        controlled intrinsic;
    }

}
