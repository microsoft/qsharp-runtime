using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// Indicates that a type can be serialized as columns of a CSV file.
    /// </summary>
    public interface ICSVColumns
    {
        /// <summary>
        /// Number of columns
        /// </summary>
        int Count { get; }
        /// <summary>
        /// Column names.  Must be of length <see cref="Count"/>.
        /// </summary>
        string[] GetColumnNames();

        /// <summary>
        /// Row corresponding to given type values. Must be of length <see cref="Count"/>.
        /// </summary>
        string[] GetRow();
    }
}
