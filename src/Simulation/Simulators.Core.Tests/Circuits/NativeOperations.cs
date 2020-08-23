// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Xunit;

namespace NativeOperations
{
    // An intrinsic operation can specify its built-in Native implementation:
    public partial class IntrinsicBody
    {
        public static string RESULT = "from native body";

        // Make sure it works with other inner Types:
        public class Other { }

        public class Native : IntrinsicBody
        {
            public Native(IOperationFactory m) : base(m) { }

            public override Func<QVoid, String> Body => (arg) =>
            {
                return RESULT;
            };
        }
    }

    // An operation can have a body, and only Emulate for specific simulators:
    public partial class DefaultBody
    {
        public class Native : DefaultBody
        {
            public Native(IOperationFactory m) : base(m) { }

            public override Func<QVoid, String> Body => (arg) =>
            {
                if (this.Factory is QuantumSimulator)
                {
                    return "Simulator";
                }
                else if (this.Factory is ToffoliSimulator)
                {
                    return "Toffoli";
                }

                return base.Body(arg);
            };
        }
    }

    // Same rules apply to Generic operations:
    public partial class IntrinsicBodyGeneric<__T__>
    {
        // This one should not be used. It extends the Q# operation but has more generic type parameters
        public class Other1<O> : IntrinsicBodyGeneric<__T__>
        {
            public Other1(IOperationFactory m) : base(m) { }

            public override Func<__T__, string> Body => throw new NotImplementedException();
        }

        // This one should not be used, it has the same number of Type parameters,
        // but does not extend the actual Q# operation:
        public class Other2<O> { }

        // This one should be used:
        public class Emulation : IntrinsicBodyGeneric<__T__>
        {
            public Emulation(IOperationFactory m) : base(m) { }

            public override Func<__T__, string> Body => (arg) =>
            {
                if (arg is string s)
                {
                    return IntrinsicBody.RESULT;
                }
                else
                {
                    return arg.ToString();
                }
            };
        }
    }

    // Make sure we can also call the body of a non-intrinsic generic
    public partial class DefaultBodyGeneric<__T__>
    {
        // This one should be used:
        public class Emulation : DefaultBodyGeneric<__T__>
        {
            public Emulation(IOperationFactory m) : base(m) { }

            public override Func<__T__, __T__> Body => (arg) =>
            {
                if (arg is string s)
                {
                    return (__T__)(object)IntrinsicBody.RESULT;
                }
                else
                {
                    return base.Body(arg);
                }
            };
        }
    }
}