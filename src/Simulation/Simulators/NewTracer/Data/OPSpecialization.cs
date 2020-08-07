using Microsoft.Quantum.Simulation.Core;
using System;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.CallGraph
{
    //TODO: track similar construct in qs-compiler and switch over if appropriate
    public class OPSpecialization : ICSVColumns
    {
        public readonly string FullName;

        public readonly OperationFunctor Variant;

        // Pre-computed hashcode to squeeze out performance.
        private int HashCode;

        public OPSpecialization(string fullName, OperationFunctor variant = OperationFunctor.Body)
        {
            this.FullName = fullName ?? throw new ArgumentNullException(nameof(fullName));
            this.Variant = variant;
            //TODO: does this work?
            this.HashCode = FullName.GetHashCode() ^ Variant.GetHashCode();
        }
        public bool IsRoot => this.FullName == ROOT.FullName;

        public bool IsAll => this.FullName == ALL.FullName;


        public override string ToString()
        {
            return $"{FullName}:{Variant}";
        }

        #region ICSVColumns implementation

        public int Count => 2;

        public string[] GetColumnNames()
        {
            return new string[] { "Name", "Variant" };
        }

        public string[] GetRow()
        {
            return new string[] { FullName, Variant.ToString() };
        }

        #endregion

        #region EqualityImplementation

        public override bool Equals(Object obj)
        {
            return obj is OPSpecialization op
                && this.FullName == op.FullName
                && this.Variant == op.Variant;
        }

        public override int GetHashCode()
        {
            return this.HashCode;
        }

        public static bool operator !=(OPSpecialization x, OPSpecialization y)
        {
            return !(x == y);
        }


        public static bool operator ==(OPSpecialization x, OPSpecialization y)
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


        public static OPSpecialization FromCallable(ICallable callable)
        {
            return new OPSpecialization(callable.FullName, callable.Variant);
        }


        // Used to refer to the root in a call graph
        public static readonly OPSpecialization ROOT = new OPSpecialization("[[root]]");

        // Used as a wildcard to refer to all operations where one is usually expected
        public static readonly OPSpecialization ALL = new OPSpecialization("[[all]]");
    }
}
