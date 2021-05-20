// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.EntryPointDriver.Azure
{
    /// <summary>
    /// A Q# entry point submission.
    /// </summary>
    /// <typeparam name="TIn">The entry point argument type.</typeparam>
    /// <typeparam name="TOut">The entry point return type.</typeparam>
    public sealed class QSharpSubmission<TIn, TOut>
    {
        /// <summary>
        /// The entry point info.
        /// </summary>
        internal EntryPointInfo<TIn, TOut> EntryPointInfo { get; }

        /// <summary>
        /// The entry point argument.
        /// </summary>
        internal TIn Argument { get; }

        /// <summary>
        /// Creates a Q# entry point submission.
        /// </summary>
        /// <param name="entryPointInfo">The entry point info.</param>
        /// <param name="argument">The entry point argument.</param>
        public QSharpSubmission(EntryPointInfo<TIn, TOut> entryPointInfo, TIn argument) =>
            (this.EntryPointInfo, this.Argument) = (entryPointInfo, argument);
    }
}
