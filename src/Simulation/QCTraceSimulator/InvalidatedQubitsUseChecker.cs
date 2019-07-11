// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Used by <see cref="InvalidatedQubitsUseChecker"/>. 
    /// See the <see cref="InvalidatedQubitsUseChecker"/> for the definition of invalidated qubit.
    /// </summary>
    [Serializable]
    public class InvalidatedQubitsUseCheckerConfiguration
    {
        /// <summary>
        /// If set to true, the <see cref="InvalidatedQubitsUseCheckerException"/> is thrown.
        /// Otherwise total number of non-distinct qubit inputs is collected.
        /// </summary>
        public bool ThrowOnInvalidatedQubitUse = true;
    }

    /// <summary>
    /// Used by <see cref="InvalidatedQubitsUseChecker"/>. 
    /// See the <see cref="InvalidatedQubitsUseChecker"/> for the definition of invalidated qubit.
    /// </summary>
    [Serializable]
    public class InvalidatedQubitsUseCheckerResults
    {
        /// <summary>
        /// Number of efforts to use invalidated qubits that has been detected.
        /// See the <see cref="InvalidatedQubitsUseChecker"/> for the definition of invalidated qubit.
        /// </summary>
        public int InvalidatedQubitsUseCount = 0;
    }

    /// <summary>
    /// Checks if the qubits input to the operation has been invalidated.
    /// Qubits are invalidated when they are returned or released. 
    /// Qubits are released in the end of using block and returned in the end of borrowing block.
    /// </summary>
    public class InvalidatedQubitsUseChecker : IQCTraceSimulatorListener
    {
        public int InvalidatedQubitsUseCount { get => results.InvalidatedQubitsUseCount ; }
        protected Action OnInvalidatedQubitsUse { get; set; }

        private readonly InvalidatedQubitsUseCheckerConfiguration configuration;
        private readonly InvalidatedQubitsUseCheckerResults results;
        InvalidatedQubitsUseCheckerConfiguration GetConfigurationCopy() { return Utils.DeepClone(configuration); }
        InvalidatedQubitsUseCheckerResults GetResultsCopy() { return Utils.DeepClone(results); }


        public InvalidatedQubitsUseChecker() : this( new InvalidatedQubitsUseCheckerConfiguration() )
        {
        }

        public InvalidatedQubitsUseChecker(InvalidatedQubitsUseCheckerConfiguration config )
        {
            OnInvalidatedQubitsUse += OnInvalidatedQubitsUseDefault;
            configuration = Utils.DeepClone(config);
            results = new InvalidatedQubitsUseCheckerResults();
        }

        private enum QubitStatus
        {
            Active,
            Invalidated 
        }

        private class QubitState
        {
            public QubitStatus status = QubitStatus.Active;
        }

        private void OnInvalidatedQubitsUseDefault()
        {
            results.InvalidatedQubitsUseCount++;
            if ( configuration.ThrowOnInvalidatedQubitUse )
            {
                throw new InvalidatedQubitsUseCheckerException();
            }
        }

        private void CheckForInvalidatedQubits(object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);
            QubitState[] qss = Utils.UnboxAs<QubitState>(qubitsTraceData);
            foreach( QubitState qs in qss )
            {
                if( qs.status == QubitStatus.Invalidated )
                {
                    OnInvalidatedQubitsUse();
                    return;
                }
            }
        }

        private void InvalidateQubits(object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);
            QubitState[] qss = Utils.UnboxAs<QubitState>(qubitsTraceData);
            foreach (QubitState qs in qss)
            {
                qs.status = QubitStatus.Invalidated;
            }
        }

        #region ITracingSimulatorListener implementation
        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public object NewTracingData(long qubitId)
        {
            return new QubitState();
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnAllocate(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationEnd(object[] returnedQubitsTraceData)
        {
            if (returnedQubitsTraceData != null)
            {
                CheckForInvalidatedQubits(returnedQubitsTraceData);
            }
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationStart(HashedString name, OperationFunctor variant,  object[] qubitsTraceData)
        {
            CheckForInvalidatedQubits(qubitsTraceData);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            CheckForInvalidatedQubits(qubitsTraceData);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnRelease(object[] qubitsTraceData)
        {
            InvalidateQubits(qubitsTraceData);
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnReturn(object[] qubitsTraceData, long newQubitsAllocated)
        {
            InvalidateQubits(qubitsTraceData);
        }


        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion 
    }
}
