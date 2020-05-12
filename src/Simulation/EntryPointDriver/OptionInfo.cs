using System;
using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Linq;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
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
        internal IReadOnlyCollection<string> Aliases { get; }

        /// <summary>
        /// The option's default value if the option has one.
        /// </summary>
        /// <exception cref="NotSupportedException">Thrown if the option does not have a default value.</exception>
        internal T DefaultValue => defaultValue();
        
        /// <summary>
        /// True if the option is required.
        /// </summary>
        internal bool Required { get; }

        /// <summary>
        /// A function that returns the default value or throws a <see cref="NotSupportedException"/>.
        /// </summary>
        private readonly Func<T> defaultValue;

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
        /// Creates an <see cref="OptionInfo{T}"/> for a non-required option.
        /// </summary>
        /// <param name="aliases">The option aliases.</param>
        /// <param name="defaultValue">The option's default value.</param>
        /// <param name="description">The option description.</param>
        /// <param name="suggestions">The option suggestions.</param>
        /// <param name="validator">The option validator.</param>
        internal OptionInfo(
            IReadOnlyCollection<string> aliases,
            T defaultValue,
            string description,
            IEnumerable<string>? suggestions = default,
            ValidateSymbol<OptionResult>? validator = default)
        {
            Aliases = aliases;
            Required = false;
            this.defaultValue = () => defaultValue;
            this.description = description;
            this.suggestions = suggestions;
            this.validator = validator;
        }
        
        /// <summary>
        /// Creates an <see cref="OptionInfo{T}"/> for a required option.
        /// </summary>
        /// <param name="aliases">The option aliases.</param>
        /// <param name="description">The option description.</param>
        /// <param name="suggestions">The option suggestions.</param>
        /// <param name="validator">The option validator.</param>
        internal OptionInfo(
            IReadOnlyCollection<string> aliases,
            string description,
            IEnumerable<string>? suggestions = default,
            ValidateSymbol<OptionResult>? validator = default)
        {
            Aliases = aliases;
            Required = true;
            defaultValue = () => throw new NotSupportedException("The option does not have a default value.");
            this.description = description;
            this.suggestions = suggestions;
            this.validator = validator;
        }

        /// <summary>
        /// Creates an option based on the information in the <see cref="OptionInfo{T}"/>.
        /// </summary>
        /// <param name="aliases">The option aliases.</param>
        /// <returns>The option.</returns>
        internal Option<T> Create(IEnumerable<string> aliases)
        {
            var option = Required
                ? new Option<T>(aliases.ToArray(), description) { Required = true }
                : new Option<T>(aliases.ToArray(), defaultValue, description);
            if (!(validator is null))
            {
                option.AddValidator(validator);
            }
            return suggestions is null ? option : option.WithSuggestions(suggestions.ToArray());
        }
    }
}
