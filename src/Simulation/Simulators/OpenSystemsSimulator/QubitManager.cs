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
                // When a qubit is released, the developer has promised that
                // either of the following two conditions holds:
                //
                //     1. The qubit has been measured immediately before
                //        releasing, such that its state is known
                //        determinstically at this point in the program.
                //     2. The qubit has been coherently unprepared, such that
                //        the the qubit is known determistically to be in the
                //        |0⟩ state at this point in the program.
                //
                // In either case, noise can cause a correct Q# program to fail
                // to meet the conditions for releasing a qubit, such that we
                // want to track the effects of that noise without failing.
                //
                // Thus, our strategy will be to always allow the release to
                // proceed, doing any resets needed to deal with case (1)
                // above.
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
