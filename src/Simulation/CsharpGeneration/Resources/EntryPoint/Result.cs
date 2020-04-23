namespace @Namespace
{
    using System;

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
