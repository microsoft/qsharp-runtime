// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Intrinsic
{
    public partial class CNOT
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args)
        {
            var controls = new List<Qubit>();
            var targets = new List<Qubit>();

            switch (args.Value)
            {
                case ValueTuple<Qubit, Qubit> cnotArgs:
                    var (ctrl, target) = cnotArgs;
                    controls.Add(ctrl);
                    targets.Add(target);
                    break;
                default:
                    Console.WriteLine($"Failed to retrieve arguments of type {args.Value.GetType()} for CNOT.");
                    break;
            }

            return new RuntimeMetadata()
            {
                Label = "X",
                IsControlled = true,
                Controls = controls,
                Targets = targets,
            };
        }
    }

    public partial class CCNOT
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args)
        {
            var controls = new List<Qubit>();
            var targets = new List<Qubit>();

            switch (args.Value)
            {
                case ValueTuple<Qubit, Qubit, Qubit> ccnotArgs:
                    var (ctrl1, ctrl2, target) = ccnotArgs;
                    controls.Add(ctrl1);
                    controls.Add(ctrl2);
                    targets.Add(target);
                    break;
                default:
                    Console.WriteLine("Failed to retrieve arguments for CNOT.");
                    break;
            }
            return new RuntimeMetadata()
            {
                Label = "X",
                IsControlled = true,
                Controls = controls,
                Targets = targets,
            };
        }
    }

    public partial class M
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args)
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

    public partial class Reset
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args) => null;
    }

    public partial class ResetAll
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args) => null;
    }
}
