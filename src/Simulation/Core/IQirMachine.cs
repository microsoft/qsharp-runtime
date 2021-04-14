// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Core = Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// A machine that can submit QIR programs to Azure.
    /// </summary>
    public interface IQirMachine : IAzureMachine
    {
        /// <summary>
        /// Submits a job to execute a QIR program without waiting for execution to complete.
        /// </summary>
        /// <param name="qir">The QIR program as a byte stream.</param>
        /// <param name="entryPoint">The fully-qualified name of the entry point to execute.</param>
        /// <param name="arguments">The arguments to the entry point in the order in which they are declared.</param>
        /// <returns>The submitted job.</returns>
        Task<IQuantumMachineJob> SubmitAsync(Stream qir, string entryPoint, IReadOnlyList<Argument> arguments);
    }

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

    /// <summary>
    /// The value of an argument to a QIR callable is a discriminated union of the argument types.
    /// </summary>
    public abstract class ArgumentValue
    {
        private ArgumentValue()
        {
        }

        /// <summary>
        /// A boolean argument value.
        /// </summary>
        public class Bool : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public bool Value { get; }

            /// <summary>
            /// Creates a boolean argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Bool(bool value) => this.Value = value;
        }

        /// <summary>
        /// An integer argument value.
        /// </summary>
        public class Int : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public long Value { get; }

            /// <summary>
            /// Creates an integer argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Int(long value) => this.Value = value;
        }

        /// <summary>
        /// A double-precision floating point argument value.
        /// </summary>
        public class Double : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public double Value { get; }

            /// <summary>
            /// Creates a double-precision floating point argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Double(double value) => this.Value = value;
        }

        /// <summary>
        /// A Pauli operator argument value.
        /// </summary>
        public class Pauli : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public Core.Pauli Value { get; }

            /// <summary>
            /// Creates a Pauli operator argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Pauli(Core.Pauli value) => this.Value = value;
        }

        /// <summary>
        /// A range argument value.
        /// </summary>
        public class Range : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public QRange Value { get; }

            /// <summary>
            /// Creates a range argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Range(QRange value) => this.Value = value;
        }

        /// <summary>
        /// A result argument value.
        /// </summary>
        public class Result : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public Core.Result Value { get; }

            /// <summary>
            /// Creates a result argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public Result(Core.Result value) => this.Value = value;
        }

        /// <summary>
        /// A string argument value.
        /// </summary>
        public class String : ArgumentValue
        {
            /// <summary>
            /// The value of the argument.
            /// </summary>
            public string Value { get; }

            /// <summary>
            /// Creates a string argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public String(string value) => this.Value = value;
        }

        /// <summary>
        /// An array argument value.
        /// </summary>
        public class Array : ArgumentValue
        {
            /// <summary>
            /// The values of the argument.
            /// </summary>
            public IQArray<ArgumentValue> Values { get; }

            /// <summary>
            /// Creates an array argument value.
            /// </summary>
            /// <param name="values">The values of the argument.</param>
            public Array(IQArray<ArgumentValue> values) => this.Values = values;
        }
    }
}
