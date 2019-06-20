using System;
using Xunit.Abstractions;
using Microsoft.Quantum.Simulation.Core;
using Xunit.Sdk;
using Xunit;

namespace Microsoft.Quantum.Simulation.XUnit
{
    [XunitTestCaseDiscoverer("Microsoft.Quantum.Simulation.XUnit.TestCaseDiscoverer", "Microsoft.Quantum.Xunit")]
    public class OperationDriverAttribute : FactAttribute
    {
        /// <summary>
        /// Suffix of the operation name that signifies that given operation is a test. Defaults to Test.
        /// </summary>
        public string Suffix { get; set; } = "Test";

        /// <summary>
        /// Assembly where look for the test cases. Defaults to the assembly in which test method is defined.
        /// </summary>
        public string AssemblyName { get; set; }

        /// <summary>
        /// Namespace where we look for the test cases. Defaults to the namespace in which test method is defined.
        /// </summary>
        public string TestNamespace { get; set; }

        /// <summary>
        /// A string to prepend to the test case name
        /// </summary>
        public string TestCasePrefix { get; set; }
    }
}
