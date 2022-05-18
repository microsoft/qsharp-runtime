// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Intrinsic.Interfaces;
using Newtonsoft.Json.Linq;

using ExpIntrin = Microsoft.Quantum.Simulation.Simulators.IntrinsicInterface;

namespace Microsoft.Quantum.Simulation.Simulators;

// NB: This class should not implement IQSharpCore, but does so temporarily
//     to make the simulator available to IQ# (note that the I in IQSharpCore
//     refers to interfaces, and not to IQ# itself...)
public partial class OpenSystemsSimulator : SimulatorBase, IQSharpCore, IDisposable
{
    public static JToken BuildInfo => OpenSystemsSimulatorNativeInterface.SimulatorInfo;

    private readonly ulong Id;

    public override string Name => OpenSystemsSimulatorNativeInterface.Name;

    public NoiseModel NoiseModel
    {
        get
        {
            return OpenSystemsSimulatorNativeInterface.GetNoiseModel(Id);
        }

        set
        {
            OpenSystemsSimulatorNativeInterface.SetNoiseModel(Id, value);
        }
    }

    public State CurrentState => OpenSystemsSimulatorNativeInterface.GetCurrentState(this.Id);

    public OpenSystemsSimulator(uint capacity = 4, string representation = "mixed") : base(new QubitManager((long)capacity))
    {
        this.Id = OpenSystemsSimulatorNativeInterface.Init(capacity, representation);
    }

    Result IIntrinsicMeasure.Body(IQArray<Pauli> paulis, IQArray<Qubit> targets) =>
        Get<ExpIntrin.Measure, ExpIntrin.Measure>().__Body__((paulis, targets));

    void IIntrinsicH.Body(Qubit target)
    {
        Get<ExpIntrin.H, ExpIntrin.H>().__Body__(target);
    }

    void IIntrinsicH.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.H, ExpIntrin.H>().__ControlledBody__((controls, target));
    }

    void IIntrinsicS.Body(Qubit target)
    {
        Get<ExpIntrin.S, ExpIntrin.S>().__Body__(target);
    }

    void IIntrinsicS.AdjointBody(Qubit target)
    {
        Get<ExpIntrin.S, ExpIntrin.S>().__AdjointBody__(target);
    }

    void IIntrinsicS.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.S, ExpIntrin.S>().__ControlledBody__((controls, target));
    }

    void IIntrinsicS.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.S, ExpIntrin.S>().__ControlledAdjointBody__((controls, target));
    }

    void IIntrinsicT.Body(Qubit target)
    {
        Get<ExpIntrin.T, ExpIntrin.T>().__Body__(target);
    }

    void IIntrinsicT.AdjointBody(Qubit target)
    {
        Get<ExpIntrin.T, ExpIntrin.T>().__AdjointBody__(target);
    }

    void IIntrinsicT.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.T, ExpIntrin.T>().__ControlledBody__((controls, target));
    }

    void IIntrinsicT.ControlledAdjointBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.T, ExpIntrin.T>().__ControlledAdjointBody__((controls, target));
    }

    void IIntrinsicX.Body(Qubit target)
    {
        Get<ExpIntrin.X, ExpIntrin.X>().__Body__(target);
    }

    void IIntrinsicX.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.X, ExpIntrin.X>().__ControlledBody__((controls, target));
    }

    void IIntrinsicY.Body(Qubit target)
    {
        Get<ExpIntrin.Y, ExpIntrin.Y>().__Body__(target);
    }

    void IIntrinsicY.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.Y, ExpIntrin.Y>().__ControlledBody__((controls, target));
    }

    void IIntrinsicZ.Body(Qubit target)
    {
        Get<ExpIntrin.Z, ExpIntrin.Z>().__Body__(target);
    }

    void IIntrinsicZ.ControlledBody(IQArray<Qubit> controls, Qubit target)
    {
        Get<ExpIntrin.Z, ExpIntrin.Z>().__ControlledBody__((controls, target));
    }

    void IDisposable.Dispose()
    {
        OpenSystemsSimulatorNativeInterface.Destroy(this.Id);
    }

}
