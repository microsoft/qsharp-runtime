using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator : SimulatorBase, IDisposable
    {
        class QSimQubit : Qubit
        {
            [DebuggerBrowsable(DebuggerBrowsableState.Never)]
            private static Pauli[] PAULI_Z = new Pauli[] { Pauli.PauliZ };
        
            [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "JointEnsembleProbability")]
            private static extern double JointEnsembleProbability(uint id, uint n, Pauli[] b, uint[] q);

            public QSimQubit(int id, uint simulatorId) : base(id)
            {
                this.SimulatorId = simulatorId;
            }

            [DebuggerBrowsable(DebuggerBrowsableState.Never)]
            public uint SimulatorId { get; }

            public double Probability => JointEnsembleProbability(this.SimulatorId, 1, PAULI_Z, new uint[] { (uint)this.Id });
        }
    }
}
