// Copyright (c) Microsoft Corporation. All rights reserved.
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
    public partial class OpenSystemsSimulator : SimulatorBase, IType1Core, IDisposable
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


        public OpenSystemsSimulator(uint capacity = 3) : base(new QubitManager((long)capacity))
        {
            this.Id = NativeInterface.Init(capacity);
        }

        public void ApplyControlledX__Body(Qubit control, Qubit target)
        {
            NativeInterface.CNOT(this.Id, control, target);
        }

        public void ApplyControlledZ__Body(Qubit control, Qubit target)
        {
            // FIXME: Make this a new Type4, with CZ applied by decompositions.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledH__Body(Qubit target)
        {
            NativeInterface.H(this.Id, target);
        }

        public void ApplyUncontrolledRx__AdjointBody(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledRx__Body(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledRy__AdjointBody(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledRy__Body(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledRz__AdjointBody(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledRz__Body(double angle, Qubit target)
        {
            // FIXME: Rotations are not yet supported.
            throw new NotImplementedException();
        }

        public void ApplyUncontrolledS__AdjointBody(Qubit target)
        {
            NativeInterface.SAdj(this.Id, target);
        }

        public void ApplyUncontrolledS__Body(Qubit target)
        {
            NativeInterface.S(this.Id, target);
        }

        public void ApplyUncontrolledT__AdjointBody(Qubit target)
        {
            NativeInterface.TAdj(this.Id, target);
        }

        public void ApplyUncontrolledT__Body(Qubit target)
        {
            NativeInterface.T(this.Id, target);
        }

        public void ApplyUncontrolledX__Body(Qubit target)
        {
            NativeInterface.X(this.Id, target);
        }

        public void ApplyUncontrolledY__Body(Qubit target)
        {
            NativeInterface.Y(this.Id, target);
        }

        public void ApplyUncontrolledZ__Body(Qubit target)
        {
            NativeInterface.Z(this.Id, target);
        }

        public void Dispose()
        {
            NativeInterface.Destroy(this.Id);
        }

        public Result M__Body(Qubit target) =>
            NativeInterface.M(this.Id, target);

        public void Reset__Body(Qubit target)
        {
            throw new NotImplementedException();
        }
    }
}
