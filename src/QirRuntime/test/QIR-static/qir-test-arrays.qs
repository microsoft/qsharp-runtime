// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR {

    function UpdateArray(array: Double[], mapper : (Double -> Double)) : Double[]
    {
        mutable result = new Double[0];
        for (element in array)
        {
            set result = result + [ mapper(element) ];
        }
        return result;
    }

    function Adder(a : Double, b : Double) : Double
    {
        return a + b;
    }

    function NetPositive(array : Double[]) : Int
    {
        mutable count = 0;
        let tolerance = 0.0001;
        for (element in array)
        {
            if (element > tolerance)
            {
                set count = count + 1;
            }
            elif (element < -tolerance)
            {
                set count = count - 1;
            }
        }
        return count;
    }

    @EntryPoint()
    operation Test_Arrays (array : Double[], seed : Double, count : Int) : Int
    {
        mutable current = array;
        mutable posCount = 0;

        for (i in 1..count)
        {
            set current = UpdateArray(current, Adder(seed, _));
            set posCount = posCount + NetPositive(current);
        }

        return posCount;
    }
}
