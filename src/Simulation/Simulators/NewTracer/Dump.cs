// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.NewTracer
{
    //Dump error logic copied from old tracer
    public partial class TracerSimulator
    {
        public class TracerDumpMachine<T> : Diagnostics.DumpMachine<T>
        {
            private readonly SimulatorBase Sim;
            public TracerDumpMachine(SimulatorBase sim) : base(sim)
            {
                Sim = sim;
            }

            public override Func<T, QVoid> Body => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                //this.Sim.QuantumProcessor.OnDumpMachine(location); //TODO: is this necessary?

                var filename = (location is QVoid) ? "" : location.ToString();
                var msg = "QCTraceSimulator doesn't support state dump.";

                var logMessage = this.Factory.Get<ICallable<string, QVoid>, Intrinsic.Message>();

                if (string.IsNullOrEmpty(filename))
                {
                    logMessage.Apply(msg);
                }
                else
                {
                    try
                    {
                        File.WriteAllText(filename, msg);
                    }
                    catch (Exception e)
                    {
                        logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                        return QVoid.Instance;
                    }
                }
                return QVoid.Instance;
            };
        }

        public class TracerDumpRegister<T> : Diagnostics.DumpRegister<T>
        {
            private readonly SimulatorBase Sim;
            public TracerDumpRegister(SimulatorBase sim) : base(sim)
            {
                Sim = sim;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> Body => (__in) =>
            {
                var (location, qubits) = __in;
                if (location == null) { throw new ArgumentNullException(nameof(location)); }

                //this.Sim.QuantumProcessor.OnDumpRegister<T>(location, qubits);

                var filename = (location is QVoid) ? "" : location.ToString();
                var msg = "QCTraceSimulator doesn't support state dump.";

                var logMessage = this.Factory.Get<ICallable<string, QVoid>, Intrinsic.Message>();

                if (string.IsNullOrEmpty(filename))
                {
                    logMessage.Apply(msg);
                }
                else
                {
                    try
                    {
                        File.WriteAllText(filename, msg);
                    }
                    catch (Exception e)
                    {
                        logMessage.Apply($"[warning] Unable to write state to '{filename}' ({e.Message})");
                        return QVoid.Instance;
                    }
                }
                return QVoid.Instance;
            };
        }
    }
}
