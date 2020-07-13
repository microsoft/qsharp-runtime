using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.GateDecomposition;
using System;
using System.Collections.Generic;
using System.Linq;
using static Microsoft.Quantum.Simulation.Simulators.NewTracer.GateDecomposition.DecompositionUtils;

namespace Microsoft.Quantum.Simulators.NewTracer.GateDecomposition
{
    //TODO: provide reference to white paper and q-sharp decomposition implementation
    public class DefaultDecomposer : DecomposerBase
    {
        protected readonly SimulatorBase Simulator;
        protected readonly Allocate AllocateQubit;
        protected readonly Release ReleaseQubit;

        //TODO: somehow register tracer during constructor
        public DefaultDecomposer(IQuantumProcessor targetProcessor, SimulatorBase sim)
            : base(targetProcessor)
        {
            this.Simulator = sim ?? throw new ArgumentNullException(nameof(sim));
            this.AllocateQubit = sim.Get<Allocate>(typeof(Allocate));
            this.ReleaseQubit = sim.Get<Release>(typeof(Release));
        }

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
            else if (controls.Length <= 2) //TODO: should this 2 be a 1?
            {
                Target.ControlledZ(controls, qubit);
            }
            else
            {
                ApplyWithOneLessControl(this.ControlledZ, controls, qubit);
            }
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

        public override void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            if (controls.Length == 0)
            {
                this.SWAP(qubit1, qubit2);
            }
            else if (controls.Length == 1)
            {
                this.ControlledX(ToIQArray(qubit2), qubit1);
                this.ControlledX(ToIQArray(controls[0], qubit1), qubit2);
                this.ControlledX(ToIQArray(qubit2), qubit1);
            }
            else
            {
                ControlledOp self = (cntrls, _) => ControlledSWAP(cntrls, qubit1, qubit2);
                ApplyWithOneLessControl(self, controls, null);
            }
        }

        public override void Reset(Qubit qubit)
        {
            if (this.M(qubit) == Result.One)
            {
                X(qubit);
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
                            this.S(qubit);
                            this.T(qubit);
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
                RemoveIdentities(paulis, qubits, out IList<Pauli> newPaulis, out IList<Qubit> newQubits);

                if (newPaulis.Count != 0)
                {
                    void cExpZ(IList<Qubit> _qubits)
                    {
                        //TODO: controls need to be in here as well?
                        for (int i = 1; i < _qubits.Count; i++)
                        { this.ControlledX(ToIQArray(_qubits[i]), _qubits[0]); }

                        this.ControlledRz(controls, -2.0 * theta, _qubits[0]);

                        // adjoint:
                        for (int i = _qubits.Count - 1; i >= 1; i--)
                        { this.ControlledX(ToIQArray(_qubits[i]), _qubits[0]); }
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
            if (paulis.Length != 0)
            {
                RemoveIdentities(paulis, qubits, out var newPaulis, out var newQubits);

                if (newPaulis.Count != 0)
                {
                    //TODO: pull this out as own method and have it be overwritten
                    void cExpFracZ(IList<Qubit> _qubits)
                    {
                        for (int i = 1; i < _qubits.Count; i++)
                        { this.ControlledX(ToIQArray(_qubits[i]), _qubits[0]); }

                        this.ControlledRFrac(controls, Pauli.PauliZ, numerator, power, _qubits[0]);

                        for (int i = _qubits.Count - 1; i >= 1; i--)
                        { this.ControlledX(ToIQArray(_qubits[i]), _qubits[0]); }
                    }

                    WithinMapPaulisZ(newPaulis, (qs) => cExpFracZ(qs), newQubits);
                }
                else
                {
                    this.ApplyGlobalPhaseFracControlled(controls, numerator, power);
                }
            }
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

        protected virtual void Rz(double theta, Qubit qubit)
        {
            base.R(Pauli.PauliZ, theta, qubit);
        }

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

            this.ControlledX(ToIQArray(control), qubit);
            this.T(qubit);
            this.ControlledX(ToIQArray(control), qubit);
        }

        protected virtual void CRzFrac12Adj(Qubit control, Qubit qubit)
        {
            this.ControlledX(ToIQArray(control), qubit);
            this.TAdjoint(qubit);
            this.ControlledX(ToIQArray(control), qubit);

            this.T(qubit);
        }

        protected virtual void CRzFrac32(Qubit control, Qubit qubit)
        {
            this.Z(control);
            this.T(qubit);

            this.ControlledX(ToIQArray(control), qubit);
            this.TAdjoint(qubit);
            this.ControlledX(ToIQArray(control), qubit);
        }

        protected virtual void CRzFrac32Adj(Qubit control, Qubit qubit)
        {
            this.ControlledX(ToIQArray(control), qubit);
            this.T(qubit);
            this.ControlledX(ToIQArray(control), qubit);

            this.TAdjoint(qubit);
            this.Z(qubit);
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

        protected virtual void WithinMapPaulisZ(IList<Pauli> paulis, Action<IList<Qubit>> op, IList<Qubit> qubits)
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

        protected virtual void ApplyWithOneLessControl(ControlledOp op, IQArray<Qubit> controls, Qubit qubit)
        {
            if (controls.Length == 0)
            { throw new ArgumentException("Not enough controls!"); }

            //See: AsRCczTClifford.CCXAssertingTargetIsZero, AsRCczTClifford.ApplyWithOneLessControlA and
            //[arXiv:1709.06648](https://arxiv.org/pdf/1709.06648.pdf)

            Qubit control0 = controls[0];
            Qubit control1 = controls.Length > 1 ? controls[1] : qubit;
            Qubit helper = this.AllocateQubit.Apply();
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

            this.ReleaseQubit.Apply(helper);

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

        protected virtual Qubit AllocateAncillaQubit()
        {
            Qubit qubit = MockQubit();
            OnAllocateQubits(ToIQArray(qubit));
            return qubit;
        }

        protected virtual IQArray<T> ToIQArray<T>(params T[] args)
        {
            //TODO: when optimizing performance consider mocking qubit arrays in instances where we'd
            //only care about the number of qubits
            return new QArray<T>(args);
        }

        private int ancillaCounter = -1;
        /// <summary>
        /// This is a hack for generating mock ancilla qubits needed in the course of operation decomposition 
        /// that can then be used in <see cref="IQuantumProcessor"/> method dispatches to the attached Target,
        /// so that e.g. a gate tracker can count measurements of such ancilla qubits.
        /// Qubit IDs are negative so as not to conflict with actual qubit objects generated by a simulator.
        /// Instances of this class shouldn't ever be exposed outside of the tracer, but nevertheless I am not 
        /// sure what the potential dangers of negative IDs are.
        /// </summary>
        private class MockAncillaQubit : Qubit
        {
            internal MockAncillaQubit(int id) : base(id)
            {
            }
        }
        protected virtual Qubit MockQubit()
        {
            return new MockAncillaQubit(ancillaCounter--);
        }

        #endregion
    }
}
