// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.EntryPointDriver;
using System;
using System.Collections.Generic;
using System.Collections.Immutable;
using System.CommandLine;
using System.CommandLine.Builder;
using System.CommandLine.Help;
using System.CommandLine.Invocation;
using System.CommandLine.Parsing;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using Microsoft.Azure.Quantum.Authentication;

namespace Microsoft.Quantum.EntryPointDriver
{
    using Validators = ImmutableList<ValidateSymbol<CommandResult>>;

    /// <summary>
    /// The entry point driver is the entry point for the C# application that executes Q# entry points.
    /// </summary>
    public sealed class Driver
    {
        /// <summary>
        /// The subscription option.
        /// </summary>
        private static readonly OptionInfo<string> SubscriptionOption = new OptionInfo<string>(
            ImmutableList.Create("--subscription"), "The subscription ID.");

        /// <summary>
        /// The resource group option.
        /// </summary>
        private static readonly OptionInfo<string> ResourceGroupOption = new OptionInfo<string>(
            ImmutableList.Create("--resource-group"), "The resource group name.");

        /// <summary>
        /// The workspace option.
        /// </summary>
        private static readonly OptionInfo<string> WorkspaceOption = new OptionInfo<string>(
            ImmutableList.Create("--workspace"), "The workspace name.");

        /// <summary>
        /// The storage option.
        /// </summary>
        private static readonly OptionInfo<string?> StorageOption = new OptionInfo<string?>(
            ImmutableList.Create("--storage"), default, "The storage account connection string.");

        /// <summary>
        /// The credential option.
        /// </summary>
        private static readonly OptionInfo<CredentialType?> CredentialOption = new OptionInfo<CredentialType?>(
            ImmutableList.Create("--credential"),
            CredentialType.Default,
            "The type of credential to use to authenticate with Azure.");

        /// <summary>
        /// The AAD token option.
        /// </summary>
        private static readonly OptionInfo<string?> AadTokenOption = new OptionInfo<string?>(
            ImmutableList.Create("--aad-token"), default, "The Azure Active Directory authentication token.");

        /// <summary>
        /// The User-Agent option.
        /// </summary>
        private static readonly OptionInfo<string?> UserAgentOption = new OptionInfo<string?>(
            ImmutableList.Create("--user-agent"), default, "A label to identify this application when making requests to Azure Quantum.");
        /// <summary>
        /// The base URI option.
        /// </summary>
        private static readonly OptionInfo<Uri?> BaseUriOption = new OptionInfo<Uri?>(
            ImmutableList.Create("--base-uri"), default, "The base URI of the Azure Quantum endpoint.");

        /// <summary>
        /// The location to use with the default endpoint option.
        /// </summary>
        private static readonly OptionInfo<string?> LocationOption = new OptionInfo<string?>(
            ImmutableList.Create("--location"),
            default,
            "The location to use with the default endpoint.",
            validator: result =>
            {
                var location = result.Tokens.SingleOrDefault()?.Value;
                if (location == null)
                {
                    return default;
                }

                var normalizedLocation = AzureSettings.NormalizeLocation(location);
                return Uri.CheckHostName(normalizedLocation) == UriHostNameType.Unknown ?
                    $"\"{location}\" is an invalid value for the --location option." :
                    default;
            });

        /// <summary>
        /// The job name option.
        /// </summary>
        private static readonly OptionInfo<string> JobNameOption = new OptionInfo<string>(
            ImmutableList.Create("--job-name"), string.Empty, "The name of the submitted job.");

        /// <summary>
        /// The shots option.
        /// </summary>
        private static readonly OptionInfo<int> ShotsOption = new OptionInfo<int>(
            ImmutableList.Create("--shots"),
            500,
            "The number of times the program is executed on the target machine.",
            validator: result =>
                int.TryParse(result.Tokens.SingleOrDefault()?.Value, out var value) && value <= 0
                    ? "The number of shots must be a positive number."
                    : default);

        /// <summary>
        /// The output option.
        /// </summary>
        private static readonly OptionInfo<OutputFormat> OutputOption = new OptionInfo<OutputFormat>(
            ImmutableList.Create("--output"),
            OutputFormat.FriendlyUri,
            "The information to show in the output after the job is submitted.");

