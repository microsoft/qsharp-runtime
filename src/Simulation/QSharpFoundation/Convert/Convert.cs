// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Numerics;

namespace Microsoft.Quantum.Convert
{
    public partial class IntAsDouble
    {
        public class Native : IntAsDouble
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, double> __Body__ => (arg) => System.Convert.ToDouble(arg);
        }
    }

    public partial class IntAsBigInt
    {
        public class Native : IntAsBigInt
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, BigInteger> __Body__ => (arg) => new BigInteger(arg);
        }
    }


    public partial class BoolAsString
    {
        public class Native : BoolAsString
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<bool, string> __Body__ => (arg) => System.Convert.ToString(arg);
        }
    }

    public partial class DoubleAsString
    {
        public class Native : DoubleAsString
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<double, string> __Body__ => (arg) => System.Convert.ToString(arg);
        }
    }

    public partial class DoubleAsStringWithFormat
    {
        public class Native : DoubleAsStringWithFormat
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(double, string), string> __Body__ => (arg) => arg.Item1.ToString(arg.Item2);
        }
    }

    public partial class IntAsString
    {
        public class Native : IntAsString
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<long, string> __Body__ => (arg) => System.Convert.ToString(arg);
        }
    }

    public partial class IntAsStringWithFormat
    {
        public class Native : IntAsStringWithFormat
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<(long, string), string> __Body__ => (arg) => arg.Item1.ToString(arg.Item2);
        }
    }

}
