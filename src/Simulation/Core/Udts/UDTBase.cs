// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Base class for all Q# user-defined types (UDT). Provides unwrapping and integration with debugger.
    /// </summary>
    [DebuggerTypeProxy(typeof(UDTBase<>.DebuggerProxy))]
    public class UDTBase<T> : QTuple<T>, IApplyData
    {
        public UDTBase(T t) : base(t) { }

        [DebuggerBrowsable(DebuggerBrowsableState.Never)]
        IEnumerable<Qubit> IApplyData.Qubits => ((IApplyData)Data)?.Qubits;

        public override string ToString() => $"{this.GetType().Name}({this.Data})";


        internal class DebuggerProxy
        {
            private UDTBase<T> u;

            DebuggerProxy(UDTBase<T> udt)
            {
                this.u = udt;
            }

            public T Base => u.Data;
        }
    }
}
