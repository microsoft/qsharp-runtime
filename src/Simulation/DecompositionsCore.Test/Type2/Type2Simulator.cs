// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators;

namespace Test.Decompositions
{
    public class Type2Simulator : QuantumSimulator
    {
        public Type2Simulator()
            : base()
        { }

        public class Type2SimulatorX : X
        {
            private QuantumSimulator.QSimX Simulator { get; }

            public Type2SimulatorX(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimX(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;
        }

        public class Type2SimulatorY : Y
        {
            private QuantumSimulator.QSimY Simulator { get; }

            public Type2SimulatorY(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimY(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;
        }

        public class Type2SimulatorZ : Z
        {
            private QuantumSimulator.QSimZ Simulator { get; }

            public Type2SimulatorZ(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimZ(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;
        }

        public class Type2SimulatorH : H
        {
            private QuantumSimulator.QSimH Simulator { get; }

            public Type2SimulatorH(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimH(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;
        }

        public class Type2SimulatorS : S
        {
            private QuantumSimulator.QSimS Simulator { get; }

            public Type2SimulatorS(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimS(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;

            public override Func<Qubit, QVoid> AdjointBody => Simulator.AdjointBody;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledAdjointBody => Simulator.ControlledAdjointBody;
        }

        public class Type2SimulatorT : T
        {
            private QuantumSimulator.QSimT Simulator { get; }

            public Type2SimulatorT(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimT(m);
            }

            public override Func<Qubit, QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => Simulator.ControlledBody;

            public override Func<Qubit, QVoid> AdjointBody => Simulator.AdjointBody;

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledAdjointBody => Simulator.ControlledAdjointBody;
        }

        public class Type2SimulatorSWAP : SWAP
        {
            private QuantumSimulator.QSimX Simulator { get; }

            public Type2SimulatorSWAP(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimX(m);
            }

            public override Func<(Qubit, Qubit), QVoid> Body => (args) =>
             {
                 (Qubit q1, Qubit q2) = args;
                 Simulator.ControlledBody((new QArray<Qubit>(q1), q2));
                 Simulator.ControlledBody((new QArray<Qubit>(q2), q1));
                 Simulator.ControlledBody((new QArray<Qubit>(q1), q2));
                 return QVoid.Instance;
             };

            public override Func<(IQArray<Qubit>, (Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                (IQArray<Qubit> ctrls, (Qubit q1, Qubit q2)) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Body((q1, q2));
                }
                else
                {
                    Simulator.ControlledBody((QArray<Qubit>.Add(ctrls, new QArray<Qubit>(q1)), q2));
                    Simulator.ControlledBody((QArray<Qubit>.Add(ctrls, new QArray<Qubit>(q2)), q1));
                    Simulator.ControlledBody((QArray<Qubit>.Add(ctrls, new QArray<Qubit>(q1)), q2));
                }

                return QVoid.Instance;
            };
        }

        public class Type2SimulatorR : R
        {
            private QuantumSimulator.QSimR Simulator { get; }

            public Type2SimulatorR(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimR(m);
            }

            public override Func<(Pauli, double, Qubit), QVoid> Body => Simulator.Body;

            public override Func<(Pauli, double, Qubit), QVoid> AdjointBody => Simulator.AdjointBody;

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledBody => Simulator.ControlledBody;

            public override Func<(IQArray<Qubit>, (Pauli, double, Qubit)), QVoid> ControlledAdjointBody => Simulator.ControlledAdjointBody;
        }

        public class Type2SimulatorExp : Exp
        {
            private QuantumSimulator.QSimExp Simulator { get; }

            public Type2SimulatorExp(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimExp(m);
            }

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> Body => Simulator.Body;

            public override Func<(IQArray<Pauli>, double, IQArray<Qubit>), QVoid> AdjointBody => Simulator.AdjointBody;

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledBody => Simulator.ControlledBody;

            public override Func<(IQArray<Qubit>, (IQArray<Pauli>, double, IQArray<Qubit>)), QVoid> ControlledAdjointBody => Simulator.ControlledAdjointBody;
        }

        public class Type2SimulatorM : M
        {
            private QuantumSimulator.QSimM Simulator { get; }

            public Type2SimulatorM(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimM(m);
            }

            public override Func<Qubit, Result> Body => Simulator.Body;
        }

        public class Type2SimulatorApplyIsingXX : IsingXX
        {
            private QuantumSimulator.QSimExp Simulator { get; }

            public Type2SimulatorApplyIsingXX(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimExp(m);
            }

            public override Func<(double, Qubit, Qubit), QVoid> Body => (args) =>
            {
                (double theta, Qubit q1, Qubit q2) = (args);
                Simulator.Body(((new QArray<Pauli>(Pauli.PauliX, Pauli.PauliX)), (theta * 2.0), (new QArray<Qubit>(q1, q2))));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                (IQArray<Qubit> ctrls, (double theta, Qubit q1, Qubit q2)) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Body((theta, q1, q2));
                }
                else
                {
                    Simulator.ControlledBody((ctrls, ((new QArray<Pauli>(Pauli.PauliX, Pauli.PauliX)), (theta * 2.0), (new QArray<Qubit>(q1, q2)))));
                }

                return QVoid.Instance;
            };
        }

        public class Type2SimulatorApplyIsingYY : IsingYY
        {
            private QuantumSimulator.QSimExp Simulator { get; }

            public Type2SimulatorApplyIsingYY(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimExp(m);
            }

            public override Func<(double, Qubit, Qubit), QVoid> Body => (args) =>
            {
                (double theta, Qubit q1, Qubit q2) = (args);
                Simulator.Body(((new QArray<Pauli>(Pauli.PauliY, Pauli.PauliY)), (theta * 2.0), (new QArray<Qubit>(q1, q2))));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                (IQArray<Qubit> ctrls, (double theta, Qubit q1, Qubit q2)) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Body((theta, q1, q2));
                }
                else
                {
                    Simulator.ControlledBody((ctrls, ((new QArray<Pauli>(Pauli.PauliY, Pauli.PauliY)), (theta * 2.0), (new QArray<Qubit>(q1, q2)))));
                }

                return QVoid.Instance;
            };
        }
        public class Type2SimulatorApplyIsingZZ : IsingZZ
        {
            private QuantumSimulator.QSimExp Simulator { get; }

            public Type2SimulatorApplyIsingZZ(QuantumSimulator m) : base(m)
            {
                Simulator = new QuantumSimulator.QSimExp(m);
            }

            public override Func<(double, Qubit, Qubit), QVoid> Body => (args) =>
            {
                (double theta, Qubit q1, Qubit q2) = (args);
                Simulator.Body(((new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliZ)), (theta * 2.0), (new QArray<Qubit>(q1, q2))));
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, (double, Qubit, Qubit)), QVoid> ControlledBody => (args) =>
            {
                (IQArray<Qubit> ctrls, (double theta, Qubit q1, Qubit q2)) = args;

                if ((ctrls == null) || (ctrls.Count == 0))
                {
                    Body((theta, q1, q2));
                }
                else
                {
                    Simulator.ControlledBody((ctrls, ((new QArray<Pauli>(Pauli.PauliZ, Pauli.PauliZ)), (theta * 2.0), (new QArray<Qubit>(q1, q2)))));
                }

                return QVoid.Instance;
            };
        }
    }
}
