// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.CommandLine.Parsing;
using System.Linq;
using System.Numerics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
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
        private delegate Validation<T> TryParseValue<T>(string value, string optionName);
        
        /// <summary>
        /// Creates an argument parser for a single-valued argument of the given type, if one exists.
        /// </summary>
        /// <typeparam name="T">The type of the argument.</typeparam>
        /// <returns>An argument parser or null if none exists.</returns>
        internal static ParseArgument<T>? ParseOneArgument<T>()
        {
            var parser = TryGetValueParser<T>();
            return parser == null ? null : ParseOneArgumentWith(parser);
        }
        
        /// <summary>
        /// Creates an argument parser for a many-valued argument of the given type, if one exists.
        /// </summary>
        /// <typeparam name="T">The type of the arguments.</typeparam>
        /// <returns>An argument parser or null if none exists.</returns>
        internal static ParseArgument<IEnumerable<T>>? ParseManyArguments<T>()
        {
            var parser = TryGetValueParser<T>();
            return parser == null ? null : ParseManyArgumentsWith(parser);
        }

        /// <summary>
        /// Creates an argument parser for a single-valued argument using a parser that operates on the string value.
        /// </summary>
        /// <typeparam name="T">The type of the parsed value.</typeparam>
        /// <param name="parse">The string parser.</param>
        /// <returns>The argument parser.</returns>
        private static ParseArgument<T> ParseOneArgumentWith<T>(TryParseValue<T> parse) => argument =>
        {
            var values = ParseManyArgumentsWith(parse)(argument);
            return (values == null ? default : values.Single())!;
        };
        
        /// <summary>
        /// Creates an argument parser for a many-valued argument using a parser that operates on each string value.
        /// </summary>
        /// <typeparam name="T">The type of the parsed value.</typeparam>
        /// <param name="parse">The string parser.</param>
        /// <returns>The argument parser.</returns>
        private static ParseArgument<IEnumerable<T>> ParseManyArgumentsWith<T>(TryParseValue<T> parse) => argument =>
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
        /// Returns the value parser for the given type if one exists.
        /// </summary>
        /// <typeparam name="T">The type of the value.</typeparam>
        /// <returns>A value parser or null if none exists.</returns>
        private static TryParseValue<T>? TryGetValueParser<T>()
        {
            // We need to use casts to convince the type system that T really is the same as the concrete type in each
            // conditional branch.
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
                : null;
        }

        /// <summary>
        /// Parses a <see cref="BigInteger"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="BigInteger"/>.</returns>
        private static Validation<BigInteger> TryParseBigInteger(string value, string optionName) =>
            BigInteger.TryParse(value, out var result)
            ? Validation<BigInteger>.Success(result)
            : Validation<BigInteger>.Failure(ArgumentErrorMessage(value, optionName, typeof(BigInteger)));

        /// <summary>
        /// Parses a <see cref="QRange"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QRange"/>.</returns>
        private static Validation<QRange> TryParseQRange(string value, string optionName)
        {
            Validation<long> TryParseLong(string longValue) =>
                long.TryParse(longValue, out var result)
                ? Validation<long>.Success(result)
                : Validation<long>.Failure(ArgumentErrorMessage(longValue, optionName, typeof(long)));

            return value.Split("..").Select(TryParseLong).Sequence().Bind(values =>
            {
                var list = values.ToList();
                return list.Count switch
                {
                    2 => Validation<QRange>.Success(new QRange(list[0], list[1])),
                    3 => Validation<QRange>.Success(new QRange(list[0], list[1], list[2])),
                    _ => Validation<QRange>.Failure(ArgumentErrorMessage(value, optionName, typeof(QRange)))
                };
            });
        }

        /// <summary>
        /// Parses a <see cref="QVoid"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="QVoid"/>.</returns>
        private static Validation<QVoid> TryParseQVoid(string value, string optionName) =>
            value.Trim() == QVoid.Instance.ToString()
            ? Validation<QVoid>.Success(QVoid.Instance)
            : Validation<QVoid>.Failure(ArgumentErrorMessage(value, optionName, typeof(QVoid)));

        /// <summary>
        /// Parses a <see cref="Result"/>.
        /// </summary>
        /// <param name="value">The string value to parse.</param>
        /// <param name="optionName">The name of the option that the value was used with.</param>
        /// <returns>A validation of the parsed <see cref="Result"/>.</returns>
        private static Validation<Result> TryParseResult(string value, string optionName) =>
            Enum.TryParse(value, ignoreCase: true, out ResultValue result)
            ? Validation<Result>.Success(result switch
            {
                ResultValue.Zero => Result.Zero,
                ResultValue.One => Result.One,
                var invalid => throw new Exception($"Invalid result value '{invalid}'.")
            })
            : Validation<Result>.Failure(ArgumentErrorMessage(value, optionName, typeof(Result)));

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
