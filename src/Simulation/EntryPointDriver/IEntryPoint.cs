using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    public interface IEntryPoint<T>
    {
        string Summary { get; }
        
        IEnumerable<Option> Options { get; }
        
        string DefaultSimulator { get; }

        IOperationFactory CreateDefaultCustomSimulator();

        Task<T> Run(IOperationFactory factory, ParseResult parseResult);
    }
}
