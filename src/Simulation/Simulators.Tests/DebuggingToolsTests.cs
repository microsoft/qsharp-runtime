// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Globalization;
using System.Threading;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Tests.CoreOperations;

using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    using Helper = OperationsTestHelper;
    /// <summary>
    /// Provides test methods for things that are useful during debugging.
    /// </summary>
    public class DebuggingToolsTests
    {
        [Fact]
        public void ToStringTests() => Helper.RunWithMultipleSimulators(qsim =>
        {
            var _ = AbstractCallable._;

            var dump = qsim.Get<ICallable>(typeof(Microsoft.Quantum.Extensions.Diagnostics.DumpMachine<>));
            var trace = qsim.Get<IUnitary>(typeof(Circuits.Generics.Trace<>));
            var x = qsim.Get<Intrinsic.X>();
            var q2 = new FreeQubit(2) as Qubit;
            var Q = new Q(q2);
            var Qs = new QArray<Qubit>(q2);
            var qs = new Qs(Qs);
            var udtOp = new U3(x);
            var udtQ = new Q(q2);
            var t1 = new QTuple<(long, QRange, (Qubit, IUnitary))>((1L, new QRange(10, -2, 4), (q2, x)));
            var t4 = new T4((3L, (1.1, false, Result.One)));
            var t5 = new T5((Pauli.PauliX, Qs, qs, Q));

            var d_1 = dump.Partial(_);
            var d_2 = d_1.Partial(_);
            var x_1 = x.Partial(new Func<Qubit, Qubit>(q => q));
            var x_2 = x_1.Partial(new Func<Qubit, Qubit>(q => q));
            var x_3 = x.Partial<OperationPartial<Qubit, Qubit, QVoid>>(_);

            var t_1 = trace.Adjoint.Partial(_);
            var t_2 = t_1.Controlled.Partial(_);

            WithInvariantCulture(() =>
            {
                Assert.Equal("()", QVoid.Instance.ToString());
                Assert.Equal("_", _.ToString());
                Assert.Equal("U3(X)", udtOp.ToString());
                Assert.Equal("q:2", q2.ToString());
                Assert.Equal("Q(q:2)", udtQ.ToString());
                Assert.Equal("(1, 10..-2..4, (q:2, X))", t1.ToString());
                Assert.Equal("T4((3, (1.1, False, One)))", t4.ToString());
                Assert.Equal("T5((PauliX, [q:2], Qs([q:2]), Q(q:2)))", t5.ToString());
                Assert.Equal("X", x.ToString());
                Assert.Equal("(Adjoint X)", x.Adjoint.ToString());
                Assert.Equal("(Controlled X)", x.Controlled.ToString());
                Assert.Equal("(Adjoint (Controlled X))", x.Controlled.Adjoint.ToString());
                Assert.Equal("(Controlled (Adjoint X))", x.Adjoint.Controlled.ToString());
                Assert.Equal("X{_}", x_1.ToString());
                Assert.Equal("(Adjoint X{_})", x_1.Adjoint.ToString());
                Assert.Equal("X{_}{_}", x_2.ToString());
                Assert.Equal("X{_}", x_3.ToString());
                Assert.Equal("DumpMachine", dump.ToString());
                Assert.Equal("DumpMachine{_}", d_1.ToString());
                Assert.Equal("DumpMachine{_}{_}", d_2.ToString());
                Assert.Equal("Trace", trace.ToString());
                Assert.Equal("(Adjoint Trace)", trace.Adjoint.ToString());
                Assert.Equal("(Controlled Trace)", trace.Controlled.ToString());
                Assert.Equal("(Adjoint (Controlled Trace))", trace.Controlled.Adjoint.ToString());
                Assert.Equal("(Adjoint Trace){_}", t_1.ToString());
                Assert.Equal("(Adjoint (Controlled (Adjoint Trace){_}){_})", t_2.Adjoint.ToString());
            });
        });

        [Fact]
        public void QSharpTypeTests()
        {
            Helper.RunWithMultipleSimulators((qsim) =>
            {
                var _ = AbstractCallable._;

                var x = qsim.Get<Intrinsic.X>();
                var q2 = new FreeQubit(2) as Qubit;
                var Q = new Q(q2);
                var Qs = new QArray<Qubit>(q2);
                var qs = new Qs(Qs);
                var udtOp = new U3(x);
                var udtQ = new Q(q2);
                var t4 = new T4((3L, (1.1, false, Result.One)));
                var t5 = new T5((Pauli.PauliX, Qs, qs, Q));
                var plain = qsim.Get<BPlain1>();
                var adj = qsim.Get<BAdj1>();
                var ctrl = qsim.Get<BCtrl1>();
                var mapper = qsim.Get<Circuits.ClosedType.Map>();

                Assert.Equal("()", typeof(QVoid).QSharpType());
                Assert.Equal("_", _.GetType().QSharpType());
                Assert.Equal("U3", udtOp.GetType().QSharpType());
                Assert.Equal("Qubit => () : Adjoint, Controlled", udtOp.Data.GetType().QSharpType());
                Assert.Equal("Qubit", q2.GetType().QSharpType());
                Assert.Equal("Q", udtQ.GetType().QSharpType());
                Assert.Equal("Qubit", udtQ.Data.GetType().QSharpType());
                Assert.Equal("T4", t4.GetType().QSharpType());
                Assert.Equal("(Int,(Double,Boolean,Result))", t4.Data.GetType().QSharpType());
                Assert.Equal("T5", t5.GetType().QSharpType());
                Assert.Equal("(Pauli,Qubit[],Qs,Q)", t5.Data.GetType().QSharpType());
                Assert.Equal("Qubit => () : Adjoint, Controlled", x.GetType().QSharpType());
                Assert.Equal("Qubit => () : Adjoint, Controlled", x.Adjoint.GetType().QSharpType());
                Assert.Equal("(Qubit[],Qubit) => () : Adjoint, Controlled", x.Controlled.GetType().QSharpType());
                Assert.Equal("(Qubit[],Qubit) => () : Adjoint, Controlled", x.Controlled.Adjoint.GetType().QSharpType());
                Assert.Equal("(Int,Qubit,Callable) => ()", plain.GetType().QSharpType());
                Assert.Equal("(Int,(Qubit,Qubit,Qubit[]),Adjointable) => () : Adjoint", adj.GetType().QSharpType());
                Assert.Equal("(Int,Qs,Controllable) => () : Controlled", ctrl.GetType().QSharpType());
                Assert.Equal("(Callable,Result[]) => String[]", mapper.GetType().QSharpType());
            });
        }

        private void TestOneOp<I, O>(string name, string fullName, OperationFunctor variant, string signature, AdjointedOperation<I, O> op)
        {
            var proxy = new AdjointedOperation<I, O>.DebuggerProxy(op);
            TestOneProxy(name, fullName, variant, signature, proxy);
        }

        private void TestOneOp<I, O>(string name, string fullName, OperationFunctor variant, string signature, ControlledOperation<I, O> op)
        {
            var proxy = new ControlledOperation<I, O>.DebuggerProxy(op);
            TestOneProxy(name, fullName, variant, signature, proxy);
        }

        private void TestOneOp<I, O>(string name, string fullName, OperationFunctor variant, string signature, Operation<I, O> op)
        {
            TestOneProxy(name, fullName, variant, signature, new Operation<I, O>.DebuggerProxy(op));
        }

        private void TestOneProxy<I,O>(string name, string fullName, OperationFunctor variant, string signature, Operation<I, O>.DebuggerProxy proxy)
        {
            Assert.Equal(name, proxy.Name);
            Assert.Equal(fullName, proxy.FullName);
            Assert.Equal(variant, proxy.Variant);
            Assert.Equal(signature, proxy.Signature);
        }

        [Fact]
        public void NonGenericDebuggerProxy()
        {
            Helper.RunWithMultipleSimulators((qsim) =>
            {
                var x = qsim.Get<Intrinsic.X>();
                var plain = qsim.Get<BPlain1>();
                var adj = qsim.Get<BAdj1>();
                var ctrl = qsim.Get<BCtrl1>();
                var mapper = qsim.Get<Circuits.ClosedType.Map>();

                TestOneOp("X", "Microsoft.Quantum.Intrinsic.X", OperationFunctor.Body , "Qubit => () : Adjoint, Controlled", x);
                TestOneOp("X", "Microsoft.Quantum.Intrinsic.X", OperationFunctor.Adjoint , "Qubit => () : Adjoint, Controlled", x.Adjoint);
                TestOneOp("X", "Microsoft.Quantum.Intrinsic.X", OperationFunctor.Controlled , "(Qubit[],Qubit) => () : Adjoint, Controlled", x.Controlled);
                TestOneOp("X", "Microsoft.Quantum.Intrinsic.X", OperationFunctor.ControlledAdjoint , "(Qubit[],Qubit) => () : Adjoint, Controlled", x.Adjoint.Controlled);
                TestOneOp("BPlain1", "Microsoft.Quantum.Tests.CoreOperations.BPlain1", OperationFunctor.Body, "(Int,Qubit,Callable) => ()", plain);
                TestOneOp("BAdj1", "Microsoft.Quantum.Tests.CoreOperations.BAdj1", OperationFunctor.Body, "(Int,(Qubit,Qubit,Qubit[]),Adjointable) => () : Adjoint", adj);
                TestOneOp("BAdj1", "Microsoft.Quantum.Tests.CoreOperations.BAdj1", OperationFunctor.Adjoint, "(Int,(Qubit,Qubit,Qubit[]),Adjointable) => () : Adjoint", adj.Adjoint);
                TestOneOp("BCtrl1", "Microsoft.Quantum.Tests.CoreOperations.BCtrl1", OperationFunctor.Body, "(Int,Qs,Controllable) => () : Controlled", ctrl);
                TestOneOp("BCtrl1", "Microsoft.Quantum.Tests.CoreOperations.BCtrl1", OperationFunctor.Controlled, "(Qubit[],(Int,Qs,Controllable)) => () : Controlled", ctrl.Controlled);
                TestOneOp("Map", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.ClosedType.Map", OperationFunctor.Body, "(Callable,Result[]) => String[]", mapper);
            });
        }

        private void TestOneProxy<P, I, O>(string signature, OperationPartial<P, I, O> op)
        {
            var proxy = new OperationPartial<P, I, O>.DebuggerProxy(op);

            Assert.Equal(op.BaseOp, proxy.Base);
            Assert.Equal(signature, proxy.Signature);
        }

        [Fact]
        public void NonGenericPartialDebuggerProxy()
        {
            Helper.RunWithMultipleSimulators((qsim) =>
            {
                var x = qsim.Get<Intrinsic.X>();
                var plain = qsim.Get<BPlain1>();
                var adj = qsim.Get<BAdj1>();
                var ctrl = qsim.Get<BCtrl1>();
                var mapper = qsim.Get<Circuits.ClosedType.Map>();

                var x_1 = x.Partial(new Func<Qubit, Qubit>(q => q));
                var x_2 = x_1.Partial(new Func<Qubit, Qubit>(q => q));
                var x_3 = x.Partial<OperationPartial<Qubit, Qubit, QVoid>>(AbstractCallable._);

                var plain_1 = plain.Partial(new Func<Qubit, (Int64, Qubit, ICallable)>((arg) => (1, arg, x)));
                var adj_1 = adj.Partial(new Func<((Qubit,Qubit,IQArray<Qubit>),IAdjointable), (Int64, (Qubit, Qubit, IQArray<Qubit>), IAdjointable)>((arg) => (3, arg.Item1, arg.Item2)));
                var adj_2 = adj_1.Adjoint.Partial(new Func<(Qubit, Qubit, IQArray<Qubit>), ((Qubit, Qubit, IQArray<Qubit>), IAdjointable)>((arg) => (arg, adj)));
                var ctrl_1 = ctrl.Partial(new Func<(Qs, IControllable), (Int64, Qs,IControllable)>((arg) => (4, arg.Item1, arg.Item2)));
                var mapper_1 = mapper.Partial(new Func<IQArray<Result>, (ICallable, IQArray<Result>)>((arg) => (x, arg)));

                TestOneProxy("Qubit => () : Adjoint, Controlled", x_1);
                TestOneProxy("Qubit => () : Adjoint, Controlled", x_2);
                TestOneProxy("Qubit => () : Adjoint, Controlled", x_3);
                TestOneProxy("((Qubit,Qubit,Qubit[]),Adjointable) => () : Adjoint", adj_1);
                TestOneProxy("(Qubit,Qubit,Qubit[]) => () : Adjoint", adj_2);
                TestOneOp("BAdj1", "Microsoft.Quantum.Tests.CoreOperations.BAdj1", OperationFunctor.Body, "(Qubit,Qubit,Qubit[]) => () : Adjoint", adj_2.Adjoint);
                TestOneProxy("(Qs,Controllable) => () : Controlled", ctrl_1);
                TestOneOp("BCtrl1", "Microsoft.Quantum.Tests.CoreOperations.BCtrl1", OperationFunctor.Controlled, "(Qubit[],(Qs,Controllable)) => () : Controlled", ctrl_1.Controlled);
                TestOneProxy("Result[] => String[]", mapper_1);
            });
        }

        private void TestOneProxy(string name, string fullName, OperationFunctor variant, string signature, GenericCallable op)
        {
            var proxy = new GenericCallable.DebuggerProxy(op);

            Assert.Equal(name, proxy.Name);
            Assert.Equal(fullName, proxy.FullName);
            Assert.Equal(variant, proxy.Variant);
        }

        [Fact]
        public void GenericDebuggerProxy()
        {
            Helper.RunWithMultipleSimulators((qsim) =>
            {
                var dump = qsim.Get<ICallable>(typeof(Microsoft.Quantum.Extensions.Diagnostics.DumpMachine<>)) as GenericCallable;
                var trace = qsim.Get<IUnitary>(typeof(Circuits.Generics.Trace<>)) as GenericCallable;
                var gen3 = qsim.Get<IControllable>(typeof(Circuits.Generics.Gen3<,,>)) as GenericCallable;

                TestOneProxy("Trace", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Trace", OperationFunctor.Body, "T => () : Adjoint, Controlled", trace);
                TestOneProxy("Trace", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Trace", OperationFunctor.Adjoint, "T => () : Adjoint, Controlled", trace.Adjoint);
                TestOneProxy("Trace", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Trace", OperationFunctor.Controlled, "(Qubit[],T) => () : Adjoint, Controlled", trace.Controlled);
                TestOneProxy("Trace", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Trace", OperationFunctor.ControlledAdjoint, "(Qubit[],T) => () : Adjoint, Controlled", trace.Adjoint.Controlled);
                TestOneProxy("DumpMachine", "Microsoft.Quantum.Extensions.Diagnostics.DumpMachine", OperationFunctor.Body, "T => ()", dump);
                TestOneProxy("Gen3", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Gen3", OperationFunctor.Body, "(__T1,(__T2,__T3),Result) => () : Controlled", gen3);
                TestOneProxy("Gen3", "Microsoft.Quantum.Simulation.Simulators.Tests.Circuits.Generics.Gen3", OperationFunctor.Controlled, "(Qubit[],(__T1,(__T2,__T3),Result)) => () : Controlled", gen3.Controlled);
            });
        }

        private void TestOneProxy(string partialTuple, GenericPartial op)
        {
            var proxy = new GenericPartial.DebuggerProxy(op);

            Assert.Equal(op.BaseOp, proxy.Base);
            Assert.Equal(partialTuple, proxy.PartialTuple);
        }

        [Fact]
        public void GenericPartialDebuggerProxy()
        {
            Helper.RunWithMultipleSimulators((qsim) =>
            {
                var _ = AbstractCallable._;

                var dump = qsim.Get<ICallable>(typeof(Microsoft.Quantum.Extensions.Diagnostics.DumpMachine<>)) as GenericCallable;
                var trace = qsim.Get<IUnitary>(typeof(Circuits.Generics.Trace<>)) as GenericCallable;
                var gen3 = qsim.Get<IControllable>(typeof(Circuits.Generics.Gen3<,,>)) as GenericCallable;

                var d_1 = dump.Partial(_);
                var d_2 = d_1.Partial(_);
                var d_3 = d_2.Adjoint.Partial(_);                

                var t_1 = trace.Adjoint.Partial(_);
                var t_2 = t_1.Controlled.Partial((_, true));

                var g_1 = gen3.Partial((_, ("hello", _), _));
                var g_2 = g_1.Partial((_, Pauli.PauliX, Result.Zero));
                var g_3 = gen3.Partial(new Func<bool, (bool, (string, Int64), Result)>(arg => (arg, ("bye", 3), Result.One)));

                TestOneProxy("_", t_1);
                TestOneProxy("(_, True)", t_2);
                TestOneProxy("_", d_1);
                TestOneProxy("_", d_2);
                TestOneProxy("(_, (hello, _), _)", g_1);
                TestOneProxy("(_, PauliX, Zero)", g_2);
                TestOneProxy("<mapper>", g_3);
            });
        }

        /// <summary>
        /// Changes the current thread culture to the invariant culture, runs the action, and then restores the original
        /// thread culture.
        /// </summary>
        /// <param name="action">The action to run within the invariant culture.</param>
        private static void WithInvariantCulture(System.Action action)
        {
            var culture = Thread.CurrentThread.CurrentCulture;
            Thread.CurrentThread.CurrentCulture = CultureInfo.InvariantCulture;
            action();
            Thread.CurrentThread.CurrentCulture = culture;
        }
    }
}
