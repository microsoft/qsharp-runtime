namespace Quantum.StandaloneSupportedInputs {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    function TautologyPredicate<'T> (input : 'T) : Bool
    {
        return true;
    }

    @EntryPoint()
    operation ExerciseInputs (intValue : Int, intArray : Int[], doubleValue : Double, doubleArray : Double[], boolValue : Bool, boolArray : Bool[], pauliValue : Pauli, pauliArray : Pauli[], rangeValue : Range, resultValue : Result, resultArray : Result[], stringValue : String) : Unit {
        Message("Exercise Supported Inputs Reference");
        Message($"intValue: {intValue}");
        Message($"intArray: {intArray} ({Count(TautologyPredicate<Int>, intArray)})");
        Message($"doubleValue: {doubleValue}");
        Message($"doubleArray: {doubleArray} ({Count(TautologyPredicate<Double>, doubleArray)})");
        Message($"boolValue: {boolValue}");
        Message($"boolArray: {boolArray} ({Count(TautologyPredicate<Bool>, boolArray)})");
        Message($"pauliValue: {pauliValue}");
        Message($"pauliArray: {pauliArray} ({Count(TautologyPredicate<Pauli>, pauliArray)})");
        Message($"rangeValue: {rangeValue}");
        Message($"resultValue: {resultValue}");
        Message($"resultArray: {resultArray} ({Count(TautologyPredicate<Result>, resultArray)})");
        Message($"stringValue: {stringValue}");
    }
}
