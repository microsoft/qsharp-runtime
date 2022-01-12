// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.


using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        protected override void MCX(uint count, uint[] ctrls, uint qubit)
        {
            MCXNative(this.Id, count, ctrls, qubit);
        }

        protected override void MCZ(uint count, uint[] ctrls, uint qubit)
        {
            MCZNative(this.Id, count, ctrls, qubit);
        }

        protected override void H(uint qubit)
        {
            HNative(this.Id, qubit);
        }
        protected override void MCH(uint count, uint[] ctrls, uint qubit)
        {
            MCHNative(this.Id, count, ctrls, qubit);
        }

        protected override void R(Pauli basis, double angle, uint qubit)
        {
            RNative(this.Id, basis, angle, qubit);
        }

        protected override void S(uint qubit)
        {
            SNative(this.Id, qubit);
        }

        protected override void AdjS(uint qubit)
        {
            AdjSNative(this.Id, qubit);
        }

        protected override void T(uint qubit)
        {
            TNative(this.Id, qubit);
        }

        protected override void AdjT(uint qubit)
        {
            AdjTNative(this.Id, qubit);
        }

        protected override void X(uint qubit)
        {
            XNative(this.Id, qubit);
        }

        protected override void Y(uint qubit)
        {
            YNative(this.Id, qubit);
        }

        protected override void Z(uint qubit)
        {
            ZNative(this.Id, qubit);
        }

        protected override double JointEnsembleProbability(uint n, Pauli[] b, uint[] q)
        {
            return JointEnsembleProbabilityNative(this.Id, n, b, q);
        }

        protected override void Exp(uint n, Pauli[] paulis, double angle, uint[] ids)
        {
            ExpNative(this.Id, n, paulis, angle, ids);
        }

        protected override void MCExp(uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids)
        {
            MCExpNative(this.Id, n, paulis, angle, nc, ctrls, ids);
        }

        protected override uint M(uint q)
        {
            return MNative(this.Id, q);
        }

        protected override uint Measure(uint n, Pauli[] b, uint[] ids)
        {
            return MeasureNative(this.Id, n, b, ids);
        }

        protected override void MCR(Pauli basis, double angle, uint count, uint[] ctrls, uint qubit)
        {
            MCRNative(this.Id, basis, angle, count, ctrls, qubit);
        }

        protected override void MCS(uint count, uint[] ctrls, uint qubit)
        {
            MCSNative(this.Id, count, ctrls, qubit);
        }

        protected override void MCAdjS(uint count, uint[] ctrls, uint qubit)
        {
            MCAdjSNative(this.Id, count, ctrls, qubit);
        }

        protected override void sim_Dump(DumpCallback callback)
        {
            sim_DumpNative(this.Id, callback);
        }

        protected override bool sim_DumpQubits(uint count, uint[] ids, DumpCallback callback)
        {
            return sim_DumpQubitsNative(this.Id, count, ids, callback);
        }

        protected override void MCT(uint count, uint[] ctrls, uint qubit)
        {
            MCTNative(this.Id, count, ctrls, qubit);
        }

        protected override void MCAdjT(uint count, uint[] ctrls, uint qubit)
        {
            MCAdjTNative(this.Id, count, ctrls, qubit);
        }

        protected override void MCY(uint count, uint[] ctrls, uint qubit)
        {
            MCYNative(this.Id, count, ctrls, qubit);
        }

        protected override void AllocateOne(uint qubit_id)
        {
            AllocateOneNative(this.Id, qubit_id);
        }
        protected override bool ReleaseOne(uint qubit_id)
        {
            return ReleaseOneNative(this.Id, qubit_id);
        }

    }
}