// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;

using Native = Microsoft.Quantum.Simulation.Simulators.NativeInterface;

namespace Microsoft.Quantum.Simulation.Simulators;

public partial class OpenSystemsSimulator : SimulatorBase
{
    internal class H : Native.H
    {
        public H(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.H((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class X : Native.X
    {
        public X(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.X((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class Y : Native.Y
    {
        public Y(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.Y((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class Z : Native.Z
    {
        public Z(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.Z((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class S : Native.S
    {
        public S(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.S((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };

        public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.SAdj((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class T : Native.T
    {
        public T(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.T((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };

        public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
        {
            OpenSystemsSimulatorNativeInterface.TAdj((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class CNOT : Native.CNOT
    {
        public CNOT(IOperationFactory m) : base(m) { }

        public override Func<(Qubit, Qubit), QVoid> __Body__ => (args) =>
        {
            OpenSystemsSimulatorNativeInterface.CNOT((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Rx : Native.Rx
    {
        public Rx(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            OpenSystemsSimulatorNativeInterface.Rx((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Ry : Native.Ry
    {
        public Ry(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            OpenSystemsSimulatorNativeInterface.Ry((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Rz : Native.Rz
    {
        public Rz(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            OpenSystemsSimulatorNativeInterface.Rz((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class M : Native.M
    {
        public M(IOperationFactory m) : base(m) { }

        public override Func<Qubit, Result> __Body__ => (target) =>
            OpenSystemsSimulatorNativeInterface.M((this.__Factory__ as OpenSystemsSimulator).Id, target);
    }

}

