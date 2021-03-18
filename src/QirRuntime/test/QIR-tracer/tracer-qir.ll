
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Result = type opaque
%Qubit = type opaque
%Array = type opaque
%Callable = type opaque
%String = type opaque

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__Tracer__Delay = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__Tracer__Delay__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@Microsoft__Quantum__Intrinsic__X = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i32)*] [void (%Tuple*, i32)* @MemoryManagement__1__RefCount, void (%Tuple*, i32)* @MemoryManagement__1__AliasCount]
@Microsoft__Quantum__Intrinsic__Y = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctladj__wrapper]
@PartialApplication__2 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@Microsoft__Quantum__Intrinsic__Z = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctladj__wrapper]
@PartialApplication__3 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__3__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@Microsoft__Quantum__Intrinsic__S = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctladj__wrapper]
@PartialApplication__4 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__4__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@MemoryManagement__2 = constant [2 x void (%Tuple*, i32)*] [void (%Tuple*, i32)* @MemoryManagement__2__RefCount, void (%Tuple*, i32)* @MemoryManagement__2__AliasCount]

define %Result* @Microsoft__Quantum__Instructions__Mx__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb)
  ret %Result* %0
}

declare %Result* @__quantum__qis__single_qubit_measure(i64, i64, %Qubit*)

define %Result* @Microsoft__Quantum__Instructions__Mxx__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 105, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %0
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i32)

declare %Result* @__quantum__qis__joint_measure(i64, i64, %Array*)

define %Result* @Microsoft__Quantum__Instructions__Mxz__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 103, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Instructions__Mz__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Instructions__Mzx__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 104, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Instructions__Mzz__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 102, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %0
}

define void @Microsoft__Quantum__Instructions__Sx__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 17, i64 1, %Qubit* %qb)
  ret void
}

declare void @__quantum__qis__single_qubit_op(i64, i64, %Qubit*)

define void @Microsoft__Quantum__Instructions__Sx__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 17, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Sx__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 18, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

declare void @__quantum__qis__single_qubit_op_ctl(i64, i64, %Array*, %Qubit*)

define void @Microsoft__Quantum__Instructions__Sx__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 18, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Sz__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Sz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Sz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Sz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tx__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 13, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tx__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 13, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tx__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 14, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tx__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 14, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tz__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Instructions__Tz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__ApplyConditionallyIntrinsic__body(%Array* %measurementResults, %Array* %resultsValues, %Callable* %onEqualOp, %Callable* %onNonEqualOp) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %measurementResults, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %resultsValues, i32 1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onEqualOp, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onEqualOp, i32 1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onNonEqualOp, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onNonEqualOp, i32 1)
  call void @__quantum__qis__apply_conditionally(%Array* %measurementResults, %Array* %resultsValues, %Callable* %onEqualOp, %Callable* %onNonEqualOp)
  call void @__quantum__rt__array_update_alias_count(%Array* %measurementResults, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %resultsValues, i32 -1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onEqualOp, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onEqualOp, i32 -1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onNonEqualOp, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onNonEqualOp, i32 -1)
  ret void
}

declare void @__quantum__rt__capture_update_alias_count(%Callable*, i32)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i32)

declare void @__quantum__qis__apply_conditionally(%Array*, %Array*, %Callable*, %Callable*)

define void @Microsoft__Quantum__Intrinsic__ApplyIfElseIntrinsic__body(%Result* %measurementResult, %Callable* %onResultZeroOp, %Callable* %onResultOneOp) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onResultZeroOp, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onResultZeroOp, i32 1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onResultOneOp, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onResultOneOp, i32 1)
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = bitcast i8* %1 to %Result**
  store %Result* %measurementResult, %Result** %2, align 8
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 0)
  %5 = bitcast i8* %4 to %Result**
  %6 = call %Result* @__quantum__rt__result_get_zero()
  store %Result* %6, %Result** %5, align 8
  call void @__quantum__qis__apply_conditionally(%Array* %0, %Array* %3, %Callable* %onResultZeroOp, %Callable* %onResultOneOp)
  call void @__quantum__rt__result_update_reference_count(%Result* %measurementResult, i32 1)
  call void @__quantum__rt__result_update_reference_count(%Result* %6, i32 1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onResultZeroOp, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onResultZeroOp, i32 -1)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %onResultOneOp, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %onResultOneOp, i32 -1)
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %7 = phi i64 [ 0, %entry ], [ %12, %exiting__1 ]
  %8 = icmp sle i64 %7, 0
  br i1 %8, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %7)
  %10 = bitcast i8* %9 to %Result**
  %11 = load %Result*, %Result** %10, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %11, i32 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %12 = add i64 %7, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i32 -1)
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %13 = phi i64 [ 0, %exit__1 ], [ %18, %exiting__2 ]
  %14 = icmp sle i64 %13, 0
  br i1 %14, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %13)
  %16 = bitcast i8* %15 to %Result**
  %17 = load %Result*, %Result** %16, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %17, i32 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %18 = add i64 %13, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i32 -1)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare %Result* @__quantum__rt__result_get_zero()

declare void @__quantum__rt__result_update_reference_count(%Result*, i32)

