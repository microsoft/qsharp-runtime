namespace @Namespace
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.Collections.Generic;
    using System.CommandLine.Parsing;
    using System.Linq;
    using System.Numerics;

    /// <summary>
    /// A delegate that parses the value and returns a validation.
    /// </summary>
    /// <typeparam name="T">The type parsed value.</typeparam>
    /// <param name="value">The string to parse.</param>
    /// <param name="optionName">The name of the option that the value was used with.</param>
    /// <returns>A validation of the parsed value.</returns>
    internal delegate Validation<T> TryParseValue<T>(string value, string optionName = null);

    /// <summary>
    /// Parsers for command-line arguments.
    /// </summary>
    internal static class Parsers
    {
        /// <summary>
        /// Creates an argument parser for a many-valued argument using a parser that operates on each string value.
        /// </summary>
        /// <typeparam name="T">The type of the parsed value.</typeparam>
        /// <param name="parse">The string parser.</param>
        /// <returns>The argument parser.</returns>
        internal static ParseArgument<IEnumerable<T>> ParseArgumentsWith<T>(TryParseValue<T> parse) => argument =>
        {
            var optionName = ((OptionResult)argument.Parent).Token.Value;
            var validation = argument.Tokens.Select(token => parse(token.Value, optionName)).Sequence();
            if (validation.IsFailure)
            {
                argument.ErrorMessage = validation.ErrorMessage;
            }
            return validation.ValueOrDefault;
        };

        /// <summary>
        /// Creates an argument parser for a single-valued argument using a parser that operates on the string value.
        /// </summary>
        /// <typeparam name="T">The type of the parsed value.</typeparam>
        /// <param name="parse">The string parser.</param>
        /// <returns>The argument parser.</returns>
        internal static ParseArgument<T> ParseArgumentWith<T>(TryParseValue<T> parse) => argument =>
        {
            var values = ParseArgumentsWith(parse)(argument);
            return values == null ? default : values.Single();
        };

        /// <summary>
        /// Parses a <see cref="BigInteger"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="BigInteger"/>.</returns>
        internal static Validation<BigInteger> TryParseBigInteger(string value, string optionName = null) =>
            BigInteger.TryParse(value, out var result)
            ? Validation<BigInteger>.Success(result)
            : Validation<BigInteger>.Failure(GetArgumentErrorMessage(value, optionName, typeof(BigInteger)));

        /// <summary>
        /// Parses a <see cref="QRange"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QRange"/>.</returns>
        internal static Validation<QRange> TryParseQRange(string value, string optionName = null)
        {
            Validation<long> tryParseLong(string longValue) =>
                long.TryParse(longValue, out var result)
                ? Validation<long>.Success(result)
                : Validation<long>.Failure(GetArgumentErrorMessage(longValue, optionName, typeof(long)));

            return value.Split("..").Select(tryParseLong).Sequence().Bind(values =>
                values.Count() == 2
                ? Validation<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1)))
                : values.Count() == 3
                ? Validation<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1), values.ElementAt(2)))
                : Validation<QRange>.Failure(GetArgumentErrorMessage(value, optionName, typeof(QRange))));
        }

        /// <summary>
        /// Parses a <see cref="QVoid"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QVoid"/>.</returns>
        internal static Validation<QVoid> TryParseQVoid(string value, string optionName = null) =>
            value.Trim() == QVoid.Instance.ToString()
            ? Validation<QVoid>.Success(QVoid.Instance)
            : Validation<QVoid>.Failure(GetArgumentErrorMessage(value, optionName, typeof(QVoid)));

        /// <summary>
        /// Parses a <see cref="Result"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="Result"/>.</returns>
        internal static Validation<Result> TryParseResult(string value, string optionName = null) =>
            Enum.TryParse(value, ignoreCase: true, out ResultValue result)
            ? Validation<Result>.Success(result switch
            {
                ResultValue.Zero => Result.Zero,
                ResultValue.One => Result.One,
                var invalid => throw new Exception($"Invalid result value '{invalid}'.")
            })
            : Validation<Result>.Failure(GetArgumentErrorMessage(value, optionName, typeof(Result)));

        /// <summary>
        /// Returns an error message string for an argument parser.
        /// </summary>
        /// <param name="arg">The value of the argument being parsed.</param>
        /// <param name="optionName">The name of the option.</param>
        /// <param name="type">The expected type of the argument.</param>
        /// <returns>An error message string for an argument parser.</returns>
        private static string GetArgumentErrorMessage(string arg, string optionName, Type type) =>
            $"Cannot parse argument '{arg}' for option '{optionName}' as expected type {type}.";
    }
}
