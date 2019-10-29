using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Core;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Common
{
    public class CommonUtils
    {
        /// <summary>
        /// Removes PauliI terms from observable and corresponding qubits from qubits. 
        /// Returns the observable description that is equivalent to the original one, but has no PauliI terms
        /// </summary>
        public static void PruneObservable(IQArray<Pauli> observable, IQArray<Qubit> qubits, out QArray<Pauli> prunnedObservable, out QArray<Qubit> prunnedQubits)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);
            Debug.Assert(observable.Length == qubits.Length);
            prunnedObservable = new QArray<Pauli>(PrunnedSequence(observable, Pauli.PauliI, observable));
            prunnedQubits = new QArray<Qubit>(PrunnedSequence(observable, Pauli.PauliI, qubits));
        }

        /// <summary>
        /// Returns IEnumerable<T> that contains sub-sequence of <paramref name="sequenceToPrune"/>[i], such that <paramref name="sequence"/>[i] is not equal to <paramref name="value"/>.
        /// </summary>
        public static IEnumerable<T> PrunnedSequence<U,T>(IQArray<U> sequence, U value, IQArray<T> sequenceToPrune )
        {
            for (uint i = 0; i < sequence.Length; ++i)
            {
                if (!sequence[i].Equals(value))
                {
                    yield return sequenceToPrune[i];
                }
            }
        }

        /// <summary>
        /// Converts numbers of the form <paramref name="numerator"/>/2^<paramref name="denominatorPower"/> into canonical form where <paramref name="numerator"/> is odd or zero.
        /// If <paramref name="numerator"/> is zero, <paramref name="denominatorPower"/> must also be zero in the canonical form.
        /// </summary>
        public static (long, long) Reduce(long numerator, long denominatorPower)
        {
            if (numerator == 0)
            {
                return (0, 0);
            }

            if (numerator % 2 != 0)
            {
                return (numerator, denominatorPower);
            }

            long numNew = numerator;
            long denomPowerNew = denominatorPower;

            while (numNew % 2 == 0)
            {
                numNew /= 2;
                denomPowerNew -= 1;
            }

            return (numNew, denomPowerNew);
        }
    }
}
