// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
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

            if (targetName.StartsWith("ionq."))
            {
                var ionQType = Type.GetType(
                    "Microsoft.Quantum.Providers.IonQ.Targets.IonQQuantumMachine, Microsoft.Quantum.Providers.IonQ",
                    throwOnError: true);
                return (IQuantumMachine)Activator.CreateInstance(
                    ionQType, targetName, storageAccountConnectionString, workspace);
            }
            
            return null;
        }
    }
}