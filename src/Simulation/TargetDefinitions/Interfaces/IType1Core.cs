// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IType1Core :
        IGate_ApplyControlledX,
        IGate_ApplyControlledZ,
        IGate_ApplyUncontrolledH,
        IGate_ApplyUncontrolledRx,
        IGate_ApplyUncontrolledRy,
        IGate_ApplyUncontrolledRz,
        IGate_ApplyUncontrolledS,
        IGate_ApplyUncontrolledT,
        IGate_ApplyUncontrolledX,
        IGate_ApplyUncontrolledY,
        IGate_ApplyUncontrolledZ,
        IGate_M,
        IGate_Reset
    { }
}