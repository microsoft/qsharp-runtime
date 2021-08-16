// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Qir.Serialization;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public partial class QirCppDriver
    {
        public readonly EntryPointOperation EntryPoint;

        public readonly IQirRuntimeInitializer RuntimeInitializer;

        public QirCppDriver(EntryPointOperation entryPoint, IQirRuntimeInitializer runtimeInitializer)
        {
            EntryPoint = entryPoint;
            RuntimeInitializer = runtimeInitializer;
        }
    }
}
