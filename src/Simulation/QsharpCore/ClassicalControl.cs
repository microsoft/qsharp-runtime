// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor.Extensions
{
    /// <summary>
    /// Provides interface to access base `GetRuntimeMetadata` method.
    /// </summary>
    public interface IApplyIfElse : ICallable
    {
        RuntimeMetadata? GetBaseRuntimeMetadata(IApplyData args);
    }

    /// <summary>
    /// Provides static `GetRuntimeMetadata` method for ApplyIfElseR and its variants
    /// to avoid code duplication.
    /// </summary>
    public class ApplyIfElseUtils<__C__, __T__, __U__>
    {
        public static RuntimeMetadata? GetRuntimeMetadata(IApplyIfElse op, IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Result, (__C__, __T__), (__C__, __U__)>,
                $"Failed to retrieve runtime metadata for {op.ToString()}.");

            if (args.Value is ValueTuple<Result, (__C__, __T__), (__C__, __U__)> ifArgs)
            {
                var (result, (onZeroOp, zeroArg), (onOneOp, oneArg)) = ifArgs;
                var metadata = op.GetBaseRuntimeMetadata(args);

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

    public partial class ApplyIfElseR<__T__, __U__> : IApplyIfElse
    {
        public RuntimeMetadata? GetBaseRuntimeMetadata(IApplyData args) =>
            base.GetRuntimeMetadata(args);

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            ApplyIfElseUtils<ICallable, __T__, __U__>.GetRuntimeMetadata(this, args);
    }

    public partial class ApplyIfElseRA<__T__, __U__> : IApplyIfElse
    {
        public RuntimeMetadata? GetBaseRuntimeMetadata(IApplyData args) =>
            base.GetRuntimeMetadata(args);

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            ApplyIfElseUtils<IAdjointable, __T__, __U__>.GetRuntimeMetadata(this, args);
    }

    public partial class ApplyIfElseRC<__T__, __U__> : IApplyIfElse
    {
        public RuntimeMetadata? GetBaseRuntimeMetadata(IApplyData args) =>
            base.GetRuntimeMetadata(args);

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            ApplyIfElseUtils<IControllable, __T__, __U__>.GetRuntimeMetadata(this, args);
    }

    public partial class ApplyIfElseRCA<__T__, __U__> : IApplyIfElse
    {
        public RuntimeMetadata? GetBaseRuntimeMetadata(IApplyData args) =>
            base.GetRuntimeMetadata(args);

        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args) =>
            ApplyIfElseUtils<IUnitary, __T__, __U__>.GetRuntimeMetadata(this, args);
    }
}
