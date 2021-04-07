
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Result = type opaque
%Array = type opaque
%String = type opaque
%Callable = type opaque

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@0 = internal constant [36 x i8] c"Exercise Supported Inputs Reference\00"
@1 = internal constant [11 x i8] c"intValue: \00"
@Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@2 = internal constant [11 x i8] c"intArray: \00"
@3 = internal constant [3 x i8] c" (\00"
@4 = internal constant [2 x i8] c")\00"
@5 = internal constant [14 x i8] c"doubleValue: \00"
@Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@6 = internal constant [14 x i8] c"doubleArray: \00"
@7 = internal constant [3 x i8] c" (\00"
@8 = internal constant [2 x i8] c")\00"
@9 = internal constant [12 x i8] c"boolValue: \00"
@Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@10 = internal constant [12 x i8] c"boolArray: \00"
@11 = internal constant [3 x i8] c" (\00"
@12 = internal constant [2 x i8] c")\00"
@13 = internal constant [13 x i8] c"pauliValue: \00"
@Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@14 = internal constant [13 x i8] c"pauliArray: \00"
@15 = internal constant [3 x i8] c" (\00"
@16 = internal constant [2 x i8] c")\00"
@17 = internal constant [13 x i8] c"rangeValue: \00"
@18 = internal constant [14 x i8] c"resultValue: \00"
@Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@19 = internal constant [14 x i8] c"resultArray: \00"
@20 = internal constant [3 x i8] c" (\00"
@21 = internal constant [2 x i8] c")\00"
@22 = internal constant [14 x i8] c"stringValue: \00"
@23 = internal constant [2 x i8] c"[\00"
@24 = internal constant [3 x i8] c", \00"
@25 = internal constant [2 x i8] c"]\00"
@26 = internal constant [2 x i8] c"[\00"
@27 = internal constant [3 x i8] c", \00"
@28 = internal constant [2 x i8] c"]\00"
@29 = internal constant [2 x i8] c"[\00"
@30 = internal constant [3 x i8] c", \00"
@31 = internal constant [2 x i8] c"]\00"
@32 = internal constant [2 x i8] c"[\00"
@33 = internal constant [3 x i8] c", \00"
@34 = internal constant [2 x i8] c"]\00"
@35 = internal constant [2 x i8] c"[\00"
@36 = internal constant [3 x i8] c", \00"
@37 = internal constant [2 x i8] c"]\00"
@38 = internal constant [3 x i8] c"()\00"

