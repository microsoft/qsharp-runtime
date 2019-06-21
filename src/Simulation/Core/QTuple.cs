using System;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    public interface IQTuple<out T> : IApplyData
    {
        T Data { get; }
        string ToString();
    }

    /// <summary>
    /// Generic implementation for Q# Tuples. A QTuple is the base class for tuple-based UDTs,
    /// where 'T is the corresponding base ValueTuple.
    /// </summary>
    public class QTuple<T> : IQTuple<T>
    {
        /// <summary>
        ///     Basic constructor
        /// </summary>
        /// <param name="data"></param>
        public QTuple(T data)
        {
            this.Data = data;
        }

        /// <summary>
        /// The original valueTuple
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public T Data { get; }

        /// <summary>
        /// IData implementation, returns the base tuple data.
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        object IApplyData.Value => this.Data;

        /// <summary>
        /// By default, uses a QubitsExtractor to identify the fields with Qubits.
        /// However, most QTuples will override this property as they know at compile time
        /// the Qubit fields.
        /// </summary>
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        IEnumerable<Qubit> IApplyData.Qubits => QubitsExtractor.Get(typeof(T))?.Extract(Data);

        public override bool Equals(object obj)
        {
            return this.Equals(obj as QTuple<T>);
        }

        public bool Equals(QTuple<T> other)
        {
            return other != null &&
                   EqualityComparer<T>.Default.Equals(Data, other.Data);
        }

        public override int GetHashCode()
        {
            return -604923257 + EqualityComparer<T>.Default.GetHashCode(Data);
        }

        public override string ToString() => this.Data?.ToString();
    }
}
