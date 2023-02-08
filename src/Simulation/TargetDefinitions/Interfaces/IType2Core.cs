// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic.Interfaces
{
    public interface IType2Core :
        IIntrinsicH,
        IIntrinsicApplyUncontrolledRxx,
        IIntrinsicApplyUncontrolledRyy,
        IIntrinsicApplyUncontrolledRzz,
        IIntrinsicMZ,
        IIntrinsicRx,
        IIntrinsicRy,
        IIntrinsicRz,
        IIntrinsicS,
        IIntrinsicSWAP,
        IIntrinsicT,
        IIntrinsicX,
        IIntrinsicY,
        IIntrinsicZ,
        IIntrinsicReset
    { }
}