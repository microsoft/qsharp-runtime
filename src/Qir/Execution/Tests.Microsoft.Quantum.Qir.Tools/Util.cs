// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Reflection;
using Microsoft.Quantum.QsCompiler.BondSchemas.EntryPoint;

namespace Tests.Microsoft.Quantum.Qir.Tools
{
    public static class Util
    {
        public static void DeleteDirectory(DirectoryInfo directory)
        {
            foreach (var file in directory.GetFiles())
            {
                file.Delete();
            }
            directory.Delete();
        }


        public static bool EntryPointsAreEqual(EntryPointOperation entryPointA, EntryPointOperation entryPointB)
        {
            var method = typeof(Extensions)
                .GetMethod("ValueEquals", BindingFlags.Static | BindingFlags.NonPublic, null, new[] { typeof(EntryPointOperation), typeof(EntryPointOperation) }, null);
            object[] parameters = { entryPointA, entryPointB };
            return (bool)method.Invoke(null, parameters);
        }
    }
}
