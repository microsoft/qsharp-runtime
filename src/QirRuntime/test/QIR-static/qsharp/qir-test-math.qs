// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Math {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;        // E()
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Convert;     // DoubleAsString()

    function SqrtTest() : Int {
        if  2.0 != Sqrt(  4.0)          { return 1; }           // The return value indicates which test case has failed.
        if  3.0 != Sqrt(  9.0)          { return 2; }     
        if 10.0 != Sqrt(100.0)          { return 3; }     

        if not IsNan(Sqrt(-5.0))            { return 4; }      
        if not IsNan(Sqrt(NAN()))           { return 5; }      
        if not IsInf(Sqrt(INFINITY()))      { return 6; }      

        return 0;
    }

    function LogTest() : Int {
        if 1.0 != Log(E())                          { return 1; }       // ln(e)   -> 1     // The return value indicates which test case has failed.
        if 2.0 != Log(E() * E())                    { return 2; }       // ln(e^2) -> 2

        if not IsNegativeInfinity(Log(0.0))         { return 3; }        // ln(0)           -> (-nfinity)
        if not IsNan(Log(-5.0))                     { return 4; }        // ln(<negaive>)   -> NaN
        if not IsNan(Log(NAN()))                    { return 5; }        // ln(NaN)         -> NaN
        if not IsInf(Log(INFINITY()))               { return 6; }        // ln(+infinity)   -> +infinity

        return 0;
    }

    function ArcTan2Test() : Int {

        // function ArcTan2(y : Double, x : Double) : Double 

        if  0.0          != ArcTan2( 0.0,  1.0 )    { return 1; }    // The return value indicates which test case has failed.
        if  PI()         != ArcTan2( 0.0, -1.0 )    { return 2; }
        if  PI()/2.0     != ArcTan2( 1.0,  0.0 )    { return 3; }
        if -PI()/2.0     != ArcTan2(-1.0,  0.0 )    { return 4; }

        if  PI()/4.0     != ArcTan2( 1.0,  1.0 )    { return 5; }
        if  PI()*3.0/4.0 != ArcTan2( 1.0, -1.0 )    { return 6; }
        if -PI()*3.0/4.0 != ArcTan2(-1.0, -1.0 )    { return 7; }
        if -PI()/4.0     != ArcTan2(-1.0,  1.0 )    { return 8; }

        if  0.0          != ArcTan2( 0.0,  0.0 )    { return 9; }    

        // Fails because of lack of precision:
        // if  PI()/6.0  != ArcTan2( 1.0, Sqrt(3.0) )      { return 10; }      // tg(Pi/6) = sin(Pi/6) / cos(Pi/6) = (1/2) / (Sqrt(3)/2) = 1/Sqrt(3) = y/x.  ArcTan2(1.0, Sqrt(3)) -> Pi/6

        if not IsNan(ArcTan2(NAN(),   0.0) )        { return 11; }
        if not IsNan(ArcTan2(  0.0, NAN()) )        { return 12; }
        if not IsNan(ArcTan2(NAN(), NAN()) )        { return 13; }

        // The infinity cases show discrepancy between  
        // https://docs.microsoft.com/en-us/dotnet/api/system.math.atan2?view=net-5.0
        // and https://en.cppreference.com/w/cpp/numeric/math/atan2 .
        
        return 0;
    }

    operation TestDrawRandomInt(min : Int, max : Int) : Int {
        return DrawRandomInt(min, max);
    }

    function Close(expected : Double, actual : Double) : Bool {
        let neighbourhood = 0.0000001;  // On x86-64 + Win the error is in 16th digit after the decimal point. 
                                        // E.g. enstead of 0.0 there can be 0.00000000000000012.
                                        // Thus 0.0000001 should be more than enough.

        return ((expected - neighbourhood) < actual) and (actual < (expected + neighbourhood));
    }

    function SinTest() : Int {

        // function Sin (theta : Double) : Double

        if not Close(0.0, Sin(0.0))                 { return  1; }    // The return value indicates which test case has failed.
        if not Close(0.5, Sin(PI()/6.0))            { return  2; }
        if not Close(1.0, Sin(PI()/2.0))            { return  3; }
        if not Close(0.5, Sin(5.0*PI()/6.0))        { return  4; }
        if not Close(0.0, Sin(PI()))                { return  5; }

        if not Close(-0.5, Sin(-5.0*PI()/6.0))      { return  6; }
        if not Close(-1.0, Sin(-PI()/2.0))          { return  7; }
        if not Close(-0.5, Sin(-PI()/6.0))          { return  8; }

        if not Close(Sqrt(2.0)/2.0, Sin(PI()/4.0))  { return  9; }
                                                                                              
        if NAN() != Sin(NAN())                      { return 10; }
        if NAN() != Sin(INFINITY())                 { return 11; }
        if NAN() != Sin(-INFINITY())                { return 11; }

        return 0;
    }

    function CosTest() : Int {

        // function Cos (theta : Double) : Double

        if not Close( 1.0, Cos(0.0))                { return  1; }    // The return value indicates which test case has failed.
        if not Close( 0.5, Cos(PI()/3.0))           { return  2; }
        if not Close( 0.0, Cos(PI()/2.0))           { return  3; }
        if not Close(-0.5, Cos(2.0*PI()/3.0))       { return  4; }
        if not Close(-1.0, Cos(PI()))               { return  5; }

        if not Close(-0.5, Cos(-2.0*PI()/3.0))      { return  6; }
        if not Close( 0.0, Cos(-PI()/2.0))          { return  7; }
        if not Close( 0.5, Cos(-PI()/3.0))          { return  8; }

        if not Close(Sqrt(2.0)/2.0, Cos(PI()/4.0))  { return  9; }
                                                                                              
        if NAN() != Cos(NAN())                      { return 10; }
        if NAN() != Cos(INFINITY())                 { return 11; }
        if NAN() != Cos(-INFINITY())                { return 11; }

        return 0;
    }
}

