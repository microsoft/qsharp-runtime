// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator
    {
        public class QSimrandom : Quantum.Intrinsic.Random
        {
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "random_choice")]
            private static extern Int64 random_choice(uint id, Int64 size, double[] p);

            private uint SimulatorId { get; }


            public QSimrandom(QuantumSimulator m) : base(m)
            {
                this.SimulatorId = m.Id;
            }

            public override Func<IQArray<double>, Int64> Body => (p) =>
            {
                return random_choice(this.SimulatorId, p.Length, p.ToArray());
            };            
        }
    }
}
