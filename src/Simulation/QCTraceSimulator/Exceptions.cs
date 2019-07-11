// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators
{
    /// <summary>
    /// This exception is thrown when the input to an 
    /// operation contains multiple qubits with the same ID.
    /// </summary>
    public class DistinctInputsCheckerException : System.Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="DistinctInputsCheckerException"/>
        /// </summary>
        public DistinctInputsCheckerException() : 
            base("Non distinct inputs to the operation.")
        {
        }
    }

    /// <summary>
    /// This exception is thrown when a qubit input to the operation has already been released or returned. 
    /// Qubits are released at the end of a Q# <c>using</c> statement
    /// and returned at the end of a Q# <c>borrowing</c> statement.
    /// </summary>
    public class InvalidatedQubitsUseCheckerException : System.Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="InvalidatedQubitsUseCheckerException"/>
        /// </summary>
        public InvalidatedQubitsUseCheckerException() : 
            base("Attempt to use released(deallocated) or returned qubit.")
        {
        }
    }

    /// <summary>
    /// This exception is thrown when inconsistencies in the recording of qubit metrics are detected.
    /// </summary>
    public class QubitTimeMetricsException : System.Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="QubitTimeMetricsException"/>
        /// </summary>
        public QubitTimeMetricsException() : 
            base("Trying to record an inconsistent time metric")
        {
        }
    }

    /// <summary>
    /// This exception is thrown when a measurement is performed, but has not been annotated using
    /// a call to either <c>Microsoft.Quantum.Intrinsic.AssertProb</c> or
    /// <c>Microsoft.Quantum.Intrinsic.Assert</c>.
    /// </summary>
    public class UnconstrainedMeasurementException : System.Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="UnconstrainedMeasurementException"/>
        /// </summary>
        public UnconstrainedMeasurementException() : 
            base("Unconstrained measurement outcome")
        {
        }
    }

}