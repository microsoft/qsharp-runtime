using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;

namespace Microsoft.Quantum.Simulation.Core
{
    public static partial class Extensions
    {
        private static ConcurrentDictionary<Type, bool> _isContainerCache = new ConcurrentDictionary<Type, bool>();

        public static bool IsQubitsContainer(this Type t)
        {
            if (t == null || t.IsPrimitive || t.IsEnum || t == typeof(String) || t == typeof(MissingParameter))
            {
                return false;
            }

            if (_isContainerCache.TryGetValue(t, out bool __result))
            {
                return __result;
            }

            if (typeof(IApplyData).IsAssignableFrom(t))
            {
                __result = true;
            }
            else
            {
                var extractor = QubitsExtractor.Get(t);
                __result = extractor?.IsQubitContainer() ?? false;
            }

            _isContainerCache[t] = __result;
            return __result;
        }

        /// <summary>
        /// Returns all the qubits contained in a given type. 
        /// </summary>
        /// <param name="value">The object from which qubits are extracted</param>
        public static IEnumerable<Qubit> GetQubits(this object value)
        {
            if (value is IApplyData qContainer)
            {
                return qContainer.Qubits;
            }
            else if (value == null)
            {
                return null;
            }
            else if (value.GetType().IsQubitsContainer())
            {
                return QubitsExtractor.Get(value.GetType())?.Extract(value);
            }

            return null;
        }
    }
}
