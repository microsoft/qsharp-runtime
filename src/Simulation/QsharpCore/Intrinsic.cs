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
            else
            {
                Console.WriteLine($"Failed to retrieve runtime metadata for {this.ToString()}.");
                return null;
            }
        }
    }

    public partial class CCNOT
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args)
        {
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
            else
            {
                Console.WriteLine($"Failed to retrieve runtime metadata for {this.ToString()}.");
                return null;
            }
        }
    }

    public partial class M
    {
        public override RuntimeMetadata GetRuntimeMetadata(IApplyData args)
        {
            if (args.Value is Qubit target)
            {
                return new RuntimeMetadata()
                {
                    Label = ((ICallable)this).Name,
                    IsMeasurement = true,
                    Targets = new List<Qubit>() { target },
                };
            }
            else
            {
                Console.WriteLine($"Failed to retrieve runtime metadata for {this.ToString()}.");
                return null;
            }            
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
