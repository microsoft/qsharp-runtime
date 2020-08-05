using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.MetricCollectors;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public class NewMeasurementAssertTracker : MeasurementAssertTrackerBase, INewDecompositionTarget
    {
        public NewMeasurementAssertTracker(bool throwOnUnconstrainedMeasurement) : base(throwOnUnconstrainedMeasurement)
        {
        }

        public void Z(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void CZ(Qubit control, Qubit qubit)
        {
            this.InvalidateConstraint(control);
            this.InvalidateConstraint(qubit);
        }

        public void CCZ(Qubit control1, Qubit control2, Qubit qubit)
        {
            this.InvalidateConstraint(control1);
            this.InvalidateConstraint(control2);
            this.InvalidateConstraint(qubit);
        }

        public void H(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void S(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void SAdjoint(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }
        public void T(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void TAdjoint(Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        public void Rz(double theta, Qubit qubit)
        {
            this.InvalidateConstraint(qubit);
        }

        void INewDecompositionTarget.Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
        }

        void INewDecompositionTarget.M(Qubit qubit)
        {
        }
    }
}