        /// <summary>
        /// The dry run option.
        /// </summary>
        private static readonly OptionInfo<bool> DryRunOption = new OptionInfo<bool>(
            ImmutableList.Create("--dry-run"),
            false,
            "Validate the program and options, but do not submit to Azure Quantum.");

        /// <summary>
        /// The verbose option.
        /// </summary>
        private static readonly OptionInfo<bool> VerboseOption = new OptionInfo<bool>(
            ImmutableList.Create("--verbose"), false, "Show additional information about the submission.");

        /// <summary>
        /// The target option.
        /// </summary>
        private readonly OptionInfo<string?> TargetOption;

        /// <summary>
        /// The simulator option.
        /// </summary>
        private readonly OptionInfo<string> SimulatorOption;

        /// <summary>
        /// The driver settings.
        /// </summary>
        private readonly DriverSettings settings;

        /// <summary>
        /// All the registered entry points of the program.
        /// </summary>
        private readonly IReadOnlyCollection<IEntryPoint> entryPoints;

        /// <summary>
        /// Creates a new driver for the entry point.
        /// </summary>
        /// <param name="settings">The driver settings.</param>
        /// <param name="entryPoints">The entry points.</param>
        public Driver(DriverSettings settings, IReadOnlyCollection<IEntryPoint> entryPoints)
        {
            this.settings = settings;

            this.SimulatorOption = new OptionInfo<string>(
                this.settings.SimulatorOptionAliases,
                this.settings.DefaultSimulatorName,
                "The name of the simulator to use.",
                suggestions: new[]
                {
                    this.settings.QuantumSimulatorName,
                    this.settings.ToffoliSimulatorName,
                    this.settings.ResourcesEstimatorName,
                    this.settings.DefaultSimulatorName
                });

            var targetAliases = ImmutableList.Create("--target");
            const string targetDescription = "The target device ID.";
            this.TargetOption = string.IsNullOrWhiteSpace(settings.DefaultExecutionTarget)
                ? new OptionInfo<string?>(targetAliases, targetDescription)
                : new OptionInfo<string?>(targetAliases, this.settings.DefaultExecutionTarget, targetDescription);

            this.entryPoints = entryPoints;
        }

        /// <summary>
        /// Runs the entry point using the command-line arguments.
        /// </summary>
        /// <param name="args">The command-line arguments.</param>
        /// <returns>The exit code.</returns>
        public async Task<int> Run(string[] args)
        {
            var generateAzurePayloadSubCommands =
                this.entryPoints.Select(this.CreateGenerateAzureQuantumPayloadEntryPointCommand).ToList();
            var simulateSubCommands = this.entryPoints.Select(this.CreateSimulateEntryPointCommand).ToList();
            var submitSubCommands = this.entryPoints.Select(this.CreateSubmitEntryPointCommand).ToList();

            // TODO: Add generate command.
            var generate = CreateTopLevelCommand(
                "generateazurepayload",
                "Locally generate payload that can be submitted to Azure.",
                generateAzurePayloadSubCommands);

            var simulate = CreateTopLevelCommand(
                "simulate",
                "(default) Run the program using a local simulator.",
                simulateSubCommands);
            
            var submit = CreateTopLevelCommand(
                "submit",
                "Submit the program to Azure Quantum.",
                submitSubCommands);

            var root = new RootCommand() { simulate.Command, submit.Command, generate.Command };
            if (this.entryPoints.Count() == 1)
            {
                SetSubCommandAsDefault(root, simulate.Command, simulate.Validators);
                root.Description = this.entryPoints.First().Summary;
            }

            Console.OutputEncoding = Encoding.UTF8;
            return await new CommandLineBuilder(root)
                .UseDefaults()
                .UseHelpBuilder(context => new QsHelpBuilder(context.Console))
                .Build()
                .InvokeAsync(args);
        }

        /// <summary>
        /// Displays a message to the console using the given color and text writer.
        /// </summary>
        /// <param name="color">The text color.</param>
        /// <param name="writer">The text writer for the console output stream.</param>
        /// <param name="message">The message to display.</param>
        internal static void DisplayWithColor(ConsoleColor color, TextWriter writer, string message)
        {
            var originalForeground = Console.ForegroundColor;
            Console.ForegroundColor = color;
            writer.WriteLine(message);
            Console.ForegroundColor = originalForeground;
        }

