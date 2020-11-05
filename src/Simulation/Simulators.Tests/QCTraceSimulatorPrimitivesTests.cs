// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.XUnit;
using System;
using System.Diagnostics;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests
{
    public class PrimitivesTestsQuite
    {
        private readonly ITestOutputHelper output;
        public PrimitivesTestsQuite(ITestOutputHelper output)
        {
            this.output = output;
        }

        private static void OverrideOperation<OperationType, TypeToOverride, TypeToOverrideBy>(Factory<AbstractCallable> sim)
            where TypeToOverrideBy : AbstractCallable, OperationType
            where TypeToOverride : AbstractCallable, OperationType
        {
            IOperationFactory factory = sim as IOperationFactory;
            Debug.Assert(factory != null);
            OperationType op = factory.Get<OperationType, TypeToOverrideBy>();
            sim.Register(typeof(TypeToOverride), op.GetType(), typeof(OperationType));
        }

        [OperationDriver(TestCasePrefix = "QSim:Circuits:")]
        public void QSimTestTarget(TestOperation op)
        {
            using (var sim = new QuantumSimulator())
            {
                OverrideOperation<
                    ICallable<(Qubit, Qubit), QVoid>,
                    Simulators.QCTraceSimulators.Implementation.Interface_CX,
                    Intrinsic.CNOT>(sim);

                OverrideOperation<
                    ICallable<(Pauli, Int64, Int64, Qubit), QVoid>,
                    Simulators.QCTraceSimulators.Implementation.Interface_RFrac,
                    Intrinsic.RFrac>(sim);

                OverrideOperation<
                    ICallable<(Pauli, Double, Qubit), QVoid>,
                    Simulators.QCTraceSimulators.Implementation.Interface_R,
                    Intrinsic.R>(sim);

                OverrideOperation<
                    ICallable<(Int64, Pauli, Qubit), QVoid>,
                    Simulators.QCTraceSimulators.Implementation.Interface_Clifford,
                    Interface_Clifford>(sim);

                sim.OnLog += (msg) => { output.WriteLine(msg); };
                sim.OnLog += (msg) => { Debug.WriteLine(msg); };

                op.TestOperationRunner(sim);
            }
        }
    }
}
