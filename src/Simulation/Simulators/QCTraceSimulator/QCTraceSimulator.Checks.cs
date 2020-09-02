// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        public class TracerCheckQubitUniqueness : Intrinsic.CheckQubitUniqueness
        {
            public TracerCheckQubitUniqueness(QCTraceSimulatorImpl m) : base(m)
            {
            }

            public override Func<IQArray<Qubit>, QVoid> Body => (qubits) =>
            {
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, IQArray<Qubit>), QVoid> ControlledBody => (args) =>
            {
                return QVoid.Instance;
            };
        }

        public class TracerRotationAngleValidation : Intrinsic.RotationAngleValidation
        {
            public TracerRotationAngleValidation(QCTraceSimulatorImpl m) : base(m)
            {
            }

            public override Func<double, QVoid> Body => (angle) =>
            {
                return QVoid.Instance;
            };
        }
    }
}
