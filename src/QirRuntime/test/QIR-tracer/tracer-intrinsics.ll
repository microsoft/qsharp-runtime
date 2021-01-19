
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Testing__Tracer__AllIntrinsics = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body

define void @Microsoft__Quantum__Intrinsic__Tz__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

declare void @__quantum__trc__single_qubit_op(i64, i64, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Tz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

declare void @__quantum__rt__array_add_access(%Array*)

declare void @__quantum__trc__single_qubit_op_ctl(i64, i64, %Array*, %Qubit*)

declare void @__quantum__rt__array_remove_access(%Array*)

define void @Microsoft__Quantum__Intrinsic__Tz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %paulis, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %paulis)
  call void @__quantum__rt__array_add_access(%Array* %qubits)
  %0 = load %Result*, %Result** @ResultOne
  %res = alloca %Result*
  store %Result* %0, %Result** %res
  %haveY = alloca i1
  store i1 false, i1* %haveY
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %paulis)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %17, %exiting__1 ]
  %3 = icmp sge i64 %i, %2
  %4 = icmp sle i64 %i, %2
  %5 = select i1 true, i1 %4, i1 %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %7 = bitcast i8* %6 to i2*
  %8 = load i2, i2* %7
  %9 = load i2, i2* @PauliY
  %10 = icmp eq i2 %8, %9
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 %i)
  %12 = bitcast i8* %11 to i2*
  %13 = load i2, i2* %12
  %14 = load i2, i2* @PauliI
  %15 = icmp eq i2 %13, %14
  %16 = or i1 %10, %15
  br i1 %16, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  store i1 true, i1* %haveY
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %17 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %18 = load i1, i1* %haveY
  br i1 %18, label %then0__2, label %test1__1

then0__2:                                         ; preds = %exit__1
  %19 = call %Result* @__quantum__trc__multi_qubit_measure(i64 106, i64 1, %Array* %qubits)
  store %Result* %19, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %19)
  br label %continue__2

test1__1:                                         ; preds = %exit__1
  %20 = icmp sgt i64 %1, 2
  br i1 %20, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %21 = call %Result* @__quantum__trc__multi_qubit_measure(i64 107, i64 1, %Array* %qubits)
  store %Result* %21, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %21)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  %22 = icmp eq i64 %1, 1
  br i1 %22, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %24 = bitcast i8* %23 to i2*
  %25 = load i2, i2* %24
  %26 = load i2, i2* @PauliX
  %27 = icmp eq i2 %25, %26
  br i1 %27, label %then0__3, label %else__1

then0__3:                                         ; preds = %then2__1
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %29 = bitcast i8* %28 to %Qubit**
  %qb__inline__1 = load %Qubit*, %Qubit** %29
  %30 = call %Result* @__quantum__trc__single_qubit_measure(i64 101, i64 1, %Qubit* %qb__inline__1)
  store %Result* %30, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %30)
  br label %continue__3

else__1:                                          ; preds = %then2__1
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %32 = bitcast i8* %31 to %Qubit**
  %qb__inline__2 = load %Qubit*, %Qubit** %32
  %33 = call %Result* @__quantum__trc__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__inline__2)
  store %Result* %33, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %33)
  br label %continue__3

continue__3:                                      ; preds = %else__1, %then0__3
  br label %continue__2

test3__1:                                         ; preds = %test2__1
  %34 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %35 = bitcast i8* %34 to i2*
  %36 = load i2, i2* %35
  %37 = load i2, i2* @PauliX
  %38 = icmp eq i2 %36, %37
  %39 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %40 = bitcast i8* %39 to i2*
  %41 = load i2, i2* %40
  %42 = load i2, i2* @PauliX
  %43 = icmp eq i2 %41, %42
  %44 = and i1 %38, %43
  br i1 %44, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %45 = call %Result* @__quantum__trc__multi_qubit_measure(i64 108, i64 1, %Array* %qubits)
  store %Result* %45, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %45)
  br label %continue__2

test4__1:                                         ; preds = %test3__1
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %47 = bitcast i8* %46 to i2*
  %48 = load i2, i2* %47
  %49 = load i2, i2* @PauliX
  %50 = icmp eq i2 %48, %49
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %52 = bitcast i8* %51 to i2*
  %53 = load i2, i2* %52
  %54 = load i2, i2* @PauliZ
  %55 = icmp eq i2 %53, %54
  %56 = and i1 %50, %55
  br i1 %56, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %57 = call %Result* @__quantum__trc__multi_qubit_measure(i64 109, i64 1, %Array* %qubits)
  store %Result* %57, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %57)
  br label %continue__2

