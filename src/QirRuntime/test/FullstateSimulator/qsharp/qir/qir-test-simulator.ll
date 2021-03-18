
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Callable = type opaque
%Qubit = type opaque
%Array = type opaque
%Result = type opaque

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Intrinsic__X = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__Y = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__Z = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__H = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__S = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__T = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__R = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctladj__wrapper]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i32)*] [void (%Tuple*, i32)* @MemoryManagement__1__RefCount, void (%Tuple*, i32)* @MemoryManagement__1__AliasCount]

@Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS = alias i64 (), i64 ()* @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body

define i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %op) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %op, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i32 1)
  %res = alloca i64, align 8
  store i64 0, i64* %res, align 4
  %target = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Qubit* }*
  %2 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %1, i32 0, i32 0
  store %Qubit* %target, %Qubit** %2, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %op, %Tuple* %0, %Tuple* null)
  %3 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %3)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Qubit* }*
  %6 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %5, i32 0, i32 0
  store %Qubit* %target, %Qubit** %6, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %3, %Tuple* %4, %Tuple* null)
  %7 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %8 = call %Result* @__quantum__rt__result_get_zero()
  %9 = call i1 @__quantum__rt__result_equal(%Result* %7, %Result* %8)
  %10 = xor i1 %9, true
  br i1 %10, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  store i64 1, i64* %res, align 4
  br label %continue__1

else__1:                                          ; preds = %entry
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %12 = bitcast i8* %11 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %12, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %14 = bitcast i8* %13 to %Qubit**
  %qubit__1 = load %Qubit*, %Qubit** %14, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__1)
  %15 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %15)
  %16 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %17 = bitcast %Tuple* %16 to { %Array*, %Qubit* }*
  %18 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %17, i32 0, i32 0
  %19 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %17, i32 0, i32 1
  store %Array* %ctls, %Array** %18, align 8
  store %Qubit* %target, %Qubit** %19, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %15, %Tuple* %16, %Tuple* null)
  %20 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %20, i32 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %20)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %20)
  %21 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %22 = bitcast %Tuple* %21 to { %Array*, %Qubit* }*
  %23 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i32 0, i32 0
  %24 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i32 0, i32 1
  store %Array* %ctls, %Array** %23, align 8
  store %Qubit* %target, %Qubit** %24, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %20, %Tuple* %21, %Tuple* null)
  %25 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %26 = call %Result* @__quantum__rt__result_get_zero()
  %27 = call i1 @__quantum__rt__result_equal(%Result* %25, %Result* %26)
  %28 = xor i1 %27, true
  br i1 %28, label %then0__2, label %continue__2

then0__2:                                         ; preds = %else__1
  store i64 2, i64* %res, align 4
  br label %continue__2

continue__2:                                      ; preds = %then0__2, %else__1
  %29 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %30 = bitcast i8* %29 to %Qubit**
  %qubit__2 = load %Qubit*, %Qubit** %30, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__2)
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %32 = bitcast i8* %31 to %Qubit**
  %qubit__3 = load %Qubit*, %Qubit** %32, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__3)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %16, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %20, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %20, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %25, i32 -1)
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %7, i32 -1)
  call void @__quantum__rt__qubit_release(%Qubit* %target)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  %33 = load i64, i64* %res, align 4
  call void @__quantum__rt__capture_update_alias_count(%Callable* %op, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i32 -1)
  ret i64 %33
}

declare void @__quantum__rt__capture_update_alias_count(%Callable*, i32)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i32)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__array_update_alias_count(%Array*, i32)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__capture_update_reference_count(%Callable*, i32)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qubit) {
entry:
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliZ, align 1
  store i2 %2, i2* %1, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %qubit, %Qubit** %4, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i32 -1)
  ret %Result* %5
}

declare %Result* @__quantum__rt__result_get_zero()

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__qis__h__body(%Qubit*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i32)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i32)

declare void @__quantum__rt__result_update_reference_count(%Result*, i32)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

