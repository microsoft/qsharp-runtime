// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IType3Core :
        IIntrinsicApplyControlledX,
        IIntrinsicApplyControlledZ,
        IIntrinsicApplyUncontrolledH,
        IIntrinsicApplyUncontrolledRx,
        IIntrinsicApplyUncontrolledRy,
        IIntrinsicApplyUncontrolledRz,
        IIntrinsicApplyUncontrolledS,
        IIntrinsicApplyUncontrolledSWAP,
        IIntrinsicApplyUncontrolledT,
        IIntrinsicApplyUncontrolledX,
        IIntrinsicApplyUncontrolledY,
        IIntrinsicApplyUncontrolledZ,
        IIntrinsicM,
        IIntrinsicReset
    { }
}