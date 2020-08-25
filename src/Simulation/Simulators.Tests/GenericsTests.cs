// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.ClosedType;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics;
using System;
using System.Collections.Generic;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    using Helper = Microsoft.Quantum.Simulation.Simulators.Tests.OperationsTestHelper;

    public class TestQubit : Qubit
    {
        public TestQubit() : base(0) { }
    }

    public class GenericsTests
    {
        [Fact]
        public void CreateGenericOperation()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                {
                    var gen = new GenericCallable(s, typeof(Gen0<>));
                    Assert.Same(typeof(Gen0<long>), gen.FindCallable(typeof(long), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<(long, Result)>), gen.FindCallable(typeof((long, Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<((long, bool), Result)>), gen.FindCallable(typeof(((long, bool), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<UDT_G1>), gen.FindCallable(typeof(UDT_G1), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<UDT_G2>), gen.FindCallable(typeof(UDT_G2), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<UDT_G3>), gen.FindCallable(typeof(UDT_G3), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<QArray<long>>), gen.FindCallable(typeof(QArray<long>), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen0<LittleEndian>), gen.FindCallable(typeof(LittleEndian), typeof(QVoid)).GetType());
                }
                {
                    var gen = new GenericCallable(s, typeof(Gen1<,>));
                    Assert.Same(typeof(Gen1<long, bool>), gen.FindCallable(typeof((long, bool)), typeof(bool)).GetType());
                    Assert.Same(typeof(Gen1<(long, Result), bool>), gen.FindCallable(typeof(((long, Result), bool)), typeof(bool)).GetType());
                    Assert.Same(typeof(Gen1<((long, bool), Result), QVoid>), gen.FindCallable(typeof((((long, bool), Result), bool)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen1<((long, bool), Result), Pauli>), gen.FindCallable(typeof((((long, bool), Result), bool)), typeof(Pauli)).GetType());
                    Assert.Same(typeof(Gen1<QArray<long>, bool>), gen.FindCallable(typeof((QArray<long>, bool)), typeof(bool)).GetType());
                    Assert.Same(typeof(Gen1<UDT_G1, Qubit>), gen.FindCallable(typeof(UDT_G1), typeof(Qubit)).GetType());    // no need to unwrapp qtuples automatically anymore.
                    Assert.Same(typeof(Gen1<UDT_G2, Qubit>), gen.FindCallable(typeof(UDT_G2), typeof(Qubit)).GetType());    // no need to unwrapp qtuples automatically anymore.
                    Assert.Same(typeof(Gen1<UDT_G5, UDT_G2>), gen.FindCallable(typeof(UDT_G5), typeof(UDT_G2)).GetType());  // no need to unwrapp qtuples automatically anymore.
                }
                
                {
                    var gen = new GenericCallable(s, typeof(Gen2<,>));
                    Assert.Same(typeof(Gen2<Result, bool>), gen.FindCallable(typeof((Result, long, bool)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen2<(Result, Pauli, Qubit), bool>), gen.FindCallable(typeof(((Result, Pauli, Qubit), long, bool)), typeof(QVoid)).GetType());
                    // not a valid scenario due to unwrap: Assert.Same(typeof(Gen2<QArray<bool>, Qubit>), gen.FindOperation(typeof(UDT_G4), typeof(QVoid)).GetType());
                }
                
                {
                    var gen = new GenericCallable(s, typeof(Gen3<,,>));
                    Assert.Same(typeof(Gen3<Result, bool, Pauli>), gen.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen3<Result, (long, long), Pauli>), gen.FindCallable(typeof((Result, ((long, long), Pauli), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen3<(long, IAdjointable, double), bool, Pauli>), gen.FindCallable(typeof(((long, IAdjointable, double), (bool, Pauli), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen3<Result, bool, (Pauli, Pauli)>), gen.FindCallable(typeof((Result, (bool, (Pauli, Pauli)), Result)), typeof(QVoid)).GetType());
                }
                
                {
                    var gen = new GenericCallable(s, typeof(Gen4<,>));
                    Assert.Same(typeof(Gen4<bool, Pauli>), gen.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen4<(bool, long, (int, ICallable)), Pauli>), gen.FindCallable(typeof((Result, ((bool, long, (int, ICallable)), Pauli), Result)), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen4<(IUnitary, bool), (IAdjointable, Pauli)>), gen.FindCallable(typeof((Result, ((IUnitary, bool), (IAdjointable, Pauli)), Result)), typeof(QVoid)).GetType());
                }
                
                {
                    var gen = new GenericCallable(s, typeof(Gen5<>));
                    Assert.Same(typeof(Gen5<Qubit>), gen.FindCallable(typeof(IQArray<Qubit>), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen5<bool>), gen.FindCallable(typeof(IQArray<bool>), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen5<IQArray<long>>), gen.FindCallable(typeof(IQArray<IQArray<long>>), typeof(QVoid)).GetType());
                    // not a valid scenario due to unwrap: Assert.Same(typeof(Gen5<Qubit>), gen.FindOperation(typeof(LittleEndian), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen5<LittleEndian>), gen.FindCallable(typeof(IQArray<LittleEndian>), typeof(QVoid)).GetType());
                    Assert.Same(typeof(Gen5<IQArray<LittleEndian>>), gen.FindCallable(typeof(IQArray<IQArray<LittleEndian>>), typeof(QVoid)).GetType());
                }
                
                {
                    var gen = new GenericCallable(s, typeof(Iter<>));
                    Assert.Same(typeof(Iter<Qubit>), gen.FindCallable(typeof((ICallable, IQArray<Qubit>)), typeof(QVoid)).GetType());
                }
            });
        }

        [Fact]
        public void CreateGenericAdjointOperation()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var gen0 = new GenericCallable(s, typeof(Gen0<>));

                Assert.Same(typeof(AdjointedOperation<long, QVoid>), gen0.Adjoint.FindCallable(typeof(long), typeof(QVoid)).GetType());
                Assert.Same(typeof(AdjointedOperation<(long, Result), QVoid>), gen0.Adjoint.FindCallable(typeof((long, Result)), typeof(QVoid)).GetType());
                Assert.Same(typeof(AdjointedOperation<((long, bool), Result), QVoid>), gen0.Adjoint.FindCallable(typeof(((long, bool), Result)), typeof(QVoid)).GetType());
                Assert.Same(typeof(AdjointedOperation<(long, Result), QVoid>), gen0.Adjoint.FindCallable(typeof((long, Result)), typeof(QVoid)).GetType()); // Twice to test caching.

                var gen2 = new GenericCallable(s, typeof(Gen2<,>));
                var r2 = gen2.Adjoint.FindCallable(typeof((Result, long, bool)), typeof(QVoid)) as AdjointedOperation<(Result, long, bool), QVoid>;
                Assert.NotNull(r2);
                Assert.Same(typeof(Gen2<Result, bool>), r2.BaseOp.GetType());

                var gen4 = new GenericCallable(s, typeof(Gen4<,>));
                var r4 = gen4.Adjoint.FindCallable(typeof((Result, ((IUnitary, bool), (IAdjointable, Pauli)), Result)), typeof(QVoid)) as AdjointedOperation<(Result, ((IUnitary, bool), (IAdjointable, Pauli)), Result), QVoid>;
                Assert.NotNull(r4);
                Assert.Same(typeof(Gen4<(IUnitary, bool), (IAdjointable, Pauli)>), r4.BaseOp.GetType());
            });
        }


        [Fact]
        public void CreateGenericControlledOperation()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var gen0 = new GenericCallable(s, typeof(Gen0<>));

                Assert.Same(typeof(ControlledOperation<long, QVoid>), gen0.Controlled.FindCallable(typeof((QArray<Qubit>, long)), typeof(QVoid)).GetType());
                Assert.Same(typeof(ControlledOperation<long, QVoid>), gen0.Controlled.FindCallable(typeof((LittleEndian, long)), typeof(QVoid)).GetType());
                Assert.Same(typeof(ControlledOperation<(long, Result), QVoid>), gen0.Controlled.FindCallable(typeof((QArray<Qubit>, (long, Result))), typeof(QVoid)).GetType());
                Assert.Same(typeof(ControlledOperation<((Qubit, bool), Result), QVoid>), gen0.Controlled.FindCallable(typeof((QArray<Qubit>, ((TestQubit, bool), Result))), typeof(QVoid)).GetType());
                Assert.Same(typeof(ControlledOperation<long, QVoid>), gen0.Controlled.FindCallable(typeof((QArray<Qubit>, long)), typeof(QVoid)).GetType()); // Twice to check for caching.

                var gen2 = new GenericCallable(s, typeof(Gen2<,>));
                var r2 = gen2.Controlled.FindCallable(typeof((LittleEndian, (QArray<Qubit>, long, bool))), typeof(QVoid)) as ControlledOperation<(QArray<Qubit>, long, bool), QVoid>;
                Assert.NotNull(r2);
                Assert.Same(typeof(Gen2<QArray<Qubit>, bool>), r2.BaseOp.GetType());

                var gen4 = new GenericCallable(s, typeof(Gen4<,>));
                var r4 = gen4.Controlled.FindCallable(typeof((QArray<Qubit>, (Result, ((IUnitary<Qubit>, bool), (IAdjointable<(TestQubit, Result)>, Pauli)), Result))), typeof(QVoid)) as ControlledOperation<(Result, ((IUnitary, bool), (IAdjointable, Pauli)), Result), QVoid>;
                Assert.NotNull(r4);
                Assert.Same(typeof(Gen4<(IUnitary, bool), (IAdjointable, Pauli)>), r4.BaseOp.GetType());
            });
        }
        [Fact]
        public void FindOperation()
        {
            var _ = AbstractCallable._;

            Helper.RunWithMultipleSimulators((s) =>
            {
                {
                    var gen = s.Get<GenericCallable>(typeof(Gen1<,>));

                    // Calling twice for the same input
                    var expected = gen.FindCallable(typeof((long, bool)), typeof(bool));
                    var actual = gen.FindCallable(typeof((long, bool)), typeof(bool));
                    Assert.Same(expected, actual);

                    // Change the input type, different operations
                    expected = gen.FindCallable(typeof((long, Result)), typeof(Result));
                    Assert.NotSame(expected, actual);
                    actual = gen.FindCallable(typeof((long, Result)), typeof(Result));
                    Assert.Same(expected, actual);
                    
                    var unitary = s.Get<GenericCallable>(typeof(Gen4<,>));
                    expected = unitary.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid));
                    actual = unitary.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid));
                    Assert.Same(expected, actual);

                    expected = unitary.Adjoint.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid));
                    actual = unitary.Adjoint.FindCallable(typeof((Result, (bool, Pauli), Result)), typeof(QVoid));
                    Assert.Same(expected, actual);

                    expected = unitary.Controlled.FindCallable(typeof((QArray<Qubit>, (Result, (bool, Pauli), Result))), typeof(QVoid));
                    actual = unitary.Controlled.FindCallable(typeof((QArray<Qubit>, (Result, (bool, Pauli), Result))), typeof(QVoid));
                    Assert.Same(expected, actual);

                    // Partial gives us a new instance every time.
                    expected = unitary.Partial((_,_,_));
                    actual = unitary.Partial((_, _, _));
                    Assert.NotSame(expected, actual);
                }
            });
        }
        

        [Fact]
        public void CreateGenericOperationWithMultipleFunctors()
        {
            var _ = AbstractCallable._;

            Helper.RunWithMultipleSimulators((s) =>
            {
                var gen0 = new GenericCallable(s, typeof(Gen0<>));

                Assert.Same(typeof(Gen0<long>), gen0.FindCallable(typeof(long), typeof(QVoid)).GetType());
                Assert.Same(typeof(ControlledOperation<long, QVoid>), gen0.Controlled.FindCallable(typeof((IQArray<Qubit>, long)), typeof(QVoid)).GetType());
                Assert.Same(typeof(AdjointedOperation<long, QVoid>), gen0.Adjoint.FindCallable(typeof(long), typeof(QVoid)).GetType());
                {
                    var op = gen0.Adjoint.Controlled.FindCallable(typeof((IQArray<Qubit>, long)), typeof(QVoid)) as ControlledOperation<long, QVoid>;
                    Assert.NotNull(op);
                    Assert.Same(typeof(AdjointedOperation<long, QVoid>), op.BaseOp.GetType());
                }
                {
                    var op = gen0.Controlled.Adjoint.FindCallable(typeof((IQArray<Qubit>, long)), typeof(QVoid)) as AdjointedOperation<(IQArray<Qubit>, long), QVoid>;
                    Assert.NotNull(op);
                    Assert.Same(typeof(ControlledOperation<long, QVoid>), op.BaseOp.GetType());
                }
            });
        }


        [Fact]
        public void CreateGenericPartial()
        {
            var _ = AbstractCallable._;

            Helper.RunWithMultipleSimulators((s) =>
            {
                {
                    var gen = new GenericCallable(s, typeof(Gen0<>));
                    var partial = gen.Partial(_);
                    Assert.Same(typeof(long), partial.IdentifyBaseArgsType(typeof(long)));
                    Assert.Same(typeof(Qubit), partial.IdentifyBaseArgsType(typeof(Qubit)));
                    Assert.Same(typeof((bool, long)), partial.IdentifyBaseArgsType(typeof((bool, long))));

                    {
                        var op1 = partial.FindCallable(typeof(Qubit), typeof(QVoid)) as OperationPartial<Qubit, Qubit, QVoid>;
                        Assert.NotNull(op1);
                    }
                    {
                        var op1 = partial.FindCallable(typeof(Double), typeof(QVoid)) as OperationPartial<Double, Double, QVoid>;
                        Assert.NotNull(op1);
                    }
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen0<>));
                    var partial = gen.Adjoint.Partial(_);
                    Assert.Same(typeof(long), partial.IdentifyBaseArgsType(typeof(long)));
                    Assert.Same(typeof(Qubit), partial.IdentifyBaseArgsType(typeof(Qubit)));
                    Assert.Same(typeof((bool, long)), partial.IdentifyBaseArgsType(typeof((bool, long))));

                    {
                        var op1 = partial.FindCallable(typeof(Qubit), typeof(QVoid)) as OperationPartial<Qubit, Qubit, QVoid>;
                        Assert.NotNull(op1);
                    }
                    {
                        var op1 = partial.FindCallable(typeof(Double), typeof(QVoid)) as OperationPartial<Double, Double, QVoid>;
                        Assert.NotNull(op1);
                    }
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen0<>));
                    var ctrl = gen.Controlled;
                    var partial = ctrl.Partial((new QArray<Qubit>(), _));
                    Assert.Same(typeof((QArray<Qubit>, long)), partial.IdentifyBaseArgsType(typeof(long)));
                    Assert.Same(typeof((QArray<Qubit>, string)), partial.IdentifyBaseArgsType(typeof(string)));
                    Assert.Same(typeof((QArray<Qubit>, Qubit)), partial.IdentifyBaseArgsType(typeof(Qubit)));
                    Assert.Same(typeof((QArray<Qubit>, (bool, long))), partial.IdentifyBaseArgsType(typeof((bool, long))));
                    {
                        var op1 = partial.FindCallable(typeof(Result), typeof(QVoid));
                        Assert.Equal(typeof(OperationPartial<Result, (IQArray<Qubit>, Result), QVoid>), op1.GetType());
                    }
                    {
                        var op1 = partial.FindCallable(typeof(string), typeof(QVoid));
                        Assert.Equal(typeof(OperationPartial<string, (IQArray<Qubit>, string), QVoid>), op1.GetType());
                    }
                }

                {
                    var gen = new GenericCallable(s, typeof(TraceGate<>));
                    var partial = gen.Partial((s.Get<IUnitary<Qubit>, Intrinsic.X>(), "normal", _));

                    Assert.Same(typeof((IUnitary, string, Result)), partial.IdentifyBaseArgsType(typeof(Result)));
                    Assert.Same(typeof((IUnitary, string, Qubit)), partial.IdentifyBaseArgsType(typeof(TestQubit)));
                    var op1 = partial.FindCallable(typeof(TestQubit), typeof(QVoid));
                    Assert.Equal(typeof(OperationPartial<Qubit, (IUnitary, string, Qubit), QVoid>), op1.GetType());
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen1<,>));
                    var partial = gen.Partial((_, 2.3D));
                    Assert.Same(typeof((Result, double)), partial.IdentifyBaseArgsType(typeof(Result)));
                    var op1 = partial.FindCallable(typeof(Result), typeof(double));
                    Assert.Equal(typeof(OperationPartial<Result,(Result, Double), Double>), op1.GetType());
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen2<,>));
                    var partial = gen.Partial((_, _, _));
                    Assert.Same(typeof((Result, long, bool)), partial.IdentifyBaseArgsType(typeof((Result, long, bool))));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen2<,>));
                    var p1 = new GenericCallable(s, typeof(Gen1<,>)) as ICallable;
                    var p2 = new GenericCallable(s, typeof(Gen2<,>)) as IAdjointable;
                    var p3 = p2.Partial((_, true));

                    var partial = gen.Partial((p1, _, (p2, p3)));
                    Assert.Same(typeof((ICallable, long, (IAdjointable, IAdjointable))), partial.IdentifyBaseArgsType(typeof(long)));
                    var op1 = partial.FindCallable(typeof(long), typeof(QVoid));
                    Assert.Equal(typeof(OperationPartial<long, (ICallable, long, (IAdjointable, IAdjointable)), QVoid>), op1.GetType());
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen2<,>));
                    var p1 = new GenericCallable(s, typeof(Gen1<,>)) as ICallable;
                    var p2 = new GenericCallable(s, typeof(Gen2<,>)) as IAdjointable;
                    var p3 = p2.Partial((_, true));

                    var partial = gen.Partial(((_, p1), _, (p2, p3)));
                    Assert.Same(typeof(((Qubit, ICallable), long, (IAdjointable, IAdjointable))), partial.IdentifyBaseArgsType(typeof((TestQubit, long))));
                    var op1 = partial.FindCallable(typeof((TestQubit, long)), typeof(QVoid));
                    Assert.Equal(typeof(OperationPartial<(Qubit, long), ((Qubit, ICallable), long, (IAdjointable, IAdjointable)), QVoid>), op1.GetType());
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen2<,>));
                    var partial = gen.Partial((_, 2L, false));
                    Assert.Same(typeof((Result, long, bool)), partial.IdentifyBaseArgsType(typeof(Result)));
                    Assert.Same(typeof((IUnitary, long, bool)), partial.IdentifyBaseArgsType(typeof(IUnitary)));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen3<,,>));
                    var partial = gen.Partial((_, (_, s.Get<IControllable<(string, (double, Pauli), Result)>, ClosedType3>()), Result.Zero));
                    Assert.Same(typeof((long, (bool, IControllable), Result)), partial.IdentifyBaseArgsType(typeof((long, bool))));
                    Assert.Same(typeof((IUnitary, (Qubit, IControllable), Result)), partial.IdentifyBaseArgsType(typeof((IUnitary, Qubit))));
                    Assert.Same(typeof((string, (string, IControllable), Result)), partial.IdentifyBaseArgsType(typeof((string, string))));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen3<,,>));
                    var partial = gen.Partial((s.Get<IAdjointable<(string, long, double)>, ClosedType2>(), (_, _), Result.Zero));
                    Assert.Same(typeof((IAdjointable, (long, bool), Result)), partial.IdentifyBaseArgsType(typeof((long, bool))));
                    Assert.Same(typeof((IAdjointable, (IUnitary, Qubit), Result)), partial.IdentifyBaseArgsType(typeof((IUnitary, Qubit))));
                    Assert.Same(typeof((IAdjointable, (string, string), Result)), partial.IdentifyBaseArgsType(typeof((string, string))));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen4<,>));
                    var partial = gen.Partial((Result.One, (s.Get<IUnitary<(Result, (String, Int64), Result)>, ClosedType4>(), _), Result.Zero));
                    Assert.Same(typeof((Result, (IUnitary, bool), Result)), partial.IdentifyBaseArgsType(typeof(bool)));
                    Assert.Same(typeof((Result, (IUnitary, (IUnitary, Qubit)), Result)), partial.IdentifyBaseArgsType(typeof((IUnitary, Qubit))));
                    Assert.Same(typeof((Result, (IUnitary, (string, string)), Result)), partial.IdentifyBaseArgsType(typeof((string, string))));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen3<,,>));
                    var partial = gen.Partial((_,_,Result.Zero)); 
                    Assert.Same(typeof(((long, bool), (double,double), Result)), partial.IdentifyBaseArgsType(typeof(((long, bool),(double,double)))));
                    Assert.Same(typeof((long, (double, double), Result)), partial.IdentifyBaseArgsType(typeof((long, (double, double)))));
                    Assert.Same(typeof((long, (double, (long,double)), Result)), partial.IdentifyBaseArgsType(typeof((long, (double, (long,double))))));
                }

                {
                    var gen = new GenericCallable(s, typeof(Gen3<,,>));
                    var partial = gen.Partial((_, (4.1,_), Result.Zero)); 
                    Assert.Same(typeof(((long, bool), (double, double), Result)), partial.IdentifyBaseArgsType(typeof(((long, bool), double))));
                    Assert.Same(typeof((long, (double, double), Result)), partial.IdentifyBaseArgsType(typeof((long, double))));
                    Assert.Same(typeof((long, (double ,(long, double)), Result)), partial.IdentifyBaseArgsType(typeof((long, (long, double)))));
                }
            });
        }


        [Fact]
        public void CreateDifferentPartial()
        {
            var _ = AbstractCallable._;

            Helper.RunWithMultipleSimulators((s) =>
            {
                {
                    var gen = new GenericCallable(s, typeof(Gen1<,>));
                    var partial = gen.Partial(_);
                    Assert.Equal(typeof(GenericPartial), partial.GetType());
                }
                
                {
                    var closed = new Gen1<long, bool>(s);
                    var partial = closed.Partial<ICallable>(_);
                    Assert.Equal(typeof(OperationPartial<(long, bool), (long, bool), bool>), partial.GetType());
                }
                
                {
                    var closed = new Gen1<(long, long), bool>(s);
                    var partial = closed.Partial<ICallable>(((3L, _), true));
                    Assert.Equal(typeof(OperationPartial<long, ((long, long), bool), bool>), partial.GetType());
                }
                
                {
                    var x = s.Get<IUnitary<Qubit>, Intrinsic.X>();
                    var closed = new Gen1<(long, (IUnitary, Qubit, Result)), bool>(s);
                    var partial = closed.Partial<ICallable>(((_, (x, _, _)), true));
                    Assert.Equal(typeof(OperationPartial<(long, (Qubit, Result)), ((long, (IUnitary, Qubit, Result)), bool), bool>), partial.GetType());
                }
                
                {
                    var x = s.Get<IUnitary<Qubit>, Intrinsic.X>();
                    var closed = new Gen1<(long, (IUnitary, Qubit, Result)), bool>(s) as ICallable<((long, (IUnitary, Qubit, Result)), bool), bool>;
                    var partial = closed.Partial(((_, (x, _, _)), false));
                    Assert.Equal(typeof(OperationPartial<(long, (Qubit, Result)), ((long, (IUnitary, Qubit, Result)), bool), bool>), partial.GetType());
                }

                {
                    var closed = new Gen2<(long, bool, Result), IUnitary>(s);
                    var partial = closed.Partial<IAdjointable>(((_, true, _), 3L, _));
                    Assert.Equal(typeof(OperationPartial<((long, Result), IUnitary), ((long, bool, Result), long, IUnitary), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen2<bool, Result>(s) as IAdjointable<(bool, long, Result)>;
                    var partial = closed.Partial((_, 3L, Result.Zero));
                    Assert.Equal(typeof(OperationPartial<bool, (bool, long, Result), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen4<bool, bool>(s) as IUnitary<(Result, (bool, bool), Result)>;
                    var partial = closed.Controlled.Partial((_, (_, (true, _), Result.Zero)));
                    Assert.Equal(typeof(OperationPartial<(IQArray<Qubit>, (Result, bool)), (IQArray<Qubit>, (Result, (bool, bool), Result)), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen4<bool, bool>(s) as IControllable<(Result, (bool, bool), Result)>;
                    var partial = closed.Controlled.Partial((_, (_, (true, _), Result.Zero)));
                    Assert.Equal(typeof(OperationPartial<(IQArray<Qubit>, (Result, bool)), (IQArray<Qubit>, (Result, (bool, bool), Result)), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen2<bool, Result>(s) as IAdjointable;
                    var partial = closed.Partial((_, 3L, Result.Zero));
                    Assert.Equal(typeof(OperationPartial<bool, (bool, long, Result), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen4<bool, bool>(s) as IUnitary;
                    var partial = closed.Adjoint.Controlled.Partial((_, (_, (true, _), Result.Zero)));
                    Assert.Equal(typeof(OperationPartial<(IQArray<Qubit>, (Result, bool)), (IQArray<Qubit>, (Result, (bool, bool), Result)), QVoid>), partial.GetType());
                }

                {
                    var closed = new Gen4<bool, bool>(s) as IControllable;
                    var partial = closed.Controlled.Partial((_, (_, (true, _), Result.Zero)));
                    Assert.Equal(typeof(OperationPartial<(IQArray<Qubit>, (Result, bool)), (IQArray<Qubit>, (Result, (bool, bool), Result)), QVoid>), partial.GetType());
                }
            });
        }

        private void CheckIter<T>(Log<T> log, T zero, T uno)
        {
            Assert.Equal(2, log.GetNumberOfCalls(OperationFunctor.Body, zero));
            Assert.Equal(1, log.GetNumberOfCalls(OperationFunctor.Body, uno));

            Assert.Equal(3, log.GetNumberOfCalls(OperationFunctor.Adjoint, zero));
            Assert.Equal(2, log.GetNumberOfCalls(OperationFunctor.Adjoint, uno));

            Assert.Equal(1, log.GetNumberOfCalls(OperationFunctor.Controlled, zero));
            Assert.Equal(3, log.GetNumberOfCalls(OperationFunctor.Controlled, uno));

            Assert.Equal(4, log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, zero));
            Assert.Equal(5, log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, uno));
        }

        private void CheckRepeat(Log<string> log)
        {
            Assert.Equal(5, log.GetNumberOfCalls(OperationFunctor.Body, "normal"));
            Assert.Equal(2, log.GetNumberOfCalls(OperationFunctor.Adjoint, "normal"));
            Assert.Equal(3, log.GetNumberOfCalls(OperationFunctor.Controlled, "normal"));
            Assert.Equal(0, log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "normal"));

            Assert.Equal(2, log.GetNumberOfCalls(OperationFunctor.Body, "adjoint"));
            Assert.Equal(5, log.GetNumberOfCalls(OperationFunctor.Adjoint, "adjoint"));
            Assert.Equal(0, log.GetNumberOfCalls(OperationFunctor.Controlled, "adjoint"));
            Assert.Equal(3, log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "adjoint"));
        }

        [Fact]
        public void ClosedTypeIter()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                Circuits.ClosedType.TestIter.Run(s).Wait();

                var tracer = s.Get<Trace>() as Helper.TracerImpl;
                CheckIter(tracer.Log, "cero", "uno");
            });
        }

        [Fact]
        public void ClosedTypeRepeatPartial()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                Circuits.ClosedType.TestRepeatPartial.Run(s).Wait();

                var t = s.Get<Trace>() as Helper.TracerImpl;
                CheckRepeat(t.Log);
            });
        }

        [Fact]
        public void GenericIter()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                Circuits.Generics.TestIter.Run(s).Wait();

                var strTracer = s.GetTracer<string>();
                CheckIter(strTracer.Log, "cero", "uno");

                var resTracer = s.GetTracer<Result>();
                CheckIter(resTracer.Log, Result.Zero, Result.One);
            });
        }

        [Fact]
        public void GenericRepeatPartial()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                Circuits.Generics.TestRepeatPartial.Run(s).Wait();

                var tracer = s.GetTracer<string>();
                CheckRepeat(tracer.Log);
            });
        }

        [Fact]
        public void CreateRepeatWrapperPartial()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestCreateRepeatWrapperPartial.Run(s).Wait();

                var tracer = s.GetTracer<string>();
                CheckRepeat(tracer.Log);
            });
        }

        [Fact]
        public void TestLookupUnitaries()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                Circuits.Generics.TestLookupUnitaries.Run(s).Wait();

                var tracer = s.GetTracer<string>(); 

                Assert.Equal(6, tracer.GetNumberOfCalls(OperationFunctor.Body, "uno"));
                Assert.Equal(6, tracer.GetNumberOfCalls(OperationFunctor.Adjoint, "uno"));
                Assert.Equal(9, tracer.GetNumberOfCalls(OperationFunctor.Controlled, "uno"));
                Assert.Equal(6, tracer.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "uno"));
            });
        }

        [Fact]
        public void ClosedUDTsPolyMorphism()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestUDTsUnwrapping.Run(s).Wait();

                var stracer = s.Get<Trace>() as Helper.TracerImpl;

                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "d2a"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "d2b"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "d2a"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "d2b"));

                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "d2x"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "d2y"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "d2x"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "d2y"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, "d2x"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, "d2y"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "d2x"));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "d2y"));
            });
        }

        [Fact]
        public void NonGenericPartial()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestNonGenericPartial.Run(s).Wait();

                var stracer = s.GetTracer<string>();
                var itracer = s.GetTracer<Int64>();
                var rtracer = s.GetTracer<Result>();
                var sstracer = s.GetTracer<(string, string)>();
                var rrtracer = s.GetTracer<(Result, Result)>();

                Assert.Equal(7, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "a1"));
                Assert.Equal(7, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "a2"));
                Assert.Equal(7, itracer.Log.GetNumberOfCalls(OperationFunctor.Body, 2));
                Assert.Equal(7, itracer.Log.GetNumberOfCalls(OperationFunctor.Body, 3));
                Assert.Equal(7, rtracer.Log.GetNumberOfCalls(OperationFunctor.Body, Result.Zero));
                Assert.Equal(7, rtracer.Log.GetNumberOfCalls(OperationFunctor.Body, Result.One));
                Assert.Equal(7, sstracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("a1", "a2")));
                Assert.Equal(7, rrtracer.Log.GetNumberOfCalls(OperationFunctor.Body, (Result.Zero, Result.One)));


                Assert.Equal(9, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "a1"));
                Assert.Equal(9, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, "a2"));
                Assert.Equal(9, itracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, 2));
                Assert.Equal(9, itracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, 3));
                Assert.Equal(9, rtracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, Result.Zero));
                Assert.Equal(9, rtracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, Result.One));
                Assert.Equal(9, sstracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, ("a1", "a2")));
                Assert.Equal(9, rrtracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (Result.Zero, Result.One)));

                Assert.Equal(3, stracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, "a1"));
                Assert.Equal(3, stracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, "a2"));
                Assert.Equal(3, itracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, 2));
                Assert.Equal(3, itracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, 3));
                Assert.Equal(3, rtracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, Result.Zero));
                Assert.Equal(3, rtracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, Result.One));
                Assert.Equal(3, sstracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, ("a1", "a2")));
                Assert.Equal(3, rrtracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, (Result.Zero, Result.One)));

                Assert.Equal(4, stracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "a1"));
                Assert.Equal(4, stracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, "a2"));
                Assert.Equal(4, itracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, 2));
                Assert.Equal(4, itracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, 3));
                Assert.Equal(4, rtracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, Result.Zero));
                Assert.Equal(4, rtracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, Result.One));
                Assert.Equal(4, sstracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, ("a1", "a2")));
                Assert.Equal(4, rrtracer.Log.GetNumberOfCalls(OperationFunctor.ControlledAdjoint, (Result.Zero, Result.One)));
            });
        }

        [Fact]
        public void GenericPartialNestedTupleArgs()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestGenericPartial.Run(s).Wait();

                var sstracer = s.GetTracer<(string, string)>();
                var stracer = s.GetTracer<string>();

                Assert.Equal(9, sstracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("T1", "T2")));
                Assert.Equal(11, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("argA")));
                Assert.Equal(11, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("argB")));
                Assert.Equal(10, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("argD")));
            });
        }

        [Fact]
        public void GenericsCallablesArguments()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                BindTest.Run(s).Wait();
                var stracer = s.GetTracer<string>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("success!")));
            });
        }

        [Fact]
        public void GenericCompose()
        // FIXME: there are more cases similar to this one where the workaround of using object 
        // for the parts of the type argument O in Apply which are unresolvable won't work 
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestCompose.Run(s).Wait();
                var stracer = s.GetTracer<string>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "cero"));
                TestComposeWithNonGeneric.Run(s).Wait();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, "redirecting:cero"));
            });
        }

        [Fact]
        public void GenericMultiControlled()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                MultiControlledTest.Run(s).Wait();
                var stracer = s.GetTracer<long>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (1)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (2)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (3)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (4)));
            });
        }

        [Fact]
        public void GenericsMixedComponents()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                MixedComponentsTest.Run(s).Wait();
                var stracer = s.GetTracer<long>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body,    (1)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (2)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (2)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (3)));
            });
        }

        [Fact]
        public void GenericsAssignments()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                AssignmentsTest.Run(s).Wait();
                var stracer = s.GetTracer<long>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (1)));
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (2)));
                Assert.Equal(2, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (3)));
                Assert.Equal(2, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (3)));
            });
        }

        [Fact]
        public void GenericsAssignmentsWithPartialApplications()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                AssignmentsWithPartialsTest.Run(s).Wait();
                var stracer = s.GetTracer<long>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, (2)));
                Assert.Equal(3, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, (3)));
            });
        }

        [Fact]
        public void GenericsCallableCasts()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                CCNOTCiruitsTest.Run(s).Wait();
                var stracer = s.GetTracer<string>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("success!")));
            });
        }

        [Fact] // FIXME: remove dummy in MapDefaults in Generics.qs to make this test meaningful! (currently this is not supported in the simulation core)
        public void GenericsHiddenGenericParameters() 
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestMapDefaults.Run(s).Wait();
                var stracer = s.GetTracer<string>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Body, ("success!")));
            });
        }

        [Fact]
        public void GenericsMultipleTypeParameters()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestMultipleTypeParamters.Run(s).Wait();
                var ltracer = s.GetTracer<long>();
                Assert.Equal(1, ltracer.Log.GetNumberOfCalls(OperationFunctor.Body, (1L)));
            });
        }

        [Fact]
        public void GenericsDestructingArgTuple()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                TestDestructingArgTuple.Run(s).Wait();
                var ltracer = s.GetTracer<long>();
                Assert.Equal(1, ltracer.Log.GetNumberOfCalls(OperationFunctor.Body, (1L)));
                var sstracer = s.GetTracer<(string, string)>();
                Assert.Equal(1, sstracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, ("Hello", "World")));
            });
        }

        [Fact]
        public void ControlledBitString()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var q0 = new FreeQubit(0) as Qubit;
                var q1 = new FreeQubit(1) as Qubit;
                var q2 = new FreeQubit(2) as Qubit;

                TestControlledBitString.Run(s).Wait();
                var tracer = s.GetTracer<long>();
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, 0));
                Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, 1));
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Body, 2));

                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, 0));
                Assert.Equal(0, tracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, 1));
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Adjoint, 2));

                var stracer = s.GetTracer<string>();
                Assert.Equal(1, stracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, "ok"));
            });
        }


        [Fact]
        public void ApplyToEachUdt()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var q0 = new FreeQubit(0) as Qubit;
                var q1 = new FreeQubit(1) as Qubit;
                var q2 = new FreeQubit(2) as Qubit;

                TestApplyToEachUdt.Run(s).Wait();
                var tracer = s.GetTracer<Qubit>();
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, q0));
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, q1));
                Assert.Equal(1, tracer.Log.GetNumberOfCalls(OperationFunctor.Controlled, q2));
            });
        }

        [Fact]
        public void UDTsPolyMorphism()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var tracker = new StartTracker(s);

                TestUDTsPolyMorphism.Run(s).Wait();

                Assert.Equal(20, tracker.GetNumberOfCalls("Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Trace", OperationFunctor.Body));
            });
        }

        [Fact]
        public void WrapperWithDifferentReturnValues()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var gen = new GenericCallable(s, typeof(Gen0<>));
                WrapperWithDifferentReturnValuesTest.Run(s).Wait();

                // do some manual tests to verify cache works:
                var wrapper = new GenericCallable(s, typeof(GenWrapper<,>));
                var str1 = wrapper.FindCallable(typeof((ICallable, Result)), typeof(String));
                var int1 = wrapper.FindCallable(typeof((ICallable, Result)), typeof(Int64));
                var str2 = wrapper.FindCallable(typeof((ICallable, Result)), typeof(String));
                var int2 = wrapper.FindCallable(typeof((ICallable, Result)), typeof(Int64));

                Assert.Same(str1, str2);
                Assert.Same(int1, int2);
                Assert.NotSame(str1, int1);
                Assert.Same(typeof(GenWrapper<Result, String>), str1.GetType());
                Assert.Same(typeof(GenWrapper<Result, Int64>), int1.GetType());
            });
        }
    }
}
