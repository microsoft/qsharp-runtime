using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;

namespace NewTracer.GateDecomposition
{
    public static class DecompositionUtils
    {
        public delegate void Op(Qubit qubit);
        public delegate void SinglyControlledOp(Qubit control, Qubit qubit);
        public delegate void ControlledOp(IQArray<Qubit> controls, Qubit qubit);

        public static (long, long) ReduceDyadicFractionPeriodic(long numerator, long denominatorPowerOfTwo)
        {
            (long k, long n) = ReducedDyadicFraction(numerator, denominatorPowerOfTwo); // k is odd, or (k,n) are both 0

            long period = 2;
            for (long i = 0; i < denominatorPowerOfTwo; i++)
            { period *= 2; }

            long kMod = k % period;
            long kModPositive = kMod >= 0 ? kMod : kMod + period;
            return (kModPositive, n);
        }

        public static (long, long) ReducedDyadicFraction(long numerator, long denominatorPowerOfTwo)
        {
            if (numerator == 0) { return (0, 0); }
            while (numerator % 2 == 0)
            {
                numerator /= 2;
                denominatorPowerOfTwo++;
            }
            return (numerator, denominatorPowerOfTwo);
        }

        public static void RemoveIdentities(IQArray<Pauli> paulis, IQArray<Qubit> qubits,
            out IList<Pauli> newPaulis, out IList<Qubit> newQubits)
        {
            if (paulis.Length != qubits.Length)
            { throw new Exception("Arrays must be the same length."); }

            newPaulis = new List<Pauli>(paulis.Count);
            newQubits = new List<Qubit>(qubits.Count);

            for (int i = 0; i < paulis.Length; i++)
            {
                if (paulis[i] != Pauli.PauliI)
                {
                    newPaulis.Add(paulis[i]);
                    newQubits.Add(qubits[i]);
                }
            }
        }
    }
}
