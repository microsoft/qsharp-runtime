// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Intrinsic.Interfaces;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Experimental
{
    // NB: This class should not implement IQSharpCore, but does so temporarily
    //     to make the simulator available to IQ# (note that the I in IQSharpCore
    //     refers to interfaces, and not to IQ# itself...)
    public partial class OpenSystemsSimulator : SimulatorBase, IQSharpCore
    {
        private readonly ulong Id;

        public override string Name => NativeInterface.Name;

        public NoiseModel NoiseModel
        {
            get
            {
                return NativeInterface.GetNoiseModel(Id);
            }

            set
            {
                NativeInterface.SetNoiseModel(Id, value);
            }
        }

        public State CurrentState => NativeInterface.GetCurrentState(this.Id);

        public class OpenSystemsQubitManager : QubitManager
        {
            private readonly OpenSystemsSimulator Parent;
            public OpenSystemsQubitManager(OpenSystemsSimulator parent, uint capacity)
                : base(capacity)
            {
                this.Parent = parent;
            }

            protected override void Release(Qubit qubit, bool wasUsedOnlyForBorrowing)
            {
                if (qubit != null && qubit.IsMeasured)
                {
                    // Try to reset measured qubits.
                    // TODO: There are better ways to do this; increment on the
                    //       design and make it customizable.
                    // FIXME: In particular, this implementation uses a lot of
                    //        extraneous measurements.
                    if (this.Parent.Measure__Body(new QArray<Pauli>(Pauli.PauliZ), new QArray<Qubit>(qubit)) == Result.One)
                    {
                        this.Parent.X__Body(qubit);
                    }
                }
                base.Release(qubit, wasUsedOnlyForBorrowing);
            }
        }

        public OpenSystemsSimulator(uint capacity = 3) : base(new QubitManager((long)capacity))
        {
            this.Id = NativeInterface.Init(capacity);
        }

        public void Exp__Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            throw new NotImplementedException();
        }

        public void Exp__AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            throw new NotImplementedException();
        }

        public void Exp__ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            throw new NotImplementedException();
        }

        public void Exp__ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
        {
            throw new NotImplementedException();
        }

        public void H__Body(Qubit target)
        {
            NativeInterface.H(this.Id, target);
        }

        public void H__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public Result Measure__Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            if (targets is { Count: 1 } && paulis is { Count: 1 } && paulis.Single() == Pauli.PauliZ)
            {
                return NativeInterface.M(this.Id, targets.Single());
            }
            else
            {
                // FIXME: Pass multiqubit and non-Z cases to decompositions.
                throw new NotImplementedException();
            }
        }

        public void R__Body(Pauli pauli, double angle, Qubit target)
        {
            if (pauli == Pauli.PauliI)
            {
                // Don't apply global phases on uncontrolled operations.
                return;
            }
            throw new NotImplementedException("Arbitrary rotation with noise is not yet supported.");
        }

        public void R__AdjointBody(Pauli pauli, double angle, Qubit target)
        {
            R__Body(pauli, -angle, target);
        }

        public void R__ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            if (controls is { Count: 0 })
            {
                R__Body(pauli, angle, target);
            }
            else
            {
                throw new NotImplementedException("Arbitrary controlled rotation with noise is not yet supported.");
            }
        }

        public void R__ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
        {
            R__ControlledBody(controls, pauli, -angle, target);
        }

        public void S__Body(Qubit target)
        {
            NativeInterface.S(this.Id, target);
        }

        public void S__AdjointBody(Qubit target)
        {
            NativeInterface.SAdj(this.Id, target);
        }

        public void S__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public void S__ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public void T__Body(Qubit target)
        {
            NativeInterface.T(this.Id, target);
        }

        public void T__AdjointBody(Qubit target)
        {
            NativeInterface.TAdj(this.Id, target);
        }

        public void T__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public void T__ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public void X__Body(Qubit target)
        {
            NativeInterface.X(this.Id, target);
        }

        public void X__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            // TODO: pass off to decompositions for more than one control.
            if (controls is { Count: 0 })
            {
                X__Body(target);
            }
            else if (controls is { Count: 1 })
            {
                NativeInterface.CNOT(this.Id, controls[0], target);
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public void Y__Body(Qubit target)
        {
            NativeInterface.Y(this.Id, target);
        }

        public void Y__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        public void Z__Body(Qubit target)
        {
            NativeInterface.Z(this.Id, target);
        }

        public void Z__ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            // TODO: pass off to decompositions for more than one control.
            if (controls is { Count: 0 })
            {
                Z__Body(target);
            }
            else if (controls is { Count: 1 })
            {
                Get<ApplyCZUsingCNOT, ApplyCZUsingCNOT>().__Body__((controls[0], target));
            }
            else
            {
                throw new NotImplementedException();
            }
        }

        public void Dispose()
        {
            NativeInterface.Destroy(this.Id);
        }

        public class OpenSystemsDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
        {
            private OpenSystemsSimulator Simulator { get; }

            public OpenSystemsDumpMachine(OpenSystemsSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                Simulator.MaybeDisplayDiagnostic(Simulator.CurrentState);
                return QVoid.Instance;
            };
        }

        // TODO: implement this by adding a new PartialTrace trait to the
        //       Rust side, and then exposing it through the C API.
        //       Until we have that, there's not a sensible way to interpret
        //       states on subregisters in general.
        public class OpenSystemsDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
        {
            private OpenSystemsSimulator Simulator { get; }

            public OpenSystemsDumpRegister(OpenSystemsSimulator m) : base(m)
            {
                this.Simulator = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (args) =>
            {
                var (location, register) = args;
                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                this.Simulator.Get<Message, Message>().__Body__?.Invoke("DumpRegister not yet supported on OpenSystemsSimulator; skipping.");
                return QVoid.Instance;
            };
        }
    }
}
