using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Linq;

namespace Microsoft.Quantum.EntryPointDriver
{
    /// <summary>
    /// Information about a command-line option.
    /// </summary>
    /// <typeparam name="T">The type of the option's argument.</typeparam>
    internal sealed class OptionInfo<T>
    {
        /// <summary>
        /// The option aliases.
        /// </summary>
        internal ImmutableList<string> Aliases { get; }

        /// <summary>
        /// The option's default value, if it has one.
        /// </summary>
        internal Maybe<T> DefaultValue { get; }

        /// <summary>
        /// The option description.
        /// </summary>
        private readonly string description;

        /// <summary>
        /// The option suggestions.
        /// </summary>
        private readonly IEnumerable<string>? suggestions;

        /// <summary>
        /// The option validator.
        /// </summary>
        private readonly ValidateSymbol<OptionResult>? validator;

        /// <summary>
        /// The option's argument descriptor.
        /// </summary>
        private readonly Argument<T>? argument;

        /// <summary>
        /// Creates an <see cref="OptionInfo{T}"/>.
        /// </summary>
        /// <param name="aliases">The option aliases.</param>
        /// <param name="defaultValue">The option's default value.</param>
        /// <param name="description">The option description.</param>
        /// <param name="suggestions">The option suggestions.</param>
        /// <param name="validator">The option validator.</param>
        /// <param name="argument">The option's argument descriptor.</param>
        internal OptionInfo(
            ImmutableList<string> aliases,
            Maybe<T> defaultValue,
            string description,
            IEnumerable<string>? suggestions = null,
            ValidateSymbol<OptionResult>? validator = null,
            Argument<T>? argument = null)
        {
            Aliases = aliases;
            DefaultValue = defaultValue;
            this.description = description;
            this.suggestions = suggestions;
            this.validator = validator;
            this.argument = argument;
        }

        /// <summary>
        /// Converts this <see cref="OptionInfo{T}"/> to an <see cref="Option{T}"/>.
        /// </summary>
        /// <param name="aliases">The option aliases.</param>
        /// <returns>The option.</returns>
        internal Option<T> ToOption(IEnumerable<string> aliases)
        {
            var option = DefaultValue.Case(
                () => new Option<T>(aliases.ToArray(), description) { Required = true },
                defaultValue => new Option<T>(aliases.ToArray(), () => defaultValue, description));

            if (!(argument is null))
            {
                option.Argument = argument;
            }

            if (!(validator is null))
            {
                option.AddValidator(validator);
            }

            return suggestions is null ? option : option.WithSuggestions(suggestions.ToArray());
        }
    }
}
