// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Core
{
    public partial class Length<__T__>
    {
        public class Native : Length<__T__>
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<IQArray<__T__>, long> __Body__ => (arg) => (arg.Length);
        }
    }

    public partial class RangeStart
    {
        public class Native : RangeStart
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QRange, long> __Body__ => (arg) => (arg.Start);
        }
    }

    public partial class RangeEnd
    {
        public class Native : RangeEnd
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QRange, long> __Body__ => (arg) => (arg.End);
        }
    }

    public partial class RangeStep
    {
        public class Native : RangeStep
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QRange, long> __Body__ => (arg) => (arg.Step);
        }
    }

    public partial class RangeReverse
    {
        public class Native : RangeReverse
        {
            public Native(IOperationFactory m) : base(m) { }
            public override Func<QRange, QRange> __Body__ => (arg) => (arg.Reverse());
        }
    }
}
