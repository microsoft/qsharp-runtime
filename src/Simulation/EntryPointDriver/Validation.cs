// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    /// <summary>
    /// Represents either a success or a failure of a process.
    /// </summary>
    /// <typeparam name="T">The type of the success value.</typeparam>
    internal struct Validation<T>
    {
        public bool IsSuccess { get; }
        public bool IsFailure { get => !IsSuccess; }
        public T Value { get => IsSuccess ? ValueOrDefault : throw new InvalidOperationException(); }
        public T ValueOrDefault { get; }
        public string ErrorMessage { get; }

        private Validation(bool isSuccess, T value, string errorMessage)
        {
            IsSuccess = isSuccess;
            ValueOrDefault = value;
            ErrorMessage = errorMessage;
        }

        public static Validation<T> Success(T value) =>
            new Validation<T>(true, value, default);

        public static Validation<T> Failure(string errorMessage = null) =>
            new Validation<T>(false, default, errorMessage);
    }

    /// <summary>
    /// Extension methods for <see cref="Validation{T}"/>.
    /// </summary>
    internal static class ValidationExtensions
    {
        /// <summary>
        /// Sequentially composes two validations, passing the value of the first validation to another
        /// validation-producing function if the first validation is a success.
        /// </summary>
        /// <typeparam name="T">The type of the first validation's success value.</typeparam>
        /// <typeparam name="U">The type of the second validation's success value.</typeparam>
        /// <param name="validation">The first validation.</param>
        /// <param name="bind">
        /// A function that takes the value of the first validation and returns a second validation.
        /// </param>
        /// <returns>
        /// The first validation if the first validation is a failure; otherwise, the return value of calling the bind
        /// function on the first validation's success value.
        /// </returns>
        internal static Validation<U> Bind<T, U>(this Validation<T> validation, Func<T, Validation<U>> bind) =>
            validation.IsFailure ? Validation<U>.Failure(validation.ErrorMessage) : bind(validation.Value);

        /// <summary>
        /// Converts an enumerable of validations into a validation of an enumerable.
        /// </summary>
        /// <typeparam name="T">The type of the validation success values.</typeparam>
        /// <param name="validations">The validations to sequence.</param>
        /// <returns>
        /// A validation that contains an enumerable of the validation values if all of the validations are a success,
        /// or the first error message if one of the validations is a failure.
        /// </returns>
        internal static Validation<IEnumerable<T>> Sequence<T>(this IEnumerable<Validation<T>> validations) =>
            validations.All(validation => validation.IsSuccess)
            ? Validation<IEnumerable<T>>.Success(validations.Select(validation => validation.Value))
            : Validation<IEnumerable<T>>.Failure(validations.First(validation => validation.IsFailure).ErrorMessage);

        /// <summary>
        /// Calls the action on the validation value if the validation is a success.
        /// </summary>
        /// <typeparam name="T">The type of the validation's success value.</typeparam>
        /// <param name="validation">The validation.</param>
        /// <param name="onSuccess">The action to call if the validation is a success.</param>
        internal static void Then<T>(this Validation<T> validation, Action<T> onSuccess)
        {
            if (validation.IsSuccess)
            {
                onSuccess(validation.Value);
            }
        }
    }
}
