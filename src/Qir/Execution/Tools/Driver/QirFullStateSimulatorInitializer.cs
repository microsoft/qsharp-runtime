// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public class QirFullStateSimulatorInitializer : IQirRuntimeInitializer
    {
        public string Generate() => new QirCppFullStateSimulatorInitializer().TransformText();

        public IEnumerable<string> Headers => new [] {
                "SimFactory.hpp"
            };

        public IEnumerable<string> LinkLibraries => new string[0];
    }
}
