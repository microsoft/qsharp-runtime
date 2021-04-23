// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public interface IQirSimulatorInitializer
    {
        public void GenerateSimulatorInitialization(Stream stream);

        public IList<string> Headers { get; }

        public IList<string> LinkLibraries { get; }
    }
}
