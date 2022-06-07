// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators;

public partial class OpenSystemsSimulator
{

    public class OpenSystemsDumpMachine<T> : Quantum.Diagnostics.DumpMachine<T>
    {
        private OpenSystemsSimulator Simulator { get; }

        public OpenSystemsDumpMachine(OpenSystemsSimulator m) : base(m)
        {
            this.Simulator = m;
        }

        public override Func<T, QVoid> __Body__ => (location) =>
        {
            if (location == null) { throw new ArgumentNullException(nameof(location)); }
            Simulator.MaybeDisplayDiagnostic(Simulator.CurrentState);
            return QVoid.Instance;
        };
    }

    // TODO: implement this by adding a new PartialTrace trait to the
    //       Rust side, and then exposing it through the C API.
    //       Until we have that, there's not a sensible way to interpret
    //       states on subregisters in general.
    public class OpenSystemsDumpRegister<T> : Quantum.Diagnostics.DumpRegister<T>
    {
        private OpenSystemsSimulator Simulator { get; }

        public OpenSystemsDumpRegister(OpenSystemsSimulator m) : base(m)
        {
            this.Simulator = m;
        }

        public override Func<(T, IQArray<Qubit>), QVoid> __Body__ => (args) =>
        {
            var (location, register) = args;
            if (location == null) { throw new ArgumentNullException(nameof(location)); }
            this.Simulator.Get<Message, Message>().__Body__?.Invoke("DumpRegister not yet supported on OpenSystemsSimulator; skipping.");
            return QVoid.Instance;
        };
    }
}
