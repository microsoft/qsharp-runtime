// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Runtime.Tools.Driver
{
    public interface IQirRuntimeInitializer
    {
        public string Generate();

        public IEnumerable<string> Headers { get; }

        public IEnumerable<string> LinkLibraries { get; }
    }
}
