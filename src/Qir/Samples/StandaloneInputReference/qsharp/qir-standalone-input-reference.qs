namespace Quantum.StandaloneSupportedInputs {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;

    function ArrayToString<'T> (array : 'T[]) : String
    {
        mutable first = true;
        mutable itemsString = "[";
        for item in array
        {
            if (first)
            {
                set first = false;
                set itemsString = itemsString + $"{item}";
            }
            else
            {
                set itemsString = itemsString + $", {item}";
            }
        }

        set itemsString = itemsString + "]";
        return itemsString;
    }

    function TautologyPredicate<'T> (input : 'T) : Bool
    {
        return true;
    }

    @EntryPoint()
    operation ExerciseInputs (intValue : Int, intArray : Int[], doubleValue : Double, doubleArray : Double[], boolValue : Bool, boolArray : Bool[], pauliValue : Pauli, pauliArray : Pauli[], rangeValue : Range, resultValue : Result, resultArray : Result[], stringValue : String, stringArray : String[]) : Unit {
        Message("Exercise Supported Inputs Reference");
        Message($"intValue: {intValue}");
        Message($"intArray: {ArrayToString<Int>(intArray)} ({Count(TautologyPredicate<Int>, intArray)})");
        Message($"doubleValue: {doubleValue}");
        Message($"doubleArray: {ArrayToString<Double>(doubleArray)} ({Count(TautologyPredicate<Double>, doubleArray)})");
        Message($"boolValue: {boolValue}");
        Message($"boolArray: {ArrayToString<Bool>(boolArray)} ({Count(TautologyPredicate<Bool>, boolArray)})");
        Message($"pauliValue: {pauliValue}");
        Message($"pauliArray: {ArrayToString<Pauli>(pauliArray)} ({Count(TautologyPredicate<Pauli>, pauliArray)})");
        Message($"rangeValue: {rangeValue}");
        Message($"resultValue: {resultValue}");
        Message($"resultArray: {ArrayToString<Result>(resultArray)} ({Count(TautologyPredicate<Result>, resultArray)})");
        Message($"stringValue: {stringValue}");
        Message($"stringArray: {ArrayToString<String>(stringArray)} ({Count(TautologyPredicate<String>, stringArray)})");
    }
}
