// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Contains information about the Q# operation that can be used at runtime.
    /// </summary>
    public class OperationInfo<I, O>
    {
        public Type Operation { get; }
        public Type InType => typeof(I);
        public Type OutType => typeof(O);
        public OperationInfo(Type operation)
        {
            this.Operation = operation;
        }

        public IReadOnlyDictionary<> TargetSpecificRedirects; 
    }
}
