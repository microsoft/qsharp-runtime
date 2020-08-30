// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    public partial class QCTraceSimulatorImpl
    {
        public class TracerDumpMachine<T> : Diagnostics.DumpMachine<T>
        {
            private readonly QCTraceSimulatorImpl core;
            public TracerDumpMachine(QCTraceSimulatorImpl m) : base(m)
            {
                core = m;
            }

            public override Func<T, QVoid> __Body__ => (location) =>
            {
                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                var filename = (location is QVoid) ? "" : location.ToString();
                var msg = "QCTraceSimulator doesn't support state dump.";

                var logMessage = this.__Factory__.Get<ICallable<string, QVoid>, Intrinsic.Message>();

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
            private readonly QCTraceSimulatorImpl core;
            public TracerDumpRegister(QCTraceSimulatorImpl m) : base(m)
            {
                core = m;
            }

            public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (__in) =>
            {
                var (location, qubits) = __in;

                if (location == null) { throw new ArgumentNullException(nameof(location)); }
                var filename = (location is QVoid) ? "" : location.ToString();
                var msg = "QCTraceSimulator doesn't support state dump.";

                var logMessage = this.__Factory__.Get<ICallable<string, QVoid>, Intrinsic.Message>();

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
