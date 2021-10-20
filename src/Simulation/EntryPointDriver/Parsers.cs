// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.CommandLine.Parsing;
using System.ComponentModel;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.EntryPointDriver
{
    using Environment = System.Environment;

    /// <summary>
    /// Parsers for command-line arguments.
    /// </summary>
    internal static class Parsers
    {
        /// <summary>
        /// A delegate that parses the value and returns a validation.
        /// </summary>
        /// <typeparam name="T">The type parsed value.</typeparam>
        /// <param name="value">The string to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed value.</returns>
        private delegate Validation<T, string> TryParseValue<T>(string value, string optionName);

        /// <summary>
        /// Creates an argument parser for a single-valued argument of the given type.
        /// </summary>
        /// <typeparam name="T">The type of the argument.</typeparam>
        /// <returns>The argument parser.</returns>
        internal static ParseArgument<T> ParseOneArgument<T>() => argument =>
            ParseManyArguments<T>()(argument).SingleOrDefault();

        /// <summary>
        /// Creates an argument parser for a many-valued argument of the given type.
        /// </summary>
        /// <typeparam name="T">The type of the arguments.</typeparam>
        /// <returns>The argument parser.</returns>
        internal static ParseArgument<IQArray<T>> ParseManyArguments<T>() => argument =>
        {
            var parse = ValueParser<T>();
            var optionName = ((OptionResult)argument.Parent).Token.Value;
            var parsedValues = argument.Tokens.Select(token => parse(token.Value, optionName)).Sequence();

            return parsedValues.Case(
                values => new QArray<T>(values),
                errors => 
                { 
                    argument.ErrorMessage = string.Join(Environment.NewLine, errors); 
                    return new QArray<T>(); 
                });
        };

        /// <summary>
        /// Parses a sequence of <c>key=value</c> arguments as a dictionary of key-value pairs.
        /// </summary>
        /// <param name="argument">The argument result.</param>
        /// <returns>The parsed dictionary.</returns>
        internal static ImmutableDictionary<string, string> ParseDictionary(ArgumentResult argument)
        {
            var parsedPairs = argument.Tokens
                .Select(token =>
                {
                    var items = token.Value.Split('=', 2);
                    return items.Length == 2
                        ? Validation.Success<KeyValuePair<string, string>, string>(KeyValuePair.Create(items[0], items[1]))
                        : Validation.Failure<KeyValuePair<string, string>, string>($"This is not a \"key=value\" pair: '{token.Value}'");
                })
                .Sequence();

            return parsedPairs.Case(
                ImmutableDictionary.CreateRange,
                errors =>
                {
                    argument.ErrorMessage = string.Join(Environment.NewLine, errors);
                    return ImmutableDictionary<string, string>.Empty;
                });
        }

        /// <summary>
        /// Returns the value parser for the given type.
        /// </summary>
        /// <typeparam name="T">The type of the value.</typeparam>
        /// <returns>The value parser.</returns>
        private static TryParseValue<T> ValueParser<T>()
        {
            // We need to use casts because the type system does not realize that T really is the same as the concrete
            // type in each conditional branch.
            var type = typeof(T);
            return
                type == typeof(BigInteger)
                ? (TryParseValue<T>)(object)(TryParseValue<BigInteger>)TryParseBigInteger
                : type == typeof(QRange)
                ? (TryParseValue<T>)(object)(TryParseValue<QRange>)TryParseQRange
                : type == typeof(QVoid)
                ? (TryParseValue<T>)(object)(TryParseValue<QVoid>)TryParseQVoid
                : type == typeof(Result)
                ? (TryParseValue<T>)(object)(TryParseValue<Result>)TryParseResult
                : TryParseWithTypeConverter<T>;
        }

        /// <summary>
        /// Parses a <see cref="BigInteger"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="BigInteger"/>.</returns>
        private static Validation<BigInteger, string> TryParseBigInteger(string value, string optionName) =>
            BigInteger.TryParse(value, out var result)
                ? Validation.Success<BigInteger, string>(result)
                : Validation.Failure<BigInteger, string>(ArgumentErrorMessage(value, optionName, typeof(BigInteger)));

        /// <summary>
        /// Parses a <see cref="QRange"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QRange"/>.</returns>
        private static Validation<QRange, string> TryParseQRange(string value, string optionName)
        {
            Validation<long, string> TryParseLong(string longValue) =>
                long.TryParse(longValue, out var result)
                ? Validation.Success<long, string>(result)
                : Validation.Failure<long, string>(ArgumentErrorMessage(longValue, optionName, typeof(long)));

            var parsedItems = value
                .Split("..")
                .Select(TryParseLong)
                .Sequence()
                .Map(items => items.ToList(), errors => string.Concat(Environment.NewLine, errors));

            return parsedItems.Bind(items => items.Count switch
            {
                2 => Validation.Success<QRange, string>(new QRange(items[0], items[1])),
                3 => Validation.Success<QRange, string>(new QRange(items[0], items[1], items[2])),
                _ => Validation.Failure<QRange, string>(ArgumentErrorMessage(value, optionName, typeof(QRange)))
            });
        }

        /// <summary>
        /// Parses a <see cref="QVoid"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QVoid"/>.</returns>
        private static Validation<QVoid, string> TryParseQVoid(string value, string optionName) =>
            value.Trim() == QVoid.Instance.ToString()
            ? Validation.Success<QVoid, string>(QVoid.Instance)
            : Validation.Failure<QVoid, string>(ArgumentErrorMessage(value, optionName, typeof(QVoid)));

        /// <summary>
        /// Parses a <see cref="Result"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="Result"/>.</returns>
        private static Validation<Result, string> TryParseResult(string value, string optionName) =>
            Enum.TryParse(value, ignoreCase: true, out ResultValue result)
            ? Validation.Success<Result, string>(result switch
            {
                ResultValue.Zero => Result.Zero,
                ResultValue.One => Result.One,
                var invalid => throw new Exception($"Invalid result value '{invalid}'.")
            })
            : Validation.Failure<Result, string>(ArgumentErrorMessage(value, optionName, typeof(Result)));

        /// <summary>
        /// Parses a string into the given type using the corresponding type converter.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <typeparam name="T">The type of the parsed value.</typeparam>
        /// <returns>A validation of the parsed <typeparamref name="T"/>.</returns>
        private static Validation<T, string> TryParseWithTypeConverter<T>(string value, string optionName)
        {
            var converter = TypeDescriptor.GetConverter(typeof(T));
            if (!converter.CanConvertFrom(typeof(string)))
            {
                return Validation.Failure<T, string>(ArgumentErrorMessage(value, optionName, typeof(T)));
            }

            try
            {
                return Validation.Success<T, string>((T)converter.ConvertFromInvariantString(value));
            }
            catch
            {
                return Validation.Failure<T, string>(ArgumentErrorMessage(value, optionName, typeof(T)));
            }
        }
        
        /// <summary>
        /// Returns an error message string for an argument parser.
        /// </summary>
        /// <param name="arg">The value of the argument being parsed.</param>
        /// <param name="optionName">The name of the option.</param>
        /// <param name="type">The expected type of the argument.</param>
        /// <returns>An error message string for an argument parser.</returns>
        private static string ArgumentErrorMessage(string arg, string optionName, Type type) =>
            $"Cannot parse argument '{arg}' for option '{optionName}' as expected type {type}.";
    }
}