define void @Quantum__StandaloneSupportedInputs__ExerciseInputs__body(i64 %intValue, %Array* %intArray, double %doubleValue, %Array* %doubleArray, i1 %boolValue, %Array* %boolArray, i2 %pauliValue, %Array* %pauliArray, %Range %rangeValue, %Result* %resultValue, %Array* %resultArray, %String* %stringValue) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %intArray, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %doubleArray, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %boolArray, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %pauliArray, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %resultArray, i32 1)
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([36 x i8], [36 x i8]* @0, i32 0, i32 0))
  call void @__quantum__rt__message(%String* %0)
  %1 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @1, i32 0, i32 0))
  %2 = call %String* @__quantum__rt__int_to_string(i64 %intValue)
  %3 = call %String* @__quantum__rt__string_concatenate(%String* %1, %String* %2)
  call void @__quantum__rt__string_update_reference_count(%String* %1, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %2, i32 -1)
  call void @__quantum__rt__message(%String* %3)
  %4 = call %String* @Quantum__StandaloneSupportedInputs___58b06fb8838645aba850713a715678d6_ArrayToString__body(%Array* %intArray)
  %5 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %6 = call i64 @Microsoft__Quantum__Arrays___8487a9df7d0d4ac5a6694fb1d077b2b4_Count__body(%Callable* %5, %Array* %intArray)
  %7 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @2, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %4, i32 1)
  %8 = call %String* @__quantum__rt__string_concatenate(%String* %7, %String* %4)
  call void @__quantum__rt__string_update_reference_count(%String* %7, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i32 -1)
  %9 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @3, i32 0, i32 0))
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  %11 = call %String* @__quantum__rt__int_to_string(i64 %6)
  %12 = call %String* @__quantum__rt__string_concatenate(%String* %10, %String* %11)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  %13 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @4, i32 0, i32 0))
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  call void @__quantum__rt__message(%String* %14)
  %15 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @5, i32 0, i32 0))
  %16 = call %String* @__quantum__rt__double_to_string(double %doubleValue)
  %17 = call %String* @__quantum__rt__string_concatenate(%String* %15, %String* %16)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %16, i32 -1)
  call void @__quantum__rt__message(%String* %17)
  %18 = call %String* @Quantum__StandaloneSupportedInputs___651cdf0b91af440a8c52eefc05d57b06_ArrayToString__body(%Array* %doubleArray)
  %19 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %20 = call i64 @Microsoft__Quantum__Arrays___1575e931e75b478d9338ff1c1ba98161_Count__body(%Callable* %19, %Array* %doubleArray)
  %21 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @6, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 1)
  %22 = call %String* @__quantum__rt__string_concatenate(%String* %21, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %21, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  %23 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @7, i32 0, i32 0))
  %24 = call %String* @__quantum__rt__string_concatenate(%String* %22, %String* %23)
  call void @__quantum__rt__string_update_reference_count(%String* %22, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %23, i32 -1)
  %25 = call %String* @__quantum__rt__int_to_string(i64 %20)
  %26 = call %String* @__quantum__rt__string_concatenate(%String* %24, %String* %25)
  call void @__quantum__rt__string_update_reference_count(%String* %24, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %25, i32 -1)
  %27 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @8, i32 0, i32 0))
  %28 = call %String* @__quantum__rt__string_concatenate(%String* %26, %String* %27)
  call void @__quantum__rt__string_update_reference_count(%String* %26, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %27, i32 -1)
  call void @__quantum__rt__message(%String* %28)
  %29 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @9, i32 0, i32 0))
  %30 = call %String* @__quantum__rt__bool_to_string(i1 %boolValue)
  %31 = call %String* @__quantum__rt__string_concatenate(%String* %29, %String* %30)
  call void @__quantum__rt__string_update_reference_count(%String* %29, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %30, i32 -1)
  call void @__quantum__rt__message(%String* %31)
  %32 = call %String* @Quantum__StandaloneSupportedInputs___f5a60aadd6b1405d8efce41485ff4d80_ArrayToString__body(%Array* %boolArray)
  %33 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %34 = call i64 @Microsoft__Quantum__Arrays___67c459c137a0446995c133a29250678d_Count__body(%Callable* %33, %Array* %boolArray)
  %35 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([12 x i8], [12 x i8]* @10, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %32, i32 1)
  %36 = call %String* @__quantum__rt__string_concatenate(%String* %35, %String* %32)
  call void @__quantum__rt__string_update_reference_count(%String* %35, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %32, i32 -1)
  %37 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @11, i32 0, i32 0))
  %38 = call %String* @__quantum__rt__string_concatenate(%String* %36, %String* %37)
  call void @__quantum__rt__string_update_reference_count(%String* %36, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %37, i32 -1)
  %39 = call %String* @__quantum__rt__int_to_string(i64 %34)
  %40 = call %String* @__quantum__rt__string_concatenate(%String* %38, %String* %39)
  call void @__quantum__rt__string_update_reference_count(%String* %38, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %39, i32 -1)
  %41 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @12, i32 0, i32 0))
  %42 = call %String* @__quantum__rt__string_concatenate(%String* %40, %String* %41)
  call void @__quantum__rt__string_update_reference_count(%String* %40, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %41, i32 -1)
  call void @__quantum__rt__message(%String* %42)
  %43 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @13, i32 0, i32 0))
  %44 = call %String* @__quantum__rt__pauli_to_string(i2 %pauliValue)
  %45 = call %String* @__quantum__rt__string_concatenate(%String* %43, %String* %44)
  call void @__quantum__rt__string_update_reference_count(%String* %43, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %44, i32 -1)
  call void @__quantum__rt__message(%String* %45)
  %46 = call %String* @Quantum__StandaloneSupportedInputs___ec0b3349aeaf419f9d7d96decefd1869_ArrayToString__body(%Array* %pauliArray)
  %47 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %48 = call i64 @Microsoft__Quantum__Arrays___c71932228c1b4b6fb8c3c63c9d8e35e4_Count__body(%Callable* %47, %Array* %pauliArray)
  %49 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @14, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %46, i32 1)
  %50 = call %String* @__quantum__rt__string_concatenate(%String* %49, %String* %46)
  call void @__quantum__rt__string_update_reference_count(%String* %49, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %46, i32 -1)
  %51 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @15, i32 0, i32 0))
  %52 = call %String* @__quantum__rt__string_concatenate(%String* %50, %String* %51)
  call void @__quantum__rt__string_update_reference_count(%String* %50, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %51, i32 -1)
  %53 = call %String* @__quantum__rt__int_to_string(i64 %48)
  %54 = call %String* @__quantum__rt__string_concatenate(%String* %52, %String* %53)
  call void @__quantum__rt__string_update_reference_count(%String* %52, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %53, i32 -1)
  %55 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @16, i32 0, i32 0))
  %56 = call %String* @__quantum__rt__string_concatenate(%String* %54, %String* %55)
  call void @__quantum__rt__string_update_reference_count(%String* %54, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %55, i32 -1)
  call void @__quantum__rt__message(%String* %56)
  %57 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([13 x i8], [13 x i8]* @17, i32 0, i32 0))
  %58 = call %String* @__quantum__rt__range_to_string(%Range %rangeValue)
  %59 = call %String* @__quantum__rt__string_concatenate(%String* %57, %String* %58)
  call void @__quantum__rt__string_update_reference_count(%String* %57, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %58, i32 -1)
  call void @__quantum__rt__message(%String* %59)
  %60 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @18, i32 0, i32 0))
  %61 = call %String* @__quantum__rt__result_to_string(%Result* %resultValue)
  %62 = call %String* @__quantum__rt__string_concatenate(%String* %60, %String* %61)
  call void @__quantum__rt__string_update_reference_count(%String* %60, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %61, i32 -1)
  call void @__quantum__rt__message(%String* %62)
  %63 = call %String* @Quantum__StandaloneSupportedInputs___c22db911562e4518b3ec04b3a395976a_ArrayToString__body(%Array* %resultArray)
  %64 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %65 = call i64 @Microsoft__Quantum__Arrays___aa464afb2404486a86d7d9b45b4e8d2c_Count__body(%Callable* %64, %Array* %resultArray)
  %66 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @19, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %63, i32 1)
  %67 = call %String* @__quantum__rt__string_concatenate(%String* %66, %String* %63)
  call void @__quantum__rt__string_update_reference_count(%String* %66, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %63, i32 -1)
  %68 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @20, i32 0, i32 0))
  %69 = call %String* @__quantum__rt__string_concatenate(%String* %67, %String* %68)
  call void @__quantum__rt__string_update_reference_count(%String* %67, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %68, i32 -1)
  %70 = call %String* @__quantum__rt__int_to_string(i64 %65)
  %71 = call %String* @__quantum__rt__string_concatenate(%String* %69, %String* %70)
  call void @__quantum__rt__string_update_reference_count(%String* %69, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %70, i32 -1)
  %72 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @21, i32 0, i32 0))
  %73 = call %String* @__quantum__rt__string_concatenate(%String* %71, %String* %72)
  call void @__quantum__rt__string_update_reference_count(%String* %71, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %72, i32 -1)
  call void @__quantum__rt__message(%String* %73)
  %74 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @22, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %stringValue, i32 1)
  %75 = call %String* @__quantum__rt__string_concatenate(%String* %74, %String* %stringValue)
  call void @__quantum__rt__string_update_reference_count(%String* %74, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %stringValue, i32 -1)
  call void @__quantum__rt__message(%String* %75)
  call void @__quantum__rt__array_update_alias_count(%Array* %intArray, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %doubleArray, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %boolArray, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %pauliArray, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %resultArray, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %3, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %5, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %5, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %28, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %31, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %32, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %33, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %33, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %42, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %45, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %46, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %47, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %47, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %56, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %59, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %62, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %63, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %64, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %64, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %73, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %75, i32 -1)
  ret void
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i32)

