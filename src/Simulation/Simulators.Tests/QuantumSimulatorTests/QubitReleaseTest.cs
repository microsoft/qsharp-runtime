// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public partial class QuantumSimulatorTests
    {
        //test to check that qubit cannot be released if it is not in zero state
        [Fact]
        public async Task ZeroStateQubitReleaseTest()
        {
            var sim = new QuantumSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics));

            await Assert.ThrowsAsync<ReleasedQubitsAreNotInZeroState>(() => UsingQubitCheck.Run(sim));
        }

        //test to check that qubit can be released if measured
        [Fact]
        public async Task MeasuredQubitReleaseTest()
        {
            var sim = new QuantumSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics));

            //should not throw an exception, as Measured qubits are allowed to be released, and the release aspect is handled in the C++ code
            await ReleaseMeasuredQubitCheck.Run(sim);
        }

        //test to check that qubits cannot be released after multiple qubit measure
        [Fact]
        public async Task MeasuredMultipleQubitsReleaseTest()
        {
            var sim = new QuantumSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics));

            await Assert.ThrowsAsync<ReleasedQubitsAreNotInZeroState>(() => ReleaseMeasureMultipleQubitCheck.Run(sim));
        }

        //test to check that qubit that is released and reallocated is in state |0>
        [Fact]
        public async Task ReallocateQubitInGroundStateTest()
        {
            var sim = new QuantumSimulator(typeof(Microsoft.Quantum.Intrinsic.TargetIntrinsics));
            var allocate = sim.Get<Intrinsic.Allocate>();
            var release = sim.Get<Intrinsic.Release>();
            var q1 = allocate.Apply(1);
            var q1Id = q1[0].Id;
            var gate = sim.Get<Intrinsic.X>();
            var measure = sim.Get<Intrinsic.M>();
            gate.Apply(q1[0]);
            var result1 = measure.Apply(q1[0]);
            //Check X operation
            Assert.Equal(result1, Result.One);
            release.Apply(q1[0]);
            var q2 = allocate.Apply(1);
            var q2Id = q2[0].Id;
            //Assert reallocated qubit has the same id as the one released
            Assert.Equal(q1Id, q2Id);
            var result2 = measure.Apply(q2[0]);
            //Assert reallocated qubit has is initialized in state |0>
            Assert.Equal(result2, Result.Zero);


            
        }
    }
}
