// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Intrinsic;
using Microsoft.Quantum.Simulation.Common;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QuantumProcessor;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.NewTracer;
using Microsoft.Quantum.Simulation.Simulators.NewTracer.NewDecomposition;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using Xunit;
using Xunit.Abstractions;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests
{
    public class PrimitivesTestsQuite
    {
        private readonly ITestOutputHelper output;
        public PrimitivesTestsQuite(ITestOutputHelper output)
        {
            this.output = output;
        }

        private static void OverrideOperation<OperationType, TypeToOverride, TypeToOverrideBy>(AbstractFactory<AbstractCallable> sim)
            where TypeToOverrideBy : AbstractCallable, OperationType
            where TypeToOverride : AbstractCallable, OperationType
        {
            IOperationFactory factory = sim as IOperationFactory;
            Debug.Assert(factory != null);
            OperationType op = factory.Get<OperationType, TypeToOverrideBy>();
            sim.Register(typeof(TypeToOverride), op.GetType(), typeof(OperationType));
        }

        [Fact]
        public void SingleQubitOperationsWithControls()
        {
            void print(String s)
            {
                if(s.Contains("TESTING", StringComparison.OrdinalIgnoreCase))
                {
                    Debug.WriteLine(s);
                    Console.WriteLine(s);
                }
            }
            var sim = new DecompositionTestingSim(print);
            SingleQubitOperationsWithControlsTest.Run(sim).Wait();
        }

        [Fact]
        public void SingleQubitRotationsWithControls()
        {
            var sim = new DecompositionTestingSim((s)=>{ Debug.WriteLine(s); });
            SingleQubitRotationsWithOneControlTest.Run(sim).Wait();
        }

        [Fact]
        public void TwoQubitOperationsWithControls()
        {
            var sim = new DecompositionTestingSim((_) => { });
            TwoQubitOperationsWithControllsTest.Run(sim).Wait();
        }

        [Fact]
        public void ThreeQubitOperationsWithControls()
        {
            var sim = new DecompositionTestingSim((_) => { });
            ThreeQubitPlusOperationsWithControllsTest.Run(sim).Wait();
        }

        class DecompositionTestingSim : QuantumSimulator
        {
            QuantumProcessorDispatcher DecomposingSim;
            const string DECOMPOSER_INTERFACE_PREFIX = "_Decomposer_"; //TODO: make more unique?
            const string QPD_OP_PREFIX = "QuantumProcessorDispatcher";

            readonly Dictionary<string, AbstractCallable> dispatcherOpsCache = new Dictionary<string, AbstractCallable>();
            readonly Type[] dispatcherOpsTypes;

            readonly Action<string> Log;
 
            public DecompositionTestingSim(Action<string> log) : base()
            {
                this.OnLog += this.Log = log;
                //we decompose to the tracer's target gate set, and then call the primitive gates on this sim
                ITracerTarget bridge = new DecomposerToSimBridge(this); 
                IQuantumProcessor decomposer = new NewDecomposer(this, new[] { bridge }); //the QuantumSimulator will handle qubit allocation within the decomposer
                this.DecomposingSim = new QuantumProcessorDispatcher(decomposer, this.QubitManager);

                this.dispatcherOpsTypes = (
                    from op in typeof(QuantumProcessorDispatcher).GetNestedTypes()
                    where op.IsSubclassOf(typeof(AbstractCallable))
                    select op
                    ).ToArray();
            }

            //hacky
            //Intrinsic operations (e.g. Intrinsic.H) are called on the QuantumSimulator. If we are given the QuantumProcessorDispatcher
            //version of an intrinsic (e.g. QuantumProcessorDispatcherH), then we call that on the decomposing simulator.
            public override AbstractCallable CreateInstance(Type t)
            {
                string opName = t.Name;
                if (t.IsAbstract && t.Name.StartsWith(DECOMPOSER_INTERFACE_PREFIX))
                {
                    if (dispatcherOpsCache.TryGetValue(opName, out AbstractCallable op))
                    {
                        return op;
                    }
                    string intrinsicName = t.Name.Substring(DECOMPOSER_INTERFACE_PREFIX.Length);
                    IEnumerable<Type> matchingDispatcherTypes =
                        from opType in dispatcherOpsTypes
                        where opType.Name == QPD_OP_PREFIX + intrinsicName
                        select opType;

                    Debug.Assert(matchingDispatcherTypes.Count() == 1);
                    Type opImplementationType = matchingDispatcherTypes.First();

                    op = (AbstractCallable)Activator.CreateInstance(opImplementationType, this.DecomposingSim);
                    this.dispatcherOpsCache[opName] = op;
                    this.Init(op);
                    return op;
                }
                
                return base.CreateInstance(t);
            }

            public override void StartOperation(ICallable operation, IApplyData inputValue)
            {
                if(!operation.FullName.Contains("AsRCczTClifford") || true)
                {
                    if(operation.FullName.StartsWith("Microsoft.Quantum.Intrinsic"))
                    {
                        //Log($"{operation.Name}({operation.Variant})({inputValue}) start");
                    }
                    else
                    {
                        //Log($"//{operation.Name}({operation.Variant})({inputValue}) start");
                    }
                }
                base.StartOperation(operation, inputValue);
            }

            public class DecomposerToSimBridge : INewDecompositionTarget, IMeasurementManagementTarget
            {
                SimulatorBase Sim;

                public DecomposerToSimBridge(SimulatorBase sim)
                {
                    this.Sim = sim;
                }

                public void Z(Qubit qubit)
                {
                    Sim.Get<Z, Z>().Apply(qubit);
                }

                public void CZ(Qubit control, Qubit qubit)
                {
                    var args = (new QArray<Qubit>(control), qubit);
                    Sim.Get<Z, Z>().Controlled.Apply(args);
                }

                public void CCZ(Qubit control0, Qubit control1, Qubit qubit)
                {
                    var args = (new QArray<Qubit>(control0, control1), qubit);
                    Sim.Get<Z, Z>().Controlled.Apply(args);
                }

                public void H(Qubit qubit)
                {
                    Sim.Get<H, H>().Apply(qubit);
                }

                public void Rz(double theta, Qubit qubit)
                {
                    var args = (theta, qubit);
                    Sim.Get<Rz, Rz>().Apply(args);
                }

                public void S(Qubit qubit)
                {
                    Sim.Get<S, S>().Apply(qubit);
                }

                public void SAdjoint(Qubit qubit)
                {
                    Sim.Get<S, S>().Adjoint.Apply(qubit);
                }

                public void T(Qubit qubit)
                {
                    Sim.Get<T, T>().Apply(qubit);
                }

                public void TAdjoint(Qubit qubit)
                {
                    Sim.Get<T, T>().Adjoint.Apply(qubit);
                }

                public Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
                {
                    var args = (bases, qubits);
                    return Sim.Get<Measure, Measure>().Apply(args);
                }

                public Result M(Qubit qubit)
                {
                    return Sim.Get<M, M>().Apply(qubit);
                }

                public void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg)
                {
                    var args = (bases, qubits, result, msg);
                    Sim.Get<Diagnostics.AssertMeasurement, Diagnostics.AssertMeasurement>().Apply(args);
                }

                public void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol)
                {
                    var args = (bases, qubits, Result.Zero, probabilityOfZero, msg, tol);
                    Sim.Get<Diagnostics.AssertMeasurementProbability, Diagnostics.AssertMeasurementProbability>().Apply(args);
                }

                void INewDecompositionTarget.M(Qubit qubit)
                {
                }

                void INewDecompositionTarget.Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits)
                {
                }

                bool ITracerTarget.SupportsTarget(ITracerTarget target) => false;
            }
        }
    }
}
