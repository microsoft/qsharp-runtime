// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using Xunit;

using System;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Xunit.Abstractions;
using System.Text;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class StackTraceTests
    {
        const string namespacePrefix = "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.";

        private readonly ITestOutputHelper output;
        public StackTraceTests(ITestOutputHelper output)
        {
            this.output = output;
        }

        [Fact]
        public void AllocateQubit2Test()
        {
            using var sim = new QuantumSimulator();
            try
            {
                IgnorableAssert.Disable();
                QVoid res = sim.Execute<AllocateQubit2, QVoid, QVoid>(QVoid.Instance);
            }
            catch (ExecutionFailException)
            {
                var stackFrames = sim.CallStack;

                // Make sure that the call stack isn't null before proceeding.
                Assert.NotNull(stackFrames);

                // The following assumes that Assert is on Q# stack.
                Assert.Equal(2, stackFrames!.Length);

                Assert.Equal("Microsoft.Quantum.Diagnostics.AssertMeasurement", stackFrames[0].Callable.FullName);
                Assert.Equal(namespacePrefix + "AllocateQubit2", stackFrames[1].Callable.FullName);

                Assert.Equal(OperationFunctor.Body, stackFrames[0].Callable.Variant);
                Assert.Equal(OperationFunctor.Body, stackFrames[1].Callable.Variant);

                Assert.Equal(94, stackFrames[1].FailedLineNumber);
            }
            finally
            {
                IgnorableAssert.Enable();
            }
        }

        [Fact]
        public void AlwaysFail4Test()
        {
            using (var sim = new QuantumSimulator())
            {
                try
                {
                    QVoid res = AlwaysFail4.Run(sim).Result;
                }
                catch (AggregateException ex)
                {
                    Assert.True(ex.InnerException is ExecutionFailException);

                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(5, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "AlwaysFail1", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "AlwaysFail2", stackFrames[2].Callable.FullName);
                    Assert.Equal(namespacePrefix + "AlwaysFail3", stackFrames[3].Callable.FullName);
                    Assert.Equal(namespacePrefix + "AlwaysFail4", stackFrames[4].Callable.FullName);

                    Assert.Equal(OperationFunctor.Controlled, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Controlled, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);
                    Assert.Equal(OperationFunctor.Adjoint, stackFrames[3].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[4].Callable.Variant);

                    Assert.Equal(14, stackFrames[2].FailedLineNumber);
                    Assert.Equal(21, stackFrames[4].FailedLineNumber);

                    // For Adjoint and Controlled we expect failedLineNumber to be equal to declarationStartLineNumber
                    Assert.Equal(stackFrames[0].DeclarationStartLineNumber, stackFrames[0].FailedLineNumber);
                    Assert.Equal(stackFrames[1].DeclarationStartLineNumber, stackFrames[1].FailedLineNumber);
                    Assert.Equal(stackFrames[3].DeclarationStartLineNumber, stackFrames[3].FailedLineNumber);

                    for (int i = 0; i < stackFrames.Length; ++i)
                    {
                        Assert.StartsWith(@"https://github.com/", stackFrames[i].GetURLFromPDB());
                        Assert.EndsWith($"#L{stackFrames[i].FailedLineNumber}", stackFrames[i].GetURLFromPDB());
                    }

                    StringBuilder builder = new StringBuilder();
                    builder.Append("13 ".PadLeft(PortablePDBEmbeddedFilesCache.lineNumberPaddingWidth));
                    builder.AppendLine("    operation AlwaysFail2() : Unit is Adj + Ctl {");
                    builder.Append("14 ".PadLeft(PortablePDBEmbeddedFilesCache.lineNumberPaddingWidth) + PortablePDBEmbeddedFilesCache.lineMarkPrefix);
                    builder.AppendLine("        Controlled AlwaysFail1(new Qubit[0],());");
                    builder.Append("15 ".PadLeft(PortablePDBEmbeddedFilesCache.lineNumberPaddingWidth));
                    builder.AppendLine("    }");
                    Assert.Equal(builder.ToString(), stackFrames[2].GetOperationSourceFromPDB());

                    for (int i = 0; i < stackFrames.Length; ++i)
                    {
                        output.WriteLine($"operation:{stackFrames[i].Callable.FullName}");
                        output.WriteLine(stackFrames[i].GetOperationSourceFromPDB());
                    }
                }
            }
        }

        [Fact]
        public void UrlMappingTest()
        {
            const string rawUrl = @"https://raw.githubusercontent.com/microsoft/qsharp-runtime/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs";
            const string expectedURL = @"https://github.com/microsoft/qsharp-runtime/blob/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs#L13";
            Assert.Equal(expectedURL, PortablePdbSymbolReader.TryFormatGitHubUrl(rawUrl, 13));
        }

    }
}