define i64 @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body() #0 {
entry:
  %res = alloca i64, align 8
  store i64 0, i64* %res, align 4
  %0 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__X, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %1 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %0)
  store i64 %1, i64* %res, align 4
  %2 = icmp ne i64 %1, 0
  br i1 %2, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  ret i64 %1

continue__1:                                      ; preds = %entry
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Y, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %3)
  store i64 %4, i64* %res, align 4
  %5 = icmp ne i64 %4, 0
  br i1 %5, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  %6 = add i64 10, %4
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  ret i64 %6

continue__2:                                      ; preds = %continue__1
  %7 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Z, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %8 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %7)
  store i64 %8, i64* %res, align 4
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  %10 = add i64 20, %8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  ret i64 %10

continue__3:                                      ; preds = %continue__2
  %11 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__H, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %12 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %11)
  store i64 %12, i64* %res, align 4
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  %14 = add i64 30, %12
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  ret i64 %14

continue__4:                                      ; preds = %continue__3
  %15 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__S, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %16 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %15)
  store i64 %16, i64* %res, align 4
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  %18 = add i64 40, %16
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  ret i64 %18

continue__5:                                      ; preds = %continue__4
  %19 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__T, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %20 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %19)
  store i64 %20, i64* %res, align 4
  %21 = icmp ne i64 %20, 0
  br i1 %21, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  %22 = add i64 50, %20
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i32 -1)
  ret i64 %22

continue__6:                                      ; preds = %continue__5
  %23 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i2, double }* getelementptr ({ %Callable*, i2, double }, { %Callable*, i2, double }* null, i32 1) to i64))
  %24 = bitcast %Tuple* %23 to { %Callable*, i2, double }*
  %25 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i32 0, i32 0
  %26 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i32 0, i32 1
  %27 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i32 0, i32 2
  %28 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__R, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %29 = load i2, i2* @PauliX, align 1
  store %Callable* %28, %Callable** %25, align 8
  store i2 %29, i2* %26, align 1
  store double 4.200000e-01, double* %27, align 8
  %30 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i32)*]* @MemoryManagement__1, %Tuple* %23)
  %31 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %30)
  store i64 %31, i64* %res, align 4
  %32 = icmp ne i64 %31, 0
  br i1 %32, label %then0__7, label %continue__7

then0__7:                                         ; preds = %continue__6
  %33 = add i64 60, %31
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %30, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i32 -1)
  ret i64 %33

continue__7:                                      ; preds = %continue__6
  %targets = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 1)
  %ctls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %paulis = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %34 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %35 = bitcast i8* %34 to i2*
  %36 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %37 = bitcast i8* %36 to i2*
  %38 = load i2, i2* @PauliX, align 1
  %39 = load i2, i2* @PauliY, align 1
  store i2 %38, i2* %35, align 1
  store i2 %39, i2* %37, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 1)
  call void @__quantum__qis__exp__body(%Array* %paulis, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis, i32 -1)
  %paulis__1 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__1, i64 0)
  %41 = bitcast i8* %40 to i2*
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__1, i64 1)
  %43 = bitcast i8* %42 to i2*
  %44 = load i2, i2* @PauliX, align 1
  %45 = load i2, i2* @PauliY, align 1
  store i2 %44, i2* %41, align 1
  store i2 %45, i2* %43, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__1, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 1)
  call void @__quantum__qis__exp__adj(%Array* %paulis__1, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__1, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__1, i32 -1)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 0)
  %47 = bitcast i8* %46 to %Qubit**
  %48 = load %Qubit*, %Qubit** %47, align 8
  %49 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %48)
  %50 = call %Result* @__quantum__rt__result_get_zero()
  %51 = call i1 @__quantum__rt__result_equal(%Result* %49, %Result* %50)
  %52 = xor i1 %51, true
  br i1 %52, label %then0__8, label %continue__8

then0__8:                                         ; preds = %continue__7
  store i64 1, i64* %res, align 4
  br label %continue__8

