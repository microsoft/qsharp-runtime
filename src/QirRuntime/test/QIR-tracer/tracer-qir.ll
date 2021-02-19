
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Qubit = type opaque
%Array = type opaque
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

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

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare void @__quantum__qis__single_qubit_op_ctl(i64, i64, %Array*, %Qubit*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

declare void @__quantum__qis__single_qubit_op(i64, i64, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

declare %Result* @__quantum__qis__single_qubit_measure(i64, i64, %Qubit*)

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %paulis, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = load %Result*, %Result** @ResultOne
  %res = alloca %Result*
  store %Result* %0, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i64 1)
  %haveY = alloca i1
  store i1 false, i1* %haveY
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
  %6 = load i2, i2* %5
  %7 = load i2, i2* @PauliY
  %8 = icmp eq i2 %6, %7
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %10 = bitcast i8* %9 to i2*
  %11 = load i2, i2* %10
  %12 = load i2, i2* @PauliI
  %13 = icmp eq i2 %11, %12
  %14 = or i1 %8, %13
  br i1 %14, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  store i1 true, i1* %haveY
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %15 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i1, i1* %haveY
  br i1 %16, label %then0__2, label %test1__1

then0__2:                                         ; preds = %exit__1
  %17 = call %Result* @__quantum__qis__joint_measure(i64 106, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %17, i64 1)
  store %Result* %17, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %17, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %0, i64 -1)
  br label %continue__2

test1__1:                                         ; preds = %exit__1
  %18 = icmp sgt i64 %1, 2
  br i1 %18, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %19 = call %Result* @__quantum__qis__joint_measure(i64 107, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %19, i64 1)
  %20 = load %Result*, %Result** %res
  store %Result* %19, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %19, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %20, i64 -1)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  %21 = icmp eq i64 %1, 1
  br i1 %21, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %23 = bitcast i8* %22 to i2*
  %24 = load i2, i2* %23
  %25 = load i2, i2* @PauliX
  %26 = icmp eq i2 %24, %25
  br i1 %26, label %then0__3, label %else__1

then0__3:                                         ; preds = %then2__1
  %27 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %28 = bitcast i8* %27 to %Qubit**
  %qb = load %Qubit*, %Qubit** %28
  %29 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb)
  call void @__quantum__rt__result_update_reference_count(%Result* %29, i64 1)
  %30 = load %Result*, %Result** %res
  store %Result* %29, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %29, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %30, i64 -1)
  br label %continue__3

else__1:                                          ; preds = %then2__1
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %32 = bitcast i8* %31 to %Qubit**
  %qb__1 = load %Qubit*, %Qubit** %32
  %33 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__1)
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i64 1)
  %34 = load %Result*, %Result** %res
  store %Result* %33, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %34, i64 -1)
  br label %continue__3

continue__3:                                      ; preds = %else__1, %then0__3
  br label %continue__2

test3__1:                                         ; preds = %test2__1
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %36 = bitcast i8* %35 to i2*
  %37 = load i2, i2* %36
  %38 = load i2, i2* @PauliX
  %39 = icmp eq i2 %37, %38
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %41 = bitcast i8* %40 to i2*
  %42 = load i2, i2* %41
  %43 = load i2, i2* @PauliX
  %44 = icmp eq i2 %42, %43
  %45 = and i1 %39, %44
  br i1 %45, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %46 = call %Result* @__quantum__qis__joint_measure(i64 108, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %46, i64 1)
  %47 = load %Result*, %Result** %res
  store %Result* %46, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %46, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %47, i64 -1)
  br label %continue__2

test4__1:                                         ; preds = %test3__1
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %49 = bitcast i8* %48 to i2*
  %50 = load i2, i2* %49
  %51 = load i2, i2* @PauliX
  %52 = icmp eq i2 %50, %51
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %54 = bitcast i8* %53 to i2*
  %55 = load i2, i2* %54
  %56 = load i2, i2* @PauliZ
  %57 = icmp eq i2 %55, %56
  %58 = and i1 %52, %57
  br i1 %58, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %59 = call %Result* @__quantum__qis__joint_measure(i64 109, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 1)
  %60 = load %Result*, %Result** %res
  store %Result* %59, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %60, i64 -1)
  br label %continue__2