test5__1:                                         ; preds = %test4__1
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %59 = bitcast i8* %58 to i2*
  %60 = load i2, i2* %59
  %61 = load i2, i2* @PauliZ
  %62 = icmp eq i2 %60, %61
  %63 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %64 = bitcast i8* %63 to i2*
  %65 = load i2, i2* %64
  %66 = load i2, i2* @PauliX
  %67 = icmp eq i2 %65, %66
  %68 = and i1 %62, %67
  br i1 %68, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %69 = call %Result* @__quantum__trc__multi_qubit_measure(i64 110, i64 1, %Array* %qubits)
  store %Result* %69, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %69)
  br label %continue__2

test6__1:                                         ; preds = %test5__1
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 0)
  %71 = bitcast i8* %70 to i2*
  %72 = load i2, i2* %71
  %73 = load i2, i2* @PauliZ
  %74 = icmp eq i2 %72, %73
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis, i64 1)
  %76 = bitcast i8* %75 to i2*
  %77 = load i2, i2* %76
  %78 = load i2, i2* @PauliZ
  %79 = icmp eq i2 %77, %78
  %80 = and i1 %74, %79
  br i1 %80, label %then6__1, label %continue__2

then6__1:                                         ; preds = %test6__1
  %81 = call %Result* @__quantum__trc__multi_qubit_measure(i64 111, i64 1, %Array* %qubits)
  store %Result* %81, %Result** %res
  call void @__quantum__rt__result_unreference(%Result* %81)
  br label %continue__2

continue__2:                                      ; preds = %then6__1, %test6__1, %then5__1, %then4__1, %then3__1, %continue__3, %then1__1, %then0__2
  %82 = load %Result*, %Result** %res
  call void @__quantum__rt__result_reference(%Result* %82)
  call void @__quantum__rt__array_remove_access(%Array* %paulis)
  call void @__quantum__rt__array_remove_access(%Array* %qubits)
  ret %Result* %82
}

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare %Result* @__quantum__trc__multi_qubit_measure(i64, i64, %Array*)

declare void @__quantum__rt__result_unreference(%Result*)

declare %Result* @__quantum__trc__single_qubit_measure(i64, i64, %Qubit*)

