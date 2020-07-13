using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.CallGraph
{
    /// <summary>
    /// A <see cref="CallGraphEdge"/> refers to a call from one specialization to another within
    /// a call graph. There can be multiple invocations of the same <see cref="CallGraphEdge"/>; If the
    /// same node (same path in graph from root to the operation within a call graph invokes
    /// another node multiple times, then those are invocations of the same <see cref="CallGraphEdge"/>.
    /// <see cref="CallGraphEdge"/>'s in turn can have children: <see cref="CallGraphEdge"/>'s that were ever
    /// invoked from the current <see cref="CallGraphEdge"/>.
    /// </summary>
    public class CallGraphEdge
    {
        public readonly OPSpecialization Operation;

        public readonly CallGraphEdge ParentEdge;

        public readonly int Id;

        public int NumInvocations { get; private set; }

        private readonly List<CallGraphEdge> Children;

        private CallGraphEdge(CallGraphEdge parent, OPSpecialization operation, int id)
        {
            this.ParentEdge = parent;
            this.Operation = operation ?? throw new ArgumentNullException(nameof(operation));
            this.Id = id;
            this.NumInvocations = 1;
            this.Children = new List<CallGraphEdge>();
        }


        /// <summary>
        /// Adds an invocation to the given operation as a child <see cref="CallGraphEdge"/> of this <see cref="CallGraphEdge"/> 
        /// (or increments its <see cref="NumInvocations"/> if such an edge already exists), and returns the new child.
        /// </summary>
        /// <returns>The new <see cref="CallGraphEdge"/>.</returns>
        internal CallGraphEdge AddCallTo(OPSpecialization operation, int id)
        {
            for (int i = 0; i < Children.Count; i++)
            {
                if (Children[i].Operation.Equals(operation))
                {
                    CallGraphEdge child = Children[i];
                    child.NumInvocations++;
                    return child;
                }
            }

            CallGraphEdge builtChild = new CallGraphEdge(this, operation, id);
            Children.Add(builtChild);
            return builtChild;
        }

        public CallGraphEdge Clone(CallGraphEdge clonedParent)
        {
            CallGraphEdge result = new CallGraphEdge(clonedParent, Operation, Id);
            result.NumInvocations = this.NumInvocations;
            result.Children.AddRange(this.Children.Select((CallGraphEdge child) => child.Clone(result)));
            return result;
        }

        public IReadOnlyList<CallGraphEdge> GetChildren()
        {
            return Children;
        }

        public override bool Equals(Object obj)
        {
            return obj is CallGraphEdge edge
                && this.Id == edge.Id;
        }

        public override int GetHashCode()
        {
            return this.Id;
        }

        public override string ToString()
        {
            return this.Operation.ToString();
        }

        /// <summary>
        /// Call graph root is a parentless edge with Id -1 calling <see cref="CallGraphEdge.CallGraphRoot"/>.
        /// </summary>
        /// <returns></returns>
        public static CallGraphEdge MakeRoot()
        {
            return new CallGraphEdge(null, OPSpecialization.ROOT, -1);
        }
    }
}
