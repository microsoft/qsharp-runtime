using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition
{
    public static class DecompositionUtils
    {
        public delegate void Op(Qubit qubit);
        public delegate void SinglyControlledOp(Qubit control, Qubit qubit);
        public delegate void ControlledOp(IQArray<Qubit> controls, Qubit qubit);

        public static (long, long) ReduceDyadicFractionPeriodic(long numerator, long denominatorPowerOfTwo)
        {
            (long k, long n) = ReducedDyadicFraction(numerator, denominatorPowerOfTwo); // k is odd, or (k,n) are both 0

            //period = 2*2^n
            long period = 2;
            for (long i = 0; i < n; i++)
            { period *= 2; }
            for (long i = 0; i > n; i--)
            { period /= 2; }

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
                denominatorPowerOfTwo--;
            }
            return (numerator, denominatorPowerOfTwo);
        }
    }
}