continue__8:                                      ; preds = %then0__8, %continue__7
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %54 = bitcast i8* %53 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %54, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  %55 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %56 = bitcast i8* %55 to %Qubit**
  %qubit__1 = load %Qubit*, %Qubit** %56, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %paulis__2 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %57 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__2, i64 0)
  %58 = bitcast i8* %57 to i2*
  %59 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__2, i64 1)
  %60 = bitcast i8* %59 to i2*
  %61 = load i2, i2* @PauliX, align 1
  %62 = load i2, i2* @PauliY, align 1
  store i2 %61, i2* %58, align 1
  store i2 %62, i2* %60, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__2, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 1)
  %63 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %64 = bitcast %Tuple* %63 to { %Array*, double, %Array* }*
  %65 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %64, i32 0, i32 0
  %66 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %64, i32 0, i32 1
  %67 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %64, i32 0, i32 2
  store %Array* %paulis__2, %Array** %65, align 8
  store double 4.200000e-01, double* %66, align 8
  store %Array* %targets, %Array** %67, align 8
  call void @__quantum__qis__exp__ctl(%Array* %ctls, { %Array*, double, %Array* }* %64)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__2, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__2, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %63, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %paulis__3 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %68 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__3, i64 0)
  %69 = bitcast i8* %68 to i2*
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__3, i64 1)
  %71 = bitcast i8* %70 to i2*
  %72 = load i2, i2* @PauliX, align 1
  %73 = load i2, i2* @PauliY, align 1
  store i2 %72, i2* %69, align 1
  store i2 %73, i2* %71, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__3, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 1)
  %74 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %75 = bitcast %Tuple* %74 to { %Array*, double, %Array* }*
  %76 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %75, i32 0, i32 0
  %77 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %75, i32 0, i32 1
  %78 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %75, i32 0, i32 2
  store %Array* %paulis__3, %Array** %76, align 8
  store double 4.200000e-01, double* %77, align 8
  store %Array* %targets, %Array** %78, align 8
  call void @__quantum__qis__exp__ctladj(%Array* %ctls, { %Array*, double, %Array* }* %75)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__3, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__3, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %74, i32 -1)
  %79 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %80 = bitcast i8* %79 to %Qubit**
  %qubit__2 = load %Qubit*, %Qubit** %80, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__2)
  %81 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %82 = bitcast i8* %81 to %Qubit**
  %qubit__3 = load %Qubit*, %Qubit** %82, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__3)
  %83 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 0)
  %84 = bitcast i8* %83 to %Qubit**
  %85 = load %Qubit*, %Qubit** %84, align 8
  %86 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %85)
  %87 = call %Result* @__quantum__rt__result_get_zero()
  %88 = call i1 @__quantum__rt__result_equal(%Result* %86, %Result* %87)
  %89 = xor i1 %88, true
  br i1 %89, label %then0__9, label %continue__9

then0__9:                                         ; preds = %continue__8
  store i64 2, i64* %res, align 4
  br label %continue__9

continue__9:                                      ; preds = %then0__9, %continue__8
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %49, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %86, i32 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %targets)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  %90 = load i64, i64* %res, align 4
  %91 = icmp ne i64 %90, 0
  br i1 %91, label %then0__10, label %continue__10

then0__10:                                        ; preds = %continue__9
  %92 = add i64 70, %90
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %30, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i32 -1)
  ret i64 %92

continue__10:                                     ; preds = %continue__9
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 1)
  %93 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %94 = bitcast i8* %93 to %Qubit**
  %qubit__4 = load %Qubit*, %Qubit** %94, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__4)
  %95 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %96 = bitcast i8* %95 to %Qubit**
  %qubit__5 = load %Qubit*, %Qubit** %96, align 8
  call void @__quantum__qis__h__body(%Qubit* %qubit__5)
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 3)
  %97 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %98 = bitcast i8* %97 to i2*
  %99 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 1)
  %100 = bitcast i8* %99 to i2*
  %101 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 2)
  %102 = bitcast i8* %101 to i2*
  %103 = load i2, i2* @PauliX, align 1
  %104 = load i2, i2* @PauliZ, align 1
  %105 = load i2, i2* @PauliX, align 1
  store i2 %103, i2* %98, align 1
  store i2 %104, i2* %100, align 1
  store i2 %105, i2* %102, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 1)
  %106 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i32 -1)
  %107 = call %Result* @__quantum__rt__result_get_zero()
  %108 = call i1 @__quantum__rt__result_equal(%Result* %106, %Result* %107)
  %109 = xor i1 %108, true
  br i1 %109, label %then0__11, label %continue__11

