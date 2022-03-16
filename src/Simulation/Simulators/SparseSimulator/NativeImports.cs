// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

#nullable enable
namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.UInt32;
    using SimulatorIdType = System.UInt32;

    public partial class SparseSimulator
    {
        private const string simulatorDll = "Microsoft.Quantum.SparseSimulator.Runtime";

        [DllImport(simulatorDll)]
        private static extern QubitIdType num_qubits_cpp(SimulatorIdType sim);

        [DllImport(simulatorDll)]
        private static extern SimulatorIdType init_cpp(QubitIdType numQubits);

        [DllImport(simulatorDll)]
        private static extern void destroy_cpp(SimulatorIdType sim);

        [DllImport(simulatorDll)]
        private static extern void seed_cpp(SimulatorIdType sim, uint newSeed);

        [DllImport(simulatorDll)]
        private static extern void allocateQubit_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern bool releaseQubit_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void Exp_cpp(SimulatorIdType sim, int length, int[] b, double phi, QubitIdType[] q);

        [DllImport(simulatorDll)]
        private static extern void MCExp_cpp(SimulatorIdType sim, int controlsLength, int length, QubitIdType[] c, int[] b, double phi, QubitIdType[] q);

        [DllImport(simulatorDll)]
        private static extern void H_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void MCH_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern uint M_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern uint Measure_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);

        [DllImport(simulatorDll)]
        private static extern void R_cpp(SimulatorIdType sim, int axis, double theta, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void MCR_cpp(SimulatorIdType sim, int basis, double angle, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern void MCR1_cpp(SimulatorIdType sim, double angle, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern void S_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void AdjS_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void T_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void AdjT_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void X_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void MCX_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern void Y_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void MCY_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern void Z_cpp(SimulatorIdType sim, QubitIdType qubitId);

        [DllImport(simulatorDll)]
        private static extern void MCZ_cpp(SimulatorIdType sim, int length, QubitIdType[] controls, QubitIdType target);

        [DllImport(simulatorDll)]
        private static extern void Dump_cpp(SimulatorIdType sim, DumpCallback callback);

        [DllImport(simulatorDll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool DumpQubits_cpp(SimulatorIdType sim, int length, QubitIdType[] qubitIds, DumpCallback callback);

        private delegate void IdsCallback(QubitIdType id);
        [DllImport(simulatorDll)]
        private static extern void QubitIds_cpp(SimulatorIdType sim, IdsCallback callback);

        [DllImport(simulatorDll)] 
        private static extern double JointEnsembleProbability_cpp(SimulatorIdType sim, int length, int[] basis, QubitIdType[] qubits);

    }
}
