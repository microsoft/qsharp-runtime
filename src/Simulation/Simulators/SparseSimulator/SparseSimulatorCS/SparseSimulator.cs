// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System.Runtime.InteropServices;
using System.Runtime.ExceptionServices;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Newtonsoft.Json.Serialization;
using System.Reflection.Metadata.Ecma335;
using Microsoft.VisualBasic.FileIO;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.CodeAnalysis.CSharp.Syntax;
using System.Linq;
using Newtonsoft.Json.Converters;
using Microsoft.Quantum.Diagnostics;
using Microsoft.Quantum.Extensions.Math;
using Microsoft.Quantum.Math;
using System.Numerics;
using Microsoft.Quantum.Canon;
using Microsoft.Quantum.Measurement;

using Microsoft.Quantum.SparseSimulation;

namespace Microsoft.Quantum.SparseSimulation
{

    // Class that can be used as a simulator, but is mostly a wrapper
    // for the underlying SparseSimulatorProcessor
    public partial class SparseSimulator : QuantumProcessorDispatcher, IDisposable
    {
        public uint Id { get; }

        // If set to true, the simulator will output the name of all operations
        // it executes to the console, as it executes them
        public void SetLogging(bool isLogging)
        {
            ((SparseSimulatorProcessor)this.QuantumProcessor).isLogging = isLogging;
        }
      
        public SparseSimulator() : base(new SparseSimulatorProcessor() )
        {
            // Emulates AND
            Register(typeof(ApplyAnd), typeof(ApplyAndWrapper), typeof(IUnitary));
            Id = ((SparseSimulatorProcessor)this.QuantumProcessor).Id;
        }

        public void Dispose()
        {
            Dispose(true);
        }
       
        // Clears memory, specifically by telling the C++ to clear the memory
        public void Dispose(bool Disposing)
        {
            ((SparseSimulatorProcessor)this.QuantumProcessor).Dispose();
        }

        // Sets the random seed in the C++ code, used for the randomness
        // of measurements. 
        // Default value is the default for std::mt19937
        public void SetSeed(uint newSeed = 5489)
        {
            ((SparseSimulatorProcessor)this.QuantumProcessor).SetSeed(newSeed);
        }

    }


    // Class that performs all gate operations
    // Mostly a wrapper for C++ code
    partial class SparseSimulatorProcessor : QuantumProcessorBase 
    {
        // References the C++ dll that is copied in during the build
        private const string simulator_dll = "SparseQuantumSimulator.dll";
        // Controls whether it outputs all operations for debugging
        public bool isLogging = false;
        // For debugging
        private string stackDepth;

        // C++ code uses the Id to refer to this simulator in a vector of simulators
        public uint Id { get; }

        public string Name => "Sparse Simulator";

        [DllImport(simulator_dll)]
        private static extern uint init_cpp(uint num_qubits);
        public SparseSimulatorProcessor(uint num_qubits = 64)
        {
            Id = init_cpp(num_qubits);
            stackDepth = "";
        }


        [DllImport(simulator_dll)]
        private static extern void seed_cpp(uint sim, uint new_seed);
        public void SetSeed(uint newSeed = 5489)
        {
            seed_cpp(Id, newSeed);
        }



        // Basic gates
        [DllImport(simulator_dll)]
        private static extern void MCApplyAnd_cpp(uint sim, int length, int[] controls, int target);
        public void MCApplyAnd(IQArray<Qubit> controls, Qubit qubit)
        {
            MCApplyAnd_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }

        [DllImport(simulator_dll)]
        private static extern void MCAdjointApplyAnd_cpp(uint sim, int length, int[] controls, int target);
        public void MCAdjointApplyAnd(IQArray<Qubit> controls, Qubit qubit)
        {
            MCAdjointApplyAnd_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }


