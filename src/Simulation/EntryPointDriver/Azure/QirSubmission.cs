// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Runtime;
using System;
using System.Collections.Immutable;
using System.IO;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// A QIR entry point submission.
    /// </summary>
    public sealed class QirSubmission
    {
        /// <summary>
        /// The QIR bitcode stream.
        /// </summary>
        internal Stream QirStream { get; }

        /// <summary>
        /// The entry point name.
        /// </summary>
        internal string EntryPointName { get; }

        /// <summary>
        /// The entry point arguments.
        /// </summary>
        internal ImmutableList<Argument> Arguments { get; }

        /// <summary>
        /// Creates a QIR entry point submission.
        /// </summary>
        /// <param name="qirStream">The QIR bitcode stream.</param>
        /// <param name="entryPointName">The entry point name.</param>
        /// <param name="arguments">The entry point arguments.</param>
        public QirSubmission(Stream qirStream, string entryPointName, ImmutableList<Argument> arguments) =>
            (this.QirStream, this.EntryPointName, this.Arguments) = (qirStream, entryPointName, arguments);
    }
}
