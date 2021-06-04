// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Text;
using System.Text.Json;
using Microsoft.Quantum.Experimental;
using Microsoft.Quantum.Simulation.Core;
using Newtonsoft.Json.Linq;
using Xunit;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    internal static class SerializationExtensions
    {
        internal static void AssertTypeAnd<T>(this object obj, Action<T> then)
        {
            if (!(obj is T t))
            {
                Assert.IsType<T>(obj);
            }
            else
            {
                then(t);
            }
        }

        internal static string Serialize(this JsonDocument document)
        {
            var stream = new MemoryStream();
            var writer = new Utf8JsonWriter(stream);
            document.WriteTo(writer);
            return Encoding.UTF8.GetString(stream.ToArray());
        }

        internal static void AssertJsonIsEqualTo(this string expectedJson, string actualJson)
        {
            // To get a stable text representation, we first parse both strings to JsonDocument
            // objects, then re-serialize them. This avoids numerical precision issues in
            // JToken.DeepEquals, and allows for highlighting diffs more easily.
            var expectedNormalized = JsonDocument.Parse(expectedJson).Serialize();
            var actualNormalized = JsonDocument.Parse(actualJson).Serialize();
            Assert.Equal(expectedNormalized, actualNormalized);
        }
    }
}
