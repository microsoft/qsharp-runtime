// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Math
{
    public partial class ArcCos
    {
        public class Native : ArcCos
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Acos;
        }
    }

    public partial class ArcSin
    {
        public class Native : ArcSin
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Asin;
        }
    }

    public partial class ArcTan
    {
        public class Native : ArcTan
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Atan;
        }
    }


    public partial class ArcTan2
    {
        public class Native : ArcTan2
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> __Body__ => (args) => System.Math.Atan2(args.Item1, args.Item2);
        }
    }

    public partial class Cos
    {
        public class Native : Cos
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Cos;
        }
    }

    public partial class Cosh
    {
        public class Native : Cosh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Cosh;
        }
    }

    public partial class DivRemL
    {
        public class Native : DivRemL
        {
            public Native(IOperationFactory m) : base(m) { }

            private static (BigInteger, BigInteger) Impl((BigInteger, BigInteger) arg)
            {
                BigInteger rem;
                var div = BigInteger.DivRem(arg.Item1, arg.Item2, out rem);
                return (div, rem);
            }
            public override Func<(BigInteger, BigInteger), (BigInteger, BigInteger)> __Body__ => Impl;
        }
    }

    public partial class ExpD
    {
        public class Native : ExpD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Exp;
        }
    }
    public partial class IEEERemainder
    {
        public class Native : IEEERemainder
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> __Body__ => (arg) => System.Math.IEEERemainder(arg.Item1, arg.Item2);
        }
    }

    public partial class Log
    {
        public class Native : Log
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Log;
        }
    }

    public partial class Log10
    {
        public class Native : Log10
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => System.Math.Log10;
        }
    }

    public partial class ModPowL
    {
        public class Native : ModPowL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(BigInteger, BigInteger, BigInteger), BigInteger> __Body__ => (args) => BigInteger.ModPow(args.Item1, args.Item2, args.Item3);
        }
    }
    public partial class Sin
    {
        public class Native : Sin
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => (theta) => System.Math.Sin(theta);
        }
    }

    public partial class Sinh
    {
        public class Native : Sinh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => (theta) => System.Math.Sinh(theta);
        }
    }

    public partial class Sqrt
    {
        public class Native : Sqrt
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => (arg) => System.Math.Sqrt(arg);
        }
    }

    public partial class Tan
    {
        public class Native : Tan
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => (theta) => System.Math.Tan(theta);
        }
    }

    public partial class Tanh
    {
        public class Native : Tanh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> __Body__ => (theta) => System.Math.Tanh(theta);
        }
    }

}

