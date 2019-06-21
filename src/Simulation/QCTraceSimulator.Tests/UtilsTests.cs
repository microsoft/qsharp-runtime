// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Xunit;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.Tests
{

    public partial class TracingSimulatorCoreTests
    {
        [Fact]
        public void UtilsTests()
        {
            QArray<Pauli> obs = new QArray<Pauli>(Pauli.PauliI, Pauli.PauliX, Pauli.PauliX);
            QArray<Qubit> qs = new QArray<Qubit>(new TraceableQubit(0, 0), new TraceableQubit(1, 0), new TraceableQubit(2, 0));
            Utils.PruneObservable(obs, qs, out var obsPr, out var qubitsPr);
            Assert.Equal(2, obsPr.Count);
            Assert.Equal(2, qubitsPr.Count);

            Assert.Equal(Pauli.PauliX, obsPr[0]);
            Assert.Equal(Pauli.PauliX, obsPr[1]);

            Assert.Equal(1, qubitsPr[0].Id);
            Assert.Equal(2, qubitsPr[1].Id);

            Assert.Equal("IXX", Utils.ObservableToString(obs));
            Assert.Equal("XX", Utils.ObservableToString(obsPr));

            Assert.Equal(Result.One, Utils.Opposite(Result.Zero));
            Assert.Equal(Result.Zero, Utils.Opposite(Result.One));
        }
    }
}