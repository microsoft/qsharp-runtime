// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

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
        /// <param name="storageAccountConnectionString">The connection string for the Azure storage account.</param>
        /// <returns>A quantum machine for job submission targeting <c>targetName</c>.</returns>
        public static IQuantumMachine? CreateMachine(Workspace workspace, string targetName, string storageAccountConnectionString)
        {
            if (string.IsNullOrEmpty(targetName))
            {
                return null;
            }

            var machineName =
                targetName.StartsWith("ionq.")
                ? "Microsoft.Quantum.Providers.IonQ.Targets.IonQQuantumMachine, Microsoft.Quantum.Providers.IonQ"
                : targetName.StartsWith("honeywell.")
                ? "Microsoft.Quantum.Providers.Honeywell.Targets.HoneywellQuantumMachine, Microsoft.Quantum.Providers.Honeywell"
                : null;
            return machineName is null
                ? null
                : (IQuantumMachine)Activator.CreateInstance(
                    Type.GetType(machineName, throwOnError: true),
                    targetName,
                    storageAccountConnectionString,
                    workspace);
        }
    }
}