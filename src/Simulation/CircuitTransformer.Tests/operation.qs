namespace Microsoft.Hack {
    open Microsoft.Quantum.Intrinsic;

    operation Foo() : Int {

        using ((q1, q2) = (Qubit(), Qubit())) {
            H(q1);

            // Replace the following block with ApplyIfOne.
            if (M(q1) == One) {
                X(q2);
            }
        }

        return 0;
    }


}