using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using static Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition.DecompositionUtils;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    //TODO: provide reference to white paper and q-sharp decomposition implementation
    public class NewDecomposer : QuantumProcessorBase, ITracerTarget
    {
        protected readonly SimulatorBase Simulator;

        //Only can be one measurement manager
        protected IMeasurementManagementTarget? MeasurementTarget;
        protected readonly IList<INewDecompositionTarget> DecompositionTargets = new List<INewDecompositionTarget>();
        protected readonly IList<IQubitTrackingTarget> QubitTargets = new List<IQubitTrackingTarget>();

        public NewDecomposer(SimulatorBase sim, IEnumerable<ITracerTarget> tracerTargets)
        {
            this.Simulator = sim ?? throw new ArgumentNullException(nameof(sim));
            foreach (ITracerTarget target in tracerTargets)
            {
                RegisterTarget(target);
            }
        }

        bool ITracerTarget.SupportsTarget(ITracerTarget target)
        {
            return target is INewDecompositionTarget
               || target is IQubitTrackingTarget
               || target is IMeasurementManagementTarget;
        }

        private void RegisterTarget(ITracerTarget target)
        {
            if (target == null) { throw new ArgumentNullException(nameof(target)); }

            if (target is IMeasurementManagementTarget measurementTarget)
            {
                if (this.MeasurementTarget != null && measurementTarget != this.MeasurementTarget)
                {
                    throw new ArgumentException("A measurement manager is already registered.");
                }
                this.MeasurementTarget = measurementTarget;
            }
            if (target is INewDecompositionTarget decompositionTarget)
            {
                this.DecompositionTargets.Add(decompositionTarget);
            }
            if (target is IQubitTrackingTarget qubitTarget)
            {
                this.QubitTargets.Add(qubitTarget);
            }
            //TODO: shuold we fail for unrecognized target type?
        }

        public override void Z(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.Z(qubit);
            }
        }

        public virtual void CZ(Qubit control, Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.CZ(control, qubit);
            }
        }

        public virtual void CCZ(Qubit control0, Qubit control1, Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.CCZ(control0, control1, qubit);
            }
        }

        public override void H(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.H(qubit);
            }
        }

        public override void S(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.S(qubit);
            }
        }

        public override void SAdjoint(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.SAdjoint(qubit);
            }
        }

        public override void T(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.T(qubit);
            }
        }

        public override void TAdjoint(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.TAdjoint(qubit);
            }
        }

        public virtual void Rz(double theta, Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.Rz(theta, qubit);
            }
        }

        public override Result M(Qubit qubit)
        {
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.M(qubit);
            }
            return this.MeasurementTarget != null ? this.MeasurementTarget.M(qubit) : base.M(qubit);
        }

        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            //TODO: should this be decomposed?
            foreach (INewDecompositionTarget target in this.DecompositionTargets)
            {
                target.Measure(bases, qubits);
            }
            return this.MeasurementTarget != null ? this.MeasurementTarget.Measure(bases, qubits) : base.Measure(bases, qubits);
        }


        public override void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
            if (this.MeasurementTarget != null)
            {
                this.MeasurementTarget.Assert(bases, qubits, result, msg);
            }
            else
            {
                base.Assert(bases, qubits, result, msg);
            }
        }

        public override void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
            if (this.MeasurementTarget != null)
            {
                this.MeasurementTarget.AssertProb(bases, qubits, probabilityOfZero, msg, tol);
            }
            else
            {
                base.AssertProb(bases, qubits, probabilityOfZero, msg, tol);
            }
        }

        public override void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            foreach (IQubitTrackingTarget target in this.QubitTargets)
            {
                target.OnAllocateQubits(qubits);
            }
        }

        public override void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            foreach (IQubitTrackingTarget target in this.QubitTargets)
            {
                target.OnReleaseQubits(qubits);
            }
        }

        public override void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount)
        {
            foreach (IQubitTrackingTarget target in this.QubitTargets)
            {
                target.OnBorrowQubits(qubits, allocatedForBorrowingCount);
            }
        }

        public override void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount)
        {
            foreach (IQubitTrackingTarget target in this.QubitTargets)
            {
                target.OnReturnQubits(qubits, releasedOnReturnCount);
            }
        }

        #region IQuantumProcesor -> INewDecompositionTarget decomposition

        public override void X(Qubit qubit)
        {
            WithinMapPauliZ(Pauli.PauliX, this.Z, qubit);
        }

        public override void Y(Qubit qubit)
        {
            WithinMapPauliZ(Pauli.PauliY, this.Z, qubit);
        }

        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            WithinMapPauliZ(Pauli.PauliX, this.ControlledZ, controls, qubit);
        }

        public override void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            WithinMapPauliZ(Pauli.PauliY, this.ControlledZ, controls, qubit);
        }

        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.Z(qubit);
            }
            else if (controls.Length == 1)
            {
                this.CZ(controls[0], qubit);
            }
            else if (controls.Length == 2) //TODO: should this 2 be a 1?
            {
                this.CCZ(controls[0], controls[1], qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledZ, controls, qubit);
            }
        }

        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            //TODO: discuss with Vadym whether SWAP is free (swapping pointers) or done with CNOTs
            this.CNOT(qubit1, qubit2);
            this.CNOT(qubit2, qubit1);
            this.CNOT(qubit1, qubit2);
        }

        public override void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.H(qubit);
            }
            else if (controls.Length == 1)
            {
                this.S(qubit);
                WithinMapPauliZ(Pauli.PauliX, this.T, qubit);

                this.ControlledZ(controls, qubit);

                WithinMapPauliZAdj(Pauli.PauliX, this.TAdjoint, qubit);
                this.SAdjoint(qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledH, controls, qubit);
            }
        }

        public override void ControlledS(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.S(qubit);
            }
            else if (controls.Length == 1)
            {
                this.ControlledX(controls, qubit);
                this.TAdjoint(qubit);
                this.ControlledX(controls, qubit); //adj

                this.T(controls[0]);
                this.T(qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledS, controls, qubit);
            }
        }

        public override void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.SAdjoint(qubit);
            }
            else if (controls.Length == 1)
            {
                this.TAdjoint(qubit);
                this.TAdjoint(controls[0]);

                this.ControlledX(controls, qubit);
                this.T(qubit);
                this.ControlledX(controls, qubit); //adj
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledSAdjoint, controls, qubit);
            }
        }

        public override void ControlledT(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.T(qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledT, controls, qubit);
            }
        }

        public override void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.TAdjoint(qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledTAdjoint, controls, qubit);
            }
        }

        public override void Reset(Qubit qubit)
        {
            if (this.M(qubit) == Result.One)
            {
                X(qubit);
            }
        }

        public override void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            if (controls.Length == 0)
            {
                this.SWAP(qubit1, qubit2);
            }
            else if (controls.Length == 1)
            {
                this.CNOT(qubit2, qubit1);
                this.ControlledX(ToIQArray(controls[0], qubit1), qubit2);
                this.CNOT(qubit2, qubit1);
            }
            else
            {
                ControlledOp self = (cntrls, _) => ControlledSWAP(cntrls, qubit1, qubit2);
                ApplyWithOneLessControl(self, controls, null);
            }
        }

        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            if (axis != Pauli.PauliI)
            {
                WithinMapPauliZ(axis, (q) => this.Rz(theta, q), qubit);
            }
        }

        public override void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            if (axis == Pauli.PauliI)
            {
                ApplyGlobalPhaseControlled(controls, -theta / 2.0);
            }
            else
            {
                WithinMapPauliZ(axis, (cntrls, q) => ControlledRz(cntrls, theta, q), controls, qubit);
            }
        }


        public override void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            this.ControlledRFrac(ToIQArray<Qubit>(), axis, numerator, power, qubit);
        }

        public override void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            if (axis == Pauli.PauliI)
            {
                ApplyGlobalPhaseFracControlled(controls, numerator, power);
            }
            else
            {
                WithinMapPauliZ(axis, (q) => this.ControlledRzFrac(controls, numerator, power, q), qubit);
            }
        }


        public override void R1(double theta, Qubit qubit)
        {
            this.ControlledR1(ToIQArray<Qubit>(), theta, qubit);
        }

        public override void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                this.Rz(theta, qubit);
            }
            else
            {
                ControlledOp ControlledR1 = (cntrls, q) => this.ControlledR1(cntrls, theta, q);
                ApplyWithOneLessControl(ControlledR1, controls, qubit);
            }
        }


        public override void R1Frac(long numerator, long power, Qubit qubit)
        {
            this.ControlledR1Frac(ToIQArray<Qubit>(), numerator, power, qubit);
        }

        public override void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            if (power >= 0)
            {
                (long kModPositive, long n) = ReduceDyadicFractionPeriodic(numerator, power);
                if (n == 0)
                {
                    if (kModPositive == 1) { this.ControlledZ(controls, qubit); }
                    else if (kModPositive == 0) { }
                    else { throw new Exception("Something went wrong. This should be unreachable"); }
                }
                else if (n == 1)
                {
                    if (kModPositive == 1) { this.ControlledS(controls, qubit); }
                    else if (kModPositive == 3) { this.ControlledSAdjoint(controls, qubit); }
                    else { throw new Exception("Something went wrong. This should be unreachable"); }
                }
                else if (n == 2)
                {
                    if (kModPositive == 1) { this.ControlledT(controls, qubit); }
                    else if (kModPositive == 3)
                    {
                        Op TS = (q) =>
                        {
                            this.S(q);
                            this.T(q);
                        };
                        ApplyPhaseOp(TS, controls, qubit);
                    }
                    else if (kModPositive == 5)
                    {
                        Op TSAdjoint = (q) =>
                        {
                            this.TAdjoint(q);
                            this.SAdjoint(q);
                        };
                        ApplyPhaseOp(TSAdjoint, controls, qubit);
                    }
                    else if (kModPositive == 7) { this.ControlledTAdjoint(controls, qubit); }
                    else { throw new Exception("Something went wrong. This should be unreachable."); }
                }
                else
                {
                    double numeratorD = System.Math.PI * kModPositive;
                    double phi = numeratorD * System.Math.Pow(2.0, -n);
                    this.ControlledR1(controls, phi, qubit);
                }
            }
        }


        public override void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            this.ControlledExp(ToIQArray<Qubit>(), paulis, theta, qubits);
        }

        //TODO: likely restructure these the same way as done in the original .qs, i.e.
        //pull out cExpZ and MultiCX for overrideability and better readability
        public override void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            if (paulis.Length != 0)
            {
                CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
                if (newPaulis.Count != 0)
                {
                    void cExpZ(IQArray<Qubit> _qubits)
                    {
                        //TODO: controls need to be in here as well?
                        for (int i = 1; i < _qubits.Count; i++)
                        { this.CNOT(_qubits[i], _qubits[0]); }

                        this.ControlledRz(controls, -2.0 * theta, _qubits[0]);

                        // adjoint:
                        for (int i = _qubits.Count - 1; i >= 1; i--)
                        { this.CNOT(_qubits[i], _qubits[0]); }
                    }
                    WithinMapPaulisZ(newPaulis, (qs) => cExpZ(qs), newQubits);
                }
                else
                {
                    this.ApplyGlobalPhaseControlled(controls, theta);
                }
            }
        }


        public override void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            this.ControlledExpFrac(ToIQArray<Qubit>(), paulis, numerator, power, qubits);
        }

        public override void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits)
        {
            //if (paulis.Length != 0)
            //{
            CommonUtils.PruneObservable(paulis, qubits, out QArray<Pauli> newPaulis, out QArray<Qubit> newQubits);
            if (newPaulis.Count != 0)
            {
                //TODO: pull this out as own method and have it be overwritten
                void cExpFracZ(IQArray<Qubit> _qubits)
                {
                    for (int i = 1; i < _qubits.Count; i++)
                    { this.CNOT(_qubits[i], _qubits[0]); }

                    this.ControlledRFrac(controls, Pauli.PauliZ, numerator, power, _qubits[0]);

                    for (int i = _qubits.Count - 1; i >= 1; i--)
                    { this.CNOT(_qubits[i], _qubits[0]); }
                }

                WithinMapPaulisZ(newPaulis, (qs) => cExpFracZ(qs), newQubits);
            }
            else
            {
                this.ApplyGlobalPhaseFracControlled(controls, numerator, power);
            }
            //}
        }

        #region Global Phase

        protected virtual void ApplyGlobalPhaseControlled(IQArray<Qubit> controls, double theta)
        {
            if (controls.Length > 0)
            {
                IQArray<Qubit> cntrls = controls.Slice(new QRange(1, controls.Length - 1));
                ApplyPhaseOp((qubit) => this.Rz(theta, qubit), cntrls, controls[0]);
            }
        }


        protected virtual void ApplyGlobalPhaseFracControlled(IQArray<Qubit> controls, long numerator, long power)
        {
            if (controls.Length > 0)
            {
                IQArray<Qubit> cntrls = controls.Slice(new QRange(1, controls.Length - 1));
                this.ControlledR1Frac(cntrls, numerator, power, controls[0]);
            }
        }

        #endregion

        #region Rz / RzFrac Implementations

        public virtual void ControlledRz(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            ControlledOp self = (cntrls, q) => ControlledRz(cntrls, theta, q);

            if (controls.Length == 0)
            {
                this.Rz(theta, qubit);
            }
            else if (controls.Length == 1)
            {
                this.Rz(-theta / 2.0, controls[0]);
                ApplyWithOneLessControl(self, controls, qubit);
            }
            else
            {
                ApplyWithOneLessControl(self, controls, qubit);
            }
        }

        protected virtual void ControlledRzFrac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            //TODO: very likely some of the Adjoint cases below were translated wrong
            if (power >= 0)
            {
                (long kModPositive, long n) = ReduceDyadicFractionPeriodic(numerator, power);
                if (n == 0)
                {
                    if (kModPositive == 1) { ApplyGlobalPhaseFracControlled(controls, 1, 0); }
                    else if (kModPositive == 0) { }
                    else { throw new Exception("Something went wrong."); }
                }
                else if (n == 1)
                {
                    if (kModPositive == 1) { ApplyUsingSinglyControlledVersion(Z, CRzFrac11, controls, qubit); }
                    else if (kModPositive == 3) { ApplyUsingSinglyControlledVersion(Z, CRzFrac11Adj, controls, qubit); }
                    else { throw new Exception("Something went wrong."); }
                }
                else if (n == 2)
                {
                    if (kModPositive == 1) { ApplyUsingSinglyControlledVersion(SAdjoint, CRzFrac12, controls, qubit); }
                    else if (kModPositive == 3) { ApplyUsingSinglyControlledVersion(S, CRzFrac32, controls, qubit); }
                    else if (kModPositive == 5) { ApplyUsingSinglyControlledVersion(SAdjoint, CRzFrac32Adj, controls, qubit); }
                    else if (kModPositive == 7) { ApplyUsingSinglyControlledVersion(S, CRzFrac12Adj, controls, qubit); }
                    else { throw new Exception("Something went wrong"); }
                }
                else
                {
                    ApplyUsingSinglyControlledVersion(
                        (q) => this.R1Frac(-kModPositive, n - 1, q),
                        (c, q) => CRzFrac(kModPositive, n, c, q),
                        controls,
                        qubit);

                    void CRzFrac(long num, long denomPow, Qubit control, Qubit q)
                    {
                        this.R1Frac(num, denomPow, control);
                        this.ControlledR1Frac(ToIQArray(control), -num, denomPow - 1, qubit);
                    }
                }
            }
        }

        protected virtual void CRzFrac12(Qubit control, Qubit qubit)
        {
            this.TAdjoint(qubit);

            this.CNOT(control, qubit);
            this.T(qubit);
            this.CNOT(control, qubit);
        }

        protected virtual void CRzFrac12Adj(Qubit control, Qubit qubit)
        {
            this.CNOT(control, qubit);
            this.TAdjoint(qubit);
            this.CNOT(control, qubit);

            this.T(qubit);
        }

        protected virtual void CRzFrac32(Qubit control, Qubit qubit)
        {
            this.Z(control);
            this.T(qubit);

            this.CNOT(control, qubit);
            this.TAdjoint(qubit);
            this.CNOT(control, qubit);
        }

        protected virtual void CRzFrac32Adj(Qubit control, Qubit qubit)
        {
            this.CNOT(control, qubit);
            this.T(qubit);
            this.CNOT(control, qubit);

            this.TAdjoint(qubit);
            this.Z(control);
        }

        protected virtual void CRzFrac11(Qubit control, Qubit qubit)
        {
            this.S(control);
            this.ControlledZ(ToIQArray(control), qubit);
        }

        protected virtual void CRzFrac11Adj(Qubit control, Qubit qubit)
        {
            this.ControlledZ(ToIQArray(control), qubit);
            this.SAdjoint(control);
        }

        #endregion

        #region Utility Functions

        protected virtual void ApplyUsingSinglyControlledVersion(Op op, SinglyControlledOp cOp, IQArray<Qubit> controls, Qubit target)
        {
            if (controls.Length == 0)
            {
                op(target);
            }
            else if (controls.Length == 1)
            {
                cOp(controls[0], target);
            }
            else
            {
                ControlledOp self = (ctrls, q) => ApplyUsingSinglyControlledVersion(op, cOp, ctrls, q);
                ApplyWithOneLessControl(self, controls, target);
            }
        }

        protected virtual void WithinMapPauliZ(Pauli pauli, Op op, Qubit qubit)
        {
            switch (pauli)
            {
                case Pauli.PauliZ:
                    op(qubit);
                    break;
                case Pauli.PauliX:
                    this.H(qubit);
                    op(qubit);
                    this.H(qubit);
                    break;
                case Pauli.PauliY:
                    this.H(qubit);
                    this.S(qubit);
                    this.H(qubit);
                    op(qubit);
                    this.H(qubit);
                    this.SAdjoint(qubit);
                    this.H(qubit);
                    break;
                case Pauli.PauliI:
                    throw new ArgumentException("Pauli is identity");
            }
        }

        protected virtual void WithinMapPauliZAdj(Pauli pauli, Op op, Qubit qubit)
        {
            switch (pauli)
            {
                case Pauli.PauliZ:
                    op(qubit);
                    break;
                case Pauli.PauliX:
                    this.H(qubit);
                    op(qubit);
                    this.H(qubit);
                    break;
                case Pauli.PauliY:
                    this.H(qubit);
                    this.SAdjoint(qubit);
                    this.H(qubit);
                    op(qubit);
                    this.H(qubit);
                    this.S(qubit);
                    this.H(qubit);
                    break;
                case Pauli.PauliI:
                    throw new Exception("Expecting Pauli not equal to identity");
            }
        }

        protected virtual void WithinMapPauliZ(Pauli pauli, ControlledOp op, IQArray<Qubit> controls, Qubit qubit)
        {
            WithinMapPauliZ(pauli, (target) => op(controls, target), qubit);
        }

        protected virtual void WithinMapPaulisZ(IQArray<Pauli> paulis, Action<IQArray<Qubit>> op, IQArray<Qubit> qubits)
        {
            if (paulis.Count != qubits.Count)
            { throw new ArgumentException("Lists must be same length."); }

            void mapPaulisThenOp(int currPauliIndex)
            {
                if (currPauliIndex == paulis.Count - 1)
                {
                    WithinMapPauliZ(paulis[currPauliIndex], (_) => op(qubits), qubits[currPauliIndex]);
                }
                else
                {
                    WithinMapPauliZ(paulis[currPauliIndex], (_) => mapPaulisThenOp(currPauliIndex + 1), qubits[currPauliIndex]);
                }
            }
            mapPaulisThenOp(0);
        }

        protected virtual void CNOT(Qubit control, Qubit qubit)
        {
            this.ControlledX(ToIQArray(control), qubit);
        }

        protected virtual void ApplyWithOneLessControl(ControlledOp op, IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            { throw new ArgumentException("Not enough controls!"); }

            //See: AsRCczTClifford.CCXAssertingTargetIsZero, AsRCczTClifford.ApplyWithOneLessControlA and
            //[arXiv:1709.06648](https://arxiv.org/pdf/1709.06648.pdf)

            Qubit control0 = controls[0];
            Qubit control1 = controls.Length > 1 ? controls[1] : qubit;
            Qubit helper = this.Simulator.Get<Allocate, Allocate>().Apply(); //TODO: cache?
            Qubit target = controls.Length > 1 ? qubit : helper;

            this.Assert(ToIQArray(Pauli.PauliZ), ToIQArray(helper), Result.Zero, "");
            this.ControlledX(ToIQArray(control0, control1), helper);

            IQArray<Qubit> oneLessControl = controls.Slice(new QRange(2, controls.Length - 1));
            if (controls.Length > 1) { oneLessControl = new QArray<Qubit>(oneLessControl.Prepend(helper)); }

            op(oneLessControl, target);

            this.H(helper);
            this.AssertProb(ToIQArray(Pauli.PauliZ), ToIQArray(helper), 0.5, "", 0.0000000001);
            Result res = this.M(helper);

            long id = this.StartConditionalStatement(res, Result.One);
            if (this.RunThenClause(id))
            {
                this.X(helper);
                this.ControlledZ(ToIQArray(control0), control1);
            }
            this.EndConditionalStatement(id);

            this.Simulator.Get<Release, Release>().Apply(helper);

            //TODO: check if following is correctly translated
            //let res = MResetZ(helper);
            //ApplyIfOne(res, (CZ, (control0,control1)) );
        }

        protected virtual void ApplyPhaseOp(Op op, IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            {
                op(qubit);
            }
            else
            {
                ApplyWithOneLessControl((cntrls, q) => ApplyPhaseOp(op, cntrls, q), controls, qubit);
            }
        }

        protected virtual IQArray<T> ToIQArray<T>(params T[] args)
        {
            return new QArray<T>(args);
        }

        #endregion

        #endregion

        public override void OnDumpMachine<T>(T location)
        {
            if (location == null) { throw new ArgumentNullException(nameof(location)); }

            var filename = (location is QVoid) ? "" : location.ToString();
            var msg = "TracerSimulator doesn't support state dump.";

            if (string.IsNullOrEmpty(filename))
            {
                this.OnMessage(msg);
            }
            else
            {
                try
                {
                    File.WriteAllText(filename, msg);
                }
                catch (Exception e)
                {
                    this.OnMessage($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
        }

        public override void OnDumpRegister<T>(T location, IQArray<Qubit> qubits)
        {
            if (location == null) { throw new ArgumentNullException(nameof(location)); }

            var filename = (location is QVoid) ? "" : location.ToString();
            var msg = "QCTraceSimulator doesn't support state dump.";

            if (string.IsNullOrEmpty(filename))
            {
                this.OnMessage(msg);
            }
            else
            {
                try
                {
                    File.WriteAllText(filename, msg);
                }
                catch (Exception e)
                {
                    this.OnMessage($"[warning] Unable to write state to '{filename}' ({e.Message})");
                }
            }
        }
    }
}