using Microsoft.Quantum.Simulation.Core;
using System.Runtime.InteropServices;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        protected abstract double JointEnsembleProbability(uint n, Pauli[] b, uint[] q);
        protected abstract void Exp(uint n, Pauli[] paulis, double angle, uint[] ids);
        protected abstract void MCExp(uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);
        protected abstract void H(uint qubit);
        protected abstract void MCH(uint count, uint[] ctrls, uint qubit);
        protected abstract uint M(uint q);
        protected abstract uint Measure(uint n, Pauli[] b, uint[] ids);
        protected abstract void AllocateOne(uint qubit_id);
        protected abstract bool ReleaseOne(uint qubit_id);
        protected abstract void R(Pauli basis, double angle, uint qubit);
        protected abstract void MCR(Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);
        protected abstract void S(uint qubit);
        protected abstract void AdjS(uint qubit);
        protected abstract void MCS(uint count, uint[] ctrls, uint qubit);
        protected abstract void MCAdjS(uint count, uint[] ctrls, uint qubit);
        protected abstract void T(uint qubit);
        protected abstract void AdjT(uint qubit);
        protected abstract void MCT(uint count, uint[] ctrls, uint qubit);
        protected abstract void MCAdjT(uint count, uint[] ctrls, uint qubit);
        protected abstract void X(uint qubit);
        protected abstract void MCX(uint count, uint[] ctrls, uint qubit);
        protected abstract void Y(uint qubit);
        protected abstract void MCY(uint count, uint[] ctrls, uint qubit);
        protected abstract void Z(uint qubit);
        protected abstract void MCZ(uint count, uint[] ctrls, uint qubit);

        protected delegate bool DumpCallback([MarshalAs(UnmanagedType.LPStr)] string idx, double real, double img);
        protected abstract void sim_Dump(DumpCallback callback);
        protected abstract bool sim_DumpQubits(uint count, uint[] ids, DumpCallback callback);
    }
}
