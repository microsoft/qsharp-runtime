// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public const string QSIM_DLL_NAME = "Microsoft.Quantum.Simulator.Runtime"; // If this is not public then
            // we get a CI build error:
            // Preparation\Arbitrary.cs(23,41): error CS0117: 'QuantumSimulator' does not contain a definition for
            // 'QSIM_DLL_NAME' [D:\a\1\s\submodules\QuantumLibraries\Standard\src\Standard.csproj]

        [DllImport("libomp", ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "omp_get_num_threads")]
        private static extern int OmpGetNumberOfThreadsNative();

        private delegate void IdsCallback(uint id);
        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpIds")]
        private static extern void sim_QubitsIdsNative(IntPtr id, IdsCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "init")]
        private static extern IntPtr InitNative();

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "destroy")]
        private static extern uint DestroyNative(IntPtr id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "seed")]
        private static extern void SetSeedNative(IntPtr id, UInt32 seedValue);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "allocateQubit")]
        private static extern void AllocateOneNative(IntPtr id, uint qubit_id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "release")]
        private static extern bool ReleaseOneNative(IntPtr id, uint qubit_id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Exp")]
        private static extern void ExpNative(IntPtr id, uint n, Pauli[] paulis, double angle, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCExp")]
        private static extern void MCExpNative(IntPtr id, uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "H")]
        private static extern void HNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCH")]
        private static extern void MCHNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "M")]
        private static extern uint MNative(IntPtr id, uint q);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Measure")]
        private static extern uint MeasureNative(IntPtr id, uint n, Pauli[] b, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
        private static extern void RNative(IntPtr id, Pauli basis, double angle, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCR")]
        private static extern void MCRNative(IntPtr id, Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "S")]
        private static extern void SNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjS")]
        private static extern void AdjSNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCS")]
        private static extern void MCSNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjS")]
        private static extern void MCAdjSNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "T")]
        private static extern void TNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjT")]
        private static extern void AdjTNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCT")]
        private static extern void MCTNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjT")]
        private static extern void MCAdjTNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "X")]
        private static extern void XNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
        private static extern void MCXNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Y")]
        private static extern void YNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCY")]
        private static extern void MCYNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Z")]
        private static extern void ZNative(IntPtr id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCZ")]
        private static extern void MCZNative(IntPtr id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Dump")]
        private static extern void sim_DumpNative(IntPtr id, DumpCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpQubits")]
        private static extern bool sim_DumpQubitsNative(IntPtr id, uint cout, uint[] ids, DumpCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "JointEnsembleProbability")]
        private static extern double JointEnsembleProbabilityNative(IntPtr id, uint n, Pauli[] b, uint[] q);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "random_choice")]
        private static extern Int64 random_choiceNative(IntPtr id, Int64 size, double[] p);
    }
}