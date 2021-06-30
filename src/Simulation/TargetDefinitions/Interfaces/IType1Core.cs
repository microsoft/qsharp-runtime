// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IType1Core :
        IIntrinsicApplyControlledX,
        IIntrinsicApplyControlledZ,
        IIntrinsicApplyUncontrolledH,
        IIntrinsicApplyUncontrolledRx,
        IIntrinsicApplyUncontrolledRy,
        IIntrinsicApplyUncontrolledRz,
        IIntrinsicApplyUncontrolledS,
        IIntrinsicApplyUncontrolledSAdj,
        IIntrinsicApplyUncontrolledT,
        IIntrinsicApplyUncontrolledTAdj,
        IIntrinsicApplyUncontrolledX,
        IIntrinsicApplyUncontrolledY,
        IIntrinsicApplyUncontrolledZ,
        IIntrinsicM,
        IIntrinsicReset
    { }
}