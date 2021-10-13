// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        private const string QSIM_DLL_NAME = "Microsoft.Quantum.Simulator.Runtime";

        private delegate void IdsCallback(uint id);
        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpIds")]
        private static extern void sim_QubitsIdsNative(uint id, IdsCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "init")]
        private static extern uint InitNative();

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "destroy")]
        private static extern uint DestroyNative(uint id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "seed")]
        private static extern void SetSeedNative(uint id, UInt32 seedValue);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "allocateQubit")]
        private static extern void AllocateOneNative(uint id, uint qubit_id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "release")]
        private static extern bool ReleaseOneNative(uint id, uint qubit_id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Exp")]
        private static extern void ExpNative(uint id, uint n, Pauli[] paulis, double angle, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCExp")]
        private static extern void MCExpNative(uint id, uint n, Pauli[] paulis, double angle, uint nc, uint[] ctrls, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "H")]
        private static extern void HNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCH")]
        private static extern void MCHNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "M")]
        private static extern uint MNative(uint id, uint q);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Measure")]
        private static extern uint MeasureNative(uint id, uint n, Pauli[] b, uint[] ids);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "R")]
        private static extern void RNative(uint id, Pauli basis, double angle, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCR")]
        private static extern void MCRNative(uint id, Pauli basis, double angle, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "S")]
        private static extern void SNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjS")]
        private static extern void AdjSNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCS")]
        private static extern void MCSNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjS")]
        private static extern void MCAdjSNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "T")]
        private static extern void TNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "AdjT")]
        private static extern void AdjTNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCT")]
        private static extern void MCTNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCAdjT")]
        private static extern void MCAdjTNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "X")]
        private static extern void XNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCX")]
        private static extern void MCXNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Y")]
        private static extern void YNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCY")]
        private static extern void MCYNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Z")]
        private static extern void ZNative(uint id, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "MCZ")]
        private static extern void MCZNative(uint id, uint count, uint[] ctrls, uint qubit);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "Dump")]
        private static extern void sim_DumpNative(uint id, DumpCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpQubits")]
        private static extern bool sim_DumpQubitsNative(uint id, uint cout, uint[] ids, DumpCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "JointEnsembleProbability")]
        private static extern double JointEnsembleProbabilityNative(uint id, uint n, Pauli[] b, uint[] q);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "random_choice")]
        private static extern Int64 random_choiceNative(uint id, Int64 size, double[] p);
    }
}