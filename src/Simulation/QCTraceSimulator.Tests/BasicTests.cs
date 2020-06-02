// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;
using Xunit;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests
{
    public class BasicCoreTests
    {
        [Fact]
        public void TracerCoreConstructor()
        {
            QCTraceSimulatorConfiguration tracerCoreConfiguration = new QCTraceSimulatorConfiguration();
            tracerCoreConfiguration.UsePrimitiveOperationsCounter = true;
            QCTraceSimulator tracerCore = new QCTraceSimulator(tracerCoreConfiguration);
        }

        [Fact]
        public void GetPrimitiveOperations()
        {
            QCTraceSimulator tracerCore = new QCTraceSimulator();

            var measureOp = tracerCore.Get<Intrinsic.Measure, Intrinsic.Measure>();
            Assert.NotNull(measureOp);

            var assertOp = tracerCore.Get<Intrinsic.Assert, Intrinsic.Assert>();
            Assert.NotNull(assertOp);

            var assertProb = tracerCore.Get<Intrinsic.AssertProb, Intrinsic.AssertProb>();
            Assert.NotNull(assertProb);

            var allocOp = tracerCore.Get<Intrinsic.Allocate, Intrinsic.Allocate>();
            Assert.NotNull(allocOp);

            var releaseOp = tracerCore.Get<Intrinsic.Release, Intrinsic.Release>();
            Assert.NotNull(releaseOp);

            var borrowOp = tracerCore.Get<Intrinsic.Borrow, Intrinsic.Borrow>();
            Assert.NotNull(borrowOp);

            var returnOp = tracerCore.Get<Intrinsic.Return, Intrinsic.Return>();
            Assert.NotNull(returnOp);
        }

        [Fact]
        public void GetInterfaceOperations()
        {
            QCTraceSimulator tracerCore = new QCTraceSimulator();

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
            QCTraceSimulator tracerCore = new QCTraceSimulator();

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
                    var i = tracerCore.GetInstance(op);
                    Assert.NotNull(i);
                }
                catch (Exception e)
                {
                    missing.Add(op);
                }
            }

            Assert.Empty(missing);
        }
    }
}
