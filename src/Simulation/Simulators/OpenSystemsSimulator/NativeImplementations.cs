// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Experimental;
public partial class OpenSystemsSimulator : SimulatorBase
{
    internal class H : Native.H
    {
        public H(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.H((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class X : Native.X
    {
        public X(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.X((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class Y : Native.Y
    {
        public Y(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.Y((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class Z : Native.Z
    {
        public Z(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.Z((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class S : Native.S
    {
        public S(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.S((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };

        public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
        {
            NativeInterface.SAdj((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class T : Native.T
    {
        public T(IOperationFactory m) : base(m) { }

        public override Func<Qubit, QVoid> __Body__ => (target) =>
        {
            NativeInterface.T((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };

        public override Func<Qubit, QVoid> __AdjointBody__ => (target) =>
        {
            NativeInterface.TAdj((this.__Factory__ as OpenSystemsSimulator).Id, target);
            return QVoid.Instance;
        };
    }

    internal class CNOT : Native.CNOT
    {
        public CNOT(IOperationFactory m) : base(m) { }

        public override Func<(Qubit, Qubit), QVoid> __Body__ => (args) =>
        {
            NativeInterface.CNOT((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Rx : Native.Rx
    {
        public Rx(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            NativeInterface.Rx((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Ry : Native.Ry
    {
        public Ry(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            NativeInterface.Ry((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class Rz : Native.Rz
    {
        public Rz(IOperationFactory m) : base(m) { }

        public override Func<(double, Qubit), QVoid> __Body__ => (args) =>
        {
            NativeInterface.Rz((this.__Factory__ as OpenSystemsSimulator).Id, args.Item1, args.Item2);
            return QVoid.Instance;
        };
    }

    internal class M : Native.M
    {
        public M(IOperationFactory m) : base(m) { }

        public override Func<Qubit, Result> __Body__ => (target) =>
            NativeInterface.M((this.__Factory__ as OpenSystemsSimulator).Id, target);
    }

}

