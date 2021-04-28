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
        public async Task GenerateAsync(Stream stream)
        {
            var simulatorInitializerSourceCode = this.GenerateString();
            await stream.WriteAsync(Encoding.UTF8.GetBytes(simulatorInitializerSourceCode));
            await stream.FlushAsync();
            stream.Position = 0;
        }
        public string GenerateString()
        {
            // TODO: Implement.
            return String.Empty;
        }

        public IList<string> Headers => new List<string> {
                "QirContext.hpp",
                "SimFactory.hpp"
            };

        public IList<string> LinkLibraries => new List<string>();
    }
}
