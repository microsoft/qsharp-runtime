// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Tests.Tuples;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    internal class FreeQubit : Qubit
    {
        public FreeQubit(int id) : base(id)
        {
        }
    }

    internal class UnitaryNoOp<TInput> : Unitary<TInput>, ICallable
    {
        public UnitaryNoOp() : base(null) { }

        public override void Init() { }

        public override Func<(IQArray<Qubit>, TInput), QVoid> ControlledAdjointBody => (arg) =>
        {
            Debug.Write("NoOp:ControlledAdjointBody:" + typeof(TInput).FullName);
            return QVoid.Instance;
        };

        public override Func<TInput, QVoid> AdjointBody => (arg) =>
        {
            Debug.Write("NoOp:AdjointBody:" + typeof(TInput).FullName);
            return QVoid.Instance;
        };

        public override Func<(IQArray<Qubit>, TInput), QVoid> ControlledBody => (arg) =>
        {
            Debug.Write("NoOp:ControlledBody:" + typeof(TInput).FullName);
            return QVoid.Instance;
        };

        public override Func<TInput, QVoid> Body => (TInput arg) =>
        {
            Debug.Write("NoOp:Body:" + typeof(TInput).FullName);
            return QVoid.Instance;
        };

        string ICallable.FullName => "UnitaryNoOp";
    }

    public class GetQubitsTests
    {
        int GetQubitsCount(object val)
        {
            var v = val.GetQubits();
            if (v == null) { return 0; }
            return v.Count();
        }

        [Fact]
        public void QubitFreeTypes()
        {
            Assert.Null((Pauli.PauliI as object).GetQubits());
            Assert.Null((OperationFunctor.Body as object).GetQubits());

            var x1 = new QRange(0, 1);
            Assert.Null((x1 as object).GetQubits());

            var tpl1 = (1, 1, (1.2, new QRange(0, 1)));
            Assert.Null((tpl1 as object).GetQubits());

            var tpl2 = (1, new int[] { 1, 2 });
            Assert.Null((tpl2 as object).GetQubits());

            var tpl3 = (1, 1, 1);
            Assert.Null((tpl3 as object).GetQubits());

            var tpl4 = (1, 1, 1, 1);
            Assert.Null((tpl4 as object).GetQubits());

            var tpl5 = (1, 1, 1, 1, 1);
            Assert.Null((tpl5 as object).GetQubits());

            var tpl6 = (1, 1, 1, 1, 1, 1);
            Assert.Null((tpl6 as object).GetQubits());

            var tpl7 = (1, 1, 1, 1, 1, 1, 1);
            Assert.Null((tpl7 as object).GetQubits());

            var tpl8 = (1, 1, 1, 1, 1, 1, 1, 1);
            Assert.Null((tpl8 as object).GetQubits());

            var tpl9 = (1, 1, 1, 1, 1, 1, 1, 1, 1);
            Assert.Null((tpl9 as object).GetQubits());

            var e1 = new int[][] { new int[] { 1 }, new int[] { 2, 3 } };
            Assert.Null((e1 as object).GetQubits());
        }

        static IQArray<Qubit> FreeQubitsRange(int start, int length)
        {
            var ids = Enumerable.Range(start, length);
            return new QArray<Qubit>(ids.Select(id => new FreeQubit(id))); 
        }

        static IQArray<(T, Qubit)> FreeQubitsTuplesRange<T>(int start, int length)
        {
            var ids = Enumerable.Range(start, length);
            var items = ids.Select(id => (default(T), (Qubit) new FreeQubit(id))); 
            return new QArray<(T, Qubit)>(items);
        }

        [Fact]
        public void TypesWithQubits()
        {
            var tpl2 = (new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(2, GetQubitsCount(tpl2));

            var tpl3 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(3, GetQubitsCount(tpl3));

            var tpl4 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(4, GetQubitsCount(tpl4));

            var tpl5 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(5, GetQubitsCount(tpl5));

            var tpl6 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(6, GetQubitsCount(tpl6));

            var tpl7 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(7, GetQubitsCount(tpl7));

            var tpl8 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(8, GetQubitsCount(tpl8));

            var tpl9 = (new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0), new FreeQubit(0));
            Assert.Equal(9, GetQubitsCount(tpl9));

            var rng2 = FreeQubitsTuplesRange<(int, int, double)>(0, 10);
            Assert.Equal(rng2.Length, GetQubitsCount(rng2));

            var rng5 = FreeQubitsRange(0, 10);
            Assert.Equal(rng5.Length, GetQubitsCount(rng5));
        }

        void AssertAllFunctorsHaveNoQubitsCaptured(IUnitary op)
        {
            var AssertNullOrEmpty = new System.Action<Qubit[]>((qubits) =>
            {
                Assert.True(qubits == null || qubits.Length == 0);
            });

            AssertNullOrEmpty(op.GetQubits()?.ToArray());
            AssertNullOrEmpty(op.Controlled.GetQubits()?.ToArray());
            AssertNullOrEmpty(op.Adjoint.GetQubits()?.ToArray());
            AssertNullOrEmpty(op.Controlled.Adjoint.GetQubits()?.ToArray());
        }

        void AssertAllFunctorsHaveQubitsCaptured(IUnitary op, int numberOfQubits)
        {
            Assert.Equal(numberOfQubits, GetQubitsCount(op));
            Assert.Equal(numberOfQubits, GetQubitsCount(op.Controlled));
            Assert.Equal(numberOfQubits, GetQubitsCount(op.Adjoint));
            Assert.Equal(numberOfQubits, GetQubitsCount(op.Adjoint.Controlled));
        }

        [Fact]
        public void TypesWithClosures()
        {
            {
                var op1 = new UnitaryNoOp<(int, int, int)>() as IUnitary<(int, int, int)>;
                var partialOp1 = op1.Partial((AbstractCallable._, AbstractCallable._, 3));
                var partialOp3 = partialOp1.Partial((AbstractCallable._, 3));

                AssertAllFunctorsHaveNoQubitsCaptured(partialOp1);
                AssertAllFunctorsHaveNoQubitsCaptured(partialOp3);
                AssertAllFunctorsHaveNoQubitsCaptured(op1);
            }
            {
                var op2 = new UnitaryNoOp<(int, int, Qubit)>() as IUnitary<(int, int, Qubit)>;
                var partialOp2 = op2.Partial((AbstractCallable._, AbstractCallable._, new FreeQubit(0)));

                AssertAllFunctorsHaveQubitsCaptured(partialOp2, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op2);
            }
            {
                var op3 = new UnitaryNoOp<(int, Qubit, Qubit)>() as IUnitary<(int, Qubit, Qubit)>;
                var partialOp4 = op3.Partial((AbstractCallable._, AbstractCallable._, new FreeQubit(0)));

                AssertAllFunctorsHaveQubitsCaptured(partialOp4, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op3);

                var partialOp5 = partialOp4.Partial((AbstractCallable._, new FreeQubit(1)));
                AssertAllFunctorsHaveQubitsCaptured(partialOp5, 2);
            }
            {
                var _ = AbstractCallable._;
                var q0 = new FreeQubit(0);
                var q1 = new FreeQubit(1);
                var q2 = new FreeQubit(2);
                var q3 = new FreeQubit(3);
                var q4 = new FreeQubit(4);
                var q5 = new FreeQubit(5);
                var qArray = new QArray<Qubit>(q4, q5);

                var op = new UnitaryNoOp<(int, (Qubit, Qubit, Qubit), QArray<Qubit>)>() as IUnitary<(int, (Qubit, Qubit, Qubit), QArray<Qubit>)>;
                var p1 = op.Partial((_, (_, q1, _), _));

                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);

                var p2 = p1.Partial((_, _, qArray));
                AssertAllFunctorsHaveQubitsCaptured(p2, 3);
                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);

                var p3 = p2.Partial(new Func<int, (int, (Qubit, Qubit))>(q => (2, (q3, q2))));
                AssertAllFunctorsHaveQubitsCaptured(p3, 5);
                AssertAllFunctorsHaveQubitsCaptured(p2, 3);
                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);
            }
        }

        [Fact]
        public void GenericTypesWithClosures()
        {
            var _ = AbstractCallable._;
            var q0 = new FreeQubit(0) as Qubit;
            var q1 = new FreeQubit(1) as Qubit;
            var q2 = new FreeQubit(2) as Qubit;
            var q3 = new FreeQubit(3) as Qubit;
            var q4 = new FreeQubit(4) as Qubit;
            var q5 = new FreeQubit(5) as Qubit;
            var qArray = new QArray<Qubit>(q4, q5);

            {
                var op1 = new GenericCallable(null, typeof(UnitaryNoOp<(int, int, int)>));
                var partialOp1 = op1.Partial((AbstractCallable._, AbstractCallable._, 3));
                var partialOp3 = partialOp1.Partial((AbstractCallable._, 3));

                AssertAllFunctorsHaveNoQubitsCaptured(partialOp1);
                AssertAllFunctorsHaveNoQubitsCaptured(partialOp3);
                AssertAllFunctorsHaveNoQubitsCaptured(op1);
            }
            {
                var op2 = new GenericCallable(null, typeof(UnitaryNoOp<(int, int, Qubit)>)) as IUnitary;
                var partialOp2 = op2.Partial((AbstractCallable._, AbstractCallable._, q0));

                AssertAllFunctorsHaveQubitsCaptured(partialOp2, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op2);
                AssertIDataQubits(partialOp2, q0);
            }
            {
                var op3 = new GenericCallable(null, typeof(UnitaryNoOp<(int, Qubit, Qubit)>)) as IUnitary;
                var partialOp4 = op3.Partial((AbstractCallable._, AbstractCallable._, q0));

                AssertAllFunctorsHaveQubitsCaptured(partialOp4, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op3);
                AssertIDataQubits(partialOp4, q0);

                var partialOp5 = partialOp4.Partial((AbstractCallable._, q1));
                AssertAllFunctorsHaveQubitsCaptured(partialOp5, 2);
                AssertIDataQubits(partialOp5, q1, q0);
            }
            {
                var op = new GenericCallable(null, typeof(UnitaryNoOp<(int, (Qubit, Qubit, Qubit), QArray<Qubit>)>)) as IUnitary;
                var p1 = op.Partial((_, (_, q1, _), _));

                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);
                AssertIDataQubits(p1, q1);

                var p2 = p1.Partial((_, _, qArray));
                AssertAllFunctorsHaveQubitsCaptured(p2, 3);
                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);
                AssertIDataQubits(p1, q1);
                AssertIDataQubits(p2, q4, q5, q1);

                var p3 = p2.Partial(new Func<int, (int, (Qubit, Qubit))>(q => (2, (q3, q2))));
                AssertAllFunctorsHaveQubitsCaptured(p3, 5);
                AssertAllFunctorsHaveQubitsCaptured(p2, 3);
                AssertAllFunctorsHaveQubitsCaptured(p1, 1);
                AssertAllFunctorsHaveNoQubitsCaptured(op);
                AssertIDataQubits(p1, q1);
                AssertIDataQubits(p2, q4, q5, q1);
                AssertIDataQubits(p3, q3, q2, q4, q5, q1);
            }
        }

        [Fact]
        public void UdtTypesWithClosures()
        {
            var q0 = new FreeQubit(0) as Qubit;
            var q1 = new FreeQubit(1) as Qubit;
            var q2 = new FreeQubit(2) as Qubit;

            var op = new UnitaryNoOp<(TupleA,TupleD)>() as IUnitary<(TupleA, TupleD)>;
            var p1 = op.Partial((AbstractCallable._, new TupleD(new QArray<Qubit>(q1, q0))));

            var f0 = new TupleF(op);
            var f1 = new TupleF(p1);
            
            AssertAllFunctorsHaveQubitsCaptured(f1.Data, 2);
            AssertAllFunctorsHaveNoQubitsCaptured(f0.Data);
            AssertIDataQubits(f1, q1, q0);

            var p1a = f0.Data.Partial(new Func<(long, TupleD), (TupleA, TupleD)>((arg) => (new TupleA((arg.Item1, Pauli.PauliZ, q2, (q0, 4L, q0))), arg.Item2)));
            AssertAllFunctorsHaveQubitsCaptured(p1a, 3);
            AssertIDataQubits(p1a, q2, q0, q0);

            var p2 = p1.Partial(new Func<(long, (Pauli, Qubit)), TupleA>((arg) => new TupleA((arg.Item1, arg.Item2.Item1, arg.Item2.Item2, (q1, 5L, q2)))));
            var p2a = p1a.Partial(new Func<long, (long, TupleD)>(arg => (arg, new TupleD(new QArray<Qubit>(q1, q1)))));
            var f2 = new TupleF(p2);
            AssertAllFunctorsHaveQubitsCaptured(f2.Data, 5);
            AssertIDataQubits(f2, null, q1, q2, q1, q0);
            AssertAllFunctorsHaveQubitsCaptured(p2a, 5);
            AssertIDataQubits(p2a, q2, q0, q0, q1, q1);
        }

        [Fact]
        public void QubitsFromUDTs()
        {
            var q0 = new FreeQubit(0);
            var q1 = new FreeQubit(1);
            var q2 = new FreeQubit(2);
            var q3 = new FreeQubit(3);
            var q4 = new FreeQubit(4);
            var q5 = new FreeQubit(5);
            var q6 = new FreeQubit(6);
            var op = new UnitaryNoOp<TupleD>() as IUnitary<TupleD>;

            var qubits = new QArray<Qubit>(q2, q4, q6);
            var bData = ((1L, 2L), (q1, (3L, (q2, q3)), 3.5));
            var qtuple = new QTuple<((Int64, Int64), (Qubit, (Int64, (Qubit, Qubit)), Double))>(bData) as IApplyData;
            var tupleB = new TupleB(((1L, 2L), (q6, (3L, (q4, q6)), 3.5)));
            var tupleA = new TupleA((1L, Pauli.PauliY, q1, (q4, 3L, q5)));
            var tupleC = new TupleC((q5, tupleB));
            var tupleD = new TupleD(new QArray<Qubit>(q1, q2, q3, q4, q6));
            var tupleE = new TupleE((1L, new QArray<Qubit>(q1, q3, q4, q6)));
            var tupleF = new TupleF(op);
            var tupleG = new TupleG((q3, tupleF, tupleC, tupleD));
            var tupleH = new TupleH((tupleD, tupleG));
            var tupleJ = new TupleJ(new QArray<(long, Qubit)>((1L, q1), (2L, q2), (5L, q5), (3L, q3)));
            var tupleU = new QTuple<IUnitary>(null);
            var q = new Q(q3);

            AssertEnumerable(new Qubit[] { q2 }, q2.Qubits);
            AssertEnumerable(new Qubit[] { q1, q2, q3 }, qtuple.Qubits);

            AssertIDataQubits(q2, q2);
            AssertIDataQubits(qtuple, q1, q2, q3);
            AssertIDataQubits(tupleA, q1, q4, q5);
            AssertIDataQubits(tupleB, q6, q4, q6);
            AssertIDataQubits(tupleC, q5, q6, q4, q6);
            AssertIDataQubits(tupleD, q1, q2, q3, q4, q6);
            AssertIDataQubits(tupleE, q1, q3, q4, q6);
            AssertIDataQubits(tupleF, null);
            AssertIDataQubits(tupleG, q3, q5, q6, q4, q6, q1, q2, q3, q4, q6);
            AssertIDataQubits(tupleH, q1, q2, q3, q4, q6, q3, q5, q6, q4, q6, q1, q2, q3, q4, q6);
            AssertIDataQubits(tupleJ, q1, q2, q5, q3);
            AssertIDataQubits(q, q3);
            AssertIDataQubits(tupleU, null);
        }

        private static void AssertEnumerable<T>(IEnumerable<T> e, IEnumerable<T> a)
        {
            if (e == null)
            {
                Assert.Null(a);
            }
            else
            {
                var expected = e.ToArray();
                var actual = a.ToArray();

                Assert.Equal(expected.Length, actual.Length);
                for (int i = 0; i < expected.Length; i++)
                {
                    Assert.Equal(expected[i], actual[i]);
                }
            }
        }

        private static void AssertIDataQubits(IApplyData d, params Qubit[] expected)
        {
            AssertEnumerable(expected, d.Qubits);
        }
    }
}