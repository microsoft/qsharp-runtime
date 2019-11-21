// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Xunit;

using System;
using System.Threading.Tasks;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Xunit.Abstractions;
using System.Text;

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
        public void AlwaysFail4Test()
        {
            ToffoliSimulator sim = new ToffoliSimulator();
            StackTraceCollector sc = new StackTraceCollector(sim);
            ICallable op = sim.Get<ICallable, AlwaysFail4>();
            try
            {
                QVoid res = op.Apply<QVoid>(QVoid.Instance);
            }
            catch (ExecutionFailException)
            {
                StackFrame[] stackFrames = sc.CallStack;

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

                for( int i = 0; i < stackFrames.Length; ++i )
                {
                    output.WriteLine($"operation:{stackFrames[i].Callable.FullName}");
                    output.WriteLine(stackFrames[i].GetOperationSourceFromPDB());
                }
            }
        }

        [Fact]
        public void GenericFail1Test()
        {
            ToffoliSimulator sim = new ToffoliSimulator();

            {
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, GenericFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, GenericAdjFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, GenericCtlFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, PartialFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, PartialAdjFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
                StackTraceCollector sc = new StackTraceCollector(sim);
                ICallable op = sim.Get<ICallable, PartialCtlFail1>();
                try
                {
                    QVoid res = op.Apply<QVoid>(QVoid.Instance);
                }
                catch (ExecutionFailException)
                {
                    StackFrame[] stackFrames = sc.CallStack;

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
            sim.EnableStackTrace();
            StringBuilder stringBuilder = new StringBuilder();
            sim.OnLog += (msg) => stringBuilder.AppendLine(msg);
            try
            {
                QVoid res = sim.Execute<AlwaysFail4, QVoid, QVoid>(QVoid.Instance);
            }
            catch (ExecutionFailException)
            {
            }
            output.WriteLine(stringBuilder.ToString());
        }
    }
}