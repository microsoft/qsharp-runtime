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
            var a = new RuntimeMetadata { };
            var i = 5;
            Assert.False(a.Equals(i));
        }

        [Fact]
        public void NullEquality()
        {
            var a = new RuntimeMetadata { };
            RuntimeMetadata? b = null;
            Assert.NotEqual(a, b);
            Assert.NotEqual(b, a);
        }

        [Fact]
        public void CheckEquality()
        {
            var a = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
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
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());

            b.Label = "X";
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
            b.Label = "H";

            b.FormattedNonQubitArgs = "(1)";
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
            b.FormattedNonQubitArgs = "";

            b.IsAdjoint = true;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
            b.IsAdjoint = false;

            b.IsControlled = true;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
            b.IsControlled = false;

            b.IsMeasurement = true;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
            b.IsMeasurement = false;

            b.IsComposite = true;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
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
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());

            b.Controls = new List<Qubit>() { new FreeQubit(1) };
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());

            a.Controls = new List<Qubit>() { new FreeQubit(1) };
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());
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
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());

            b.Targets = new List<Qubit>() { new FreeQubit(1) };
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());

            a.Targets = new List<Qubit>() { new FreeQubit(1) };
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());
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
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());

            var aChildren = a.Children.ToList();
            aChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "H" } };
            a.Children = aChildren;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());

            var bChildren = b.Children.ToList();
            bChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "X" } };
            b.Children = bChildren;
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());

            bChildren[0] = new List<RuntimeMetadata>() { new RuntimeMetadata() { Label = "H" } };
            Assert.Equal(a, b);
            Assert.Equal(a.GetHashCode(), b.GetHashCode());

            b.Children = b.Children.SkipLast(1);
            Assert.NotEqual(a, b);
            Assert.NotEqual(a.GetHashCode(), b.GetHashCode());
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
            var args = op.__DataIn__((control, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void CCNOT()
        {
            var control1 = new FreeQubit(0);
            var control2 = new FreeQubit(2);
            var target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.CCNOT>();
            var args = op.__DataIn__((control1, control2, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control1, control2 },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void Swap()
        {
            var q1 = new FreeQubit(0);
            var q2 = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.SWAP>();
            var args = op.__DataIn__((q1, q2));
            var expected = new RuntimeMetadata()
            {
                Label = "SWAP",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { q1, q2 },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void Ry()
        {
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.Ry>();
            var args = op.__DataIn__((2.1, target));
            var expected = new RuntimeMetadata()
            {
                Label = "Ry",
                FormattedNonQubitArgs = "(" + 2.1 + ")",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void M()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.M>();
            var args = op.__DataIn__(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "M",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void Reset()
        {
            var target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.Reset>();
            var args = op.__DataIn__(target);
            var expected = new RuntimeMetadata()
            {
                Label = "Reset",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void ResetAll()
        {
            IQArray<Qubit> targets = new QArray<Qubit>(new[] { new FreeQubit(0) });
            var op = new QuantumSimulator().Get<Intrinsic.ResetAll>();
            var args = op.__DataIn__(targets);
            var expected = new RuntimeMetadata()
            {
                Label = "ResetAll",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = true,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = targets,
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }
    }

    public class MeasurementTests
    {
        [Fact]
        public void MResetX()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetX>();
            var args = op.__DataIn__(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetX",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void MResetY()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetY>();
            var args = op.__DataIn__(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetY",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void MResetZ()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Measurement.MResetZ>();
            var args = op.__DataIn__(measureQubit);
            var expected = new RuntimeMetadata()
            {
                Label = "MResetZ",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = true,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { measureQubit },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }
    }

    public class CustomCircuitTests
    {
        [Fact]
        public void EmptyOperation()
        {
            var measureQubit = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Circuits.Empty>();
            var args = op.__DataIn__(QVoid.Instance);
            var expected = new RuntimeMetadata()
            {
                Label = "Empty",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void OperationAsArgument()
        {
            var q = new FreeQubit(0);
            var opArg = new QuantumSimulator().Get<Circuits.HOp>();
            var op = new QuantumSimulator().Get<Circuits.WrapperOp>();
            var args = op.__DataIn__((opArg, q));
            var expected = new RuntimeMetadata()
            {
                Label = "WrapperOp",
                FormattedNonQubitArgs = "(HOp)",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { q },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void NestedOperation()
        {
            var op = new QuantumSimulator().Get<Circuits.NestedOp>();
            var args = op.__DataIn__(QVoid.Instance);
            var expected = new RuntimeMetadata()
            {
                Label = "NestedOp",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void DuplicateQubitArgs()
        {
            var q = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Circuits.TwoQubitOp>();
            var args = op.__DataIn__((q, q));
            var expected = new RuntimeMetadata()
            {
                Label = "TwoQubitOp",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { q },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void QArrayArgs()
        {
            var op = new QuantumSimulator().Get<Circuits.BoolArrayOp>();
            IQArray<Boolean> bits = new QArray<Boolean>(new bool[] { false, true });
            var args = op.__DataIn__(bits);
            var expected = new RuntimeMetadata()
            {
                Label = "BoolArrayOp",
                FormattedNonQubitArgs = "[False, True]",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }
    }

    public class UDTTests
    {
        [Fact]
        public void FooUDTOp()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Tests.Circuits.FooUDTOp>();
            var args = op.__DataIn__(new Circuits.FooUDT(("bar", (target, 2.1))));
            var expected = new RuntimeMetadata()
            {
                Label = "FooUDTOp",
                FormattedNonQubitArgs = "(\"bar\", (" + 2.1 + "))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
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
            var args = op.__DataIn__((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void ControlledX()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op = new QuantumSimulator().Get<Intrinsic.X>().Controlled;
            var args = op.__DataIn__((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void ControlledCNOT()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit control = new FreeQubit(1);
            Qubit target = new FreeQubit(2);
            var op = new QuantumSimulator().Get<Intrinsic.CNOT>().Controlled;
            var args = op.__DataIn__((controls, (control, target)));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls.Append(control),
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
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
            var args = op.__DataIn__((controls, (control2, control3, target)));
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { control1, control2, control3 },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }
    }

    public class AdjointTests
    {
        [Fact]
        public void AdjointH()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.H>().Adjoint;
            var args = op.__DataIn__(target);
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void AdjointX()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.X>().Adjoint;
            var args = op.__DataIn__(target);
            var expected = new RuntimeMetadata()
            {
                Label = "X",
                FormattedNonQubitArgs = "",
                IsAdjoint = true,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void AdjointAdjointH()
        {
            Qubit target = new FreeQubit(0);
            var op = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Adjoint;
            var args = op.__DataIn__(target);
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void ControlledAdjointH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op1 = new QuantumSimulator().Get<Intrinsic.H>().Controlled.Adjoint;
            var op2 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Controlled;
            var args = op1.__DataIn__((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
                IsAdjoint = true,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op1.GetRuntimeMetadata(args), expected);
            Assert.Equal(op2.GetRuntimeMetadata(args), expected);
        }

        [Fact]
        public void ControlledAdjointAdjointH()
        {
            IQArray<Qubit> controls = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Qubit target = new FreeQubit(1);
            var op1 = new QuantumSimulator().Get<Intrinsic.H>().Controlled.Adjoint.Adjoint;
            var op2 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Controlled.Adjoint;
            var op3 = new QuantumSimulator().Get<Intrinsic.H>().Adjoint.Adjoint.Controlled;
            var args = op1.__DataIn__((controls, target));
            var expected = new RuntimeMetadata()
            {
                Label = "H",
                FormattedNonQubitArgs = "",
                IsAdjoint = false,
                IsControlled = true,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = controls,
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op1.GetRuntimeMetadata(args), expected);
            Assert.Equal(op2.GetRuntimeMetadata(args), expected);
            Assert.Equal(op3.GetRuntimeMetadata(args), expected);
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
            var args = op.__DataIn__(2.1);
            var expected = new RuntimeMetadata()
            {
                Label = "Ry",
                FormattedNonQubitArgs = "(" + 2.1 + ")",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { target },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
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
                FormattedNonQubitArgs = "(\"bar\", (" + 2.1 + "))",
                IsAdjoint = false,
                IsControlled = false,
                IsMeasurement = false,
                IsComposite = false,
                Children = null,
                Controls = new List<Qubit>() { },
                Targets = new List<Qubit>() { },
            };

            Assert.Equal(op.GetRuntimeMetadata(args), expected);
        }
    }
}
