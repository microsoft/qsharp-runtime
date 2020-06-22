// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    //TODO: what is a good naming scheme to distinguish between this type of edge and the other CallGraphEdge?

    /// <summary>
    /// A <see cref="CallGraphTreeEdge"/> refers to a call from one specialization to another within
    /// a call graph. There can be multiple invocations of the same <see cref="CallGraphTreeEdge"/>; If the
    /// same node (same path in graph from root to the operation within a call graph invokes
    /// another node multiple times, then those are invocations of the same <see cref="CallGraphTreeEdge"/>.
    /// <see cref="CallGraphTreeEdge"/>'s in turn can have children: <see cref="CallGraphTreeEdge"/>'s that were ever
    /// invoked from the current <see cref="CallGraphTreeEdge"/>.
    /// </summary>
    public class CallGraphTreeEdge : ICSVColumns
    {
        public readonly HashedString OperationName;

        public readonly OperationFunctor FunctorSpecialization;

        public readonly CallGraphTreeEdge ParentEdge;

        public readonly int Id;

        public int NumInvocations { get; private set; }

        private readonly List<CallGraphTreeEdge> Children;

        public CallGraphTreeEdge()
        {
            //statistics collector needs a blank constructor for some reason? //TODO: investigate
            throw new InvalidOperationException();
        }

        private CallGraphTreeEdge(CallGraphTreeEdge parent, HashedString operation, OperationFunctor functor, int id)
        {
            this.ParentEdge = parent;
            this.OperationName = operation ?? throw new ArgumentNullException(nameof(operation));
            this.FunctorSpecialization = functor;
            this.Id = id;
            this.NumInvocations = 1;
            this.Children = new List<CallGraphTreeEdge>();
        }


        /// <summary>
        /// Adds an invocation to the given operation as a child <see cref="CallGraphTreeEdge"/> of this <see cref="CallGraphTreeEdge"/> 
        /// (or increments its <see cref="NumInvocations"/> if such an edge already exists), and returns the new child.
        /// </summary>
        /// <returns>The new <see cref="CallGraphEdge"/>.</returns>
        public CallGraphTreeEdge AddCallTo(HashedString operation, OperationFunctor functor, int id)
        {
            for (int i = 0; i < Children.Count; i++)
            {
                if (Children[i].OperationName.Equals(operation) && Children[i].FunctorSpecialization == functor)
                {
                    CallGraphTreeEdge child = Children[i];
                    child.NumInvocations++;
                    return child;
                }
            }

            CallGraphTreeEdge builtChild = new CallGraphTreeEdge(this, operation, functor, id);
            Children.Add(builtChild);
            return builtChild;
        }

        public IReadOnlyList<CallGraphTreeEdge> GetChildren()
        {
            return Children;
        }

        public CallGraphEdge ToCallGraphEdge()
        {
            return new CallGraphEdge(OperationName, ParentEdge?.OperationName,
                FunctorSpecialization, ParentEdge?.FunctorSpecialization ?? OperationFunctor.Body);
        }

        public override bool Equals(Object obj)
        {
            return obj is CallGraphTreeEdge edge
                && this.Id == edge.Id;
        }

        public override int GetHashCode()
        {
            return this.Id;
        }

        /// <summary>
        /// Call graph root is a parentless edge with Id -1 calling <see cref="CallGraphEdge.CallGraphRoot"/>.
        /// </summary>
        /// <returns></returns>
        public static CallGraphTreeEdge MakeRoot()
        {
            return new CallGraphTreeEdge(null, CallGraphEdge.CallGraphRootHashed, OperationFunctor.Body, -1);
        }

        #region ICSVColumns implementation (should really only be used for debugging purposes)

        public string[] GetColumnNames()
        {
            return new string[] { "EdgeId", "Operation", "Variant" };
        }

        public string[] GetRow()
        {
            return new string[] { Id.ToString(), OperationName, FunctorSpecialization.ToString() };
        }

        public int Count => 3;

        #endregion
    }
}
