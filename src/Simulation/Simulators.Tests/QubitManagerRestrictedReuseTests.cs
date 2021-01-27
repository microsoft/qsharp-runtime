// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using System;
using Xunit;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.Tests {
    public class QubitManagerRestrictedReuseTests {

        [Fact]
        public void QubitManagerRR_AllocDealloc1() {
            // Basic allocation without extending capacity
            QubitManagerRestrictedReuse qm = new QubitManagerRestrictedReuse(1);
            Assert.Equal(1, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);
            Qubit q0 = qm.Allocate();
            Assert.Equal(0, q0.Id);
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(1, qm.AllocatedQubitsCount);
            Assert.Throws<NotEnoughQubits>(() => qm.Allocate());
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(1, qm.AllocatedQubitsCount);
            qm.Release(q0);
            Assert.Equal(1, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);
            Qubit q00 = qm.Allocate();
            Assert.Equal(0, q0.Id);
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(1, qm.AllocatedQubitsCount);
            qm.Release(q0);
            Assert.Equal(1, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);
        }

        [Fact]
        public void QubitManagerRR_AllocDealloc2() {
            QubitManagerRestrictedReuse qm = new QubitManagerRestrictedReuse(2, encourageReuse: true);
            Qubit q0 = qm.Allocate();
            Assert.Equal(0, q0.Id);
            Qubit q1 = qm.Allocate();
            Assert.Equal(1, q1.Id);
            Assert.Throws<NotEnoughQubits>(() => qm.Allocate());
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(2, qm.AllocatedQubitsCount);

            qm.Release(q0);
            Qubit q0a = qm.Allocate();
            Assert.Equal(0, q0.Id);
            Assert.Throws<NotEnoughQubits>(() => qm.Allocate());

            qm.Release(q1);
            qm.Release(q0a);
            Assert.Equal(2, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);

            Qubit q0b = qm.Allocate();
            Assert.Equal(0, q0b.Id); // With encourageReuse=true last released should be allocated first.
            Qubit q1a = qm.Allocate();
            Assert.Equal(1, q1a.Id);
            Assert.Throws<NotEnoughQubits>(() => qm.Allocate());
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(2, qm.AllocatedQubitsCount);

            qm.Release(q1a);
            qm.Release(q0b);
        }

        [Fact]
        public void QubitManagerRR_ExtendingCapacity() {
            QubitManagerRestrictedReuse qm = new QubitManagerRestrictedReuse(
                1, mayExtendCapacity: true, encourageReuse: true);

            Qubit q0 = qm.Allocate();
            Assert.Equal(0, q0.Id);
            Qubit q1 = qm.Allocate(); // This should double capacity
            Assert.Equal(1, q1.Id);
            Assert.Equal(0, qm.FreeQubitsCount);
            Assert.Equal(2, qm.AllocatedQubitsCount);

            qm.Release(q0);
            Qubit q0a = qm.Allocate();
            Assert.Equal(0, q0a.Id);
            Qubit q3 = qm.Allocate(); // This should double capacity again
            Assert.Equal(2, q3.Id);
            Assert.Equal(1, qm.FreeQubitsCount);
            Assert.Equal(3, qm.AllocatedQubitsCount);

            qm.Release(q1);
            qm.Release(q0a);
            qm.Release(q3);
            Assert.Equal(4, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);

            IQArray<Qubit> qqq = qm.Allocate(3);
            Assert.Equal(1, qm.FreeQubitsCount);
            Assert.Equal(3, qm.AllocatedQubitsCount);
            qm.Release(qqq);
            Assert.Equal(4, qm.FreeQubitsCount);
            Assert.Equal(0, qm.AllocatedQubitsCount);
        }

        [Fact]
        public void QubitManagerRR_RestrictedArea() {
            QubitManagerRestrictedReuse qm = new QubitManagerRestrictedReuse(
                3, mayExtendCapacity: false, encourageReuse: true);

            Qubit q0 = qm.Allocate();
            Assert.Equal(0, q0.Id);

            qm.StartRestrictedReuseArea();

            // Allocates fresh qubit
            Qubit q1 = qm.Allocate();
            Assert.Equal(1, q1.Id);
            qm.Release(q1);

            qm.NextRestrictedReuseSegment();

            // Allocates fresh qubit, q1 cannot be reused - it belongs to a differen segment.
            Qubit q2 = qm.Allocate();
            Assert.Equal(2, q2.Id);
            qm.Release(q2);

            qm.NextRestrictedReuseSegment();

            // There's no qubits left here. q0 is allocates, q1 and q2 are from different segments.
            Assert.Throws<NotEnoughQubits>(() => qm.Allocate());

            qm.EndRestrictedReuseArea();

            // All qubits are available here again.
            Qubit qq = qm.Allocate();
            Assert.Equal(2, q2.Id);
        }



    }
}
