// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;
using System.Numerics;
using System.Text.Json;
using System.Text.Json.Serialization;
using NumSharp;

namespace Microsoft.Quantum.Experimental
{
    public class Instrument
    {
        public IList<Channel> Effects { get; set; } = new List<Channel>();

        public override string ToString() =>
            $"Instrument {{ Effects = {String.Join(", ", Effects.Select(effect => effect.ToString()))} }}";
    }
}
