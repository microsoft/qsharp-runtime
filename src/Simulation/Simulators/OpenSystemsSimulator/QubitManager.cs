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
    public partial class OpenSystemsSimulator
    {

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
                    if ((this.Parent as IIntrinsicMeasure).Body(new QArray<Pauli>(Pauli.PauliZ), new QArray<Qubit>(qubit)) == Result.One)
                    {
                        (this.Parent as IIntrinsicX).Body(qubit);
                    }
                }
                base.Release(qubit, wasUsedOnlyForBorrowing);
            }
        }

    }
}
