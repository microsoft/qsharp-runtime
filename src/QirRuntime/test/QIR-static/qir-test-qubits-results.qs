namespace Microsoft.Quantum.Testing.QIR
{
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation Test_Qubit_Result_Management() : Bool
    {
        // exercise __quantum__rt__qubit_allocate_array
        using(qs = Qubit[2])
        {
            X(qs[1]);
            // exercise __quantum__rt__qubit_allocate
            using (q = Qubit())
            {
                // exercise __quantum__rt__result_equal and accessing result constants
                if (M(qs[1]) == One) {X(q);}
                return M(qs[0]) != M(q);
            } // exercise __quantum__rt__qubit_release
        } // exercise __quantum__rt__qubit_release_array
    }
}