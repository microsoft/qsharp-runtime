// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public partial class QirCppDriver
    {
        private CppEntryPointOperation EntryPoint;
        private IQirSimulatorInitializer SimulatorInitializer;

        public QirCppDriver(EntryPointOperation entryPoint, IQirSimulatorInitializer simulatorInitializer)
        {
            EntryPoint = new CppEntryPointOperation(entryPoint);
            SimulatorInitializer = simulatorInitializer;
        }
    }
}
