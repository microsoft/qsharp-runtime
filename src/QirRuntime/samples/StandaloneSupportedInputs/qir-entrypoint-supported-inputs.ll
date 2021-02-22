
%Result = type opaque
%Range = type { i64, i64, i64 }
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@0 = internal constant [26 x i8] c"Exercise Supported Inputs\00"
@1 = internal constant [8 x i8] c"anInt: \00"
@2 = internal constant [11 x i8] c"anDouble: \00"

@Quantum__StandaloneSupportedInputs__ExerciseSupportedInputs = alias void (i64, double), void (i64, double)* @Quantum__StandaloneSupportedInputs__ExerciseSupportedInputs__body

define void @Quantum__StandaloneSupportedInputs__ExerciseSupportedInputs__body(i64 %anInt, double %aDouble) #0 {
entry:
  %msg = call %String* @__quantum__rt__string_create(i32 25, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @0, i32 0, i32 0))
  call void @__quantum__qis__message__body(%String* %msg)
  call void @__quantum__rt__string_update_reference_count(%String* %msg, i64 -1)
  %0 = call %String* @__quantum__rt__string_create(i32 7, i8* getelementptr inbounds ([8 x i8], [8 x i8]* @1, i32 0, i32 0))
  %1 = call %String* @__quantum__rt__int_to_string(i64 %anInt)
  %msg__1 = call %String* @__quantum__rt__string_concatenate(%String* %0, %String* %1)
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %1, i64 -1)
  call void @__quantum__qis__message__body(%String* %msg__1)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__1, i64 -1)
  %2 = call %String* @__quantum__rt__string_create(i32 10, i8* getelementptr inbounds ([11 x i8], [11 x i8]* @2, i32 0, i32 0))
  %3 = call %String* @__quantum__rt__double_to_string(double %aDouble)
  %msg__2 = call %String* @__quantum__rt__string_concatenate(%String* %2, %String* %3)
  call void @__quantum__rt__string_update_reference_count(%String* %2, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %3, i64 -1)
  call void @__quantum__qis__message__body(%String* %msg__2)
  call void @__quantum__rt__string_update_reference_count(%String* %msg__2, i64 -1)
  ret void
}

declare %String* @__quantum__rt__string_create(i32, i8*)

declare void @__quantum__qis__message__body(%String*)

declare void @__quantum__rt__string_update_reference_count(%String*, i64)

declare %String* @__quantum__rt__int_to_string(i64)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

declare %String* @__quantum__rt__double_to_string(double)

define void @Microsoft__Quantum__Intrinsic__Message__body(%String* %msg) {
entry:
  call void @__quantum__qis__message__body(%String* %msg)
  ret void
}

attributes #0 = { "EntryPoint" }