declare void @__quantum__rt__result_reference(%Result*)

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 23, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 24, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__Mz__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__trc__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__1, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__1)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__1)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare void @__quantum__rt__array_unreference(%Array*)

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__1, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__1)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__Mx__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__trc__single_qubit_measure(i64 101, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__trc__single_qubit_measure(i64 100, i64 1, %Qubit* %qb)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define i1 @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body() #0 {
entry:
  %res = alloca i1
  store i1 false, i1* %res
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_add_access(%Array* %qs)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb__inline__1 = load %Qubit*, %Qubit** %1
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__1)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__inline__2 = load %Qubit*, %Qubit** %3
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb__inline__2)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %qb__inline__3 = load %Qubit*, %Qubit** %5
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb__inline__3)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %qb__inline__4 = load %Qubit*, %Qubit** %7
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb__inline__4)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %12 = bitcast i8* %11 to %Qubit**
  %13 = load %Qubit*, %Qubit** %12
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %10, %Qubit* %13)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %15 = bitcast i8* %14 to %Qubit**
  %qb__inline__5 = load %Qubit*, %Qubit** %15
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb__inline__5)
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %17 = bitcast i8* %16 to %Qubit**
  %qb__inline__6 = load %Qubit*, %Qubit** %17
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb__inline__6)
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %19 = bitcast i8* %18 to %Qubit**
  %qb__inline__7 = load %Qubit*, %Qubit** %19
  call void @__quantum__trc__single_qubit_op(i64 23, i64 1, %Qubit* %qb__inline__7)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %21 = bitcast i8* %20 to %Qubit**
  %qb__inline__8 = load %Qubit*, %Qubit** %21
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb__inline__8)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %23 = bitcast i8* %22 to %Qubit**
  %qb__inline__10 = load %Qubit*, %Qubit** %23
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb__inline__10)
  call void @__quantum__trc__inject_global_barrier(i64 42, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  %qb__inline__12 = load %Qubit*, %Qubit** %25
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__12)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %27 = bitcast i8* %26 to %Qubit**
  %qb__inline__13 = load %Qubit*, %Qubit** %27
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb__inline__13)
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %29 = bitcast i8* %28 to %Qubit**
  %qb__inline__14 = load %Qubit*, %Qubit** %29
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb__inline__14)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %31 = bitcast i8* %30 to %Qubit**
  %qb__inline__15 = load %Qubit*, %Qubit** %31
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb__inline__15)
  %32 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %33 = bitcast i8* %32 to %Qubit**
  %34 = load %Qubit*, %Qubit** %33
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %36 = bitcast i8* %35 to %Qubit**
  %37 = load %Qubit*, %Qubit** %36
  call void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %34, %Qubit* %37)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %39 = bitcast i8* %38 to %Qubit**
  %qb__inline__16 = load %Qubit*, %Qubit** %39
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb__inline__16)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %41 = bitcast i8* %40 to %Qubit**
  %qb__inline__17 = load %Qubit*, %Qubit** %41
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb__inline__17)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %43 = bitcast i8* %42 to %Qubit**
  %qb__inline__18 = load %Qubit*, %Qubit** %43
  call void @__quantum__trc__single_qubit_op(i64 24, i64 1, %Qubit* %qb__inline__18)
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %45 = bitcast i8* %44 to %Qubit**
  %qb__inline__19 = load %Qubit*, %Qubit** %45
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb__inline__19)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %47 = bitcast i8* %46 to %Qubit**
  %qb__inline__21 = load %Qubit*, %Qubit** %47
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb__inline__21)
  %c = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls__inline__23 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__23, i64 0)
  %49 = bitcast i8* %48 to %Qubit**
  store %Qubit* %c, %Qubit** %49
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__23)
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %51 = bitcast i8* %50 to %Qubit**
  %qb__inline__23 = load %Qubit*, %Qubit** %51
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__23, %Qubit* %qb__inline__23)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__23, %Qubit* %qb__inline__23)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__23)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__23)
  %ctls__inline__24 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__24, i64 0)
  %53 = bitcast i8* %52 to %Qubit**
  store %Qubit* %c, %Qubit** %53
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__24)
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %55 = bitcast i8* %54 to %Qubit**
  %qb__inline__24 = load %Qubit*, %Qubit** %55
  br i1 true, label %then0__2, label %else__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls__inline__24, %Qubit* %qb__inline__24)
  br label %continue__2

else__2:                                          ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls__inline__24, %Qubit* %qb__inline__24)
  br label %continue__2

continue__2:                                      ; preds = %else__2, %then0__2
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__24)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__24)
  %ctls__inline__25 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__25, i64 0)
  %57 = bitcast i8* %56 to %Qubit**
  store %Qubit* %c, %Qubit** %57
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__25)
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %59 = bitcast i8* %58 to %Qubit**
  %qb__inline__25 = load %Qubit*, %Qubit** %59
  br i1 true, label %then0__3, label %else__3

then0__3:                                         ; preds = %continue__2
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls__inline__25, %Qubit* %qb__inline__25)
  br label %continue__3

else__3:                                          ; preds = %continue__2
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls__inline__25, %Qubit* %qb__inline__25)
  br label %continue__3