declare void @__quantum__rt__array_update_reference_count(%Array*, i32)

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %ctls, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1, align 8
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2, align 8
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 0)
  %5 = bitcast i8* %4 to %Qubit**
  store %Qubit* %control, %Qubit** %5, align 8
  %ctls__1 = call %Array* @__quantum__rt__array_concatenate(%Array* %ctls, %Array* %3)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i32 1)
  %6 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls__1)
  %7 = icmp eq i64 %6, 1
  br i1 %7, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__1, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__1, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__1, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

define void @Microsoft__Quantum__Intrinsic__CNOT__ctladj(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1, align 8
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2, align 8
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %4 = bitcast %Tuple* %3 to { %Qubit*, %Qubit* }*
  %5 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 1
  store %Qubit* %control, %Qubit** %5, align 8
  store %Qubit* %target, %Qubit** %6, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i32 -1)
  ret void
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i32)

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %paulis, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %0 = call %Result* @__quantum__rt__result_get_one()
  %res = alloca %Result*, align 8
  store %Result* %0, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i32 1)
  %haveY = alloca i1, align 1
  store i1 false, i1* %haveY, align 1
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %paulis)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %3 = icmp sle i64 %i, %2
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %5 = bitcast i8* %4 to i2*
  %6 = load i2, i2* %5, align 1
  %7 = load i2, i2* @PauliY, align 1
  %8 = icmp eq i2 %6, %7
  br i1 %8, label %condContinue__1, label %condFalse__1

condFalse__1:                                     ; preds = %body__1
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %10 = bitcast i8* %9 to i2*
  %11 = load i2, i2* %10, align 1
  %12 = load i2, i2* @PauliI, align 1
  %13 = icmp eq i2 %11, %12
  br label %condContinue__1

condContinue__1:                                  ; preds = %condFalse__1, %body__1
  %14 = phi i1 [ %8, %body__1 ], [ %13, %condFalse__1 ]
  br i1 %14, label %then0__1, label %continue__1

then0__1:                                         ; preds = %condContinue__1
  store i1 true, i1* %haveY, align 1
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %condContinue__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i1, i1* %haveY, align 1
  br i1 %16, label %then0__2, label %test1__1

then0__2:                                         ; preds = %exit__1
  %17 = call %Result* @__quantum__qis__joint_measure(i64 106, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %17, i32 1)
  store %Result* %17, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %17, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i32 -1)
  br label %continue__2

test1__1:                                         ; preds = %exit__1
  %18 = icmp sgt i64 %1, 2
  br i1 %18, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %19 = call %Result* @__quantum__qis__joint_measure(i64 107, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %19, i32 1)
  %20 = load %Result*, %Result** %res, align 8
  store %Result* %19, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %19, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %20, i32 -1)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  %21 = icmp eq i64 %1, 1
  br i1 %21, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %23 = bitcast i8* %22 to i2*
  %24 = load i2, i2* %23, align 1
  %25 = load i2, i2* @PauliX, align 1
  %26 = icmp eq i2 %24, %25
  br i1 %26, label %then0__3, label %else__1

then0__3:                                         ; preds = %then2__1
  %27 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %28 = bitcast i8* %27 to %Qubit**
  %qb = load %Qubit*, %Qubit** %28, align 8
  %29 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb)
  call void @__quantum__rt__result_update_reference_count(%Result* %29, i32 1)
  %30 = load %Result*, %Result** %res, align 8
  store %Result* %29, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %29, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %30, i32 -1)
  br label %continue__3

else__1:                                          ; preds = %then2__1
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %32 = bitcast i8* %31 to %Qubit**
  %qb__1 = load %Qubit*, %Qubit** %32, align 8
  %33 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__1)
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i32 1)
  %34 = load %Result*, %Result** %res, align 8
  store %Result* %33, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %34, i32 -1)
  br label %continue__3

continue__3:                                      ; preds = %else__1, %then0__3
  br label %continue__2

test3__1:                                         ; preds = %test2__1
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %36 = bitcast i8* %35 to i2*
  %37 = load i2, i2* %36, align 1
  %38 = load i2, i2* @PauliX, align 1
  %39 = icmp eq i2 %37, %38
  br i1 %39, label %condTrue__1, label %condContinue__2

condTrue__1:                                      ; preds = %test3__1
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %41 = bitcast i8* %40 to i2*
  %42 = load i2, i2* %41, align 1
  %43 = load i2, i2* @PauliX, align 1
  %44 = icmp eq i2 %42, %43
  br label %condContinue__2

condContinue__2:                                  ; preds = %condTrue__1, %test3__1
  %45 = phi i1 [ %44, %condTrue__1 ], [ %39, %test3__1 ]
  br i1 %45, label %then3__1, label %test4__1

then3__1:                                         ; preds = %condContinue__2
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %46 = call %Result* @__quantum__qis__joint_measure(i64 105, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %46, i32 1)
  %47 = load %Result*, %Result** %res, align 8
  store %Result* %46, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %46, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %47, i32 -1)
  br label %continue__2

test4__1:                                         ; preds = %condContinue__2
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %49 = bitcast i8* %48 to i2*
  %50 = load i2, i2* %49, align 1
  %51 = load i2, i2* @PauliX, align 1
  %52 = icmp eq i2 %50, %51
  br i1 %52, label %condTrue__2, label %condContinue__3

condTrue__2:                                      ; preds = %test4__1
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %54 = bitcast i8* %53 to i2*
  %55 = load i2, i2* %54, align 1
  %56 = load i2, i2* @PauliZ, align 1
  %57 = icmp eq i2 %55, %56
  br label %condContinue__3

