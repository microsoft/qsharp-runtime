// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Runtime.Submitters
{
    /// <summary>
    /// Options for a job submitted to Azure Quantum.
    /// </summary>
    public class EntryPointArgument
    {
        public string Name { get; }

        public Type Type { get; }

        public object Value { get; }

        public EntryPointArgument(string name, Type type, object value) => (Name, Type, Value) = (name, type, value);
    }
}
