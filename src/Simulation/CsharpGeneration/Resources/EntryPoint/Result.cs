namespace @Namespace
{
    using System;
    using System.Collections.Generic;
    using System.Linq;

    /// <summary>
    /// The result of a process that can either succeed or fail.
    /// </summary>
    /// <typeparam name="T">The type of the result value.</typeparam>
    internal struct Result<T>
    {
        public bool IsSuccess { get; }
        public bool IsFailure { get => !IsSuccess; }
        public T Value { get => IsSuccess ? ValueOrDefault : throw new InvalidOperationException(); }
        public T ValueOrDefault { get; }
        public string ErrorMessage { get; }

        private Result(bool isSuccess, T value, string errorMessage)
        {
            IsSuccess = isSuccess;
            ValueOrDefault = value;
            ErrorMessage = errorMessage;
        }

        public static Result<T> Success(T value) => new Result<T>(true, value, default);

        public static Result<T> Failure(string errorMessage = null) => new Result<T>(false, default, errorMessage);
    }

    /// <summary>
    /// Extension methods for <see cref="Result{T}"/>.
    /// </summary>
    internal static class ResultExtensions
    {
        /// <summary>
        /// Converts an enumerable of results into a result of an enumerable.
        /// </summary>
        /// <typeparam name="T">The type of the result values.</typeparam>
        /// <param name="results">The results to sequence.</param>
        /// <returns>
        /// A result that contains an enumerable of the result values if all of the results are a success, or the first
        /// error message if one of the results is a failure.
        /// </returns>
        internal static Result<IEnumerable<T>> Sequence<T>(this IEnumerable<Result<T>> results) =>
            results.All(result => result.IsSuccess)
            ? Result<IEnumerable<T>>.Success(results.Select(results => results.Value))
            : Result<IEnumerable<T>>.Failure(results.First(results => results.IsFailure).ErrorMessage);

        /// <summary>
        /// Calls the action on the result value if the result is a success.
        /// </summary>
        /// <typeparam name="T">The type of the result value.</typeparam>
        /// <param name="result">The result.</param>
        /// <param name="onSuccess">The action to call if the result is a success.</param>
        internal static void Then<T>(this Result<T> result, Action<T> onSuccess)
        {
            if (result.IsSuccess)
            {
                onSuccess(result.Value);
            }
        }
    }
}
