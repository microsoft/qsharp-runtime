// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Qir.Serialization;

namespace Microsoft.Quantum.Qir.Tools.Driver
{
    public interface IQirDriverGenerator
    {
        Task GenerateAsync(EntryPointOperation entryPoint, Stream stream);

        string GetCommandLineArguments(ExecutionInformation executionInformation);
    }
}
