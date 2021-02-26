namespace Microsoft.Quantum.Testing.QIR {

    @EntryPoint()
    operation Tests() : Unit {
        TestApplyIf();
        TestApplyIfWithFunctors();
        TestApplyConditionally();
    }

}