continue__3:                                      ; preds = %else__3, %then0__3
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__25)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__25)
  %ctls__inline__26 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__26, i64 0)
  %61 = bitcast i8* %60 to %Qubit**
  store %Qubit* %c, %Qubit** %61
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__26)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %63 = bitcast i8* %62 to %Qubit**
  %qb__inline__26 = load %Qubit*, %Qubit** %63
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls__inline__26, %Qubit* %qb__inline__26)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__26)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__26)
  %ctls__inline__27 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__27, i64 0)
  %65 = bitcast i8* %64 to %Qubit**
  store %Qubit* %c, %Qubit** %65
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__27)
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %67 = bitcast i8* %66 to %Qubit**
  %qb__inline__27 = load %Qubit*, %Qubit** %67
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls__inline__27, %Qubit* %qb__inline__27)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__27)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__27)
  %ctls__inline__28 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %68 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__28, i64 0)
  %69 = bitcast i8* %68 to %Qubit**
  store %Qubit* %c, %Qubit** %69
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__28)
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %71 = bitcast i8* %70 to %Qubit**
  %qb__inline__28 = load %Qubit*, %Qubit** %71
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls__inline__28, %Qubit* %qb__inline__28)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__28)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__28)
  %ctls__inline__29 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__29, i64 0)
  %73 = bitcast i8* %72 to %Qubit**
  store %Qubit* %c, %Qubit** %73
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__29)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %75 = bitcast i8* %74 to %Qubit**
  %qb__inline__29 = load %Qubit*, %Qubit** %75
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls__inline__29, %Qubit* %qb__inline__29)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__29)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__29)
  %ctls__inline__30 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__30, i64 0)
  %77 = bitcast i8* %76 to %Qubit**
  store %Qubit* %c, %Qubit** %77
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__30)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %79 = bitcast i8* %78 to %Qubit**
  %qb__inline__30 = load %Qubit*, %Qubit** %79
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__30)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls__inline__30, %Qubit* %qb__inline__30)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__30)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__30)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__30)
  %ctls__inline__32 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__32, i64 0)
  %81 = bitcast i8* %80 to %Qubit**
  store %Qubit* %c, %Qubit** %81
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__32)
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %83 = bitcast i8* %82 to %Qubit**
  %qb__inline__32 = load %Qubit*, %Qubit** %83
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__32)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls__inline__32, %Qubit* %qb__inline__32)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__32)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__32)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__32)
  call void @__quantum__rt__qubit_release(%Qubit* %c)
  %cc = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %84 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %85 = bitcast i8* %84 to %Qubit**
  %qb__inline__34 = load %Qubit*, %Qubit** %85
  %86 = call i64 @__quantum__rt__array_get_size_1d(%Array* %cc)
  %87 = icmp eq i64 %86, 1
  br i1 %87, label %then0__4, label %else__4

then0__4:                                         ; preds = %continue__3
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %cc, %Qubit* %qb__inline__34)
  br label %continue__4

else__4:                                          ; preds = %continue__3
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %cc, %Qubit* %qb__inline__34)
  br label %continue__4

continue__4:                                      ; preds = %else__4, %then0__4
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %89 = bitcast i8* %88 to %Qubit**
  %qb__inline__35 = load %Qubit*, %Qubit** %89
  %90 = icmp eq i64 %86, 1
  br i1 %90, label %then0__5, label %else__5

then0__5:                                         ; preds = %continue__4
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %cc, %Qubit* %qb__inline__35)
  br label %continue__5

else__5:                                          ; preds = %continue__4
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %cc, %Qubit* %qb__inline__35)
  br label %continue__5

continue__5:                                      ; preds = %else__5, %then0__5
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %92 = bitcast i8* %91 to %Qubit**
  %qb__inline__36 = load %Qubit*, %Qubit** %92
  %93 = icmp eq i64 %86, 1
  br i1 %93, label %then0__6, label %else__6

then0__6:                                         ; preds = %continue__5
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %cc, %Qubit* %qb__inline__36)
  br label %continue__6

else__6:                                          ; preds = %continue__5
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %cc, %Qubit* %qb__inline__36)
  br label %continue__6

