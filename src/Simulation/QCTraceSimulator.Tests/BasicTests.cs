// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;
using Xunit;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests
{
    public class BasicCoreTests
    {
        [Fact]
        public void TracerCoreConstructor()
        {
            var tracerCoreConfiguration = new NewTracerConfiguration();
            tracerCoreConfiguration.UsePrimitiveOperationsCounter = true;
            var tracer = new TracerSimulator(tracerCoreConfiguration);
        }

        [Fact]
        public void GetPrimitiveOperationsNew()
        {
            var tracer = new TracerSimulator();

            var measureOp = tracer.Get<Intrinsic.Measure, Intrinsic.Measure>();
            Assert.NotNull(measureOp);

            var assertOp = tracer.Get<Intrinsic.Assert, Intrinsic.Assert>();
            Assert.NotNull(assertOp);

            var assertProb = tracer.Get<Intrinsic.AssertProb, Intrinsic.AssertProb>();
            Assert.NotNull(assertProb);

            var allocOp = tracer.Get<Intrinsic.Allocate, Intrinsic.Allocate>();
            Assert.NotNull(allocOp);

            var releaseOp = tracer.Get<Intrinsic.Release, Intrinsic.Release>();
            Assert.NotNull(releaseOp);

            var borrowOp = tracer.Get<Intrinsic.Borrow, Intrinsic.Borrow>();
            Assert.NotNull(borrowOp);

            var returnOp = tracer.Get<Intrinsic.Return, Intrinsic.Return>();
            Assert.NotNull(returnOp);
        }

        [Fact]
        public void GetPrimitiveOperationsOld()
        {
            var tracer = new TracerSimulator(new QCTraceSimConfiguration());

            var measureOp = tracer.Get<Intrinsic.Measure, Intrinsic.Measure>();
            Assert.NotNull(measureOp);

            var assertOp = tracer.Get<Intrinsic.Assert, Intrinsic.Assert>();
            Assert.NotNull(assertOp);

            var assertProb = tracer.Get<Intrinsic.AssertProb, Intrinsic.AssertProb>();
            Assert.NotNull(assertProb);

            var allocOp = tracer.Get<Intrinsic.Allocate, Intrinsic.Allocate>();
            Assert.NotNull(allocOp);

            var releaseOp = tracer.Get<Intrinsic.Release, Intrinsic.Release>();
            Assert.NotNull(releaseOp);

            var borrowOp = tracer.Get<Intrinsic.Borrow, Intrinsic.Borrow>();
            Assert.NotNull(borrowOp);

            var returnOp = tracer.Get<Intrinsic.Return, Intrinsic.Return>();
            Assert.NotNull(returnOp);
        }

        [Fact]
        public void GetInterfaceOperations()
        {
            var tracerCore = new TracerSimulator(new QCTraceSimConfiguration());

            var CX = tracerCore.Get<Interface_CX, Interface_CX>();
            Assert.NotNull(CX);

            var clifford = tracerCore.Get<Interface_Clifford, Interface_Clifford>();
            Assert.NotNull(clifford);

            var r = tracerCore.Get<Interface_R, Interface_R>();
            Assert.NotNull(r);

            var rFrac = tracerCore.Get<Interface_RFrac, Interface_RFrac>();
            Assert.NotNull(rFrac);

            var forceMeasure = tracerCore.Get<ForceMeasure, ForceMeasure>();
            Assert.NotNull(forceMeasure);
        }

        [Fact]
        public void TracerVerifyPrimitivesCompleteness()
        {
            var tracer = new TracerSimulator();

            var ops =
                from op in typeof(Intrinsic.X).Assembly.GetExportedTypes()
                where op.IsSubclassOf(typeof(AbstractCallable))
                where !op.IsNested
                select op;

            var missing = new List<Type>();

            foreach (var op in ops)
            {
                try
                {
                    var i = tracer.GetInstance(op);
                    Assert.NotNull(i);
                }
                catch (Exception)
                {
                    missing.Add(op);
                }
            }

            Assert.Empty(missing);
        }
    }
}