condContinue__3:                                  ; preds = %condTrue__2, %test4__1
  %58 = phi i1 [ %57, %condTrue__2 ], [ %52, %test4__1 ]
  br i1 %58, label %then4__1, label %test5__1

then4__1:                                         ; preds = %condContinue__3
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %59 = call %Result* @__quantum__qis__joint_measure(i64 103, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i32 1)
  %60 = load %Result*, %Result** %res, align 8
  store %Result* %59, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %60, i32 -1)
  br label %continue__2

test5__1:                                         ; preds = %condContinue__3
  %61 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %62 = bitcast i8* %61 to i2*
  %63 = load i2, i2* %62, align 1
  %64 = load i2, i2* @PauliZ, align 1
  %65 = icmp eq i2 %63, %64
  br i1 %65, label %condTrue__3, label %condContinue__4

condTrue__3:                                      ; preds = %test5__1
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %67 = bitcast i8* %66 to i2*
  %68 = load i2, i2* %67, align 1
  %69 = load i2, i2* @PauliX, align 1
  %70 = icmp eq i2 %68, %69
  br label %condContinue__4

condContinue__4:                                  ; preds = %condTrue__3, %test5__1
  %71 = phi i1 [ %70, %condTrue__3 ], [ %65, %test5__1 ]
  br i1 %71, label %then5__1, label %test6__1

then5__1:                                         ; preds = %condContinue__4
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %72 = call %Result* @__quantum__qis__joint_measure(i64 104, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %72, i32 1)
  %73 = load %Result*, %Result** %res, align 8
  store %Result* %72, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %72, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %73, i32 -1)
  br label %continue__2

test6__1:                                         ; preds = %condContinue__4
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %75 = bitcast i8* %74 to i2*
  %76 = load i2, i2* %75, align 1
  %77 = load i2, i2* @PauliZ, align 1
  %78 = icmp eq i2 %76, %77
  br i1 %78, label %condTrue__4, label %condContinue__5

condTrue__4:                                      ; preds = %test6__1
  %79 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %80 = bitcast i8* %79 to i2*
  %81 = load i2, i2* %80, align 1
  %82 = load i2, i2* @PauliZ, align 1
  %83 = icmp eq i2 %81, %82
  br label %condContinue__5

condContinue__5:                                  ; preds = %condTrue__4, %test6__1
  %84 = phi i1 [ %83, %condTrue__4 ], [ %78, %test6__1 ]
  br i1 %84, label %then6__1, label %continue__2

then6__1:                                         ; preds = %condContinue__5
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 1)
  %85 = call %Result* @__quantum__qis__joint_measure(i64 102, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %85, i32 1)
  %86 = load %Result*, %Result** %res, align 8
  store %Result* %85, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %85, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %86, i32 -1)
  br label %continue__2

continue__2:                                      ; preds = %then6__1, %condContinue__5, %then5__1, %then4__1, %then3__1, %continue__3, %then1__1, %then0__2
  %87 = load %Result*, %Result** %res, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i32 -1)
  ret %Result* %87
}

declare %Result* @__quantum__rt__result_get_one()

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 24, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1, align 8
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qb = load %Qubit*, %Qubit** %2, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 24, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__controlQubits__)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__controlQubits__)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__controlQubits__)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %__controlQubits__, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i32 -1)
  ret void
}

define void @Microsoft__Quantum__Testing__Tracer__Delay__body(%Callable* %op, %Qubit* %arg, %Tuple* %aux) {
entry:
  call void @__quantum__rt__capture_update_alias_count(%Callable* %op, i32 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i32 1)
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Qubit* }*
  %2 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %1, i32 0, i32 0
  store %Qubit* %arg, %Qubit** %2, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %op, %Tuple* %0, %Tuple* null)
  call void @__quantum__rt__capture_update_alias_count(%Callable* %op, i32 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i32 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %0, i32 -1)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