continue__6:                                      ; preds = %else__6, %then0__6
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %94 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %95 = bitcast i8* %94 to %Qubit**
  %qb__inline__37 = load %Qubit*, %Qubit** %95
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %cc, %Qubit* %qb__inline__37)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %97 = bitcast i8* %96 to %Qubit**
  %qb__inline__38 = load %Qubit*, %Qubit** %97
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %cc, %Qubit* %qb__inline__38)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %99 = bitcast i8* %98 to %Qubit**
  %qb__inline__39 = load %Qubit*, %Qubit** %99
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %cc, %Qubit* %qb__inline__39)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %101 = bitcast i8* %100 to %Qubit**
  %qb__inline__40 = load %Qubit*, %Qubit** %101
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %cc, %Qubit* %qb__inline__40)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %103 = bitcast i8* %102 to %Qubit**
  %qb__inline__41 = load %Qubit*, %Qubit** %103
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %cc, %Qubit* %qb__inline__41)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %104 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %105 = bitcast i8* %104 to %Qubit**
  %qb__inline__43 = load %Qubit*, %Qubit** %105
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %cc, %Qubit* %qb__inline__43)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__qubit_release_array(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_unreference(%Array* %cc)
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %107 = bitcast i8* %106 to %Qubit**
  %qb__inline__45 = load %Qubit*, %Qubit** %107
  %r0 = call %Result* @__quantum__trc__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__inline__45)
  %qs12 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %108 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %109 = bitcast i8* %108 to %Qubit**
  %110 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 1)
  %111 = bitcast i8* %110 to %Qubit**
  %112 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %113 = bitcast i8* %112 to %Qubit**
  %114 = load %Qubit*, %Qubit** %113
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %116 = bitcast i8* %115 to %Qubit**
  %117 = load %Qubit*, %Qubit** %116
  store %Qubit* %114, %Qubit** %109
  store %Qubit* %117, %Qubit** %111
  call void @__quantum__rt__array_add_access(%Array* %qs12)
  %paulis__inline__47 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %118 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %119 = bitcast i8* %118 to i2*
  %120 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 1)
  %121 = bitcast i8* %120 to i2*
  %122 = load i2, i2* @PauliY
  %123 = load i2, i2* @PauliX
  store i2 %122, i2* %119
  store i2 %123, i2* %121
  call void @__quantum__rt__array_add_access(%Array* %paulis__inline__47)
  call void @__quantum__rt__array_add_access(%Array* %qs12)
  %124 = load %Result*, %Result** @ResultOne
  %res__inline__47 = alloca %Result*
  store %Result* %124, %Result** %res__inline__47
  %haveY__inline__47 = alloca i1
  store i1 false, i1* %haveY__inline__47
  br label %header__1

header__1:                                        ; preds = %exiting__1, %continue__6
  %i__inline__47 = phi i64 [ 0, %continue__6 ], [ %139, %exiting__1 ]
  %125 = icmp sge i64 %i__inline__47, 1
  %126 = icmp sle i64 %i__inline__47, 1
  %127 = select i1 true, i1 %126, i1 %125
  br i1 %127, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %128 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 %i__inline__47)
  %129 = bitcast i8* %128 to i2*
  %130 = load i2, i2* %129
  %131 = load i2, i2* @PauliY
  %132 = icmp eq i2 %130, %131
  %133 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 %i__inline__47)
  %134 = bitcast i8* %133 to i2*
  %135 = load i2, i2* %134
  %136 = load i2, i2* @PauliI
  %137 = icmp eq i2 %135, %136
  %138 = or i1 %132, %137
  br i1 %138, label %then0__7, label %continue__7

then0__7:                                         ; preds = %body__1
  store i1 true, i1* %haveY__inline__47
  br label %continue__7

continue__7:                                      ; preds = %then0__7, %body__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__7
  %139 = add i64 %i__inline__47, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %140 = load i1, i1* %haveY__inline__47
  br i1 %140, label %then0__8, label %test1__1

then0__8:                                         ; preds = %exit__1
  %141 = call %Result* @__quantum__trc__multi_qubit_measure(i64 106, i64 1, %Array* %qs12)
  store %Result* %141, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %141)
  br label %continue__8

test1__1:                                         ; preds = %exit__1
  br i1 false, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %142 = call %Result* @__quantum__trc__multi_qubit_measure(i64 107, i64 1, %Array* %qs12)
  store %Result* %142, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %142)
  br label %continue__8

test2__1:                                         ; preds = %test1__1
  br i1 false, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %143 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %144 = bitcast i8* %143 to i2*
  %145 = load i2, i2* %144
  %146 = load i2, i2* @PauliX
  %147 = icmp eq i2 %145, %146
  br i1 %147, label %then0__9, label %else__7

then0__9:                                         ; preds = %then2__1
  %148 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %149 = bitcast i8* %148 to %Qubit**
  %qb__inline__48 = load %Qubit*, %Qubit** %149
  %150 = call %Result* @__quantum__trc__single_qubit_measure(i64 101, i64 1, %Qubit* %qb__inline__48)
  store %Result* %150, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %150)
  br label %continue__9

