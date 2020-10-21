// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using Microsoft.Quantum.Simulation.Core;
    using System;
    using System.Collections.Generic;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Common;
    using System.Linq;

    [Serializable]
    public class QCTraceSimulatorCoreConfiguration
    {
        /// <summary>
        /// If set to true,  TracingSimulatorCore will throw an exception every time there is a
        /// measurement that has not been annotated via AssertProb or DebugForceMeasure.
        /// This is mainly useful in combination with interactive debugging. This way it is easier
        /// to identify all the measurements that have not been annotated and fix them.
        /// </summary>
        public bool ThrowOnUnconstrainedMeasurement { get; set; }

        [NonSerialized]
        public IList<IQCTraceSimulatorListener> Listeners = new List<IQCTraceSimulatorListener>();

        /// <summary>
        /// Bounds the call stack depth for which information per call graph edge is stored.
        /// The depth of a given node in the call graph is the distance from the node to the root
        /// of the call graph.
        /// </summary>
        public uint CallStackDepthLimit = uint.MaxValue;
    }

    /// <summary>
    /// Core of the simulator that drives the execution path of quantum algorithm
    /// without simulating quantum state. Instead relies on additional information
    /// provided by the user regarding the measurement outcomes. This information
    /// is provided to the class via :
    /// <code>
    /// AssertMeasureProb(QArray<Pauli> observable, QArray<Qubit> qubits, Result value, double probability)
    /// AssertMeasure(QArray<Pauli> observable, QArray<Qubit> qubits, Result value)
    /// ForceMeasure(QArray<Pauli> observable, QArray<Qubit> qubits, Result value)
    /// </code>
    /// Given this information, when Measure is called the appropriate value is returned.
    /// If no information regarding the measurement outcome was provided,
    /// value of
    /// <code>
    /// UnconstrainedMeasurementResult()
    /// </code>
    /// is returned. Currently it is Result.Zero. Number of unconstrained
    /// measurements that happened is collected in NumberOfUnconstrainedMeasurements
    /// property.
    /// </summary>
    public class QCTraceSimulatorCore
    {
        private readonly IQubitManager qubitManager;
        private readonly bool tracingDataInQubitsIsNeeded = false;
        private readonly QCTraceSimulatorCoreConfiguration configuration;

        public QCTraceSimulatorCoreConfiguration GetCoreConfigurationCopy() { return Utils.DeepClone(configuration); }
        protected Action OnUnconstrainedMeasurement { get; set; }

        /// <summary>
        /// Random number generator used to sample measurement outcomes according to the
        /// probability distribution specified by user.
        /// </summary>
        private Random randomGenerator;

        /// <summary>
        /// Number of unconstrained measurements that happened during execution.
        /// </summary>
        public uint NumberOfUnconstrainedMeasurements { get; private set; }

        private readonly Func<long, object>[] qubitDataInitializers;
        private readonly bool[] listenerNeedsTracingData;
        private readonly IQCTraceSimulatorListener[] listeners;
        private readonly Dictionary<OperationFunctor, string> functorNames = new Dictionary<OperationFunctor, string>();

        private uint callStackDepth = 0;
        private readonly uint callStackDepthLimit = uint.MaxValue;

        public QCTraceSimulatorCore(
            QCTraceSimulatorCoreConfiguration config
            )
        {
            Utils.FillDictionaryForEnumNames<OperationFunctor, OperationFunctor>(functorNames);

            this.listeners = config.Listeners.ToArray();
            randomGenerator = new Random();
            configuration = Utils.DeepClone(config);
            OnUnconstrainedMeasurement += OnUnconstrainedMeasurementDefault;

            qubitDataInitializers = new Func<long, object>[listeners.Length + 1];
            listenerNeedsTracingData = new bool[listeners.Length];
            qubitDataInitializers[0] = QubitConstraintInit;
            for (int i = 0; i < listeners.Length; ++i)
            {
                qubitDataInitializers[i + 1] = listeners[i].NewTracingData;
                listenerNeedsTracingData[i] = listeners[i].NeedsTracingDataInQubits;
                tracingDataInQubitsIsNeeded = listenerNeedsTracingData[i] || tracingDataInQubitsIsNeeded;
            }

            qubitManager = (IQubitManager) new TraceableQubitManager(qubitDataInitializers);
            callStackDepthLimit = Math.Max( 1, configuration.CallStackDepthLimit );
        }

        private static object QubitConstraintInit(long id)
        {
            return QubitConstraint.ZeroStateConstraint();
        }

        private static QubitConstraint[] QubitConstraints(IReadOnlyList<Qubit> qubits)
        {
            return Utils.ExtractTracingData<QubitConstraint>(qubits, 0);
        }

        private object[][] GetTracingData(IReadOnlyList<Qubit> res)
        {
            return Utils.ExtractTracingDataBulk(res, 1, listeners.Length);
        }

        public IQArray<Qubit> Allocate(long count)
        {
            if (count == 0)
            {
                return new QArray<Qubit>();
            }

            IQArray<Qubit> res = qubitManager.Allocate(count);

            object[][] tracingData = GetTracingData(res);
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnAllocate(tracingData[i]);
            }

            return res;
        }

        public IQArray<Qubit> Borrow(long count)
        {
            long qubitBeforeBorrow = qubitManager.GetAllocatedQubitsCount();
            IQArray<Qubit> res = qubitManager.Borrow(count);
            long newQubitsAllocated = qubitManager.GetAllocatedQubitsCount() - qubitBeforeBorrow;

            object[][] tracingData = GetTracingData(res);
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnBorrow(tracingData[i], newQubitsAllocated);
            }

            return res;
        }

        public void Return(Qubit qubit)
        {
            Debug.Assert(qubit != null);

            long qubitBeforeBorrow = qubitManager.GetAllocatedQubitsCount();
            qubitManager.Return(qubit);
            long qubitsReleased = qubitBeforeBorrow - qubitManager.GetAllocatedQubitsCount();

            object[][] tracingData = GetTracingData(new QArray<Qubit>(qubit));
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnReturn(tracingData[i], qubitsReleased);
            }
        }

        public void Return(IQArray<Qubit> qubits)
        {
            Debug.Assert(qubits != null);

            long qubitBeforeBorrow = qubitManager.GetAllocatedQubitsCount();
            qubitManager.Return(qubits);
            long qubitsReleased = qubitBeforeBorrow - qubitManager.GetAllocatedQubitsCount();

            object[][] tracingData = GetTracingData(qubits);
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnReturn(tracingData[i], qubitsReleased);
            }
        }

        public void Release(Qubit qubit)
        {
            Debug.Assert(qubit != null);
            object[][] tracingData = GetTracingData(new QArray<Qubit>(qubit));
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnRelease(tracingData[i]);
            }

            qubitManager.Release(qubit);
        }

        public void Release(IQArray<Qubit> qubits)
        {
            Debug.Assert(qubits != null);
            object[][] tracingData = GetTracingData(qubits);
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnRelease(tracingData[i]);
            }

            qubitManager.Release(qubits);
        }

        void OnUnconstrainedMeasurementDefault()
        {
            if (configuration.ThrowOnUnconstrainedMeasurement)
            {
                throw new UnconstrainedMeasurementException();
            }
            NumberOfUnconstrainedMeasurements += 1;
        }

        Result UnconstrainedMeasurementResult()
        {
            OnUnconstrainedMeasurement();
            return Result.Zero;
        }

        /// <summary>
        /// Implements the Q# standard library callable Measure.
        /// Not all measurements considered primitive operations. The measurements
        /// that are primitive operations are listed in
        /// MetricsCalculatorConfiguration.MeasurementToPrimitiveOperation
        /// If the measurement is not primitive, the operation will throw
        /// NonPrimitiveMeasurementException.
        /// </summary>
        public Result Measure(IQArray<Pauli> observable, IQArray<Qubit> qubits)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);

            Utils.PruneObservable(observable, qubits, out var observablePr, out var qubitsPr);

            if (observablePr.Count == 0)
            {
                return Result.Zero;
            }

            QubitConstraint[] constr = QubitConstraints(qubitsPr);

            QubitConstraint qubit0Constraint = constr[0];
            if (qubit0Constraint.Constraint == null)
            {
                return UnconstrainedMeasurementResult();
            }
            else
            {
                for (int i = 0; i < qubitsPr.Count; ++i)
                {
                    QubitConstraint qubitIConstraint = constr[i];

                    // makes sure that none of the qubits constraints have been invalidated
                    if (qubitIConstraint.Constraint == null)
                    {
                        return UnconstrainedMeasurementResult();
                    }

                    // makes sure that all qubits involved have the same constraint
                    if (qubitIConstraint.Constraint != qubit0Constraint.Constraint)
                    {
                        return UnconstrainedMeasurementResult();
                    }

                    // makes sure that constrain's observable matches observable being measured
                    if (qubitIConstraint.QubitPauli != observablePr[i])
                    {
                        return UnconstrainedMeasurementResult();
                    }
                }
            }

            // here we have ensured that all conditions we need to predict the measurement outcome are met
            MeasurementConstraint constraint = qubit0Constraint.Constraint;
            if (constraint.Type == MeasurementConstraint.ConstraintType.Force)
            {
                return constraint.ConstrainToResult;
            }
            else if (constraint.Type == MeasurementConstraint.ConstraintType.Assert)
            {
                Double sample = randomGenerator.NextDouble();
                if (sample <= constraint.Probability)
                {
                    Debug.WriteLine($"Measurement outcome with probability {constraint.Probability} happened, result is {constraint.ConstrainToResult}");
                    return constraint.ConstrainToResult;
                }
                else
                {
                    Debug.WriteLine($"Measurement outcome with probability {constraint.Probability} did not happen, result is {Utils.Opposite(constraint.ConstrainToResult)}");
                    return Utils.Opposite(constraint.ConstrainToResult);
                }
            }
            Debug.Assert(false, "This point should not be reached.");
            return UnconstrainedMeasurementResult();
        }

        /// <summary>
        /// Implements the Q# standard library callable Assert```
        /// </summary>
        public void Assert(IQArray<Pauli> observable, IQArray<Qubit> qubits, Result value)
        {
            AssertProb(observable, qubits, value, 1.0);
        }

        /// <summary>
        /// Implements the Q# standard library callable AssertProb
        /// </summary>
        public void AssertProb(IQArray<Pauli> observable, IQArray<Qubit> qubits, Result value, double probability)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);
            Debug.Assert(observable.Length == qubits.Length);

            Utils.PruneObservable(observable, qubits, out var observablePr, out var qubitsPr);
            Debug.Assert((probability >= 0.0) && (probability <= 1.0));
            MeasurementConstraint constr = MeasurementConstraint.AssertMeasurement(observablePr, value, probability);
            QubitConstraint.SetConstraint(QubitConstraints(qubitsPr), constr);
        }

        /// <summary>
        /// Ensures that measurement of given observable on given qubits will
        /// lead to result given by value
        /// </summary>
        public void ForceMeasure(IQArray<Pauli> observable, IQArray<Qubit> qubits, Result value)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);
            Debug.Assert(observable.Length == qubits.Length);

            Utils.PruneObservable(observable, qubits, out var observablePr, out var _);
            var constr = MeasurementConstraint.ForceMeasurement(observablePr, value);
            QubitConstraint.SetConstraint(QubitConstraints(qubits), constr);
        }

        /// <summary>
        /// Notifies qubits involved in Primitive operation that they have been modified.
        /// Performs calls runtime checker for distinct qubits input check.
        /// </summary>
        private void InvalidateConstraints(IReadOnlyList<Qubit> qubits)
        {
            Debug.Assert(qubits != null);
            QubitConstraint[] contraints = QubitConstraints(qubits);
            foreach (QubitConstraint c in contraints)
            {
                c.OnUseQubit();
            }
        }


        /// <summary>
        /// Callback for primitive operations
        /// </summary>
        public void DoPrimitiveOperation(int id, IQArray<Qubit> qubits, double duration, bool invalidateConstraints = true)
        {
            Debug.Assert(qubits != null);

            object[][] tracingData = GetTracingData(qubits);
            for (int i = 0; i < listeners.Length; ++i)
            {
                listeners[i].OnPrimitiveOperation(id, tracingData[i], duration);
            }

            if (invalidateConstraints)
            {
                InvalidateConstraints(qubits);
            }
        }

        public string FullOperationName(string operation, OperationFunctor functor = OperationFunctor.Body)
        {
            return operation + ":" + functorNames[functor];
        }

        public string FullOperationName(ICallable operation)
        {
            return FullOperationName(operation.FullName, operation.Variant);
        }

        /// <summary>
        /// Callback to notify tracer that an operation execution has started.
        /// Passes callBack down to metricsCalculator and runtimeChecker.
        /// </summary>
        public void OnOperationStart(ICallable operation, IApplyData inputValue)
        {
            callStackDepth += 1;
            qubitManager.OnOperationStart(operation, inputValue);

            if (listeners.Length > 0 && callStackDepth <= callStackDepthLimit )
            {
                HashedString hashedOperationName = new HashedString(operation.FullName);
                if (tracingDataInQubitsIsNeeded)
                {
                    var qubits = new List<Qubit>(inputValue?.Qubits?.Where(q => q != null) ?? Qubit.NO_QUBITS);
                    object[][] tracingData = GetTracingData(qubits);
                    for (int i = 0; i < listeners.Length; ++i)
                    {
                        listeners[i].OnOperationStart(hashedOperationName, operation.Variant, listenerNeedsTracingData[i] ? tracingData[i] : null );
                    }
                }
                else
                {
                    for (int i = 0; i < listeners.Length; ++i)
                    {
                        listeners[i].OnOperationStart(hashedOperationName, operation.Variant, null);
                    }
                }
            }
        }

        /// <summary>
        /// Callback to notify tracer that an operation execution has ended.
        /// Passes callBack down to metricsCalculator and runtimeChecker.
        /// </summary>
        public void OnOperationEnd(ICallable operation, IApplyData resultValue)
        {
            qubitManager.OnOperationEnd(operation, resultValue);
            if (listeners.Length > 0 && callStackDepth <= callStackDepthLimit)
            {
                if (tracingDataInQubitsIsNeeded)
                {
                    var qubits = new List<Qubit>(resultValue?.Qubits?.Where(q => q != null) ?? Qubit.NO_QUBITS);
                    object[][] tracingData = GetTracingData(qubits);
                    for (int i = 0; i < listeners.Length; ++i)
                    {
                        listeners[i].OnOperationEnd(tracingData[i]);
                    }
                }
                else
                {
                    for (int i = 0; i < listeners.Length; ++i)
                    {
                        listeners[i].OnOperationEnd(null);
                    }
                }
            }

            callStackDepth -= 1;
        }
    }
}