define void @Microsoft__Quantum__Testing__Tracer__TestCoreIntrinsics__body() {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb = load %Qubit*, %Qubit** %1, align 8
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__1 = load %Qubit*, %Qubit** %3, align 8
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb__1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %qb__2 = load %Qubit*, %Qubit** %5, align 8
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb__2)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %qb__3 = load %Qubit*, %Qubit** %7, align 8
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb__3)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9, align 8
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %12 = bitcast i8* %11 to %Qubit**
  %13 = load %Qubit*, %Qubit** %12, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %10, %Qubit* %13)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %15 = bitcast i8* %14 to %Qubit**
  %qb__4 = load %Qubit*, %Qubit** %15, align 8
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb__4)
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %17 = bitcast i8* %16 to %Qubit**
  %qb__5 = load %Qubit*, %Qubit** %17, align 8
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb__5)
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %19 = bitcast i8* %18 to %Qubit**
  %qb__6 = load %Qubit*, %Qubit** %19, align 8
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb__6)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %21 = bitcast i8* %20 to %Qubit**
  %qb__7 = load %Qubit*, %Qubit** %21, align 8
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb__7)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %23 = bitcast i8* %22 to %Qubit**
  %qb__9 = load %Qubit*, %Qubit** %23, align 8
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb__9)
  call void @__quantum__qis__inject_barrier(i64 42, i64 0)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  %qb__11 = load %Qubit*, %Qubit** %25, align 8
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb__11)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %27 = bitcast i8* %26 to %Qubit**
  %qb__13 = load %Qubit*, %Qubit** %27, align 8
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb__13)
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %29 = bitcast i8* %28 to %Qubit**
  %qb__15 = load %Qubit*, %Qubit** %29, align 8
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb__15)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %31 = bitcast i8* %30 to %Qubit**
  %qb__17 = load %Qubit*, %Qubit** %31, align 8
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb__17)
  %32 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %33 = bitcast i8* %32 to %Qubit**
  %34 = load %Qubit*, %Qubit** %33, align 8
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %36 = bitcast i8* %35 to %Qubit**
  %37 = load %Qubit*, %Qubit** %36, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %34, %Qubit* %37)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %39 = bitcast i8* %38 to %Qubit**
  %qb__19 = load %Qubit*, %Qubit** %39, align 8
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb__19)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %41 = bitcast i8* %40 to %Qubit**
  %qb__20 = load %Qubit*, %Qubit** %41, align 8
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb__20)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %43 = bitcast i8* %42 to %Qubit**
  %qb__21 = load %Qubit*, %Qubit** %43, align 8
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb__21)
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %45 = bitcast i8* %44 to %Qubit**
  %qb__22 = load %Qubit*, %Qubit** %45, align 8
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb__22)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %47 = bitcast i8* %46 to %Qubit**
  %qb__24 = load %Qubit*, %Qubit** %47, align 8
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb__24)
  %c = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %49 = bitcast i8* %48 to %Qubit**
  store %Qubit* %c, %Qubit** %49, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 1)
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %51 = bitcast i8* %50 to %Qubit**
  %qb__26 = load %Qubit*, %Qubit** %51, align 8
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb__26)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb__26)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i32 -1)
  %ctls__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__1, i64 0)
  %53 = bitcast i8* %52 to %Qubit**
  store %Qubit* %c, %Qubit** %53, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i32 1)
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %55 = bitcast i8* %54 to %Qubit**
  %qb__27 = load %Qubit*, %Qubit** %55, align 8
  br i1 true, label %then0__2, label %else__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls__1, %Qubit* %qb__27)
  br label %continue__2

else__2:                                          ; preds = %continue__1
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls__1, %Qubit* %qb__27)
  br label %continue__2

continue__2:                                      ; preds = %else__2, %then0__2
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__1, i32 -1)
  %ctls__2 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__2, i64 0)
  %57 = bitcast i8* %56 to %Qubit**
  store %Qubit* %c, %Qubit** %57, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__2, i32 1)
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %59 = bitcast i8* %58 to %Qubit**
  %qb__28 = load %Qubit*, %Qubit** %59, align 8
  br i1 true, label %then0__3, label %else__3

then0__3:                                         ; preds = %continue__2
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls__2, %Qubit* %qb__28)
  br label %continue__3

else__3:                                          ; preds = %continue__2
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls__2, %Qubit* %qb__28)
  br label %continue__3

continue__3:                                      ; preds = %else__3, %then0__3
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__2, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__2, i32 -1)
  %ctls__3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__3, i64 0)
  %61 = bitcast i8* %60 to %Qubit**
  store %Qubit* %c, %Qubit** %61, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__3, i32 1)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %63 = bitcast i8* %62 to %Qubit**
  %qb__29 = load %Qubit*, %Qubit** %63, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls__3, %Qubit* %qb__29)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__3, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__3, i32 -1)
  %ctls__4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__4, i64 0)
  %65 = bitcast i8* %64 to %Qubit**
  store %Qubit* %c, %Qubit** %65, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__4, i32 1)
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %67 = bitcast i8* %66 to %Qubit**
  %qb__30 = load %Qubit*, %Qubit** %67, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls__4, %Qubit* %qb__30)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__4, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__4, i32 -1)
  %ctls__5 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %68 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__5, i64 0)
  %69 = bitcast i8* %68 to %Qubit**
  store %Qubit* %c, %Qubit** %69, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__5, i32 1)
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %71 = bitcast i8* %70 to %Qubit**
  %qb__31 = load %Qubit*, %Qubit** %71, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls__5, %Qubit* %qb__31)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__5, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__5, i32 -1)
  %ctls__6 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__6, i64 0)
  %73 = bitcast i8* %72 to %Qubit**
  store %Qubit* %c, %Qubit** %73, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__6, i32 1)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %75 = bitcast i8* %74 to %Qubit**
  %qb__32 = load %Qubit*, %Qubit** %75, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 24, i64 1, %Array* %ctls__6, %Qubit* %qb__32)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__6, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__6, i32 -1)
  %ctls__7 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__7, i64 0)
  %77 = bitcast i8* %76 to %Qubit**
  store %Qubit* %c, %Qubit** %77, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i32 1)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %79 = bitcast i8* %78 to %Qubit**
  %qb__33 = load %Qubit*, %Qubit** %79, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls__7, %Qubit* %qb__33)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__7, i32 -1)
  %ctls__9 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__9, i64 0)
  %81 = bitcast i8* %80 to %Qubit**
  store %Qubit* %c, %Qubit** %81, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i32 1)
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %83 = bitcast i8* %82 to %Qubit**
  %qb__35 = load %Qubit*, %Qubit** %83, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls__9, %Qubit* %qb__35)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__9, i32 -1)
  call void @__quantum__rt__qubit_release(%Qubit* %c)
  %cc = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %84 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %85 = bitcast i8* %84 to %Qubit**
  %qb__37 = load %Qubit*, %Qubit** %85, align 8
  %86 = call i64 @__quantum__rt__array_get_size_1d(%Array* %cc)
  %87 = icmp eq i64 %86, 1
  br i1 %87, label %then0__4, label %else__4