then0__11:                                        ; preds = %continue__10
  store i64 80, i64* %res, align 4
  br label %continue__11

continue__11:                                     ; preds = %then0__11, %continue__10
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %106, i32 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  %110 = load i64, i64* %res, align 4
  call void @__quantum__rt__capture_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %30, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i32 -1)
  ret i64 %110
}

define void @Microsoft__Quantum__Intrinsic__X__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i32)*]*, %Tuple*)

define void @Microsoft__Quantum__Intrinsic__Y__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1, align 8
  call void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i2, double, %Qubit* }*
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %4 = load i2, i2* %1, align 1
  %5 = load double, double* %2, align 8
  %6 = load %Qubit*, %Qubit** %3, align 8
  call void @Microsoft__Quantum__Intrinsic__R__body(i2 %4, double %5, %Qubit* %6)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i2, double, %Qubit* }*
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %4 = load i2, i2* %1, align 1
  %5 = load double, double* %2, align 8
  %6 = load %Qubit*, %Qubit** %3, align 8
  call void @Microsoft__Quantum__Intrinsic__R__adj(i2 %4, double %5, %Qubit* %6)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i2, double, %Qubit* }* }*
  %1 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { i2, double, %Qubit* }*, { i2, double, %Qubit* }** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %3, { i2, double, %Qubit* }* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i2, double, %Qubit* }* }*
  %1 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load { i2, double, %Qubit* }*, { i2, double, %Qubit* }** %2, align 8
  call void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %3, { i2, double, %Qubit* }* %4)
  ret void
}

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 1
  %2 = load i2, i2* %1, align 1
  %3 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 2
  %4 = load double, double* %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %6 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %5, i32 0, i32 0
  %7 = load %Qubit*, %Qubit** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { i2, double, %Qubit* }*
  %10 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 2
  store i2 %2, i2* %10, align 1
  store double %4, double* %11, align 8
  store %Qubit* %7, %Qubit** %12, align 8
  %13 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
  ret void
}

