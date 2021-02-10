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

        public NDArray Data { get; }

        internal State(int nQubits, NDArray data)
        {
            NQubits = nQubits;
            Data = data;
        }
    }

    public class PureState : State
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

    public class MixedState : State
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