then0__4:                                         ; preds = %continue__3
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %cc, %Qubit* %qb__37)
  br label %continue__4

else__4:                                          ; preds = %continue__3
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %cc, %Qubit* %qb__37)
  br label %continue__4

continue__4:                                      ; preds = %else__4, %then0__4
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %89 = bitcast i8* %88 to %Qubit**
  %qb__38 = load %Qubit*, %Qubit** %89, align 8
  %90 = icmp eq i64 %86, 1
  br i1 %90, label %then0__5, label %else__5

then0__5:                                         ; preds = %continue__4
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %cc, %Qubit* %qb__38)
  br label %continue__5

else__5:                                          ; preds = %continue__4
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %cc, %Qubit* %qb__38)
  br label %continue__5

continue__5:                                      ; preds = %else__5, %then0__5
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %92 = bitcast i8* %91 to %Qubit**
  %qb__39 = load %Qubit*, %Qubit** %92, align 8
  %93 = icmp eq i64 %86, 1
  br i1 %93, label %then0__6, label %else__6

then0__6:                                         ; preds = %continue__5
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %cc, %Qubit* %qb__39)
  br label %continue__6

else__6:                                          ; preds = %continue__5
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %cc, %Qubit* %qb__39)
  br label %continue__6

continue__6:                                      ; preds = %else__6, %then0__6
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %94 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %95 = bitcast i8* %94 to %Qubit**
  %qb__40 = load %Qubit*, %Qubit** %95, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %cc, %Qubit* %qb__40)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %97 = bitcast i8* %96 to %Qubit**
  %qb__41 = load %Qubit*, %Qubit** %97, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %cc, %Qubit* %qb__41)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %99 = bitcast i8* %98 to %Qubit**
  %qb__42 = load %Qubit*, %Qubit** %99, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %cc, %Qubit* %qb__42)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %101 = bitcast i8* %100 to %Qubit**
  %qb__43 = load %Qubit*, %Qubit** %101, align 8
  call void @__quantum__qis__single_qubit_op_ctl(i64 24, i64 1, %Array* %cc, %Qubit* %qb__43)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %103 = bitcast i8* %102 to %Qubit**
  %qb__44 = load %Qubit*, %Qubit** %103, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %cc, %Qubit* %qb__44)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  %104 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %105 = bitcast i8* %104 to %Qubit**
  %qb__46 = load %Qubit*, %Qubit** %105, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %cc, %Qubit* %qb__46)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i32 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %cc)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  ret void
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__qis__inject_barrier(i64, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

define void @Microsoft__Quantum__Testing__Tracer__TestMeasurements__body() {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 6)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb = load %Qubit*, %Qubit** %1, align 8
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__2 = load %Qubit*, %Qubit** %3, align 8
  %r0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__2)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %qb__4 = load %Qubit*, %Qubit** %5, align 8
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb__4)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %8 = load %Qubit*, %Qubit** %7, align 8
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %10 = bitcast i8* %9 to %Qubit**
  %11 = load %Qubit*, %Qubit** %10, align 8
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %8, %Qubit* %11)
  %qs12 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %13 = bitcast i8* %12 to %Qubit**
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 1)
  %15 = bitcast i8* %14 to %Qubit**
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %17 = bitcast i8* %16 to %Qubit**
  %18 = load %Qubit*, %Qubit** %17, align 8
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %20 = bitcast i8* %19 to %Qubit**
  %21 = load %Qubit*, %Qubit** %20, align 8
  store %Qubit* %18, %Qubit** %13, align 8
  store %Qubit* %21, %Qubit** %15, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %paulis = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %23 = bitcast i8* %22 to i2*
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %25 = bitcast i8* %24 to i2*
  %26 = load i2, i2* @PauliY, align 1
  %27 = load i2, i2* @PauliX, align 1
  store i2 %26, i2* %23, align 1
  store i2 %27, i2* %25, align 1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %28 = call %Result* @__quantum__rt__result_get_one()
  %res = alloca %Result*, align 8
  store %Result* %28, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i32 1)
  %haveY = alloca i1, align 1
  store i1 false, i1* %haveY, align 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %41, %exiting__1 ]
  %29 = icmp sle i64 %i, 1
  br i1 %29, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %31 = bitcast i8* %30 to i2*
  %32 = load i2, i2* %31, align 1
  %33 = load i2, i2* @PauliY, align 1
  %34 = icmp eq i2 %32, %33
  br i1 %34, label %condContinue__1, label %condFalse__1

condFalse__1:                                     ; preds = %body__1
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %36 = bitcast i8* %35 to i2*
  %37 = load i2, i2* %36, align 1
  %38 = load i2, i2* @PauliI, align 1
  %39 = icmp eq i2 %37, %38
  br label %condContinue__1

condContinue__1:                                  ; preds = %condFalse__1, %body__1
  %40 = phi i1 [ %34, %body__1 ], [ %39, %condFalse__1 ]
  br i1 %40, label %then0__1, label %continue__1

