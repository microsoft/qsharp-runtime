// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.CommandLine;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using static System.Reflection.BindingFlags;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Creates command-line options.
    /// </summary>
    public static class Options
    {
        /// <summary>
        /// Suggestions for values corresponding to each argument type.
        /// </summary>
        private static readonly IReadOnlyDictionary<Type, IReadOnlyCollection<string>> Suggestions =
            new Dictionary<Type, IReadOnlyCollection<string>>
            {
                [typeof(Result)] = Array.AsReadOnly(new[] { "Zero", "One" })
            };
        
        /// <summary>
        /// Creates a command-line option.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="name">The name of the option.</param>
        /// <param name="description">A description of the option.</param>
        /// <returns>An option.</returns>
        public static Option<T> CreateOption<T>(string name, string description)
        {
            var type = typeof(T);
            var isArray = type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IQArray<>);
            var baseType = isArray ? type.GenericTypeArguments.Single() : type;
            var create = isArray
                ? typeof(Options).GetMethod(nameof(CreateManyValuedOption), NonPublic | Static)
                : typeof(Options).GetMethod(nameof(CreateSingleValuedOption), NonPublic | Static);
            var option = (Option<T>)create
                .MakeGenericMethod(baseType)
                .Invoke(null, new object[] { name, description });
            return Suggestions.TryGetValue(baseType, out var suggestions)
                ? option.WithSuggestions(suggestions.ToArray())
                : option;
        }

        /// <summary>
        /// Creates a command-line option with a single-valued argument.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="name">The name of the option.</param>
        /// <param name="description">A description of the option.</param>
        /// <returns>An option.</returns>
        private static Option<T> CreateSingleValuedOption<T>(string name, string description) =>
            new Option<T>(name, description)
            {
                Required = true,
                Argument = new Argument<T>(Parsers.ParseOneArgument<T>())
                {
                    Arity = ArgumentArity.ExactlyOne
                }
            };

        /// <summary>
        /// Creates a command-line option with a many-valued argument.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="name">The name of the option.</param>
        /// <param name="description">A description of the option.</param>
        /// <returns>An option.</returns>
        private static Option<IQArray<T>> CreateManyValuedOption<T>(string name, string description) =>
            new Option<IQArray<T>>(name, description)
            {
                Required = true,
                Argument = new Argument<IQArray<T>>(Parsers.ParseManyArguments<T>())
                {
                    Arity = ArgumentArity.OneOrMore
                }
            };

        /// <summary>
        /// Creates a prefix and alias tuple from a string representing an option alias provided through the command line
        /// following the convention that muti-character aliases start with '--' and single-character aliases start with '-'.
        /// </summary>
        /// <param name="commandLineAlias">Option alias provided through the command line.</param>
        /// <returns>TODO.</returns>
        internal static Tuple<string, string> PrefixAliasTuple(string commandLineAlias)
        {
            var multiCharacterAliasPrefix = "--";
            var singleCharacterAliasPrefix = "-";
            string prefix;
            string alias;
            if (commandLineAlias.StartsWith(multiCharacterAliasPrefix))
            {
                prefix = multiCharacterAliasPrefix;
                alias = commandLineAlias.Substring(prefix.Length);
            }
            else if (commandLineAlias.StartsWith(singleCharacterAliasPrefix))
            {
                prefix = singleCharacterAliasPrefix;
                alias = commandLineAlias.Substring(prefix.Length);
            }
            else
            {
                prefix = commandLineAlias.Length > 1 ? multiCharacterAliasPrefix : singleCharacterAliasPrefix;
                alias = commandLineAlias;
            }

            return new Tuple<string, string>(prefix, alias);
        }
    }
}
