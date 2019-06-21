// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using System;
using System.Linq;
using Xunit;
using Microsoft.Quantum.Tests.Tuples;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class QTupleTests
    {
        [Fact]
        public void TupleEmptyConstructor()
        {
            var NullOrEmptyQubits = new Action<IApplyData>((t) =>
            {
                var qubits = t.Qubits;
                Assert.True(qubits == null || qubits?.Where(q => q != null).Count() == 0);
            });

            {
                var actual = new Q();
                Assert.Null(((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new I();
                Assert.Equal(0L, ((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleA();
                Assert.Equal(default((Int64, Pauli, Qubit, (Qubit, Int64, Qubit))), ((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleC();
                Assert.Equal(default((Qubit, TupleB)), ((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleD();
                Assert.Empty(((IApplyData)actual).Value as IQArray<Qubit>);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleE();
                Assert.Equal(default((Int64, IQArray<Qubit>)), ((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleF();
                Assert.Null(((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleH();
                Assert.Equal(default((TupleD, TupleG)), ((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleI();
                Assert.Null(((IApplyData)actual).Value);
                NullOrEmptyQubits(actual);
            }
            {
                var actual = new TupleJ();
                Assert.Empty(((IApplyData)actual).Value as IQArray<(Int64,Qubit)>);
                NullOrEmptyQubits(actual);
            }
        }

        [Fact]
        public void TupleBasicConstructor()
        {
            var AssertQubitsCount = new Action<int, IApplyData>((count, t) =>
            {
                var qubits = t.Qubits;
                if (count == 0)
                {
                    Assert.True(qubits == null || qubits?.Where(q => q != null).Count() == 0);
                } else
                {
                    Assert.Equal(count, qubits?.Where(q => q != null).Count());
                }
            });

            var q0 = new FreeQubit(0) as Qubit;
            var q1 = new FreeQubit(1) as Qubit;
            var q2 = new FreeQubit(2) as Qubit;

            {
                var actual = new Q(q0);
                Assert.Equal(q0, ((IApplyData)actual).Value);
                AssertQubitsCount(1, actual);
            }
            {
                var actual = new I(32L);
                Assert.Equal(32L, ((IApplyData)actual).Value);
                AssertQubitsCount(0, actual);
            }
            {
                var data = (2L, Pauli.PauliY, q1, (q0, -7L, null as Qubit));
                var actual = new TupleA(data);
                Assert.Equal(data, ((IApplyData)actual).Value);
                AssertQubitsCount(2, actual);
            }
            {
                var data = (q1, new TupleB(((2L, 3L), (q1, (4L, (q0, q2)), 3.0))));
                var actual = new TupleC(data);
                Assert.Equal(data, ((IApplyData)actual).Value);
                AssertQubitsCount(4, actual);
            }
            {
                var data = new QArray<Qubit>(q1, q2, q0, q0, q1);
                var actual = new TupleD(data);
                Assert.Equal((IQArray<Qubit>)data, ((IApplyData)actual).Value);
                AssertQubitsCount(5, actual);
            }
            {
                var data = (5L, new QArray<Qubit>(q1, q2, q0));
                var actual = new TupleE(data);
                Assert.Equal((data.Item1, (IQArray<Qubit>)data.Item2), ((IApplyData)actual).Value);
                AssertQubitsCount(3, actual);
            }
            {
                var data = new UnitaryNoOp<(TupleA, TupleD)>();
                var actual = new TupleF(data);
                Assert.Equal(data, ((IApplyData)actual).Value);
                AssertQubitsCount(0, actual);
            }
            {
                var op= new UnitaryNoOp<(TupleA, TupleD)>();
                var mapper = new Func<(TupleA, TupleD), (IQArray<Qubit>, (TupleA, TupleD))>((_arg) => (new QArray<Qubit>(q1, q2), _arg));
                var data = op.Controlled.Partial(mapper);
                var actual = new TupleF(data);
                Assert.Equal(data, ((IApplyData)actual).Value);
                AssertQubitsCount(2, actual);
            }
            {
                var data = (new TupleD(new QArray<Qubit>(q1, q2, q0)), new TupleG());
                var actual = new TupleH(data);
                Assert.Equal(data, ((IApplyData)actual).Value);
                AssertQubitsCount(3, actual);
            }
            {
                var data = new QArray<(Int64, Qubit)>((1L, q1));
                var actual = new TupleJ(data);
                Assert.Equal((IQArray<(Int64, Qubit)>)data, ((IApplyData)actual).Value);
                AssertQubitsCount(1, actual);
            }
        }

        private static void AssertOneData<T> (T expected, Type tupleType)
        {
            var d = Activator.CreateInstance(tupleType, expected) as IApplyData;

            Assert.NotNull(d);
            Assert.Equal(expected, d.Value);
            if (d is QTuple<T> tuple)
            {
                Assert.Equal(expected, tuple.Data);
            }
        }

        [Fact]
        public void UdtData()
        {
            var q0 = new FreeQubit(0) as Qubit;
            var q1 = new FreeQubit(1) as Qubit;
            var q2 = new FreeQubit(2) as Qubit;
            var q3 = new FreeQubit(3) as Qubit;
            var q4 = new FreeQubit(4) as Qubit;
            var q5 = new FreeQubit(5) as Qubit;
            var q6 = new FreeQubit(6) as Qubit;
            var op = new Op1(null)    as IUnitary;
            var f1 = new F1(null);
            var qubits = new QArray<Qubit>(q2, q4, q6);

            var dataA = (1L, Pauli.PauliY, q1, (q4, 3L, q5));
            var dataB = ((1L, 2L), (q6, (3L, (q4, q6)), 3.5));
            var dataC = (q5, new TupleB(dataB));
            var dataD = new QArray<Qubit>(q1, q2, q3, q4, q6);
            var dataE = (4L, (IQArray<Qubit>)qubits); // FIXME: [BH] CHECK IF THIS IS OK
            var dataF = op;
            var dataG = (q3, new TupleF(dataF), new TupleC(dataC), new TupleD(dataD));
            var dataQ = ((1L, 2L), (q1, (3L, (q2, q3)), 3.5));
            var dataH = (new TupleD(dataD), new TupleG(dataG));
            var dataI = f1;

            AssertOneData(dataQ, typeof(QTuple<((Int64, Int64), (Qubit, (Int64, (Qubit, Qubit)), Double))>));
            AssertOneData(((ICallable)null), typeof(QTuple<ICallable>));
            AssertOneData(q3, typeof(Q));
            AssertOneData(dataA, typeof(TupleA));
            AssertOneData(dataB, typeof(TupleB));
            AssertOneData(dataC, typeof(TupleC));
            AssertOneData(dataD, typeof(TupleD));
            AssertOneData(dataE, typeof(TupleE));
            AssertOneData(dataF, typeof(TupleF));
            AssertOneData(dataG, typeof(TupleG));
            AssertOneData(dataH, typeof(TupleH));
            AssertOneData(dataI, typeof(TupleI));
        }
    }
}
