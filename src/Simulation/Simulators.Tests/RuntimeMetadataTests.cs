// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class RuntimeMetadataEqualityTests
    {
        [Fact]
        public void WrongType()
        {
            RuntimeMetadata a = new RuntimeMetadata { };
            var i = 5;
            Assert.False(a.Equals(i));
        }

        [Fact]
        public void NullEquality()
        {
            RuntimeMetadata a = new RuntimeMetadata { };
            Assert.False(a == null);
            Assert.False(null == a);
            Assert.True(null == null);
        }

        [Fact]
        public void CheckEquality()
        {
            var a = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };
            var b = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };
            Assert.True(a == b);

            b.Label = "X";
            Assert.False(a == b);
            b.Label = "H";

            b.Args = "(1)";
            Assert.False(a == b);
            b.Args = null;

            b.IsAdjoint = true;
            Assert.False(a == b);
            b.IsAdjoint = false;

            b.IsControlled = true;
            Assert.False(a == b);
            b.IsControlled = false;

            b.IsMeasurement = true;
            Assert.False(a == b);
            b.IsMeasurement = false;

            b.IsComposite = true;
            Assert.False(a == b);
            b.IsComposite = false;
        }

        [Fact]
        public void ControlsEquality()
        {
            var a = new RuntimeMetadata()
            {
                Controls = new List<Qubit>() { },
            };
            var b = new RuntimeMetadata()
            {
                Controls = new List<Qubit>() { },
            };
            Assert.True(a == b);

            b.Controls = new List<Qubit>() { new FreeQubit(1) };
            Assert.False(a == b);

            a.Controls = new List<Qubit>() { new FreeQubit(1) };
            Assert.True(a == b);
        }

        [Fact]
        public void TargetsEquality()
        {
            var a = new RuntimeMetadata()
            {
                Targets = new List<Qubit>() { },
            };
            var b = new RuntimeMetadata()
            {
                Targets = new List<Qubit>() { },
            };
            Assert.True(a == b);

            b.Targets = new List<Qubit>() { new FreeQubit(1) };
            Assert.False(a == b);

            a.Targets = new List<Qubit>() { new FreeQubit(1) };
            Assert.True(a == b);
        }

        [Fact]
        public void ChildrenEquality()
        {
            var a = new RuntimeMetadata()
            {
                Children = new[]
                {
                    new List<RuntimeMetadata>(),
                    new List<RuntimeMetadata>(),
                },
            };
            var b = new RuntimeMetadata()
            {
                Children = new[]
                {
                    new List<RuntimeMetadata>(),
                    new List<RuntimeMetadata>(),
                },
            };
            Assert.True(a == b);

            var aChildren = a.Children.ToList();
            aChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "H" } };
            a.Children = aChildren;
            Assert.False(a == b);

            var bChildren = b.Children.ToList();
            bChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "X" } };
            b.Children = bChildren;
            Assert.False(a == b);

            bChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "H" } };
            Assert.True(a == b);

            b.Children = b.Children.SkipLast(1);
            Assert.False(a == b);
        }
    }

    public class IntrinsicTests
    {
        [Fact]
        public void CNOT()
        {
            var control = new FreeQubit(1);
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.CNOT>();
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

            var metadata = op.GetRuntimeMetadata(args);
            var equals = metadata == expected;

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void CCNOT()
        {
            var control1 = new FreeQubit(0);
            var control2 = new FreeQubit(2);
            var target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.CCNOT>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void Ry()
        {
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.Ry>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void M()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.M>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }
    }

    public class MeasurementTests
    {
        [Fact]
        public void MResetX()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetX>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void MResetY()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetY>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void MResetZ()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetZ>();
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }
    }

    public class UDTTests
    {
        [Fact]
        public void FooUDTOp()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Tests.Circuits.FooUDTOp>();
            var args = op.__dataIn(new Circuits.FooUDT(("bar", (target, 2.1))));
            var expected = new RuntimeMetadata()
            {
                Label = "FooUDTOp",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }
    }

    public class ControlledOpTests
    {
        [Fact]
        public void ControlledH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.H>().Controlled;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledX()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.X>().Controlled;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledCNOT()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit control = new FreeQubit(1);
            Qubit target = new FreeQubit(2);
            var op = new QuantumSimulator().Get<Intrinsic.CNOT>().Controlled;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledCCNOT()
        {
            Qubit control1 = new FreeQubit(0);
            Qubit control2 = new FreeQubit(1);
            Qubit control3 = new FreeQubit(2);
            Qubit target = new FreeQubit(3);
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { control1 });
            var op = new QuantumSimulator().Get<Intrinsic.CCNOT>().Controlled;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledUDT()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Tests.Circuits.FooUDTOp>().Controlled;
            var args = new QTuple<ValueTuple<IQArray<Qubit>, Circuits.FooUDT>>((controls, new Circuits.FooUDT(("bar", (target, 2.1)))));
            var expected = new RuntimeMetadata()
            {
                Label = "FooUDTOp",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }
    }

    public class AdjointTests
    {
        [Fact]
        public void AdjointH()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.H>().Adjoint;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void AdjointX()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.X>().Adjoint;
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void AdjointUDT()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Tests.Circuits.FooUDTOp>().Adjoint;
            var args = op.__dataIn(new Circuits.FooUDT(("bar", (target, 2.1))));
            var expected = new RuntimeMetadata()
            {
                Label = "FooUDTOp",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void AdjointAdjointH()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Adjoint;
            var args = op.__dataIn(target);
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledAdjointH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op1 = new QuantumSimulator().Get<Intrinsic.H>().Controlled.Adjoint;
            var op2 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Controlled;
            var args = op1.__dataIn((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                Args = null,
                IsAdjoint = true,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.True(op1.GetRuntimeMetadata(args) == expected);
            Assert.True(op2.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void ControlledAdjointAdjointH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op1 = new QuantumSimulator().Get<Intrinsic.H>().Controlled.Adjoint.Adjoint;
            var op2 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Controlled.Adjoint;
            var op3 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Adjoint.Controlled;
            var args = op1.__dataIn((controls, target));
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

            Assert.True(op1.GetRuntimeMetadata(args) == expected);
            Assert.True(op2.GetRuntimeMetadata(args) == expected);
            Assert.True(op3.GetRuntimeMetadata(args) == expected);
        }
    }

    public class PartialOpTests
    {

        [Fact]
        public void PartialRy()
        {
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.Ry>().Partial((double d) =>
                new ValueTuple<double, Qubit>(d, target));
            var args = op.__dataIn(2.1);
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

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }

        [Fact]
        public void PartialUDT()
        {
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<ICallable<(String, (Qubit, Double)), Circuits.FooUDT>>(typeof(Circuits.FooUDT))
                .Partial<double>((double d) => (("bar", (target, d))));
            var args = new QTuple<double>(2.1);
            var expected = new RuntimeMetadata()
            {
                Label = "FooUDT",
                Args = "(\"bar\", (2.1))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };

            Assert.True(op.GetRuntimeMetadata(args) == expected);
        }
    }
}
