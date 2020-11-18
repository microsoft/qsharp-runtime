// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents a Quantum Bit.
    /// </summary>
    public abstract class Qubit : IApplyData, IEquatable<Qubit>, IEqualityComparer<Qubit>
    {
        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public static readonly Qubit[] NO_QUBITS = Array.Empty<Qubit>();
        
        /// <summary>
        /// Used by UDTs that extend Qubit. 
        /// Sets id to MaxValue for null qubits. 0 is typically the default qubit.id.
        /// </summary>
        public Qubit(Qubit q) : this(q?.Id ?? int.MaxValue) {}

        /// <summary>
        /// Creates a qubit with given ID
        /// </summary>
        /// <param name="id">ID of the qubit</param>
        public Qubit(int id)
        {
            this.Id = id;
        }

        public bool IsMeasured { get; set; } = false;

        public int Id { get; private set; }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public virtual object Value => this;

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        public virtual IEnumerable<Qubit> Qubits => new Qubit[] { this };

        public override bool Equals(object obj)
        {
            return this.Equals(obj as Qubit);
        }

        public bool Equals(Qubit other)
        {
            return other != null && Equals(this, other);
        }

        /// <summary>
        /// Check if two qubits have equal IDs
        /// </summary>
        /// <param name="q1">First qubit being compared</param>
        /// <param name="q2">Second qubit being compared</param>
        /// <returns>True if two qubits have equal ids</returns>
        public bool Equals(Qubit q1, Qubit q2)
        {
            if (Object.ReferenceEquals(q1, q2)) { return true; }
            if (Object.ReferenceEquals(q1, null) || Object.ReferenceEquals(q2, null)) { return false; }
            return q1.Id == q2.Id;
        }

        /// <summary>
        /// Qubits hash code based in Id
        /// </summary>
        /// <param name="q">Qubit for which hash should be computed</param>
        /// <returns></returns>
        public int GetHashCode(Qubit q)
        {
            if (Object.ReferenceEquals(q, null)) return 0;
            return q.Id.GetHashCode();
        }

        public override int GetHashCode()
        {
            return GetHashCode(this);
        }

        public static IEnumerable<Qubit> Concat(params IEnumerable<Qubit>[] containers)
        {
            return containers?.SelectMany(c => c ?? NO_QUBITS);
        }

        public override string ToString()
        {
            return $"q:{this.Id}";
        }
    }

}
