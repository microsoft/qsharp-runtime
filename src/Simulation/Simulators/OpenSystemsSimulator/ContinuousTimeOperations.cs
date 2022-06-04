// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

using IntrinsicInterface = Microsoft.Quantum.Simulation.Simulators.IntrinsicInterface;

namespace Microsoft.Quantum.Simulation.Simulators;

public partial class OpenSystemsSimulator
{
    // These gates are not yet supported, pending a design for how to extend
    // noise models to continuous-time gates (that is, those parameterized
    // by real numbers, such as angles).

    void IIntrinsicExp.Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        Get<IntrinsicInterface.Exp, IntrinsicInterface.Exp>().__Body__((paulis, angle, targets));
    }

    void IIntrinsicExp.AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        Get<IntrinsicInterface.Exp, IntrinsicInterface.Exp>().__Body__((paulis, -angle, targets));
    }

    void IIntrinsicExp.ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        Get<IntrinsicInterface.Exp, IntrinsicInterface.Exp>().__ControlledBody__((controls, (paulis, angle, targets)));
    }

    void IIntrinsicExp.ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        Get<IntrinsicInterface.Exp, IntrinsicInterface.Exp>().__ControlledBody__((controls, (paulis, -angle, targets)));
    }
    void IIntrinsicR.Body(Pauli pauli, double angle, Qubit target)
    {
        Get<IntrinsicInterface.R, IntrinsicInterface.R>().__Body__((pauli, angle, target));
    }

    void IIntrinsicR.AdjointBody(Pauli pauli, double angle, Qubit target)
    {
        (this as IIntrinsicR).Body(pauli, -angle, target);
    }

    void IIntrinsicR.ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
    {
        Get<IntrinsicInterface.R, IntrinsicInterface.R>().__ControlledBody__((controls, (pauli, angle, target)));
    }

    void IIntrinsicR.ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
    {
        (this as IIntrinsicR).ControlledBody(controls, pauli, -angle, target);
    }

}
