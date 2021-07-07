// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools.Driver
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
