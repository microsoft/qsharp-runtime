// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Testing.QIR {
    open Microsoft.Quantum.Testing.QIR.Math;
    open Microsoft.Quantum.Testing.QIR.Str;
    open Microsoft.Quantum.Testing.QIR.Out;

    @EntryPoint()
    operation Test_Arrays(array : Int[], index : Int, val : Int, compilerDecoy : Bool) : Int {
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
        for i in 0..Length(result)-1 {
            set sum += result[i];
        }

        // The purpose of this block is to keep the Q# compiler from optimizing away other tests when generating QIR
        if (compilerDecoy) {
            let res1 = TestControlled();
            let res2 = TestPartials(17, 42);
            TestQubitResultManagement();

            // Math tests:
            let res4 = SqrtTest();
            let res5 = LogTest();
            let res6 = ArcTan2Test();
            let res7 = PauliToStringTest();
            let res8 = TestDrawRandomInt(0, 1);
            let res9 = SinTest();
            let res10 = CosTest();
            MessageTest("Test");
        }
        return sum;
    }
}
