using NewTracer.CallGraph;
using Newtonsoft.Json;
using System;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using System.Linq;
using System.Collections;
using System.Collections.Generic;

namespace NewTracer
{
    /// <summary>
    /// An <see cref="AggregateInvocation"/> describes an operation X calling an operation Y, but does not contain
    /// any additional information. Unlike a <see cref="CallGraphEdge"/>, it does not refer to a 
    /// particular edge within a call graph.
    /// </summary>
    public class AggregateInvocation : ICSVColumns
    {
        public readonly OPSpecialization Caller;

        public readonly OPSpecialization Callee;

        public AggregateInvocation(OPSpecialization callee, OPSpecialization caller)
        {
            Caller = caller ?? throw new ArgumentNullException(nameof(caller));
            Callee = callee ?? throw new ArgumentNullException(nameof(callee));
        }

        public override string ToString()
        {
            return $"{Caller} -> {Callee}";
        }

        public bool IsRootCall => this.Caller.IsRoot;


        public bool ContainsWildcard => this.Caller.IsAll || this.Callee.IsAll;

        #region ICSVColumns implementation

        int ICSVColumns.Count => this.Callee.Count + this.Caller.Count;

        public string[] GetColumnNames()
        {
            IEnumerable<string> callerHeaders = this.Caller.GetColumnNames()
                .Select((string header) => $"Caller{header}"); //prefxing caller headers with "Caller"

            return this.Callee.GetColumnNames().Concat(callerHeaders).ToArray();
        }

        public string[] GetRow()
        {
            return this.Callee.GetRow().Concat(this.Caller.GetRow()).ToArray();
        }

        #endregion

        #region Equality implementation

        public override bool Equals(Object obj)
        {
            return obj is AggregateInvocation inv
               && this.Caller.Equals(inv.Caller)
               && this.Callee.Equals(inv.Callee);
        }

        public override int GetHashCode()
        {
            return -Caller.GetHashCode() ^ Callee.GetHashCode();
        }

        public static bool operator !=(AggregateInvocation x, AggregateInvocation y)
        {
            return !(x == y);
        }

        public static bool operator ==(AggregateInvocation x, AggregateInvocation y)
        {
            if (x is null)
            {
                return y is null;
            }
            else
            {
                return x.Equals(y);
            }
        }

        #endregion

        // Used to mean a global aggregate
        public static readonly AggregateInvocation ROOT_AGGREGATE = new AggregateInvocation(OPSpecialization.ROOT, OPSpecialization.ALL);
    }
}
