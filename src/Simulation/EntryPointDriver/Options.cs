using System;
using System.Collections.Generic;
using System.CommandLine;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using static System.Reflection.BindingFlags;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
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
        /// <param name="name">The name of the option.</param>
        /// <param name="description">A description of the option.</param>
        /// <param name="type">The type of the option's argument.</param>
        /// <returns>An option.</returns>
        public static Option CreateOption(string name, string description, Type type)
        {
            var isEnumerable = type.IsGenericType && type.GetGenericTypeDefinition() == typeof(IEnumerable<>);
            var baseType = isEnumerable ? type.GenericTypeArguments.Single() : type;
            var create = isEnumerable
                ? typeof(Options).GetMethod(nameof(CreateManyValuedOption), NonPublic | Static)
                : typeof(Options).GetMethod(nameof(CreateSingleValuedOption), NonPublic | Static);
            var option = (Option)create.MakeGenericMethod(baseType).Invoke(null, new object[] { name, description });
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
        private static Option<T> CreateSingleValuedOption<T>(string name, string description)
        {
            var parser = Parsers.ParseOneArgument<T>();
            return parser == null
                ? new Option<T>(name, description) { Required = true }
                : new Option<T>(name, parser, false, description) { Required = true };
        }

        /// <summary>
        /// Creates a command-line option with a many-valued argument.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="name">The name of the option.</param>
        /// <param name="description">A description of the option.</param>
        /// <returns>An option.</returns>
        private static Option<IEnumerable<T>> CreateManyValuedOption<T>(string name, string description)
        {
            var parser = Parsers.ParseManyArguments<T>();
            return parser == null
                ? new Option<IEnumerable<T>>(name, description) { Required = true }
                : new Option<IEnumerable<T>>(name, parser, false, description) { Required = true };
        }
    }
}