        /// <summary>
        /// Copies the handle and options from the given sub command to the given command.
        /// </summary>
        /// <param name="root">The command whose handle and options will be set.</param>
        /// <param name="subCommand">The sub command that will be copied from.</param>
        /// <param name="validators">The validators associated with the sub command.</param>
        private static void SetSubCommandAsDefault(Command root, Command subCommand, Validators validators)
        {
            root.Handler = subCommand.Handler;
            foreach (var option in subCommand.Options)
            {
                root.AddOption(option);
            }
            foreach (var validator in validators)
            {
                root.AddValidator(validator);
            }
        }

        /// <summary>
        /// Returns true if the alias is not already used by an existing option.
        /// </summary>
        /// <param name="alias">The alias to check.</param>
        /// <param name="existingOptions">Existing options to check against.</param>
        /// <returns>True if the alias is available for use by the driver.</returns>
        private static bool IsAliasAvailable(string alias, IEnumerable<Option> existingOptions) =>
            !existingOptions.SelectMany(option => option.RawAliases).Contains(alias);

        /// <summary>
        /// Returns the default value and displays a warning if the primary (first) alias is
        /// shadowed by one of the given entry point's options, and returns the original value otherwise.
        /// </summary>
        /// <typeparam name="T">The type of the option values.</typeparam>
        /// <param name="entryPoint">The entry point whose options are checked against.</param>
        /// <param name="option">The option.</param>
        /// <param name="value">The value of the option given on the command line.</param>
        /// <returns>The default value or the original value.</returns>
        private static T DefaultIfShadowed<T>(IEntryPoint entryPoint, OptionInfo<T> option, T value)
        {
            if (IsAliasAvailable(option.Aliases.First(), entryPoint.Options))
            {
                return value;
            }
            else
            {
                DisplayWithColor(ConsoleColor.Yellow, Console.Error,
                    $"Warning: Option {option.Aliases.First()} is overridden by an entry point parameter name. " +
                    $"Using default value {option.DefaultValue}.");
                return option.DefaultValue;
            }
        }

        /// <summary>
        /// Adds the option to the command using only the aliases that are available, and only if the primary (first)
        /// alias is available. If a required option is not available, the command is disabled.
        /// </summary>
        /// <typeparam name="T">The type of the option's argument.</typeparam>
        /// <param name="command">The command to add the option to.</param>
        /// <param name="option">The option to add.</param>
        /// <returns>The list of validators added to the command during this function.</returns>
        private static Validators AddOptionIfAvailable<T>(Command command, OptionInfo<T> option)
        {
            if (IsAliasAvailable(option.Aliases.First(), command.Options))
            {
                command.AddOption(option.Create(option.Aliases.Where(alias => IsAliasAvailable(alias, command.Options))));
            }
            else if (option.Required)
            {
                ValidateSymbol<CommandResult> validator = commandResult =>
                    $"The required option {option.Aliases.First()} conflicts with an entry point parameter name.";

                command.AddValidator(validator);
                return ImmutableList.Create(validator);
            }

            return Validators.Empty;
        }

        /// <summary>
        /// Adds a validator to the command such that the specified options cannot be simultaneously included.
        /// </summary>
        /// <param name="command">The command to add the validator to.</param>
        /// <param name="primaryAliases">The primary aliases of the options to be marked as mutually exclusive.</param>
        /// <returns>The list of validators added to the command during this function.</returns>
        private static Validators MarkOptionsAsMutuallyExclusive(Command command, string[] primaryAliases)
        {
            ValidateSymbol<CommandResult> validator = result =>
            {
                var presentAliases = new List<string>();
                foreach (var rawAlias in primaryAliases)
                {
                    var option = command.Options.Where(o => o.RawAliases.Contains(rawAlias)).FirstOrDefault();
                    var presentAlias = option?.RawAliases.Where(result.Children.Contains).FirstOrDefault();
                    if (!string.IsNullOrEmpty(presentAlias) &&
                        result.Children.GetByAlias(presentAlias).Tokens.Count > 0)
                    {
                        presentAliases.Add(presentAlias);
                    }
                }

                if (presentAliases.Count > 1)
                {
                    return $"Options {string.Join(", ", presentAliases)} cannot be used together.";
                }

                return default;
            };

            command.AddValidator(validator);
            return ImmutableList.Create(validator);
        }