else__7:                                          ; preds = %then2__1
  %151 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %152 = bitcast i8* %151 to %Qubit**
  %qb__inline__49 = load %Qubit*, %Qubit** %152
  %153 = call %Result* @__quantum__trc__single_qubit_measure(i64 100, i64 1, %Qubit* %qb__inline__49)
  store %Result* %153, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %153)
  br label %continue__9

continue__9:                                      ; preds = %else__7, %then0__9
  br label %continue__8

test3__1:                                         ; preds = %test2__1
  %154 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %155 = bitcast i8* %154 to i2*
  %156 = load i2, i2* %155
  %157 = load i2, i2* @PauliX
  %158 = icmp eq i2 %156, %157
  %159 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 1)
  %160 = bitcast i8* %159 to i2*
  %161 = load i2, i2* %160
  %162 = load i2, i2* @PauliX
  %163 = icmp eq i2 %161, %162
  %164 = and i1 %158, %163
  br i1 %164, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %165 = call %Result* @__quantum__trc__multi_qubit_measure(i64 108, i64 1, %Array* %qs12)
  store %Result* %165, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %165)
  br label %continue__8

test4__1:                                         ; preds = %test3__1
  %166 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %167 = bitcast i8* %166 to i2*
  %168 = load i2, i2* %167
  %169 = load i2, i2* @PauliX
  %170 = icmp eq i2 %168, %169
  %171 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 1)
  %172 = bitcast i8* %171 to i2*
  %173 = load i2, i2* %172
  %174 = load i2, i2* @PauliZ
  %175 = icmp eq i2 %173, %174
  %176 = and i1 %170, %175
  br i1 %176, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %177 = call %Result* @__quantum__trc__multi_qubit_measure(i64 109, i64 1, %Array* %qs12)
  store %Result* %177, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %177)
  br label %continue__8

test5__1:                                         ; preds = %test4__1
  %178 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %179 = bitcast i8* %178 to i2*
  %180 = load i2, i2* %179
  %181 = load i2, i2* @PauliZ
  %182 = icmp eq i2 %180, %181
  %183 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 1)
  %184 = bitcast i8* %183 to i2*
  %185 = load i2, i2* %184
  %186 = load i2, i2* @PauliX
  %187 = icmp eq i2 %185, %186
  %188 = and i1 %182, %187
  br i1 %188, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %189 = call %Result* @__quantum__trc__multi_qubit_measure(i64 110, i64 1, %Array* %qs12)
  store %Result* %189, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %189)
  br label %continue__8

test6__1:                                         ; preds = %test5__1
  %190 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 0)
  %191 = bitcast i8* %190 to i2*
  %192 = load i2, i2* %191
  %193 = load i2, i2* @PauliZ
  %194 = icmp eq i2 %192, %193
  %195 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__47, i64 1)
  %196 = bitcast i8* %195 to i2*
  %197 = load i2, i2* %196
  %198 = load i2, i2* @PauliZ
  %199 = icmp eq i2 %197, %198
  %200 = and i1 %194, %199
  br i1 %200, label %then6__1, label %continue__8

then6__1:                                         ; preds = %test6__1
  %201 = call %Result* @__quantum__trc__multi_qubit_measure(i64 111, i64 1, %Array* %qs12)
  store %Result* %201, %Result** %res__inline__47
  call void @__quantum__rt__result_unreference(%Result* %201)
  br label %continue__8

continue__8:                                      ; preds = %then6__1, %test6__1, %then5__1, %then4__1, %then3__1, %continue__9, %then1__1, %then0__8
  %r12 = load %Result*, %Result** %res__inline__47
  call void @__quantum__rt__result_reference(%Result* %r12)
  call void @__quantum__rt__array_remove_access(%Array* %paulis__inline__47)
  call void @__quantum__rt__array_remove_access(%Array* %qs12)
  call void @__quantum__rt__array_unreference(%Array* %paulis__inline__47)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_remove_access(%Array* %qs)
  call void @__quantum__rt__array_remove_access(%Array* %qs12)
  call void @__quantum__rt__array_unreference(%Array* %qs)
  call void @__quantum__rt__result_unreference(%Result* %r0)
  call void @__quantum__rt__array_unreference(%Array* %qs12)
  call void @__quantum__rt__result_unreference(%Result* %r12)
  ret i1 true
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__trc__inject_global_barrier(i64, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

attributes #0 = { "EntryPoint" }
