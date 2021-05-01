// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public class QirFullStateSimulatorInitializer : IQirSimulatorInitializer
    {
        public string Generate() => new QirCppFullStateSimulatorInitializer().TransformText();

        public IList<string> Headers => new List<string> {
                "SimFactory.hpp"
            };

        public IList<string> LinkLibraries => new List<string>();
    }
}
