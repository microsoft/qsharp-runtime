using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    internal interface IOldDecomposerInterface : IOldDecompositionTarget
    {
        void RFrac(Pauli axis, long numerator, long denomPower, Qubit qubit);
    }

    //TODO: inherit from measurement tracker
    internal partial class OldTracerInternalSim : SimulatorBase, IOldDecomposerInterface
    {
        private readonly IOldDecompositionTarget[] Targets;

        internal TracerSimulator Tracer { get; private set; }
        internal IMeasurementManagementTarget MeasurementManager { get; private set; }

        public override string Name => "QcInternalTracer";

        public OldTracerInternalSim(TracerSimulator tracer, IQubitManager qubitManager, IEnumerable<ITracerTarget> tracerTargets)
            : base(qubitManager)
        {
            this.Tracer = tracer ?? throw new ArgumentNullException(nameof(tracer));
            this.Targets = tracerTargets?.Extract<ITracerTarget, IOldDecompositionTarget>().ToArray()
                ?? throw new ArgumentNullException(nameof(tracerTargets));
            this.MeasurementManager = this.Tracer.GetTarget<IMeasurementManagementTarget>();
            this.RegisterPrimitiveOperationsGivenAsCircuits();
        }

        private void RegisterPrimitiveOperationsGivenAsCircuits()
        {
            IEnumerable<Type> primitiveOperationTypes =
                from op in typeof(Intrinsic.X).Assembly.GetExportedTypes()
                where op.IsSubclassOf(typeof(AbstractCallable))
                select op;

            IEnumerable<Type> primitiveOperationAsCircuits =
                from op in typeof(Circuits.X).Assembly.GetExportedTypes()
                where op.IsSubclassOf(typeof(AbstractCallable))
                      && op.Namespace == typeof(Circuits.X).Namespace
                select op;

            foreach (Type operationType in primitiveOperationTypes)
            {
                IEnumerable<Type> machingCircuitTypes =
                    from op in primitiveOperationAsCircuits
                    where op.Name == operationType.Name
                    select op;

                int numberOfMatchesFound = machingCircuitTypes.Count();
                Debug.Assert(
                     numberOfMatchesFound <= 1,
                    "There should be at most one matching operation.");
                if (numberOfMatchesFound == 1)
                {
                    Register(operationType, machingCircuitTypes.First(), operationType.ICallableType());
                }
            }
        }

        public bool SupportsTarget(ITracerTarget target)
        {
            return target is IOldDecompositionTarget;
        }

        public void CX(Qubit control, Qubit qubit)
        {
            foreach (IOldDecompositionTarget target in Targets)
            {
                target.CX(control, qubit);
            }
        }

        public void Measure(IQArray<Pauli> observables, IQArray<Qubit> qubits)
        {
            foreach (IOldDecompositionTarget target in Targets)
            {
                target.Measure(observables, qubits);
            }
        }

        public void QubitClifford(int id, Pauli pauli, Qubit qubit)
        {
            foreach (IOldDecompositionTarget target in Targets)
            {
                target.QubitClifford(id, pauli, qubit);
            }
        }

        public void R(Pauli pauli, double angle, Qubit qubit)
        {
            foreach (IOldDecompositionTarget target in Targets)
            {
                target.R(pauli, angle, qubit);
            }
        }

        // Logic translated from OldTracerInternalSim.cs
        public void RFrac(Pauli axis, long numerator, long denomPower, Qubit qubit)
        {
            if (axis == Pauli.PauliI)
            {
                return; // global phase case
            }

            (long numNew, long denomPowerNew) = CommonUtils.Reduce(numerator, denomPower);
            switch (denomPowerNew)
            {
                case 3:
                    long power = ((numNew % 8) + 8) % 8;
                    if (power == 3 || power == 5)
                    {
                        this.QubitClifford(-1, Pauli.PauliZ, qubit); //TODO:hack
                    }
                    this.T(qubit);
                    break;
                case 2:
                case 1:
                    this.QubitClifford(-1, Pauli.PauliZ, qubit);
                    break;
                default:
                    if (denomPowerNew > 0)
                    {
                        this.R(Pauli.PauliZ, -1, qubit); //TODO:hack
                    }
                    // when denomPowerNew is negative we just have a global phase
                    break;
            }
        }

        public void T(Qubit qubit)
        {
            foreach (IOldDecompositionTarget target in Targets)
            {
                target.T(qubit);
            }
        }
    }
}