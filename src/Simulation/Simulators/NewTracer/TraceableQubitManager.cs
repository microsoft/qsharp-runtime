using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using static Microsoft.Quantum.Simulation.Simulators.NewTracer.TraceableQubitManager;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    public interface IQubitTraceSubscriber : ITracerTarget
    {
        object? NewTracingData(long id);
    }

    public interface IQubitTraceSubscriber<TData> : IQubitTraceSubscriber
    {
        new TData NewTracingData(long id);

        object? IQubitTraceSubscriber.NewTracingData(long id) => this.NewTracingData(id);
    }

    /// <summary>
    /// Qubit manager for TraceableQubit type. Ensures that all the traceable 
    /// qubits are configured as requested during qubit manage construction.
    /// </summary>
    internal class TraceableQubitManager : QubitManagerTrackingScope
    {
        const long NumQubits = 1024;

        private readonly IQubitTraceSubscriber[] Subscribers;

        public TraceableQubitManager(IEnumerable<IQubitTraceSubscriber>? subscribers, bool optimizeDepth)
            : base(NumQubits, mayExtendCapacity: true, disableBorrowing: false, encourageReuse: !optimizeDepth)
        {
            this.Subscribers = subscribers?.ToArray() ?? new IQubitTraceSubscriber[] { };
        }

        public override Qubit CreateQubitObject(long id)
        {
            return new TraceableQubit(this.Subscribers, (int)id);
        }

        internal class TraceableQubit : Qubit
        {
            // Objects attached to the qubit
            private readonly object?[] TraceData;

            private readonly IQubitTraceSubscriber[] Subscribers;

            internal TraceableQubit(IQubitTraceSubscriber[] subscribers, int id) : base(id)
            {
                this.Subscribers = subscribers;

                this.TraceData = new object[subscribers.Length];
                for (int i = 0; i < subscribers.Length; i++)
                {
                    TraceData[i] = subscribers[i].NewTracingData(id);
                }
            }

            internal TData ExtractData<TData>(IQubitTraceSubscriber<TData> subscriber)
            {
                int subIndex = GetSubscriberIndex(subscriber);
                #pragma warning disable CS8603 // Possible null reference return.
                return (TData)TraceData[subIndex];
            }

            internal void SetData<TData>(IQubitTraceSubscriber<TData> subscriber, TData value)
            {
                int subIndex = GetSubscriberIndex(subscriber);
                this.TraceData[subIndex] = value;
            }

            private int GetSubscriberIndex(IQubitTraceSubscriber subscriber)
            {
                for (int i = 0; i < Subscribers.Length; i++)
                {
                    if (Object.ReferenceEquals(Subscribers[i], subscriber))
                    { return i; }
                }
                throw new ArgumentException("Provided subscriber not registered.");
            }
        }
    }

    public static class QubitTracingExtensions
    {
        public static TData ExtractQubitData<TData>(this IQubitTraceSubscriber<TData> sub, Qubit q)
        {
            return ((TraceableQubit)q).ExtractData(sub);
        }

        public static void SetQubitData<TData>(this IQubitTraceSubscriber<TData> sub, Qubit q, TData value)
        {
            ((TraceableQubit)q).SetData(sub, value);
        }
    }
}