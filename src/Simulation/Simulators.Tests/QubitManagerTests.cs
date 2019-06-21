﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using System;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class QubitManagerTests
    {
        /// <summary>
        /// Test for QubitManager.
        /// </summary>
        [Fact]
        public void TestQubitManager()
        {
            QubitManager qm = new QubitManager(20);

            // Test allocation of single qubit
            Qubit q1 = qm.Allocate();
            Assert.True(q1.Id == 0);

            // Test allocation of multiple qubits
            var qa1 = qm.Allocate(4);
            Assert.True(qa1.Length == 4);
            Assert.True(qa1[0].Id == 1);
            Assert.True(qa1[1].Id == 2);
            Assert.True(qa1[2].Id == 3);
            Assert.True(qa1[3].Id == 4);

            // Test reuse of deallocated qubits
            qm.Release(qa1[1]);
            // Note: The Qb compiler today cannot release a single qubit that has been allocated as part of a group. 
            //       But QubitManager supports this anyway.

            Qubit q2 = qm.Allocate();
            Assert.True(q2.Id == 2);

            var qa2 = qm.Allocate(3);
            Assert.True(qa2.Length == 3);
            Assert.True(qa2[0].Id == 5);
            Assert.True(qa2[1].Id == 6);
            Assert.True(qa2[2].Id == 7);

            qm.Release(qa2);

            Qubit q3 = qm.Allocate();
            Assert.True(q3.Id == 7);

            Qubit q4 = qm.Allocate();
            Assert.True(q4.Id == 6);

            Qubit q5 = qm.Allocate();
            Assert.True(q5.Id == 5);

            // Test borrowing
            Qubit[] exclusion = new Qubit[4];
            exclusion[0] = qa1[0];
            exclusion[1] = qa1[2];
            exclusion[2] = q4;
            exclusion[3] = q3;

            long qubitsAvailable;

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qab = qm.Borrow(5, exclusion);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 1);
            Assert.True(qab[0].Id == 0);
            Assert.True(qab[1].Id == 2);
            Assert.True(qab[2].Id == 4);
            Assert.True(qab[3].Id == 5);
            Assert.True(qab[4].Id == 8);

            Qubit q6 = qm.Allocate();
            Assert.True(q6.Id == 9);

            // Test borrowing of the same qubit again
            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb1 = qm.Borrow(1, exclusion);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 0);
            Assert.True(qb1[0].Id == 0);
            qm.Return(qb1[0]);

            qm.Return(qab);

            // Test that qubit allocated for borrowing is freed after being returned
            Qubit q7 = qm.Allocate();
            Assert.True(q7.Id == 8);

            // Test allocation of qubits out of order.
            qm.Release(q4);
            qm.Release(qa1[2]);
            qm.Release(q1);

            var qa3 = qm.Allocate(4);
            Assert.True(qa3.Length == 4);
            Assert.True(qa3[0].Id == 0);
            Assert.True(qa3[1].Id == 3);
            Assert.True(qa3[2].Id == 6);
            Assert.True(qa3[3].Id == 10);

            // Test allocating qubits over capacity
            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                IQArray<Qubit> n_q;

                Assert.Throws<NotEnoughQubits>(() => n_q = qm.Allocate(10));
                Assert.Throws<NotEnoughQubits>(() => n_q = qm.Borrow(25, exclusion));

                Assert.Throws<ArgumentException>(() => n_q = qm.Allocate(0));
                Assert.Throws<ArgumentException>(() => n_q = qm.Allocate(-2));
                Assert.Throws<ArgumentException>(() => n_q = qm.Borrow(0, exclusion));
                Assert.Throws<ArgumentException>(() => n_q = qm.Borrow(-2, exclusion));
            });
        }

        /// <summary>
        /// Test for QubitManagerTrackingScope.
        /// </summary>
        [Fact]
        public void TestQubitManagerTrackingScope()
        {
            QubitManagerTrackingScope qm = new QubitManagerTrackingScope(20);

            Qubit q1 = qm.Allocate();
            Assert.True(q1.Id == 0);

            var qa1 = qm.Allocate(4);
            Assert.True(qa1.Length == 4);
            Assert.True(qa1[0].Id == 1);
            Assert.True(qa1[1].Id == 2);
            Assert.True(qa1[2].Id == 3);
            Assert.True(qa1[3].Id == 4);

            Qubit q2 = qm.Allocate();
            Assert.True(q2.Id == 5);

            qm.OnOperationStart(null, qa1);

            long qubitsAvailable;

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb1 = qm.Borrow(3);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 1);
            Assert.True(qb1[0].Id == 0);
            Assert.True(qb1[1].Id == 5);
            Assert.True(qb1[2].Id == 6);
            qm.Return(qb1[0]);
            qm.Return(qb1[2]);

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb2 = qm.Borrow(3);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 2);
            Assert.True(qb2[0].Id == 0);
            Assert.True(qb2[1].Id == 6);
            Assert.True(qb2[2].Id == 7);

            {
                qm.OnOperationStart(null, qb2);

                qubitsAvailable = qm.GetFreeQubitsCount();
                var qb3 = qm.Borrow(3);
                Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 0);
                Assert.True(qb3[0].Id == 1);
                Assert.True(qb3[1].Id == 2);
                Assert.True(qb3[2].Id == 3);

                qm.OnOperationEnd(null, QVoid.Instance); 
            }

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb4 = qm.Borrow(1);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 1);
            Assert.True(qb4[0].Id == 8);

            qm.OnOperationEnd(null, QVoid.Instance);
        }

        [Fact]
        public void TestQubitManagerDisabledBorrowing()
        {
            QubitManagerTrackingScope qm = new QubitManagerTrackingScope(20, mayExtendCapacity: true, disableBorrowing: true);

            Qubit q1 = qm.Allocate();
            Assert.True(q1.Id == 0);

            var qa1 = qm.Allocate(4);
            Assert.True(qa1.Length == 4);
            Assert.True(qa1[0].Id == 1);
            Assert.True(qa1[1].Id == 2);
            Assert.True(qa1[2].Id == 3);
            Assert.True(qa1[3].Id == 4);

            Qubit q2 = qm.Allocate();
            Assert.True(q2.Id == 5);

            qm.OnOperationStart(null, qa1);

            long qubitsAvailable;

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb1 = qm.Borrow(3);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 3);
            Assert.True(qb1[0].Id == 6);
            Assert.True(qb1[1].Id == 7);
            Assert.True(qb1[2].Id == 8);

            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 11);
            qm.Return(qb1[0]);
            qm.Return(qb1[2]);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 13);

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb2 = qm.Borrow(3);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 3);
            Assert.True(qb2[0].Id == 8);
            Assert.True(qb2[1].Id == 6);
            Assert.True(qb2[2].Id == 9);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 10);

            {
                qm.OnOperationStart(null, qb2);

                qubitsAvailable = qm.GetFreeQubitsCount();
                var qb3 = qm.Borrow(3);
                Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 3);
                Assert.True(qb3[0].Id == 10);
                Assert.True(qb3[1].Id == 11);
                Assert.True(qb3[2].Id == 12);

                qubitsAvailable = qm.GetFreeQubitsCount();
                Assert.True(qubitsAvailable == 7);

                qm.OnOperationEnd(null, QVoid.Instance);
            }

            qm.Release(qb2[1]);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 8);

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb4 = qm.Borrow(1);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 1);
            Assert.True(qb4[0].Id == 6);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 7);

            qm.OnOperationEnd(null, QVoid.Instance);
        }

        [Fact]
        public void TestQubitManagerGrowth()
        {
            QubitManagerTrackingScope qm = new QubitManagerTrackingScope(7, mayExtendCapacity : true, disableBorrowing: false);

            Qubit q1 = qm.Allocate();
            Assert.True(q1.Id == 0);

            var qa1 = qm.Allocate(4);
            Assert.True(qa1.Length == 4);
            Assert.True(qa1[0].Id == 1);
            Assert.True(qa1[1].Id == 2);
            Assert.True(qa1[2].Id == 3);
            Assert.True(qa1[3].Id == 4);

            Qubit q2 = qm.Allocate();
            Assert.True(q2.Id == 5);

            qm.OnOperationStart(null, qa1);

            long qubitsAvailable;

            qubitsAvailable = qm.GetFreeQubitsCount();
            var qb1 = qm.Borrow(3);
            Assert.True(qubitsAvailable - qm.GetFreeQubitsCount() == 1);
            Assert.True(qb1[0].Id == 0);
            Assert.True(qb1[1].Id == 5);
            Assert.True(qb1[2].Id == 6);
            qm.Return(qb1[0]);
            qm.Return(qb1[2]);

            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 1);
            var qb2 = qm.Borrow(3); // This should grow qubit capacity
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 6);
            Assert.True(qb2[0].Id == 0);
            Assert.True(qb2[1].Id == 6);
            Assert.True(qb2[2].Id == 7);

            qm.OnOperationEnd(null, null);

            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 6);
            var qa2 = qm.Allocate(4);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 2);
            Assert.True(qa2.Length == 4);
            Assert.True(qa2[0].Id == 8);
            Assert.True(qa2[1].Id == 9);
            Assert.True(qa2[2].Id == 10);
            Assert.True(qa2[3].Id == 11);

            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 2);
            qm.Release(qa2[0]);
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 3);

            var qa3 = qm.Allocate(4); // This should grow qubit capacity
            qubitsAvailable = qm.GetFreeQubitsCount();
            Assert.True(qubitsAvailable == 13);
            Assert.True(qa3.Length == 4);
            Assert.True(qa3[0].Id == 8);
            Assert.True(qa3[1].Id == 12);
            Assert.True(qa3[2].Id == 13);
            Assert.True(qa3[3].Id == 14);
        }
    }
}
