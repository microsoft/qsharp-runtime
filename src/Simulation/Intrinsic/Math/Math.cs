// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Math
{
    public partial class AbsD
    {
        public class Native : AbsD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Abs;
        }
    }

    public partial class AbsI
    {
        public class Native : AbsI
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, long> Body => System.Math.Abs;
        }
    }

    public partial class AbsL
    {
        public class Native : AbsL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<BigInteger, BigInteger> Body => BigInteger.Abs;
        }
    }

    public partial class ArcCos
    {
        public class Native : ArcCos
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Acos;
        }
    }

    public partial class ArcSin
    {
        public class Native : ArcSin
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Asin;
        }
    }

    public partial class ArcTan
    {
        public class Native : ArcTan
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Atan;
        }
    }


    public partial class ArcTan2
    {
        public class Native : ArcTan2
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> Body => (args) => System.Math.Atan2(args.Item1, args.Item2);
        }
    }

    public partial class Ceiling
    {
        public class Native : Ceiling
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, long> Body => (arg) => System.Convert.ToInt64(System.Math.Ceiling(arg));
        }
    }

    public partial class Cos
    {
        public class Native : Cos
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Cos;
        }
    }

    public partial class Cosh
    {
        public class Native : Cosh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Cosh;
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
            public override Func<(BigInteger, BigInteger), (BigInteger, BigInteger)> Body => Impl;
        }
    }

    public partial class E
    {
        public class Native : E
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QVoid, double> Body => (arg) => System.Math.E;
        }
    }

    public partial class ExpD
    {
        public class Native : ExpD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Exp;
        }
    }

    public partial class Floor
    {
        public class Native : Floor
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, long> Body => (arg) => System.Convert.ToInt64(System.Math.Floor(arg));
        }
    }

    public partial class IEEERemainder
    {
        public class Native : IEEERemainder
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> Body => (arg) => System.Math.IEEERemainder(arg.Item1, arg.Item2);
        }
    }

    public partial class Log
    {
        public class Native : Log
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Log;
        }
    }

    public partial class Log10
    {
        public class Native : Log10
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => System.Math.Log10;
        }
    }

    public partial class MaxD
    {
        public class Native : MaxD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> Body => (args) => System.Math.Max(args.Item1, args.Item2);
        }
    }

    public partial class MaxI
    {
        public class Native : MaxI
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, long), long> Body => (args) => System.Math.Max(args.Item1, args.Item2);
        }
    }

    public partial class MaxL
    {
        public class Native : MaxL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(BigInteger, BigInteger), BigInteger> Body => (args) => BigInteger.Max(args.Item1, args.Item2);
        }
    }

    public partial class MinD
    {
        public class Native : MinD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> Body => (args) => System.Math.Min(args.Item1, args.Item2);
        }
    }

    public partial class MinI
    {
        public class Native : MinI
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, long), long> Body => (args) => System.Math.Min(args.Item1, args.Item2);
        }
    }

    public partial class MinL
    {
        public class Native : MinL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(BigInteger, BigInteger), BigInteger> Body => (args) => BigInteger.Min(args.Item1, args.Item2);
        }
    }

    public partial class ModPowL
    {
        public class Native : ModPowL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(BigInteger, BigInteger, BigInteger), BigInteger> Body => (args) => BigInteger.ModPow(args.Item1, args.Item2, args.Item3);
        }
    }

    public partial class PI : Function<QVoid, Double>
    {
        public class Native : PI
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QVoid, double> Body => (arg) => System.Math.PI;
        }
    }

    public partial class PowD
    {
        public class Native : PowD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, double), double> Body => (arg) => System.Math.Pow(arg.Item1, arg.Item2);
        }
    }

    public partial class Round
    {
        public class Native : Round
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, long> Body => (arg) => System.Convert.ToInt64(System.Math.Round(arg));
        }
    }

    public partial class Sin
    {
        public class Native : Sin
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => (theta) => System.Math.Sin(theta);
        }
    }

    public partial class SignD
    {
        public class Native : SignD
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, long> Body => (arg) => System.Math.Sign(arg);
        }
    }

    public partial class SignI
    {
        public class Native : SignI
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, long> Body => (arg) => System.Math.Sign(arg);
        }
    }

    public partial class SignL
    {
        public class Native : SignL
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<BigInteger, long> Body => (arg) => arg.Sign;
        }
    }

    public partial class Sinh
    {
        public class Native : Sinh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => (theta) => System.Math.Sinh(theta);
        }
    }

    public partial class Sqrt
    {
        public class Native : Sqrt
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => (arg) => System.Math.Sqrt(arg);
        }
    }

    public partial class Tan
    {
        public class Native : Tan
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => (theta) => System.Math.Tan(theta);
        }
    }

    public partial class Tanh
    {
        public class Native : Tanh
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, double> Body => (theta) => System.Math.Tanh(theta);
        }
    }

    public partial class Truncate
    {
        public class Native : Truncate
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, long> Body => (arg) => System.Convert.ToInt64(System.Math.Truncate(arg));
        }
    }
}

