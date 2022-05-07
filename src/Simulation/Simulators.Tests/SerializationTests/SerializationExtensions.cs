// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System.Diagnostics;
using System.IO;
using System.Text;
using System.Text.Json;

namespace Microsoft.Quantum.Simulation.Simulators.Tests;

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
        writer.Flush();
        return Encoding.UTF8.GetString(stream.ToArray());
    }

    internal static void AssertSerializationRoundTrips<T>(this T obj, ITestOutputHelper? output = null)
    {
        string expected;
        try
        {
            expected = JsonSerializer.Serialize<T>(obj);
        }
        catch (Exception ex)
        {
            output?.WriteLine($"Serialization of {typeof(T)} failed to round-trip: initial serialization failed.");
            throw ex;
        }

        T roundTripObj;
        try
        {
            var deserialized = JsonSerializer.Deserialize<T>(expected);
            Debug.Assert(deserialized is not null);
            roundTripObj = deserialized;
        }
        catch (JsonException ex)
        {
            output?.WriteLine(
                $"Serialization of {typeof(T)} failed to round-trip: JSON exception deserializing.\n" +
                $"Line {ex.LineNumber}, offset {ex.BytePositionInLine}.\n" +
                "Source:\n" +
                $"{expected}"
            );
            throw ex;
        }

        var actual = JsonSerializer.Serialize<T>(roundTripObj);
        expected.AssertJsonIsEqualTo(actual);
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
