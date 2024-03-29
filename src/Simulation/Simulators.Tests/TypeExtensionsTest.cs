// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class ApplyData<T> : IApplyData
    {
        public T Data;

        public ApplyData(T data)
        {
            this.Data = data;
        }

        object IApplyData.Value => this.Data;

        IEnumerable<Qubit> IApplyData.Qubits => QubitsExtractor.Get(typeof(T))?.Extract(Data);
    }

    public class GetNonQubitArgumentsAsStringTests : SimulatorFactoryProvider
    {
        [Fact]
        public void BasicTypes()
        {
            Assert.Equal("3", 3.GetNonQubitArgumentsAsString());
            Assert.Equal("False", false.GetNonQubitArgumentsAsString());
            Assert.Equal("\"Foo\"", "Foo".GetNonQubitArgumentsAsString());
            Assert.Equal("\"\"", "".GetNonQubitArgumentsAsString());
        }

        [Fact]
        public void OperationTypes()
        {
            foreach(var factory in simulatorFactories)
            {
                var sim1 = factory();
                var sim2 = factory();

                try
                {
                    var op = sim1.Get<Intrinsic.H>();
                    Assert.Equal("H", op.GetNonQubitArgumentsAsString());

                    var op2 = sim2.Get<Intrinsic.CNOT>();
                    Assert.Equal("CNOT", op2.GetNonQubitArgumentsAsString());            
                }
                finally
                {
                    sim2.Dispose();
                    sim1.Dispose();
                }
            }
        }

        [Fact]
        public void QubitTypes()
        {
            var q = new FreeQubit(0);
            Assert.Null(q.GetNonQubitArgumentsAsString());

            var qs = new QArray<Qubit>(new[] { new FreeQubit(0) });
            Assert.Null(qs.GetNonQubitArgumentsAsString());

            qs = new QArray<Qubit>(new[] { new FreeQubit(0), new FreeQubit(1) });
            Assert.Null(qs.GetNonQubitArgumentsAsString());

            var qtuple = new QTuple<Qubit>(q);
            Assert.Null(qtuple.GetNonQubitArgumentsAsString());
        }

        [Fact]
        public void TupleTypes()
        {
            Assert.Equal("(1, 2)", (1, 2).GetNonQubitArgumentsAsString());
            Assert.Equal("(\"foo\", \"bar\")", ("foo", "bar").GetNonQubitArgumentsAsString());
            Assert.Equal("(\"foo\", \"bar\", \"\")", ("foo", "bar", "").GetNonQubitArgumentsAsString());
            Assert.Equal("(\"foo\", (\"bar\", \"car\"))", ("foo", ("bar", "car")).GetNonQubitArgumentsAsString());
            Assert.Equal("((\"foo\"), (\"bar\", \"car\"))", (("foo", new FreeQubit(0)), ("bar", "car")).GetNonQubitArgumentsAsString());

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var op = sim.Get<Intrinsic.H>();
                    var opTuple = new QTuple<(ICallable, string)>((op, "foo"));
                    Assert.Equal("(H, \"foo\")", opTuple.GetNonQubitArgumentsAsString());
                }
                finally
                {
                    sim.Dispose();
                }
            }

            var qtuple = new QTuple<(Qubit, string)>((new FreeQubit(0), "foo"));
            Assert.Equal("(\"foo\")", qtuple.GetNonQubitArgumentsAsString());
        }

        [Fact]
        public void ArrayTypes()
        {
            Assert.Equal("[1, 2, 3]", new[] { 1, 2, 3 }.GetNonQubitArgumentsAsString());
            Assert.Equal("[\"foo\", \"bar\"]", new[] { "foo", "bar" }.GetNonQubitArgumentsAsString());

            foreach (var factory in simulatorFactories)
            {
                var sim1 = factory();
                var sim2 = factory();
                var sim3 = factory();
                try
                {
                    var opArr = new ICallable[] {
                        sim1.Get<Intrinsic.H>(),
                        sim2.Get<Intrinsic.CNOT>(),
                        sim3.Get<Intrinsic.Ry>(),
                    };

                    Assert.Equal("[H, CNOT, Ry]", opArr.GetNonQubitArgumentsAsString());
                }
                finally
                {
                    sim3.Dispose();
                    sim2.Dispose();
                    sim1.Dispose();
                }
            }

            var qTupleArr = new[] {
                (new FreeQubit(0), "foo"),
                (new FreeQubit(1), "bar"),
            };
            Assert.Equal("[(\"foo\"), (\"bar\")]", qTupleArr.GetNonQubitArgumentsAsString());

            var qArrayBool = new QArray<Boolean>(new[] { false, true });
            Assert.Equal("[False, True]", qArrayBool.GetNonQubitArgumentsAsString());
        }

        [Fact]
        public void IApplyDataTypes()
        {
            IApplyData data;
            data = new ApplyData<int>(3);
            Assert.Equal("3", data.GetNonQubitArgumentsAsString());

            data = new ApplyData<bool>(false);
            Assert.Equal("False", data.GetNonQubitArgumentsAsString());

            data = new ApplyData<string>("Foo");
            Assert.Equal("\"Foo\"", data.GetNonQubitArgumentsAsString());

            var simulators = new CommonNativeSimulator[] { 
                new QuantumSimulator(),
                new SparseSimulator()
            };

            foreach (var sim in simulators)
            {
                try
                {
                    var op = sim.Get<Intrinsic.H>();
                    data = new ApplyData<ICallable>(op);
                    Assert.Equal("H", data.GetNonQubitArgumentsAsString());
                }
                finally
                {
                    sim.Dispose();
                }
            }

            data = new ApplyData<ValueTuple<int, string>>((1, "foo"));
            Assert.Equal("(1, \"foo\")", data.GetNonQubitArgumentsAsString());

            data = new ApplyData<ValueTuple<ValueTuple<string, Qubit>, ValueTuple<string, string>>>((("foo", new FreeQubit(0)), ("bar", "car")));
            Assert.Equal("((\"foo\"), (\"bar\", \"car\"))", data.GetNonQubitArgumentsAsString());

            data = new ApplyData<int[]>(new[] { 1, 2, 3 });
            Assert.Equal("[1, 2, 3]", data.GetNonQubitArgumentsAsString());

            var arr = new[] {
                (new FreeQubit(0), "foo"),
                (new FreeQubit(1), "bar"),
            };
            data = new ApplyData<(FreeQubit, string)[]>(arr);
            Assert.Equal("[(\"foo\"), (\"bar\")]", data.GetNonQubitArgumentsAsString());

            var qtupleWithString = new QTuple<(Qubit, string)>((new FreeQubit(0), "foo"));
            data = new ApplyData<QTuple<(Qubit, string)>>(qtupleWithString);
            Assert.Equal("(\"foo\")", data.GetNonQubitArgumentsAsString());

            var q = new FreeQubit(0);
            data = new ApplyData<Qubit>(q);
            Assert.Null(data.GetNonQubitArgumentsAsString());

            var qs = new QArray<Qubit>(new[] { new FreeQubit(0), new FreeQubit(1) });
            data = new ApplyData<IQArray<Qubit>>(qs);
            Assert.Null(data.GetNonQubitArgumentsAsString());

            var qtuple = new QTuple<Qubit>(q);
            data = new ApplyData<QTuple<Qubit>>(qtuple);
            Assert.Null(data.GetNonQubitArgumentsAsString());
        }
    }
}
