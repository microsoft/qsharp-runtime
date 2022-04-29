// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IType4Core :
        IIntrinsicApplyControlledX,
        IIntrinsicApplyControlledZ,
        IIntrinsicApplyUncontrolledH,
        IIntrinsicApplyUncontrolledRx,
        IIntrinsicApplyUncontrolledRy,
        IIntrinsicApplyUncontrolledRz,
        IIntrinsicApplyUncontrolledS,
        IIntrinsicApplyUncontrolledSAdj,
        IIntrinsicApplyUncontrolledSWAP,
        IIntrinsicApplyUncontrolledT,
        IIntrinsicApplyUncontrolledTAdj,
        IIntrinsicApplyUncontrolledX,
        IIntrinsicApplyUncontrolledY,
        IIntrinsicApplyUncontrolledZ,
        IIntrinsicMZ,
        IIntrinsicMeasureEachZ,
        IIntrinsicReset
    { }
}