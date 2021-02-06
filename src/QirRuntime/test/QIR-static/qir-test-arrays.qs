// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Testing.QIR.Math;

    @EntryPoint()
    operation Test_Arrays(array : Int[], index : Int, val : Int, dummy : Bool) : Int
    {
        // exercise __quantum__rt__array_copy
        mutable local = array;

        // exercise __quantum__rt__array_get_element_ptr_1d
        set local w/= index <- val;

        // exercise __quantum__rt__array_get_size
        let n = Length(local);

        // exercise __quantum__rt__array_slice with various ranges
        let slice1 = local[index .. Length(local) - 1];
        let slice2 = local[index..-2..0];

        // exercise __quantum__rt__array_concatenate
        let result = slice2 + slice1;

        // return a value that is likely to be correct only if the above operations did what was expected
        mutable sum = 0;
        for (i in 0..Length(result)-1)
        {
            set sum += result[i];
        }

        // The purpose of this block is to keep the Q# compiler from optimizing away other tests when generating QIR
        if (dummy)
        {
            let res1 = TestControlled();
            let res2 = TestPartials(17, 42);
            let res3 = Test_Qubit_Result_Management();
            let res4 = SqrtTest();
        }

        return sum;
    }

}
