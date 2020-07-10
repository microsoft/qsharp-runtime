// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Measurement
{
    public partial class MResetX
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            var targets = new List<Qubit>();
            var target = args.Value as Qubit;
            if (target != null) targets.Add(target);

            return new RuntimeMetadata()
            {
                Label = ((ICallable)this).Name,
                IsMeasurement = true,
                Targets = targets,
            };
        }
    }

    public partial class MResetY
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            var targets = new List<Qubit>();
            var target = args.Value as Qubit;
            if (target != null) targets.Add(target);

            return new RuntimeMetadata()
            {
                Label = ((ICallable)this).Name,
                IsMeasurement = true,
                Targets = targets,
            };
        }
    }

    public partial class MResetZ
    {
        /// <inheritdoc/>
        public override RuntimeMetadata? GetRuntimeMetadata(IApplyData args)
        {
            var targets = new List<Qubit>();
            var target = args.Value as Qubit;
            if (target != null) targets.Add(target);

            return new RuntimeMetadata()
            {
                Label = ((ICallable)this).Name,
                IsMeasurement = true,
                Targets = targets,
            };
        }
    }
}
