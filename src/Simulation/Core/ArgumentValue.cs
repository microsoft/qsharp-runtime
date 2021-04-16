// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Immutable;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Core = Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// The value of an argument to a QIR callable is a discriminated union of the argument types.
    /// </summary>
    public abstract class ArgumentValue
    {
        /// <summary>
        /// The type of the argument.
        /// </summary>
        public abstract ArgumentType Type { get; }

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

            public override ArgumentType Type => ArgumentType.Bool;

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

            public override ArgumentType Type => ArgumentType.Int;

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

            public override ArgumentType Type => ArgumentType.Double;

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

            public override ArgumentType Type => ArgumentType.Pauli;

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

            public override ArgumentType Type => ArgumentType.Range;

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

            public override ArgumentType Type => ArgumentType.Result;

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

            public override ArgumentType Type => ArgumentType.String;

            /// <summary>
            /// Creates a string argument value.
            /// </summary>
            /// <param name="value">The value of the argument.</param>
            public String(string value) => this.Value = value;
        }

        /// <summary>
        /// An array argument value where all values are of the same type.
        /// </summary>
        public class Array : ArgumentValue
        {
            /// <summary>
            /// The values of the argument.
            /// </summary>
            public ImmutableArray<ArgumentValue> Values { get; }

            public override ArgumentType Type { get; }

            private Array(ImmutableArray<ArgumentValue> values, ArgumentType itemType) =>
                (this.Values, this.Type) = (values, new ArgumentType.Array(itemType));

            /// <summary>
            /// Tries to create an array argument value.
            /// </summary>
            /// <param name="values">The values of the argument.</param>
            /// <param name="itemType">The type of the values.</param>
            /// <returns>The array or <c>null</c> if not all values have the type <paramref name="itemType"/>.</returns>
            public static Array? TryCreate(ImmutableArray<ArgumentValue> values, ArgumentType itemType) =>
                values.All(value => value.Type == itemType) ? new Array(values, itemType) : null;
        }
    }
}
