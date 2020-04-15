namespace @Namespace
{
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.Simulators;
    using System;
    using System.Collections.Generic;
    using System.CommandLine;
    using System.CommandLine.Invocation;
    using System.CommandLine.Parsing;
    using System.Linq;
    using System.Numerics;
    using System.Threading.Tasks;

    /// <summary>
    /// The entry point driver is the entry point for the C# application that executes the Q# entry point.
    /// </summary>
    internal static class @EntryPointDriver
    {
        /// <summary>
        /// The argument handler for the Q# Unit type.
        /// </summary>
        internal static Argument<QVoid> UnitArgumentHandler { get; } = new Argument<QVoid>(
            CreateArgumentParser(arg => arg.Trim() == "()" ? (true, QVoid.Instance) : (false, default)));

        /// <summary>
        /// The argument handler for the Q# Result type.
        /// </summary>
        internal static Argument<Result> ResultArgumentHandler { get; } = new Argument<Result>(
            CreateArgumentParser(arg => Enum.TryParse(arg, ignoreCase: true, out ResultValue result) ? result switch
            {
                ResultValue.Zero => (true, Result.Zero),
                ResultValue.One => (true, Result.One),
                _ => (false, default)
            } : (false, default)));

        /// <summary>
        /// The argument handler for the Q# BigInt type.
        /// </summary>
        internal static Argument<BigInteger> BigIntArgumentHandler { get; } = new Argument<BigInteger>(
            CreateArgumentParser(arg => BigInteger.TryParse(arg, out var result) ? (true, result) : (false, default)));

        /// <summary>
        /// The argument handler for the Q# Range type.
        /// </summary>
        internal static Argument<QRange> RangeArgumentHandler { get; } = new Argument<QRange>(result =>
        {
            var option = ((OptionResult)result.Parent).Token.Value;
            var arg = string.Join(' ', result.Tokens.Select(token => token.Value));
            return new[]
            {
                ParseRangeFromEnumerable(option, arg, result.Tokens.Select(token => token.Value)),
                ParseRangeFromEnumerable(option, arg, arg.Split(".."))
            }
            .Choose(errors => result.ErrorMessage = string.Join('\n', errors.Distinct()));
        })
        {
            Arity = ArgumentArity.OneOrMore
        };

        /// <summary>
        /// Runs the entry point.
        /// </summary>
        /// <param name="args">The command-line arguments.</param>
        /// <returns>The exit code.</returns>
        private static async Task<int> Main(string[] args)
        {
            var simulate = new Command("simulate", "(default) Run the program using a local simulator.")
            {
                new Option<SimulatorKind>(new[] { "--simulator", "-s" },
                                          () => SimulatorKind.QuantumSimulator,
                                          "The name of the simulator to use.")
            };
            simulate.Handler = CommandHandler.Create<@EntryPointAdapter, SimulatorKind>(Simulate);

            var root = new RootCommand(@EntryPointAdapter.Summary) { simulate };
            foreach (var option in @EntryPointAdapter.Options) { root.AddGlobalOption(option); }

            // Set the simulate command as the default.
            foreach (var option in simulate.Options) { root.AddOption(option); }
            root.Handler = simulate.Handler;

            return await root.InvokeAsync(args);
        }

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point adapter.</param>
        /// <param name="simulator">The simulator to use.</param>
        private static async Task Simulate(@EntryPointAdapter entryPoint, SimulatorKind simulator)
        {
            static void DisplayReturnValue<T>(T value)
            {
                if (!(value is QVoid)) { Console.WriteLine(value); }
            }

            // TODO: Support custom simulators.
            switch (simulator)
            {
                case SimulatorKind.QuantumSimulator:
                    using (var quantumSimulator = new QuantumSimulator())
                    {
                        DisplayReturnValue(await entryPoint.Run(quantumSimulator));
                    }
                    break;
                case SimulatorKind.ToffoliSimulator:
                    DisplayReturnValue(await entryPoint.Run(new ToffoliSimulator()));
                    break;
                case SimulatorKind.ResourcesEstimator:
                    var resourcesEstimator = new ResourcesEstimator();
                    await entryPoint.Run(resourcesEstimator);
                    Console.WriteLine(resourcesEstimator.ToTSV());
                    break;
                default:
                    throw new ArgumentException("Invalid simulator.");
            }
        }

        /// <summary>
        /// Creates an argument parser that will use a default error message if parsing fails.
        /// </summary>
        /// <typeparam name="T">The type of the argument.</typeparam>
        /// <param name="parser">
        /// A function that takes the argument as a string and returns the parsed value and a boolean to indicate
        /// whether parsing succeeded.
        /// </param>
        /// <returns>An argument parser.</returns>
        private static ParseArgument<T> CreateArgumentParser<T>(Func<string, (bool, T)> parser) => result =>
        {
            var (success, value) = parser(result.Tokens.Single().Value);
            if (!success)
            {
                result.ErrorMessage = GetErrorMessage(
                    ((OptionResult)result.Parent).Token.Value, result.Tokens.Single().Value, typeof(T));
            }
            return value;
        };

        /// <summary>
        /// Parses a Q# range from an enumerable of strings, where the items are start and end or start, step, and end.
        /// </summary>
        /// <param name="option">The name of the option being parsed.</param>
        /// <param name="arg">The full argument string for the option.</param>
        /// <param name="items">The items in the argument.</param>
        /// <returns>The result of parsing the strings.</returns>
        private static @Result<QRange> ParseRangeFromEnumerable(string option, string arg, IEnumerable<string> items) =>
            items.Select(item => TryParseLong(option, item)).Sequence().Bind(values =>
                values.Count() == 2
                ? @Result<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1)))
                : values.Count() == 3
                ? @Result<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1), values.ElementAt(2)))
                : @Result<QRange>.Failure(GetErrorMessage(option, arg, typeof(QRange))));

        /// <summary>
        /// Parses a long from a string.
        /// </summary>
        /// <param name="option">The name of the option being parsed.</param>
        /// <param name="str">The string to parse.</param>
        /// <returns>The result of parsing the string.</returns>
        private static @Result<long> TryParseLong(string option, string str) =>
            long.TryParse(str, out var result)
            ? @Result<long>.Success(result)
            : @Result<long>.Failure(GetErrorMessage(option, str, typeof(long)));

        /// <summary>
        /// Returns an error message string for an argument parser.
        /// </summary>
        /// <param name="option">The name of the option.</param>
        /// <param name="arg">The value of the argument being parsed.</param>
        /// <param name="type">The expected type of the argument.</param>
        /// <returns></returns>
        private static string GetErrorMessage(string option, string arg, Type type) =>
            $"Cannot parse argument '{arg}' for option '{option}' as expected type {type}.";

        /// <summary>
        /// The names of simulators that can be used to simulate the entry point.
        /// </summary>
        private enum SimulatorKind
        {
            QuantumSimulator,
            ToffoliSimulator,
            ResourcesEstimator
        }
    }

    /// <summary>
    /// The result of a process that can either succeed or fail.
    /// </summary>
    /// <typeparam name="T">The type of the result value.</typeparam>
    internal struct @Result<T>
    {
        public bool IsSuccess { get; }
        public T Value { get; }
        public bool IsFailure { get => !IsSuccess; }
        public string ErrorMessage { get; }

        private @Result(bool isSuccess, T value, string errorMessage)
        {
            IsSuccess = isSuccess;
            Value = value;
            ErrorMessage = errorMessage;
        }

        public static @Result<T> Success(T value) => new @Result<T>(true, value, default);

        public static @Result<T> Failure(string errorMessage) => new @Result<T>(false, default, errorMessage);
    }

    /// <summary>
    /// Extensions method for <see cref="@Result"/>.
    /// </summary>
    internal static class @ResultExtensions
    {
        /// <summary>
        /// Sequentially composes two results, passing the value of the first result to another result-producing
        /// function if the first result is a success.
        /// </summary>
        /// <typeparam name="T">The value type of the first result.</typeparam>
        /// <typeparam name="U">The value type of the second result.</typeparam>
        /// <param name="result">The first result.</param>
        /// <param name="binder">
        /// A function that takes the value of the first result and returns a second result.
        /// </param>
        /// <returns>
        /// The first result if the first result is a failure; otherwise, the result of calling the binder function on
        /// the first result's value.
        /// </returns>
        internal static @Result<U> Bind<T, U>(this @Result<T> result, Func<T, @Result<U>> binder) =>
            result.IsFailure ? @Result<U>.Failure(result.ErrorMessage) : binder(result.Value);

        /// <summary>
        /// Converts an enumerable of results into a result of an enumerable.
        /// </summary>
        /// <typeparam name="T">The value type of the results.</typeparam>
        /// <param name="results">The results to sequence.</param>
        /// <returns>
        /// A result that contains an enumerable of the result values if all of the results are a success, or the first
        /// error message if one of the results is a failure.
        /// </returns>
        internal static @Result<IEnumerable<T>> Sequence<T>(this IEnumerable<@Result<T>> results) =>
            results.All(result => result.IsSuccess)
            ? @Result<IEnumerable<T>>.Success(results.Select(results => results.Value))
            : @Result<IEnumerable<T>>.Failure(results.First(results => results.IsFailure).ErrorMessage);

        /// <summary>
        /// Chooses the first successful result out of an enumerable of results.
        /// </summary>
        /// <typeparam name="T">The type of the result values.</typeparam>
        /// <param name="results">The results to choose from.</param>
        /// <param name="onError">
        /// The action to call with an enumerable of error messages if all of the results are failures.
        /// </param>
        /// <returns>
        /// The value of the first successful result, or default if none of the results were successful.
        /// </returns>
        internal static T Choose<T>(this IEnumerable<@Result<T>> results, Action<IEnumerable<string>> onError)
        {
            if (results.Any(result => result.IsSuccess))
            {
                return results.First(attempt => attempt.IsSuccess).Value;
            }
            else
            {
                onError(results.Where(result => result.IsFailure).Select(result => result.ErrorMessage));
                return default;
            }
        }
    }
}
