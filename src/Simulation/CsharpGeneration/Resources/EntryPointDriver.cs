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
        /// The argument handler for the Q# BigInt type.
        /// </summary>
        internal static readonly Argument<BigInteger> BigIntArgumentHandler =
            new Argument<BigInteger>(result =>
            {
                var option = (result.Parent as OptionResult)?.Token.Value ?? result.Argument.Name;
                var arg = result.Tokens.Single().Value;
                if (BigInteger.TryParse(arg, out var num))
                {
                    return num;
                }
                else
                {
                    result.ErrorMessage = GetErrorMessage(option, arg, typeof(BigInteger));
                    return default;
                }
            });

        /// <summary>
        /// The argument handler for the Q# Range type.
        /// </summary>
        internal static readonly Argument<QRange> RangeArgumentHandler =
            new Argument<QRange>(result =>
            {
                var option = (result.Parent as OptionResult)?.Token.Value ?? result.Argument.Name;
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
            var simulate = new Command("simulate")
            {
                Description = "Run the program using a local simulator.",
                Handler = CommandHandler.Create<@EntryPointAdapter, SimulatorKind>(Simulate)
            };
            simulate.AddOption(new Option<SimulatorKind>(
                new[] { "--simulator", "-s" },
                () => SimulatorKind.FullState,
                "The name of the simulator to use."));

            var resources = new Command("resources")
            {
                Description = "Estimate the resource usage of the program.",
                Handler = CommandHandler.Create<@EntryPointAdapter>(Resources)
            };

            var root = new RootCommand(@EntryPointAdapter.Summary) { simulate, resources };
            foreach (var option in @EntryPointAdapter.Options)
            {
                root.AddGlobalOption(option);
            }
            root.AddValidator(result => "A command is required.");
            return await root.InvokeAsync(args);
        }

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="entryPoint">The entry point adapter.</param>
        /// <param name="simulator">The simulator to use.</param>
        private static async Task Simulate(@EntryPointAdapter entryPoint, SimulatorKind simulator)
        {
            var result = await WithSimulator(entryPoint.Run, simulator);
#pragma warning disable CS0184
            if (!(result is QVoid))
#pragma warning restore CS0184
            {
                Console.WriteLine(result);
            }
        }

        /// <summary>
        /// Estimates the resource usage of the Q# program.
        /// </summary>
        /// <param name="entryPoint">The entry point adapter.</param>
        private static async Task Resources(@EntryPointAdapter entryPoint)
        {
            var estimator = new ResourcesEstimator();
            await entryPoint.Run(estimator);
            Console.Write(estimator.ToTSV());
        }

        /// <summary>
        /// Simulates a callable.
        /// </summary>
        /// <typeparam name="T">The return type of the callable.</typeparam>
        /// <param name="callable">The callable to simulate.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <returns>The return value of the callable.</returns>
        private static async Task<T> WithSimulator<T>(Func<IOperationFactory, Task<T>> callable, SimulatorKind simulator)
        {
            switch (simulator)
            {
                case SimulatorKind.FullState:
                    using (var quantumSimulator = new QuantumSimulator())
                    {
                        return await callable(quantumSimulator);
                    }
                case SimulatorKind.Toffoli:
                    return await callable(new ToffoliSimulator());
                default:
                    throw new ArgumentException("Invalid simulator.");
            }
        }

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
            FullState,
            Toffoli
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