then0__1:                                         ; preds = %condContinue__1
  store i1 true, i1* %haveY, align 1
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %condContinue__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %41 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %42 = load i1, i1* %haveY, align 1
  br i1 %42, label %then0__2, label %test1__1

then0__2:                                         ; preds = %exit__1
  %43 = call %Result* @__quantum__qis__joint_measure(i64 106, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %43, i32 1)
  store %Result* %43, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %43, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i32 -1)
  br label %continue__2

test1__1:                                         ; preds = %exit__1
  br i1 false, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %44 = call %Result* @__quantum__qis__joint_measure(i64 107, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %44, i32 1)
  %45 = load %Result*, %Result** %res, align 8
  store %Result* %44, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %44, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %45, i32 -1)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  br i1 false, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %47 = bitcast i8* %46 to i2*
  %48 = load i2, i2* %47, align 1
  %49 = load i2, i2* @PauliX, align 1
  %50 = icmp eq i2 %48, %49
  br i1 %50, label %then0__3, label %else__1

then0__3:                                         ; preds = %then2__1
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %52 = bitcast i8* %51 to %Qubit**
  %qb__6 = load %Qubit*, %Qubit** %52, align 8
  %53 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb__6)
  call void @__quantum__rt__result_update_reference_count(%Result* %53, i32 1)
  %54 = load %Result*, %Result** %res, align 8
  store %Result* %53, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %53, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %54, i32 -1)
  br label %continue__3

else__1:                                          ; preds = %then2__1
  %55 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %56 = bitcast i8* %55 to %Qubit**
  %qb__7 = load %Qubit*, %Qubit** %56, align 8
  %57 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__7)
  call void @__quantum__rt__result_update_reference_count(%Result* %57, i32 1)
  %58 = load %Result*, %Result** %res, align 8
  store %Result* %57, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %57, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %58, i32 -1)
  br label %continue__3

continue__3:                                      ; preds = %else__1, %then0__3
  br label %continue__2

test3__1:                                         ; preds = %test2__1
  %59 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %60 = bitcast i8* %59 to i2*
  %61 = load i2, i2* %60, align 1
  %62 = load i2, i2* @PauliX, align 1
  %63 = icmp eq i2 %61, %62
  br i1 %63, label %condTrue__1, label %condContinue__2

condTrue__1:                                      ; preds = %test3__1
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %65 = bitcast i8* %64 to i2*
  %66 = load i2, i2* %65, align 1
  %67 = load i2, i2* @PauliX, align 1
  %68 = icmp eq i2 %66, %67
  br label %condContinue__2

condContinue__2:                                  ; preds = %condTrue__1, %test3__1
  %69 = phi i1 [ %68, %condTrue__1 ], [ %63, %test3__1 ]
  br i1 %69, label %then3__1, label %test4__1

then3__1:                                         ; preds = %condContinue__2
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %70 = call %Result* @__quantum__qis__joint_measure(i64 105, i64 1, %Array* %qs12)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %70, i32 1)
  %71 = load %Result*, %Result** %res, align 8
  store %Result* %70, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %70, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %71, i32 -1)
  br label %continue__2

test4__1:                                         ; preds = %condContinue__2
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %73 = bitcast i8* %72 to i2*
  %74 = load i2, i2* %73, align 1
  %75 = load i2, i2* @PauliX, align 1
  %76 = icmp eq i2 %74, %75
  br i1 %76, label %condTrue__2, label %condContinue__3

condTrue__2:                                      ; preds = %test4__1
  %77 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %78 = bitcast i8* %77 to i2*
  %79 = load i2, i2* %78, align 1
  %80 = load i2, i2* @PauliZ, align 1
  %81 = icmp eq i2 %79, %80
  br label %condContinue__3

condContinue__3:                                  ; preds = %condTrue__2, %test4__1
  %82 = phi i1 [ %81, %condTrue__2 ], [ %76, %test4__1 ]
  br i1 %82, label %then4__1, label %test5__1

then4__1:                                         ; preds = %condContinue__3
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %83 = call %Result* @__quantum__qis__joint_measure(i64 103, i64 1, %Array* %qs12)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %83, i32 1)
  %84 = load %Result*, %Result** %res, align 8
  store %Result* %83, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %83, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %84, i32 -1)
  br label %continue__2

test5__1:                                         ; preds = %condContinue__3
  %85 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %86 = bitcast i8* %85 to i2*
  %87 = load i2, i2* %86, align 1
  %88 = load i2, i2* @PauliZ, align 1
  %89 = icmp eq i2 %87, %88
  br i1 %89, label %condTrue__3, label %condContinue__4

condTrue__3:                                      ; preds = %test5__1
  %90 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %91 = bitcast i8* %90 to i2*
  %92 = load i2, i2* %91, align 1
  %93 = load i2, i2* @PauliX, align 1
  %94 = icmp eq i2 %92, %93
  br label %condContinue__4

condContinue__4:                                  ; preds = %condTrue__3, %test5__1
  %95 = phi i1 [ %94, %condTrue__3 ], [ %89, %test5__1 ]
  br i1 %95, label %then5__1, label %test6__1

then5__1:                                         ; preds = %condContinue__4
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %96 = call %Result* @__quantum__qis__joint_measure(i64 104, i64 1, %Array* %qs12)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %96, i32 1)
  %97 = load %Result*, %Result** %res, align 8
  store %Result* %96, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %96, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %97, i32 -1)
  br label %continue__2

