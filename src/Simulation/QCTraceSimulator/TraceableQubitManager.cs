// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Common;

    public interface ISetQubitFactory
    {
        public void SetQubitFactory(TraceableQubitFactory traceableQubitFactory);
    }


    /// <summary>
    /// Qubit manager for TraceableQubit type. Ensures that all the traceable 
    /// qubits are configured as requested during qubit manage construction.
    /// </summary>
    public class TraceableQubitManager : QubitManager, ISetQubitFactory {
        new const long NumQubits = 1024;

        TraceableQubitFactory qubitFactory = null;

        /// <summary>
        /// The qubit manager makes sure that trace data array for qubits 
        /// is initialized with objects created by qubitTraceDataInitializers callbacks
        /// </summary>
        public TraceableQubitManager(bool optimizeDepth) 
            : base(NumQubits, mayExtendCapacity : true, disableBorrowing : false, encourageReuse: !optimizeDepth)
        {
        }

        public void SetQubitFactory(TraceableQubitFactory traceableQubitFactory) {
            if (qubitFactory != null) {
                throw new ApplicationException("Cannot replace existing qubit factory.");
            }
            qubitFactory = traceableQubitFactory;
        }

        public override Qubit CreateQubitObject(long id)
        {
            return qubitFactory.CreateQubitObject(id);
        }
    }

    public class RestrictedTraceableQubitManager : QubitManagerRestrictedReuse, ISetQubitFactory {
        const long NumQubits = 1024;

        TraceableQubitFactory qubitFactory = null;

        /// <summary>
        /// The qubit manager makes sure that trace data array for qubits 
        /// is initialized with objects created by qubitTraceDataInitializers callbacks
        /// </summary>
        public RestrictedTraceableQubitManager(bool optimizeDepth)
            : base(NumQubits, mayExtendCapacity: true, disableBorrowing: false, encourageReuse: !optimizeDepth)
        {
        }

        public void SetQubitFactory(TraceableQubitFactory traceableQubitFactory) {
            if (qubitFactory != null) {
                throw new ApplicationException("Cannot replace existing qubit factory.");
            }
            qubitFactory = traceableQubitFactory;
        }

        public override Qubit CreateQubitObject(long id)
        {
            return qubitFactory.CreateQubitObject(id);
        }
    }

}
