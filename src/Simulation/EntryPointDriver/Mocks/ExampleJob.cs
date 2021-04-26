using Microsoft.Quantum.Runtime;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace Microsoft.Quantum.EntryPointDriver.Mocks
{
    /// <summary>
    /// A quantum machine job with default properties to use as an example.
    /// </summary>
    internal class ExampleJob : IQuantumMachineJob
    {
        public string Id => "00000000-0000-0000-0000-0000000000000";

        public string Status => "NotImplemented";

        public bool InProgress => false;

        public bool Succeeded => false;

        public bool Failed => true;

        public Uri Uri => new Uri($"https://www.example.com/{Id}");

        public Task CancelAsync(CancellationToken cancellationToken = default) => throw new NotSupportedException();

        public Task RefreshAsync(CancellationToken cancellationToken = default) =>
            throw new NotSupportedException();
    }
}
