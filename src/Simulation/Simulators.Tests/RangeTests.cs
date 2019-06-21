// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Tests.CoreOperations;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    using Helper = Microsoft.Quantum.Simulation.Simulators.Tests.OperationsTestHelper;

    public class RangeTests
    {
        [Fact]
        public void RangeConstructor()
        {
            // The SimulatorBase class only implements operations for Qubit management,
            // i.e. Allocate/Release:
            var subject = new Range(1, 5, 10);

            Assert.Equal(1, subject.Start);
            Assert.Equal(5, subject.Step);
            Assert.Equal(10, subject.End);

            subject = new Range(10, -5, 0);

            Assert.Equal(10, subject.Start);
            Assert.Equal(-5, subject.Step);
            Assert.Equal(0, subject.End);
        }

        [Fact]
        public void RangeSamples()
        {
            var subject = new Range(1, 3);
            var expected = new long[] { 1, 2, 3 };
            Assert.Equal(expected, subject);

            subject = new Range(2, 2, 5);
            expected = new long[] { 2, 4 };
            Assert.Equal(expected, subject);

            subject = new Range(2, 2, 5);
            expected = new long[] { 2, 4 };
            Assert.Equal(expected, subject);

            subject = new Range(2, 2, 6);
            expected = new long[] { 2, 4, 6 };
            Assert.Equal(expected, subject);

            subject = new Range(6, -2, 2);
            expected = new long[] { 6, 4, 2 };
            Assert.Equal(expected, subject);

            subject = new Range(2, 6, 7);
            expected = new long[] { 2 };
            Assert.Equal(expected, subject);

            subject = new Range(-1, 2, 10);
            expected = new long[] { -1, 1, 3, 5, 7, 9 };
            Assert.Equal(expected, subject);

            subject = new Range(-1, -1, -5);
            expected = new long[] { -1, -2, -3, -4, -5 };
            Assert.Equal(expected, subject);

            subject = new Range(1, 1);
            expected = new long[] { 1 };
            Assert.Equal(expected, subject);
        }

        [Fact]
        public void EmptyRangeSamples()
        {
            var subject = new Range(2, 2, 1);
            Assert.Empty(subject);
            Assert.Empty(subject.Reverse());

            subject = new Range(2, 1);
            Assert.Empty(subject);
            Assert.Empty(subject.Reverse());

            subject = new Range(1, -1, 2);
            Assert.Empty(subject);
            Assert.Empty(subject.Reverse());

            subject = new Range(1, 2, 0);
            Assert.Empty(subject);
            Assert.Empty(subject.Reverse());
        }

        [Fact]
        public void InvalidRangeStep()
        {
            Assert.Throws<ArgumentException>("step", () => { new Range(1, 0, 10); });
        }

        [Fact]
        public void RangeIteration()
        {
            var subject = new Range(6, -2, 2);
            var expected = new long[] { 6, 4, 2 };
            var actual = new List<long>();

            foreach (var i in subject)
            {
                actual.Add(i);
            }
            Assert.Equal(expected, actual);

            actual = new List<long>();
            foreach (var j in new Range(6, -(2L), 2))
            {
                actual.Add(j);
            }
            Assert.Equal(expected, actual);
        }

        [Fact]
        public void RangeReversal()
        {
            var subject = new Range(6, -2, 2);
            var expected = new Range(2, 2, 6);
            Assert.Equal(expected, subject.Reverse());

            subject = new Range(1, 1, 0);
            expected = new Range(0, -1, 1);
            Assert.Equal(expected, subject.Reverse());

            subject = new Range(1, 2, 2);
            expected = new Range(1, -2, 1);
            Assert.Equal(expected, subject.Reverse());
        }

        [Fact]
        public void SimpleRange()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                IgnorableAssert.Disable();
                try
                {
                    //We have to call the method in the same tread for IgnorableAssert.Disable() to work 
                    s.Get<SimpleRangeTest>().Apply(QVoid.Instance);
                }
                finally
                {
                    IgnorableAssert.Enable();
                }

                var tracer = s.GetTracer<long>();

                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (0L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (1L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (2L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (3L)));
                    Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (4L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (5L)));
                    Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (6L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (7L)));
                    Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (8L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (9L)));
                    Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (10L)));
                    Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, (11L)));

            });
        }
    }
}
