// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Newtonsoft.Json;

/// <summary>
/// The types used to represent Q# type in the generated C# code.
/// </summary>
namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents the Result of a Measurement. Corresponds to Q# type <code>Result</code>.
    /// </summary>
    [Serializable]
    public enum ResultValue
    {
        /// <summary>
        /// Corresponds to measuring +1 eigenstate of an observable or 
        /// measuring |0⟩ in computational basis.
        /// Represents Q# <code>Zero</code> constant.
        /// </summary>
        Zero,
        /// <summary>
        /// Corresponds to measuring -1 eigenstate of an observable or 
        /// measuring |1⟩ in computational basis.
        /// Represents Q# <code>One</code> constant.
        /// </summary>
        One
    }

    /// <summary>
    /// Represents the Result of a Measurement when value is known at the construction time. 
    /// Corresponds to Q# type <code>Result</code>.
    /// </summary>
    [Serializable]
    public class ResultConst : Result
    {
        private ResultValue Value;

        public ResultConst(ResultValue value)
        {
            Value = value;
        }

        public override ResultValue GetValue()
        {
            return Value;
        }
    }

    /// <summary>
    /// Represents the Result of a Measurement. Corresponds to Q# type <code>Result</code>.
    /// </summary>
    [Serializable]
    [JsonConverter(typeof(ResultConverter))]
    public abstract class Result : IEquatable<Result>
    {
        /// <summary>
        /// Returns the actual value of the result.
        /// Can be overridden to allow implementaiton of delayed result 
        /// retrieval or controlled access to the usage of the result.
        /// </summary>
        public abstract ResultValue GetValue();

        /// <summary>
        /// Corresponds to measuring +1 eigenstate of an observable or 
        /// measuring |0⟩ in computational basis.
        /// Represents Q# <code>Zero</code> constant.
        /// </summary>
        public static Result Zero = new ResultConst(ResultValue.Zero);
        /// <summary>
        /// Corresponds to measuring -1 eigenstate of an observable or 
        /// measuring |1⟩ in computational basis.
        /// Represents Q# <code>One</code> constant.
        /// </summary>
        public static Result One = new ResultConst(ResultValue.One);

        public override string ToString()
        {
            return GetValue().ToString();
        }

        public override bool Equals(object obj)
        {
            return this.Equals(obj as Result);
        }

        public bool Equals(Result p)
        {
            if (Object.ReferenceEquals(p, null))
            {
                return false; // Returning false is required for null
            }

            // Optimization for the case when references are equal.
            if (Object.ReferenceEquals(this, p))
            {
                return true;
            }

            return (GetValue() == p.GetValue());
        }

        public static bool operator ==(Result lhs, Result rhs)
        {
            if (Object.ReferenceEquals(lhs, null)) // Left side is null
            {
                if (Object.ReferenceEquals(rhs, null))
                {
                    return true; // null == null.
                }

                return false; // The left side is null, but the right side is not.
            }
            return lhs.Equals(rhs);
        }

        public static bool operator !=(Result lhs, Result rhs)
        {
            return !(lhs == rhs);
        }

        public override int GetHashCode()
        {
            return GetValue().GetHashCode();
        }
    }

    /// <summary>
    /// Represents single-qubit Pauli operator.
    /// Corresponds to Q# type <code>Pauli</code>.
    /// </summary>
    [Serializable]
    public enum Pauli
    {
        /// <summary>
        /// Pauli Identity operator. Corresponds to Q# constant <code>PauliI</code>.
        /// </summary>
        PauliI = 0,
        /// <summary>
        /// Pauli X operator. Corresponds to Q# constant <code>PauliX</code>.
        /// </summary>
        PauliX = 1,
        /// <summary>
        /// Pauli Y operator. Corresponds to Q# constant <code>PauliY</code>.
        /// </summary>
        PauliY = 3,
        /// <summary>
        /// Pauli Z operator. Corresponds to Q# constant <code>PauliZ</code>.
        /// </summary>
        PauliZ = 2
    }

    /// <summary>
    /// Exception thrown when the "fail" statement is reached in a Q# file.
    /// </summary>
    public class ExecutionFailException : Exception
    {
        /// <summary>
        /// Creates an instance of <see cref="ExecutionFailException"/>.
        /// </summary>
        /// <param name="message">String that is a part of  Q# fail statement</param>
        public ExecutionFailException(string message) : base(message) { }
    }

    /// <summary>
    /// This class is used to serialize Result instances using the default values.
    /// </summary>
    public class ResultConverter : JsonConverter<Result>
    {
        public override Result ReadJson(JsonReader reader, Type objectType, Result existingValue, bool hasExistingValue, JsonSerializer serializer) =>
            (serializer.Deserialize<int>(reader) == 1)
                ? Result.One
                : Result.Zero;

        public override void WriteJson(JsonWriter writer, Result value, JsonSerializer serializer)
        {
            // See https://github.com/JamesNK/Newtonsoft.Json/issues/386#issuecomment-421161191
            // for why this works to pass through.
            var token = Newtonsoft.Json.Linq.JToken.FromObject(value.GetValue(), serializer);
            token.WriteTo(writer);
        }
    }
}
