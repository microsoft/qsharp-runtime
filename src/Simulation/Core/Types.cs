// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

/// <summary>
/// The types used to represent Q# type in the generated C# code.
/// </summary>
namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents the Result of a Measurement. Corresponds to Q# type <code>Result</code>.
    /// </summary>
    [Serializable]
    public enum Result
    {
        /// <summary>
        /// Corresponds to measuring +1 eigenstate of an observable or 
        /// measuring |0⟩ in computational basis.
        /// Represents Q# <code>Zero</code> constant.
        /// </summary>
        Zero,
        /// <summary>
        /// Corresponds to measuring -1 eigenstate of an observable or 
        /// measuring |1⟩ in computational basis.
        /// Represents Q# <code>One</code> constant.
        /// </summary>
        One
    }

    /// <summary>
    /// Represents single-qubit Pauli operator.
    /// Corresponds to Q# type <code>Pauli</code>.
    /// </summary>
    [Serializable]
    public enum Pauli
    {
        /// <summary>
        /// Pauli Identity operator. Corresponds to Q# constant <code>PauliI</code>.
        /// </summary>
        PauliI = 0,
        /// <summary>
        /// Pauli X operator. Corresponds to Q# constant <code>PauliX</code>.
        /// </summary>
        PauliX = 1,
        /// <summary>
        /// Pauli Y operator. Corresponds to Q# constant <code>PauliY</code>.
        /// </summary>
        PauliY = 3,
        /// <summary>
        /// Pauli Z operator. Corresponds to Q# constant <code>PauliZ</code>.
        /// </summary>
        PauliZ = 2
    }

    /// <summary>
    /// Exception thrown when the "fail" statement is reached in a Q# file.
    /// </summary>
    public class ExecutionFailException : Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="ExecutionFailException"/>.
        /// </summary>
        /// <param name="message">String that is a part of  Q# fail statement</param>
        public ExecutionFailException(string message) : base(message) { }
    }
}
