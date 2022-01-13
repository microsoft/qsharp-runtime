// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Intrinsic.Interfaces;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator : CommonNativeSimulator
    {
        /// <summary>
        /// Creates a an instance of a quantum simulator.
        /// </summary>
        /// <param name="throwOnReleasingQubitsNotInZeroState"> If set to true, the exception is thrown when trying to release qubits not in zero state. </param>
        /// <param name="randomNumberGeneratorSeed"> Seed for the random number generator used by a simulator for measurement outcomes and the Random operation. </param>
        /// <param name="disableBorrowing"> If true, Borrowing qubits will be disabled, and a new qubit will be allocated instead every time borrowing is requested. Performance may improve. </param>
        public QuantumSimulator(
            bool throwOnReleasingQubitsNotInZeroState = true,
            UInt32? randomNumberGeneratorSeed = null,
            bool disableBorrowing = false)
        : base(throwOnReleasingQubitsNotInZeroState,
               randomNumberGeneratorSeed,
               disableBorrowing)
        {
            if (!RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                // We don't need this value, but explicitly calling an OMP function should trigger the load of libomp
                // by .NET from the runtimes folder for the current platform, such that the later library load by the
                // simulator does not need to know where to search for it.
                var threadCount = OmpGetNumberOfThreadsNative();
            }

            Id = InitNative();
            // Make sure that the same seed used by the built-in System.Random
            // instance is also used by the native simulator itself.
            SetSeedNative(this.Id, (uint)this.Seed);
        }

        public override void Dispose()
        {
            DestroyNative(this.Id);
        }

        public override string Name
        {
            get
            {
                return "Quantum Simulator"; // There is a test case that expects exactly this string literal.
            }
        }
    }
}
