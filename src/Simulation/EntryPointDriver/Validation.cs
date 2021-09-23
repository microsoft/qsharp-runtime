// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.Linq;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Represents either success with a value of type <typeparamref name="TValue"/>, or failure with an error of type
    /// <typeparamref name="TError"/>.
    /// </summary>
    /// <typeparam name="TValue">The type of the value.</typeparam>
    /// <typeparam name="TError">The type of the error.</typeparam>
    internal abstract class Validation<TValue, TError>
    {
        private Validation()
        {
        }

        /// <summary>
        /// Case analysis on <see cref="Either{TValue, TError}"/>.
        /// </summary>
        /// <param name="onSuccess">Handles the case when this is <see cref="Success"/>.</param>
        /// <param name="onFailure">Handles the case when this is <see cref="Failure"/>.</param>
        /// <typeparam name="TResult">The type of the result.</typeparam>
        /// <returns>The result of handling the cases.</returns>
        internal abstract TResult Case<TResult>(Func<TValue, TResult> onSuccess, Func<TError, TResult> onFailure);

        /// <summary>
        /// The successful case of <see cref="Either{TValue, TError}"/> where a value is present.
        /// </summary>
        internal class Success : Validation<TValue, TError>
        {
            private readonly TValue value;

            /// <summary>
            /// Creates a <see cref="Success"/> instance.
            /// </summary>
            /// <param name="value">The value.</param>
            internal Success(TValue value) => this.value = value;

            internal override TResult Case<TResult>(Func<TValue, TResult> onSuccess, Func<TError, TResult> onFailure) =>
                onSuccess(value);
        }

        /// <summary>
        /// The failure case of <see cref="Either{TValue, TError}"/> where an error is present.
        /// </summary>
        internal class Failure : Validation<TValue, TError>
        {
            private readonly TError error;

            /// <summary>
            /// Creates a <see cref="Failure"/> instance.
            /// </summary>
            /// <param name="error">The error.</param>
            internal Failure(TError error) => this.error = error;

            internal override TResult Case<TResult>(Func<TValue, TResult> onSuccess, Func<TError, TResult> onFailure) =>
                onFailure(error);
        }
    }

    /// <summary>
    /// Static methods for <see cref="Validation{TSuccess, TError}"/>.
    /// </summary>
    internal static class Validation
    {
        /// <summary>
        /// The <see cref="Validation{TValue, TError}.Success"/> case.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <typeparam name="TValue">The type of the value.</typeparam>
        /// <typeparam name="TError">The type of the error</typeparam>
        /// <returns>The <see cref="Validation{TValue, TError}.Success"/> case.</returns>
        internal static Validation<TValue, TError> Success<TValue, TError>(TValue value) =>
            new Validation<TValue, TError>.Success(value);

        /// <summary>
        /// The <see cref="Validation{TValue, TError}.Failure"/> case.
        /// </summary>
        /// <param name="error">The error.</param>
        /// <typeparam name="TValue">The type of the value.</typeparam>
        /// <typeparam name="TError">The type of the error</typeparam>
        /// <returns>The <see cref="Validation{TValue, TError}.Failure"/> case.</returns>
        internal static Validation<TValue, TError> Failure<TValue, TError>(TError error) =>
            new Validation<TValue, TError>.Failure(error);

        /// <summary>
        /// Applies a mapping function to either the value or error of this <see cref="Validation{TValue, TError}"/>
        /// depending on its case.
        /// </summary>
        /// <param name="validation">The validation.</param>
        /// <param name="mapValue">The function to apply to the value.</param>
        /// <param name="mapError">The function to apply to the error.</param>
        /// <typeparam name="TValue1">The type of the original value.</typeparam>
        /// <typeparam name="TValue2">The type of the mapped value.</typeparam>
        /// <typeparam name="TError1">The type of the original error.</typeparam>
        /// <typeparam name="TError2">The type of the mapped error.</typeparam>
        /// <returns>The mapped <see cref="Validation{TValue, TError}"/>.</returns>
        internal static Validation<TValue2, TError2> Map<TValue1, TValue2, TError1, TError2>(
            this Validation<TValue1, TError1> validation,
            Func<TValue1, TValue2> mapValue,
            Func<TError1, TError2> mapError) =>
            validation.Case(
                value => Success<TValue2, TError2>(mapValue(value)), 
                error => Failure<TValue2, TError2>(mapError(error)));

        /// <summary>
        /// Composes two validations, passing the value of the first validation to another validation-producing function
        /// if the first validation is a success.
        /// </summary>
        /// <typeparam name="TValue1">The value type of the first validation.</typeparam>
        /// <typeparam name="TValue2">The value type of the second validation.</typeparam>
        /// <typeparam name="TError">The error type of both validations.</typeparam>
        /// <param name="validation">The first validation.</param>
        /// <param name="bind">
        /// A function that takes the value of the first validation and returns a second validation.
        /// </param>
        /// <returns>
        /// The first validation if the first validation is a failure; otherwise, the return value of calling the bind
        /// function on the first validation's value.
        /// </returns>
        internal static Validation<TValue2, TError> Bind<TValue1, TValue2, TError>(
            this Validation<TValue1, TError> validation, Func<TValue1, Validation<TValue2, TError>> bind) =>
            validation.Case(bind, Failure<TValue2, TError>);

        /// <summary>
        /// Converts an enumerable of validations into a validation of an enumerable of values and errors.
        /// </summary>
        /// <typeparam name="TValue">The value type of the validations.</typeparam>
        /// <typeparam name="TError">The error type of the validations.</typeparam>
        /// <param name="validations">The validations to sequence.</param>
        /// <returns>
        /// A validation that contains an enumerable of values if all validations are a success, or an enumerable of
        /// errors if any validation is a failure.
        /// </returns>
        internal static Validation<IEnumerable<TValue>, IEnumerable<TError>> Sequence<TValue, TError>(
            this IEnumerable<Validation<TValue, TError>> validations)
        {
            var (successes, failures) = validations.Aggregate(
                (ImmutableList<TValue>.Empty, ImmutableList<TError>.Empty),
                (acc, validation) => validation.Case(
                    value => (acc.Item1.Add(value), acc.Item2),
                    error => (acc.Item1, acc.Item2.Add(error))));

            return failures.Any()
                ? Failure<IEnumerable<TValue>, IEnumerable<TError>>(failures)
                : Success<IEnumerable<TValue>, IEnumerable<TError>>(successes);
        }
    }
}
