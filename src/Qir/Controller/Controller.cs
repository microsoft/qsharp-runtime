// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;

namespace Microsoft.Quantum.Qir
{
    internal static class Controller
    {
        internal static void Execute(
            FileInfo input,
            FileInfo output,
            FileInfo error)
        {
            Console.WriteLine(input.FullName);
            Console.WriteLine(output.FullName);
            Console.WriteLine(error.FullName);
        }
    }
}
