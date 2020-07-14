// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public static class IntrinsicTestsExtensions
    {
        // Look into better ways of checking equality (i.e. GetType().GetProperties())
        public static bool IsEqual(this RuntimeMetadata self, RuntimeMetadata to) =>
            self.Label == to.Label && self.Args == to.Args && self.IsAdjoint == to.IsAdjoint &&
            self.IsControlled == to.IsControlled && self.IsMeasurement == to.IsMeasurement &&
            self.IsComposite == to.IsComposite &&
            self.Controls.SequenceEqual(to.Controls) && self.Targets.SequenceEqual(to.Targets);
    }

    public class FooOp : Operation<ValueTuple<string, ValueTuple<Qubit, Double>>, QVoid>, ICallable
    {
        public FooOp(IOperationFactory m) : base(m) { }

        public override void Init() { }

        public override Func<ValueTuple<string, ValueTuple<Qubit, Double>>, QVoid> Body =>
            (ValueTuple<string, ValueTuple<Qubit, Double>> data) => null;

        public override IApplyData __dataIn(ValueTuple<string, ValueTuple<Qubit, Double>> data) =>
            new QTuple<ValueTuple<string, ValueTuple<Qubit, Double>>>(data);

        string ICallable.Name => "Foo";
        string ICallable.FullName => "Microsoft.Quantum.Simulation.Simulators.Tests.Foo";
    }


    public class IntrinsicTests
    {
        [Fact]
        public void CNOT()
        {
            var control = new FreeQubit(1);
            var target = new FreeQubit(0);
            var op = new Microsoft.Quantum.Intrinsic.CNOT(new TrivialSimulator());
            var args = op.__dataIn((control, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void CCNOT()
        {
            var control1 = new FreeQubit(0);
            var control2 = new FreeQubit(2);
            var target = new FreeQubit(1);
            var op = new Microsoft.Quantum.Intrinsic.CCNOT(new TrivialSimulator());
            var args = op.__dataIn((control1, control2, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control1, control2 },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void Ry()
        {
            var target = new FreeQubit(0);
            var op = new Microsoft.Quantum.Intrinsic.Ry(new TrivialSimulator());
            var args = op.__dataIn((2.1, target));
            var expected = new RuntimeMetadata()
            {
                Label = "Ry",
                Args = "(2.1)",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void M()
        {
            var measureQubit = new FreeQubit(0);
            var op = new Microsoft.Quantum.Intrinsic.M(new TrivialSimulator());
            var args = op.__dataIn(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "M",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void Reset()
        {
            var target = new FreeQubit(0);
            var op = new Microsoft.Quantum.Intrinsic.Reset(new TrivialSimulator());
            var args = op.__dataIn(target);
            Assert.Null(op.GetRuntimeMetadata(args));
        }

        [Fact]
        public void ResetAll()
        {
            var targets = QArray<Qubit>.Create(3);
            var op = new Microsoft.Quantum.Intrinsic.ResetAll(new TrivialSimulator());
            var args = op.__dataIn(targets);
            Assert.Null(op.GetRuntimeMetadata(args));
        }
    }

    public class MeasurementTests
    {
        [Fact]
        public void MResetX()
        {
            var measureQubit = new FreeQubit(0);
            var op = new Microsoft.Quantum.Measurement.MResetX(new TrivialSimulator());
            var args = op.__dataIn(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetX",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void MResetY()
        {
            var measureQubit = new FreeQubit(0);
            var op = new Microsoft.Quantum.Measurement.MResetY(new TrivialSimulator());
            var args = op.__dataIn(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetY",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void MResetZ()
        {
            var measureQubit = new FreeQubit(0);
            var op = new Microsoft.Quantum.Measurement.MResetZ(new TrivialSimulator());
            var args = op.__dataIn(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetZ",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }
    }

    public class CustomOpTests
    {
        [Fact]
        public void Foo()
        {
            Qubit target = new FreeQubit(0);
            var op = new FooOp(new TrivialSimulator());
            var args = op.__dataIn(("bar", (target, 2.1)));
            var expected = new RuntimeMetadata()
            {
                Label = "Foo",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }
    }

    public class ControlledOpTests
    {
        [Fact]
        public void ControlledH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            Operation<Qubit, QVoid> baseOp = new QuantumSimulator().Get<Intrinsic.H>();
            var op = new ControlledOperation<Qubit, QVoid>(baseOp);
            var args = op.__dataIn((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void ControlledX()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            Operation<Qubit, QVoid> baseOp = new QuantumSimulator().Get<Intrinsic.X>();
            var op = new ControlledOperation<Qubit, QVoid>(baseOp);
            var args = op.__dataIn((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void ControlledCNOT()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit control = new FreeQubit(1);
            Qubit target = new FreeQubit(2);
            Operation<ValueTuple<Qubit, Qubit>, QVoid> baseOp = new Microsoft.Quantum.Intrinsic.CNOT(new TrivialSimulator());
            var op = new ControlledOperation<ValueTuple<Qubit, Qubit>, QVoid>(baseOp);
            var args = op.__dataIn((controls, (control, target)));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls.Append(control),
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void ControlledCCNOT()
        {
            Qubit control1 = new FreeQubit(0);
            Qubit control2 = new FreeQubit(1);
            Qubit control3 = new FreeQubit(2);
            Qubit target = new FreeQubit(3);
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { control1 });
            Operation<ValueTuple<Qubit, Qubit, Qubit>, QVoid> baseOp = new Microsoft.Quantum.Intrinsic.CCNOT(new TrivialSimulator());
            var op = new ControlledOperation<ValueTuple<Qubit, Qubit, Qubit>, QVoid>(baseOp);
            var args = op.__dataIn((controls, (control2, control3, target)));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control1, control2, control3 },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void ControlledFoo()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var baseOp = new FooOp(new TrivialSimulator());
            var op = new ControlledOperation<ValueTuple<string, ValueTuple<Qubit, double>>, QVoid>(baseOp);
            var args = op.__dataIn((controls, ("bar", (target, 2.1))));
            var expected = new RuntimeMetadata()
            {
                Label = "Foo",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }
    }

    public class AdjointTests
    {
        [Fact]
        public void AdjointH()
        {
            Qubit target = new FreeQubit(0);
            Operation<Qubit, QVoid> baseOp = new QuantumSimulator().Get<Intrinsic.H>();
            var op = new AdjointedOperation<Qubit, QVoid>(baseOp);
            var args = op.__dataIn(target);
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void AdjointX()
        {
            Qubit target = new FreeQubit(0);
            Operation<Qubit, QVoid> baseOp = new QuantumSimulator().Get<Intrinsic.X>();
            var op = new AdjointedOperation<Qubit, QVoid>(baseOp);
            var args = op.__dataIn(target);
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                Args = null,
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void AdjointFoo()
        {
            Qubit target = new FreeQubit(0);
            var baseOp = new FooOp(new TrivialSimulator());
            var op = new AdjointedOperation<ValueTuple<string, ValueTuple<Qubit, double>>, QVoid>(baseOp);
            var args = op.__dataIn(("bar", (target, 2.1)));
            var expected = new RuntimeMetadata()
            {
                Label = "Foo",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }
    }

    public class PartialOpTests
    {

        [Fact]
        public void PartialRy()
        {
            var target = new FreeQubit(0);
            Operation<ValueTuple<double, Qubit>, QVoid> baseOp = new Microsoft.Quantum.Intrinsic.Ry(new TrivialSimulator());
            Func<ValueTuple<double>, ValueTuple<double, Qubit>> mapper = (ValueTuple<double> d) => new ValueTuple<double, Qubit>(d.Item1, target);
            var op = new OperationPartial<ValueTuple<double>, ValueTuple<double, Qubit>, QVoid>(baseOp, mapper);
            var args = op.__dataIn(new ValueTuple<double>(2.1));
            var expected = new RuntimeMetadata()
            {
                Label = "Ry",
                Args = "(2.1)",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }

        [Fact]
        public void PartialFoo()
        {
            var target = new FreeQubit(0);
            Operation<ValueTuple<string, ValueTuple<Qubit, double>>, QVoid> baseOp = new FooOp(new TrivialSimulator());
            Func<ValueTuple<double>, ValueTuple<string, ValueTuple<Qubit, double>>> mapper = (ValueTuple<double> d) => new ValueTuple<string, ValueTuple<Qubit, double>>("bar", (target, d.Item1));
            var op = new OperationPartial<ValueTuple<double>, ValueTuple<string, ValueTuple<Qubit, double>>, QVoid>(baseOp, mapper);
            var args = op.__dataIn(new ValueTuple<double>(2.1));

            var expected = new RuntimeMetadata()
            {
                Label = "Foo",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args).IsEqual(expected));
        }
    }
}