test5__1:                                         ; preds = %test4__1
  %61 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %62 = bitcast i8* %61 to i2*
  %63 = load i2, i2* %62
  %64 = load i2, i2* @PauliZ
  %65 = icmp eq i2 %63, %64
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %67 = bitcast i8* %66 to i2*
  %68 = load i2, i2* %67
  %69 = load i2, i2* @PauliX
  %70 = icmp eq i2 %68, %69
  %71 = and i1 %65, %70
  br i1 %71, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %72 = call %Result* @__quantum__qis__joint_measure(i64 110, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %72, i64 1)
  %73 = load %Result*, %Result** %res
  store %Result* %72, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %72, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %73, i64 -1)
  br label %continue__2

test6__1:                                         ; preds = %test5__1
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %75 = bitcast i8* %74 to i2*
  %76 = load i2, i2* %75
  %77 = load i2, i2* @PauliZ
  %78 = icmp eq i2 %76, %77
  %79 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %80 = bitcast i8* %79 to i2*
  %81 = load i2, i2* %80
  %82 = load i2, i2* @PauliZ
  %83 = icmp eq i2 %81, %82
  %84 = and i1 %78, %83
  br i1 %84, label %then6__1, label %continue__2

then6__1:                                         ; preds = %test6__1
  %85 = call %Result* @__quantum__qis__joint_measure(i64 111, i64 1, %Array* %qubits)
  call void @__quantum__rt__result_update_reference_count(%Result* %85, i64 1)
  %86 = load %Result*, %Result** %res
  store %Result* %85, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %85, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %86, i64 -1)
  br label %continue__2

continue__2:                                      ; preds = %then6__1, %test6__1, %then5__1, %then4__1, %then3__1, %continue__3, %then1__1, %then0__2
  %87 = load %Result*, %Result** %res
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %87
}

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare %Result* @__quantum__qis__joint_measure(i64, i64, %Array*)

define %Result* @Microsoft__Quantum__Intrinsic__Mx__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mxx__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 105, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mxz__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 103, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mz__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mzx__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 104, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mzz__body(%Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__joint_measure(i64 102, i64 1, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 24, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sx__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 17, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sx__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 17, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sx__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 18, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sx__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 18, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tx__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 13, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tx__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 13, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tx__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 14, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tx__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 14, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Testing__Tracer__Fixup__body(%Array* %qs) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %qs)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %5, %exiting__1 ]
  %2 = icmp sle i64 %i, %1
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 %i)
  %4 = bitcast i8* %3 to %Qubit**
  %qb = load %Qubit*, %Qubit** %4
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %5 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Testing__Tracer__TestCoreIntrinsics__body() {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb = load %Qubit*, %Qubit** %1
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__1 = load %Qubit*, %Qubit** %3
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb__1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %qb__2 = load %Qubit*, %Qubit** %5
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb__2)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %qb__3 = load %Qubit*, %Qubit** %7
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb__3)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %12 = bitcast i8* %11 to %Qubit**
  %13 = load %Qubit*, %Qubit** %12
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %10, %Qubit* %13)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %15 = bitcast i8* %14 to %Qubit**
  %qb__4 = load %Qubit*, %Qubit** %15
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb__4)
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %17 = bitcast i8* %16 to %Qubit**
  %qb__5 = load %Qubit*, %Qubit** %17
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb__5)
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %19 = bitcast i8* %18 to %Qubit**
  %qb__6 = load %Qubit*, %Qubit** %19
  call void @__quantum__qis__single_qubit_op(i64 23, i64 1, %Qubit* %qb__6)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %21 = bitcast i8* %20 to %Qubit**
  %qb__7 = load %Qubit*, %Qubit** %21
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb__7)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %23 = bitcast i8* %22 to %Qubit**
  %qb__9 = load %Qubit*, %Qubit** %23
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb__9)
  call void @__quantum__qis__inject_barrier(i64 42, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  %qb__11 = load %Qubit*, %Qubit** %25
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb__11)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %27 = bitcast i8* %26 to %Qubit**
  %qb__12 = load %Qubit*, %Qubit** %27
  call void @__quantum__qis__single_qubit_op(i64 3, i64 1, %Qubit* %qb__12)
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %29 = bitcast i8* %28 to %Qubit**
  %qb__13 = load %Qubit*, %Qubit** %29
  call void @__quantum__qis__single_qubit_op(i64 6, i64 1, %Qubit* %qb__13)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %31 = bitcast i8* %30 to %Qubit**
  %qb__14 = load %Qubit*, %Qubit** %31
  call void @__quantum__qis__single_qubit_op(i64 9, i64 1, %Qubit* %qb__14)
  %32 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %33 = bitcast i8* %32 to %Qubit**
  %34 = load %Qubit*, %Qubit** %33
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %36 = bitcast i8* %35 to %Qubit**
  %37 = load %Qubit*, %Qubit** %36
  call void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %34, %Qubit* %37)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %39 = bitcast i8* %38 to %Qubit**
  %qb__15 = load %Qubit*, %Qubit** %39
  call void @__quantum__qis__single_qubit_op(i64 19, i64 1, %Qubit* %qb__15)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %41 = bitcast i8* %40 to %Qubit**
  %qb__16 = load %Qubit*, %Qubit** %41
  call void @__quantum__qis__single_qubit_op(i64 21, i64 1, %Qubit* %qb__16)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %43 = bitcast i8* %42 to %Qubit**
  %qb__17 = load %Qubit*, %Qubit** %43
  call void @__quantum__qis__single_qubit_op(i64 24, i64 1, %Qubit* %qb__17)
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %45 = bitcast i8* %44 to %Qubit**
  %qb__18 = load %Qubit*, %Qubit** %45
  call void @__quantum__qis__single_qubit_op(i64 15, i64 1, %Qubit* %qb__18)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %47 = bitcast i8* %46 to %Qubit**
  %qb__20 = load %Qubit*, %Qubit** %47
  call void @__quantum__qis__single_qubit_op(i64 11, i64 1, %Qubit* %qb__20)
  %c = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %49 = bitcast i8* %48 to %Qubit**
  store %Qubit* %c, %Qubit** %49
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %51 = bitcast i8* %50 to %Qubit**
  %qb__22 = load %Qubit*, %Qubit** %51
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb__22)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb__22)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  %ctls__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__1, i64 0)
  %53 = bitcast i8* %52 to %Qubit**
  store %Qubit* %c, %Qubit** %53
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i64 1)
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %55 = bitcast i8* %54 to %Qubit**
  %qb__23 = load %Qubit*, %Qubit** %55
  br i1 true, label %then0__2, label %else__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls__1, %Qubit* %qb__23)
  br label %continue__2

