using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    [Serializable]
    public class CallGraphEdge : ICSVColumns
    {
        private readonly int hashCode;

        public CallGraphEdge(
            HashedString operationName,
            HashedString operationCallerName,
            OperationFunctor functorSpecialization,
            OperationFunctor callerFunctorSpecialization)
        {
            OperationName = operationName;
            OperationCallerName = operationCallerName;
            FunctorSpecialization = functorSpecialization;
            CallerFunctorSpecialization = callerFunctorSpecialization;
            hashCode = InternalHashCode();
        }

        public CallGraphEdge(HashedString operationName, OperationFunctor operationVariant )
            : this(operationName, CallGraphRootHashed, operationVariant, OperationFunctor.Body)
        {

        }

        public CallGraphEdge() : this( (HashedString)"", (HashedString)"", OperationFunctor.Body, OperationFunctor.Body)
        {
        }

        /// <summary>
        /// Name of the root element of the call graph. OperationCallerName
        /// must be equal to this value for all top-level operations.
        /// </summary>
        public const string CallGraphRoot = "[[root]]";
        public static readonly HashedString CallGraphRootHashed = new HashedString(CallGraphRoot);

        public HashedString OperationName { get; private set; }
        public HashedString OperationCallerName { get; private set; }
        public OperationFunctor FunctorSpecialization { get; private set; }
        public OperationFunctor CallerFunctorSpecialization { get; private set; }

        public override bool Equals(object obj)
        {
            var edge = obj as CallGraphEdge;
            return edge != null &&
                   OperationName.Equals(edge.OperationName) &&
                   OperationCallerName.Equals(edge.OperationCallerName) &&
                   FunctorSpecialization == edge.FunctorSpecialization &&
                   CallerFunctorSpecialization == edge.CallerFunctorSpecialization;
        }

        private int InternalHashCode()
        {
            var hashCode = 419446955;
            const int hashSeed = -1521134295;
            hashCode = hashCode * hashSeed + OperationName.GetHashCode();
            hashCode = hashCode * hashSeed + OperationCallerName.GetHashCode();
            hashCode = hashCode * hashSeed + EqualityComparer<OperationFunctor>.Default.GetHashCode(FunctorSpecialization);
            hashCode = hashCode * hashSeed + EqualityComparer<OperationFunctor>.Default.GetHashCode(CallerFunctorSpecialization);
            return hashCode;
        }

        public override int GetHashCode()
        {
            return hashCode;
        }

        public string[] GetColumnNames()
        {
            return new string[] { "Name", "Variant", "Caller", "CallerVariant" };
        }

        public string[] GetRow()
        {
            return new string[] { OperationName, FunctorSpecialization.ToString() , OperationCallerName, CallerFunctorSpecialization.ToString() };
        }

        public int Count => 2;
    }
}
