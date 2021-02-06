// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Math
{
    open Microsoft.Quantum.Intrinsic;

    function TestSqrt() : Int
    {
        mutable testResult = 0;

        if(           2.0 != Sqrt(  4.0) )    { set testResult = 1; }     
        else { if(    3.0 != Sqrt(  9.0) )    { set testResult = 2; }     
        else { if(   10.0 != Sqrt(100.0) )    { set testResult = 3; }     
                                                                      
        else { if( not IsNan(Sqrt(-5.0)))        { set testResult = 4; }      
        else { if( not IsNan(Sqrt(NAN())))       { set testResult = 5; }      
        else { if( not IsInf(Sqrt(INFINITY())))  { set testResult = 6; }      
        }}}}}

        return testResult;
    }
}