else__2:                                          ; preds = %continue__1
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls__1, %Qubit* %qb__23)
  br label %continue__2

continue__2:                                      ; preds = %else__2, %then0__2
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__1, i64 -1)
  %ctls__2 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__2, i64 0)
  %57 = bitcast i8* %56 to %Qubit**
  store %Qubit* %c, %Qubit** %57
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__2, i64 1)
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %59 = bitcast i8* %58 to %Qubit**
  %qb__24 = load %Qubit*, %Qubit** %59
  br i1 true, label %then0__3, label %else__3

then0__3:                                         ; preds = %continue__2
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls__2, %Qubit* %qb__24)
  br label %continue__3

else__3:                                          ; preds = %continue__2
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls__2, %Qubit* %qb__24)
  br label %continue__3

continue__3:                                      ; preds = %else__3, %then0__3
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__2, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__2, i64 -1)
  %ctls__3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__3, i64 0)
  %61 = bitcast i8* %60 to %Qubit**
  store %Qubit* %c, %Qubit** %61
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__3, i64 1)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %63 = bitcast i8* %62 to %Qubit**
  %qb__25 = load %Qubit*, %Qubit** %63
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls__3, %Qubit* %qb__25)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__3, i64 -1)
  %ctls__4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__4, i64 0)
  %65 = bitcast i8* %64 to %Qubit**
  store %Qubit* %c, %Qubit** %65
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__4, i64 1)
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %67 = bitcast i8* %66 to %Qubit**
  %qb__26 = load %Qubit*, %Qubit** %67
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls__4, %Qubit* %qb__26)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__4, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__4, i64 -1)
  %ctls__5 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %68 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__5, i64 0)
  %69 = bitcast i8* %68 to %Qubit**
  store %Qubit* %c, %Qubit** %69
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__5, i64 1)
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %71 = bitcast i8* %70 to %Qubit**
  %qb__27 = load %Qubit*, %Qubit** %71
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls__5, %Qubit* %qb__27)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__5, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__5, i64 -1)
  %ctls__6 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__6, i64 0)
  %73 = bitcast i8* %72 to %Qubit**
  store %Qubit* %c, %Qubit** %73
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__6, i64 1)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %75 = bitcast i8* %74 to %Qubit**
  %qb__28 = load %Qubit*, %Qubit** %75
  call void @__quantum__qis__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls__6, %Qubit* %qb__28)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__6, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__6, i64 -1)
  %ctls__7 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__7, i64 0)
  %77 = bitcast i8* %76 to %Qubit**
  store %Qubit* %c, %Qubit** %77
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i64 1)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %79 = bitcast i8* %78 to %Qubit**
  %qb__29 = load %Qubit*, %Qubit** %79
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls__7, %Qubit* %qb__29)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__7, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__7, i64 -1)
  %ctls__9 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__9, i64 0)
  %81 = bitcast i8* %80 to %Qubit**
  store %Qubit* %c, %Qubit** %81
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i64 1)
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %83 = bitcast i8* %82 to %Qubit**
  %qb__31 = load %Qubit*, %Qubit** %83
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls__9, %Qubit* %qb__31)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls__9, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls__9, i64 -1)
  call void @__quantum__rt__qubit_release(%Qubit* %c)
  %cc = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %84 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %85 = bitcast i8* %84 to %Qubit**
  %qb__33 = load %Qubit*, %Qubit** %85
  %86 = call i64 @__quantum__rt__array_get_size_1d(%Array* %cc)
  %87 = icmp eq i64 %86, 1
  br i1 %87, label %then0__4, label %else__4

