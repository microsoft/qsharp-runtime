using System.Collections.Generic;
using System.CommandLine;
using System.CommandLine.Parsing;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.CsharpGeneration.EntryPointDriver
{
    internal interface IEntryPoint
    {
        string Summary { get; }
        
        IEnumerable<Option> Options { get; }
        
        string DefaultSimulator { get; }

        IOperationFactory CreateDefaultCustomSimulator();

        // TODO: Type parameterize the return type.
        Task<object> Run(IOperationFactory factory, ParseResult parseResult);
    }
}
