// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Bitwise
{
    public partial class Xor
    {
        public class Native : Xor
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, long), long> Body => (arg) => (arg.Item1 ^ arg.Item2);
        }
    }

    public partial class And
    {
        public class Native : And
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, long), long> Body => (arg) => (arg.Item1 & arg.Item2);
        }
    }

    public partial class Or
    {
        public class Native : Or
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, long), long> Body => (arg) => (arg.Item1 | arg.Item2);
        }
    }

    public partial class Not
    {
        public class Native : Not
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, long> Body => (arg) => (~arg);
        }
    }

    public partial class Parity
    {
        public class Native : Parity
        {
            static long ParityFunc(long val)
            {
                // parity function using idea described at http://graphics.stanford.edu/~seander/bithacks.html#ParityMultiply
                ulong v = System.Convert.ToUInt64(val);
                v ^= v >> 1;
                v ^= v >> 2;
                v = (v & 0x1111111111111111UL) * 0x1111111111111111UL;
                return System.Convert.ToInt64((v >> 60) & 1);
            }

            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, long> Body => ParityFunc;
        }
    }

    public partial class XBits
    {
        public class Native : XBits
        {
            static long XBitsFunc(IQArray<Pauli> pauli)
            {
                if (pauli.Length > 63) { throw new ExecutionFailException("Cannot pack X bits of Pauli array longer than 63"); }
                ulong res = 0;
                for (long i = pauli.Length - 1; i >= 0; --i)
                {
                    res <<= 1;
                    if (pauli[i] == Pauli.PauliX || pauli[i] == Pauli.PauliY)
                    {
                        res |= 1;
                    }
                }
                return System.Convert.ToInt64(res);
            }

            public Native(IOperationFactory m) : base(m) { }
            public override Func<IQArray<Pauli>, long> Body => XBitsFunc;
        }
    }

    public partial class ZBits
    {
        public class Native : ZBits
        {
            static long ZBitsFunc(IQArray<Pauli> pauli)
            {
                if (pauli.Length > 63) { throw new ExecutionFailException("Cannot pack Z bits of Pauli array longer than 63"); }
                ulong res = 0;
                for (long i = pauli.Length - 1; i >= 0; --i)
                {
                    res <<= 1;
                    if (pauli[i] == Pauli.PauliZ || pauli[i] == Pauli.PauliY)
                    {
                        res |= 1;
                    }
                }
                return System.Convert.ToInt64(res);
            }

            public Native(IOperationFactory m) : base(m) { }
            public override Func<IQArray<Pauli>, long> Body => ZBitsFunc;
        }
    }
}
