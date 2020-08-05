using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.OldDecomposition
{
    public class OldMeasurementAssertTracker : MeasurementAssertTrackerBase, IOldDecompositionTarget
    {
        public OldMeasurementAssertTracker(bool throwOnUnconstrainedMeasurement) : base(throwOnUnconstrainedMeasurement)
        {
        }

        public void CX(Qubit control, Qubit qubit)
        {
            this.InvalidateConstraint(control);
            this.InvalidateConstraint(qubit);
        }

        public void QubitClifford(int id, Pauli pauli, Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void R(Pauli pauli, double angle, Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void T(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        void IOldDecompositionTarget.Measure(IQArray<Pauli> observable, IQArray<Qubit> target)
        {
        }
    }
}