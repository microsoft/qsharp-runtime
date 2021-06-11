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
using Newtonsoft.Json.Linq;

namespace Microsoft.Quantum.Experimental
{
    // NB: This class should not implement IQSharpCore, but does so temporarily
    //     to make the simulator available to IQ# (note that the I in IQSharpCore
    //     refers to interfaces, and not to IQ# itself...)
    public partial class OpenSystemsSimulator : SimulatorBase, IQSharpCore
    {
        public static JToken BuildInfo => NativeInterface.SimulatorInfo;

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

        public OpenSystemsSimulator(uint capacity = 3, string representation = "mixed") : base(new QubitManager((long)capacity))
        {
            this.Id = NativeInterface.Init(capacity, representation);
        }

        void IIntrinsicH.Body(Qubit target)
        {
            NativeInterface.H(this.Id, target);
        }

        void IIntrinsicH.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            if (controls is { Count: 0 })
            {
                (this as IIntrinsicH).Body(target);
            }
            else
            {
                Get<Decompositions.ApplyControlledH, Decompositions.ApplyControlledH>().__Body__((controls, target));
            }
        }

        Result IIntrinsicMeasure.Body(IQArray<Pauli> paulis, IQArray<Qubit> targets)
        {
            if (targets is { Count: 1 } && paulis is { Count: 1 } && paulis.Single() == Pauli.PauliZ)
            {
                return NativeInterface.M(this.Id, targets.Single());
            }
            else
            {
                Get<Decompositions.Measure, Decompositions.Measure>().__Body__((paulis, targets));
            }
        }

        void IIntrinsicS.Body(Qubit target)
        {
            NativeInterface.S(this.Id, target);
        }

        void IIntrinsicS.AdjointBody(Qubit target)
        {
            NativeInterface.SAdj(this.Id, target);
        }

        void IIntrinsicS.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        void IIntrinsicS.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        void IIntrinsicT.Body(Qubit target)
        {
            NativeInterface.T(this.Id, target);
        }

        void IIntrinsicT.AdjointBody(Qubit target)
        {
            NativeInterface.TAdj(this.Id, target);
        }

        void IIntrinsicT.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        void IIntrinsicT.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        void IIntrinsicX.Body(Qubit target)
        {
            NativeInterface.X(this.Id, target);
        }

        void IIntrinsicX.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            // TODO: pass off to decompositions for more than one control.
            if (controls is { Count: 0 })
            {
                (this as IIntrinsicX).Body(target);
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

        void IIntrinsicY.Body(Qubit target)
        {
            NativeInterface.Y(this.Id, target);
        }

        void IIntrinsicY.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            throw new NotImplementedException();
        }

        void IIntrinsicZ.Body(Qubit target)
        {
            NativeInterface.Z(this.Id, target);
        }

        void IIntrinsicZ.ControlledBody(IQArray<Qubit> controls, Qubit target)
        {
            // TODO: pass off to decompositions for more than one control.
            if (controls is { Count: 0 })
            {
                (this as IIntrinsicZ).Body(target);
            }
            else if (controls is { Count: 1 })
            {
                Get<Decompositions.ApplyCZUsingCNOT, Decompositions.ApplyCZUsingCNOT>().__Body__((controls[0], target));
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

    }
}
