#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

namespace Simulator
{
    public class ResourcesEstimatorWithAdditionalPrimitiveOperations : ResourcesEstimator
    {
        public ResourcesEstimatorWithAdditionalPrimitiveOperations() : this(ResourcesEstimator.RecommendedConfig())
        {
        }

        public ResourcesEstimatorWithAdditionalPrimitiveOperations(QCTraceSimulatorConfiguration config) : base(WithoutPrimitiveOperationsCounter(config))
        {
        }

        private static QCTraceSimulatorConfiguration WithoutPrimitiveOperationsCounter(QCTraceSimulatorConfiguration config)
        {
            config.UsePrimitiveOperationsCounter = false;
            return config;
        }

        protected virtual IDictionary<string, IEnumerable<Type>>? AdditionalOperations { get; }

        protected override void InitializeQCTracerCoreListeners(IList<IQCTraceSimulatorListener> listeners)
        {
            base.InitializeQCTracerCoreListeners(listeners);

            // add custom primitive operations listener
            var primitiveOperationsIdToNames = new Dictionary<int, string>();
            Utils.FillDictionaryForEnumNames<PrimitiveOperationsGroups, int>(primitiveOperationsIdToNames);

            var operationNameToId = new Dictionary<string, int>();

            if (AdditionalOperations != null)
            {
                foreach (var name in AdditionalOperations.Keys)
                {
                    var id = primitiveOperationsIdToNames.Count;
                    operationNameToId[name] = id;
                    primitiveOperationsIdToNames.Add(id, name);
                }
            }

            var cfg = new PrimitiveOperationsCounterConfiguration { primitiveOperationsNames = primitiveOperationsIdToNames.Values.ToArray() };
            var operationsCounter = new PrimitiveOperationsCounter(cfg);
            tCoreConfig.Listeners.Add(operationsCounter);

            if (AdditionalOperations != null)
            {
                var compare = new AssignableTypeComparer();
                this.OnOperationStart += (callable, data) => {
                    var unwrapped = callable.UnwrapCallable();
                    foreach (var (name, types) in AdditionalOperations)
                    {
                        if (types.Contains(unwrapped.GetType(), compare))
                        {
                            var adjName = $"Adjoint{name}";

                            var key = (callable.Variant == OperationFunctor.Adjoint || callable.Variant == OperationFunctor.ControlledAdjoint) && AdditionalOperations.ContainsKey(adjName)
                                        ? adjName
                                        : name;

                            operationsCounter.OnPrimitiveOperation(operationNameToId[key], new object[] { }, 0.0);
                            break;
                        }
                    }
                };
            }
        }

        private class AssignableTypeComparer : IEqualityComparer<Type>
        {
            public bool Equals([AllowNull] Type x, [AllowNull] Type y)
            {
                return x != null && x.IsAssignableFrom(y);
            }

            public int GetHashCode([DisallowNull] Type obj)
            {
                return obj.GetHashCode();
            }
        }
    }
}
