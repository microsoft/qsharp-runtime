// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        class QSimQubitManager : QubitManager
        {
            readonly bool throwOnReleasingQubitsNotInZeroState;

            public uint SimulatorId { get; private set; }

            public QSimQubitManager(bool throwOnReleasingQubitsNotInZeroState = true, long qubitCapacity = 32, bool mayExtendCapacity = true, bool disableBorrowing = false)
                : base(qubitCapacity, mayExtendCapacity, disableBorrowing)
            {
                this.throwOnReleasingQubitsNotInZeroState = throwOnReleasingQubitsNotInZeroState;
            }

            public void Init(uint simulatorId)
            {
                this.SimulatorId = simulatorId;
            }

            /// <summary>
            ///  The max number used as qubit id so far.
            /// </summary>
            public long MaxId { get; private set; }

            public override Qubit CreateQubitObject(long id)
            {
                Debug.Assert(id < 50, "Using a qubit id > 50. This is a full-state simulator! Validating ids uniquenes might start becoming slow.");

                if (id >= this.MaxId)
                {
                    this.MaxId = id + 1;
                }

                return new QSimQubit((int)id, SimulatorId);
            }

            protected override Qubit Allocate(bool usedOnlyForBorrowing)
            {
                Qubit qubit = base.Allocate(usedOnlyForBorrowing);
                if (qubit != null) { AllocateOne(this.SimulatorId, (uint)qubit.Id); }
                return qubit;
            }

            protected override void Release(Qubit qubit, bool wasUsedOnlyForBorrowing)
            {
                base.Release(qubit, wasUsedOnlyForBorrowing);
                if (qubit != null)
                {
                    bool isReleasedQubitZero = ReleaseOne(this.SimulatorId, (uint)qubit.Id);
                    if (!(isReleasedQubitZero || qubit.IsMeasured) && throwOnReleasingQubitsNotInZeroState)
                    {
                        throw new ReleasedQubitsAreNotInZeroState();
                    }
                }
            }
        }

    }
}
