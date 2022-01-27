// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

#nullable enable
namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.IntPtr;
    using SimulatorIdType = System.UInt32;

    public partial class SparseSimulator2
    {
        //public const string QSIM_DLL_NAME = "SparseQuantumSimulator.dll"; 
        private const string simulatorDll = "SparseQuantumSimulator";

        // [DllImport("libomp", ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "omp_get_num_threads")]
        // private static extern int OmpGetNumberOfThreadsNative();

        [DllImport(simulatorDll)]
        private static extern QubitIdType num_qubits_cpp(SimulatorIdType sim);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "init")]
        // private static extern uint InitNative();
        [DllImport(simulatorDll)]
        private static extern SimulatorIdType init_cpp(QubitIdType numQubits);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "destroy")]
        // private static extern uint DestroyNative(uint id);
        [DllImport(simulatorDll)]
        private static extern void destroy_cpp(SimulatorIdType sim);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "seed")]
        // private static extern void SetSeedNative(uint id, UInt32 seedValue);
        [DllImport(simulatorDll)]
        private static extern void seed_cpp(SimulatorIdType sim, uint newSeed);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "allocateQubit")]
        // private static extern void AllocateOneNative(uint id, uint qubitId);
        [DllImport(simulatorDll)]
        private static extern void allocateQubit_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "release")]
        // private static extern bool ReleaseOneNative(uint id, uint qubitId);
        [DllImport(simulatorDll)]
        private static extern bool releaseQubit_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Exp")]
        // private static extern void ExpNative(uint id, uint n, Pauli[] paulis, double angle, uint[] ids);
        [DllImport(simulatorDll)]
        private static extern void Exp_cpp(SimulatorIdType sim, int length, int[] b, double phi, QubitIdType[] q);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCExp")]
        // private static extern void MCExpNative(uint id, uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);
        [DllImport(simulatorDll)]
        private static extern void MCExp_cpp(SimulatorIdType sim, int controlsLength, int length, QubitIdType[] c, int[] b, double phi, QubitIdType[] q);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "H")]
        // private static extern void HNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void H_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCH")]
        // private static extern void MCHNative(uint id, uint count, uint[] ctrls, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void MCH_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "M")]
        // private static extern uint MNative(uint id, uint q);
        [DllImport(simulatorDll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool M_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Measure")]
        // private static extern uint MeasureNative(uint id, uint n, Pauli[] b, uint[] ids);
        [DllImport(simulatorDll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool Measure_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
        // private static extern void RNative(uint id, Pauli basis, double angle, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void R_cpp(SimulatorIdType sim, int axis, double theta, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCR")]
        // private static extern void MCRNative(uint id, Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void MCR_cpp(SimulatorIdType sim, int basis, double angle, int length, QubitIdType[] controls, QubitIdType target);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "S")]
        // private static extern void SNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void S_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjS")]
        // private static extern void AdjSNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void AdjS_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // TODO(rokuzmin)
        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCS")]
        // private static extern void MCSNative(uint id, uint count, uint[] ctrls, uint qubit);

        // TODO(rokuzmin)
        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjS")]
        // private static extern void MCAdjSNative(uint id, uint count, uint[] ctrls, uint qubit);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "T")]
        // private static extern void TNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void T_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjT")]
        // private static extern void AdjTNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void AdjT_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // TODO(rokuzmin)
        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCT")]
        // private static extern void MCTNative(uint id, uint count, uint[] ctrls, uint qubit);

        // TODO(rokuzmin)
        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjT")]
        // private static extern void MCAdjTNative(uint id, uint count, uint[] ctrls, uint qubit);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "X")]
        // private static extern void XNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void X_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
        // private static extern void MCXNative(uint id, uint count, uint[] ctrls, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void MCX_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Y")]
        // private static extern void YNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void Y_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCY")]
        // private static extern void MCYNative(uint id, uint count, uint[] ctrls, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void MCY_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Z")]
        // private static extern void ZNative(uint id, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void Z_cpp(SimulatorIdType sim, QubitIdType qubitId);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCZ")]
        // private static extern void MCZNative(uint id, uint count, uint[] ctrls, uint qubit);
        [DllImport(simulatorDll)]
        private static extern void MCZ_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Dump")]
        // private static extern void sim_DumpNative(uint id, DumpCallback callback);
        [DllImport(simulatorDll)]
        private static extern void Dump_cpp(SimulatorIdType sim, QubitIdType max_qubits, DumpCallback callback);

        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpQubits")]
        // private static extern bool sim_DumpQubitsNative(uint id, uint cout, uint[] ids, DumpCallback callback);
        [DllImport(simulatorDll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool DumpQubits_cpp(SimulatorIdType sim, int length, QubitIdType[] qubitIds, DumpCallback callback);

        private delegate void IdsCallback(QubitIdType id);
        //[DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpIds")]
        // private static extern void sim_QubitsIdsNative(uint id, IdsCallback callback);
        [DllImport(simulatorDll)]
        //private static extern void qubit_ids_cpp(SimulatorIdType sim, IdsCallback callback);
        private static extern void QubitIds_cpp(SimulatorIdType sim, IdsCallback callback);


        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "JointEnsembleProbability")]
        // private static extern double JointEnsembleProbabilityNative(uint id, uint n, Pauli[] b, uint[] q);
        [DllImport(simulatorDll)] 
        private static extern double JointEnsembleProbability_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);

        // TODO(rokuzmin):
        // [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "random_choice")]
        // private static extern Int64 random_choiceNative(uint id, Int64 size, double[] p);
    }
}