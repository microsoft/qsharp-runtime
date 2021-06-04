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
using static System.Math;

namespace Microsoft.Quantum.Experimental
{
    [JsonConverter(typeof(StateConverter))]
    public abstract class State
    {
        public int NQubits { get; }

        internal State(int nQubits)
        {
            NQubits = nQubits;
        }
    }

    public class StabilizerState : State
    {
        // Design note:
        // We could use the same array converter as used of complex-like arrays
        // of floats, but it's a bit easier in this case to directly
        // deserialize into a type that represents the underlying data that
        // we need.
        internal class TableArray
        {
            [JsonPropertyName("v")]
            internal int SchemaVersion { get; set; } = 1;

            [JsonPropertyName("dim")]
            internal List<int>? Dimensions { get; set; }

            [JsonPropertyName("data")]
            internal List<bool>? Data { get; set; }

            internal NDArray? AsArray =>
                Dimensions == null || Data == null
                ? null
                : np.ndarray(
                    new Shape(Dimensions.ToArray()),
                    typeof(bool),
                    Data.ToArray()
                );
        }

        public NDArray Data { get; }

        internal StabilizerState(int nQubits, TableArray data) : base(nQubits)
        {
            var array = data.AsArray;
            if (array == null)
            {
                throw new Exception($"Data deserialized for stabilizer state was null. Dimensions: {data.Dimensions}, data: {data.Data}");
            }
            Data = array!;
        }
    }

    public abstract class ArrayState : State
    {
        public NDArray Data { get; }

        internal ArrayState(int nQubits, NDArray data) : base(nQubits)
        {
            this.Data = data;
        }
    }

    public class PureState : ArrayState
    {
        public PureState(int nQubits, NDArray data) : base(nQubits, data)
        {
            // Pure states should be of dimension (2^n, 2), with the last
            // index indicating real-vs-imag.
            if (data.shape.Length != 2 || data.shape[0] != (int) (Pow(2, nQubits)) || data.shape[1] != 2)
            {
                throw new ArgumentException("Expected (2^nQubits, 2) array.", nameof(data));
            }
        }

        // TODO: Override ToString here!
    }

    public class MixedState : ArrayState
    {
        public MixedState(int nQubits, NDArray data) : base(nQubits, data)
        {
            // Pure states should be of dimension (2^n, 2^n, 2), with the last
            // index indicating real-vs-imag.
            var dim = (int) Pow(2, nQubits);
            if (data.shape.Length != 3 || data.shape[0] != dim || data.shape[1] != dim || data.shape[2] != 2)
            {
                throw new ArgumentException("Expected (2^nQubits, 2) array.", nameof(data));
            }
        }

        public override string ToString() =>
            $@"Mixed state on {NQubits} qubits: {Data.AsTextMatrixOfComplex(rowSep: " ")}";
    }

}
