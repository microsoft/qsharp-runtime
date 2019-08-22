// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class QArrayTests
    {
        [Fact]
        public void CreateArrayWithDefaults()
        {
            var actual = new QArray<Qubit>(new Qubit[0]);
            Assert.Empty(actual);

            actual = new QArray<Qubit>(new Qubit[1]);
            Assert.Single(actual);
            Assert.Null(actual[0]);

            actual = new QArray<Qubit>(new Qubit[5]);
            Assert.Equal(5, actual.Length);
            Assert.Null(actual[0]);
            Assert.Null(actual[1]);
            Assert.Null(actual[2]);
            Assert.Null(actual[3]);
            Assert.Null(actual[4]);

            var longs = new QArray<long>(new long[0]);
            Assert.Empty(longs);

            longs = new QArray<long>(new long[3]);
            Assert.Equal(3, longs.Length);
            Assert.Equal(0, longs[0]);
            Assert.Equal(0, longs[1]);
            Assert.Equal(0, longs[2]);

            var ops = new QArray<ICallable>(new ICallable[2]);
            Assert.Equal(2, ops.Length);
            Assert.Null(ops[0]);
            Assert.Null(ops[1]);
        }

        private void Wrapper<T>(long count)
        {
            var array = new QArray<T>(new T[count]);
            Assert.Equal(count, array.Length);
        }

        [Fact]
        public void CreateArrayWithGenerics()
        {
            Wrapper<ICallable>(3);
            Wrapper<Double>(4);
        }

        [Fact]
        public void ArraysByIndex()
        {
            var longs = new QArray<long> (2, 1, 0);
            Assert.NotEmpty(longs);
            Assert.Equal(3, longs.Length);
            Assert.Equal(2, longs[0]);
            Assert.Equal(1, longs[1]);
            Assert.Equal(0, longs[2]);

            longs = new QArray<long>(new long[5]);
            longs.Modify(0, 5);
            longs.Modify(2, 3);
            longs.Modify(4, 1);
            Assert.Equal(5, longs.Length);
            Assert.Equal(5, longs[0]);
            Assert.Equal(0, longs[1]);
            Assert.Equal(3, longs[2]);
            Assert.Equal(0, longs[3]);
            Assert.Equal(1, longs[4]);

            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                // Make sure we can call it with a long index:
                Assert.Throws<ArgumentOutOfRangeException>(() => longs[-1]);
                Assert.Throws<ArgumentOutOfRangeException>(() => longs[int.MaxValue]);
                Assert.Throws<ArgumentOutOfRangeException>(() => longs[(long)int.MaxValue + 1]);
            });
        }

        [Fact]
        public void JoinArrays()
        {
            var arr1 = new QArray<long>();
            var arr2 = new QArray<long>();
            var expected = new QArray<long>();
            var actual = QArray<long>.Add(arr1, arr2);
            Assert.Equal(expected, actual);

            arr1 = new QArray<long>(1);
            arr2 = new QArray<long>();
            expected = new QArray<long>(1);
            actual = QArray<long>.Add(arr1, arr2);
            Assert.Equal(expected, actual);

            arr1 = new QArray<long>();
            arr2 = new QArray<long>(1);
            expected = new QArray<long>(1);
            actual = QArray<long>.Add(arr1, arr2);
            Assert.Equal(expected, actual);

            arr1 = new QArray<long>(1, 2, 3);
            arr2 = new QArray<long>(1, 4, 5, 3, 6);
            expected = new QArray<long>(1, 2, 3, 1, 4, 5, 3, 6);
            actual = QArray<long>.Add(arr1, arr2);
            Assert.Equal(expected, actual);

            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                arr1 = null;
                arr2 = new QArray<long>(1, 4, 5, 3, 6);
                expected = new QArray<long>(1, 4, 5, 3, 6);
                actual = QArray<long>.Add(arr1, arr2);
                Assert.Equal(expected, actual);

                arr1 = new QArray<long>(1, 2, 3);
                arr2 = null;
                expected = new QArray<long>(1, 2, 3);
                actual = QArray<long>.Add(arr1, arr2);
                Assert.Equal(expected, actual);

                arr1 = null;
                arr2 = null;
                expected = null;
                actual = QArray<long>.Add(arr1, arr2);
                Assert.Equal(expected, actual);
            });
        }

        [Fact]
        public void SliceArray()
        {
            var source = new QArray<long>(0);
            var range = new Range(0, 0);
            var expected = new QArray<long>(0);
            var actual = source.Slice(range);
            Assert.Equal(expected, actual);

            source = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            range = new Range(0, 2, 10);
            expected = new QArray<long>(0, 2, 4, 6, 8, 10);
            actual = source.Slice(range);
            Assert.Equal(expected, actual);


            source = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
            expected = new QArray<long>(1, 6);
            actual = source.Slice(new Range(1, 5, 10));
            Assert.Equal(expected, actual);

            OperationsTestHelper.IgnoreDebugAssert(() =>
            {
                source = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10);
                range = null;
                expected = new QArray<long>();
                actual = source.Slice(range);
                Assert.Equal(expected, actual);
            });
        }

        [Fact]
        public void ArraySharing()
        {
            // Basic copy-on-write
            var array1 = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            var array2 = new QArray<long>(array1);
            Assert.Equal(2, array1[2]);
            Assert.Equal(2, array2[2]);
            array1.Modify(2, 12);
            Assert.Equal(12, array1[2]);
            Assert.Equal(2, array2[2]);
            array2.Modify(2, 22);
            Assert.Equal(12, array1[2]);
            Assert.Equal(22, array2[2]);

            // Arrays of arrays
            array1 = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            array2 = new QArray<long>(array1);
            var arrayArray1 = new QArray<QArray<long>>(array1, array2); // in generated C# code, QArray<IQArray<long>> is used
            var arrayArray2 = new QArray<QArray<long>>(arrayArray1);
            Assert.Equal(2, arrayArray1[0][2]);
            Assert.Equal(2, arrayArray1[1][2]);
            arrayArray1.Modify(0, arrayArray1[0].Modify(2, 12));
            Assert.Equal(12, arrayArray1[0][2]);
            Assert.Equal(2, arrayArray1[1][2]);
            Assert.Equal(12, array1[2]);
            arrayArray1.Modify(1, arrayArray1[1].Modify(2, 22));
            Assert.Equal(12, arrayArray1[0][2]);
            Assert.Equal(22, arrayArray1[1][2]);
            Assert.Equal(12, array1[2]);
            Assert.Equal(22, array2[2]);

            // Copy-on-write with slices
            var r = new Range(1, 2, 10);
            var array3 = array2.Slice(r);
            var expected = new QArray<long>(1, 3, 5, 7, 9);
            Assert.Equal(expected, array3);
            array3.Modify(0, 11);
            Assert.Equal(1, array2[1]);
            Assert.Equal(11, array3[0]);

            // Mixing slicing and joining
            array2 = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            var expected2 = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            r = new Range(1, 2, 10);
            array3 = array2.Slice(r);
            var array4 = new QArray<long>(11, 13);
            var array5 = QArray<long>.Add(array3, array4);
            var expected3 = new QArray<long>(1, 3, 5, 7, 9);
            var expected4 = new QArray<long>(11, 13);
            var expected5 = new QArray<long>(1, 3, 5, 7, 9, 11, 13);
            Assert.Equal(expected2, array2);
            Assert.Equal(expected3, array3);
            Assert.Equal(expected4, array4);
            Assert.Equal(expected5, array5);

            // Self-joining
            array1 = new QArray<long>(0, 1, 2);
            array2 = new QArray<long>(QArray<long>.Add(array1, array1));
            var expected1 = new QArray<long>(0, 1, 2);
            expected2 = new QArray<long>(0, 1, 2, 0, 1, 2);
            Assert.Equal(expected1, array1);
            Assert.Equal(expected2, array2);
            array1.Modify(0, 10);
            Assert.Equal(10, array1[0]);
            Assert.Equal(0, array2[0]);
        }

        [Fact]
        public void ArrayEnumeration()
        {
            // Basic enumeration
            var array1 = new QArray<long>(0, 1, 2, 3, 4, 5, 6, 7, 8, 9);
            int index = 0;
            foreach (var n in array1)
            {
                Assert.Equal(index, n);
                index++;
            }
            Assert.Equal(10, index);

            // Enumerating a slice
            var r = new Range(1, 2, 10);
            var array2 = array1.Slice(r);
            index = 1;
            foreach (var n in array2)
            {
                Assert.Equal(index, n);
                index += 2;
            }
            Assert.Equal(11, index);

            // Enumerating a join
            var array3 = QArray<long>.Add(array1, array2);
            index = 0;
            foreach (var n in array3)
            {
                if (index < 10)
                {
                    Assert.Equal(index, n);
                }
                else
                {
                    Assert.Equal(2 * index - 19, n);
                }
                index++;
            }
            Assert.Equal(15, index);
        }

        [Fact]
        public void CastArrays()
        {
            // Basic enumeration
            var array1 = new QArray<object>(1L, 2L, 3L);
            var array2 = new QArray<long>(array1);

            Assert.Equal(array1.Length, array2.Length);
            Assert.Equal((long)array1[0], array2[0]);
            Assert.Equal((long)array1[2], array2[2]);
        }

        [Fact]
        public void IQArraySerialization()
        {
            // Basic enumeration
            var array1 = new QArray<long>(1L, 2L, 3L) as IQArray<long>;
            var json = JsonConvert.SerializeObject(array1);
            Assert.Equal("[1,2,3]", json);

            var array2 = JsonConvert.DeserializeObject<IQArray<long>>(json);
            var array3 = JsonConvert.DeserializeObject<QArray<long>>(json);
            Assert.Equal(array1, array2);
            Assert.Equal(array1, array3);

            // Results enumeration
            var array_result = new QArray<Result>(Result.One, Result.Zero, Result.Zero) as IQArray<Result>;
            json = JsonConvert.SerializeObject(array_result);
            Assert.Equal("[1,0,0]", json);

            var array_from_json = JsonConvert.DeserializeObject<IQArray<Result>>(json);
            Assert.Equal(array_result, array_from_json);
        }
    }
}