test6__1:                                         ; preds = %condContinue__4
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %99 = bitcast i8* %98 to i2*
  %100 = load i2, i2* %99, align 1
  %101 = load i2, i2* @PauliZ, align 1
  %102 = icmp eq i2 %100, %101
  br i1 %102, label %condTrue__4, label %condContinue__5

condTrue__4:                                      ; preds = %test6__1
  %103 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %104 = bitcast i8* %103 to i2*
  %105 = load i2, i2* %104, align 1
  %106 = load i2, i2* @PauliZ, align 1
  %107 = icmp eq i2 %105, %106
  br label %condContinue__5

condContinue__5:                                  ; preds = %condTrue__4, %test6__1
  %108 = phi i1 [ %107, %condTrue__4 ], [ %102, %test6__1 ]
  br i1 %108, label %then6__1, label %continue__2

then6__1:                                         ; preds = %condContinue__5
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 1)
  %109 = call %Result* @__quantum__qis__joint_measure(i64 102, i64 1, %Array* %qs12)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %109, i32 1)
  %110 = load %Result*, %Result** %res, align 8
  store %Result* %109, %Result** %res, align 8
  call void @__quantum__rt__result_update_reference_count(%Result* %109, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %110, i32 -1)
  br label %continue__2

continue__2:                                      ; preds = %then6__1, %condContinue__5, %then5__1, %then4__1, %then3__1, %continue__3, %then1__1, %then0__2
  %r12 = load %Result*, %Result** %res, align 8
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis, i32 -1)
  %111 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %112 = bitcast %Tuple* %111 to { %Callable*, %Callable*, %Qubit* }*
  %113 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %112, i32 0, i32 0
  %114 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %112, i32 0, i32 1
  %115 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %112, i32 0, i32 2
  %116 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__Tracer__Delay, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %117 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__X, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %118 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 3)
  %119 = bitcast i8* %118 to %Qubit**
  %120 = load %Qubit*, %Qubit** %119, align 8
  store %Callable* %116, %Callable** %113, align 8
  store %Callable* %117, %Callable** %114, align 8
  store %Qubit* %120, %Qubit** %115, align 8
  %121 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i32)*]* @MemoryManagement__1, %Tuple* %111)
  %122 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %123 = bitcast %Tuple* %122 to { %Callable*, %Callable*, %Qubit* }*
  %124 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %123, i32 0, i32 0
  %125 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %123, i32 0, i32 1
  %126 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %123, i32 0, i32 2
  %127 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__Tracer__Delay, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %128 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Y, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %129 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 3)
  %130 = bitcast i8* %129 to %Qubit**
  %131 = load %Qubit*, %Qubit** %130, align 8
  store %Callable* %127, %Callable** %124, align 8
  store %Callable* %128, %Callable** %125, align 8
  store %Qubit* %131, %Qubit** %126, align 8
  %132 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__2, [2 x void (%Tuple*, i32)*]* @MemoryManagement__1, %Tuple* %122)
  call void @Microsoft__Quantum__Intrinsic__ApplyIfElseIntrinsic__body(%Result* %r0, %Callable* %121, %Callable* %132)
  %133 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %134 = bitcast %Tuple* %133 to { %Callable*, %Callable*, %Qubit* }*
  %135 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %134, i32 0, i32 0
  %136 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %134, i32 0, i32 1
  %137 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %134, i32 0, i32 2
  %138 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__Tracer__Delay, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %139 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Z, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %140 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 4)
  %141 = bitcast i8* %140 to %Qubit**
  %142 = load %Qubit*, %Qubit** %141, align 8
  store %Callable* %138, %Callable** %135, align 8
  store %Callable* %139, %Callable** %136, align 8
  store %Qubit* %142, %Qubit** %137, align 8
  %143 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__3, [2 x void (%Tuple*, i32)*]* @MemoryManagement__1, %Tuple* %133)
  %144 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %145 = bitcast %Tuple* %144 to { %Callable*, %Callable*, %Qubit* }*
  %146 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %145, i32 0, i32 0
  %147 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %145, i32 0, i32 1
  %148 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %145, i32 0, i32 2
  %149 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__Tracer__Delay, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %150 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__S, [2 x void (%Tuple*, i32)*]* null, %Tuple* null)
  %151 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 4)
  %152 = bitcast i8* %151 to %Qubit**
  %153 = load %Qubit*, %Qubit** %152, align 8
  store %Callable* %149, %Callable** %146, align 8
  store %Callable* %150, %Callable** %147, align 8
  store %Qubit* %153, %Qubit** %148, align 8
  %154 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__4, [2 x void (%Tuple*, i32)*]* @MemoryManagement__2, %Tuple* %144)
  call void @Microsoft__Quantum__Intrinsic__ApplyIfElseIntrinsic__body(%Result* %r12, %Callable* %143, %Callable* %154)
  %155 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 5)
  %156 = bitcast i8* %155 to %Qubit**
  %qb__8 = load %Qubit*, %Qubit** %156, align 8
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb__8)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i32 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %r0, i32 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs12, i32 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %r12, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %121, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %121, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %132, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %132, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %143, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %143, i32 -1)
  call void @__quantum__rt__capture_update_reference_count(%Callable* %154, i32 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %154, i32 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  ret void
}

