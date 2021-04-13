// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Intrinsic {

    open Microsoft.Quantum.Targeting;
    open Microsoft.Quantum.Core;

    @Inline()
    function NAN() : Double {
        body intrinsic;
    }

    @Inline()
    function IsNan(d: Double) : Bool {
        body intrinsic;
    }

    @Inline()
    function INFINITY() : Double {
        body intrinsic;
    }

    @Inline()
    function IsInf(d: Double) : Bool {
        body intrinsic;
    }

    @Inline()
    function IsNegativeInfinity(d : Double) : Bool {
        body intrinsic;
    }

}
