// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Tests.StartOperation;
using System;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    using Helper = Microsoft.Quantum.Simulation.Simulators.Tests.OperationsTestHelper;

    public class StartOperationTests
    {
        [Fact]
        public void StartOperationCalls()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var tracker = new StartTracker(s);
                StartOperationTest.Run(s).Wait();

                var q0 = new FreeQubit(0) as Qubit;
                var q1 = new FreeQubit(1) as Qubit;
                var q2 = new FreeQubit(2) as Qubit;
                var q3 = new FreeQubit(3) as Qubit;

                Assert.Equal(1, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.StartOperationTest"));

                var allVariantsBody = 3;
                var allVariantsAdjoint = 2;
                var allVariantsCtrl = 2;
                var allVariantsAdjointCtrl = 1;
                var allVariants = allVariantsBody + allVariantsAdjoint + allVariantsCtrl + allVariantsAdjointCtrl;
                Assert.Equal(allVariants, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants"));
                Assert.Equal(allVariantsBody, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Body));
                Assert.Equal(allVariantsAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Adjoint));
                Assert.Equal(allVariantsCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Controlled));
                Assert.Equal(allVariantsAdjointCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.ControlledAdjoint));

                var basicBody = 9;
                var basicAdjoint = 7;
                var basicCtrl = 9;
                var basicCtrlAdjoint = 7;
                var basic = basicBody + basicAdjoint + basicCtrl + basicCtrlAdjoint;
                Assert.Equal(basic, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic"));
                Assert.Equal(basicBody, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Body));
                Assert.Equal(basicAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Adjoint));
                Assert.Equal(basicCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Controlled));
                Assert.Equal(basicCtrlAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.ControlledAdjoint));

                var data1 = (0L, q1, (q2, q3), Result.One);
                Assert.Equal(3, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Body, data1));
                Assert.Equal(3, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Adjoint, data1));

                var data2 = (1L, q1, (q2, q3), Result.Zero);
                Assert.Equal(6, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Body, data2));
                Assert.Equal(4, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Adjoint, data2));

                Assert.Equal(basic * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X"));
                Assert.Equal(basicBody * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Body));
                Assert.Equal(basicAdjoint * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Adjoint));
                Assert.Equal(basicCtrl * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Controlled));
                Assert.Equal(basicCtrlAdjoint * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.ControlledAdjoint));
            });
        }

        [Fact]
        public void StartUDTOperationCalls()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var tracker = new StartTracker(s);
                StartOperationUDTTest.Run(s).Wait();

                Assert.Equal(1, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.StartOperationUDTTest"));

                var allVariantsBody = 3;
                var allVariantsAdjoint = 2;
                var allVariantsCtrl = 2;
                var allVariantsAdjointCtrl = 1;
                var allVariants = allVariantsBody + allVariantsAdjoint + allVariantsCtrl + allVariantsAdjointCtrl;
                Assert.Equal(allVariants, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants"));
                Assert.Equal(allVariantsBody, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Body));
                Assert.Equal(allVariantsAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Adjoint));
                Assert.Equal(allVariantsCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.Controlled));
                Assert.Equal(allVariantsAdjointCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.AllVariants", OperationFunctor.ControlledAdjoint));

                var basicBody = 12;
                var basicAdjoint = 7;
                var basicCtrl = 9;
                var basicCtrlAdjoint = 7;
                var basic = basicBody + basicAdjoint + basicCtrl + basicCtrlAdjoint;
                Assert.Equal(basic, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic"));
                Assert.Equal(basicBody, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Body));
                Assert.Equal(basicAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Adjoint));
                Assert.Equal(basicCtrl, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.Controlled));
                Assert.Equal(basicCtrlAdjoint, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.Basic", OperationFunctor.ControlledAdjoint));
                
                // Because of unwrapping, udts are not called directly, only their base operation:
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT1"));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT1", OperationFunctor.Body));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT1", OperationFunctor.Adjoint));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT1", OperationFunctor.Controlled));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT1", OperationFunctor.ControlledAdjoint));

                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT2"));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT2", OperationFunctor.Body));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT2", OperationFunctor.Adjoint));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT2", OperationFunctor.Controlled));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT2", OperationFunctor.ControlledAdjoint));

                Assert.Equal(basic * 4 + 2, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X"));
                Assert.Equal(basicBody * 4 + 2, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Body));
                Assert.Equal(basicAdjoint * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Adjoint));
                Assert.Equal(basicCtrl * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.Controlled));
                Assert.Equal(basicCtrlAdjoint * 4, tracker.GetNumberOfCalls("Microsoft.Quantum.Intrinsic.X", OperationFunctor.ControlledAdjoint));

                var b3Body = 8;
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT3"));
                Assert.Equal(0, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.UDT3", OperationFunctor.Body));
                Assert.Equal(b3Body, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.B3"));
                Assert.Equal(b3Body, tracker.GetNumberOfCalls("Microsoft.Quantum.Tests.StartOperation.B3", OperationFunctor.Body)); ;
            });
        }


        [Fact]
        public void StartDataIn()
        {
            Helper. RunWithMultipleSimulators((s) =>
            {
                var basic = s.Get<Basic>();
                var q1 = new FreeQubit(1);
                var q2 = new FreeQubit(2);
                var q3 = new FreeQubit(3);
                var expected = (1L, q1, (q2, q3), Result.One);

                var m1 = new Func<(Qubit, Qubit), (Int64, Qubit, (Qubit, Qubit), Result)>((_arg1) => (1L, q1, (_arg1.Item1, _arg1.Item2), Result.One));
                var m2 = new Func<Qubit, (Qubit, Qubit)>((_arg2) => (_arg2, q3));
                var p1 = basic.Partial(m1);
                var p2 = p1.Partial(m2);

                AssertTuple(expected, p1.__dataIn((q2, q3)).Value);
                AssertTuple(expected, p2.__dataIn((q2)).Value);

                Assert.Equal(new Qubit[] { q1, q2, q3 }, p1.__dataIn((q2, q3)).Qubits);
                Assert.Equal(new Qubit[] { q1, q2, q3 }, p2.__dataIn(q2).Qubits);

                Assert.Null(((IApplyData)basic).Qubits);
                Assert.Equal(new Qubit[] { q1, null, null }, ((IApplyData)p1).Qubits);
                Assert.Equal(new Qubit[] { q1, null, q3 }, ((IApplyData)p2).Qubits);
            });
        }

        [Fact]
        public void StartUDTDataIn()
        {
            Helper.RunWithMultipleSimulators((s) =>
            {
                var basic = new UDT1(s.Get<Basic>());
                var q1 = new FreeQubit(1);
                var q2 = new FreeQubit(2);
                var q3 = new FreeQubit(3);
                var expected = (1L, q1, (q2, q3), Result.One);

                var m1 = new Func<(Qubit, Qubit), (Int64, Qubit, (Qubit, Qubit), Result)>((_arg1) => (1L, q1, (_arg1.Item1, _arg1.Item2), Result.One));
                var m2 = new Func<Qubit, (Qubit, Qubit)>((_arg2) => (_arg2, q3));
                var p1 = ((Basic)basic.Data).Partial(m1);
                var p2 = p1.Partial(m2);

                AssertTuple(expected, p1.__dataIn((q2, q3)).Value);
                AssertTuple(expected, p2.__dataIn((q2)).Value);

                Assert.Equal(new Qubit[] { q1, q2, q3 }, p1.__dataIn((q2, q3)).Qubits);
                Assert.Equal(new Qubit[] { q1, q2, q3 }, p2.__dataIn(q2).Qubits);

                Assert.Null(((IApplyData)basic).Qubits);
                Assert.Equal(new Qubit[] { q1, null, null }, ((IApplyData)p1).Qubits);
                Assert.Equal(new Qubit[] { q1, null, q3 }, ((IApplyData)p2).Qubits);
            });
        }

        private static void AssertTuple(object expected, object actual)
        {
            var value = PartialMapper.CastTuple(expected.GetType(), actual);
            Assert.Equal(expected, value);
        }
    }
}
