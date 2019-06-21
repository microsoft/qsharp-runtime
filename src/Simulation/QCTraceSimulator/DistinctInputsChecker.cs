// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Used by <see cref="DistinctInputsChecker"/>.
    /// </summary>
    [Serializable]
    public class DistinctInputsCheckerConfiguration
    {
        /// <summary>
        /// If set to true, <see cref="DistinctInputsCheckerException"/> will be thrown every time non-distinct input qubits are detected.
        /// </summary>
        public bool ThrowOnNonDistinctQubits = true;

        /// <summary>
        /// Operations for which distinct inputs check should not be performed.
        /// There are potentially cases when one might need to disable this check, but we expect them to be extremely rare.
        /// </summary>
        public HashSet<string> OperationsToIgnore = null; 
    }

    /// <summary>
    /// Used by <see cref="DistinctInputsChecker"/>.
    /// </summary>
    [Serializable]
    public class DistinctInputsCheckerResults
    {
        /// <summary>
        /// Number of times non-distinct inputs to the operation were detected
        /// </summary>
        public uint nonDistinctInputsEventTotalCount = 0;
    }

    /// <summary>
    /// <see cref="QCTraceSimulatorCore"/> listener that checks that qubits passed to operations are distinct.
    /// TODO: reference the section of the spec discussing the ramifications of passing non-distinct qubits to operations.
    /// </summary>
    public class DistinctInputsChecker : IQCTraceSimulatorListener
    {
        public uint NonDistinctInputsEventTotalCount { get => results.nonDistinctInputsEventTotalCount; }
        protected Action OnNonDistinctQubitIds { get; set; }

        private readonly DistinctInputsCheckerConfiguration configuration;
        private readonly DistinctInputsCheckerResults results;
        DistinctInputsCheckerConfiguration GetConfigurationCopy() { return Utils.DeepClone(configuration); }
        DistinctInputsCheckerResults GetResultsCopy() { return Utils.DeepClone(results); }

        Stack<bool> operationToIgnoreStack;

        class DistinctInputsCheckerData : IComparable<DistinctInputsCheckerData>
        {
            public DistinctInputsCheckerData( long id )
            {
                qubitId = id;
            }
            public long qubitId;

            public int CompareTo(DistinctInputsCheckerData other)
            {
                return qubitId.CompareTo(other.qubitId);
            }
        }

        public DistinctInputsChecker() : this( new DistinctInputsCheckerConfiguration() ) {}

        public DistinctInputsChecker( DistinctInputsCheckerConfiguration config  )
        {
            operationToIgnoreStack = new Stack<bool>();
            OnNonDistinctQubitIds += OnNonDistinctQubitIdsDefault;
            configuration = Utils.DeepClone(config);
            results = new DistinctInputsCheckerResults();
        }

        /// <summary>
        /// Check if the id's of qubits contained in qubitsTraceData are all distinct. 
        /// </summary>
        private void DistinctQubitsCheck(object[] qubitsTraceData)
        {
            Debug.Assert(qubitsTraceData != null);

            if (qubitsTraceData.Length == 0 || qubitsTraceData.Length == 1)
            {
                return;
            }

            DistinctInputsCheckerData[] ids = Utils.UnboxAs<DistinctInputsCheckerData>(qubitsTraceData);
            HashSet<long> uniqueIds = new HashSet<long>();
            foreach (DistinctInputsCheckerData id in ids)
            {
                if (!uniqueIds.Add(id.qubitId))
                {
                    OnNonDistinctQubitIds();
                }
            }
        }

        private void OnNonDistinctQubitIdsDefault()
        {
            results.nonDistinctInputsEventTotalCount++;
            if (configuration.ThrowOnNonDistinctQubits)
            {
                throw new DistinctInputsCheckerException();
            }
        }

        #region ITracingSimulatorListener implementation

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public object NewTracingData(long qubitId)
        {
            return new DistinctInputsCheckerData(qubitId);
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
            if(returnedQubitsTraceData != null)
            {
                if (!operationToIgnoreStack.Peek())
                {
                    DistinctQubitsCheck(returnedQubitsTraceData);
                }
            }
            operationToIgnoreStack.Pop();
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData)
        {
            bool ignore = configuration.OperationsToIgnore?.Contains(name) ?? false;
            operationToIgnoreStack.Push(ignore);
            if ( !ignore )
            {
                DistinctQubitsCheck(qubitsTraceData);
            }
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration)
        {
            if (!operationToIgnoreStack.Peek())
            {
                DistinctQubitsCheck(qubitsTraceData);
            }
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnRelease(object[] qubitsTraceData)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public void OnReturn(object[] qubitsTraceData, long qubitReleased)
        {
        }

        /// <summary>
        /// Part of implementation of <see cref="IQCTraceSimulatorListener"/> interface. See the interface documentation for more details.
        /// </summary>
        public bool NeedsTracingDataInQubits => true;
        #endregion
    }
}
