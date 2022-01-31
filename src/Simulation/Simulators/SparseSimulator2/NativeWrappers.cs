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
            //MCXNative(this.Id, count, ctrls, qubit);

            // private static extern void MCXNative(uint id, uint count, uint[] ctrls, uint qubit);
            // private static extern void MCX_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);
            //QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCX_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);
        }

        protected override void MCZ(uint count, uint[] ctrls, uint qubit)
        {
            //MCZNative(this.Id, count, ctrls, qubit);
            // private static extern void MCZNative(uint id, uint count, uint[] ctrls, uint qubit);
            //private static extern void MCZ_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);
            //QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCZ_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);

        }

        protected override void H(uint qubit)
        {
            //HNative(this.Id, qubit);
            //private static extern void H_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            H_cpp(this.Id, (QubitIdType)qubit);
        }
        protected override void MCH(uint count, uint[] ctrls, uint qubit)
        {
            //MCHNative(this.Id, count, ctrls, qubit);
            //MCH_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);
            //QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCH_cpp(this.Id, (int)count, ctrls, (QubitIdType)qubit);
        }

        protected override void R(Pauli basis, double angle, uint qubit)
        {
            //RNative(this.Id, basis, angle, qubit);
            //private static extern void R_cpp(SimulatorIdType sim, int axis, double theta, QubitIdType qubit_id);
            R_cpp(this.Id, (int)basis, angle, (QubitIdType)qubit);
        }

        protected override void S(uint qubit)
        {
            //SNative(this.Id, qubit);
            //private static extern void S_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            S_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void AdjS(uint qubit)
        {
            //AdjSNative(this.Id, qubit);
            //private static extern void AdjS_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            AdjS_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void T(uint qubit)
        {
            // TNative(this.Id, qubit);
            // private static extern void T_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            T_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void AdjT(uint qubit)
        {
            // AdjTNative(this.Id, qubit);
            // private static extern void AdjT_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            AdjT_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void X(uint qubit)
        {
            // XNative(this.Id, qubit);
            // private static extern void X_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            X_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void Y(uint qubit)
        {
            // YNative(this.Id, qubit);
            // private static extern void Y_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            Y_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override void Z(uint qubit)
        {
            // ZNative(this.Id, qubit);
            // private static extern void Z_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            Z_cpp(this.Id, (QubitIdType)qubit);
        }

        protected override double JointEnsembleProbability(uint n, Pauli[] b, uint[] q)
        {
            // return JointEnsembleProbabilityNative(this.Id, n, b, q);
            // private static extern double JointEnsembleProbabilityNative(uint id, uint n, Pauli[] b, uint[] q);
            // private static extern double JointEnsembleProbability_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);
            //QubitIdType[] qids = q.Select(c => (QubitIdType)c).ToArray();
            int[] bases = b.Cast<int>().ToArray();
            return JointEnsembleProbability_cpp(this.Id, (int)n, bases, q);
        }

        protected override void Exp(uint n, Pauli[] paulis, double angle, uint[] ids)
        {
            // ExpNative(this.Id, n, paulis, angle, ids);
            // private static extern void Exp_cpp(SimulatorIdType sim, int length, int[] b, double phi, QubitIdType[] q);
            int[] bases = paulis.Cast<int>().ToArray();
            //QubitIdType[] qids = ids.Select(c => (QubitIdType)c).ToArray();
            Exp_cpp(this.Id, (int)n, bases, angle, ids);
        }

        protected override void MCExp(uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids)
        {
            // MCExpNative(this.Id, n, paulis, angle, nc, ctrls, ids);
            // private static extern void MCExp_cpp(SimulatorIdType sim, int controls_length, int length, QubitIdType[] c, int[] b, double phi, QubitIdType[] q);
            int[] bases = paulis.Cast<int>().ToArray();
            //QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            //QubitIdType[] qids = ids.Select(c => (QubitIdType)c).ToArray();
            MCExp_cpp(this.Id, (int)nc, (int)n, ctrls, bases, angle, ids);
        }

        protected override uint M(uint q)
        {
            // return MNative(this.Id, q);
            // private static extern bool M_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            return M_cpp(this.Id, (QubitIdType)q);
        }

        protected override uint Measure(uint n, Pauli[] b, uint[] ids)
        {
            // return MeasureNative(this.Id, n, b, ids);
            // private static extern bool Measure_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);
            int[] bases = b.Cast<int>().ToArray();
            QubitIdType[] qids = ids.Select(c => (QubitIdType)c).ToArray();
            return Measure_cpp(this.Id, (int)n, bases, qids);
        }

        protected override void MCR(Pauli basis, double angle, uint count, uint[] ctrls, uint qubit)
        {
            // MCRNative(this.Id, basis, angle, count, ctrls, qubit);
            // private static extern void MCR_cpp(SimulatorIdType sim, int basis, double angle, int length, QubitIdType[] controls, QubitIdType target);
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
            // sim_DumpNative(this.Id, callback);
            // private static extern void Dump_cpp(SimulatorIdType sim, QubitIdType max_qubits, DumpCallback callback);
            // TODO(rokuzmin)
            throw new UnsupportedOperationException();
        }

        protected override bool sim_DumpQubits(uint count, uint[] ids, DumpCallback callback)
        {
            // return sim_DumpQubitsNative(this.Id, count, ids, callback);

            // private delegate void DumpCallback(StringBuilder label, double real, double img);
            // private static extern bool DumpQubits_cpp(SimulatorIdType sim, int length, QubitIdType[] qubit_ids, DumpCallback callback);
            
            // return DumpQubits_cpp(this.Id, (int)count, ids, callback);

            // TODO(rokuzmin)
            throw new UnsupportedOperationException();
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
            // MCYNative(this.Id, count, ctrls, qubit);
            // private static extern void MCY_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);
            QubitIdType[] controls = ctrls.Select(c => (QubitIdType)c).ToArray();
            MCY_cpp(this.Id, (int)count, controls, (QubitIdType)qubit);
        }

        protected override void AllocateOne(uint qubit_id)
        {
            // AllocateOneNative(this.Id, qubit_id);
            // private static extern void allocateQubit_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            allocateQubit_cpp(this.Id, (QubitIdType)qubit_id);
        }
        protected override bool ReleaseOne(uint qubit_id)
        {
            // return ReleaseOneNative(this.Id, qubit_id);
            // private static extern bool releaseQubit_cpp(SimulatorIdType sim, QubitIdType qubit_id);
            return releaseQubit_cpp(this.Id, (QubitIdType)qubit_id);
        }

    }
}