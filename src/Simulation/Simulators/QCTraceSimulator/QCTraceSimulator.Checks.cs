// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        internal class QCTracesimulatorImplCheckQubitUniqueness : Intrinsic.CheckQubitUniqueness
        {
            public QCTracesimulatorImplCheckQubitUniqueness(QCTraceSimulatorImpl m) : base(m)
            {
            }

            public override Func<IQArray<Qubit>, QVoid> __Body__ => (qubits) =>
            {
                // Noop
                return QVoid.Instance;
            };

            public override Func<(IQArray<Qubit>, IQArray<Qubit>), QVoid> __ControlledBody__ => (args) =>
            {
                // Noop
                return QVoid.Instance;
            };
        }

        internal class QCTracesimulatorImplRotationAngleValidation : Intrinsic.RotationAngleValidation
        {
            public QCTracesimulatorImplRotationAngleValidation(QCTraceSimulatorImpl m) : base(m)
            {
            }

            public override Func<double, QVoid> __Body__ => (angle) =>
            {
                // Noop
                return QVoid.Instance;
            };
        }
    }
}
