// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Intrinsic.Interfaces;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class CommonNativeSimulator
    {
        IQArray<Result> IIntrinsicMeasureEachZ.Body(IQArray<Qubit> targets)
        {
            this.CheckQubits(targets);
            return new QArray<Result>(targets.Select(q =>
            {
                q.IsMeasured = true;
                return M((uint)q.Id).ToResult();
            }));
        }
    }
}
