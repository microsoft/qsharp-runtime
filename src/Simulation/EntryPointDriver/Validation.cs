// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using Microsoft.Quantum.QsCompiler.CompilationBuilder;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Represents either a success or a failure of a process.
    /// </summary>
    /// <typeparam name="T">The type of the success value.</typeparam>
    internal readonly struct Validation<T>
    {
        /// <summary>
        /// True if the validation succeeded.
        /// </summary>
        internal bool IsSuccess { get; }
        
        /// <summary>
        /// True if the validation failed.
        /// </summary>
        internal bool IsFailure => !IsSuccess;

        /// <summary>
        /// The success value of the validation.
        /// </summary>
        /// <exception cref="InvalidOperationException">Thrown if the validation failed.</exception>
        internal T Value =>
            // Suppress null warning since ValueOrDefault may not be null if IsSuccess is true.
            (IsSuccess ? ValueOrDefault : throw new InvalidOperationException())!;

        /// <summary>
        /// The success value of the validation or a default value if the validation failed.
        /// </summary>
        [MaybeNull]
        internal T ValueOrDefault { get; }
        
        /// <summary>
        /// The error message of the validation, or null if the validation has no error message.
        /// </summary>
        internal string? ErrorMessage { get; }

        /// <summary>
        /// Creates a new validation.
        /// </summary>
        /// <param name="isSuccess">True if the validation succeeded.</param>
        /// <param name="value">The success value or a default value</param>
        /// <param name="errorMessage">The error message.</param>
        private Validation(bool isSuccess, T value, string? errorMessage)
        {
            IsSuccess = isSuccess;
            ValueOrDefault = value;
            ErrorMessage = errorMessage;
        }

        /// <summary>
        /// Creates a successful validation.
        /// </summary>
        /// <param name="value">The success value.</param>
        /// <returns>The successful validation.</returns>
        internal static Validation<T> Success(T value) =>
            new Validation<T>(true, value, default);

        /// <summary>
        /// Creates a failed validation.
        /// </summary>
        /// <param name="errorMessage">The error message.</param>
        /// <returns>The failed validation.</returns>
        internal static Validation<T> Failure(string? errorMessage = null) =>
            new Validation<T>(false, default!, errorMessage);
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
        /// <typeparam name="T1">The type of the first validation's success value.</typeparam>
        /// <typeparam name="T2">The type of the second validation's success value.</typeparam>
        /// <param name="validation">The first validation.</param>
        /// <param name="bind">
        /// A function that takes the value of the first validation and returns a second validation.
        /// </param>
        /// <returns>
        /// The first validation if the first validation is a failure; otherwise, the return value of calling the bind
        /// function on the first validation's success value.
        /// </returns>
        internal static Validation<T2> Bind<T1, T2>(this Validation<T1> validation, Func<T1, Validation<T2>> bind) =>
            validation.IsFailure ? Validation<T2>.Failure(validation.ErrorMessage) : bind(validation.Value);

        /// <summary>
        /// Converts an enumerable of validations into a validation of an enumerable.
        /// </summary>
        /// <typeparam name="T">The type of the validation success values.</typeparam>
        /// <param name="validations">The validations to sequence.</param>
        /// <returns>
        /// A validation that contains an enumerable of the validation values if all of the validations are a success,
        /// or the first error message if one of the validations is a failure.
        /// </returns>
        internal static Validation<IEnumerable<T>> Sequence<T>(this IEnumerable<Validation<T>> validations)
        {
            var (successes, failures) = validations.Partition(validation => validation.IsSuccess);
            return failures.Any()
                ? Validation<IEnumerable<T>>.Failure(failures.First().ErrorMessage)
                : Validation<IEnumerable<T>>.Success(successes.Select(validation => validation.Value));
        }

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