        // TODO: Add documentation.
        // TODO: This should take name and description of the command as arguments.
        private static CommandWithValidators CreateTopLevelCommand(
            string name,
            string description,
            List<CommandWithValidators> entryPointCommands)
        {
            var topLevelCommand= new Command(name, description);
            if (entryPointCommands.Count() == 1)
            {
                var epCommandWValidators = entryPointCommands.First();
                epCommandWValidators.Command.IsHidden = true;
                topLevelCommand.AddCommand(epCommandWValidators.Command);
                SetSubCommandAsDefault(topLevelCommand, epCommandWValidators.Command, epCommandWValidators.Validators);
                return new CommandWithValidators(topLevelCommand, epCommandWValidators.Validators);
            }
            else
            {
                foreach (var epCommandWValidators in entryPointCommands)
                {
                    topLevelCommand.AddCommand(epCommandWValidators.Command);
                }
                return new CommandWithValidators(topLevelCommand, Validators.Empty);
            }
        }

        // TODO: Add documentation.
        // TODO: Maybe this can be abstracted because the only different logic is the handler.
        private CommandWithValidators CreateGenerateAzureQuantumPayloadEntryPointCommand(IEntryPoint entryPoint)
        {
            var command = new Command(entryPoint.Name, entryPoint.Summary)
            {
                Handler = CommandHandler.Create(
                    (ParseResult parseResult, GenerateAzurePayloadSettings settings) =>
                        this.GenerateAzurePayload(parseResult, settings, entryPoint))
            };
            foreach (var option in entryPoint.Options)
            {
                command.AddOption(option);
            }

            // TODO: Check if Validators should be empty.
            return new CommandWithValidators(command, Validators.Empty);
        }

        /// <summary>
        /// Creates a sub command specific to the given entry point for the simulate command.
        /// </summary>
        /// <param name="entryPoint">The entry point to make a command for.</param>
        /// <returns>The command corresponding to the given entry point with the validators for that command.</returns>
        private CommandWithValidators CreateSimulateEntryPointCommand(IEntryPoint entryPoint)
        {
            var command = new Command(entryPoint.Name, entryPoint.Summary)
            {
                Handler = CommandHandler.Create((ParseResult parseResult, string simulator) => this.Simulate(parseResult, simulator, entryPoint))
            };
            foreach (var option in entryPoint.Options)
            {
                command.AddOption(option);
            }
            return new CommandWithValidators(command, AddOptionIfAvailable(command, this.SimulatorOption));
        }

        /// <summary>
        /// Creates a sub command specific to the given entry point for the submit command.
        /// </summary>
        /// <param name="entryPoint">The entry point to make a command for.</param>
        /// <returns>The command corresponding to the given entry point with the validators for that command.</returns>
        private CommandWithValidators CreateSubmitEntryPointCommand(IEntryPoint entryPoint)
        {
            var command = new Command(entryPoint.Name, entryPoint.Summary)
            {
                Handler = CommandHandler.Create((ParseResult parseResult, AzureSettings settings) => this.Submit(parseResult, settings, entryPoint))
            };
            foreach (var option in entryPoint.Options)
            {
                command.AddOption(option);
            }

            // TODO: Make stuff mutually exclusive here.
            var validators = AddOptionIfAvailable(command, SubscriptionOption)
                .Concat(AddOptionIfAvailable(command, ResourceGroupOption))
                .Concat(AddOptionIfAvailable(command, WorkspaceOption))
                .Concat(AddOptionIfAvailable(command, TargetOption))
                .Concat(AddOptionIfAvailable(command, CredentialOption))
                .Concat(AddOptionIfAvailable(command, StorageOption))
                .Concat(AddOptionIfAvailable(command, AadTokenOption))
                .Concat(AddOptionIfAvailable(command, UserAgentOption))
                .Concat(AddOptionIfAvailable(command, BaseUriOption))
                .Concat(AddOptionIfAvailable(command, LocationOption))
                .Concat(AddOptionIfAvailable(command, JobNameOption))
                .Concat(AddOptionIfAvailable(command, ShotsOption))
                .Concat(AddOptionIfAvailable(command, OutputOption))
                .Concat(AddOptionIfAvailable(command, DryRunOption))
                .Concat(AddOptionIfAvailable(command, VerboseOption))
                .Concat(MarkOptionsAsMutuallyExclusive(
                    command,
                    new[] { BaseUriOption.Aliases.First(), LocationOption.Aliases.First() }));

            return new CommandWithValidators(command, validators.ToImmutableList());
        }