declare %String* @__quantum__rt__string_create(i8*)

declare void @__quantum__rt__message(%String*)

declare void @__quantum__rt__string_update_reference_count(%String*, i32)

declare %String* @__quantum__rt__int_to_string(i64)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

define %String* @Quantum__StandaloneSupportedInputs___58b06fb8838645aba850713a715678d6_ArrayToString__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %first = alloca i1, align 1
  store i1 true, i1* %first, align 1
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @23, i32 0, i32 0))
  %itemsString = alloca %String*, align 8
  store %String* %0, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to i64*
  %item = load i64, i64* %6, align 4
  %7 = load i1, i1* %first, align 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %body__1
  store i1 false, i1* %first, align 1
  %8 = load %String*, %String** %itemsString, align 8
  %9 = call %String* @__quantum__rt__int_to_string(i64 %item)
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 1)
  store %String* %10, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  br label %continue__1

else__1:                                          ; preds = %body__1
  %11 = load %String*, %String** %itemsString, align 8
  %12 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @24, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__int_to_string(i64 %item)
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  %15 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 1)
  store %String* %15, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load %String*, %String** %itemsString, align 8
  %18 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @25, i32 0, i32 0))
  %19 = call %String* @__quantum__rt__string_concatenate(%String* %17, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 1)
  store %String* %19, %String** %itemsString, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 -1)
  ret %String* %19
}

define i64 @Microsoft__Quantum__Arrays___8487a9df7d0d4ac5a6694fb1d077b2b4_Count__body(%Callable* %predicate, %Array* %array) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %totalFound = alloca i64, align 8
  store i64 0, i64* %totalFound, align 4
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to i64*
  %element = load i64, i64* %5, align 4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { i64 }*
  %8 = getelementptr inbounds { i64 }, { i64 }* %7, i32 0, i32 0
  store i64 %element, i64* %8, align 4
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %predicate, %Tuple* %6, %Tuple* %9)
  %10 = bitcast %Tuple* %9 to { i1 }*
  %11 = getelementptr inbounds { i1 }, { i1 }* %10, i32 0, i32 0
  %12 = load i1, i1* %11, align 1
  br i1 %12, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %13 = load i64, i64* %totalFound, align 4
  %14 = add i64 %13, 1
  store i64 %14, i64* %totalFound, align 4
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %totalFound, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  ret i64 %16
}

define void @Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i64 }*
  %1 = getelementptr inbounds { i64 }, { i64 }* %0, i32 0, i32 0
  %2 = load i64, i64* %1, align 4
  %3 = call i1 @Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate__body(i64 %2)
  %4 = bitcast %Tuple* %result-tuple to { i1 }*
  %5 = getelementptr inbounds { i1 }, { i1 }* %4, i32 0, i32 0
  store i1 %3, i1* %5, align 1
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i32)*]*, %Tuple*)

declare %String* @__quantum__rt__double_to_string(double)

define %String* @Quantum__StandaloneSupportedInputs___651cdf0b91af440a8c52eefc05d57b06_ArrayToString__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %first = alloca i1, align 1
  store i1 true, i1* %first, align 1
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @26, i32 0, i32 0))
  %itemsString = alloca %String*, align 8
  store %String* %0, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to double*
  %item = load double, double* %6, align 8
  %7 = load i1, i1* %first, align 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %body__1
  store i1 false, i1* %first, align 1
  %8 = load %String*, %String** %itemsString, align 8
  %9 = call %String* @__quantum__rt__double_to_string(double %item)
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 1)
  store %String* %10, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  br label %continue__1

