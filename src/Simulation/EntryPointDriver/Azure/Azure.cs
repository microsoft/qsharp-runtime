// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Microsoft.Azure.Quantum;
using Microsoft.Azure.Quantum.Exceptions;
using static Microsoft.Quantum.EntryPointDriver.Driver;
using Microsoft.Quantum.EntryPointDriver.Mock;
using Microsoft.Quantum.Runtime;
using Microsoft.Quantum.Simulation.Common.Exceptions;
using System;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Azure
{
    using Environment = System.Environment;

    /// <summary>
    /// Provides entry point submission to Azure Quantum.
    /// </summary>
    public static class Azure
    {
        /// <summary>
        /// Submits an entry point to Azure Quantum. If <paramref name="qirSubmission"/> is non-null and a QIR submitter
        /// is available for the target in <paramref name="settings"/>, the QIR entry point is submitted. Otherwise, the
        /// Q# entry point is submitted.
        /// </summary>
        /// <param name="settings">The Azure submission settings.</param>
        /// <param name="qsSubmission">A Q# entry point submission.</param>
        /// <param name="qirSubmission">A QIR entry point submission.</param>
        /// <typeparam name="TIn">The entry point argument type.</typeparam>
        /// <typeparam name="TOut">The entry point return type.</typeparam>
        /// <returns>The exit code.</returns>
        public static Task<int> Submit<TIn, TOut>(
            AzureSettings settings, QSharpSubmission<TIn, TOut> qsSubmission, QirSubmission? qirSubmission)
        {
            if (!(qirSubmission is null) && QirSubmitter(settings) is { } submitter)
            {
                return SubmitQir(settings, submitter, qirSubmission);
            }

            if (QSharpMachine(settings) is { } machine)
            {
                return SubmitQSharp(settings, machine, qsSubmission);
            }

            DisplayWithColor(ConsoleColor.Red, Console.Error, $"The target '{settings.Target}' is not recognized.");
            return Task.FromResult(1);
        }

        /// <summary>
        /// Submits a Q# entry point to Azure Quantum.
        /// </summary>
        /// <typeparam name="TIn">The entry point's argument type.</typeparam>
        /// <typeparam name="TOut">The entry point's return type.</typeparam>
        /// <param name="settings">The Azure submission settings.</param>
        /// <param name="machine">The quantum machine used for submission.</param>
        /// <param name="submission">The Q# entry point submission.</param>
        /// <returns>The exit code.</returns>
        private static async Task<int> SubmitQSharp<TIn, TOut>(
            AzureSettings settings, IQuantumMachine machine, QSharpSubmission<TIn, TOut> submission)
        {
            if (settings.Verbose)
            {
                Console.WriteLine("Submitting Q# entry point." + Environment.NewLine);
                Console.WriteLine(settings + Environment.NewLine);
            }

            return settings.DryRun ? Validate(machine, submission) : await SubmitJob(settings, machine, submission);
        }

        /// <summary>
        /// Submits a QIR entry point to Azure Quantum. 
        /// </summary>
        /// <param name="settings">The Azure submission settings.</param>
        /// <param name="submitter">The QIR entry point submitter.</param>
        /// <param name="submission">The QIR entry point submission.</param>
        /// <returns>The exit code.</returns>
        private static async Task<int> SubmitQir(
            AzureSettings settings, IQirSubmitter submitter, QirSubmission submission)
        {
            if (settings.Verbose)
            {
                Console.WriteLine("Submitting QIR entry point." + Environment.NewLine);
                Console.WriteLine(settings + Environment.NewLine);
            }

            var job = await submitter.SubmitAsync(submission.QirStream, submission.EntryPointName, submission.Arguments);
            DisplayJob(job, settings.Output);
            return 0;
        }

        /// <summary>
        /// Submits a job to Azure Quantum.
        /// </summary>
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <param name="settings">The submission settings.</param>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="submission">The entry point submission.</param>
        /// <returns>The exit code.</returns>
        private static async Task<int> SubmitJob<TIn, TOut>(
            AzureSettings settings, IQuantumMachine machine, QSharpSubmission<TIn, TOut> submission)
        {
            try
            {
                var job = await machine.SubmitAsync(
                    submission.EntryPointInfo,
                    submission.Argument,
                    new SubmissionContext { FriendlyName = settings.JobName, Shots = settings.Shots });

                DisplayJob(job, settings.Output);
                return 0;
            }
            catch (AzureQuantumException ex)
            {
                DisplayError(
                    "Something went wrong when submitting the program to the Azure Quantum service.",
                    ex.Message);
                return 1;
            }
            catch (QuantumProcessorTranslationException ex)
            {
                DisplayError(
                    "Something went wrong when performing translation to the intermediate representation used by the " +
                    "target quantum machine.",
                    ex.Message);
                return 1;
            }
        }

        /// <summary>
        /// Validates the program for the quantum machine target.
        /// </summary>
        /// <typeparam name="TIn">The input type.</typeparam>
        /// <typeparam name="TOut">The output type.</typeparam>
        /// <param name="machine">The quantum machine target.</param>
        /// <param name="submission">The entry point submission.</param>
        /// <returns>The exit code.</returns>
        private static int Validate<TIn, TOut>(IQuantumMachine machine, QSharpSubmission<TIn, TOut> submission)
        {
            var (isValid, message) = machine.Validate(submission.EntryPointInfo, submission.Argument);
            Console.WriteLine(isValid ? "✔️  The program is valid!" : "❌  The program is invalid.");
            if (!string.IsNullOrWhiteSpace(message))
            {
                Console.WriteLine(Environment.NewLine + message);
            }
            return isValid ? 0 : 1;
        }

        /// <summary>
        /// Displays the job using the output format.
        /// </summary>
        /// <param name="job">The job.</param>
        /// <param name="format">The output format.</param>
        /// <exception cref="ArgumentOutOfRangeException">Thrown if the output format is invalid.</exception>
        private static void DisplayJob(IQuantumMachineJob job, OutputFormat format)
        {
            switch (format)
            {
                case OutputFormat.FriendlyUri:
                    try
                    {
                        Console.WriteLine(job.Uri);
                    }
                    catch (Exception ex)
                    {
                        DisplayWithColor(
                            ConsoleColor.Yellow,
                            Console.Error,
                            $"The friendly URI for viewing job results could not be obtained.{Environment.NewLine}" +
                            $"Error details: {ex.Message}{Environment.NewLine}" +
                            "Showing the job ID instead.");

                        Console.WriteLine(job.Id);
                    }
                    break;
                case OutputFormat.Id:
                    Console.WriteLine(job.Id);
                    break;
                default:
                    throw new ArgumentOutOfRangeException($"Invalid output format '{format}'.");
            }
        }

        /// <summary>
        /// Displays an error to the console.
        /// </summary>
        /// <param name="summary">A summary of the error.</param>
        /// <param name="message">The full error message.</param>
        private static void DisplayError(string summary, string message)
        {
            DisplayWithColor(ConsoleColor.Red, Console.Error, summary);
            Console.Error.WriteLine(Environment.NewLine + message);
        }

        /// <summary>
        /// Returns a Q# machine.
        /// </summary>
        /// <param name="settings">The Azure Quantum submission settings.</param>
        /// <returns>A quantum machine.</returns>
        /// <exception cref="ArgumentNullException"><paramref name="settings"/>.Target is null.</exception>
        private static IQuantumMachine? QSharpMachine(AzureSettings settings) => settings.Target switch
        {
            null => throw new ArgumentNullException(nameof(settings), "Target is null."),
            NoOpQuantumMachine.TargetId => new NoOpQuantumMachine(),
            ErrorQuantumMachine.TargetId => new ErrorQuantumMachine(),
            _ => QuantumMachineFactory.CreateMachine(settings.CreateWorkspace(), settings.Target, settings.Storage)
        };

        /// <summary>
        /// Returns a QIR submitter.
        /// </summary>
        /// <param name="settings">The Azure Quantum submission settings.</param>
        /// <returns>A QIR submitter.</returns>
        /// <exception cref="ArgumentNullException"><paramref name="settings"/>.Target is null.</exception>
        private static IQirSubmitter? QirSubmitter(AzureSettings settings) => settings.Target switch
        {
            null => throw new ArgumentNullException(nameof(settings), "Target is null"),
            NoOpQirSubmitter.TargetId => new NoOpQirSubmitter(),
            _ => null // TODO
        };

        /// <summary>
        /// The quantum machine submission context.
        /// </summary>
        private sealed class SubmissionContext : IQuantumMachineSubmissionContext
        {
            public string? FriendlyName { get; set; }

            public int Shots { get; set; }
        }
    }
}
