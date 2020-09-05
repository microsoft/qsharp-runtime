// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using Microsoft.Quantum.Runtime;

namespace Microsoft.Azure.Quantum
{
    public static class QuantumMachineFactory
    {
        /// <summary>
        /// Creates a quantum machine for job submission to an Azure Quantum workspace.
        /// </summary>
        /// <param name="workspace">The Azure Quantum workspace.</param>
        /// <param name="targetName">The execution target for job submission.</param>
        /// <param name="storageConnectionString">The connection string for the Azure storage account.</param>
        /// <returns>A quantum machine for job submission targeting <c>targetName</c>.</returns>
        public static IQuantumMachine? CreateMachine(
            IWorkspace workspace, string targetName, string? storageConnectionString = null)
        {
            var machineName =
                targetName is null
                ? null
                : targetName.StartsWith("qci.")
                ? "Microsoft.Quantum.Providers.QCI.Targets.QCIQuantumMachine, Microsoft.Quantum.Providers.QCI"
                : targetName.StartsWith("ionq.")
                ? "Microsoft.Quantum.Providers.IonQ.Targets.IonQQuantumMachine, Microsoft.Quantum.Providers.IonQ"
                : targetName.StartsWith("honeywell.")
                ? "Microsoft.Quantum.Providers.Honeywell.Targets.HoneywellQuantumMachine, Microsoft.Quantum.Providers.Honeywell"
                : null;

            Type? machineType = null;
            if (machineName != null)
            {
                // First try to load the signed assembly with the correct version, then try the unsigned one.
                try
                {
                    machineType = Type.GetType($"{machineName}, Version={typeof(IWorkspace).Assembly.GetName().Version}, Culture=neutral, PublicKeyToken=40866b40fd95c7f5");
                }
                catch
                {
                    machineType = null;
                }

                machineType ??= Type.GetType(machineName, throwOnError: true);
            }

            return machineType is null
                ? null
                : (IQuantumMachine)Activator.CreateInstance(
                    machineType,
                    targetName,
                    workspace,
                    storageConnectionString);
        }
    }
}
