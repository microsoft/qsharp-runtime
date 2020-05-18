// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Linq;
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
        public static IQuantumMachine? CreateMachine(IWorkspace workspace, string targetName, string storageAccountConnectionString)
        {
            if (string.IsNullOrEmpty(targetName))
            {
                return null;
            }

            if (targetName.StartsWith("ionq."))
            {
                var ionQType = AppDomain.CurrentDomain.GetAssemblies()
                    .First(a => a.FullName.StartsWith("Microsoft.Quantum.Providers.IonQ,"))
                    .GetType("Microsoft.Quantum.Providers.IonQ.Targets.IonQQuantumMachine", throwOnError: true);
                return (IQuantumMachine)Activator.CreateInstance(
                    ionQType, targetName, storageAccountConnectionString, workspace);
            }

            return null;
        }
    }
}