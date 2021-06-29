// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;

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
    }
}