define void @Microsoft__Quantum__Testing__Tracer__Delay__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Callable*, %Qubit*, %Tuple* }*
  %1 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %0, i32 0, i32 1
  %3 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %0, i32 0, i32 2
  %4 = load %Callable*, %Callable** %1, align 8
  %5 = load %Qubit*, %Qubit** %2, align 8
  %6 = load %Tuple*, %Tuple** %3, align 8
  call void @Microsoft__Quantum__Testing__Tracer__Delay__body(%Callable* %4, %Qubit* %5, %Tuple* %6)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i32)*]*, %Tuple*)

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

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %2 = load %Callable*, %Callable** %1, align 8
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 2
  %4 = load %Qubit*, %Qubit** %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Tuple* }*
  %6 = getelementptr inbounds { %Tuple* }, { %Tuple* }* %5, i32 0, i32 0
  %7 = load %Tuple*, %Tuple** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %9 = bitcast %Tuple* %8 to { %Callable*, %Qubit*, %Tuple* }*
  %10 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 2
  store %Callable* %2, %Callable** %10, align 8
  store %Qubit* %4, %Qubit** %11, align 8
  store %Tuple* %7, %Tuple** %12, align 8
  %13 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i32 %count-change)
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %4 = load %Callable*, %Callable** %3, align 8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_alias_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i32 %count-change)
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %4 = load %Callable*, %Callable** %3, align 8
  call void @__quantum__rt__capture_update_alias_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

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

define void @Lifted__PartialApplication__2__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %2 = load %Callable*, %Callable** %1, align 8
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 2
  %4 = load %Qubit*, %Qubit** %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Tuple* }*
  %6 = getelementptr inbounds { %Tuple* }, { %Tuple* }* %5, i32 0, i32 0
  %7 = load %Tuple*, %Tuple** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %9 = bitcast %Tuple* %8 to { %Callable*, %Qubit*, %Tuple* }*
  %10 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 2
  store %Callable* %2, %Callable** %10, align 8
  store %Qubit* %4, %Qubit** %11, align 8
  store %Tuple* %7, %Tuple** %12, align 8
  %13 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
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

define void @Lifted__PartialApplication__3__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %2 = load %Callable*, %Callable** %1, align 8
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 2
  %4 = load %Qubit*, %Qubit** %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Tuple* }*
  %6 = getelementptr inbounds { %Tuple* }, { %Tuple* }* %5, i32 0, i32 0
  %7 = load %Tuple*, %Tuple** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %9 = bitcast %Tuple* %8 to { %Callable*, %Qubit*, %Tuple* }*
  %10 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 2
  store %Callable* %2, %Callable** %10, align 8
  store %Qubit* %4, %Qubit** %11, align 8
  store %Tuple* %7, %Tuple** %12, align 8
  %13 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
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

define void @Lifted__PartialApplication__4__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %2 = load %Callable*, %Callable** %1, align 8
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 2
  %4 = load %Qubit*, %Qubit** %3, align 8
  %5 = bitcast %Tuple* %arg-tuple to { %Tuple* }*
  %6 = getelementptr inbounds { %Tuple* }, { %Tuple* }* %5, i32 0, i32 0
  %7 = load %Tuple*, %Tuple** %6, align 8
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %9 = bitcast %Tuple* %8 to { %Callable*, %Qubit*, %Tuple* }*
  %10 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 1
  %12 = getelementptr inbounds { %Callable*, %Qubit*, %Tuple* }, { %Callable*, %Qubit*, %Tuple* }* %9, i32 0, i32 2
  store %Callable* %2, %Callable** %10, align 8
  store %Qubit* %4, %Qubit** %11, align 8
  store %Tuple* %7, %Tuple** %12, align 8
  %13 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %14 = load %Callable*, %Callable** %13, align 8
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i32 -1)
  ret void
}

define void @MemoryManagement__2__RefCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i32 %count-change)
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %4 = load %Callable*, %Callable** %3, align 8
  call void @__quantum__rt__capture_update_reference_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

define void @MemoryManagement__2__AliasCount(%Tuple* %capture-tuple, i32 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable*, %Qubit* }*
  %1 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1, align 8
  call void @__quantum__rt__capture_update_alias_count(%Callable* %2, i32 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i32 %count-change)
  %3 = getelementptr inbounds { %Callable*, %Callable*, %Qubit* }, { %Callable*, %Callable*, %Qubit* }* %0, i32 0, i32 1
  %4 = load %Callable*, %Callable** %3, align 8
  call void @__quantum__rt__capture_update_alias_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %4, i32 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i32 %count-change)
  ret void
}

declare void @__quantum__rt__capture_update_reference_count(%Callable*, i32)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i32)

define %Tuple* @Microsoft__Quantum__Core__Attribute__body() {
entry:
  ret %Tuple* null
}

define %Tuple* @Microsoft__Quantum__Core__EntryPoint__body() {
entry:
  ret %Tuple* null
}

define %Tuple* @Microsoft__Quantum__Core__Inline__body() {
entry:
  ret %Tuple* null
}

define { %String* }* @Microsoft__Quantum__Targeting__TargetInstruction__body(%String* %__Item1__) {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %String* }*
  %2 = getelementptr inbounds { %String* }, { %String* }* %1, i32 0, i32 0
  store %String* %__Item1__, %String** %2, align 8
  call void @__quantum__rt__string_update_reference_count(%String* %__Item1__, i32 1)
  ret { %String* }* %1
}

declare void @__quantum__rt__string_update_reference_count(%String*, i32)

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i32)