then0__4:                                         ; preds = %continue__3
  call void @__quantum__qis__single_qubit_op_ctl(i64 1, i64 1, %Array* %cc, %Qubit* %qb__33)
  br label %continue__4

else__4:                                          ; preds = %continue__3
  call void @__quantum__qis__single_qubit_op_ctl(i64 2, i64 1, %Array* %cc, %Qubit* %qb__33)
  br label %continue__4

continue__4:                                      ; preds = %else__4, %then0__4
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %89 = bitcast i8* %88 to %Qubit**
  %qb__34 = load %Qubit*, %Qubit** %89
  %90 = icmp eq i64 %86, 1
  br i1 %90, label %then0__5, label %else__5

then0__5:                                         ; preds = %continue__4
  call void @__quantum__qis__single_qubit_op_ctl(i64 4, i64 1, %Array* %cc, %Qubit* %qb__34)
  br label %continue__5

else__5:                                          ; preds = %continue__4
  call void @__quantum__qis__single_qubit_op_ctl(i64 5, i64 1, %Array* %cc, %Qubit* %qb__34)
  br label %continue__5

continue__5:                                      ; preds = %else__5, %then0__5
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %92 = bitcast i8* %91 to %Qubit**
  %qb__35 = load %Qubit*, %Qubit** %92
  %93 = icmp eq i64 %86, 1
  br i1 %93, label %then0__6, label %else__6

then0__6:                                         ; preds = %continue__5
  call void @__quantum__qis__single_qubit_op_ctl(i64 7, i64 1, %Array* %cc, %Qubit* %qb__35)
  br label %continue__6

else__6:                                          ; preds = %continue__5
  call void @__quantum__qis__single_qubit_op_ctl(i64 8, i64 1, %Array* %cc, %Qubit* %qb__35)
  br label %continue__6

