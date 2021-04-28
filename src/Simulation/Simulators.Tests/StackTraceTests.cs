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

                // TODO: The following change -
                //   https://github.com/microsoft/qsharp-runtime/pull/650/files#diff-80e206c7d2a40d77626cd9584ef57d062d3ee7ba01fdc3cc9ca88f7f017dff96 -
                //   (`AssertMeasurement()` body calls the `AssertMeasurementProbability(bases, qubits, result, 1.0, msg, 1e-10)`)
                //   causes the assert below to fail. The issue in the generator of the stack frames is suspected.
                //   Deeper analysis is needed.
                //Assert.Equal(94, stackFrames[1].FailedLineNumber);
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
        public void GenericFail1Test()
        {
            ResourcesEstimator sim = new ResourcesEstimator();

            {
                try
                {
                    QVoid res = sim.Execute<GenericFail1, QVoid, QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Body, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(7, stackFrames[0].FailedLineNumber);
                    Assert.Equal(25, stackFrames[1].FailedLineNumber);
                    Assert.Equal(29, stackFrames[2].FailedLineNumber);
                }
            }

            {
                try
                {
                    QVoid res = sim.Execute<GenericAdjFail1, QVoid, QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericAdjFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Adjoint, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Adjoint, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(6, stackFrames[0].FailedLineNumber);
                    Assert.Equal(24, stackFrames[1].FailedLineNumber);
                    Assert.Equal(52, stackFrames[2].FailedLineNumber);
                }
            }

            {
                try
                {
                    QVoid res = sim.Execute<GenericCtlFail1, QVoid, QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "GenericCtlFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Controlled, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Controlled, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(6, stackFrames[0].FailedLineNumber);
                    Assert.Equal(24, stackFrames[1].FailedLineNumber);
                    Assert.Equal(56, stackFrames[2].FailedLineNumber);
                }
            }
        }
        
        [Fact]
        public void PartialFail1Test()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            {
                try
                {
                    QVoid res = PartialFail1.Run(sim).Result;
                }
                catch (AggregateException ex)
                {
                    Assert.True(ex.InnerException is ExecutionFailException);
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Body, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(7, stackFrames[0].FailedLineNumber);
                    Assert.Equal(33, stackFrames[1].FailedLineNumber);
                    Assert.Equal(38, stackFrames[2].FailedLineNumber);
                }
            }

            {
                try
                {
                    QVoid res = PartialAdjFail1.Run(sim).Result;
                }
                catch (AggregateException ex)
                {
                    Assert.True(ex.InnerException is ExecutionFailException);
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialAdjFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Adjoint, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Adjoint, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(6, stackFrames[0].FailedLineNumber);
                    Assert.Equal(32, stackFrames[1].FailedLineNumber);
                    Assert.Equal(43, stackFrames[2].FailedLineNumber);
                }
            }

            {
                try
                {
                    QVoid res = PartialCtlFail1.Run(sim).Result;
                }
                catch (AggregateException ex)
                {
                    Assert.True(ex.InnerException is ExecutionFailException);
                    StackFrame[] stackFrames = sim.CallStack;

                    Assert.Equal(3, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "AlwaysFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "PartialCtlFail1", stackFrames[2].Callable.FullName);

                    Assert.Equal(OperationFunctor.Controlled, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Controlled, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);

                    Assert.Equal(6, stackFrames[0].FailedLineNumber);
                    Assert.Equal(32, stackFrames[1].FailedLineNumber);
                    Assert.Equal(48, stackFrames[2].FailedLineNumber);
                }
            }
        }

        [Fact]
        public void RecursionFail1Test()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            {
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, RecursionFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

                    Assert.Equal(4, stackFrames.Length);

                    Assert.Equal(namespacePrefix + "RecursionFail", stackFrames[0].Callable.FullName);
                    Assert.Equal(namespacePrefix + "RecursionFail", stackFrames[1].Callable.FullName);
                    Assert.Equal(namespacePrefix + "RecursionFail", stackFrames[2].Callable.FullName);
                    Assert.Equal(namespacePrefix + "RecursionFail1", stackFrames[3].Callable.FullName);

                    Assert.Equal(OperationFunctor.Body, stackFrames[0].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[1].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[2].Callable.Variant);
                    Assert.Equal(OperationFunctor.Body, stackFrames[3].Callable.Variant);

                    Assert.Equal(70, stackFrames[0].FailedLineNumber);
                    Assert.Equal(66, stackFrames[1].FailedLineNumber);
                    Assert.Equal(66, stackFrames[2].FailedLineNumber);
                    Assert.Equal(75, stackFrames[3].FailedLineNumber);
                }
            }
        }

        [Fact]
        public void DivideByZeroTest()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            try
            {
                sim.Execute<DivideBy0, QVoid, long>(QVoid.Instance);
            }
            catch (Exception)
            {
                StackFrame[] stackFrames = sim.CallStack;

                Assert.Single(stackFrames);
                Assert.Equal(namespacePrefix + "DivideBy0", stackFrames[0].Callable.FullName);
            }
        }

        [Fact]
        public void AllGoodTest()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            QVoid res = sim.Execute<AllGood1, QVoid, QVoid>(QVoid.Instance);
            StackFrame[] stackFrames = sim.CallStack;
            Assert.Null(stackFrames);
        }

        [Fact]
        public void UrlMappingTest()
        {
            const string rawUrl = @"https://raw.githubusercontent.com/microsoft/qsharp-runtime/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs";
            const string expectedURL = @"https://github.com/microsoft/qsharp-runtime/blob/af6262c05522d645d0a0952272443e84eeab677a/src/Xunit/TestCaseDiscoverer.cs#L13";
            Assert.Equal(expectedURL, PortablePdbSymbolReader.TryFormatGitHubUrl(rawUrl, 13));
        }

        [Fact]
        public void ErrorLogTest()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            var logs = new List<string>();
            sim.OnLog += (msg) => logs.Add(msg);
            try
            {
                QVoid res = sim.Execute<AlwaysFail4, QVoid, QVoid>(QVoid.Instance);
            }
            catch (ExecutionFailException)
            {
                Assert.Equal(7, logs.Count);
                Assert.StartsWith("Unhandled exception. Microsoft.Quantum.Simulation.Core.ExecutionFailException: Always fail", logs[0]);
                Assert.StartsWith(" ---> Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.AlwaysFail", logs[1]);
                Assert.StartsWith("   at Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.AlwaysFail1 on", logs[2]);
                Assert.StartsWith("   at Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.AlwaysFail2 on", logs[3]);
                Assert.StartsWith("   at Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.AlwaysFail3 on", logs[4]);
                Assert.StartsWith("   at Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.AlwaysFail4 on", logs[5]);
                Assert.Equal("", logs[6]);
            }

            logs.Clear();
            sim.EnableStackTracePrinting = false;
            try
            {
                QVoid res = sim.Execute<AlwaysFail4, QVoid, QVoid>(QVoid.Instance);
            }
            catch (ExecutionFailException)
            {
                Assert.Equal(2, logs.Count);
                Assert.StartsWith("Unhandled exception. Microsoft.Quantum.Simulation.Core.ExecutionFailException: Always fail", logs[0]);
                Assert.Equal("", logs[1]);
            }
        }
    }
}