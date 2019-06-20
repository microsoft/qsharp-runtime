using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit.Abstractions;
using Xunit.Sdk;

namespace Microsoft.Quantum.Simulation.XUnit
{
    public class TestCaseDiscoverer : IXunitTestCaseDiscoverer
    {
        /// <summary>
        /// Test case we use to report errors of the test case enumeration process.
        /// </summary>
        private TestCase SkipErrorTestCase(ITestFrameworkDiscoveryOptions discoveryOptions, ITestMethod testMethod, string message)
        {
            return new TestCase(
                DiagnosticMessageSink,
                discoveryOptions.MethodDisplay() ?? TestMethodDisplay.Method,
                testMethod,
                new TestOperation()
                {
                    assemblyName = "",
                    className = "", //when class name is empty the parent test case will be shown, so user can see there is a problem
                    fullClassName = "",
                    testCaseNamePrefix = "",
                    skipReason = message
                });
        }

        /// <summary>
        /// Implementation of <see cref="IXunitTestCaseDiscoverer"/>
        /// </summary>
        public IEnumerable<IXunitTestCase> Discover(ITestFrameworkDiscoveryOptions discoveryOptions, ITestMethod testMethod, IAttributeInfo factAttribute)
        {
            List<IXunitTestCase> result = new List<IXunitTestCase>();

            string assemblyName = factAttribute.GetNamedArgument<string>("AssemblyName");
            System.Reflection.Assembly testAssembly = null;
            if (assemblyName == null)
            {
                testAssembly = testMethod.TestClass.Class.ToRuntimeType().Assembly;
            }
            else
            {
                try
                {
                    testAssembly = System.Reflection.Assembly.Load(assemblyName);
                }
                catch (Exception e)
                {
                    result.Add(SkipErrorTestCase(discoveryOptions, testMethod, "Assembly load issue: " + e.Message));
                    return result;
                }
            }

            string testNamespace = factAttribute.GetNamedArgument<string>("TestNamespace") ?? testMethod.TestClass.Class.ToRuntimeType().Namespace;
            if (testNamespace == null)
            {
                result.Add(SkipErrorTestCase(discoveryOptions, testMethod, "Could not find the namespase with tests."));
                return result;
            }

            string Suffix = factAttribute.GetNamedArgument<string>("Suffix");
            string skipReason = factAttribute.GetNamedArgument<string>("Skip");
            string testCasePrefix = factAttribute.GetNamedArgument<string>("TestCasePrefix") ?? "";

            IEnumerable<Type> ourTypes =
                from definedType in testAssembly.DefinedTypes
                where definedType.Name.EndsWith(Suffix)
                where definedType.Namespace == testNamespace
                where typeof(AbstractCallable).IsAssignableFrom(definedType)
                where typeof(ICallable<QVoid, QVoid>).IsAssignableFrom(definedType)
                select definedType;

            foreach (Type operationType in ourTypes)
            {
                result.Add(
                    new TestCase(DiagnosticMessageSink, discoveryOptions.MethodDisplay() ?? TestMethodDisplay.Method, testMethod,
                        new TestOperation()
                        {
                            assemblyName = testAssembly.FullName,
                            className = operationType.Name,
                            fullClassName = operationType.FullName,
                            skipReason = skipReason,
                            testCaseNamePrefix = testCasePrefix
                        })
                    );
            }

            if (result.Count == 0)
            {
                result.Add(SkipErrorTestCase(discoveryOptions, testMethod, "No tests were found."));
            }

            return result;
        }

        protected IMessageSink DiagnosticMessageSink { get; }

        public TestCaseDiscoverer(IMessageSink diagnosticMessageSink)
        {
            DiagnosticMessageSink = diagnosticMessageSink;
        }
    }
}
