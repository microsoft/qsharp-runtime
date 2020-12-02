using System;
using Microsoft.Azure.Quantum;

namespace ShippingSample
{
    partial class Program
    {
        static Workspace CreateWorkspace()
        {
            // Instantiate Workspace object which allows you to connect to the Workspace you"ve previously deployed in Azure. 
            // Be sure to fill in the settings below which can be retrieved by running "az quantum workspace show" in the terminal.
            // Copy the settings for your workspace below
            var workspace = new Workspace(
                subscriptionId: "", // add your subscription_id
                resourceGroupName: "", // add your resource_group
                workspaceName: "", // add your workspace name
                baseUri: new Uri("https://westus.quantum.azure.com/"));

            return workspace;
        }
    }
}
