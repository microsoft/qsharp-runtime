// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Simulation.Simulators.Tests.Circuits;

using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class Log<T>
    {
        public Dictionary<string, int> _log = new Dictionary<string, int>();

        public string Key(OperationFunctor functor, T tag) => $"{functor}:{tag}";        

        public int GetNumberOfCalls(OperationFunctor functor, T tag)
        {
            var key = Key(functor, tag);

            if (_log.ContainsKey(key))
            {
                return _log[key];
            }
            else
            {
                return 0;
            }
        }

        public QVoid Record(OperationFunctor functor, T tag)
        {
            var key = Key(functor, tag);

            if (_log.ContainsKey(key))
            {
                _log[key] = _log[key] + 1;
            }
            else
            {
                _log[key] = 1;
            }

            return QVoid.Instance;
        }
    }

    public class StartTracker
    {
        private List<Key> _log = new List<Key>();

        private class Key
        {
            public ICallable callable;
            public IApplyData data;
            public Type dataType;
        }

        public StartTracker(SimulatorBase s)
        {
            s.OnOperationStart += this.OnStart;
        }

        public bool EqualData(object expected, object actual)
        {
            if (expected == null) return actual == null;

            var value = PartialMapper.CastTuple(expected.GetType(), actual);
            return expected.Equals(value);
        }


        public int GetNumberOfCalls(string name) => _log.Where(r => r.callable.FullName == name).Count();

        public int GetNumberOfCalls(string name, OperationFunctor variant) => _log.Where(r => r.callable.FullName == name && r.callable.Variant == variant).Count();

        public int GetNumberOfCalls(string name, OperationFunctor variant, object data) => _log.Where(r =>r.callable.FullName == name && r.callable.Variant == variant && EqualData(data, r.data.Value)).Count();

        private void OnStart(ICallable arg1, IApplyData arg2)
        {
            _log.Add(new Key { callable = arg1, data = arg2, dataType = arg2?.GetType() });
        }
    }

    static class OperationsTestHelper
    {
        public static TraceImpl<T> GetTracer<T>(this SimulatorBase s)
        {
            return s.Get<GenericCallable>(typeof(Tests.Circuits.Generics.Trace<>)).FindCallable(typeof(T), typeof(QVoid)) as TraceImpl<T>;
        }


        public class TracerImpl : Tests.Circuits.ClosedType.Trace
        {
            public TracerImpl(IOperationFactory m) : base(m)
            {
                this.Log = new Log<string>();
            }

            public override Func<string, QVoid> Body => (tag) => this.Log.Record(OperationFunctor.Body, tag);
            public override Func<string, QVoid> AdjointBody => (tag) => this.Log.Record(OperationFunctor.Adjoint, tag);
            public override Func<(IQArray<Qubit>, string), QVoid> ControlledBody => (args) => this.Log.Record(OperationFunctor.Controlled, args.Item2);
            public override Func<(IQArray<Qubit>, string), QVoid> ControlledAdjointBody => (args) => this.Log.Record(OperationFunctor.ControlledAdjoint, args.Item2);

            public Log<string> Log { get; }
        }

        public class TraceImpl<T> : Tests.Circuits.Generics.Trace<T>
        {
            public TraceImpl(IOperationFactory m) : base(m)
            {
                this.Log = new Log<T>();
            }

            public override Func<T, QVoid> Body => (tag) => this.Log.Record(OperationFunctor.Body, tag);
            public override Func<T, QVoid> AdjointBody => (tag) => this.Log.Record(OperationFunctor.Adjoint, tag);
            public override Func<(IQArray<Qubit>, T), QVoid> ControlledBody => (args) => this.Log.Record(OperationFunctor.Controlled, args.Item2);
            public override Func<(IQArray<Qubit>, T), QVoid> ControlledAdjointBody => (args) => this.Log.Record(OperationFunctor.ControlledAdjoint, args.Item2);

            public int GetNumberOfCalls(OperationFunctor functor, T tag) => this.Log.GetNumberOfCalls(functor, tag);

            public Log<T> Log { get; }
        }

        private static void InitSimulator(SimulatorBase sim)
        {
            sim.InitBuiltinOperations(typeof(OperationsTestHelper));
            sim.Register(typeof(Tests.Circuits.Generics.Trace<>), typeof(TraceImpl<>), typeof(IUnitary));

            // For Toffoli, replace H with I.
            if (sim is ToffoliSimulator)
            {
                sim.Register(typeof(Intrinsic.H), typeof(Intrinsic.I), typeof(IUnitary));
            }
        }

        public static void RunWithMultipleSimulators(Action<SimulatorBase> test)
        {
            var simulators = new SimulatorBase[] { new QuantumSimulator(), new ToffoliSimulator() };

            foreach (var s in simulators)
            {
                InitSimulator(s);

                test(s);

                if (s is IDisposable sim)
                {
                    sim.Dispose();
                }
            }
        }

        /// <summary>
        /// A shell for simple Apply tests.
        /// </summary>
        internal static void applyTestShell<I, O>(SimulatorBase sim, ICallable<I, O> operation, Action<Qubit> test)
        {
            var allocate = sim.Get<Intrinsic.Allocate>();
            var release = sim.Get<Intrinsic.Release>();

            var qbits = allocate.Apply(1);

            var q = qbits[0];
            operation.Apply(q);    // this is ok.

            test(q);

            operation.Apply(q);    // still ok.
            release.Apply(qbits);
        }


        /// <summary>
        /// Verifies general conditions that may cause errors on the Controlled method.
        /// </summary>
        internal static void ctrlErrorConditionsTests(SimulatorBase sim, Action<(IQArray<Qubit>, Qubit)> operationControlled)
        {
            ctrlOnReleasedQubitTest(sim, operationControlled);

            ctrlOnReleasedCtrlQubitTest(sim, operationControlled);
        }

        /// <summary>
        /// A shell for simple Controlled tests. It calls the controlled operation with 0..4 control qubits
        /// set to all possible combination of 1 & 0.
        /// </summary>
        internal static void ctrlTestShell(SimulatorBase sim, Action<(IQArray<Qubit>, Qubit)> operationControlled, Action<bool, IQArray<Qubit>, Qubit> test)
        {
            var allocate = sim.Get<Intrinsic.Allocate>();
            var release = sim.Get<Intrinsic.Release>();
            var set = sim.Get<SetQubit>();

            // Number of control bits to use
            for (int n = 0; n < 4; n++)
            {
                IQArray<Qubit> qbits = allocate.Apply(1);
                IQArray<Qubit> ctrls = allocate.Apply(n);

                Qubit q = qbits[0];
                operationControlled((ctrls, q));    // this is ok.

                // Iterate through all possible combinations of ctrl values:
                for (int i = 0; i < (1 << n); i++)
                {
                    // set control bits to match i:
                    for (int j = 0; j < n; j++)
                    {
                        var value = (i & (1 << j)) == 0
                            ? Result.Zero
                            : Result.One;

                        set.Apply((value, ctrls[j]));
                    }

                    // controlled is enabled only when all ctrls are 1 (e.g. last one):
                    bool enabled = (i == ((1 << n) - 1));
                    test(enabled, ctrls, q);
                }

                operationControlled((ctrls, q));    // still ok.
                release.Apply(qbits);
                release.Apply(ctrls);

                sim.CheckNoQubitLeak();
            }
        }

        /// <summary>
        /// Verifies that calling Controlled on a released qubit throws an Exception
        /// </summary>
        internal static void ctrlOnReleasedQubitTest(SimulatorBase sim, Action<(IQArray<Qubit>, Qubit)> operationControlled)
        {
            ctrlTestShell(sim, operationControlled, (enabled, ctrls, q) =>
            {
                Intrinsic.Allocate allocate = sim.Get<Intrinsic.Allocate>();
                Intrinsic.Release release = sim.Get<Intrinsic.Release>();

                IQArray<Qubit> qbits = allocate.Apply(1);
                Qubit qfake = qbits[0];
                release.Apply(qbits);

                Assert.Throws<ArgumentException>("q1", () =>
                {
                    operationControlled((ctrls, qfake));
                });

            });
        }

        /// <summary>
        /// Verifies that calling Controlled using released qubits as control throws an Exception
        /// </summary>
        internal static void ctrlOnReleasedCtrlQubitTest(SimulatorBase sim, Action<(IQArray<Qubit>, Qubit)> operationControlled)
        {
            var random = new System.Random();

            ctrlTestShell(sim, operationControlled, (enabled, ctrlQs, q) =>
            {
                if (ctrlQs == null || ctrlQs.Length == 0)
                {
                    return;
                }
                var ctrls = new QArray<Qubit>(ctrlQs); 

                // Pass in a random released qubit
                int index = random.Next((int)ctrls.Length);
                Qubit released = ctrls[index];

                Intrinsic.Allocate allocate = sim.Get<Intrinsic.Allocate>();
                Intrinsic.Release release = sim.Get<Intrinsic.Release>();

                IQArray<Qubit> qbits = allocate.Apply(1);
                Qubit qfake = qbits[0];
                release.Apply(qbits);
                ctrls.Modify(index, qfake);

                Assert.Throws<ArgumentException>($"ctrls[{index}]", () =>
                {
                    operationControlled((ctrls, q));
                });

                // Put real qubit back in place of released:
                ctrls.Modify(index, released);
            });
        }

        internal static void CheckNoQubitLeak(this SimulatorBase sim)
        {
            Assert.True(sim.QubitManager.GetAllocatedQubitsCount() == 0);
        }

        /// <summary>
        /// Verifies that multiple situations where over-allocating might happen throw an Exception.
        /// </summary>
        internal static void overAllocationTest(uint n, Func<long, QArray<Qubit>> allocate, Action<QArray<Qubit>> release)
        {
            // Allocating more than available
            try
            {
                allocate(n + 1);
            }
            catch (NotEnoughQubits e)
            {
                Assert.Equal((int)n, e.Available);
                Assert.Equal(n + 1, e.Requested);
            }

            // Allocating max, then trying to allocate one more:
            var qubits = allocate(n);
            Assert.Throws<NotEnoughQubits>(() =>
            {
                allocate(1);
            });
            release(qubits);

            // Allocating and releasing should be fine,
            // then allocate one max (ok), and finally allocating one more:
            qubits = allocate(n);
            release(qubits);

            var qubits2 = allocate(1);
            release(qubits2);

            qubits = allocate(n);
            Assert.Throws<NotEnoughQubits>(() =>
            {
                allocate(1);
            });
            release(qubits);


            // Allocating max, release one in the middle. 
            // then re-allocate to max (ok), and finally allocating one more:
            qubits = allocate(n);
            release(new QArray<Qubit>(qubits[1]));

            qubits = new QArray<Qubit>(qubits.Where(q => q.Id != 1)); // Remove released qubit from qubits:
            qubits2 = allocate(1);

            Assert.Throws<NotEnoughQubits>(() =>
            {
                allocate(1);
            });
            release(qubits);
            release(qubits2);
        }

        public static Action<I> AsAction<I>(this Func<I, QVoid> gate)
        {
            return (q) =>
            {
                gate.Invoke(q);
            };
        }

        public static void IgnoreDebugAssert(this Action action)
        {
            IgnorableAssert.Disable();
            try
            {
                action.Invoke();
            }
            finally
            {
                IgnorableAssert.Enable();
            }
        }

    }

}
