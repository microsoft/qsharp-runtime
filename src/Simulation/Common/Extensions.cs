// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;
using System.Linq;

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation
{

    public static partial class Extensions
    {
        /// <summary>
        /// Returns the ids of a qubit array as a uint[]
        /// </summary>
        public static uint[] GetIds(this IQArray<Qubit> qubits)
        {
            Debug.Assert(qubits != null, "Can't get Ids from a null array of qubits");
            if (qubits == null) { return new uint[0]; }

            return (from q in qubits where q != null select (uint)q.Id).ToArray();
        }

        /// <summary>
        ///  Automatically identifies and registers a Type's BuiltIn operations. 
        ///  It recursively checks on this and its BaseType for all NestedTypes that are
        ///  a subclass of T and registers as the override of the BaseType 
        ///  it implements.
        /// </summary>
        public static void InitBuiltinOperations<T>(this AbstractFactory<T> factory, Type t)
        {
            if (t == null)
            {
                return;
            }

            InitBuiltinOperations(factory, t.BaseType);

            var ops =
                from op in t.GetNestedTypes()
                where op.IsSubclassOf(typeof(T))
                select op;

            foreach (var op in ops)
            {
                factory.Register(op.BaseType, op);
            }
        }
    }
}
