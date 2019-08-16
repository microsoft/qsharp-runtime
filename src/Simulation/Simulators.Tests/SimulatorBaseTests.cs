// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Xunit;
using Xunit.Abstractions;

using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public static class Extensions
    {
        /// <summary>
        ///     This method is a wrapper to let the tests keep using a one Type parameter
        ///     method to fetch for Gates.
        /// </summary>
        public static T Get<T>(this SimulatorBase sim) where T : AbstractCallable
        {
            return sim.Get<T, T>();
        }
    }

    public class SimulatorBaseTests
    {
        private readonly ITestOutputHelper output;

        public SimulatorBaseTests(ITestOutputHelper output)
        {
            this.output = output;
        }

        /// <summary>
        /// Verifies that built-in operations (Allocate/Relase) can be retrieved and succesfully applied from a TrivialSimulator.
        /// </summary>
        [Fact]
        public void SimulatorBuiltInOperations()
        {
            // The SimulatorBase class only implements operations for Qubit management,
            // i.e. Allocate/Release:
            var subject = new TrivialSimulator();

            Assert.Equal(typeof(TrivialSimulator).Name, subject.Name);

            // Check whether our events for allocation and deallocation
            // are actually called.
            var calledOnAllocate = false;
            var calledOnRelease = false;
            subject.OnAllocateQubits += count => {
                output.WriteLine($"Allocate count = {count}");
                calledOnAllocate = true;
            };
            subject.OnReleaseQubits += register => {
                output.WriteLine($"Release qubits = {register}");
                calledOnRelease = true;
            };

            var allocate = subject.Get<Intrinsic.Allocate>();
            var release = subject.Get<Intrinsic.Release>();

            // Try the operations
            var qubits = allocate.Apply(3);
            Assert.True(calledOnAllocate);
            Assert.Equal(3, qubits.Length);

            release.Apply(qubits);
            Assert.True(calledOnRelease);

            subject.CheckNoQubitLeak();
        }

        /// <summary>
        /// Verifies that operations are not built-in in the TrivialSimulator can't be retrieved.
        /// </summary>
        [Fact]
        public void OperationWithNoBody()
        {
            var subject = new TrivialSimulator();
            Assert.Equal(typeof(TrivialSimulator).Name, subject.Name);

            Assert.Throws<MemberAccessException>(() =>
            {
                subject.Get<Intrinsic.X>();
            });
        }

        /// <summary>
        /// Verifies that operations that have dependencies on operations that 
        /// are not built-in in the TrivialSimulator can't be retrieved.
        /// </summary>
        [Fact]
        public void OperationWithNotImplementedDependency()
        {
            var subject = new TrivialSimulator();

            Assert.Throws<MemberAccessException>(() =>
            {
                subject.Get<DependsOnX>();
            });
        }

        /// <summary>
        /// Verifies that operations that have dependencies on operations that 
        /// are not built-in in the TrivialSimulator can't be retrieved.
        /// </summary>
        [Fact]
        public void OperationWithRecursiveDependencies()
        {
            var subject = new TrivialSimulator();

            var a = subject.Get<A>();
            var b = subject.Get<B>();

            // Make sure the last instance is correctly cached.
            var a2 = subject.Get<A>();
            var b2 = subject.Get<B>();
            Assert.Same(a, a2);
            Assert.Same(b, b2);
            Assert.Same(a, b.A);
            Assert.Same(b, a.B);
        }

        private class Nothing { }
        private class NothingSquared : Nothing { }

        /// <summary>
        /// Verifies that users can provide their own operation definitions.
        /// </summary>
        [Fact]
        public void UserDefinedOperations()
        {
            var subject = new TrivialSimulator();
            Assert.Equal(typeof(TrivialSimulator).Name, subject.Name);

            Assert.Throws<MemberAccessException>(() =>
            {
                subject.Get<Intrinsic.X>();
            });

            try
            {
                subject.Register(null, typeof(DummyX));
            }
            catch (ArgumentNullException e)
            {
                Assert.Equal("original", e.ParamName);
            }

            try
            {
                subject.Register(typeof(Intrinsic.Allocate), null);
            }
            catch (ArgumentNullException e)
            {
                Assert.Equal("replace", e.ParamName);
            }

            // You can only register an override of a class that extends Operation:
            Assert.Throws<ArgumentException>(() =>
            {
                subject.Register(typeof(Nothing), typeof(NothingSquared));
            });

            // By default, you can only register a Gate that is a subclass of the gate it's overriding: 
            Assert.Throws<ArgumentException>(() =>
            {
                subject.Register(typeof(Intrinsic.Allocate), typeof(DummyX));
            });

            subject.Register(typeof(Intrinsic.X), typeof(DummyX));
            var customX = subject.Get<Intrinsic.X>();

            Assert.Equal(typeof(DummyX), customX.GetType());
        }

        /// <summary>
        /// Verifies that user-defined operations can override Intrinsics just by following the interface.
        /// </summary>
        [Fact]
        public void OverrideWithNoInheritance()
        {
            var subject = new TrivialSimulator();
            Assert.Equal(typeof(TrivialSimulator).Name, subject.Name);

            // If providing an interface, the original gate must implement that interface
            Assert.Throws<ArgumentException>(() =>
            {
                subject.Register(typeof(Intrinsic.CNOT), typeof(LikeX), typeof(IUnitary<Qubit>));
            });

            // If providing an interface, the replacement gate must implement that interface
            Assert.Throws<ArgumentException>(() =>
            {
                subject.Register(typeof(Intrinsic.CNOT), typeof(LikeX), typeof(IUnitary<(Qubit, Qubit)>));
            });

            // You can override without inheritance, as long as both implement the same interface:
            subject.Register(typeof(Intrinsic.X), typeof(LikeX), typeof(IUnitary<Qubit>));

            // Verify the replacement work
            var x = subject.Get<IUnitary<Qubit>, Intrinsic.X>();
            Assert.NotNull(x);
            Assert.Equal(typeof(LikeX), x.GetType());
        }

        /// <summary>
        /// Verifies that operations instances are cached by the Simulator
        /// </summary>
        [Fact]
        public void OperationsCache()
        {
            var subject = new TrivialSimulator();
            Assert.Equal(typeof(TrivialSimulator).Name, subject.Name);

            var allocate1 = subject.Get<Intrinsic.Allocate>();
            var allocate2 = subject.Get<Intrinsic.Allocate>();

            Assert.Same(allocate1, allocate2);
        }

        [Fact]
        public void GenericDependencies()
        {
            var subject = new TrivialSimulator();

            // Can't get Gen because it depends on X
            Assert.Throws<MemberAccessException>(() =>
            {
                subject.Get<Gen<string>>();
            });

            // TODO: because we can't check dependencies, this
            // is not throwing an Exception, even though Gen depends on X:
            var gen1 = subject.Get<DependsOnGen>();
            Assert.NotNull(gen1);

            // Add an implementation of X:
            subject.Register(typeof(Intrinsic.X), typeof(LikeX), typeof(IUnitary<Qubit>));
            var gen2 = subject.Get<Gen<int>>();
            Assert.NotNull(gen1);

            // Asking for same T, should give same op, but asking for different T should not:
            var gen2a = subject.Get<Gen<int>>();
            var gen2b = subject.Get<Gen<string>>();

            Assert.Same(gen2, gen2a);
            Assert.NotSame(gen2, gen2b);
        }

        /// <summary>
        /// Verifies that CheckQubits work as expected
        /// </summary>
        [Fact]
        public void CheckQubits()
        {
            var sim = new TrivialSimulator();
            var allocate = sim.Get<Intrinsic.Allocate>();
            var release = sim.Get<Intrinsic.Release>();

            var qubits = allocate.Apply(1);
            var name = "foo";

            // This should work:
            sim.CheckQubits(qubits, name);

            // Calling with null will throw an Exception
            Assert.Throws<ArgumentNullException>(name, () => sim.CheckQubits(null, name));

            // Calling after release will throw an Exception
            sim.CheckQubits(qubits, name);
            release.Apply(qubits);
            Assert.Throws<ArgumentException>($"{name}[0]", () => sim.CheckQubits(qubits, name));
        }

        /// <summary>
        /// Verifies that GetQubitsAvailableToUse and GetQubitsAvailableToBorrow work correctly.
        /// </summary>
        [Fact]
        public void TestQubitCounts()
        {
            var sim = new TrivialSimulator();

            var baseCount = 32L;
            var allocCount = 10L;

            var (initialUse, initialBorrow, afterUse, afterBorrow, subBorrow, innerBorrow) = 
                Circuits.GetAvailableTest.Run(sim, allocCount).Result;

            Assert.Equal(baseCount, initialUse);
            Assert.Equal(baseCount, initialBorrow);
            Assert.Equal(baseCount - allocCount, afterUse);
            Assert.Equal(baseCount - allocCount, afterBorrow);
            Assert.Equal(baseCount, subBorrow);
            Assert.Equal(baseCount - 1, innerBorrow);
        }

        /// <summary>
        /// Verifies that recursive operations work as expected
        /// </summary>
        [Fact]
        public void TextRecursion()
        {
            var sim = new TrivialSimulator();
            var res1 = Tests.Circuits.Factorial.Run(sim, 4L).Result;
            var res2 = Tests.Circuits.OpFactorial.Run(sim, 4L).Result;
            var res3 = Tests.Circuits.GenRecursion<long>.Run(sim, 6L, 2L).Result;
            var res4 = Tests.Circuits.GenRecursion<long>.Run(sim, 6L, 2L).Result;
            Assert.Equal(24L, res1);
            Assert.Equal(24L, res2);
            Assert.Equal(6L, res3);
            Assert.Equal(6L, res4);
        }


        /// <summary>
        // This class has no implementation, is just used to make sure
        // a user can register their own Operation overrides:
        /// </summary>
        public class DummyX : Intrinsic.X
        {
            public DummyX(IOperationFactory m) : base(m)
            {
            }

            public override Func<Qubit, QVoid> Body => throw new NotImplementedException();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => throw new NotImplementedException();
        }

        /// <summary>
        /// This class is not abstract, but depends on X, which is.
        /// </summary>
        public class DependsOnX : Operation<QVoid, QVoid>, ICallable
        {
            public DependsOnX(IOperationFactory m) : base(m)
            {
            }

            string ICallable.FullName => "DependsOnX";

            public IUnitary<Qubit> X { get; set; }

            public override void Init()
            {
                this.X = this.Factory.Get<IUnitary<Qubit>, Intrinsic.X>();
            }

            public override Func<QVoid, QVoid> Body => throw new NotImplementedException();
        }

        /// <summary>
        // This class is a one qubit Unitary (like X), but
        //  it doesn't implement X. Still because it implmenets
        //  IUnitary<Qubit> we can use it to replace X.:
        /// </summary>
        public class LikeX : Unitary<Qubit>, ICallable
        {
            public LikeX(IOperationFactory m) : base(m)
            {
            }

            string ICallable.FullName => "LikeX";

            public override void Init() { }

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledAdjointBody => throw new NotImplementedException();

            public override Func<Qubit, QVoid> AdjointBody => throw new NotImplementedException();

            public override Func<(IQArray<Qubit>, Qubit), QVoid> ControlledBody => throw new NotImplementedException();

            public override Func<Qubit, QVoid> Body => throw new NotImplementedException();
        }


        /// <summary>
        /// This class has a recursive dependency with B
        /// </summary>
        public class A : Operation<QVoid, QVoid>, ICallable
        {
            public A(IOperationFactory m) : base(m)
            {
            }

            public ICallable B { get; set; }

            public override void Init()
            {
                this.B =  this.Factory.Get<ICallable, B>();
            }

            string ICallable.FullName => "A";

            public override Func<QVoid, QVoid> Body => (_) => { return QVoid.Instance; };
        }

        /// <summary>
        /// This class has a recursive depdency with A
        /// </summary>
        public class B : Operation<QVoid, QVoid>, ICallable
        {
            public B(IOperationFactory m) : base(m)
            {
            }

            string ICallable.FullName => "B";

            public ICallable A { get; set; }

            public override void Init()
            {
                this.A = this.Factory.Get<ICallable, A>();
            }

            public override Func<QVoid, QVoid> Body => (_) => { return QVoid.Instance; };
        }

        public class Gen<T> : Operation<T, QVoid>, ICallable
        {
            public Gen(IOperationFactory m) : base(m)
            {
            }

            string ICallable.FullName => "Gen";

            public override Func<T, QVoid> Body => (_) => { return QVoid.Instance; };

            public ICallable A { get; set; }

            public IUnitary<Qubit> X { get; set; }

            public override void Init()
            {
                this.A = this.Factory.Get<ICallable, A>();
                this.X = this.Factory.Get<IUnitary<Qubit>, Intrinsic.X>();
            }
        }


        public class DependsOnGen : Operation<QVoid, QVoid>, ICallable
        {
            public DependsOnGen(IOperationFactory m) : base(m)
            {
            }

            string ICallable.FullName => "DependsOnGen";

            public ICallable Gen { get; set; }

            public override Func<QVoid, QVoid> Body => (_) => { return QVoid.Instance; };

            public override void Init()
            {
                this.Gen = this.Factory.Get<ICallable>(typeof(Gen<>));
            }
        }
    }
}
