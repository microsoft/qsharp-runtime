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
        public IList<string> GenerateSourceCode()
        {
            var simulatorInitializer = new QirCppFullStateSimulatorInitializer();
            var sourceCode = simulatorInitializer.TransformText();
            var lines = sourceCode.Split(
                new[] { "\r\n", "\r", "\n" },
                StringSplitOptions.None);

            return new List<string>(lines);
        }

        public IList<string> Headers => new List<string> {
                "SimFactory.hpp"
            };

        public IList<string> LinkLibraries => new List<string>();
    }
}
