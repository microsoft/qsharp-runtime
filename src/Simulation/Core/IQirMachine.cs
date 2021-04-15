// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Core = Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    /// <summary>
    /// A machine that can execute QIR programs on Azure.
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
    /// The type of an argument to a QIR callable.
    /// </summary>
    public class ArgumentType
    {
        private ArgumentType()
        {
        }

        /// <summary>
        /// The boolean type.
        /// </summary>
        public static ArgumentType Bool { get; } = new ArgumentType();

        /// <summary>
        /// The integer type.
        /// </summary>
        public static ArgumentType Int { get; } = new ArgumentType();

        /// <summary>
        /// The double-precision floating point type.
        /// </summary>
        public static ArgumentType Double { get; } = new ArgumentType();

        /// <summary>
        /// The Pauli operator type.
        /// </summary>
        public static ArgumentType Pauli { get; } = new ArgumentType();

        /// <summary>
        /// The range type.
        /// </summary>
        public static ArgumentType Range { get; } = new ArgumentType();

        /// <summary>
        /// The result type.
        /// </summary>
        public static ArgumentType Result { get; } = new ArgumentType();

        /// <summary>
        /// The string type.
        /// </summary>
        public static ArgumentType String { get; } = new ArgumentType();

        /// <summary>
        /// The array type.
        /// </summary>
        public class Array : ArgumentType
        {
            /// <summary>
            /// The type of the array items.
            /// </summary>
            public ArgumentType Item { get; }

            /// <summary>
            /// Creates a new array type.
            /// </summary>
            /// <param name="item">The type of the array items.</param>
            public Array(ArgumentType item) => this.Item = item;

            public override bool Equals(object obj) => obj is Array array && this.Item.Equals(array.Item);

            public override int GetHashCode() => HashCode.Combine(1, this.Item.GetHashCode());
        }

        public override bool Equals(object obj) => ReferenceEquals(this, obj);

        public override int GetHashCode() => RuntimeHelpers.GetHashCode(this);

        public static bool operator ==(ArgumentType lhs, ArgumentType rhs) => lhs.Equals(rhs);

        public static bool operator !=(ArgumentType lhs, ArgumentType rhs) => !(lhs == rhs);
    }

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
            public IQArray<ArgumentValue> Values { get; }

            /// <summary>
            /// The type of the array items.
            /// </summary>
            public ArgumentType ItemType { get; }

            public override ArgumentType Type => new ArgumentType.Array(this.ItemType);

            private Array(IQArray<ArgumentValue> values, ArgumentType itemType) => 
                (this.Values, this.ItemType) = (values, itemType);

            /// <summary>
            /// Tries to create an array argument value.
            /// </summary>
            /// <param name="values">The values of the argument.</param>
            /// <param name="itemType">The type of the values.</param>
            /// <returns>The array or <c>null</c> if not all values have the type <paramref name="itemType"/>.</returns>
            public static Array? TryCreate(IQArray<ArgumentValue> values, ArgumentType itemType) =>
                values.All(value => value.Type == itemType) ? new Array(values, itemType) : null;
        }
    }
}
