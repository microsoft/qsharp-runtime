// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Qir.Utility
{
    /// <summary>
    /// Mockable clock interface.
    /// </summary>
    public interface IClock
    {
        public DateTimeOffset Now { get; }
    }
}
