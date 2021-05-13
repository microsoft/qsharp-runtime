using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Compression;
using System.Text.Json;
using System.Threading.Tasks;
using Azure.Storage.Blobs;
using Microsoft.Azure.Quantum.Client.Models;
using Microsoft.Azure.Quantum.Storage;

namespace Microsoft.Azure.Quantum.Optimization
{
    public class Solver
    {
        readonly Workspace workspace;
        readonly string provider;
        readonly string target;
        readonly string inputDataFormat;
        readonly string outputDataFormat;
        readonly bool hasNestedParameters;

        Dictionary<string, object> parameters;

        public Solver(
            Workspace workspace,
            string provider,
            string target,
            string inputDataFormat,
            string outputDataFormat,
            bool hasNestedParameters = true)
        {
            this.workspace = workspace;
            this.provider = provider;
            this.target = target;
            this.inputDataFormat = inputDataFormat;
            this.outputDataFormat = outputDataFormat;
            this.hasNestedParameters = hasNestedParameters;

            parameters = new Dictionary<string, object>();
            if (hasNestedParameters)
            {
                parameters.Add("params", new Dictionary<string, object>());
            }
        }

        protected void AddParameter(string name, object value)
        {
            var parms = hasNestedParameters ? parameters["params"] as Dictionary<string, object> : parameters;

            parms.Add(name, value);
        }

        public async Task<CloudJob> SubmitAsync(Problem problem)
        {
            string intermediaryFile = Path.GetTempFileName();

            // Save to the intermediary file
            using (var intermediaryWriter = File.Create(intermediaryFile)) {
                using (var compressionStream = new GZipStream(intermediaryWriter, CompressionLevel.Fastest))
                {
                    await problem.SerializeAsync(compressionStream);
                    //                problem.SerializeTo(intermediaryWriter);
                }
            }

            using (var intermediaryReader = File.OpenRead(intermediaryFile))
            {
                var jobStorageHelper = new LinkedStorageJobHelper(workspace);
                var jobId = Guid.NewGuid().ToString();
                var (containerUri, inputUri) = await jobStorageHelper.UploadJobInputAsync(jobId, intermediaryReader);

                return await SubmitAsync(jobId, problem.Name, containerUri, inputUri);
            }
        }

        public async Task<CloudJob> SubmitAsync(string problemUri)
        {
            var jobId = Guid.NewGuid().ToString();

            // Calls the service to get a SAS Uri
            var containerSasUri = await workspace.GetSasUriAsync(problemUri);

            var inputSasUri = await workspace.GetSasUriAsync(problemUri, "inputData");

            var containerUri = new Uri(containerSasUri).GetLeftPart(UriPartial.Path);

            var inputUri = new Uri(inputSasUri).GetLeftPart(UriPartial.Path);

            return await SubmitAsync(jobId, "Optimization problem", containerUri, inputUri);
        }

        private async Task<CloudJob> SubmitAsync(string jobId, string problemName, string containerUri, string inputUri)
        {
            var details = new JobDetails
            {
                Id = jobId,
                Name = problemName,
                InputDataFormat = inputDataFormat,
                OutputDataFormat = outputDataFormat,
                ProviderId = provider,
                Target = target,
                InputParams = parameters,
                ContainerUri = containerUri,
                InputDataUri = inputUri
            };

            var job = await workspace.SubmitJobAsync(new CloudJob(workspace, details));

            return job;
        }

        /// <summary>
        /// Submits the Problem to the associated Azure Quantum Workspace and get the results.
        /// </summary>
        /// <param name="problem">The Problem to solve./param>
        public async Task<Result> OptimizeAsync(Problem problem, int maxPollInterval = 30)
        {
            var job = await SubmitAsync(problem);

            await job.RefreshAsync();

            int pollInterval = 1;

            while (job.InProgress)
            {
                Console.Out.Write(".");
                await Task.Delay(TimeSpan.FromSeconds(pollInterval));
                await job.RefreshAsync();

                pollInterval = (pollInterval >= maxPollInterval) ? maxPollInterval : pollInterval * 2;
            }
            Console.Out.WriteLine();

            var outputUri = new Uri(job.Details.OutputDataUri);

            var blobClient = new BlobClient(outputUri);

            var stream = new MemoryStream();

            await blobClient.DownloadToAsync(stream);

            stream.Seek(0, SeekOrigin.Begin);

            var result = await JsonSerializer.DeserializeAsync<Result>(stream);

            string ser = JsonSerializer.Serialize(result);

            Console.Out.WriteLine(ser);

            var result2 = JsonSerializer.Deserialize<Result>(ser);

            return result;
        }

