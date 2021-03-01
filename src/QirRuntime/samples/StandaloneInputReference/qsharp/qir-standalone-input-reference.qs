namespace Quantum.StandaloneSupportedInputs {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation ExerciseInputs (intValue : Int, doubleValue : Double) : Int {
        Message("Exercise Supported Inputs");
        Message($"intValue: {intValue}");
        Message($"doubleValue: {doubleValue}");
        return 0;
    }
}