else__1:                                          ; preds = %body__1
  %11 = load %String*, %String** %itemsString, align 8
  %12 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @27, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__double_to_string(double %item)
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  %15 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 1)
  store %String* %15, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load %String*, %String** %itemsString, align 8
  %18 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @28, i32 0, i32 0))
  %19 = call %String* @__quantum__rt__string_concatenate(%String* %17, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 1)
  store %String* %19, %String** %itemsString, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 -1)
  ret %String* %19
}

define i64 @Microsoft__Quantum__Arrays___1575e931e75b478d9338ff1c1ba98161_Count__body(%Callable* %predicate, %Array* %array) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %totalFound = alloca i64, align 8
  store i64 0, i64* %totalFound, align 4
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to double*
  %element = load double, double* %5, align 8
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (double* getelementptr (double, double* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { double }*
  %8 = getelementptr inbounds { double }, { double }* %7, i32 0, i32 0
  store double %element, double* %8, align 8
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %predicate, %Tuple* %6, %Tuple* %9)
  %10 = bitcast %Tuple* %9 to { i1 }*
  %11 = getelementptr inbounds { i1 }, { i1 }* %10, i32 0, i32 0
  %12 = load i1, i1* %11, align 1
  br i1 %12, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %13 = load i64, i64* %totalFound, align 4
  %14 = add i64 %13, 1
  store i64 %14, i64* %totalFound, align 4
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %totalFound, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  ret i64 %16
}

define void @Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { double }*
  %1 = getelementptr inbounds { double }, { double }* %0, i32 0, i32 0
  %2 = load double, double* %1, align 8
  %3 = call i1 @Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate__body(double %2)
  %4 = bitcast %Tuple* %result-tuple to { i1 }*
  %5 = getelementptr inbounds { i1 }, { i1 }* %4, i32 0, i32 0
  store i1 %3, i1* %5, align 1
  ret void
}

declare %String* @__quantum__rt__bool_to_string(i1)

define %String* @Quantum__StandaloneSupportedInputs___f5a60aadd6b1405d8efce41485ff4d80_ArrayToString__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %first = alloca i1, align 1
  store i1 true, i1* %first, align 1
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @29, i32 0, i32 0))
  %itemsString = alloca %String*, align 8
  store %String* %0, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to i1*
  %item = load i1, i1* %6, align 1
  %7 = load i1, i1* %first, align 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %body__1
  store i1 false, i1* %first, align 1
  %8 = load %String*, %String** %itemsString, align 8
  %9 = call %String* @__quantum__rt__bool_to_string(i1 %item)
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 1)
  store %String* %10, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  br label %continue__1

else__1:                                          ; preds = %body__1
  %11 = load %String*, %String** %itemsString, align 8
  %12 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @30, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__bool_to_string(i1 %item)
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  %15 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 1)
  store %String* %15, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load %String*, %String** %itemsString, align 8
  %18 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @31, i32 0, i32 0))
  %19 = call %String* @__quantum__rt__string_concatenate(%String* %17, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 1)
  store %String* %19, %String** %itemsString, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 -1)
  ret %String* %19
}

define i64 @Microsoft__Quantum__Arrays___67c459c137a0446995c133a29250678d_Count__body(%Callable* %predicate, %Array* %array) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %totalFound = alloca i64, align 8
  store i64 0, i64* %totalFound, align 4
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to i1*
  %element = load i1, i1* %5, align 1
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { i1 }*
  %8 = getelementptr inbounds { i1 }, { i1 }* %7, i32 0, i32 0
  store i1 %element, i1* %8, align 1
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %predicate, %Tuple* %6, %Tuple* %9)
  %10 = bitcast %Tuple* %9 to { i1 }*
  %11 = getelementptr inbounds { i1 }, { i1 }* %10, i32 0, i32 0
  %12 = load i1, i1* %11, align 1
  br i1 %12, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %13 = load i64, i64* %totalFound, align 4
  %14 = add i64 %13, 1
  store i64 %14, i64* %totalFound, align 4
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %totalFound, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  ret i64 %16
}

define void @Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i1 }*
  %1 = getelementptr inbounds { i1 }, { i1 }* %0, i32 0, i32 0
  %2 = load i1, i1* %1, align 1
  %3 = call i1 @Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate__body(i1 %2)
  %4 = bitcast %Tuple* %result-tuple to { i1 }*
  %5 = getelementptr inbounds { i1 }, { i1 }* %4, i32 0, i32 0
  store i1 %3, i1* %5, align 1
  ret void
}

declare %String* @__quantum__rt__pauli_to_string(i2)

define %String* @Quantum__StandaloneSupportedInputs___ec0b3349aeaf419f9d7d96decefd1869_ArrayToString__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %first = alloca i1, align 1
  store i1 true, i1* %first, align 1
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @32, i32 0, i32 0))
  %itemsString = alloca %String*, align 8
  store %String* %0, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to i2*
  %item = load i2, i2* %6, align 1
  %7 = load i1, i1* %first, align 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %body__1
  store i1 false, i1* %first, align 1
  %8 = load %String*, %String** %itemsString, align 8
  %9 = call %String* @__quantum__rt__pauli_to_string(i2 %item)
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 1)
  store %String* %10, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  br label %continue__1

