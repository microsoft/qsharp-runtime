﻿// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Common;

namespace Microsoft.Quantum.Simulation.Simulators.Tests
{
    /// 
    /// This is a trivial implementation of a Simulator. Only used for unittesting. 
    /// Not apt to simulate any circuits as it implements no Primitive Gates.
    /// 
    public class TrivialSimulator : SimulatorBase
    {
        public TrivialSimulator() : base(new QubitManagerTrackingScope(32))
        {
        }

        public override string Name
        {
            get
            {
                return this.GetType().Name;
            }
        }
    }
}