        [DllImport(simulator_dll)]
        private static extern void X_cpp(uint sim, int qubit_id);
        public override void X(Qubit qubit)
        { X_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void MCX_cpp(uint sim, int length, int[] controls, int target);
        public override void ControlledX(IQArray<Qubit> controls, Qubit qubit)
        {
            MCX_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void Z_cpp(uint sim, int qubit_id);
        public override void Z(Qubit qubit)
        { Z_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void MCZ_cpp(uint sim, int length, int[] controls, int target);
        public override void ControlledZ(IQArray<Qubit> controls, Qubit qubit)
        {
            MCZ_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void Y_cpp(uint sim, int qubit_id);
        public override void Y(Qubit qubit)
        { Y_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void MCY_cpp(uint sim, int length, int[] controls, int target);
        public override void ControlledY(IQArray<Qubit> controls, Qubit qubit)
        {
            MCY_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern int H_cpp(uint sim, int qubit_id);
        public override void H(Qubit qubit)
        { H_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void MCH_cpp(uint sim, int length, int[] controls, int target);
        public override void ControlledH(IQArray<Qubit> controls, Qubit qubit)
        {
            MCH_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void S_cpp(uint sim, int qubit_id);
        public override void S(Qubit qubit)
        { S_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void AdjS_cpp(uint sim, int qubit_id);
        public override void SAdjoint(Qubit qubit)
        { AdjS_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void T_cpp(uint sim, int qubit_id);
        public override void T(Qubit qubit)
        { T_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        private static extern void AdjT_cpp(uint sim, int qubit_id);
        public override void TAdjoint(Qubit qubit)
        { AdjT_cpp(Id, qubit.Id); }
        [DllImport(simulator_dll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool M_cpp(uint sim, int qubit_id);
        public override Result M(Qubit qubit)
        {
            if (M_cpp(Id, qubit.Id))
            {
                return Result.One;
            }
            else
            {
                return Result.Zero;
            }
        }
        [DllImport(simulator_dll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool Measure_cpp(uint sim, int length, int[] basis, int[] qubits);
        public override Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
        {
            if (Measure_cpp(Id, bases.Count(), bases.Select(x => (int)x).ToArray(), qubits.Select(x => x.Id).ToArray())) {
                return Result.One;
            } else { return Result.Zero; }
        }

        [DllImport(simulator_dll)]
        private static extern void Reset_cpp(uint sim, int qubit_id);
        public override void Reset(Qubit qubit)
        {
            Reset_cpp(Id, qubit.Id);
        }


        [DllImport(simulator_dll)]
        private static extern void R_cpp(uint sim, int axis, double theta, int qubit_id);
        public override void R(Pauli axis, double theta, Qubit qubit)
        {
            R_cpp(Id, (int)axis, theta, qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void MCR_cpp(uint sim, int basis, double angle, int length, int[] controls, int target);
        public override void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit)
        {
            MCR_cpp(Id, (int)axis, theta, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void Rfrac_cpp(uint sim, int axis, long numerator, long power, int qubit_id);
        public override void RFrac(Pauli axis, long numerator, long power, Qubit qubit)
        {
            Rfrac_cpp(Id, (int)axis, numerator, power, qubit.Id);
        }

        [DllImport(simulator_dll)]
        private static extern void MCRFrac_cpp(uint sim, int basis, long numerator, long power, int length, int[] controls, int target);
        public override void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit)
        {
            MCRFrac_cpp(Id, (int)axis, numerator, power, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void R1_cpp(uint sim, double theta, int qubit_id);
        public override void R1(double theta, Qubit qubit)
        {
            R1_cpp(Id, theta, qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void MCR1_cpp(uint sim, double angle, int length, int[] controls, int target);
        public override void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit)
        {
            MCR1_cpp(Id, theta, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void R1frac_cpp(uint sim, long numerator, long power, int qubit_id);
        public override void R1Frac(long numerator, long power, Qubit qubit)
        {
            R1frac_cpp(Id, numerator, power, qubit.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void MCR1Frac_cpp(uint sim, long numerator, long power, int length, int[] controls, int target);
        public override void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit)
        {
            MCR1Frac_cpp(Id, numerator, power, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit.Id);
        }

        [DllImport(simulator_dll)]
        private static extern void SWAP_cpp(uint sim, int qubit_id_1, int qubit_id_2);
        public override void SWAP(Qubit qubit1, Qubit qubit2)
        {
            SWAP_cpp(Id, qubit1.Id, qubit2.Id);
        }
        [DllImport(simulator_dll)]
        private static extern void MCSWAP_cpp(uint sim, int length, int[] controls, int qubit_id_1, int qubit_id_2);
        public override void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2)
        {
            MCSWAP_cpp(Id, controls.Count(), controls.Select(x => x.Id).ToArray(), qubit1.Id, qubit2.Id);
        }

        [DllImport(simulator_dll)]
        private static extern void Exp_cpp(uint sim, int length, int[] b, double phi, int[] q);
        public override void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            Exp_cpp(Id, paulis.Count(), paulis.Select(x => (int)x).ToArray(), theta, qubits.Select(x => x.Id).ToArray());
        }
        [DllImport(simulator_dll)]
        private static extern void MCExp_cpp(uint sim, int controls_length, int length, int[] c, int[] b, double phi, int[] q);
        public override void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits)
        {
            MCExp_cpp(Id, controls.Count(), paulis.Count(), controls.Select(x => x.Id).ToArray(), paulis.Select(x => (int)x).ToArray(), theta, qubits.Select(x => x.Id).ToArray());
        }

        [DllImport(simulator_dll)]
        [return: MarshalAs(UnmanagedType.I1)] // necessary because C++ and C# represent bools differently
        private static extern bool Assert_cpp(uint sim, int length, int[] b, int[] q, bool result);
        public override void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
        {
            // Relies on C++ catching any assertion errors and returning false
            if (!Assert_cpp(
                Id,
                bases.Count(),
                bases.Select(x => (int)x).ToArray(),
                qubits.Select(x => x.Id).ToArray(),
                result.Equals(Result.One)))
            {
                throw new Exception(msg);
            }
        }

        [DllImport(simulator_dll)] 
        private static extern double JointEnsembleProbability_cpp(uint sim, int length, int[] basis, int[] qubits);
        public override void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
        {
            double result = JointEnsembleProbability_cpp(Id, bases.Count(), bases.Select(x => (int)x).ToArray(), qubits.Select(x => x.Id).ToArray());
            if (System.Math.Abs(1.0 - result - probabilityOfZero) > tol)
            {
                var extendedMsg = $"{msg}\n\tExpected:\t{probabilityOfZero}\n\tActual:\t{result}";
                IgnorableAssert.Assert(false, extendedMsg);
                throw new ExecutionFailException(extendedMsg);
            }
        }


        [DllImport(simulator_dll)]
        private static extern void allocateQubit_cpp(uint sim, int qubit_id);
        public override void OnAllocateQubits(IQArray<Qubit> qubits)
        {
            try
            {
                foreach (Qubit qubit in qubits)
                {
                    allocateQubit_cpp(Id, qubit.Id);
                }
            } catch (ExternalException ex)
            {
                // Possibly C++ errors: qubit already occupied, or not enough qubits
                throw ex;
            }
        }

        [DllImport(simulator_dll)]
        private static extern void releaseQubit_cpp(uint sim, int qubit_id);
        public override void OnReleaseQubits(IQArray<Qubit> qubits)
        {
            try
            {
                foreach (Qubit qubit in qubits)
                {
                    releaseQubit_cpp(Id, qubit.Id);
                }
            } catch (ExternalException)
            {
                // Possible C++ errors: Qubit not in zero state
                throw new Microsoft.Quantum.Simulation.Simulators.Exceptions.ReleasedQubitsAreNotInZeroState();
            }
        }

        // Tells C++ to delete any objects, to manage memory
        public void Dispose()
        {
            Dispose(true);
        }

        [DllImport(simulator_dll)]
        private static extern void destroy_cpp(uint sim);
        public void Dispose(bool Disposing)
        {
            destroy_cpp(Id);
        }

        public override void OnOperationStart(ICallable operation, IApplyData arguments)
        {
            // Writes the operation to console if it is logging
            if (isLogging)
            {
                Console.WriteLine(stackDepth + operation.FullName + "{");
                stackDepth += " ";
            }
        }

        public override void OnOperationEnd(ICallable operation, IApplyData arguments)
        {
            
            if (isLogging)
            {
                stackDepth = stackDepth[0..(stackDepth.Length - 1)];
                Console.WriteLine(stackDepth + "}");
            }
        }

        
    }
}
