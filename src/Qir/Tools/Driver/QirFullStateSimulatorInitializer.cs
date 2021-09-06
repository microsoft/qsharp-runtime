// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public class QirFullStateSimulatorInitializer : IQirRuntimeInitializer
    {
        private readonly bool debug;

        internal QirFullStateSimulatorInitializer(bool debug) => this.debug = debug;

        public string Generate() => new QirCppFullStateSimulatorInitializer(this.debug).TransformText();

        public IEnumerable<string> Headers => new [] {
                "SimFactory.hpp"
            };

        public IEnumerable<string> LinkLibraries => new string[0];
    }
}
