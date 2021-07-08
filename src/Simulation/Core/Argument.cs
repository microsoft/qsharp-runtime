// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// An argument to a QIR callable.
    /// </summary>
    public class Argument
    {
        /// <summary>
        /// The name of the argument.
        /// </summary>
        public string Name { get; }

        /// <summary>
        /// The value of the argument.
        /// </summary>
        public ArgumentValue Value { get; }

        /// <summary>
        /// Creates a new argument.
        /// </summary>
        /// <param name="name">The name of the argument.</param>
        /// <param name="value">The value of the argument.</param>
        public Argument(string name, ArgumentValue value) => (this.Name, this.Value) = (name, value);
    }
}
