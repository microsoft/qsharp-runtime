// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Core;
using System.Diagnostics;
using System.Linq;
using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation
{
    /// <summary>
    /// Internals of <see cref="QCTraceSimulator"/>. For internal use only.
    /// </summary>
    public partial class QCTraceSimulatorImpl : SimulatorBase
    {
        protected readonly QCTraceSimulatorConfiguration configuration;
        private readonly QCTraceSimulatorCore tracingCore;
        private readonly double[] gateTimes;
        protected readonly QCTraceSimulatorCoreConfiguration tCoreConfig;

        private Dictionary<int, string> primitiveOperationsIdToNames =
            new Dictionary<int, string>();

        protected Dictionary<string, ICallGraphStatistics> metricNameToListener;

        public override string Name => "Tracer";

        protected double GetMetricStatistic(
            string operationName,
            string metric,
            string statistic,
            string callerName = CallGraphEdge.CallGraphRoot,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            ICallGraphStatistics st = metricNameToListener[metric];
            return st.Results.GetStatistic(new CallGraphEdge((HashedString)operationName, (HashedString)callerName, functor, callerFunctor), metric, statistic);
        }

        protected double GetMetric(
            string operationName,
            string metric,
            string callerName = CallGraphEdge.CallGraphRoot,
            OperationFunctor functor = OperationFunctor.Body,
            OperationFunctor callerFunctor = OperationFunctor.Body)
        {
            double min = GetMetricStatistic(operationName, metric, MinMaxStatistic.Statistics.Min, callerName, functor, callerFunctor);
            double max = GetMetricStatistic(operationName, metric, MinMaxStatistic.Statistics.Max, callerName, functor, callerFunctor);
            if (min != max)
            {
                throw new Exception($"Given metric value is a distribution. {nameof(GetMetricStatistic)} to get the distribution parameters");
            }
            return min;
        }

        protected string GetOperationName<T>()
        {
            return this.GetInstance(typeof(T)).GetType().FullName;
        }


        public QCTraceSimulatorImpl() : this(new QCTraceSimulatorConfiguration()) { }

        public QCTraceSimulatorImpl(QCTraceSimulatorConfiguration config)
        {
            configuration = Utils.DeepClone(config);
            Utils.FillDictionaryForEnumNames<PrimitiveOperationsGroups, int>(primitiveOperationsIdToNames);

            gateTimes = new double[primitiveOperationsIdToNames.Keys.Count];
            for (int i = 0; i < primitiveOperationsIdToNames.Keys.Count; ++i)
            {
                if (!config.TraceGateTimes.ContainsKey((PrimitiveOperationsGroups)i))
                {
                    throw new Exception($"Gate time for {primitiveOperationsIdToNames[i]} must be specified.");
                }

                gateTimes[i] = config.TraceGateTimes[(PrimitiveOperationsGroups)i];
            }

            tCoreConfig = new QCTraceSimulatorCoreConfiguration {
                ThrowOnUnconstrainedMeasurement = configuration.ThrowOnUnconstrainedMeasurement,
                OptimizeDepth = configuration.OptimizeDepth
            };

            tCoreConfig.CallStackDepthLimit = config.CallStackDepthLimit; 

            InitializeQCTracerCoreListeners(tCoreConfig.Listeners);

            metricNameToListener = new Dictionary<string, ICallGraphStatistics>();
            foreach (IQCTraceSimulatorListener l in tCoreConfig.Listeners)
            {
                if (l is ICallGraphStatistics li)
                {
                    string[] variableNames = li.Results.GetVariablesNamesCopy();
                    foreach (string metric in variableNames)
                    {
                        metricNameToListener.Add(metric, li);
                    }
                }
            }

            tracingCore = new QCTraceSimulatorCore(tCoreConfig);

            OnOperationStart += tracingCore.OnOperationStart;
            OnOperationEnd += tracingCore.OnOperationEnd;

            RegisterPrimitiveOperationsGivenAsCircuits();
        }

        /// <summary>
        /// This function can be overridden to add more listeners of
        /// type <see cref="IQCTraceSimulatorListener"/>
        /// </summary>
        protected virtual void InitializeQCTracerCoreListeners(IList<IQCTraceSimulatorListener> listeners)
        {
            if (configuration.UseInvalidatedQubitsUseChecker)
            {
                listeners.Add(new InvalidatedQubitsUseChecker());
            }

            if (configuration.UseDistinctInputsChecker)
            {
                listeners.Add(new DistinctInputsChecker());
            }

            if (configuration.UsePrimitiveOperationsCounter)
            {
                PrimitiveOperationsCounterConfiguration cfg = new PrimitiveOperationsCounterConfiguration
                {
                    primitiveOperationsNames = primitiveOperationsIdToNames.Values.ToArray()
                };
                listeners.Add(new PrimitiveOperationsCounter(cfg));
            }

            if (configuration.UseDepthCounter)
            {
                listeners.Add(new DepthCounter(optimizeDepth: configuration.OptimizeDepth));
            }

            if (configuration.UseWidthCounter)
            {
                listeners.Add(new WidthCounter());
            }
        }

        private void RegisterPrimitiveOperationsGivenAsCircuits()
        {
            IEnumerable<Type> primitiveOperationTypes =
                from op in typeof(Intrinsic.X).Assembly.GetExportedTypes()
                where op.IsSubclassOf(typeof(AbstractCallable))
                select op;

            IEnumerable<Type> primitiveOperationAsCircuits =
                from op in typeof(Circuits.X).Assembly.GetExportedTypes()
                where op.IsSubclassOf(typeof(AbstractCallable))
                      && op.Namespace == typeof(Circuits.X).Namespace
                select op;

            foreach (Type operationType in primitiveOperationTypes)
            {
                IEnumerable<Type> machingCircuitTypes =
                    from op in primitiveOperationAsCircuits
                    where op.Name == operationType.Name
                    select op;

                int numberOfMatchesFound = machingCircuitTypes.Count();
                Debug.Assert(
                     numberOfMatchesFound <= 1,
                    "There should be at most one matching operation.");
                if (numberOfMatchesFound == 1)
                {
                    Register(operationType, machingCircuitTypes.First(), operationType.ICallableType());
                }
            }
        }

        #region Primitive operations logic 

        private void DoPrimitiveOperation(PrimitiveOperationsGroups operation, IQArray<Qubit> target, bool invalidateConstraints = true)
        {
            tracingCore.DoPrimitiveOperation((int)operation, target,
                gateTimes[(int)operation], invalidateConstraints);
        }

        private void CX(Qubit control, Qubit target)
        {
            DoPrimitiveOperation(PrimitiveOperationsGroups.CNOT, new QArray<Qubit>(control, target));
        }

        private void Clifford(long id, Pauli pauli, Qubit target)
        {
            DoPrimitiveOperation(PrimitiveOperationsGroups.QubitClifford, new QArray<Qubit>(target));
        }

        private void RFrac(Pauli pauli, long numerator, long denominatorPower, Qubit target)
        {
            if( pauli == Pauli.PauliI)
            {
                return; // global phase case
            }

            (long numNew, long denomPowerNew) = CommonUtils.Reduce(numerator, denominatorPower);
            switch (denomPowerNew)
            {
                case 3:
                    long power = ((numNew % 8) + 8) % 8;
                    if (power == 3 || power == 5)
                    {
                        DoPrimitiveOperation(
                           PrimitiveOperationsGroups.QubitClifford,
                           new QArray<Qubit>(target));
                    }
                    DoPrimitiveOperation(
                       PrimitiveOperationsGroups.T,
                       new QArray<Qubit>(target));
                    break;
                case 2:
                case 1:
                    DoPrimitiveOperation(
                        PrimitiveOperationsGroups.QubitClifford,
                        new QArray<Qubit>(target));
                    break;
                default:
                    if (denomPowerNew > 0)
                    {
                        DoPrimitiveOperation(
                            PrimitiveOperationsGroups.R,
                            new QArray<Qubit>(target));
                    }
                    // when denomPowerNew is negative we just have a global phase
                    break;
            }
        }

        private void R(Pauli pauli, double angle, Qubit target)
        {
            DoPrimitiveOperation(PrimitiveOperationsGroups.R, new QArray<Qubit>(target));
        }

        private Result Measure(IQArray<Pauli> observable, IQArray<Qubit> target)
        {
            DoPrimitiveOperation(PrimitiveOperationsGroups.Measure, target, false);
            return tracingCore.Measure(observable, target);
        }
        #endregion
    }
}
