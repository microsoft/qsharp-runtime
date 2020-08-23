// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits
{
    open Microsoft.Quantum.Intrinsic;

    operation TimesTwo (v : Int) : Int
    {
        return v <<< 1;
    }
    
    operation DivideTwo (v : Int) : Int
    {
        return v >>> 1;
    }
    
    operation IsEven (v : Int) : Bool
    {
        return (v &&& 1) == 0;
    }

    operation BitOperationsTest () : Unit
    {
        AssertEqual(14, TimesTwo(7));
        AssertEqual(11, DivideTwo(22));
        AssertEqual(11, DivideTwo(23));
            
        AssertEqual(17, DivideTwo(98) &&& 0x51);
        AssertEqual(0xF000F, 0xF ||| TimesTwo(0x78002));
        AssertEqual(0x00110007, 0x000f000f ^^^ (TimesTwo(0x78002) + TimesTwo(0x78002)));
    }
}