continue__6:                                      ; preds = %else__6, %then0__6
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %94 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %95 = bitcast i8* %94 to %Qubit**
  %qb__36 = load %Qubit*, %Qubit** %95
  call void @__quantum__qis__single_qubit_op_ctl(i64 10, i64 1, %Array* %cc, %Qubit* %qb__36)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %97 = bitcast i8* %96 to %Qubit**
  %qb__37 = load %Qubit*, %Qubit** %97
  call void @__quantum__qis__single_qubit_op_ctl(i64 20, i64 1, %Array* %cc, %Qubit* %qb__37)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %99 = bitcast i8* %98 to %Qubit**
  %qb__38 = load %Qubit*, %Qubit** %99
  call void @__quantum__qis__single_qubit_op_ctl(i64 22, i64 1, %Array* %cc, %Qubit* %qb__38)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %101 = bitcast i8* %100 to %Qubit**
  %qb__39 = load %Qubit*, %Qubit** %101
  call void @__quantum__qis__single_qubit_op_ctl(i64 25, i64 1, %Array* %cc, %Qubit* %qb__39)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %103 = bitcast i8* %102 to %Qubit**
  %qb__40 = load %Qubit*, %Qubit** %103
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 16, i64 1, %Array* %cc, %Qubit* %qb__40)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  %104 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %105 = bitcast i8* %104 to %Qubit**
  %qb__42 = load %Qubit*, %Qubit** %105
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 1)
  call void @__quantum__qis__single_qubit_op_ctl(i64 12, i64 1, %Array* %cc, %Qubit* %qb__42)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %cc)
  call void @__quantum__rt__array_update_alias_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %cc, i64 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  ret void
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__qis__inject_barrier(i64, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

define void @Microsoft__Quantum__Testing__Tracer__TestMeasurements__body(i1 %compare) {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb = load %Qubit*, %Qubit** %1
  %r0 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  %qs12 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %8 = load %Qubit*, %Qubit** %7
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %10 = bitcast i8* %9 to %Qubit**
  %11 = load %Qubit*, %Qubit** %10
  store %Qubit* %8, %Qubit** %3
  store %Qubit* %11, %Qubit** %5
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i64 1)
  %paulis = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %13 = bitcast i8* %12 to i2*
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %15 = bitcast i8* %14 to i2*
  %16 = load i2, i2* @PauliY
  %17 = load i2, i2* @PauliX
  store i2 %16, i2* %13
  store i2 %17, i2* %15
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i64 1)
  %18 = load %Result*, %Result** @ResultOne
  %res = alloca %Result*
  store %Result* %18, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %18, i64 1)
  %haveY = alloca i1
  store i1 false, i1* %haveY
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %31, %exiting__1 ]
  %19 = icmp sle i64 %i, 1
  br i1 %19, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %21 = bitcast i8* %20 to i2*
  %22 = load i2, i2* %21
  %23 = load i2, i2* @PauliY
  %24 = icmp eq i2 %22, %23
  %25 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %26 = bitcast i8* %25 to i2*
  %27 = load i2, i2* %26
  %28 = load i2, i2* @PauliI
  %29 = icmp eq i2 %27, %28
  %30 = or i1 %24, %29
  br i1 %30, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  store i1 true, i1* %haveY
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %31 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %32 = load i1, i1* %haveY
  br i1 %32, label %then0__2, label %test1__1

then0__2:                                         ; preds = %exit__1
  %33 = call %Result* @__quantum__qis__joint_measure(i64 106, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i64 1)
  store %Result* %33, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %18, i64 -1)
  br label %continue__2

test1__1:                                         ; preds = %exit__1
  br i1 false, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %34 = call %Result* @__quantum__qis__joint_measure(i64 107, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %34, i64 1)
  %35 = load %Result*, %Result** %res
  store %Result* %34, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %34, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %35, i64 -1)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  br i1 false, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %36 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %37 = bitcast i8* %36 to i2*
  %38 = load i2, i2* %37
  %39 = load i2, i2* @PauliX
  %40 = icmp eq i2 %38, %39
  br i1 %40, label %then0__3, label %else__1

then0__3:                                         ; preds = %then2__1
  %41 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %42 = bitcast i8* %41 to %Qubit**
  %qb__2 = load %Qubit*, %Qubit** %42
  %43 = call %Result* @__quantum__qis__single_qubit_measure(i64 101, i64 1, %Qubit* %qb__2)
  call void @__quantum__rt__result_update_reference_count(%Result* %43, i64 1)
  %44 = load %Result*, %Result** %res
  store %Result* %43, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %43, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %44, i64 -1)
  br label %continue__3

else__1:                                          ; preds = %then2__1
  %45 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %46 = bitcast i8* %45 to %Qubit**
  %qb__3 = load %Qubit*, %Qubit** %46
  %47 = call %Result* @__quantum__qis__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__3)
  call void @__quantum__rt__result_update_reference_count(%Result* %47, i64 1)
  %48 = load %Result*, %Result** %res
  store %Result* %47, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %47, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %48, i64 -1)
  br label %continue__3

continue__3:                                      ; preds = %else__1, %then0__3
  br label %continue__2

