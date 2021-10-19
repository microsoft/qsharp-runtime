// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected class QSimQubitManager : QubitManager
        {
            readonly bool throwOnReleasingQubitsNotInZeroState;

            public CommonNativeSimulator? Simulator { get; set; }   // Must not be nullable (and public). But we cannot 
                // initialize it properly _during construction_. We initialize it _after construction_. 
                // That is why it is nullable and public.

            public QSimQubitManager(bool throwOnReleasingQubitsNotInZeroState = true, long qubitCapacity = 32, bool mayExtendCapacity = true, bool disableBorrowing = false)
                : base(qubitCapacity, mayExtendCapacity, disableBorrowing)
            {
                this.throwOnReleasingQubitsNotInZeroState = throwOnReleasingQubitsNotInZeroState;
            }

            /// <summary>
            ///  The max number used as qubit id so far.
            /// </summary>
            public long MaxId { get; private set; }

            public override Qubit CreateQubitObject(long id)
            {
                Debug.Assert(id < 50, "Using a qubit id > 50. This is a full-state simulator! Validating ids uniqueness might start becoming slow.");

                if (id >= this.MaxId)
                {
                    this.MaxId = id + 1;
                }

                Debug.Assert(Simulator != null);
                return new QSimQubit((int)id, Simulator);
            }

            protected override Qubit Allocate(bool usedOnlyForBorrowing)
            {
                Qubit qubit = base.Allocate(usedOnlyForBorrowing);
                Debug.Assert(Simulator != null);
                Simulator.AllocateOne((uint)qubit.Id); 
                return qubit;
            }

            protected override void Release(Qubit qubit, bool wasUsedOnlyForBorrowing)
            {
                base.Release(qubit, wasUsedOnlyForBorrowing);
                if (qubit != null)
                {
                    Debug.Assert(Simulator != null);
                    bool isReleasedQubitZero = Simulator.ReleaseOne((uint)qubit.Id);
                    if (!(isReleasedQubitZero || qubit.IsMeasured) && throwOnReleasingQubitsNotInZeroState)
                    {
                        throw new ReleasedQubitsAreNotInZeroState();
                    }
                }
            }
        }

    }
}
