using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    /// <summary>
    /// TraceableQubit holds data associated with a qubit 
    /// for runtime checks, metrics collection and measurement constraints tracking.
    /// Used by <see cref="TraceableQubitManager"/>
    /// </summary>
    public class TraceableQubit : Qubit
    {
        /// <summary>
        /// Objects attached to the qubit
        /// </summary>
        private readonly object[] TraceData;

        private readonly TraceableQubitManager QubitManagerPtr;

        internal TraceableQubit(TraceableQubitManager managerPtr, int id, object[] traceData) : base(id)
        {
            this.QubitManagerPtr = managerPtr;
            this.TraceData = traceData;
        }

        public object ExtractData(IQubitTraceSubscriber subscriber)
        {
            return TraceData[QubitManagerPtr.GetSubscriberIndex(subscriber)];
        }

        public void SetData(IQubitTraceSubscriber subscriber, object value)
        {
            TraceData[QubitManagerPtr.GetSubscriberIndex(subscriber)] = value;
        }
    }

    public interface IQubitTraceSubscriber
    {
        object NewTracingData(long id);
    }

    /// <summary>
    /// Qubit manager for TraceableQubit type. Ensures that all the traceable 
    /// qubits are configured as requested during qubit manage construction.
    /// </summary>
    internal class TraceableQubitManager : QubitManagerTrackingScope
    {
        const long NumQubits = 1024;

        private readonly IQubitTraceSubscriber[] Subscribers;

        /// <summary>
        /// The qubit manager makes sure that trace data array for qubits 
        /// is initialized with objects created by qubitTraceDataInitializers callbacks
        /// </summary>
        public TraceableQubitManager(IList<IQubitTraceSubscriber> subscribers)
            : base(NumQubits, mayExtendCapacity: true, disableBorrowing: false)
        {
            this.Subscribers = subscribers?.ToArray() ?? new IQubitTraceSubscriber[] { };
        }

        public override Qubit CreateQubitObject(long id)
        {
            object[] traceData = new object[Subscribers.Length];
            for (int i = 0; i < traceData.Length; i++)
            {
                traceData[i] = Subscribers[i].NewTracingData(id);
            }
            return new TraceableQubit(this, (int)id, traceData);
        }

        public int GetSubscriberIndex(IQubitTraceSubscriber subscriber)
        {
            for (int i = 0; i < Subscribers.Length; i++)
            {
                if (Subscribers[i] == subscriber)
                { return i; }
            }
            throw new ArgumentException("Provided subscriber not registered.");
        }
    }
}
