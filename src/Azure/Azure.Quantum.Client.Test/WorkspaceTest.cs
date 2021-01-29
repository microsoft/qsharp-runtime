// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Net.Http;
using Microsoft.Azure.Quantum.Client;
using Microsoft.Azure.Quantum.Client.Models;
using Microsoft.Azure.Quantum.Exceptions;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Newtonsoft.Json;

namespace Microsoft.Azure.Quantum.Test
{
    [TestClass]
    public class WorkspaceTest
    {
        private MockHelper httpMock;

        [TestInitialize]
        public void Init()
        {
            this.httpMock = new MockHelper();
        }

        [TestMethod]
        public void SubmitJobTest()
        {
            string jobId = Guid.NewGuid().ToString();

            // Craft response
            SetJobResponseMessage(jobId);

            // Create Job
            IWorkspace workspace = GetWorkspace();

            JobDetails jobDetails = CreateJobDetails(jobId);
            CloudJob job = new CloudJob(workspace, jobDetails);
            CloudJob receivedJob;

            // -ve cases
            try
            {
                jobDetails.ContainerUri = null;
                receivedJob = workspace.SubmitJob(job);
                Assert.Fail();
            }
            catch (WorkspaceClientException)
            {
                jobDetails.ContainerUri = "https://uri";
            }

            try
            {
                jobDetails.ProviderId = null;
                receivedJob = workspace.SubmitJob(job);
                Assert.Fail();
            }
            catch (WorkspaceClientException)
            {
                jobDetails.ProviderId = TestConstants.ProviderId;
            }

            // Success
            receivedJob = workspace.SubmitJob(job);

            // Validate request
            ValidateJobRequestMessage(jobId, HttpMethod.Put);

            // Validate response
            Assert.IsNotNull(receivedJob);

            Assert.IsNotNull(receivedJob.Workspace);

            Assert.AreEqual(
                expected: jobId,
                actual: receivedJob.Details.Id);
        }

        [TestMethod]
        public void GetJobTest()
        {
            string jobId = Guid.NewGuid().ToString();

            // Craft response
            SetJobResponseMessage(jobId);

            // Get Job
            IWorkspace workspace = GetWorkspace();

            CloudJob receivedJob = workspace.GetJob(jobId);

            // Validate request
            ValidateJobRequestMessage(jobId, HttpMethod.Get);

            // Validate response
            Assert.IsNotNull(receivedJob);

            Assert.IsNotNull(receivedJob.Workspace);

            Assert.AreEqual(
                expected: jobId,
                actual: receivedJob.Details.Id);
        }

        [TestMethod]
        public void CancelJobTest()
        {
            string jobId = Guid.NewGuid().ToString();

            // Craft response
            SetJobResponseMessage(jobId);

            // Cancel Job
            IWorkspace workspace = GetWorkspace();

            CloudJob receivedJob = workspace.CancelJob(jobId);

            // Validate request
            ValidateJobRequestMessage(jobId, HttpMethod.Delete, HttpMethod.Get);

            // Validate response
            Assert.IsNotNull(receivedJob);

            Assert.IsNotNull(receivedJob.Workspace);

            Assert.AreEqual(
                expected: jobId,
                actual: receivedJob.Details.Id);

            // Convenience method
            CloudJob job = new CloudJob(workspace, CreateJobDetails(jobId));
            string newJobId = Guid.NewGuid().ToString();
            SetJobResponseMessage(newJobId);

            Assert.AreEqual(
                jobId,
                job.Details.Id);

            job.CancelAsync().Wait();

            Assert.AreEqual(
                newJobId,
                job.Details.Id);
        }

        [TestMethod]
        public void ListJobsTest()
        {
            // Craft response
            JobDetails jobDetails = new JobDetails
            {
                ProviderId = TestConstants.ProviderId,
            };

            dynamic page = new
            {
                nextLink = (string)null,
                value = new JobDetails[] { jobDetails },
            };

            this.httpMock.ResponseMessage = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(page)),
            };

            // Cancel Job
            IWorkspace workspace = GetWorkspace();

            List<CloudJob> receivedJobs = workspace.ListJobs().ToList();

            // Validate request
            ValidateJobRequestMessage(null, HttpMethod.Get);

            // Validate response
            Assert.IsNotNull(receivedJobs);

            Assert.IsNotNull(receivedJobs.Single().Workspace);

            Assert.AreEqual(
                expected: jobDetails.ProviderId,
                actual: receivedJobs.Single().Details.ProviderId);
        }

        private IWorkspace GetWorkspace()
        {
            return new Workspace(
                subscriptionId: TestConstants.SubscriptionId,
                resourceGroupName: TestConstants.ResourceGroupName,
                workspaceName: TestConstants.WorkspaceName)
            {
                // Mock jobs client (only needed for unit tests)
                QuantumClient = new MockHelper.MockQuantumClient(httpMock)
                {
                    SubscriptionId = TestConstants.SubscriptionId,
                    ResourceGroupName = TestConstants.ResourceGroupName,
                    WorkspaceName = TestConstants.WorkspaceName,
                    BaseUri = new Uri(TestConstants.Endpoint),
                },
            };
        }

        private void SetJobResponseMessage(string jobId)
        {
            this.httpMock.ResponseMessage = new HttpResponseMessage(HttpStatusCode.OK)
            {
                Content = new StringContent(JsonConvert.SerializeObject(CreateJobDetails(jobId))),
            };
        }

        private static JobDetails CreateJobDetails(string jobId)
        {
            return new JobDetails(
                id: jobId,
                containerUri: "https://uri",
                inputDataFormat: "format1",
                providerId: TestConstants.ProviderId,
                target: "target");
        }

        private void ValidateJobRequestMessage(
            string jobId,
            params HttpMethod[] methods)
        {
            var requestMessages = httpMock.RequestMessages;
            Assert.AreEqual(requestMessages.Count, methods.Length);

            for (var i = 0; i < requestMessages.Count; i++)
            {
                var requestMessage = requestMessages[i];
                var method = methods[i];

                // Url
                string expectedUri = $"{TestConstants.Endpoint}/v1.0/subscriptions/{TestConstants.SubscriptionId}/resourceGroups/{TestConstants.ResourceGroupName}/providers/Microsoft.Quantum/workspaces/{TestConstants.WorkspaceName}/jobs/{jobId}";
                Assert.AreEqual(
                    expected: expectedUri.TrimEnd('/'),
                    actual: requestMessage.RequestUri.ToString());

                // Method
                Assert.AreEqual(
                    expected: method,
                    actual: requestMessage.Method);
            }
        }
    }
}
