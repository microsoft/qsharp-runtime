// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public class QirFullStateSimulatorInitializer : IQirRuntimeInitializer
    {
        internal QirFullStateSimulatorInitializer() {}

        public string Generate() => "";

        public IEnumerable<string> Headers => new string[0];

        public IEnumerable<string> LinkLibraries => new string[0];
    }
}