test3__1:                                         ; preds = %test2__1
  %49 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %50 = bitcast i8* %49 to i2*
  %51 = load i2, i2* %50
  %52 = load i2, i2* @PauliX
  %53 = icmp eq i2 %51, %52
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %55 = bitcast i8* %54 to i2*
  %56 = load i2, i2* %55
  %57 = load i2, i2* @PauliX
  %58 = icmp eq i2 %56, %57
  %59 = and i1 %53, %58
  br i1 %59, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %60 = call %Result* @__quantum__qis__joint_measure(i64 108, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %60, i64 1)
  %61 = load %Result*, %Result** %res
  store %Result* %60, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %60, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %61, i64 -1)
  br label %continue__2

test4__1:                                         ; preds = %test3__1
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %63 = bitcast i8* %62 to i2*
  %64 = load i2, i2* %63
  %65 = load i2, i2* @PauliX
  %66 = icmp eq i2 %64, %65
  %67 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %68 = bitcast i8* %67 to i2*
  %69 = load i2, i2* %68
  %70 = load i2, i2* @PauliZ
  %71 = icmp eq i2 %69, %70
  %72 = and i1 %66, %71
  br i1 %72, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %73 = call %Result* @__quantum__qis__joint_measure(i64 109, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %73, i64 1)
  %74 = load %Result*, %Result** %res
  store %Result* %73, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %73, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %74, i64 -1)
  br label %continue__2

test5__1:                                         ; preds = %test4__1
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %76 = bitcast i8* %75 to i2*
  %77 = load i2, i2* %76
  %78 = load i2, i2* @PauliZ
  %79 = icmp eq i2 %77, %78
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %81 = bitcast i8* %80 to i2*
  %82 = load i2, i2* %81
  %83 = load i2, i2* @PauliX
  %84 = icmp eq i2 %82, %83
  %85 = and i1 %79, %84
  br i1 %85, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %86 = call %Result* @__quantum__qis__joint_measure(i64 110, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %86, i64 1)
  %87 = load %Result*, %Result** %res
  store %Result* %86, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %86, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %87, i64 -1)
  br label %continue__2

test6__1:                                         ; preds = %test5__1
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %89 = bitcast i8* %88 to i2*
  %90 = load i2, i2* %89
  %91 = load i2, i2* @PauliZ
  %92 = icmp eq i2 %90, %91
  %93 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %94 = bitcast i8* %93 to i2*
  %95 = load i2, i2* %94
  %96 = load i2, i2* @PauliZ
  %97 = icmp eq i2 %95, %96
  %98 = and i1 %92, %97
  br i1 %98, label %then6__1, label %continue__2

then6__1:                                         ; preds = %test6__1
  %99 = call %Result* @__quantum__qis__joint_measure(i64 111, i64 1, %Array* %qs12)
  call void @__quantum__rt__result_update_reference_count(%Result* %99, i64 1)
  %100 = load %Result*, %Result** %res
  store %Result* %99, %Result** %res
  call void @__quantum__rt__result_update_reference_count(%Result* %99, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %100, i64 -1)
  br label %continue__2

continue__2:                                      ; preds = %then6__1, %test6__1, %then5__1, %then4__1, %then3__1, %continue__3, %then1__1, %then0__2
  %r12 = load %Result*, %Result** %res
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis, i64 -1)
  br i1 %compare, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__2
  %101 = load %Result*, %Result** @ResultZero
  %102 = call i1 @__quantum__rt__result_equal(%Result* %r0, %Result* %101)
  br i1 %102, label %then0__5, label %continue__5

then0__5:                                         ; preds = %then0__4
  %103 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %104 = bitcast i8* %103 to %Qubit**
  %qb__4 = load %Qubit*, %Qubit** %104
  call void @__quantum__qis__single_qubit_op(i64 0, i64 1, %Qubit* %qb__4)
  br label %continue__5

continue__5:                                      ; preds = %then0__5, %then0__4
  br label %continue__4

continue__4:                                      ; preds = %continue__5, %continue__2
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs12, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %r0, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs12, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %r12, i64 -1)
  ret void
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

define { %String* }* @Microsoft__Quantum__Targeting__TargetInstruction__body(%String* %__Item1__) {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %String* }*
  %2 = getelementptr { %String* }, { %String* }* %1, i64 0, i32 0
  store %String* %__Item1__, %String** %2
  call void @__quantum__rt__string_update_reference_count(%String* %__Item1__, i64 1)
  ret { %String* }* %1
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__string_update_reference_count(%String*, i64)
