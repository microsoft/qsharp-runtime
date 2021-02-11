// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Runtime.CompilerServices;

#nullable enable

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// A class that implements exception to be thrown when Operation is not supported.
    /// </summary>
    public class UnsupportedOperationException : PlatformNotSupportedException
    {
        public UnsupportedOperationException(string text = "",
                            [CallerFilePath] string file = "",
                            [CallerMemberName] string member = "",
                            [CallerLineNumber] int line = 0)
            : base($"{file}::{line}::[{member}]:{text}")
        {
        }
    }

}