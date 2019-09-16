// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using Newtonsoft.Json;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Represents a collection of objects that can be individually accessed by index.
    /// Corresponds to Q# array type.
    /// </summary>
    /// <typeparam name="T">The type of elements in the list. The type of the Q# array element.</typeparam>
    [JsonConverter(typeof(IQArrayJsonConverter))]
    public interface IQArray<out T> : IReadOnlyList<T>, IApplyData
    {
        T this[long index] { get; }

        long Length { get; }

        IQArray<T> Slice(Range range);

        T[] ToArray();
    }

    /// <summary>
    /// Represents a collection of objects that can be individually accessed by index.
    /// Corresponds to Q# array type.
    /// </summary>
    /// <typeparam name="T">The type of elements in the list. The type of the Q# array element.</typeparam>
    public class QArray<T> : IQArray<T>
    {
        protected class QArrayInner
        {
            // Reference count: how many QArray instances point to this inner array.
            // We never create free-floating inner arrays, so this is always at least 1.
            private int refCount = 1;
            // The actual data storage
            private List<T> storage;
            // any items that are added to an array are piped through ArrayElement
            private static T ArrayElement(T e) => e; // nothing to do here - we make shallow copies!

            public long Length => storage?.Count ?? 0;

            /// <summary>
            /// Create an array of length 0, represented by a null pointer.
            /// </summary>
            public QArrayInner() {}

            /// <summary>
            /// Creates a new inner array from an existing one.
            /// </summary>
            /// <param name="other">The existing inner array.</param>
            /// <param name="detach">If true, indicates that the new copy is being detached from the other inner array,
            /// so the reference count of the other array should be decremented.</param>
            private QArrayInner(QArrayInner other, bool detach)
            {
                if (other.storage != null)
                {
                    storage = other.storage.Select(ArrayElement).ToList();
                }
                if (detach)
                {
                    other.RemoveReference();
                }
            }

            /// <summary>
            /// Creates an array that contains elements from the collection argument.
            /// </summary>
            /// <param name="collection"> Elements with which the array is initialized.</param>
            public QArrayInner(IEnumerable<T> collection) =>
                storage = collection.Select(ArrayElement).ToList();

            /// <summary>
            /// Creates an array that contains elements from the collection argument.
            /// </summary>
            /// <param name="collection"> Elements with which the array is initialized.</param>
            public QArrayInner(IReadOnlyList<T> collection)
            {
                storage = new List<T>(collection.Count);
                storage.AddRange(collection);
            }

            /// <summary>
            /// Creates an array that contains elements from the collection argument.
            /// </summary>
            /// <param name="collection"> Elements with which the array is initialized.</param>
            public QArrayInner(params T[] collection) 
            {
                storage = new List<T>(collection.Length);
                storage.AddRange(collection);
            }

            /// <summary>
            /// Creates an array of size given by capacity and default-initializes 
            /// array elements. Uses C# keyword <code>default</code> to initialize array elements. 
            /// </summary>
            public QArrayInner(long capacity)
            {
                storage = new List<T>((int)capacity);
                for (var i = 0L; i < capacity; ++i)
                {
                    storage.Add(CreateDefault());
                }
            }

            public T GetElement(long index) =>
                storage == null
                    ? throw new ArgumentOutOfRangeException()
                    : storage[(int)index];

            public bool UnsafeToSet(long index) => (refCount > 1) && (index < Length);

            public QArrayInner SetElement(long index, T value)
            {
                if (storage == null)
                {
                    throw new ArgumentOutOfRangeException();
                }
                QArrayInner newInner = refCount > 1 ? new QArrayInner(this, true) : this;
                newInner.storage[(int)index] = ArrayElement(value);
                return newInner;
            }

            public void UnsafeSetElement(long index, T value)
            {
                if (storage == null)
                {
                    throw new ArgumentOutOfRangeException();
                }
                storage[(int)index] = ArrayElement(value);
            }

            public void AddReference() => refCount++;

            public void RemoveReference() => refCount--;

            public void Extend(long newLength)
            {
                if (storage == null)
                {
                    storage = new List<T>();
                }
                long oldLength = storage.Count;
                for (int i = 0; i < (newLength - oldLength); i++)
                {
                    T obj = CreateDefault();
                    storage.Add(obj);
                }
            }
        }


        private QArrayInner storage;
        private long start = 0;
        private long step = 1;

        public int Count => (int)Length;

        private long ConvertIndex(long index) => start + index * step;

        private void CopyAndCompress()
        {
            QArrayInner array = new QArrayInner(this as IQArray<T>);
            storage.RemoveReference();
            storage = array;
            start = 0;
            step = 1;
        }

        // Returns the default value of an object of this type of array. Normally null or 0, but for things like
        // ValueTuples, it returns an empty instance of that value tuple.
        private static T CreateDefault()
        {
            if (typeof(T).IsValueType || typeof(T).IsAbstract || typeof(T) == typeof(String) || typeof(T) == typeof(QVoid))
            {
                return default(T);
            }
            else
            {
                // First look for an empty constructor
                ConstructorInfo defaultConstructor = typeof(T).GetConstructor(Type.EmptyTypes);
                return defaultConstructor != null
                    ? (T)(defaultConstructor.Invoke(new object[] { }))
                    : Activator.CreateInstance<T>();
            }
        }


        /// <summary>
        /// Create an array of length 0.
        /// </summary>
        public QArray() =>
            storage = new QArrayInner();

        /// <summary>
        /// Create a copy of an existing array.
        /// </summary>
        public QArray(QArray<T> other)
        {
            if (other == null)
            {
                // Debug.Assert(false, $"Trying to copy a null array");
                storage = new QArrayInner();
            }
            else
            {
                storage = other.storage;
                storage.AddReference();
                start = other.start;
                step = other.step;
                Length = other.Length;
            }
        }

        /// <summary>
        /// Creates an array that contains elements from the collection argument.
        /// </summary>
        /// <param name="collection"> Elements with which the array is initialized.</param>
        public QArray(IEnumerable collection)
        {
            storage = new QArrayInner(collection.Cast<T>());
            Length = storage.Length;
        }

        /// <summary>
        /// Creates an array that contains elements from the collection argument.
        /// </summary>
        /// <param name="collection"> Elements with which the array is initialized.</param>
        public QArray(IEnumerable<T> collection)
        {
            storage = new QArrayInner(collection);
            Length = storage.Length;
        }

        /// <summary>
        /// Creates an array that contains elements from the given argument.
        /// </summary>
        /// <param name="collection"> Elements with which the array is initialized.</param>
        public QArray(IReadOnlyList<T> collection)
        {
            storage = new QArrayInner(collection);
            Length = collection.Count;
        }

        /// <summary>
        /// Creates an array that contains elements from the collection argument.
        /// </summary>
        /// <param name="collection"> Elements with which the array is initialized.</param>
        public QArray(params T[] collection)
        {
            storage = new QArrayInner(collection);
            Length = collection.Length;
        }

        /// <summary>
        /// Creates an array of size given by capacity and default-initializes 
        /// array elements. Uses C# keyword <code>default</code> to initialize array elements. 
        /// </summary>
        public static QArray<T> Create(long capacity) => new QArray<T>
        {
            storage = new QArrayInner(capacity),
            Length = capacity
        };

        /// <summary>
        /// Creates a copy of this array.
        /// </summary>
        /// <returns>The copy</returns>
        public QArray<T> Copy() => new QArray<T>(this);

        /// <summary>
        /// The Length of the array. Corresponds to the result of calling <code>Length(arr)</code> in Q#
        /// </summary>
        public long Length { get; private set; } = 0;

        object IApplyData.Value => this;

        IEnumerable<Qubit> IApplyData.Qubits
        {
            get
            {
                if (this is IEnumerable<Qubit> qArray)
                {
                    return qArray;
                }
                else if (this is IEnumerable<IApplyData> qContainers)
                {
                    return qContainers.SelectMany(q => q?.Qubits ?? Qubit.NO_QUBITS);
                }
                else if (typeof(T).IsQubitsContainer())
                {
                    var extractor = QubitsExtractor.Get(typeof(T));
                    return this.SelectMany(d => extractor.Extract(d) ?? Qubit.NO_QUBITS);
                }
                else return null;
            }
        }

        /// <summary>
        /// Returns an element of the array with given index. Corresponds to the
        /// result of calling <code>arr[i]</code> in Q#.
        /// Allows accessing the underlying item with a long index.
        /// </summary>
        /// <param name="index">The long index of the element to access</param>
        /// <returns>The element</returns>
        public T this[long index] => 
            index >= Length
                ? throw new ArgumentOutOfRangeException()
                : storage.GetElement(ConvertIndex(index));

        /// <summary>
        /// Gets an element by integer index.
        /// </summary>
        /// <param name="index">The integer index of the element to access</param>
        /// <returns>The element</returns>
        public T this[int index] => this[(long)index];

        /// <summary>
        /// Modifies the element at the given index and returns the QArray.
        /// Note that the modification is an in-place modification!
        /// If the given index is outside the array bounds, it throws 
        /// and ArgumentOutOfRangeException.
        /// </summary>
        /// <param name="index">The long index of the element to access</param>
        /// <returns>The element</returns>
        public QArray<T> Modify(long index, T value)
        {
            if (index >= Length)
            {
                throw new ArgumentOutOfRangeException();
            }
            if (storage.UnsafeToSet(ConvertIndex(index)))
            {
                CopyAndCompress();
            }
            storage = storage.SetElement(ConvertIndex(index), value);
            return this;
        }

        /// <summary>
        /// Modifies the elements at the given indices and returns the QArray.
        /// Note that the modification is an in-place modification!
        /// If the Length of the given values does not match the number of indices, 
        /// or if an index is outside the array bounds, it throws 
        /// and ArgumentOutOfRangeException.
        /// </summary>
        /// <param name="index">The long index of the element to access</param>
        /// <returns>The element</returns>
        public QArray<T> Modify(Range indices, IQArray<T> values)
        {
            if (values.Length != indices.Count())
            {
                throw new ArgumentOutOfRangeException();
            }

            var index = 0;
            foreach (var i in indices)
            {
                this.Modify(i, values[index++]); 
            }
            return this;
        }

        /// <summary>
        ///     Returns a sub-array from the given input array, based on the indexes
        ///     returned by the provided range instance.
        ///     For example, if the Range elements are [3,2,1], then this method
        ///     will return an array consisting of the elements 3,2,1 from the 
        ///     input array.
        ///     If the input array is null, this method returns null.
        ///     If the input range is null or empty, this method returns an empty array.
        ///     If the elements of the range are outside the array bounds, it throws
        ///     an ArgumentOutOfRangeException
        /// </summary>
        public QArray<T> Slice(Range range)
        {
            if (range == null)
            {
                // Debug.Assert(false, $"Trying to slice an array with a null range");
                return new QArray<T>();
            }

            if (range.IsEmpty)
            {
                return new QArray<T>();
            }
            long rangeCount = 1 + (range.End - range.Start) / range.Step;
            long rangeEnd = range.Start + (rangeCount - 1) * range.Step;

            // Make sure the slice fits
            if ((range.Start >= Length) || (range.Start < 0) || (rangeEnd >= Length) || (rangeEnd < 0))
            {
                throw new ArgumentOutOfRangeException();
            }

            if (range.Start == range.End)
            {
                return new QArray<T>(this[range.Start]);
            }

            long newStart = ConvertIndex(range.Start);
            long newStep = range.Step * step;
            long newCount = rangeCount;

            QArray<T> result = new QArray<T>(this);
            result.start = newStart;
            result.step = newStep;
            result.Length = newCount;

            return result;
        }

        IQArray<T> IQArray<T>.Slice(Range range) => Slice(range);

        /// <summary>
        ///     Returns a new QArray with the result of concatenating the
        ///     two given parameters.
        ///     If both input arrays are null, it returns null.
        ///     If one of the input arrays is null, it returns the other.
        /// </summary>
        public static QArray<T> Add(QArray<T> arr1, IQArray<T> arr2)
        {
            if (arr1 == null || arr1.Length == 0)
            {
                return arr2 == null ? null : new QArray<T>(arr2);
            }

            if (arr2 == null || arr2.Length == 0)
            {
                return new QArray<T>(arr1);
            }

            // Special case -- if the arr1 step is positive, 
            // and if arr1 runs all the way to the end of its inner array,
            // we can extend the inner array for arr1
            // and return it without copying the elements from arr1.
            // If either of these conditions are false, we need to make a copy.
            if ((arr1.step < 0) || (arr1.ConvertIndex(arr1.Length) < arr1.storage.Length))
            {
                arr1.CopyAndCompress();
            }
            long newEnd = arr1.ConvertIndex(arr1.Length + arr2.Length - 1) + 1;
            arr1.storage.Extend(newEnd);
            for (long i = 0; i < arr2.Length; i++)
            {
                arr1.storage.UnsafeSetElement(arr1.ConvertIndex(arr1.Length + i), arr2[i]); 
            }
            QArray<T> arr3 = new QArray<T>(arr1);
            arr3.start = arr1.start;
            arr3.step = arr1.step;
            arr3.Length = arr1.Length + arr2.Length;
            return arr3;
        }

        /// <summary>
        ///     Returns a new QArray with the result of concatenating the
        ///     two given parameters.
        ///     If both input arrays are null, it returns null.
        ///     If one of the input arrays is null, it returns the other.
        /// </summary>
        public static QArray<T> Add(IQArray<T> arr1, IQArray<T> arr2) =>
            arr1 == null ? arr2 == null ? null : new QArray<T>(arr2) :
            arr2 == null ? new QArray<T>(arr1) :
            Add(new QArray<T>(arr1), arr2);

        /// <summary>
        /// Returns string that is a Q# representation of the value of the array.
        /// </summary>
        public override string ToString()
        {
            string result = "[";
            for (long i = 0; i < this.Length; ++i)
            {
                if (i > 0) result += ",";
                result += this[i]?.ToString();
            }
            result += "]";
            return result;
        }

        public T[] ToArray()
        {
            T[] array = new T[Length];
            for (int i = 0; i < Length; i++)
            {
                array[i] = this[i];
            }
            return array;
        }

        protected class QArrayEnumerator : IEnumerator<T>, IEnumerator
        {
            private QArray<T> array;
            private long currentIndex;

            public QArrayEnumerator(QArray<T> qArray)
            {
                array = qArray;
                currentIndex = -1;
            }

            public T Current => currentIndex >= 0 ? array[currentIndex] : CreateDefault();

            object IEnumerator.Current => this.Current;

            public bool MoveNext() =>
                ++currentIndex < array.Length;

            public void Reset() =>
                currentIndex = -1;

            #region IDisposable Support
            private bool disposedValue = false; // To detect redundant calls

            protected virtual void Dispose(bool disposing)
            {
                if (disposing && !disposedValue)
                {
                    array = null;
                }
                disposedValue = true;
            }

            public void Dispose() =>
                Dispose(true);
            #endregion
        }

        public IEnumerator<T> GetEnumerator() =>
            new QArrayEnumerator(this);

        IEnumerator IEnumerable.GetEnumerator() =>
            GetEnumerator();

        public static implicit operator QArray<object>(QArray<T> arg) =>
            arg;
    }


    /// <summary>
    /// This JsonConverter converts instances of IQArray['T] as QArray['T]
    /// </summary>
    public class IQArrayJsonConverter : JsonConverter
    {
        /// <summary>
        /// Writers the QArray.
        /// </summary>
        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            if (value is IEnumerable list)
            {
                writer.WriteStartArray();
                foreach (var i in list)
                {
                    serializer.Serialize(writer, i);
                }
                writer.WriteEndArray();
            }
        }

        /// <summary>
        /// Reads the QArray<>
        /// </summary>
        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            Debug.Assert(CanConvert(objectType));
            var itemsType = objectType.GetGenericArguments()[0];
            var items = serializer.Deserialize(reader, typeof(List<>).MakeGenericType(itemsType));

            return Activator.CreateInstance(typeof(QArray<>).MakeGenericType(itemsType), items);
        }

        public override bool CanConvert(Type objectType) =>
            objectType.IsGenericType && 
                objectType.GetGenericTypeDefinition() == typeof(IQArray<>) ||
                objectType.GetGenericTypeDefinition() == typeof(QArray<>);
    }
}