else__1:                                          ; preds = %body__1
  %11 = load %String*, %String** %itemsString, align 8
  %12 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @33, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__pauli_to_string(i2 %item)
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  %15 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 1)
  store %String* %15, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load %String*, %String** %itemsString, align 8
  %18 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @34, i32 0, i32 0))
  %19 = call %String* @__quantum__rt__string_concatenate(%String* %17, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 1)
  store %String* %19, %String** %itemsString, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 -1)
  ret %String* %19
}

define i64 @Microsoft__Quantum__Arrays___c71932228c1b4b6fb8c3c63c9d8e35e4_Count__body(%Callable* %predicate, %Array* %array) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %totalFound = alloca i64, align 8
  store i64 0, i64* %totalFound, align 4
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to i2*
  %element = load i2, i2* %5, align 1
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i2* getelementptr (i2, i2* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { i2 }*
  %8 = getelementptr inbounds { i2 }, { i2 }* %7, i32 0, i32 0
  store i2 %element, i2* %8, align 1
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %predicate, %Tuple* %6, %Tuple* %9)
  %10 = bitcast %Tuple* %9 to { i1 }*
  %11 = getelementptr inbounds { i1 }, { i1 }* %10, i32 0, i32 0
  %12 = load i1, i1* %11, align 1
  br i1 %12, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %13 = load i64, i64* %totalFound, align 4
  %14 = add i64 %13, 1
  store i64 %14, i64* %totalFound, align 4
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %totalFound, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  ret i64 %16
}

define void @Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i2 }*
  %1 = getelementptr inbounds { i2 }, { i2 }* %0, i32 0, i32 0
  %2 = load i2, i2* %1, align 1
  %3 = call i1 @Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate__body(i2 %2)
  %4 = bitcast %Tuple* %result-tuple to { i1 }*
  %5 = getelementptr inbounds { i1 }, { i1 }* %4, i32 0, i32 0
  store i1 %3, i1* %5, align 1
  ret void
}

declare %String* @__quantum__rt__range_to_string(%Range)

declare %String* @__quantum__rt__result_to_string(%Result*)

define %String* @Quantum__StandaloneSupportedInputs___c22db911562e4518b3ec04b3a395976a_ArrayToString__body(%Array* %array) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %first = alloca i1, align 1
  store i1 true, i1* %first, align 1
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @35, i32 0, i32 0))
  %itemsString = alloca %String*, align 8
  store %String* %0, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to %Result**
  %item = load %Result*, %Result** %6, align 8
  %7 = load i1, i1* %first, align 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %body__1
  store i1 false, i1* %first, align 1
  %8 = load %String*, %String** %itemsString, align 8
  %9 = call %String* @__quantum__rt__result_to_string(%Result* %item)
  %10 = call %String* @__quantum__rt__string_concatenate(%String* %8, %String* %9)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 1)
  store %String* %10, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %9, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %8, i32 -1)
  br label %continue__1

else__1:                                          ; preds = %body__1
  %11 = load %String*, %String** %itemsString, align 8
  %12 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @36, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__result_to_string(%Result* %item)
  %14 = call %String* @__quantum__rt__string_concatenate(%String* %12, %String* %13)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i32 -1)
  %15 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 1)
  store %String* %15, %String** %itemsString, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %14, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %15, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load %String*, %String** %itemsString, align 8
  %18 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([2 x i8], [2 x i8]* @37, i32 0, i32 0))
  %19 = call %String* @__quantum__rt__string_concatenate(%String* %17, %String* %18)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 1)
  store %String* %19, %String** %itemsString, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %18, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i32 -1)
  ret %String* %19
}

define i64 @Microsoft__Quantum__Arrays___aa464afb2404486a86d7d9b45b4e8d2c_Count__body(%Callable* %predicate, %Array* %array) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 1)
  %totalFound = alloca i64, align 8
  store i64 0, i64* %totalFound, align 4
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to %Result**
  %element = load %Result*, %Result** %5, align 8
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Result* }*
  %8 = getelementptr inbounds { %Result* }, { %Result* }* %7, i32 0, i32 0
  store %Result* %element, %Result** %8, align 8
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1* getelementptr (i1, i1* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %predicate, %Tuple* %6, %Tuple* %9)
  %10 = bitcast %Tuple* %9 to { i1 }*
  %11 = getelementptr inbounds { i1 }, { i1 }* %10, i32 0, i32 0
  %12 = load i1, i1* %11, align 1
  br i1 %12, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %13 = load i64, i64* %totalFound, align 4
  %14 = add i64 %13, 1
  store i64 %14, i64* %totalFound, align 4
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %totalFound, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %predicate, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i32 -1)
  ret i64 %16
}

define void @Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Result* }*
  %1 = getelementptr inbounds { %Result* }, { %Result* }* %0, i32 0, i32 0
  %2 = load %Result*, %Result** %1, align 8
  %3 = call i1 @Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate__body(%Result* %2)
  %4 = bitcast %Tuple* %result-tuple to { i1 }*
  %5 = getelementptr inbounds { i1 }, { i1 }* %4, i32 0, i32 0
  store i1 %3, i1* %5, align 1
  ret void
}

