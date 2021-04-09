// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Qir
{
    /// <summary>
    /// Exception that represents an error that can be written to an error file.
    /// </summary>
    public class ControllerException : Exception
    {
        public ControllerException(string message, string code)
        : base(message)
        {
            Code = code;
        }

        public string Code { get; }
    }
}
