// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Microsoft.Quantum.Qir.Driver
{
    public interface IQirSourceFileGenerator
    {
        /// <summary>
        /// Generates the C++ driver source file and writes the bytecode to a file.
        /// </summary>
        /// <param name="sourceDirectory">Directory to which driver and bytecode will be written.</param>
        /// <param name="entryPointOperation">Entry point information.</param>
        /// <param name="bytecode">The QIR bytecode.</param>
        /// <returns></returns>
        Task GenerateQirSourceFilesAsync(DirectoryInfo sourceDirectory, EntryPointOperation entryPointOperation, ArraySegment<byte> bytecode);
    }
}
