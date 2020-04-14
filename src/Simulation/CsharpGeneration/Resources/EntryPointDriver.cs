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
    using System.Threading.Tasks;

    internal static class @EntryPointDriver
    {
        internal static readonly Argument<QRange> @RangeArgumentHandler =
            new Argument<QRange>(result =>
            {
                var option = (result.Parent as OptionResult)?.Token.Value ?? result.Argument.Name;
                var arg = string.Join(' ', result.Tokens.Select(token => token.Value));
                return new[]
                {
                    ParseRangeFromEnumerable(option, arg, result.Tokens.Select(token => token.Value)),
                    ParseRangeFromEnumerable(option, arg, arg.Split("..", StringSplitOptions.RemoveEmptyEntries))
                }
                .Choose(errors => result.ErrorMessage = string.Join('\n', errors));
            })
            {
                Arity = ArgumentArity.OneOrMore
            };

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

        private static async Task Resources(@EntryPointAdapter entryPoint)
        {
            var estimator = new ResourcesEstimator();
            await entryPoint.Run(estimator);
            Console.Write(estimator.ToTSV());
        }

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

        private static @Result<QRange> ParseRangeFromEnumerable(string option, string arg, IEnumerable<string> items) =>
            items.Select(item => TryParseLong(option, item)).Sequence().Bind(values =>
                values.Count() == 2
                ? @Result<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1)))
                : values.Count() == 3
                ? @Result<QRange>.Success(new QRange(values.ElementAt(0), values.ElementAt(1), values.ElementAt(2)))
                : @Result<QRange>.Failure(
                    $"Cannot parse argument '{arg}' for option '{option}' as expected type {typeof(QRange)}."));

        private static @Result<long> TryParseLong(string option, string str) =>
            long.TryParse(str, out var result)
            ? @Result<long>.Success(result)
            : @Result<long>.Failure(
                $"Cannot parse argument '{str}' for option '{option}' as expected type {typeof(long)}.");

        private enum SimulatorKind
        {
            FullState,
            Toffoli
        }
    }

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

    internal static class @ResultExtensions
    {
        internal static @Result<U> Bind<T, U>(this @Result<T> result, Func<T, @Result<U>> binder) =>
            result.IsFailure ? @Result<U>.Failure(result.ErrorMessage) : binder(result.Value);

        internal static @Result<IEnumerable<T>> Sequence<T>(this IEnumerable<@Result<T>> results) =>
            results.All(result => result.IsSuccess)
            ? @Result<IEnumerable<T>>.Success(results.Select(results => results.Value))
            : @Result<IEnumerable<T>>.Failure(results.First(results => results.IsFailure).ErrorMessage);

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
