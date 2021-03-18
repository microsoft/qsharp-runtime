
%Range = type { i64, i64, i64 }
%Result = type opaque
%String = type opaque

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@0 = internal constant [26 x i8] c"Exercise Supported Inputs\00"
@1 = internal constant [11 x i8] c"intValue: \00"
@2 = internal constant [14 x i8] c"doubleValue: \00"
@3 = internal constant [14 x i8] c"resultValue: \00"
@4 = internal constant [14 x i8] c"stringValue: \00"

define i64 @Quantum__StandaloneSupportedInputs__ExerciseInputs__body(i64 %intValue, double %doubleValue, %Result* %resultValue, %String* %stringValue) {
entry:
  %msg = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([26 x i8], [26 x i8]* @0, i32 0, i32 0))
  call void @__quantum__qis__message__body(%String* %msg)
  call void @__quantum__rt__string_update_reference_count(%String* %msg, i32 -1)
  %0 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([11 x i8], [11 x i8]* @1, i32 0, i32 0))
  %1 = call %String* @__quantum__rt__int_to_string(i64 %intValue)
  %msg__1 = call %String* @__quantum__rt__string_concatenate(%String* %0, %String* %1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %1, i32 -1)
  call void @__quantum__qis__message__body(%String* %msg__1)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__1, i32 -1)
  %2 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @2, i32 0, i32 0))
  %3 = call %String* @__quantum__rt__double_to_string(double %doubleValue)
  %msg__2 = call %String* @__quantum__rt__string_concatenate(%String* %2, %String* %3)
  call void @__quantum__rt__string_update_reference_count(%String* %2, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %3, i32 -1)
  call void @__quantum__qis__message__body(%String* %msg__2)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__2, i32 -1)
  %4 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @3, i32 0, i32 0))
  %5 = call %String* @__quantum__rt__result_to_string(%Result* %resultValue)
  %msg__3 = call %String* @__quantum__rt__string_concatenate(%String* %4, %String* %5)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %5, i32 -1)
  call void @__quantum__qis__message__body(%String* %msg__3)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__3, i32 -1)
  %6 = call %String* @__quantum__rt__string_create(i8* getelementptr inbounds ([14 x i8], [14 x i8]* @4, i32 0, i32 0))
  call void @__quantum__rt__string_update_reference_count(%String* %stringValue, i32 1)
  %msg__4 = call %String* @__quantum__rt__string_concatenate(%String* %6, %String* %stringValue)
  call void @__quantum__rt__string_update_reference_count(%String* %6, i32 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %stringValue, i32 -1)
  call void @__quantum__qis__message__body(%String* %msg__4)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__4, i32 -1)
  ret i64 0
}

declare %String* @__quantum__rt__string_create(i8*)

declare void @__quantum__qis__message__body(%String*)

declare void @__quantum__rt__string_update_reference_count(%String*, i32)

declare %String* @__quantum__rt__int_to_string(i64)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

declare %String* @__quantum__rt__double_to_string(double)

declare %String* @__quantum__rt__result_to_string(%Result*)

define void @Microsoft__Quantum__Intrinsic__Message__body(%String* %msg) {
entry:
  call void @__quantum__qis__message__body(%String* %msg)
  ret void
}

define i64 @Quantum__StandaloneSupportedInputs__ExerciseInputs(i64 %intValue, double %doubleValue, i8 %resultValue, i8* %stringValue) #0 {
entry:
  %0 = icmp eq i8 %resultValue, 0
  %1 = call %Result* @__quantum__rt__result_get_zero()
  %2 = call %Result* @__quantum__rt__result_get_one()
  %3 = select i1 %0, %Result* %1, %Result* %2
  %4 = call %String* @__quantum__rt__string_create(i8* %stringValue)
  %5 = call i64 @Quantum__StandaloneSupportedInputs__ExerciseInputs__body(i64 %intValue, double %doubleValue, %Result* %3, %String* %4)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i32 -1)
  ret i64 %5
}

declare %Result* @__quantum__rt__result_get_zero()

declare %Result* @__quantum__rt__result_get_one()

attributes #0 = { "EntryPoint" }
