// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using System.Collections.Generic;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Core;
    using System.IO;
    using System.Runtime.Serialization.Formatters.Binary;
    using System.Runtime.Serialization;
    using System;
    using System.Reflection;

    public class Utils
    {
        /// <summary>
        /// Removes PauliI terms from observable and corresponding qubits from qubits. 
        /// Returns the observable description that is equivalent to the original one, but has no PauliI terms
        /// </summary>
        public static void PruneObservable(IQArray<Pauli> observable, IQArray<Qubit> qubits, out List<Pauli> prunnedObservable, out List<Qubit> prunnedQubits)
        {
            Debug.Assert(observable != null);
            Debug.Assert(qubits != null);

            uint IpauliCount = 0;
            Debug.Assert(observable.Length == qubits.Length);
            for (uint i = 0; i < observable.Length; ++i)
            {
                if (observable[i] == Pauli.PauliI)
                {
                    ++IpauliCount;
                }
            }

            prunnedObservable = new List<Pauli>((int)observable.Length);
            prunnedQubits = new List<Qubit>((int)observable.Length);
            uint k = 0;
            for (uint i = 0; i < observable.Length; ++i)
            {
                if (observable[i] != Pauli.PauliI)
                {
                    prunnedObservable.Add(observable[i]);
                    prunnedQubits.Add(qubits[i]);
                    ++k;
                }
            }

            Debug.Assert(k == observable.Length - IpauliCount);
        }

        /// <summary>
        /// Returns the measurement result that is the opposite to a given one
        /// </summary>
        public static Result Opposite(Result res)
        {
            if (res == Result.One)
            {
                return Result.Zero;
            }
            else
            {
                return Result.One;
            }
        }

        public static string PauliToString(Pauli pauli)
        {
            switch (pauli)
            {
                case Pauli.PauliI:
                    return "I";
                case Pauli.PauliX:
                    return "X";
                case Pauli.PauliY:
                    return "Y";
                case Pauli.PauliZ:
                    return "Z";
                default:
                    Debug.Assert(false, "This case should never be reached");
                    return "<Unknown>";
            }
        }

        public static string ObservableToString(IEnumerable<Pauli> observable)
        {
            string res = string.Empty;
            foreach (var obs in observable)
            {
                res += PauliToString(obs);
            }

            return res;
        }

        public static T[] UnboxAs<T>(object[] array) where T : class
        {
            Debug.Assert(array != null);
            T[] res = new T[array.Length];
            for (int i = 0; i < array.Length; ++i)
            {
                res[i] = array[i] as T;
                Debug.Assert(res[i] != null, $"All elements of array are expected to be of super-type {typeof(T).FullName}.");
            }
            return res;
        }

        /// <summary>
        /// Makes a deep copy of a serializable type. Based on CLR via C#, 4th ed., by J.Richter, page 615 
        /// </summary>
        public static T DeepClone<T>(T original) where T : class
        {
            using (MemoryStream stream = new MemoryStream())
            {
                BinaryFormatter formatter = new BinaryFormatter();
                formatter.Context = new StreamingContext(StreamingContextStates.Clone);
                // Serialize the object graph into the memory stream
                formatter.Serialize(stream, original);
                // Seek back to the start of the memory stream before deserializing
                stream.Position = 0;
                // Deserialize the graph into a new set of objects and
                // return the root of the graph (deep copy) to the caller
                T res = formatter.Deserialize(stream) as T;
                Debug.Assert(res != null);
                return res;
            }
        }

        /// <summary>
        /// Extracts tracing data from array of qubit with index data_id
        /// </summary>
        public static T[] ExtractTracingData<T>(IReadOnlyList<Qubit> qubits, int data_id) where T : class
        {
            Debug.Assert(qubits != null);
            T[] res = new T[qubits.Count];
            for (int i = 0; i < qubits.Count; ++i)
            {
                TraceableQubit qt = qubits[i] as TraceableQubit;
                Debug.Assert(qt != null, "Qubits are expected to have super-type TraceableQubit");
                res[i] = qt.TraceData[data_id] as T;
                Debug.Assert(res[i] != null, $"Qubits does not have data of type {typeof(T).FullName} associated to it.");
            }
            return res;
        }

        /// <summary>
        /// Extracts tracing data from array of qubit. Goes through all types attached to the qubits and tries to find 
        /// a record of type <typeparamref name="T"/>.
        /// </summary>
        public static T[] ExtractTracingData<T>(Qubit[] qubits) where T : class
        {
            Debug.Assert(qubits != null);
            T[] res = new T[qubits.Length];
            for (int i = 0; i < qubits.Length; ++i)
            {
                TraceableQubit qt = qubits[i] as TraceableQubit;
                Debug.Assert(qt != null, "Qubits are expected to have super-type TraceableQubit");
                for (int j = 0; j < qt.TraceData.Length; ++j)
                {
                    res[i] = qt.TraceData[j] as T;
                    if (res[i] != null)
                    {
                        break;
                    }
                }
                Debug.Assert(res[i] != null, $"Qubits does not have data of type {typeof(T).FullName} associated to it.");
            }
            return res;
        }

        /// <summary>
        /// Extracts arrays of data attached to array of qubits and performs the transpose.
        /// </summary>
        public static object[][] ExtractTracingDataBulk(IReadOnlyList<Qubit> qubits, int dataIdStart, int length)
        {
            Debug.Assert(qubits != null);
            object[][] res = new object[length][];

            for (int j = 0; j < length; ++j)
            {
                res[j] = new object[qubits.Count];
            }

            for (int i = 0; i < qubits.Count; ++i)
            {
                TraceableQubit qt = qubits[i] as TraceableQubit;
                Debug.Assert(qt != null, "Qubits are expected to have super-type TraceableQubit");
                for (int j = 0; j < length; ++j)
                {
                    res[j][i] = qt.TraceData[dataIdStart + j];
                }
            }
            return res;
        }

        public static Dictionary<T,int> IListToDictionary<T>( IList<T> list )
        {
            Dictionary<T, int> res = new Dictionary<T, int>();
            for ( int i = 0; i < list.Count; ++i )
            {
                res.Add(list[i] , i);
            }
            return res;
        }

        public static string[] MethodParametersNames(object inst, string name)
        {
            ParameterInfo[] parInfo = inst.GetType().GetMethod(name).GetParameters();
            string[] res = new string[parInfo.Length];
            for (var i = 0; i < parInfo.Length; ++i)
            {
                res[i] = parInfo[i].Name;
            }
            return res;
        }

        public static double[] ArrayDifference( double[] subtractedFrom, double[] toBeSubtructed )
        {
            Debug.Assert(subtractedFrom != null);
            Debug.Assert(toBeSubtructed != null);
            Debug.Assert(subtractedFrom.Length == toBeSubtructed.Length);
            double[] res = new double[subtractedFrom.Length];
            for( int i = 0; i < subtractedFrom.Length; ++i )
            {
                res[i] = subtractedFrom[i] - toBeSubtructed[i];
            }
            return res;
        }

        public static void FillDictionaryForEnumNames<TEnum, TKey>(Dictionary<TKey, string> dictionary)
        {
            foreach (string enumEltName in Enum.GetNames(typeof(TEnum)))
            {
                dictionary.Add(
                    (TKey)Enum.Parse(typeof(TEnum), enumEltName),
                    enumEltName);
            }
        }
    }

    public class ObservableEqualityComparer : IEqualityComparer<QArray<Pauli>>
    {
        public bool Equals(QArray<Pauli> x, QArray<Pauli> y)
        {
            return System.Linq.Enumerable.SequenceEqual(x,y);
        }

        public int GetHashCode(QArray<Pauli> obj)
        {
            return Utils.ObservableToString(obj).GetHashCode();
        }
    }

    /// <summary>
    /// Equivalent of string type that stores its hash
    /// Warning!!!: hash code will not be recomputed if member data is changed
    /// </summary>
    sealed public class HashedString
    {
        readonly string data;
        readonly int hash;

        public HashedString(string str)
        {
            data = str;
            hash = str.GetHashCode();
        }

        public static implicit operator string(HashedString d)
        {
            return d.data;
        }

        public static explicit operator HashedString(string d)
        {
            return new HashedString(d);
        }

        public override int GetHashCode()
        {
            return hash;
        }

        public override bool Equals(object obj)
        {
            var hstr = obj as HashedString;
            return hstr != null && hstr.data == data;
        }
    }
}