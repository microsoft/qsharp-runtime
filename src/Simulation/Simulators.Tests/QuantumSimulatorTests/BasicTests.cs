﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public partial class QuantumSimulatorTests
    {
        [Fact]
        public void QSimConstructor()
        {
            using (var subject = new QuantumSimulator())
            {
                Assert.Equal("Quantum Simulator", subject.Name);
            }
        }

        [Fact]
        public void SparseSimConstructor()
        {
            using var subject = new SparseSimulator2();
            Assert.Equal("SparseSimulator2", subject.Name);
        }

        [Fact]
        public void QSimVerifyPrimitivesCompleteness()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator2()
            };

            foreach (var sim in simulators)
            // using (var sim = new QuantumSimulator())
            {
                try
                {
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
                            var i = sim.GetInstance(op);
                            Assert.NotNull(i);
                        }
                        catch (Exception)
                        {
                            missing.Add(op);
                        }
                    }

                    Assert.Empty(missing);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimX()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
            };

            //using (var sim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
            foreach (var sim in simulators)
            {
                try
                {
                    var x = sim.Get<Intrinsic.X>();
                    var measure = sim.Get<Intrinsic.M>();
                    var set = sim.Get<Measurement.SetToBasisState>();

                    var ctrlX = x.__ControlledBody__.AsAction();
                    OperationsTestHelper.ctrlTestShell(sim, ctrlX, (enabled, ctrls, q) =>
                    {
                        set.Apply((Result.Zero, q));
                        var result = measure.Apply(q);
                        var expected = Result.Zero;
                        Assert.Equal(expected, result);

                        x.__ControlledBody__((ctrls, q));
                        result = measure.Apply(q);
                        expected = (enabled) ? Result.One : Result.Zero;
                        Assert.Equal(expected, result);
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimMultithreading()
        {
            var count = 5;
            var tasks = new Task[count];

            for (int i = 0; i < count; i++)
            {
                tasks[i] = Task.Run(() =>
                {
                    QSimVerifyX();
                    QSimVerifyY();
                    QSimVerifyZ();
                    QSimVerifyExp();
                });
            }

            Task.WaitAll(tasks);
        }


        [Fact]
        public void QSimRandom()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator2()
            };

            //using (var sim = new QuantumSimulator())
            foreach (var sim in simulators)
            {
                try
                {
                    var r = sim.Get<Intrinsic.Random>();
                    var probs = new QArray<double> (0.0, 0.0, 0.0, 0.7, 0.0, 0.0);
                    var result = r.Apply(probs);
                    Assert.Equal(3, result);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimAssert()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator2()
            };

            foreach (var sim in simulators)
            //using (var sim = new QuantumSimulator())
            {
                try
                {
                    var assert = sim.Get<Intrinsic.Assert>();
                    var h = sim.Get<Intrinsic.H>();

                    Func<Qubit, (IQArray<Pauli>, IQArray<Qubit>, Result, string)> mapper =
                        (q) => (new QArray<Pauli>(Pauli.PauliZ), new QArray<Qubit> (q), Result.Zero, "Assert failed");
                    var applyWithZero = new OperationPartial<Qubit, (IQArray<Pauli>, IQArray<Qubit>, Result, string), QVoid>(assert, mapper);

                    OperationsTestHelper.applyTestShell(sim, applyWithZero, (q) =>
                    {
                        h.Apply(q);
                        assert.Apply((new QArray<Pauli>(Pauli.PauliX), new QArray<Qubit> (q), Result.Zero, "Assert failed"));

                        OperationsTestHelper.IgnoreDebugAssert(() =>
                        {
                            Assert.Throws<ExecutionFailException>(() => assert.Apply((new QArray<Pauli> (Pauli.PauliX), new QArray<Qubit> (q), Result.One, "Assert failed")));

                            h.Apply(q);
                            Assert.Throws<ExecutionFailException>(() => assert.Apply((new QArray<Pauli> (Pauli.PauliZ), new QArray<Qubit> (q), Result.One, "Assert failed")));
                        });

                        assert.Apply((new QArray<Pauli> (Pauli.PauliZ), new QArray<Qubit>(q), Result.Zero, "Assert failed"));
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }


        [Fact]
        public void QSimAssertProb()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator2()
            };

            foreach (var sim in simulators)
            //using (var sim = new QuantumSimulator())
            {
                try
                {
                    var tolerance = 0.02;
                    var assertProb = sim.Get<Intrinsic.AssertProb>();
                    var h = sim.Get<Intrinsic.H>();
                    var allocate = sim.Get<Intrinsic.Allocate>();
                    var release = sim.Get<Intrinsic.Release>();

                    Func<Qubit, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double)> mapper = (q) =>
                    {
                        return (new QArray<Pauli>(Pauli.PauliZ), new QArray<Qubit>(q), Result.Zero, 1.0, "Assert failed", tolerance);
                    };
                    var applyWithZero = new OperationPartial<Qubit, (IQArray<Pauli>, IQArray<Qubit>, Result, double, string, double), QVoid>(assertProb, mapper);

                    OperationsTestHelper.applyTestShell(sim, applyWithZero, (q1) =>
                    {
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ), new QArray<Qubit>(q1), Result.One, 0.01, "Assert failed", tolerance));

                        // Within tolerance
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliX), new QArray<Qubit> (q1), Result.Zero, 0.51, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliX), new QArray<Qubit> (q1), Result.One, 0.51, "Assert failed", tolerance));
                        // Outside of tolerance
                        OperationsTestHelper.IgnoreDebugAssert(() =>
                        {
                            Assert.Throws<ExecutionFailException>(() => assertProb.Apply((new QArray<Pauli>(Pauli.PauliX), new QArray<Qubit>(q1), Result.One, 0.51, "Assert failed", 0.0)));
                            Assert.Throws<ExecutionFailException>(() => assertProb.Apply((new QArray<Pauli>(Pauli.PauliX), new QArray<Qubit>(q1), Result.Zero, 0.51, "Assert failed", 0.0)));
                        });

                        // Add a qubit
                        var qubits = allocate.Apply(1);
                        var q2 = qubits[0];

                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ), new QArray<Qubit> (q1), Result.Zero, 0.99, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ), new QArray<Qubit> (q1), Result.One, 0.01, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliZ), new QArray<Qubit> (q1, q2), Result.Zero, 0.99, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliZ), new QArray<Qubit> (q1, q2), Result.One, 0.01, "Assert failed", tolerance));

                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliX), new QArray<Qubit> (q1, q2), Result.Zero, 0.51, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliX, Pauli.PauliZ), new QArray<Qubit> (q1, q2), Result.Zero, 0.51, "Assert failed", tolerance));
                        assertProb.Apply((new QArray<Pauli> (Pauli.PauliX, Pauli.PauliX), new QArray<Qubit> (q1, q2), Result.Zero, 0.51, "Assert failed", tolerance));

                        OperationsTestHelper.IgnoreDebugAssert(() =>
                        {
                            // Outside of tolerance
                            Assert.Throws<ExecutionFailException>(() => assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliZ), new QArray<Qubit> (q1, q2), Result.Zero, 0.51, "Assert failed", 0.0)));
                            Assert.Throws<ExecutionFailException>(() => assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliZ), new QArray<Qubit> (q1, q2), Result.One, 0.51, "Assert failed", 0.0)));

                            // Missmatch number of arrays
                            Assert.Throws<InvalidOperationException>(() => assertProb.Apply((new QArray<Pauli> (Pauli.PauliZ, Pauli.PauliZ), new QArray<Qubit> (q1), Result.Zero, 0.51, "Assert failed", tolerance)));
                        });

                        release.Apply(qubits);
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        private static void TestCallable<O>(ICallable<Qubit, O> gate, Qubit target)
        {
            gate.Apply(target);
            Assert.Throws<ArgumentNullException>(() => gate.Apply(null));
        }

        private static void TestControllable(IControllable<Qubit> gate, IQArray<Qubit> ctrls, Qubit target)
        {
            var nullTarget = new Func<Qubit, (IQArray<Qubit>, Qubit)>(q => (ctrls, q));
            var nullCtrl = new Func<Qubit, (IQArray<Qubit>, Qubit)>(q => (new QArray<Qubit>(q, ctrls[1], ctrls[2]), target));

            var dupeTarget = new QArray<Qubit>(target, ctrls[1], ctrls[2]);
            var dupeCtrls1 = new QArray<Qubit>(ctrls[1], ctrls[1], ctrls[2]);
            var dupeCtrls2 = new QArray<Qubit>(ctrls[0], ctrls[1], ctrls[0]);

            TestCallable(gate, target);
            TestCallable(gate.Controlled.Partial(nullTarget), target);
            TestCallable(gate.Controlled.Partial(nullCtrl), ctrls[0]);

            // Some decompositions actually allow for duplications in controls, so these tests
            // should be skipped for those packages.
            if (OperationsTestHelper.ShouldPerformQubitUniquenessTest)
            {
                Assert.Throws<NotDistinctQubits>(() => gate.Controlled.Apply((dupeTarget, target)));
                Assert.Throws<NotDistinctQubits>(() => gate.Controlled.Apply((dupeCtrls1, target)));
                Assert.Throws<NotDistinctQubits>(() => gate.Controlled.Apply((dupeCtrls2, target)));
            }
        }

        private static void TestUnitary(IUnitary<Qubit> gate, IQArray<Qubit> ctrls, IQArray<Qubit> target)
        {
            TestCallable(gate, target[0]);
            TestCallable(gate.Adjoint, target[0]);
            TestControllable(gate, ctrls, target[0]);
            TestControllable(gate.Adjoint, ctrls, target[0]);
        }

        private static void TestMultiCallable<O>(ICallable<IQArray<Qubit>, O> gate, IQArray<Qubit> targets)
        {
            var mapper = new Func<Qubit, IQArray<Qubit>>(q => new QArray<Qubit>(q, targets[1], targets[2]));
            var dupTargets = new QArray<Qubit>(targets[0], targets[1], targets[0]);

            if (OperationsTestHelper.ShouldPerformQubitUniquenessTest)
            {
                Assert.Throws<NotDistinctQubits>(() => gate.Apply(dupTargets));
            }
            TestCallable(gate.Partial(mapper), targets[0]);
        }

        private static void TestMultiControllable(IControllable<IQArray<Qubit>> gate, IQArray<Qubit> ctrls, IQArray<Qubit> targets)
        {
            var mapper = new Func<Qubit, IQArray<Qubit>>(q => new QArray<Qubit>(q, targets[1], targets[2]));

            TestControllable(gate.Partial(mapper), ctrls, targets[0]);
        }

        private static void TestMultiUnitary(IUnitary<IQArray<Qubit>> gate, IQArray<Qubit> ctrls, IQArray<Qubit> targets)
        {
            TestMultiCallable(gate, targets);
            TestMultiCallable(gate.Adjoint, targets);
            TestMultiControllable(gate, ctrls, targets);
            TestMultiControllable(gate.Adjoint, ctrls, targets);
        }

        //private void TestOne<T>(QuantumSimulator qsim, T gate, Action<T, IQArray<Qubit>, IQArray<Qubit>> action)
        private void TestOne<T>(CommonNativeSimulator qsim, T gate, Action<T, IQArray<Qubit>, IQArray<Qubit>> action)
        {
            var allocate = qsim.Get<Intrinsic.Allocate>();
            var release = qsim.Get<Intrinsic.Release>();

            var targets = allocate.Apply(3);
            var ctrls = allocate.Apply(3);

            try
            {
                action(gate, ctrls, targets);
            }
            finally
            {
                release.Apply(ctrls);
                release.Apply(targets);
            }
        }

        [Fact]
        public void TestSimpleGateCheckQubits()
        {
            // Single Qubit gates:
            {
                var gateTypes = new Type[]
                {
                    typeof(Intrinsic.H),
                    typeof(Intrinsic.S),
                    typeof(Intrinsic.T),
                    typeof(Intrinsic.X),
                    typeof(Intrinsic.Y),
                    typeof(Intrinsic.Z)
                };

                foreach (var t in gateTypes)
                {
                    var simulators = new CommonNativeSimulator[] { 
                        new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                        new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
                    };

                    foreach (var qsim in simulators)
                    // using (var qsim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
                    {
                        var gate = qsim.Get<IUnitary<Qubit>>(t);
                        TestOne(qsim, gate, TestUnitary);
                    }
                }
            }
        }

        [Fact]
        public void TestRCheckQubits()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
            };

            foreach (var qsim in simulators)
            // using (var qsim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
            {
                try
                {
                    // R
                    var mapper = new Func<Qubit, (Pauli, Double, Qubit)>(qubit => (Pauli.PauliZ, 1.0, qubit));
                    var gate = qsim.Get<Intrinsic.R>();
                    var p = gate.Partial(mapper);
                    TestOne(qsim, p, TestUnitary);
                }
                finally
                {
                    qsim.Dispose();
                }
            }
        }

        [Fact]
        public void TestExpCheckQubits()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
            };

            foreach (var qsim in simulators)
            // using (var qsim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
            {
                try
                {
                    // Exp
                    {
                        var mapper = new Func<IQArray<Qubit>, (IQArray<Pauli>, Double, IQArray<Qubit>)>(qubits => (new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliX, Pauli.PauliY), 1.0, qubits));
                        var gate = qsim.Get<Intrinsic.Exp>();
                        var p = gate.Partial(mapper);
                        TestOne(qsim, p, TestMultiUnitary);
                    }

                    // ExpFrac
                    {
                        var mapper = new Func<IQArray<Qubit>, (IQArray<Pauli>, long, long, IQArray<Qubit>)>(qubits => (new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliX, Pauli.PauliY), 1, 2, qubits));
                        var gate = qsim.Get<Intrinsic.ExpFrac>();
                        var p = gate.Partial(mapper);
                        TestOne(qsim, p, TestMultiUnitary);
                    }
                }
                finally
                {
                    qsim.Dispose();
                }
            }
        }


        [Fact]
        public void TestMeasureCheckQubits()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
            };

            foreach (var qsim in simulators)
            // using (var qsim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
            {
                try
                {
                    // M
                    {
                        var gate = qsim.Get<Intrinsic.M>();
                        TestOne(qsim, gate, (g, ctrls, t) => TestCallable(g, t[0]));
                    }

                    // Measure
                    {
                        var gate = qsim.Get<Intrinsic.Measure>();
                        var mapper = new Func<IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>)>(qubits => (new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliI, Pauli.PauliI), qubits));
                        var p = gate.Partial(mapper);

                        // On systems that decompose joint measurement a qubit can actually be duplictated in
                        // the targets, so skip the duplicate qubit check.
                        TestOne(qsim, p, (g, ctrls, t) => TestMultiCallable<Result>(p, t));
                    }
                }
                finally
                {
                    qsim.Dispose();
                }
            }
        }

        [Fact]
        public void TestAssertCheckQubits()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false),
                new SparseSimulator2(throwOnReleasingQubitsNotInZeroState: false)
            };

            foreach (var qsim in simulators)
            // using (var qsim = new QuantumSimulator(throwOnReleasingQubitsNotInZeroState: false))
            {
                try
                {
                    // Assert
                    {
                        var gate = qsim.Get<Intrinsic.Assert>();
                        var mapper = new Func<IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, String)>(qubits => (new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliI, Pauli.PauliI), qubits, Result.Zero, ""));
                        var p = gate.Partial(mapper);
                        TestOne(qsim, gate, (g, ctrls, t) => TestMultiCallable(p, t));
                    }

                    // AssertProb
                    {
                        var gate = qsim.Get<Intrinsic.AssertProb>();
                        var mapper = new Func<IQArray<Qubit>, (IQArray<Pauli>, IQArray<Qubit>, Result, Double, String, Double)>(qubits => (new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliI, Pauli.PauliI), qubits, Result.Zero, 1.000, "", 0.002));
                        var p = gate.Partial(mapper);
                        TestOne(qsim, p, (g, ctrls, t) => TestMultiCallable(p, t));
                    }
                }
                finally
                {
                    qsim.Dispose();
                }
            }
        }
    }
}
