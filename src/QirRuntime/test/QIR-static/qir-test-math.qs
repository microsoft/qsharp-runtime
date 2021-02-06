// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Math
{
    open Microsoft.Quantum.Intrinsic;

    function SqrtTest() : Int {
        if( 2.0 != Sqrt(  4.0) )    { return 1; }     
        if( 3.0 != Sqrt(  9.0) )    { return 2; }     
        if(10.0 != Sqrt(100.0) )    { return 3; }     
                                                                      
        if( not IsNan(Sqrt(-5.0)))        { return 4; }      
        if( not IsNan(Sqrt(NAN())))       { return 5; }      
        if( not IsInf(Sqrt(INFINITY())))  { return 6; }      

        return 0;
    }
}

