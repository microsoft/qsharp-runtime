﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
using Xunit;

using static System.Math;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class State 
    {
        public State((double, double) alpha, (double, double) beta)
        {
            Alpha = new Microsoft.Quantum.Math.Complex(alpha);
            Beta = new Microsoft.Quantum.Math.Complex(beta);
        }

        public Microsoft.Quantum.Math.Complex Alpha { get; }

        public Microsoft.Quantum.Math.Complex Beta { get; }

        public (Microsoft.Quantum.Math.Complex, Microsoft.Quantum.Math.Complex) Value => (Alpha, Beta);


    }

    public partial class QuantumSimulatorTests
    {
        public const int seed = 19740212;
        public static System.Random r = new System.Random(seed);

        public static double sqrt1_2 = Sqrt(1.0 / 2.0);

        public static (double, double) E_i(double angle)
        {
            return (Cos(angle), Sin(angle));
        }

        public static (double, double) times(double d, (double, double) c)
        {
            var (r, i) = c;
            return ((d * r, d * i));
        }

        public static double Angle(int nom, int powerDen)
        {
            return (PI * nom / (1 << powerDen));
        }

        /// <summary>
        /// It runs the circuit to verify that the given one-qubit unitary gate performs
        /// the right operation. For it, it receives an array of the expected states that the
        /// Qubit must be in if starting from:
        /// |0>, |1>, |+>, |->
        /// accordingly.
        /// </summary>
        private static void VerifyGate(IOperationFactory sim, IUnitary<Qubit> gate, State[] expected)
        {
            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                var starts = new ValueTuple<Pauli, Result>[] {
                    (Pauli.PauliZ, Result.Zero),
                    (Pauli.PauliZ, Result.One),
                    (Pauli.PauliX, Result.Zero),
                    (Pauli.PauliX, Result.One)
                };

                for (int i = 0; i < expected.Length; i++)
                {
                    VerifyUnitary.Run(sim, gate, starts[i], expected[i].Value).Wait();
                }
            });
        }

        private static void VerifyInvalidAngles(IOperationFactory sim, IUnitary<(double, Qubit)> gate)
        {
            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                var q = sim.Get<Intrinsic.Allocate>(typeof(Intrinsic.Allocate)).Apply(1);

                Assert.Throws<ArgumentOutOfRangeException>(() => gate.Apply((Double.NaN, q[0])));
                Assert.Throws<ArgumentOutOfRangeException>(() => gate.Apply((Double.PositiveInfinity, q[0])));
                Assert.Throws<ArgumentOutOfRangeException>(() => gate.Apply((Double.NegativeInfinity, q[0])));
            });
        }

        [Fact]
        public void QSimVerifyH()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.H>();
                    VerifyGate(sim, gate, new State[]
                    {
                        new State((sqrt1_2, 0.0), (sqrt1_2, .0)),
                        new State((sqrt1_2, 0.0), (-1 * sqrt1_2, .0)),
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((0.0, 0.0), (1.0, 0.0)),
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyX()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.X>();

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((0.0, 0.0), (1.0, 0.0)),
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((sqrt1_2, 0.0), (sqrt1_2, 0.0)),
                        new State((-sqrt1_2, 0.0), (sqrt1_2, 0.0))
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyY()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.Y>();

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((0.0, 0.0), (0.0, 1.0)),
                        new State((0.0, -1.0), (0.0, 0.0)),
                        new State((0.0, -sqrt1_2), (0.0, sqrt1_2)),
                        new State((0.0, sqrt1_2), (0.0, sqrt1_2)),
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyZ()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.Z>();

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((0.0, 0.0), (-1.0, 0.0)),
                        new State((sqrt1_2, 0.0), (-sqrt1_2, 0.0)),
                        new State((sqrt1_2, 0.0), (sqrt1_2, 0.0))
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyS()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.S>();

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((0.0, 0.0), (0.0, 1.0)),
                        new State((sqrt1_2, 0.0), (0.0, sqrt1_2)),
                        new State((sqrt1_2, 0.0), (0.0, -sqrt1_2))
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyT()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.T>();

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((0.0, 0.0), E_i(PI / 4)),
                        new State((sqrt1_2, 0.0), times(sqrt1_2, E_i(PI / 4))),
                        new State((sqrt1_2, 0.0), times(-sqrt1_2, E_i(PI / 4)))
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyR1()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var angle = PI * r.NextDouble();
                    Func<Qubit, (double, Qubit)> mapper = (q) => (angle, q);

                    var gate = sim.Get<Intrinsic.R1>().Partial(mapper);

                    VerifyGate(sim, gate, new State[]
                    {
                        new State((1.0, 0.0), (0.0, 0.0)),
                        new State((0.0, 0.0), E_i(angle)),
                        new State((sqrt1_2, 0.0), times(sqrt1_2, E_i(angle))),
                        new State((sqrt1_2, 0.0), times(-sqrt1_2, E_i(angle)))
                    });
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        /// <summary>
        /// Returns the expected states when applying a rotation with the given angle
        /// to the Qubit starting from |0>,|1>,|+>,|-> accordingly
        /// </summary>
        public static State[] ExponentExpectedStates(Pauli basis, double angle)
        {
            switch (basis)
            {
                case Pauli.PauliX:
                    return new State[]
                    {
                        new State((Cos(angle), 0.0), (0.0, Sin(angle))),
                        new State((0.0, Sin(angle)), (Cos(angle), 0.0)),
                        new State((sqrt1_2 * Cos(angle), sqrt1_2 * Sin(angle)), (sqrt1_2 * Cos(angle), sqrt1_2 * Sin(angle))),
                        new State((sqrt1_2 * Cos(angle), -sqrt1_2 * Sin(angle)), (-sqrt1_2 * Cos(angle), sqrt1_2 * Sin(angle))),
                    };
                case Pauli.PauliY:
                    return new State[]
                    {
                        new State((Cos(angle), 0.0), (-Sin(angle), 0.0)),
                        new State((Sin(angle), 0.0), (Cos(angle), 0.0)),
                        new State((sqrt1_2 * (Cos(angle) + Sin(angle)), 0.0), (sqrt1_2 * (Cos(angle) - Sin(angle)), 0.0)),
                        new State((sqrt1_2 * (Cos(angle) - Sin(angle)), 0.0), (sqrt1_2 * (-Cos(angle) - Sin(angle)), 0.0))
                    };
                case Pauli.PauliZ:
                    return new State[]
                    {
                        new State(E_i(angle), (0.0, 0.0)),
                        new State((0.0, 0.0), E_i(-angle)),
                        new State(times(sqrt1_2, E_i(angle)), times(sqrt1_2, E_i(-angle))),
                        new State(times(sqrt1_2, E_i(angle)), times(-sqrt1_2, E_i(-angle)))
                    };
                case Pauli.PauliI:
                    return new State[]
                    {
                        new State(E_i(angle), (0.0, 0.0)),
                        new State((0.0, 0.0), E_i(angle)),
                        new State(times(sqrt1_2, E_i(angle)), times(sqrt1_2, E_i(angle))),
                        new State(times(sqrt1_2, E_i(angle)), times(-sqrt1_2, E_i(angle))),
                    };
                default:
                    throw new InvalidOperationException();
            }
        }

        public static State[] ExponentExpectedStates(Pauli basis, int nom, int powerDen)
        {
            return ExponentExpectedStates(basis, Angle(nom, powerDen));
        }

        public static State[] RExpectedStates(Pauli basis, double angle)
        {
            return ExponentExpectedStates(basis, (-angle / 2));
        }

        public static State[] RExpectedStates(Pauli basis, int nom, int powerDen)
        {
            return ExponentExpectedStates(basis, Angle(nom, powerDen));
        }

        [Fact]
        public void QSimVerifyRx()
        {
            var angle = 2 * PI * r.NextDouble();
            Func<Qubit, (double, Qubit)> mapper = (q)
                => (angle, q);

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.Rx>().Partial(mapper);
                    VerifyGate(sim, gate, RExpectedStates(Pauli.PauliX, angle));

                    VerifyInvalidAngles(sim, sim.Get<Intrinsic.Rx>());
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyRy()
        {
            var angle = 2 * PI * r.NextDouble();
            Func<Qubit, (double, Qubit)> mapper = (q)
                => (angle, q);

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.Ry>().Partial(mapper);
                    VerifyGate(sim, gate, RExpectedStates(Pauli.PauliY, angle));

                    VerifyInvalidAngles(sim, sim.Get<Intrinsic.Ry>());
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyRz()
        {
            var angle = 2 * PI * r.NextDouble();
            Func<Qubit, (double, Qubit)> mapper = (q)
                => (angle, q);

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.Rz>().Partial(mapper);
                    VerifyGate(sim, gate, RExpectedStates(Pauli.PauliZ, angle));

                    VerifyInvalidAngles(sim, sim.Get<Intrinsic.Rz>());
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyR()
        {
            var angle = 2 * PI * r.NextDouble();
            Func<Qubit, (Pauli, double, Qubit)> mapper = (q)
                => (Pauli.PauliI, angle, q);
            Func<(double, Qubit), (Pauli, double, Qubit)> needsAngle = (__arg) 
                => (Pauli.PauliX, __arg.Item1, __arg.Item2);

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var gate = sim.Get<Intrinsic.R>().Partial(mapper);
                    VerifyGate(sim, gate, RExpectedStates(Pauli.PauliI, angle));

                    var angleGate = sim.Get<Intrinsic.R>().Partial(needsAngle);
                    VerifyInvalidAngles(sim, angleGate);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyRFrac()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var allBases = new[] { Pauli.PauliI, Pauli.PauliX, Pauli.PauliZ, Pauli.PauliY };

                    for (var k = 0; k < 4; k++)
                    {
                        for (var n = 0; n < 3; n++)
                        {
                            foreach (var p in allBases)
                            {
                                Func<Qubit, (Pauli, long, long, Qubit)> mapper = (q) => (p, k, n, q);
                                var gate = sim.Get<Intrinsic.RFrac>().Partial(mapper);

                                VerifyGate(sim, gate, RExpectedStates(p, k, n));
                            }
                        }
                    }
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        private void VerifyExp(Pauli pauli)
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var angle = 2 * PI * r.NextDouble();

                    Func<Qubit, (IQArray<Pauli>, double, IQArray<Qubit>)> mapper = (q)
                        => (new QArray<Pauli> (pauli), angle, new QArray<Qubit> (q));
                    var gate = sim.Get<Intrinsic.Exp>().Partial(mapper);

                    VerifyGate(sim, gate, ExponentExpectedStates(pauli, angle));

                    Func<(double, Qubit), (IQArray<Pauli>, double, IQArray<Qubit>)> needsAngle = (__arg)
                        => (new QArray<Pauli> (pauli), __arg.Item1, new QArray<Qubit> (__arg.Item2));
                    var angleGate = sim.Get<Intrinsic.Exp>().Partial(needsAngle);
                    if (pauli != Pauli.PauliI)
                    {
                        VerifyInvalidAngles(sim, angleGate);
                    }
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimVerifyExp()
        {
            VerifyExp(Pauli.PauliI);
        }

        [Fact]
        public void QSimVerifyExpY()
        {
            VerifyExp(Pauli.PauliY);
        }

        [Fact]
        public void QSimVerifyExpZ()
        {
            VerifyExp(Pauli.PauliZ);
        }

        [Fact]
        public void QSimVerifyExpX()
        {
            VerifyExp(Pauli.PauliX);
        }

        [Fact]
        public void QSimVerifyExpUsingDecompositions()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };
            
            foreach (var sim in simulators)
            {
                VerifyExpUsingDecompositions.Run(sim).Wait();
            }
        }

        [Fact]
        public void QSimVerifyExpFrac()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var allBases = new[] { Pauli.PauliI, Pauli.PauliX, Pauli.PauliZ, Pauli.PauliY };

                    for (var k = 0; k < 4; k++)
                    {
                        for (var n = 0; n < 3; n++)
                        {
                            foreach (var p in allBases)
                            {
                                Func<Qubit, (IQArray<Pauli>, long, long, IQArray<Qubit>)> mapper = (q)
                                    => (new QArray<Pauli> (p), k, n, new QArray<Qubit> (q));
                                var gate = sim.Get<Intrinsic.ExpFrac>().Partial(mapper);

                                VerifyGate(sim, gate, ExponentExpectedStates(p, k, n));
                            }
                        }
                    }
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimMeasure()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var op = sim.Get<ICallable<QVoid, QVoid>, JointMeasureTest>();
                    op.Apply(QVoid.Instance);
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimM()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var m = sim.Get<Intrinsic.M>();

                    var allocate = sim.Get<Intrinsic.Allocate>();
                    var release = sim.Get<Intrinsic.Release>();
                    var x = sim.Get<Intrinsic.X>();

                    var qbits = allocate.Apply(1);
                    Assert.Single(qbits);

                    var q = qbits[0];
                    var result = m.Apply(q);
                    Assert.Equal(Result.Zero, result);

                    x.Apply(q);
                    result = m.Apply(q);
                    Assert.Equal(Result.One, result);
                    x.Apply(q);

                    release.Apply(qbits);
                    sim.CheckNoQubitLeak();
                }
                finally
                {
                    sim.Dispose();
                }
            }
        }

        [Fact]
        public void QSimMeasureEachZTest()
        {
            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };
            
            foreach (var sim in simulators)
            {
                MeasureEachZTest.Run(sim).Wait();
            }
        }
    }
}
