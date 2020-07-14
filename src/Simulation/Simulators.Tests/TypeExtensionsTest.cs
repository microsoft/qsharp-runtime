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

    public class GetNonQubitArgumentsTests
    {
        [Fact]
        public void BasicTypes()
        {
            Assert.Equal("3", 3.GetNonQubitArguments());
            Assert.Equal("False", false.GetNonQubitArguments());
            Assert.Equal("\"Foo\"", "Foo".GetNonQubitArguments());
            Assert.Equal("\"\"", "".GetNonQubitArguments());
        }

        [Fact]
        public void TupleTypes()
        {
            Assert.Equal("(1, 2)", (1, 2).GetNonQubitArguments());
            Assert.Equal("(\"foo\", \"bar\")", ("foo", "bar").GetNonQubitArguments());
            Assert.Equal("(\"foo\", \"bar\", \"\")", ("foo", "bar", "").GetNonQubitArguments());
            Assert.Equal("(\"foo\", (\"bar\", \"car\"))", ("foo", ("bar", "car")).GetNonQubitArguments());
            Assert.Equal("((\"foo\"), (\"bar\", \"car\"))", (("foo", new FreeQubit(0)), ("bar", "car")).GetNonQubitArguments());
        }

        [Fact]
        public void ArrayTypes()
        {
            Assert.Equal("[1, 2, 3]", new[] { 1, 2, 3 }.GetNonQubitArguments());
            Assert.Equal("[\"foo\", \"bar\"]", new[] { "foo", "bar" }.GetNonQubitArguments());

            var arr = new[] {
                (new FreeQubit(0), "foo"),
                (new FreeQubit(1), "bar"),
            };
            Assert.Equal("[(\"foo\"), (\"bar\")]", arr.GetNonQubitArguments());
        }

        [Fact]
        public void IApplyDataTypes()
        {
            IApplyData data;
            data = new ApplyData<int>(3);
            Assert.Equal("3", data.GetNonQubitArguments());

            data = new ApplyData<bool>(false);
            Assert.Equal("False", data.GetNonQubitArguments());

            data = new ApplyData<string>("Foo");
            Assert.Equal("\"Foo\"", data.GetNonQubitArguments());

            data = new ApplyData<ValueTuple<int, string>>((1, "foo"));
            Assert.Equal("(1, \"foo\")", data.GetNonQubitArguments());

            data = new ApplyData<ValueTuple<ValueTuple<string, Qubit>, ValueTuple<string, string>>>((("foo", new FreeQubit(0)), ("bar", "car")));
            Assert.Equal("((\"foo\"), (\"bar\", \"car\"))", data.GetNonQubitArguments());

            data = new ApplyData<int[]>(new[] { 1, 2, 3 });
            Assert.Equal("[1, 2, 3]", data.GetNonQubitArguments());

            var arr = new[] {
                (new FreeQubit(0), "foo"),
                (new FreeQubit(1), "bar"),
            };
            data = new ApplyData<(FreeQubit, string)[]>(arr);
            Assert.Equal("[(\"foo\"), (\"bar\")]", data.GetNonQubitArguments());
        }
    }
}
