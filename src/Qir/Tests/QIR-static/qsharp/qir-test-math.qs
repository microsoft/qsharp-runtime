// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR.Math {

    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Math;        // E()
    open Microsoft.Quantum.Random;
    open Microsoft.Quantum.Convert;     // DoubleAsString()

    @EntryPoint()
    function SqrtTest() : Int {
        if  2.0 != Sqrt(  4.0)          { return 1; }           // The return value indicates which test case has failed.
        if  3.0 != Sqrt(  9.0)          { return 2; }     
        if 10.0 != Sqrt(100.0)          { return 3; }     

        if not IsNan(Sqrt(-5.0))            { return 4; }      
        if not IsNan(Sqrt(NAN()))           { return 5; }      
        if not IsInf(Sqrt(INFINITY()))      { return 6; }      

        return 0;
    }

    @EntryPoint()
    function LogTest() : Int {
        if 1.0 != Log(E())                          { return 1; }       // ln(e)   -> 1     // The return value indicates which test case has failed.
        if 2.0 != Log(E() * E())                    { return 2; }       // ln(e^2) -> 2

        if not IsNegativeInfinity(Log(0.0))         { return 3; }        // ln(0)           -> (-nfinity)
        if not IsNan(Log(-5.0))                     { return 4; }        // ln(<negaive>)   -> NaN
        if not IsNan(Log(NAN()))                    { return 5; }        // ln(NaN)         -> NaN
        if not IsInf(Log(INFINITY()))               { return 6; }        // ln(+infinity)   -> +infinity

        return 0;
    }

    @EntryPoint()
    function InfTest() : Int {
        if IsInf(0.0)                               { return 1; }
        if not IsInf(INFINITY())                    { return 2; }
        if IsInf(-INFINITY())                       { return 3; }

        if IsNegativeInfinity(0.0)                  { return 4; }
        if not IsNegativeInfinity(-INFINITY())      { return 5; }
        if IsNegativeInfinity(INFINITY())           { return 6; }

        return 0;
    }

    @EntryPoint()
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

    @EntryPoint()
    operation TestDrawRandomInt(min : Int, max : Int) : Int {
        return DrawRandomInt(min, max);
    }

    @EntryPoint()
    operation TestDrawRandomDouble(min : Double, max : Double) : Double {
        return DrawRandomDouble(min, max);
    }

    @EntryPoint()
    function Close(expected : Double, actual : Double) : Bool {
        let neighbourhood = 0.0000001;  // On x86-64 + Win the error is in 16th digit after the decimal point. 
                                        // E.g. enstead of 0.0 there can be 0.00000000000000012.
                                        // Thus 0.0000001 should be more than enough.

        return ((expected - neighbourhood) < actual) and (actual < (expected + neighbourhood));
    }

    @EntryPoint()
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

    @EntryPoint()
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

    @EntryPoint()
    function TanTest() : Int {
        // function Tan (theta : Double) : Double
        if not Close( 0.0, Tan(0.0))                            { return  1; }    // The return value indicates which test case has failed.
        if not Close( 0.5/(Sqrt(3.0)/2.0), Tan( PI()/6.0))      { return  2; }  // tg(Pi/6) = sin(Pi/6) / cos(Pi/6) = (1/2) / (sqrt(3)/2)
        if not Close( 1.0, Tan( PI()/4.0))                      { return  3; }
        if not Close( (Sqrt(3.0)/2.0)/0.5, Tan( PI()/3.0))      { return  4; }
        // https://en.cppreference.com/w/cpp/numeric/math/tan
        // The function has mathematical poles at Pi(1/2 + n); however no common floating-point representation 
        // is able to represent Pi/2 exactly, thus there is no value of the argument for which a pole error occurs.
        if not Close(-1.0, Tan(3.0*PI()/4.0))                   { return  5; }
        if not Close( 0.0, Tan(PI()))                           { return  6; }

        if not Close(-0.5/(Sqrt(3.0)/2.0), Tan(-PI()/6.0))      { return  7; }
        if not Close(-1.0, Tan(-PI()/4.0))                      { return  8; }
        if not Close(-(Sqrt(3.0)/2.0)/0.5, Tan(-PI()/3.0))      { return  9; }
        if not Close( 1.0, Tan(-3.0*PI()/4.0))                  { return 10; }

        if NAN() != Tan(NAN())                                  { return 11; }
        if NAN() != Tan(INFINITY())                             { return 12; }
        if NAN() != Tan(-INFINITY())                            { return 13; }

        return 0;
    }

    @EntryPoint()
    function ArcSinTest() : Int {

        // function ArcSin (theta : Double) : Double

        if not Close(0.0, ArcSin(0.0))                  { return  1; }    // The return value indicates which test case has failed.

        if not Close(PI()/6.0, ArcSin(0.5))             { return  2; }
        if not Close(PI()/2.0, ArcSin(1.0))             { return  3; }

        if not Close(-PI()/6.0, ArcSin(-0.5))           { return  4; }
        if not Close(-PI()/2.0, ArcSin(-1.0))           { return  5; }

        if not Close(PI()/4.0, ArcSin(Sqrt(2.0)/2.0))   { return  6; }

        if NAN() != ArcSin(NAN())                       { return  7; }
        if NAN() != ArcSin(1.1)                         { return  8; }
        if NAN() != ArcSin(-1.1)                        { return  9; }

        mutable testVal = -1.0;
        while testVal <= 1.0 {
            if not Close(testVal, Sin(ArcSin(testVal))) { return 10; }
            set testVal = testVal + 0.1;
        }

        return 0;
    }

    @EntryPoint()
    function ArcCosTest() : Int {

        // function ArcCos (theta : Double) : Double

        if not Close( 0.0, ArcCos(1.0))                 { return  1; }    // The return value indicates which test case has failed.
        if not Close( PI()/3.0, ArcCos(0.5))            { return  2; }
        if not Close( PI()/2.0, ArcCos(0.0))            { return  3; }
        if not Close(2.0*PI()/3.0, ArcCos(-0.5))        { return  4; }
        if not Close(PI(), ArcCos(-1.0))                { return  5; }

        if not Close(PI()/4.0, ArcCos(Sqrt(2.0)/2.0))   { return  6; }

        if NAN() != ArcCos(NAN())                       { return  7; }
        if NAN() != ArcCos(1.1)                         { return  8; }
        if NAN() != ArcCos(-1.1)                        { return  9; }

        mutable testVal = -1.0;
        while testVal <= 1.0 {
            if not Close(testVal, Cos(ArcCos(testVal))) { return 10; }
            set testVal = testVal + 0.1;
        }

        return 0;
    }

    @EntryPoint()
    function ArcTanTest() : Int {

        // function ArcTan (theta : Double) : Double

        if not Close( 0.0, ArcTan(0.0))                     { return  1; }  // The return value indicates which test case has failed.
        if not Close( PI()/6.0, ArcTan(1.0/Sqrt(3.0)))      { return  2; }  // tg(Pi/6) = sin(Pi/6) / cos(Pi/6) = (1/2) / (sqrt(3)/2) = 1/sqrt(3)
        if not Close( PI()/4.0, ArcTan(1.0))                { return  3; }
        if not Close( PI()/3.0, ArcTan(Sqrt(3.0)))          { return  4; }

        if not Close(-PI()/6.0, ArcTan(-1.0/Sqrt(3.0)))     { return  5; }
        if not Close(-PI()/4.0, ArcTan(-1.0))               { return  6; }
        if not Close(-PI()/3.0, ArcTan(-Sqrt(3.0)))         { return  7; }

        if NAN() != ArcTan(NAN())                           { return  8; }
        if not Close( PI()/2.0, ArcTan( INFINITY()))        { return  9; }
        if not Close(-PI()/2.0, ArcTan(-INFINITY()))        { return 10; }

        mutable testVal = -10.0;
        while testVal <= 10.0 {
            if not Close(testVal, Tan(ArcTan(testVal)))     { return 11; }
            set testVal = testVal + 0.1;
        }

        return 0;
    }

    @EntryPoint()
    function SinhTest() : Int {

        // function Sinh (theta : Double) : Double

        let xValues = [ -5.0, -4.5, -4.0, -3.5, -3.0, -2.5, -2.0, -1.5, -1.0, -0.5,
                         5.0,  4.5,  4.0,  3.5,  3.0,  2.5,  2.0,  1.5,  1.0,  0.5, 0.0 ];
        for x in xValues {
            if not Close( (ExpD(x) - ExpD(-x)) / 2.0, Sinh(x)) { return 1; }    // The return value indicates which test case has failed.
        }

        if NAN()        != Sinh(NAN())                      { return 2; }
        if INFINITY()   != Sinh(INFINITY())                 { return 3; }
        if -INFINITY()  != Sinh(-INFINITY())                { return 4; }

        return 0;
    }

    @EntryPoint()
    function CoshTest() : Int {

        // function Cosh (theta : Double) : Double

        let xValues = [ -5.0, -4.5, -4.0, -3.5, -3.0, -2.5, -2.0, -1.5, -1.0, -0.5,
                         5.0,  4.5,  4.0,  3.5,  3.0,  2.5,  2.0,  1.5,  1.0,  0.5, 0.0 ];
        for x in xValues {
            if not Close( (ExpD(x) + ExpD(-x)) / 2.0, Cosh(x)) { return 1; }    // The return value indicates which test case has failed.
        }

        if NAN()        != Cosh(NAN())                      { return 2; }
        if INFINITY()   != Cosh(INFINITY())                 { return 3; }
        if INFINITY()   != Cosh(-INFINITY())                { return 4; }

        return 0;
    }

    @EntryPoint()
    function TanhTest() : Int {

        // function Tanh (theta : Double) : Double

        let xValues = [ -5.0, -4.5, -4.0, -3.5, -3.0, -2.5, -2.0, -1.5, -1.0, -0.5,
                         5.0,  4.5,  4.0,  3.5,  3.0,  2.5,  2.0,  1.5,  1.0,  0.5, 0.0 ];
        for x in xValues {
            if not Close( Sinh(x) / Cosh(x), Tanh(x))       { return 1; }    // The return value indicates which test case has failed.
        }

        if NAN() != Tanh(NAN())         { return 2; }
        if  1.0  != Tanh(INFINITY())    { return 3; }
        if -1.0  != Tanh(-INFINITY())   { return 4; }

        return 0;
    }

    @EntryPoint()
    function IeeeRemainderTest() : Int {

        // function IeeeRemainder(x : Double, y : Double) : Double

        mutable dividend = -10.0;
        while dividend <= 10.0 {

            mutable divisor = -20.0;
            while divisor < 20.0 {
                if divisor != 0.0 {
                    let absFractionalPart = AbsD(dividend / divisor) - IntAsDouble(AbsI(Truncate(dividend / divisor)));
                    if not Close(0.5, absFractionalPart) {  // Because of the calculation errors the 
                        // fractional part close to 0.5 causes very different result for 
                        // the `remainder` and `IEEERemainder()` calculated below.
                        // That is normal but we avoid that.
                        let remainder = dividend - (divisor * IntAsDouble(Round(dividend / divisor)));  
                        if not Close(remainder, IEEERemainder(dividend, divisor)) {
                            Message(DoubleAsString(remainder));     // The output for the test faiulure analysis, 
                            Message(DoubleAsString(dividend));      // if the failure happens.
                            Message(DoubleAsString(divisor));
                            Message(DoubleAsString(IEEERemainder(dividend, divisor)));
                            return 1;
                        }
                    }
                }
                set divisor = divisor + 0.3;
            }
            set dividend = dividend + 0.1;
        }

        if NAN() != IEEERemainder( INFINITY(), 1.0) { return 2; }
        if NAN() != IEEERemainder(-INFINITY(), 1.0) { return 3; }
        if NAN() != IEEERemainder(1.0, 0.0)         { return 4; }
        if NAN() != IEEERemainder(NAN(), 1.0)       { return 5; }
        if NAN() != IEEERemainder(1.0, NAN())       { return 6; }
        if NAN() != IEEERemainder(NAN(), NAN())     { return 7; }

        return 0;
    }

}
