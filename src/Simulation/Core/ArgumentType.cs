// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

namespace Microsoft.Quantum.Runtime
{
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

            public override int GetHashCode() => this.Item.GetHashCode() + 1;
        }
    }
}