        // TODO: Add documentation.
        private Task<int> GenerateAzurePayload(ParseResult parseResult, GenerateAzurePayloadSettings settings, IEntryPoint entryPoint) =>
            entryPoint.GenerateAzurePayload(parseResult, settings);

        /// <summary>
        /// Simulates the entry point.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="simulator">The simulator to use.</param>
        /// <param name="entryPoint">The entry point to simulate.</param>
        /// <returns>The exit code.</returns>
        private Task<int> Simulate(ParseResult parseResult, string simulator, IEntryPoint entryPoint) =>
            entryPoint.Simulate(parseResult, settings, DefaultIfShadowed(entryPoint, this.SimulatorOption, simulator));

        /// <summary>
        /// Submits the entry point to Azure Quantum.
        /// </summary>
        /// <param name="parseResult">The command-line parsing result.</param>
        /// <param name="azureSettings">The Azure submission settings.</param>
        /// <param name="entryPoint">The entry point to submit.</param>
        /// <returns>The exit code.</returns>
        private Task<int> Submit(ParseResult parseResult, AzureSettings azureSettings, IEntryPoint entryPoint) =>
            entryPoint.Submit(parseResult, new AzureSettings
            {
                Subscription = azureSettings.Subscription,
                ResourceGroup = azureSettings.ResourceGroup,
                Workspace = azureSettings.Workspace,
                Target = DefaultIfShadowed(entryPoint, TargetOption, azureSettings.Target),
                Storage = DefaultIfShadowed(entryPoint, StorageOption, azureSettings.Storage),
                AadToken = DefaultIfShadowed(entryPoint, AadTokenOption, azureSettings.AadToken),
                UserAgent = DefaultIfShadowed(entryPoint, UserAgentOption, azureSettings.UserAgent),
                BaseUri = DefaultIfShadowed(entryPoint, BaseUriOption, azureSettings.BaseUri),
                Location = DefaultIfShadowed(entryPoint, LocationOption, azureSettings.Location),
                Credential = DefaultIfShadowed(entryPoint, CredentialOption, azureSettings.Credential),
                JobName = DefaultIfShadowed(entryPoint, JobNameOption, azureSettings.JobName),
                Shots = DefaultIfShadowed(entryPoint, ShotsOption, azureSettings.Shots),
                Output = DefaultIfShadowed(entryPoint, OutputOption, azureSettings.Output),
                DryRun = DefaultIfShadowed(entryPoint, DryRunOption, azureSettings.DryRun),
                Verbose = DefaultIfShadowed(entryPoint, VerboseOption, azureSettings.Verbose)
            });

        /// <summary>
        /// A modification of the command-line <see cref="HelpBuilder"/> class.
        /// </summary>
        private sealed class QsHelpBuilder : HelpBuilder
        {
            /// <summary>
            /// Creates a new help builder using the given console.
            /// </summary>
            /// <param name="console">The console to use.</param>
            internal QsHelpBuilder(IConsole console) : base(console)
            {
            }

            protected override string ArgumentDescriptor(IArgument argument)
            {
                // Hide long argument descriptors.
                var descriptor = base.ArgumentDescriptor(argument);
                return descriptor.Length > 30 ? argument.Name : descriptor;
            }
        }

        /// <summary>
        /// Struct for housing a command with its validators.
        /// </summary>
        private struct CommandWithValidators
        {
            public Command Command;
            public Validators Validators;

            /// <summary>
            /// Basic constructor.
            /// </summary>
            public CommandWithValidators(Command command, Validators validators)
            {
                Command = command;
                Validators = validators;
            }
        }
    }
}
