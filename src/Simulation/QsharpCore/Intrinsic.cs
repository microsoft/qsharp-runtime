// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class CNOT
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Qubit, Qubit>, $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Qubit, Qubit> cnotArgs)
            {
                var (ctrl, target) = cnotArgs;
                return new RuntimeMetadata()
                {
                    Label = "X",
                    IsControlled = true,
                    Controls = new List<Qubit>() { ctrl },
                    Targets = new List<Qubit>() { target },
                };
            }

            return null;
        }
    }

    public partial class CCNOT
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is ValueTuple<Qubit, Qubit, Qubit>, $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is ValueTuple<Qubit, Qubit, Qubit> ccnotArgs)
            {
                var (ctrl1, ctrl2, target) = ccnotArgs;
                return new RuntimeMetadata()
                {
                    Label = "X",
                    IsControlled = true,
                    Controls = new List<Qubit>() { ctrl1, ctrl2 },
                    Targets = new List<Qubit>() { target },
                };
            }

            return null;
        }
    }

    public partial class M
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            Debug.Assert(args.Value is Qubit, $"Failed to retrieve runtime metadata for {this.ToString()}.");

            if (args.Value is Qubit target)
            {
                return new RuntimeMetadata()
                {
                    Label = ((ICallable)this).Name,
                    IsMeasurement = true,
                    Targets = new List<Qubit>() { target },
                };
            }

            return null;
        }
    }

    public partial class ResetAll
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            var metadata = base.GetRuntimeMetadata(args);
            if (metadata == null) throw new NullReferenceException($"Null RuntimeMetadata found for {this.ToString()}.");
            metadata.IsComposite = true;
            return metadata;
        }
    }

    [Obsolete("This class is deprecated and will be removed in a future release. Considering using the corresponding callable class from 'Microsoft.Quantum.Intrinsic' directly.")]
    public class QSimM : M
    {
        public QSimM(IOperationFactory factory) : base(factory)
        {

        }
    }
}
