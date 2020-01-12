// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// Hide this code from the debugger since this is called from Q# directly:
#line hidden
#nullable enable
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    // Extension method to make it simpler to call an Operation.
    public static partial class Extensions
    {
        public static IEnumerable<T> WhereNotNull<T>(this IEnumerable<T?> source) where T: class =>
            source.Where(q => q != null).Select(q => q!);

        public static Result ToResult(this bool b)
        {
            return b
                ? Result.One
                : Result.Zero;
        }

        public static Result ToResult(this uint b)
        {
            Debug.Assert(b == 0 || b == 1, $"Unexpected result value: {b}");

            return b == 0
                ? Result.Zero
                : Result.One;
        }

        public static double Pow(this double x, double y)
        {
            return System.Math.Pow(x, y);
        }

        public static long Pow(this long x, long power)
        {
            if (power < 0)
            {
                throw new ArgumentOutOfRangeException($"Negative power {power} not supported for integer exponentiation.");
            }
            long returnValue = 1;
            while (power != 0)
            {
                // Check the lowest bit of the power.
                if ((power & 1) == 1)
                {
                    returnValue *= x;
                }

                x *= x;
                power >>= 1;
            }

            return returnValue;
        }

        public static System.Numerics.BigInteger Pow(this System.Numerics.BigInteger x, long power)
        {
            return System.Numerics.BigInteger.Pow(x, Convert.ToInt32(power)); // Throws if the power is too big or negative
        }

        public static OperationFunctor AdjointVariant(this ICallable op)
        {
            switch (op.Variant)
            {
                case OperationFunctor.Adjoint: return OperationFunctor.Body;
                case OperationFunctor.Controlled: return OperationFunctor.ControlledAdjoint;
                case OperationFunctor.ControlledAdjoint: return OperationFunctor.Controlled;
                default: return OperationFunctor.Adjoint;
            }
        }

        public static OperationFunctor ControlledVariant(this ICallable op)
        {
            switch (op.Variant)
            {
                case OperationFunctor.Adjoint: return OperationFunctor.ControlledAdjoint;
                case OperationFunctor.ControlledAdjoint: return OperationFunctor.ControlledAdjoint;
                case OperationFunctor.Controlled: return OperationFunctor.Controlled;
                default: return OperationFunctor.Controlled;
            }
        }
    }
}
