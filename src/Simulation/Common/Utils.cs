// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Common
{
    public static class CommonUtils
    {
        /// <summary>
        /// Removes PauliI terms from observable and corresponding qubits from qubits. 
        /// Returns the observable description that is equivalent to the original one, but has no PauliI terms
        /// </summary>
        public static void PruneObservable(IQArray<Pauli> observable, IQArray<Qubit> qubits, out QArray<Pauli> prunedObservable, out QArray<Qubit> prunedQubits)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);
            Debug.Assert(observable.Length == qubits.Length);
            prunedObservable = new QArray<Pauli>(PrunedSequence(observable, Pauli.PauliI, observable));
            prunedQubits = new QArray<Qubit>(PrunedSequence(observable, Pauli.PauliI, qubits));
        }

        /// <summary>
        /// Returns IEnumerable&lt;T&gt; that contains sub-sequence of <paramref name="sequenceToPrune"/>[i], such that <paramref name="sequence"/>[i] is not equal to <paramref name="value"/>.
        /// </summary>
        public static IEnumerable<T> PrunedSequence<U,T>(IQArray<U> sequence, U value, IQArray<T> sequenceToPrune)
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

        /// <summary>
        /// Takes an array of doubles as
        /// input, and returns a randomly-selected index into the array 
        /// as an `Int`. The probability of selecting a specific index
        /// is proportional to the value of the array element at that index.
        /// Array elements that are equal to zero are ignored and their indices
        /// are never returned.If any array element is less than zero, or if
        /// no array element is greater than zero, then the operation fails.
        /// As a source of randomness uses a number uniformly distributed between 0 and 1. 
        /// Used for Quantum.Intrinsic.Random
        /// </summary>
        /// <param name="uniformZeroOneSample"> Number between Zero and one, uniformly distributed</param>
        public static long SampleDistribution(IQArray<double> unnormalizedDistribution, double uniformZeroOneSample)
        {
            if (unnormalizedDistribution.Any(prob => prob < 0.0))
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles.");
            }

            var total = unnormalizedDistribution.Sum();
            if (total == 0)
            {
                throw new ExecutionFailException("Random expects array of non-negative doubles with positive sum.");
            }

            var sample = uniformZeroOneSample * total;

            return unnormalizedDistribution
                // Get the unnormalized CDF of the distribution.
                .SelectAggregates((double acc, double x) => acc + x)
                // Look for the first index at which the CDF is bigger
                // than the random sample of 𝑈(0, 1) that we were given
                // as a parameter.
                .Select((cumulativeProb, idx) => (cumulativeProb, idx))
                .Where(item => item.cumulativeProb >= sample)
                // Cast that index to long, and default to returning
                // the last item.
                .Select(
                    item => (long)item.idx
                )
                .DefaultIfEmpty(
                    unnormalizedDistribution.Length - 1
                )
                .First();
        }

        internal static IEnumerable<TResult> SelectAggregates<TSource, TResult>(
            this IEnumerable<TSource> source,
            Func<TResult, TSource, TResult> aggregate,
            TResult initial = default
        )
        {
            var acc = initial;
            foreach (var element in source)
            {
                acc = aggregate(acc, element);
                yield return acc;
            }
        }

        public static IEnumerable<TResult> Extract<TSource, TResult>(this IEnumerable<TSource> source) 
            where TSource : class
            where TResult : TSource
        {
            return source?.Where(item => item is TResult)?.Cast<TResult>() ?? new TResult[] { };
        }
    }
}
