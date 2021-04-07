// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Driver
{
    public interface IQirDriverGenerator
    {
        /// <summary>
        /// Generates the C++ driver source file to compile with the bytecode.
        /// </summary>
        /// <param name="entryPointOperation">Entry point information.</param>
        /// <param name="driverFile">The file to which the source will be written.</param>
        /// <returns></returns>
        Task GenerateQirDriverCppAsync(EntryPointOperation entryPointOperation, FileInfo driverFile);
    }
}
