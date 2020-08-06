// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    public partial class ApplyIfElseR<__T__, __U__>
    {
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)>,
                $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs;
                var metadata = base.GetRuntimeMetadata(args);

                if (metadata == null) return null;

                if (result is ResultMeasured measured)
                {
                    metadata.IsConditional = true;
                    metadata.Controls = new List<Qubit>() { measured.Qubit };
                }
                else
                {
                    metadata.IsComposite = true;
                }

                return metadata;
            }

            return null;
        }
    }

    public partial class ApplyIfElseRA<__T__, __U__>
    {
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)>,
                $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs;
                var metadata = base.GetRuntimeMetadata(args);

                if (metadata == null) return null;

                if (result is ResultMeasured measured)
                {
                    metadata.IsConditional = true;
                    metadata.Controls = new List<Qubit>() { measured.Qubit };
                }
                else
                {
                    metadata.IsComposite = true;
                }

                return metadata;
            }

            return null;
        }
    }

    public partial class ApplyIfElseRC<__T__, __U__>
    {
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)>,
                $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs;
                var metadata = base.GetRuntimeMetadata(args);

                if (metadata == null) return null;

                if (result is ResultMeasured measured)
                {
                    metadata.IsConditional = true;
                    metadata.Controls = new List<Qubit>() { measured.Qubit };
                }
                else
                {
                    metadata.IsComposite = true;
                }

                return metadata;
            }

            return null;
        }
    }

    public partial class ApplyIfElseRCA<__T__, __U__>
    {
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)>,
                $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Result, (ICallable, __T__), (ICallable, __U__)> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs;
                var metadata = base.GetRuntimeMetadata(args);

                if (metadata == null) return null;

                if (result is ResultMeasured measured)
                {
                    metadata.IsConditional = true;
                    metadata.Controls = new List<Qubit>() { measured.Qubit };
                }
                else
                {
                    metadata.IsComposite = true;
                }

                return metadata;
            }

            return null;
        }
    }
}
