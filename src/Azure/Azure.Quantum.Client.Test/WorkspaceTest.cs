﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Linq;
using System.Net;
using System.Threading;
using System.Threading.Tasks;

using Azure.Quantum;
using Azure.Quantum.Jobs.Models;

using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.Azure.Quantum.Storage;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.Azure.Quantum.Test
{
    [TestClass]
    public class WorkspaceTest
    {
        private const string SETUP = @"
Live tests require you to configure your environment with these variables:
  * AZUREQUANTUM_WORKSPACE_NAME: the name of an Azure Quantum workspace to use for live testing.
  * AZUREQUANTUM_SUBSCRIPTION_ID: the Azure Quantum workspace's Subscription Id.
  * AZUREQUANTUM_WORKSPACE_RG: the Azure Quantum workspace's resource group.
  * AZUREQUANTUM_WORKSPACE_LOCATION: the Azure Quantum workspace's location (region).

We'll also try to authenticate with Azure using an instance of DefaultCredential. See
https://docs.microsoft.com/en-us/dotnet/api/overview/azure/identity-readme#authenticate-the-client
for details.

Tests will be marked as Inconclusive if the pre-reqs are not correctly setup.";

        [TestMethod]
        [TestCategory("Live")]
        public async Task SubmitJobTest()
        {
            // Create Job
            IWorkspace workspace = GetLiveWorkspace();

            CancellationTokenSource cts = new CancellationTokenSource();
            cts.CancelAfter(30000);

            var job = await SubmitTestProblem(workspace);
            AssertJob(job);

            await job.WaitForCompletion(cancellationToken: cts.Token);

            AssertJob(job);
            Assert.IsTrue(job.Succeeded);
        }

        [TestMethod]
        [TestCategory("Live")]
        public async Task GetJobTest()
        {
            IWorkspace workspace = GetLiveWorkspace();

            // Since this is a live workspace, we don't have much control about what jobs are in there
            // Get the jobs, and call Get on the first.
            await foreach (var job in workspace.ListJobsAsync())
            {
                AssertJob(job);

                var current = workspace.GetJob(job.Id);
                AssertJob(current);
                Assert.AreEqual(job.Id, current.Id);

                break;
            }
        }

        [TestMethod]
        [TestCategory("Live")]
        public async Task CancelJobTest()
        {
            // Create Job
            IWorkspace workspace = GetLiveWorkspace();

            var job = await SubmitTestProblem(workspace);
            AssertJob(job);

            try
            {
                var result = workspace.CancelJob(job.Id);
                AssertJob(result);
            }
            catch (WorkspaceClientException e)
            {
                Assert.AreEqual((int)HttpStatusCode.Conflict, e.Status);
            }
        }

        [TestMethod]
        [TestCategory("Live")]
        public async Task ListJobsTest()
        {
            IWorkspace workspace = GetLiveWorkspace();
            int max = 3;

            // Since this is a live workspace, we don't have much control about what jobs are in there
            // Just make sure there is more than one.
            await foreach (var job in workspace.ListJobsAsync())
            {
                Assert.IsNotNull(job);
                Assert.IsNotNull(job.Details);
                Assert.IsNotNull(job.Workspace);
                Assert.IsFalse(string.IsNullOrWhiteSpace(job.Id));
                Assert.AreEqual(job.Details.Id, job.Id);

                max--;
                if (max <= 0)
                {
                    break;
                }
            }

            // Make sure we iterated through all the expected jobs:
            Assert.AreEqual(0, max);
        }

        [TestMethod]
        [TestCategory("Live")]
        public async Task ListQuotasTest()
        {
            IWorkspace workspace = GetLiveWorkspace();
            int max = 3;

            // Since this is a live workspace, we don't have much control about what quotas are in there
            // Just make sure there is more than one.
            await foreach (var q in workspace.ListQuotasAsync())
            {
                Assert.IsNotNull(q);
                Assert.IsNotNull(q.ProviderId);
                Assert.IsNotNull(q.Dimension);

                max--;
                if (max <= 0)
                {
                    break;
                }
            }

            // Make sure we iterated through all the expected jobs:
            Assert.AreEqual(0, max);
        }

        [TestMethod]
        [TestCategory("Live")]
        public async Task ListProviderStatusTest()
        {
            IWorkspace workspace = GetLiveWorkspace();
            int max = 1;

            // Since this is a live workspace, we don't have much control about what quotas are in there
            // Just make sure there is more than one.
            await foreach (var s in workspace.ListProvidersStatusAsync())
            {
                Assert.IsNotNull(s);
                Assert.IsNotNull(s.ProviderId);
                Assert.IsNotNull(s.Targets);
                Assert.IsTrue(s.Targets.Any());

                max--;
                if (max <= 0)
                {
                    break;
                }
            }

            // Make sure we iterated through all the expected jobs:
            Assert.AreEqual(0, max);
        }

        private static void AssertJob(CloudJob job)
        {
            Assert.IsNotNull(job);
            Assert.IsNotNull(job.Details);
            Assert.IsNotNull(job.Workspace);
            Assert.IsFalse(string.IsNullOrEmpty(job.Id));
            Assert.AreEqual(job.Id, job.Details.Id);
        }

        private IWorkspace GetLiveWorkspace()
        {
            if (string.IsNullOrWhiteSpace(System.Environment.GetEnvironmentVariable("AZUREQUANTUM_SUBSCRIPTION_ID")) ||
                string.IsNullOrWhiteSpace(System.Environment.GetEnvironmentVariable("AZUREQUANTUM_WORKSPACE_RG")) ||
                string.IsNullOrWhiteSpace(System.Environment.GetEnvironmentVariable("AZUREQUANTUM_WORKSPACE_NAME")) ||
                string.IsNullOrWhiteSpace(System.Environment.GetEnvironmentVariable("AZUREQUANTUM_SUBSCRIPTION_ID")))
            {
                Assert.Inconclusive(SETUP);
            }

            var options = new QuantumJobClientOptions();
            options.Diagnostics.ApplicationId = "ClientTests";

            var credential = Authentication.CredentialFactory.CreateCredential(Authentication.CredentialType.Default);

            return new Workspace(
                subscriptionId: System.Environment.GetEnvironmentVariable("AZUREQUANTUM_SUBSCRIPTION_ID"),
                resourceGroupName: System.Environment.GetEnvironmentVariable("AZUREQUANTUM_WORKSPACE_RG"),
                workspaceName: System.Environment.GetEnvironmentVariable("AZUREQUANTUM_WORKSPACE_NAME"),
                location: System.Environment.GetEnvironmentVariable("AZUREQUANTUM_WORKSPACE_LOCATION"),
                options: options,
                credential: credential);
        }

        private static JobDetails CreateJobDetails(string jobId, string containerUri = null, string inputUri = null)
        {
            return new JobDetails(
                containerUri: containerUri,
                inputDataFormat: "microsoft.qio.v2",
                providerId: "Microsoft",
                target: "microsoft.paralleltempering-parameterfree.cpu")
            {
                Id = jobId,
                Name = "Azure.Quantum.Unittest",
                OutputDataFormat = "microsoft.qio-results.v2",
                InputParams = new Dictionary<string, object>()
                {
                    { "params", new Dictionary<string, object>() },
                },
                InputDataUri = inputUri,
            };
        }

        private static Problem CreateTestProblem()
        {
            // Create an Ising-type problem for shipping-containers
            var containerWeights = new int[] { 1, 5, 9, 21, 35, 5, 3, 5, 10, 11 };

            var problem = new Problem(ProblemType.Ising);
            for (int i = 0; i < containerWeights.Length; i++)
            {
                for (int j = 0; j < containerWeights.Length; j++)
                {
                    if (i != j)
                    {
                        problem.Add(i, j, containerWeights[i] * containerWeights[j]);
                    }
                }
            }

            return problem;
        }

        private async Task<(string, string)> UploadProblem(IWorkspace workspace, Problem problem, string jobId)
        {
            string intermediaryFile = Path.GetTempFileName();

            // Save to the intermediary file
            using (var intermediaryWriter = File.Create(intermediaryFile))
            {
                using (var compressionStream = new GZipStream(intermediaryWriter, CompressionLevel.Fastest))
                {
                    await problem.SerializeAsync(compressionStream);
                }
            }

            using (var intermediaryReader = File.OpenRead(intermediaryFile))
            {
                var jobStorageHelper = new LinkedStorageJobHelper(workspace);
                return await jobStorageHelper.UploadJobInputAsync(jobId, intermediaryReader);
            }
        }

        private async Task<CloudJob> SubmitTestProblem(IWorkspace workspace)
        {
            CancellationTokenSource cts = new CancellationTokenSource();
            cts.CancelAfter(30000);

            var jobId = Guid.NewGuid().ToString();
            var problem = CreateTestProblem();

            // Upload problem:
            var (containerUri, inputUri) = await UploadProblem(workspace, problem, jobId);

            CloudJob src = new CloudJob(workspace, CreateJobDetails(jobId, containerUri, inputUri));
            AssertJob(src);

            var job = await workspace.SubmitJobAsync(src, cts.Token);
            AssertJob(job);
            Assert.AreEqual(jobId, job.Id);
            Assert.IsFalse(job.Failed);

            return job;
        }
    }
}
