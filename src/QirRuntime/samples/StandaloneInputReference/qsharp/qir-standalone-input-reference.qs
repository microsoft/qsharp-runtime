namespace Quantum.StandaloneSupportedInputs {

    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    @EntryPoint()
    operation ExerciseInputs (intValue : Int, doubleValue : Double, resultValue : Result, stringValue : String) : Int {
        Message("Exercise Supported Inputs");
        Message($"intValue: {intValue}");
        Message($"doubleValue: {doubleValue}");
        Message($"resultValue: {resultValue}");
        Message($"stringValue: {stringValue}");
        return 0;
    }
}
