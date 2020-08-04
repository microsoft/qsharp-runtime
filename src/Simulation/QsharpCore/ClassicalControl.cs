// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    public partial class ApplyIfElseR<__T__, __U__>
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is QTuple<(Result,(ICallable,__T__),(ICallable,__U__))>,
                $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is QTuple<(Result,(ICallable,__T__),(ICallable,__U__))> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs.Data;
                return new RuntimeMetadata()
                {
                    Label = ((ICallable)this).Name,
                    IsComposite = true,
                };
            }

            return null;
        }
    }
}
