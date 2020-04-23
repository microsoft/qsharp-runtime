namespace @Namespace
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.CommandLine;
    using System.Linq;
    using System.Numerics;

    /// <summary>
    /// The result of trying to convert a string into the type <typeparamref name="T"/>.
    /// </summary>
    /// <typeparam name="T">The type of the value.</typeparam>
    internal abstract class ConversionResult<T>
    {
        public bool IsValid { get; protected set; }
        public T ValueOrDefault { get; protected set; }
    }

    internal static class ConversionResult
    {
        /// <summary>
        /// Adds a validator to the option that requires the argument to be successfully parsed by the given function.
        /// </summary>
        /// <typeparam name="T">The option's type parameter.</typeparam>
        /// <typeparam name="U">The type that the parser will produce.</typeparam>
        /// <param name="option">The option to add the validator to.</param>
        /// <param name="parse">The function that must successfully parse the arguments.</param>
        /// <returns>The option after the validator is added.</returns>
        internal static Option<T> WithValidator<T, U>(Option<T> option, Func<string, ConversionResult<U>> parse)
        {
            option.AddValidator(result => result
                .Tokens
                .Select(token => token.Value)
                .Where(value => !parse(value).IsValid)
                .Select(value =>
                    $"Cannot parse argument '{value}' for option '{result.Token.Value}' as expected type {typeof(U)}.")
                .FirstOrDefault());
            return option;
        }
    }

    /// <summary>
    /// Converts a string to a <see cref="BigInteger"/>.
    /// </summary>
    internal sealed class BigIntegerConverter : ConversionResult<BigInteger>
    {
        public BigIntegerConverter(string value)
        {
            IsValid = BigInteger.TryParse(value, out var result);
            ValueOrDefault = result;
        }
    }

    /// <summary>
    /// Converts a string to a <see cref="QRange"/>.
    /// </summary>
    internal sealed class QRangeConverter : ConversionResult<QRange>
    {
        public QRangeConverter(string value)
        {
            value.Split("..").Select(TryParseLong).Sequence().Then(values =>
            {
                if (values.Count() == 2)
                {
                    IsValid = true;
                    ValueOrDefault = new QRange(values.ElementAt(0), values.ElementAt(1));
                }
                else if (values.Count() == 3)
                {
                    IsValid = true;
                    ValueOrDefault = new QRange(values.ElementAt(0), values.ElementAt(1), values.ElementAt(2));
                }
            });
        }

        /// <summary>
        /// Parses a long from a string.
        /// </summary>
        /// <param name="value">The string to parse.</param>
        /// <returns>The result of parsing the string.</returns>
        private static Result<long> TryParseLong(string value) =>
            long.TryParse(value, out var result) ? Result<long>.Success(result) : Result<long>.Failure();
    }

    /// <summary>
    /// Converts a string to <see cref="QVoid"/>.
    /// </summary>
    internal sealed class QVoidConverter : ConversionResult<QVoid>
    {
        public QVoidConverter(string value)
        {
            IsValid = value.Trim() == QVoid.Instance.ToString();
            ValueOrDefault = QVoid.Instance;
        }
    }

    /// <summary>
    /// Converts a string to a <see cref="Result"/>.
    /// </summary>
    internal sealed class ResultConverter : ConversionResult<Result>
    {
        public ResultConverter(string value)
        {
            IsValid = Enum.TryParse(value, ignoreCase: true, out ResultValue result);
            ValueOrDefault = result switch
            {
                ResultValue.Zero => Result.Zero,
                ResultValue.One => Result.One,
                _ => default
            };
        }
    }
}
