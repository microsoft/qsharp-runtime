// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Intrinsic.Interfaces;
using System.Collections.Generic;
using System.Diagnostics;

#nullable enable

namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.UInt32;

    public partial class SparseSimulator2 : CommonNativeSimulator
    {
        /// <summary>
        /// Creates a an instance of a sparse simulator.
        /// </summary>
        /// <param name="throwOnReleasingQubitsNotInZeroState"> If set to true, the exception is thrown when trying to release qubits not in zero state. </param>
        /// <param name="randomNumberGeneratorSeed"> Seed for the random number generator used by a simulator for measurement outcomes and the Random operation. </param>
        /// <param name="disableBorrowing"> If true, Borrowing qubits will be disabled, and a new qubit will be allocated instead every time borrowing is requested. Performance may improve. </param>
        /// <param name="numQubits"> Qubit capacity. </param>
        public SparseSimulator2(
            bool throwOnReleasingQubitsNotInZeroState = true,
            UInt32? randomNumberGeneratorSeed = null,
            bool disableBorrowing = false,
            uint numQubits = 64)
        : base(throwOnReleasingQubitsNotInZeroState,
               randomNumberGeneratorSeed,
               disableBorrowing)
        {
            Id = init_cpp((QubitIdType)numQubits);

            // Make sure that the same seed used by the built-in System.Random
            // instance is also used by the native simulator itself.
            seed_cpp(this.Id, (uint)this.Seed);
        }

        public override void Dispose()
        {
            destroy_cpp(this.Id);
        }

        public override string Name
        {
            get
            {
                return "SparseSimulator2";
            }
        }
    }
}
