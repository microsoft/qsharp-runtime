// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
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
}
