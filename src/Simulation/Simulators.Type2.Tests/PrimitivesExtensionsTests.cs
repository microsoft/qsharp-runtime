// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;

using Microsoft.Quantum.Simulation.Core;

using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    public class PrimitivesExtensionsTests
    {
        [Fact]
        void AllExtensionsAreImplementedTest()
        {
            TestExtension("Core");
            TestExtension("Math");
            TestExtension("Convert");
            TestExtension("Bitwise");
        }

        private static void TestExtension(string extensionName)
        {
            Assembly assembly = Assembly.Load("Microsoft.Quantum.QSharp.Core");
            string extensionsNameSpace = "Microsoft.Quantum." + extensionName;

            IEnumerable<Type> abstractTypes =
                from opType in assembly.DefinedTypes
                where opType.Namespace == extensionsNameSpace
                where typeof(AbstractCallable).IsAssignableFrom(opType)
                where !opType.IsNested
                select opType;

            foreach (Type one in abstractTypes)
            {
                var t = one.IsGenericType 
                    ? one.MakeGenericType(Enumerable.Repeat(typeof(string), one.GetGenericArguments().Length).ToArray())
                    : one;
                if (t.IsAbstract)
                {
                    Assert.True(t.GetNativeImplementation() != null, $"{one.Name} missing Native implementation.");
                }
            }
        }
    }
}