declare void @__quantum__rt__capture_update_reference_count(%Callable*, i32)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i32)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

define i1 @Quantum__StandaloneSupportedInputs___ebb122eaf9244a3ca8f07f274c8368b4_TautologyPredicate__body(i64 %input) {
entry:
  ret i1 true
}

define i1 @Quantum__StandaloneSupportedInputs___8723f095507647b0aef15b4b24f7fa0c_TautologyPredicate__body(double %input) {
entry:
  ret i1 true
}

define i1 @Quantum__StandaloneSupportedInputs___d127770a63ce4b8b924428e84b62936a_TautologyPredicate__body(i1 %input) {
entry:
  ret i1 true
}

define i1 @Quantum__StandaloneSupportedInputs___92bcc13ad4b7481581e7813da34f42ed_TautologyPredicate__body(i2 %input) {
entry:
  ret i1 true
}

define i1 @Quantum__StandaloneSupportedInputs___34109cb82da642eabac2d5c8cf2751a5_TautologyPredicate__body(%Result* %input) {
entry:
  ret i1 true
}

declare void @__quantum__rt__capture_update_alias_count(%Callable*, i32)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i32)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i32)

define void @Quantum__StandaloneSupportedInputs__ExerciseInputs__Interop(i64 %intValue, { i64, i8* }* %intArray, double %doubleValue, { i64, i8* }* %doubleArray, i8 %boolValue, { i64, i8* }* %boolArray, i8 %pauliValue, { i64, i8* }* %pauliArray, { i64, i64, i64 }* %rangeValue, i8 %resultValue, { i64, i8* }* %resultArray, i8* %stringValue) #0 {
entry:
  %0 = getelementptr { i64, i8* }, { i64, i8* }* %intArray, i64 0, i32 0
  %1 = getelementptr { i64, i8* }, { i64, i8* }* %intArray, i64 0, i32 1
  %2 = load i64, i64* %0, align 4
  %3 = load i8*, i8** %1, align 8
  %4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %2)
  %5 = ptrtoint i8* %3 to i64
  %6 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %7 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %8 = icmp sle i64 %7, %6
  br i1 %8, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %9 = mul i64 %7, 8
  %10 = add i64 %5, %9
  %11 = inttoptr i64 %10 to i64*
  %12 = load i64, i64* %11, align 4
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %4, i64 %7)
  %14 = bitcast i8* %13 to i64*
  store i64 %12, i64* %14, align 4
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %7, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = getelementptr { i64, i8* }, { i64, i8* }* %doubleArray, i64 0, i32 0
  %17 = getelementptr { i64, i8* }, { i64, i8* }* %doubleArray, i64 0, i32 1
  %18 = load i64, i64* %16, align 4
  %19 = load i8*, i8** %17, align 8
  %20 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %18)
  %21 = ptrtoint i8* %19 to i64
  %22 = sub i64 %18, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %23 = phi i64 [ 0, %exit__1 ], [ %31, %exiting__2 ]
  %24 = icmp sle i64 %23, %22
  br i1 %24, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %25 = mul i64 %23, 8
  %26 = add i64 %21, %25
  %27 = inttoptr i64 %26 to double*
  %28 = load double, double* %27, align 8
  %29 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %20, i64 %23)
  %30 = bitcast i8* %29 to double*
  store double %28, double* %30, align 8
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %31 = add i64 %23, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %32 = trunc i8 %boolValue to i1
  %33 = getelementptr { i64, i8* }, { i64, i8* }* %boolArray, i64 0, i32 0
  %34 = getelementptr { i64, i8* }, { i64, i8* }* %boolArray, i64 0, i32 1
  %35 = load i64, i64* %33, align 4
  %36 = load i8*, i8** %34, align 8
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %35)
  %38 = ptrtoint i8* %36 to i64
  %39 = sub i64 %35, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %40 = phi i64 [ 0, %exit__2 ], [ %49, %exiting__3 ]
  %41 = icmp sle i64 %40, %39
  br i1 %41, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %42 = mul i64 %40, 1
  %43 = add i64 %38, %42
  %44 = inttoptr i64 %43 to i8*
  %45 = load i8, i8* %44, align 1
  %46 = trunc i8 %45 to i1
  %47 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 %40)
  %48 = bitcast i8* %47 to i1*
  store i1 %46, i1* %48, align 1
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %49 = add i64 %40, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %50 = trunc i8 %pauliValue to i2
  %51 = getelementptr { i64, i8* }, { i64, i8* }* %pauliArray, i64 0, i32 0
  %52 = getelementptr { i64, i8* }, { i64, i8* }* %pauliArray, i64 0, i32 1
  %53 = load i64, i64* %51, align 4
  %54 = load i8*, i8** %52, align 8
  %55 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %53)
  %56 = ptrtoint i8* %54 to i64
  %57 = sub i64 %53, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %58 = phi i64 [ 0, %exit__3 ], [ %67, %exiting__4 ]
  %59 = icmp sle i64 %58, %57
  br i1 %59, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %60 = mul i64 %58, 1
  %61 = add i64 %56, %60
  %62 = inttoptr i64 %61 to i8*
  %63 = load i8, i8* %62, align 1
  %64 = trunc i8 %63 to i2
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %55, i64 %58)
  %66 = bitcast i8* %65 to i2*
  store i2 %64, i2* %66, align 1
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %67 = add i64 %58, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %68 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 0
  %69 = load i64, i64* %68, align 4
  %70 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 1
  %71 = load i64, i64* %70, align 4
  %72 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 2
  %73 = load i64, i64* %72, align 4
  %74 = load %Range, %Range* @EmptyRange, align 4
  %75 = insertvalue %Range %74, i64 %69, 0
  %76 = insertvalue %Range %75, i64 %71, 1
  %77 = insertvalue %Range %76, i64 %73, 2
  %78 = icmp eq i8 %resultValue, 0
  %79 = call %Result* @__quantum__rt__result_get_zero()
  %80 = call %Result* @__quantum__rt__result_get_one()
  %81 = select i1 %78, %Result* %79, %Result* %80
  %82 = getelementptr { i64, i8* }, { i64, i8* }* %resultArray, i64 0, i32 0
  %83 = getelementptr { i64, i8* }, { i64, i8* }* %resultArray, i64 0, i32 1
  %84 = load i64, i64* %82, align 4
  %85 = load i8*, i8** %83, align 8
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %84)
  %87 = ptrtoint i8* %85 to i64
  %88 = sub i64 %84, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %89 = phi i64 [ 0, %exit__4 ], [ %101, %exiting__5 ]
  %90 = icmp sle i64 %89, %88
  br i1 %90, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %91 = mul i64 %89, 1
  %92 = add i64 %87, %91
  %93 = inttoptr i64 %92 to i8*
  %94 = load i8, i8* %93, align 1
  %95 = icmp eq i8 %94, 0
  %96 = call %Result* @__quantum__rt__result_get_zero()
  %97 = call %Result* @__quantum__rt__result_get_one()
  %98 = select i1 %95, %Result* %96, %Result* %97
  %99 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 %89)
  %100 = bitcast i8* %99 to %Result**
  store %Result* %98, %Result** %100, align 8
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %101 = add i64 %89, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  %102 = call %String* @__quantum__rt__string_create(i8* %stringValue)
  call void @Quantum__StandaloneSupportedInputs__ExerciseInputs__body(i64 %intValue, %Array* %4, double %doubleValue, %Array* %20, i1 %32, %Array* %37, i2 %50, %Array* %55, %Range %77, %Result* %81, %Array* %86, %String* %102)
  call void @__quantum__rt__array_update_reference_count(%Array* %4, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %20, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %55, i32 -1)
  %103 = sub i64 %84, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %104 = phi i64 [ 0, %exit__5 ], [ %109, %exiting__6 ]
  %105 = icmp sle i64 %104, %103
  br i1 %105, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 %104)
  %107 = bitcast i8* %106 to %Result**
  %108 = load %Result*, %Result** %107, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %108, i32 -1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %109 = add i64 %104, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_reference_count(%Array* %86, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %102, i32 -1)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Result* @__quantum__rt__result_get_zero()

