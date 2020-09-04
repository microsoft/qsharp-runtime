// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Xunit;
using System.Linq;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    using TestTuple = ValueTuple<Result, (int, double), (int, (IUnitary, QArray<Qubit>)), Qubit>;
    
    public class PartialMapperTests
    {
        private class NoOp : Unitary<TestTuple>, ICallable
        {
            public NoOp(IOperationFactory m) : base(m) { }

            string ICallable.FullName => "NoOp";

            public override Func<TestTuple, QVoid> __Body__ => (a) => QVoid.Instance;

            public override void __Init__() { }
        }

        private void TestOneTupleNoSubstitution<I>(I original, params object[] expected)
        {
            var emptyQueue = new Stack<object>();
            var content = PartialMapper.GetTupleValues(original);
            var tuple = PartialMapper.Combine(content, emptyQueue);
            Assert.Equal(content, tuple);
        }

        [Fact]
        public void TupleNoSubstitutions() // substitutes nothing 
        {
            Qubit qubit = null;
            QArray<Qubit> qubits = new QArray<Qubit>();
            IUnitary<TestTuple> op = new NoOp(null);

            TestOneTupleNoSubstitution(QVoid.Instance);
            TestOneTupleNoSubstitution(1L, 1L);
            TestOneTupleNoSubstitution(qubit, qubit);
            TestOneTupleNoSubstitution(qubits, qubits);
            TestOneTupleNoSubstitution((1L, 2.0), 1L, 2.0);
            TestOneTupleNoSubstitution((1L, 2.0, Result.Zero), 1L, 2.0, Result.Zero);
            TestOneTupleNoSubstitution(((1L, 2.0), Result.Zero), 1L, 2.0, Result.Zero);
            TestOneTupleNoSubstitution(((1L, 2.0), (Result.Zero, qubit, qubits)), 1L, 2.0, Result.Zero, qubit, qubits);
            TestOneTupleNoSubstitution(((op, 4L, (1L, 2.0)), (Result.Zero, (op, qubits, qubit))), op, 4L, 1L, 2.0, Result.Zero, op, qubits, qubit);
        }

        private void TestOneMapping<I, A>(I expected, A args, object values)
        {
            var partial = PartialMapper.Create<A, I>(values);
            var actual = partial(args);
            Assert.Equal(expected, actual);
        }

        [Fact]
        public void PartialMapping()
        {
            Qubit qubit = null;
            QArray<Qubit> qubits = new QArray<Qubit>();
            NoOp op = new NoOp(null);

            var _ = AbstractCallable._;

            TestOneMapping(1, 1, _);
            TestOneMapping(op, op, _);
            TestOneMapping(qubit, qubit, _);
            TestOneMapping(QVoid.Instance, QVoid.Instance, _);
            TestOneMapping(1, QVoid.Instance, 1);
            TestOneMapping((1, op), op, (1, _));
            TestOneMapping((qubit, op), qubit, (_, op));
            TestOneMapping((qubit, op), (qubit, op), (_, _));
            TestOneMapping((qubit, op), (qubit, op), _);
            TestOneMapping((Result.One, 2.0, 3, qubit, op), (3, op), (Result.One, 2.0, _, qubit, _));

            var expected = (Result.One, (1, 2.0), (3, (op, qubits)), qubit);
            TestOneMapping(expected, QVoid.Instance, (Result.One, (1, 2.0), (3, (op, qubits)), qubit));
            TestOneMapping(expected, Result.One, (_, (1, 2.0), (3, (op, qubits)), qubit));
            TestOneMapping(expected, (Result.One, (1, 2.0)), (_, _, (3, (op, qubits)), qubit));
            TestOneMapping(expected, (Result.One, (3, (op, qubits))), (_, (1, 2.0), _, qubit));
            TestOneMapping(expected, (Result.One, qubit), (_, (1, 2.0), (3, (op, qubits)), _));
            TestOneMapping(expected, qubit, (Result.One, (1, 2.0), (3, (op, qubits)), _));
            TestOneMapping(expected, (1, 2.0), (Result.One, _, (3, (op, qubits)), qubit));
            TestOneMapping(expected, ((1, 2.0), qubit), (Result.One, _, (3, (op, qubits)), _));
            TestOneMapping(expected, (3, (op, qubits)), (Result.One, (1, 2.0), _, qubit));
            TestOneMapping(expected, ((1, 2.0), (3, (op, qubits))), (Result.One, _, _, qubit));
            TestOneMapping(expected, 2.0, (Result.One, (1, _), (3, (op, qubits)), qubit));
            TestOneMapping(expected, (Result.One, 2.0, op), (_, (1, _), (3, (_, qubits)), qubit));
            TestOneMapping(expected, ((1, 2.0), (3, qubits)), (Result.One, _, (_, (op, _)), qubit));
            TestOneMapping(expected, expected, (_, _, _, _));
            TestOneMapping((expected, expected), expected, (expected, _));
            TestOneMapping((1, 2, (3, 4)), (2, 4), (1, _, (3, _)));
            TestOneMapping((1, (2.1,2.2), (3, 4)), ((2.1,2.2), 4), (1, _, (3, _)));
            TestOneMapping((1, (2.1, 2.2), (3, (4.1,4.2))), ((2.1, 2.2), (4.1,4.2)), (1, _, (3, _)));
        }

        private void TestOnePartialType(Type expected, Type original, object partial)
        {
            var actual = Operation<object,object>.FindPartialType(original, partial);
            Assert.Equal(expected, actual);
        }

        [Fact]
        public void FindPartialType()
        {
            Qubit qubit = new TestQubit();
            QArray<Qubit> qubits = new QArray<Qubit>();
            IUnitary<TestTuple> op = new NoOp(null);

            var _ = AbstractCallable._;

            TestOnePartialType(typeof(QVoid), typeof(long), 1L);
            TestOnePartialType(typeof(long), typeof(long), _);
            TestOnePartialType(typeof(IUnitary), typeof(IUnitary<TestTuple>), _);
            TestOnePartialType(typeof(Qubit), typeof(TestQubit), _);
            TestOnePartialType(typeof(QVoid), typeof(QVoid), _);

            TestOnePartialType(typeof(IUnitary), (1, op).GetType(), (1, _));
            TestOnePartialType(typeof(Qubit), (qubit, op).GetType(), (_, op));

            TestOnePartialType(typeof(ValueTuple<Qubit, IUnitary>), (qubit, op).GetType(), (_, _));
            TestOnePartialType(typeof(IUnitary), (qubit, op).GetType(), (qubit, _));
            TestOnePartialType(typeof(Qubit), (qubit, 1L, op).GetType(), (_, 1L, op));
            TestOnePartialType(typeof(ValueTuple<Int64, IUnitary>), (Result.One, 2.0, 3L, qubit, op).GetType(), (Result.One, 2.0, _, qubit, _));

            var original = (Result.One, (1L, 2.0), (3L, (op, qubits)));
            TestOnePartialType(typeof(QVoid), original.GetType(), (Result.One, (1L, 2.0), (3L, (op, qubits))));
            TestOnePartialType(typeof(Result), original.GetType(), (_, (1L, 2.0), (3L, (op, qubits))));
            TestOnePartialType(typeof(ValueTuple<Result, long, long>), original.GetType(), (_, (_, 2.0), (_, (op, qubits))));
            TestOnePartialType(typeof(ValueTuple<long, double>), original.GetType(), (Result.One, _, (3L, (op, qubits))));
            TestOnePartialType(typeof(ValueTuple<long, double>), original.GetType(), (Result.One, (_, _), (3L, (op, qubits))));
            TestOnePartialType(typeof(ValueTuple<long, QArray<Qubit>>), original.GetType(), (Result.One, (1L, 2.0), (_, (op, _))));
            TestOnePartialType(typeof(ValueTuple<Result, ValueTuple<long, IUnitary>>), original.GetType(), (_, (1L, 2.0), (_, (_, qubits))));
        }

        private void TestOneMappingError<I, A, E>(A args, object values) where E : Exception
        {
            var partial = PartialMapper.Create<A, I>(values);
            Assert.Throws<E>(() => partial(args));
        }

        [Fact]
        public void PartialMappingErrors()
        {
            Qubit qubit = null;
            QArray<Qubit> qubits = new QArray<Qubit>();
            NoOp op = new NoOp(null);

            var _ = AbstractCallable._;
            var expected = (Result.One, (1, 2.0), (3, (op, qubits)), qubit);

            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                // If too many parameters, are ignored:
                TestOneMapping(expected, Result.One, (Result.One, (1, 2.0), (3, (op, qubits)), qubit));
                
                // Parameters mismatch
                TestOneMappingError<TestTuple, (double, double), MissingMethodException>((2.0, 3.0), (Result.One, _, (3, (op, qubits)), qubit)); 
                TestOneMappingError<TestTuple, int, MissingMethodException>(1, (_, (1, 2.0), (3, (op, qubits)), qubit)); 
                TestOneMappingError<TestTuple, int, MissingMethodException>(1, (Result.One, _, (3, (op, qubits)), qubit));
                //TestOneMapping((1, 2, (3, 4)), (2, 4), (1, new MissingParameter(typeof((int,int))), (3, _))); 
               
                // Too little parameters
                TestOneMappingError<TestTuple, Result, InvalidOperationException>(Result.One, (_, _, (3, (op, qubits)), qubit));

                // Both, parameters mismatch and too little parameters
                TestOneMappingError<TestTuple, int, InvalidOperationException>(1, (_, _, (3, (op, qubits)), qubit)); 
            });
        }
    }
}