define void @Lifted__PartialApplication__1__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 1
  %2 = load i2, i2* %1, align 1
  %3 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 2
  %4 = load double, double* %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %6 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %5, i32 0, i32 0
  %7 = load %Qubit*, %Qubit** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { i2, double, %Qubit* }*
  %10 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i32 0, i32 2
  store i2 %2, i2* %10, align 1
  store double %4, double* %11, align 8
  store %Qubit* %7, %Qubit** %12, align 8
  %13 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  %15 = call %Callable* @__quantum__rt__callable_copy(%Callable* %14, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %15)
  call void @__quantum__rt__callable_invoke(%Callable* %15, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %15, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i32 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %6 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 1
  %7 = load i2, i2* %6, align 1
  %8 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 2
  %9 = load double, double* %8, align 8
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %11 = bitcast %Tuple* %10 to { i2, double, %Qubit* }*
  %12 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 0
  %13 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 1
  %14 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 2
  store i2 %7, i2* %12, align 1
  store double %9, double* %13, align 8
  store %Qubit* %4, %Qubit** %14, align 8
  %15 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %16 = bitcast %Tuple* %15 to { %Array*, { i2, double, %Qubit* }* }*
  %17 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i32 0, i32 0
  %18 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i32 0, i32 1
  store %Array* %3, %Array** %17, align 8
  store { i2, double, %Qubit* }* %11, { i2, double, %Qubit* }** %18, align 8
  %19 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 0
  %20 = load %Callable*, %Callable** %19, align 8
  %21 = call %Callable* @__quantum__rt__callable_copy(%Callable* %20, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %21, i32 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %21)
  call void @__quantum__rt__callable_invoke(%Callable* %21, %Tuple* %15, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %10, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %21, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %21, i32 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1, align 8
  %4 = load %Qubit*, %Qubit** %2, align 8
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %6 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 1
  %7 = load i2, i2* %6, align 1
  %8 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 2
  %9 = load double, double* %8, align 8
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %11 = bitcast %Tuple* %10 to { i2, double, %Qubit* }*
  %12 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 0
  %13 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 1
  %14 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i32 0, i32 2
  store i2 %7, i2* %12, align 1
  store double %9, double* %13, align 8
  store %Qubit* %4, %Qubit** %14, align 8
  %15 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %16 = bitcast %Tuple* %15 to { %Array*, { i2, double, %Qubit* }* }*
  %17 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i32 0, i32 0
  %18 = getelementptr inbounds { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i32 0, i32 1
  store %Array* %3, %Array** %17, align 8
  store { i2, double, %Qubit* }* %11, { i2, double, %Qubit* }** %18, align 8
  %19 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i32 0, i32 0
  %20 = load %Callable*, %Callable** %19, align 8
  %21 = call %Callable* @__quantum__rt__callable_copy(%Callable* %20, i1 false)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %21, i32 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %21)
  call void @__quantum__rt__callable_make_controlled(%Callable* %21)
  call void @__quantum__rt__callable_invoke(%Callable* %21, %Tuple* %15, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %10, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %21, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %21, i32 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr inbounds { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_alias_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare void @__quantum__qis__exp__body(%Array*, double, %Array*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i32)

declare void @__quantum__qis__exp__adj(%Array*, double, %Array*)

declare void @__quantum__qis__exp__ctl(%Array*, { %Array*, double, %Array* }*)

declare void @__quantum__qis__exp__ctladj(%Array*, { %Array*, double, %Array* }*)

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__s__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__adj(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__s__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__s__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__s__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Exp__body(%Array* %paulis, double %theta, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  call void @__quantum__qis__exp__body(%Array* %paulis, double %theta, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Exp__adj(%Array* %paulis, double %theta, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  call void @__quantum__qis__exp__adj(%Array* %paulis, double %theta, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Exp__ctl(%Array* %__controlQubits__, { %Array*, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %1 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 0
  %paulis = load %Array*, %Array** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  %2 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 2
  %qubits = load %Array*, %Array** %3, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Array*, double, %Array* }*
  %6 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 2
  store %Array* %paulis, %Array** %6, align 8
  store double %theta, double* %7, align 8
  store %Array* %qubits, %Array** %8, align 8
  call void @__quantum__qis__exp__ctl(%Array* %__controlQubits__, { %Array*, double, %Array* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Exp__ctladj(%Array* %__controlQubits__, { %Array*, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %1 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 0
  %paulis = load %Array*, %Array** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  %2 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i32 0, i32 2
  %qubits = load %Array*, %Array** %3, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Array*, double, %Array* }*
  %6 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i32 0, i32 2
  store %Array* %paulis, %Array** %6, align 8
  store double %theta, double* %7, align 8
  store %Array* %qubits, %Array** %8, align 8
  call void @__quantum__qis__exp__ctladj(%Array* %__controlQubits__, { %Array*, double, %Array* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__t__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__t__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__t__adj(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__t__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__t__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__t__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__t__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__t__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__h__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__x__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__body(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__body(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__adj(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__adj(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__adj(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1, align 1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3, align 8
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6, align 1
  store double %theta, double* %7, align 8
  store %Qubit* %qubit, %Qubit** %8, align 8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i32 -1)
  ret void
}

declare void @__quantum__qis__r__ctl(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1, align 1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2, align 8
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3, align 8
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6, align 1
  store double %theta, double* %7, align 8
  store %Qubit* %qubit, %Qubit** %8, align 8
  call void @__quantum__qis__r__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i32 -1)
  ret void
}

declare void @__quantum__qis__r__ctladj(%Array*, { i2, double, %Qubit* }*)

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__z__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__z__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__y__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__qis__y__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i32)

attributes #0 = { "EntryPoint" }
