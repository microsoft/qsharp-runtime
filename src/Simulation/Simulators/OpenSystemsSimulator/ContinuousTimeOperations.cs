// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Intrinsic.Interfaces;
using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json.Linq;

using ExpIntrin = Microsoft.Quantum.Experimental.Intrinsic;

namespace Microsoft.Quantum.Experimental;
public partial class OpenSystemsSimulator
{
    // These gates are not yet supported, pending a design for how to extend
    // noise models to continuous-time gates (that is, those parameterized
    // by real numbers, such as angles).

    void IIntrinsicExp.Body(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        throw new NotImplementedException();
    }

    void IIntrinsicExp.AdjointBody(IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        throw new NotImplementedException();
    }

    void IIntrinsicExp.ControlledBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        throw new NotImplementedException();
    }

    void IIntrinsicExp.ControlledAdjointBody(IQArray<Qubit> controls, IQArray<Pauli> paulis, double angle, IQArray<Qubit> targets)
    {
        throw new NotImplementedException();
    }
    void IIntrinsicR.Body(Pauli pauli, double angle, Qubit target)
    {
        Get<ExpIntrin.R, ExpIntrin.R>().__Body__((pauli, angle, target));
    }

    void IIntrinsicR.AdjointBody(Pauli pauli, double angle, Qubit target)
    {
        (this as IIntrinsicR).Body(pauli, -angle, target);
    }

    void IIntrinsicR.ControlledBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
    {
        Get<ExpIntrin.R, ExpIntrin.R>().__ControlledBody__((controls, (pauli, angle, target)));
    }

    void IIntrinsicR.ControlledAdjointBody(IQArray<Qubit> controls, Pauli pauli, double angle, Qubit target)
    {
        (this as IIntrinsicR).ControlledBody(controls, pauli, -angle, target);
    }

}