declare %Result* @__quantum__rt__result_get_one()

declare void @__quantum__rt__array_update_reference_count(%Array*, i32)

declare void @__quantum__rt__result_update_reference_count(%Result*, i32)

define void @Quantum__StandaloneSupportedInputs__ExerciseInputs(i64 %intValue, { i64, i8* }* %intArray, double %doubleValue, { i64, i8* }* %doubleArray, i8 %boolValue, { i64, i8* }* %boolArray, i8 %pauliValue, { i64, i8* }* %pauliArray, { i64, i64, i64 }* %rangeValue, i8 %resultValue, { i64, i8* }* %resultArray, i8* %stringValue) #1 {
entry:
  %0 = getelementptr { i64, i8* }, { i64, i8* }* %intArray, i64 0, i32 0
  %1 = getelementptr { i64, i8* }, { i64, i8* }* %intArray, i64 0, i32 1
  %2 = load i64, i64* %0, align 4
  %3 = load i8*, i8** %1, align 8
  %4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %2)
  %5 = ptrtoint i8* %3 to i64
  %6 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %7 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %8 = icmp sle i64 %7, %6
  br i1 %8, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %9 = mul i64 %7, 8
  %10 = add i64 %5, %9
  %11 = inttoptr i64 %10 to i64*
  %12 = load i64, i64* %11, align 4
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %4, i64 %7)
  %14 = bitcast i8* %13 to i64*
  store i64 %12, i64* %14, align 4
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %7, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = getelementptr { i64, i8* }, { i64, i8* }* %doubleArray, i64 0, i32 0
  %17 = getelementptr { i64, i8* }, { i64, i8* }* %doubleArray, i64 0, i32 1
  %18 = load i64, i64* %16, align 4
  %19 = load i8*, i8** %17, align 8
  %20 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %18)
  %21 = ptrtoint i8* %19 to i64
  %22 = sub i64 %18, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %23 = phi i64 [ 0, %exit__1 ], [ %31, %exiting__2 ]
  %24 = icmp sle i64 %23, %22
  br i1 %24, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %25 = mul i64 %23, 8
  %26 = add i64 %21, %25
  %27 = inttoptr i64 %26 to double*
  %28 = load double, double* %27, align 8
  %29 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %20, i64 %23)
  %30 = bitcast i8* %29 to double*
  store double %28, double* %30, align 8
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %31 = add i64 %23, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %32 = trunc i8 %boolValue to i1
  %33 = getelementptr { i64, i8* }, { i64, i8* }* %boolArray, i64 0, i32 0
  %34 = getelementptr { i64, i8* }, { i64, i8* }* %boolArray, i64 0, i32 1
  %35 = load i64, i64* %33, align 4
  %36 = load i8*, i8** %34, align 8
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %35)
  %38 = ptrtoint i8* %36 to i64
  %39 = sub i64 %35, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %40 = phi i64 [ 0, %exit__2 ], [ %49, %exiting__3 ]
  %41 = icmp sle i64 %40, %39
  br i1 %41, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %42 = mul i64 %40, 1
  %43 = add i64 %38, %42
  %44 = inttoptr i64 %43 to i8*
  %45 = load i8, i8* %44, align 1
  %46 = trunc i8 %45 to i1
  %47 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 %40)
  %48 = bitcast i8* %47 to i1*
  store i1 %46, i1* %48, align 1
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %49 = add i64 %40, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %50 = trunc i8 %pauliValue to i2
  %51 = getelementptr { i64, i8* }, { i64, i8* }* %pauliArray, i64 0, i32 0
  %52 = getelementptr { i64, i8* }, { i64, i8* }* %pauliArray, i64 0, i32 1
  %53 = load i64, i64* %51, align 4
  %54 = load i8*, i8** %52, align 8
  %55 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %53)
  %56 = ptrtoint i8* %54 to i64
  %57 = sub i64 %53, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %58 = phi i64 [ 0, %exit__3 ], [ %67, %exiting__4 ]
  %59 = icmp sle i64 %58, %57
  br i1 %59, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %60 = mul i64 %58, 1
  %61 = add i64 %56, %60
  %62 = inttoptr i64 %61 to i8*
  %63 = load i8, i8* %62, align 1
  %64 = trunc i8 %63 to i2
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %55, i64 %58)
  %66 = bitcast i8* %65 to i2*
  store i2 %64, i2* %66, align 1
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %67 = add i64 %58, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %68 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 0
  %69 = load i64, i64* %68, align 4
  %70 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 1
  %71 = load i64, i64* %70, align 4
  %72 = getelementptr { i64, i64, i64 }, { i64, i64, i64 }* %rangeValue, i64 0, i32 2
  %73 = load i64, i64* %72, align 4
  %74 = load %Range, %Range* @EmptyRange, align 4
  %75 = insertvalue %Range %74, i64 %69, 0
  %76 = insertvalue %Range %75, i64 %71, 1
  %77 = insertvalue %Range %76, i64 %73, 2
  %78 = icmp eq i8 %resultValue, 0
  %79 = call %Result* @__quantum__rt__result_get_zero()
  %80 = call %Result* @__quantum__rt__result_get_one()
  %81 = select i1 %78, %Result* %79, %Result* %80
  %82 = getelementptr { i64, i8* }, { i64, i8* }* %resultArray, i64 0, i32 0
  %83 = getelementptr { i64, i8* }, { i64, i8* }* %resultArray, i64 0, i32 1
  %84 = load i64, i64* %82, align 4
  %85 = load i8*, i8** %83, align 8
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %84)
  %87 = ptrtoint i8* %85 to i64
  %88 = sub i64 %84, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %89 = phi i64 [ 0, %exit__4 ], [ %101, %exiting__5 ]
  %90 = icmp sle i64 %89, %88
  br i1 %90, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %91 = mul i64 %89, 1
  %92 = add i64 %87, %91
  %93 = inttoptr i64 %92 to i8*
  %94 = load i8, i8* %93, align 1
  %95 = icmp eq i8 %94, 0
  %96 = call %Result* @__quantum__rt__result_get_zero()
  %97 = call %Result* @__quantum__rt__result_get_one()
  %98 = select i1 %95, %Result* %96, %Result* %97
  %99 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 %89)
  %100 = bitcast i8* %99 to %Result**
  store %Result* %98, %Result** %100, align 8
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %101 = add i64 %89, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  %102 = call %String* @__quantum__rt__string_create(i8* %stringValue)
  call void @Quantum__StandaloneSupportedInputs__ExerciseInputs__body(i64 %intValue, %Array* %4, double %doubleValue, %Array* %20, i1 %32, %Array* %37, i2 %50, %Array* %55, %Range %77, %Result* %81, %Array* %86, %String* %102)
  %103 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([3 x i8], [3 x i8]* @38, i32 0, i32 0))
  call void @__quantum__rt__message(%String* %103)
  call void @__quantum__rt__array_update_reference_count(%Array* %4, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %20, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %55, i32 -1)
  %104 = sub i64 %84, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %105 = phi i64 [ 0, %exit__5 ], [ %110, %exiting__6 ]
  %106 = icmp sle i64 %105, %104
  br i1 %106, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %107 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 %105)
  %108 = bitcast i8* %107 to %Result**
  %109 = load %Result*, %Result** %108, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %109, i32 -1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %110 = add i64 %105, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_reference_count(%Array* %86, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %102, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %103, i32 -1)
  ret void
}

attributes #0 = { "InteropFriendly" }
attributes #1 = { "EntryPoint" }
