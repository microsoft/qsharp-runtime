// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    open Microsoft.Quantum.Intrinsic;

    // Used as extensibility mechanism to add custom operations. 
    // The custom operation may use only some of the parameters. Depending on the nature of the operation, all of them may be optional. 
    // A variety of parameter types are provided for flexibility:
    //   operationId: The id of the custom operation. It is up to the custom operation implementor to define the meaning.
    //   qubits: Array of qubits to apply the operation to. Their meaning is specific to the custom operation.
    //   paulis: Array of single-qubit Pauli values. Their meaning is specific to the custom operation.
    //   longs: Array of long parameters. Their meaning is specific to the custom operation.
    //   doubles: Array of double parameters. Their meaning is specific to the custom operation.
    //   bools: Array of bool parameters. Their meaning is specific to the custom operation.
    //   results: Array of Result parameters. Their meaning is specific to the custom operation.
    //   strings: Array of string parameters. Their meaning is specific to the custom operation.
    operation ApplyCustomOperation(operationId : Int, qubits : Qubit[], paulis : Pauli[], longs : Int[], doubles : Double[], bools : Bool[], results : Result[], strings : String[]) : Unit is Ctl {
        body intrinsic;
        controlled intrinsic;
    }

}
