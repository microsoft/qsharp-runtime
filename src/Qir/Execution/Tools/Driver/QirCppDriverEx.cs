// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Qir.Serialization;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public partial class QirCppDriver
    {
        public readonly EntryPointOperation EntryPoint;

        public readonly IQirSimulatorInitializer SimulatorInitializer;

        public QirCppDriver(EntryPointOperation entryPoint, IQirSimulatorInitializer simulatorInitializer)
        {
            EntryPoint = entryPoint;
            SimulatorInitializer = simulatorInitializer;
        }
    }
}
