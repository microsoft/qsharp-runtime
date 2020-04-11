namespace @Namespace
{
    using Microsoft.Quantum.Simulation.Core;
    using Microsoft.Quantum.Simulation.Simulators;
    using System;
    using System.CommandLine;
    using System.CommandLine.Invocation;
    using System.CommandLine.Parsing;
    using System.Threading.Tasks;

    internal enum @SimulatorKind
    {
        FullState,
        Toffoli
    }

    internal static class @EntryPointDriver
    {
        private static async Task<int> Main(string[] args)
        {
            var simulate = new Command("simulate")
            {
                Description = "Run the program using a local simulator.",
                Handler = CommandHandler.Create<@EntryPointAdapter, @SimulatorKind>(Simulate)
            };
            simulate.AddOption(new Option<@SimulatorKind>(
                new[] { "--simulator", "-s" },
                () => @SimulatorKind.FullState,
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

        private static async Task Simulate(@EntryPointAdapter entryPoint, @SimulatorKind simulator)
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

        private static async Task<T> WithSimulator<T>(Func<IOperationFactory, Task<T>> callable, @SimulatorKind simulator)
        {
            switch (simulator)
            {
                case @SimulatorKind.FullState:
                    using (var quantumSimulator = new QuantumSimulator())
                    {
                        return await callable(quantumSimulator);
                    }
                case @SimulatorKind.Toffoli:
                    return await callable(new ToffoliSimulator());
                default:
                    throw new ArgumentException("Invalid simulator.");
            }
        }
    }
}
