﻿// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Qir.Serialization;
using Microsoft.Quantum.Qir.Tools.Executable;
using Microsoft.Quantum.QsCompiler;
using System;
using System.IO;
using System.Linq;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Qir.Tools
{
    /// <summary>
    /// Provides high-level utility methods to work with QIR.
    /// </summary>
    public static class QirTools
    {

        /// <summary>
        /// Creates a QIR-based executable from a .NET DLL generated by the Q# compiler.
        /// </summary>
        /// <param name="qsharpDll">.NET DLL generated by the Q# compiler.</param>
        /// <param name="libraryDirectory">Directory where the libraries to link to are located.</param>
        /// <param name="includeDirectory">Directory where the headers needed for compilation are located.</param>
        public static async Task BuildFromQSharpDll(FileInfo qsharpDll, DirectoryInfo libraryDirectory, DirectoryInfo includeDirectory)
        {
            if (!CompilationLoader.ReadBinary(qsharpDll.FullName, out var syntaxTree))
            {
                throw new ArgumentException("Unable to read the Q# syntax tree from the given DLL.");
            }

            using var qirContentStream = new MemoryStream();
            if (!AssemblyLoader.LoadQirByteCode(qsharpDll, qirContentStream))
            {
                throw new ArgumentException("The given DLL does not contain QIR byte code.");
            }

            var tasks = syntaxTree.EntryPoints.Select(entryPoint =>
            {
                var ep = new EntryPointOperation()
                {
                    Name = entryPoint.ToString()
                };
                var exeFileInfo = new FileInfo(entryPoint.ToString());
                var exe = new QirFullStateExecutable(exeFileInfo, qirContentStream.ToArray());
                return exe.BuildAsync(ep, libraryDirectory, includeDirectory);
            });

            await Task.WhenAll(tasks);
        }
    }
}
