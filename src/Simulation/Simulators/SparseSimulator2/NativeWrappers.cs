// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Linq;

#nullable enable

namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.UInt32;
    using SimulatorIdType = System.UInt32;

    public partial class SparseSimulator2
    {
        protected override void MCX(uint count, uint[] ctrls, uint qubit)
        {
            MCX_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);
        }

        protected override void MCZ(uint count, uint[] ctrls, uint qubit)
        {
            MCZ_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);

        }

        protected override void H(uint qubit)
        {
            H_cpp(this.Id, (QubitIdType)qubit);
        }
        protected override void MCH(uint count, uint[] ctrls, uint qubit)
        {
            MCH_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);
        }

        protected override void R(Pauli basis, double angle, uint qubit)
        {
            R_cpp(this.Id, (int)basis, angle, (QubitIdType)qubit);
        }

        protected override void S(uint qubit)
        {
            S_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void AdjS(uint qubit)
        {
            AdjS_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void T(uint qubit)
        {
            T_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void AdjT(uint qubit)
        {
            AdjT_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void X(uint qubit)
        {
            X_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void Y(uint qubit)
        {
            Y_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void Z(uint qubit)
        {
            Z_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override double JointEnsembleProbability(uint n, Pauli[] b, uint[] q)
        {
            int[] bases = b.Cast<int>().ToArray();
            return JointEnsembleProbability_cpp(this.Id, (int)n, bases, q);
        }

        protected override void Exp(uint n, Pauli[] paulis, double angle, uint[] ids)
        {
            int[] bases = paulis.Cast<int>().ToArray();
            Exp_cpp(this.Id, (int)n, bases, angle, ids);
        }

        protected override void MCExp(uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids)
        {
            int[] bases = paulis.Cast<int>().ToArray();
            MCExp_cpp(this.Id, (int)nc, (int)n, ctrls, bases, angle, ids);
        }

        protected override uint M(uint q)
        {
            return M_cpp(this.Id, (QubitIdType)q);
        }

        protected override uint Measure(uint n, Pauli[] b, uint[] ids)
        {
            int[] bases = b.Cast<int>().ToArray();
            QubitIdType[] qids = ids.Select(c => (QubitIdType)c).ToArray();
            return Measure_cpp(this.Id, (int)n, bases, qids);
        }

        protected override void MCR(Pauli basis, double angle, uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCR_cpp(this.Id, (int)basis, angle, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void MCS(uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCR1_cpp(this.Id, 0.5*System.Math.PI, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void MCAdjS(uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCR1_cpp(this.Id, -0.5*System.Math.PI, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void sim_Dump(DumpCallback callback)
        {
            Dump_cpp(this.Id, callback);
        }

        protected override bool sim_DumpQubits(uint count, uint[] ids, DumpCallback callback)
        {
            QubitIdType[] qs = ids.Select(q => (QubitIdType)q).ToArray();
            return DumpQubits_cpp(this.Id, (int)count, qs, callback);
        }

        protected override void MCT(uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCR1_cpp(this.Id, 0.25*System.Math.PI, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void MCAdjT(uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCR1_cpp(this.Id, -0.25*System.Math.PI, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void MCY(uint count, uint[] ctrls, uint qubit)
        {
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCY_cpp(this.Id, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void AllocateOne(uint qubit_id)
        {
            allocateQubit_cpp(this.Id, (QubitIdType)qubit_id);
        }
        protected override bool ReleaseOne(uint qubit_id)
        {
            return releaseQubit_cpp(this.Id, (QubitIdType)qubit_id);
        }

    }
}
