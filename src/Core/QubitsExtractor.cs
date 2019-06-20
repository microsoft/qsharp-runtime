using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using System.Text;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// A QubitsExtractor uses reflection to extract the Qubits from an object, i.e., the Qubits from a ValueTuple.
    /// It is implemented as a Factory where you must call Get() to get an Instance of the corresponding Extractor.
    /// There is one (and only one) Extractor per Type. 
    /// </summary>
    public class QubitsExtractor
    {
        private static ConcurrentDictionary<Type, QubitsExtractor> _extractorsCache = new ConcurrentDictionary<Type, QubitsExtractor>();
        private static QubitsExtractor _selfExtractor = new QubitsExtractor(typeof(IApplyData));

        /// <summary>
        ///  Creates a new Extractor and identifies the Fields for the given Type.
        /// </summary>
        public static QubitsExtractor Get(Type t)
        {
            if (typeof(IApplyData).IsAssignableFrom(t))
            {
                return _selfExtractor;
            }

            if (t == null || t.IsPrimitive || t.IsEnum || t == typeof(String) || t == typeof(MissingParameter)) return null;

            if (_extractorsCache.TryGetValue(t, out QubitsExtractor __result))
            {
                return __result;
            }

            __result = new QubitsExtractor(t);
            _extractorsCache[t] = __result;

            return __result;
        }

        public FieldInfo[] QubitFields { get; }

        public Type T { get; }

        public QubitsExtractor(Type t)
        {
            this.T = t;

            if (t.IsPrimitive || t.IsEnum || typeof(System.Collections.IEnumerable).IsAssignableFrom(t))
            {
                QubitFields = null;
            }
            else if (t.IsTuple())
            {
                List<FieldInfo> fields = new List<FieldInfo>();

                foreach (var f in t.GetFields())
                {
                    if (f.FieldType.IsQubitsContainer())
                    {
                        fields.Add(f);
                    }
                }

                QubitFields = fields.ToArray();
            }
            else
            {
                QubitFields = null;
            }
        }

        public virtual IEnumerable<Qubit> Extract(object value)
        {
            Debug.Assert(value == null || T.IsAssignableFrom(value.GetType()));

            if (value is IApplyData qContainer)
            {
                return qContainer.Qubits;
            }
            else if (value != null && QubitFields != null && QubitFields.Length > 0)
            {
                return QubitFields.SelectMany((f) => f.GetValue(value).GetQubits() ?? Qubit.NO_QUBITS);
            }

            return null;
        }

        public virtual bool IsQubitContainer()
        {
            return typeof(IApplyData).IsAssignableFrom(T) || (QubitFields != null && QubitFields.Length > 0);
        }
    }
}
