// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics.CodeAnalysis;
using System.Linq;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Serialization;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using NumSharp;

namespace Microsoft.Quantum.Experimental
{
    public class DelegatedConverter<T> : Newtonsoft.Json.JsonConverter<T>
    {
        public override T ReadJson(JsonReader reader, Type objectType, [AllowNull] T existingValue, bool hasExistingValue, Newtonsoft.Json.JsonSerializer serializer)
        {
            var serialized = JToken.ReadFrom(reader).ToString();
            return System.Text.Json.JsonSerializer.Deserialize<T>(serialized);
        }

        public override void WriteJson(JsonWriter writer, [AllowNull] T value, Newtonsoft.Json.JsonSerializer serializer)
        {
            var serialized = System.Text.Json.JsonSerializer.Serialize(value);
            var deserialized = Newtonsoft.Json.Linq.JToken.Parse(serialized);
            deserialized.WriteTo(writer);
        }
    }
}