        public Result Optimize(Problem problem, int maxPollInterval = 30)
        {
            return OptimizeAsync(problem, maxPollInterval).GetAwaiter().GetResult();
        }
    }

    public enum HardwarePlatform : int
    {
        CPU = 1,
        FPGA = 2
    };

    public class ParallelTemperingSolver : Solver
    {
        public ParallelTemperingSolver(Workspace workspace, int? timeout = null, int? seed = null, int? sweeps = null, int? replicas = null, int[] all_betas = null)
            : this(workspace, timeout, seed, !(sweeps.HasValue || replicas.HasValue || all_betas != null))
        {
            if (sweeps.HasValue)
                AddParameter("sweeps", sweeps.Value);

            if (all_betas != null)
            {
                AddParameter("all_betas", all_betas);
                if (replicas.HasValue)
                {
                    if (all_betas.Length != replicas)
                        throw new ArgumentException("Parameter 'replicas' must equal the length of the 'all_betas' parameters.");

                    AddParameter("replicas", replicas);
                }
                else
                {
                    AddParameter("replicas", all_betas.Length);
                }
            }
        }

        private ParallelTemperingSolver(Workspace workspace, int? timeout, int? seed, bool paramFree)
            : base(workspace,
                "Microsoft",
                paramFree ? "microsoft.paralleltempering-parameterfree.cpu" : "microsoft.paralleltempering.cpu",
                "microsoft.qio.v2",
                "microsoft.qio-results.v2")
        {

            if (timeout.HasValue)
                AddParameter("timeout", timeout.Value);

            if (seed.HasValue)
                AddParameter("seed", seed.Value);
        }
    }

    public class SimulatedAnnealingSolver : Solver
    {
        public SimulatedAnnealingSolver(Workspace workspace, int? timeout = null, int? seed = null, HardwarePlatform platform = HardwarePlatform.CPU, float? beta_start = null, float? beta_stop = null, int? sweeps = null, int? restarts = null)
            : this(workspace, timeout, seed, platform, !(beta_start.HasValue || beta_stop.HasValue || sweeps.HasValue || restarts.HasValue))
        {
            if (beta_start.HasValue)
                AddParameter("beta_start", beta_start.Value);

            if (beta_stop.HasValue)
                AddParameter("beta_stop", beta_stop.Value);

            if (sweeps.HasValue)
                AddParameter("sweeps", sweeps.Value);

            if (restarts.HasValue)
                AddParameter("restarts", restarts.Value);
        }

        private SimulatedAnnealingSolver(Workspace workspace, int? timeout, int? seed, HardwarePlatform platform, bool paramFree)
            : base(workspace,
                "Microsoft",
                (platform == HardwarePlatform.FPGA) ?
                    (paramFree ? "microsoft.simulatedannealing-parameterfree.fpga" : "microsoft.simulatedannealing.fpga") :
                    (paramFree ? "microsoft.simulatedannealing-parameterfree.cpu" : "microsoft.simulatedannealing.cpu"),
                "microsoft.qio.v2",
                "microsoft.qio-results.v2")
        {
            if (timeout.HasValue)
                AddParameter("timeout", timeout.Value);

            if (seed.HasValue)
                AddParameter("seed", seed.Value);
        }
    }

    public class TabuSolver : Solver
    {
        public TabuSolver(Workspace workspace, int? timeout = null, int? seed = null, int? sweeps = null, int? tabu_tenure = null)
            : this(workspace, timeout, seed,
                  !(tabu_tenure.HasValue || sweeps.HasValue))
        {
            if (sweeps.HasValue)
                AddParameter("sweeps", sweeps.Value);

            if (tabu_tenure.HasValue)
                AddParameter("tabu_tenure", tabu_tenure.Value);
        }

        private TabuSolver(Workspace workspace, int? timeout, int? seed, bool paramFree)
            : base(workspace,
                "Microsoft",
                paramFree ? "microsoft.tabu-parameterfree.cpu" : "microsoft.tabu.cpu",
                "microsoft.qio.v2",
                "microsoft.qio-results.v2")
        {
            if (timeout.HasValue)
                AddParameter("timeout", timeout.Value);

            if (seed.HasValue)
                AddParameter("seed", seed.Value);
        }
    }
}
