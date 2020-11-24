
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque
%Qubit = type opaque
%TupleHeader = type { i32 }
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

declare void @__quantum__qis__crx(%Array*, double, %Qubit*)

declare void @__quantum__qis__crz(%Array*, double, %Qubit*)

declare double @__quantum__qis__intAsDouble(i64)

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)

declare void @__quantum__qis__h(%Qubit*)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare %Result* @__quantum__qis__measure(%Array*, %Array*)

declare void @__quantum__qis__rx(double, %Qubit*)

declare void @__quantum__qis__rz(double, %Qubit*)

declare void @__quantum__qis__s(%Qubit*)

declare void @__quantum__qis__x(%Qubit*)

declare void @__quantum__qis__z(%Qubit*)

define void @StreamlinedBenchmarks__applyLadder__body(%Array* %angles, %Array* %reg, i64 %nQ) {
entry:
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %angles, i32 0)
  %1 = udiv i64 %0, 2
  %n = alloca i64
  store i64 %1, i64* %n
  %2 = load i64, i64* %n
  %3 = icmp sgt i64 %2, %nQ
  br i1 %3, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  store i64 %nQ, i64* %n
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  %.ctl = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %.ctl, i64 0)
  %5 = load i64, i64* %n
  %6 = sub i64 %5, 1
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %6)
  %8 = bitcast i8* %7 to %Qubit**
  %9 = load %Qubit*, %Qubit** %8
  %10 = bitcast i8* %4 to %Qubit**
  store %Qubit* %9, %Qubit** %10
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 0)
  %12 = bitcast i8* %11 to double*
  %.theta = load double, double* %12
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 0)
  %14 = bitcast i8* %13 to %Qubit**
  %.qb = load %Qubit*, %Qubit** %14
  call void @__quantum__qis__crz(%Array* %.ctl, double %.theta, %Qubit* %.qb)
  %.ctl1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %.ctl1, i64 0)
  %16 = load i64, i64* %n
  %17 = sub i64 %16, 1
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %17)
  %19 = bitcast i8* %18 to %Qubit**
  %20 = load %Qubit*, %Qubit** %19
  %21 = bitcast i8* %15 to %Qubit**
  store %Qubit* %20, %Qubit** %21
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 1)
  %23 = bitcast i8* %22 to double*
  %.theta2 = load double, double* %23
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  %.qb3 = load %Qubit*, %Qubit** %25
  call void @__quantum__qis__crx(%Array* %.ctl1, double %.theta2, %Qubit* %.qb3)
  %26 = load i64, i64* %n
  %end__1 = sub i64 %26, 2
  br label %preheader__1

preheader__1:                                     ; preds = %continue__1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %j = phi i64 [ 0, %preheader__1 ], [ %54, %exiting__1 ]
  %27 = icmp sge i64 %j, %end__1
  %28 = icmp sle i64 %j, %end__1
  %29 = select i1 true, i1 %28, i1 %27
  br i1 %29, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %.ctl4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %.ctl4, i64 0)
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %j)
  %32 = bitcast i8* %31 to %Qubit**
  %33 = load %Qubit*, %Qubit** %32
  %34 = bitcast i8* %30 to %Qubit**
  store %Qubit* %33, %Qubit** %34
  %35 = mul i64 2, %j
  %36 = add i64 %35, 2
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 %36)
  %38 = bitcast i8* %37 to double*
  %.theta5 = load double, double* %38
  %39 = add i64 %j, 1
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %39)
  %41 = bitcast i8* %40 to %Qubit**
  %.qb6 = load %Qubit*, %Qubit** %41
  call void @__quantum__qis__crz(%Array* %.ctl4, double %.theta5, %Qubit* %.qb6)
  %.ctl7 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %.ctl7, i64 0)
  %43 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %j)
  %44 = bitcast i8* %43 to %Qubit**
  %45 = load %Qubit*, %Qubit** %44
  %46 = bitcast i8* %42 to %Qubit**
  store %Qubit* %45, %Qubit** %46
  %47 = mul i64 2, %j
  %48 = add i64 %47, 3
  %49 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 %48)
  %50 = bitcast i8* %49 to double*
  %.theta8 = load double, double* %50
  %51 = add i64 %j, 1
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %51)
  %53 = bitcast i8* %52 to %Qubit**
  %.qb9 = load %Qubit*, %Qubit** %53
  call void @__quantum__qis__crx(%Array* %.ctl7, double %.theta8, %Qubit* %.qb9)
  call void @__quantum__rt__array_unreference(%Array* %.ctl4)
  call void @__quantum__rt__array_unreference(%Array* %.ctl7)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %54 = add i64 %j, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_unreference(%Array* %.ctl)
  call void @__quantum__rt__array_unreference(%Array* %.ctl1)
  ret void
}

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_unreference(%Array*)

define void @StreamlinedBenchmarks__applyRotations__body(%Array* %angles, %Array* %reg, i64 %nQ) {
entry:
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %angles, i32 0)
  %1 = udiv i64 %0, 2
  %n = alloca i64
  store i64 %1, i64* %n
  %2 = load i64, i64* %n
  %3 = icmp sgt i64 %2, %nQ
  br i1 %3, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  store i64 %nQ, i64* %n
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  %4 = load i64, i64* %n
  %end__1 = sub i64 %4, 1
  br label %preheader__1

preheader__1:                                     ; preds = %continue__1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %j = phi i64 [ 0, %preheader__1 ], [ %19, %exiting__1 ]
  %5 = icmp sge i64 %j, %end__1
  %6 = icmp sle i64 %j, %end__1
  %7 = select i1 true, i1 %6, i1 %5
  br i1 %7, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %8 = mul i64 2, %j
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 %8)
  %10 = bitcast i8* %9 to double*
  %.theta = load double, double* %10
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %j)
  %12 = bitcast i8* %11 to %Qubit**
  %.qb = load %Qubit*, %Qubit** %12
  call void @__quantum__qis__rz(double %.theta, %Qubit* %.qb)
  %13 = mul i64 2, %j
  %14 = add i64 %13, 1
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %angles, i64 %14)
  %16 = bitcast i8* %15 to double*
  %.theta1 = load double, double* %16
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %reg, i64 %j)
  %18 = bitcast i8* %17 to %Qubit**
  %.qb2 = load %Qubit*, %Qubit** %18
  call void @__quantum__qis__rx(double %.theta1, %Qubit* %.qb2)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %19 = add i64 %j, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  ret void
}

define void @StreamlinedBenchmarks__Benchmark__body(%Array* %angles, i64 %nQ, i64 %reps, i1 %linear) {
entry:
  br i1 %linear, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @StreamlinedBenchmarks__OnCircuit__body(%Array* %angles, i64 %nQ, i64 %reps)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @StreamlinedBenchmarks__OnSquareCircuit__body(%Array* %angles, i64 %nQ, i64 %reps)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  ret void
}

define void @StreamlinedBenchmarks__OnCircuit__body(%Array* %angles, i64 %nQ, i64 %reps) {
entry:
  %reg = call %Array* @__quantum__rt__qubit_allocate_array(i64 %nQ)
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %j = phi i64 [ 1, %preheader__1 ], [ %3, %exiting__1 ]
  %0 = icmp sge i64 %j, %reps
  %1 = icmp sle i64 %j, %reps
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  call void @StreamlinedBenchmarks__applyRotations__body(%Array* %angles, %Array* %reg, i64 %nQ)
  call void @StreamlinedBenchmarks__applyLadder__body(%Array* %angles, %Array* %reg, i64 %nQ)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %3 = add i64 %j, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @StreamlinedBenchmarks__ResetAll__body(%Array* %reg)
  call void @__quantum__rt__qubit_release_array(%Array* %reg)
  ret void
}

define void @StreamlinedBenchmarks__OnSquareCircuit__body(%Array* %angles, i64 %nQ, i64 %reps) {
entry:
  %reg = call %Array* @__quantum__rt__qubit_allocate_array(i64 %nQ)
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %j = phi i64 [ 1, %preheader__1 ], [ %3, %exiting__1 ]
  %0 = icmp sge i64 %j, %reps
  %1 = icmp sle i64 %j, %reps
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %end__2 = sub i64 %nQ, 1
  br label %preheader__2

exiting__1:                                       ; preds = %exit__2
  %3 = add i64 %j, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @StreamlinedBenchmarks__ResetAll__body(%Array* %reg)
  call void @__quantum__rt__qubit_release_array(%Array* %reg)
  ret void

preheader__2:                                     ; preds = %body__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %k = phi i64 [ 0, %preheader__2 ], [ %31, %exiting__2 ]
  %4 = icmp sge i64 %k, %end__2
  %5 = icmp sle i64 %k, %end__2
  %6 = select i1 true, i1 %5, i1 %4
  br i1 %6, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %7 = mul i64 2, %k
  %8 = mul i64 %7, %nQ
  %9 = mul i64 2, %k
  %10 = mul i64 %9, %nQ
  %11 = mul i64 2, %nQ
  %12 = add i64 %10, %11
  %13 = sub i64 %12, 1
  %14 = load %Range, %Range* @EmptyRange
  %15 = insertvalue %Range %14, i64 %8, 0
  %16 = insertvalue %Range %15, i64 1, 1
  %17 = insertvalue %Range %16, i64 %13, 2
  %18 = call %Array* @__quantum__rt__array_slice(%Array* %angles, i32 0, %Range %17)
  call void @StreamlinedBenchmarks__applyRotations__body(%Array* %18, %Array* %reg, i64 %nQ)
  %19 = mul i64 2, %k
  %20 = mul i64 %19, %nQ
  %21 = mul i64 2, %k
  %22 = mul i64 %21, %nQ
  %23 = mul i64 2, %nQ
  %24 = add i64 %22, %23
  %25 = sub i64 %24, 1
  %26 = load %Range, %Range* @EmptyRange
  %27 = insertvalue %Range %26, i64 %20, 0
  %28 = insertvalue %Range %27, i64 1, 1
  %29 = insertvalue %Range %28, i64 %25, 2
  %30 = call %Array* @__quantum__rt__array_slice(%Array* %angles, i32 0, %Range %29)
  call void @StreamlinedBenchmarks__applyLadder__body(%Array* %30, %Array* %reg, i64 %nQ)
  call void @__quantum__rt__array_unreference(%Array* %18)
  call void @__quantum__rt__array_unreference(%Array* %30)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %31 = add i64 %k, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  br label %exiting__1
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

define void @StreamlinedBenchmarks__ResetAll__body(%Array* %qubits) {
entry:
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %qubits, i32 0)
  %end__1 = sub i64 %0, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %6, %exiting__1 ]
  %1 = icmp sge i64 %iter__1, %end__1
  %2 = icmp sle i64 %iter__1, %end__1
  %3 = select i1 true, i1 %2, i1 %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %iter__1)
  %5 = bitcast i8* %4 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %5
  call void @StreamlinedBenchmarks__Reset__body(%Qubit* %qubit)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %6 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  ret void
}

declare void @__quantum__rt__qubit_release_array(%Array*)

declare %Array* @__quantum__rt__array_slice(%Array*, i32, %Range)

define void @StreamlinedBenchmarks__Reset__body(%Qubit* %target) {
entry:
  %0 = call %Result* @__quantum__qis__mz(%Qubit* %target)
  %1 = load %Result*, %Result** @ResultOne
  %2 = call i1 @__quantum__rt__result_equal(%Result* %0, %Result* %1)
  br i1 %2, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @Microsoft__Quantum__Instructions__ControlledPhysRx__body(%Array*, double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__ControlledPhysRz__body(%Array*, double, %Qubit*)

declare double @Microsoft__Quantum__Instructions__IntAsDoubleImpl__body(i64)

declare void @Microsoft__Quantum__Instructions__PhysCNOT__body(%Qubit*, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysH__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysM__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysMeasure__body(%Array*, %Array*)

declare void @Microsoft__Quantum__Instructions__PhysRx__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRz__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysS__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysX__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysZ__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  call void @__quantum__qis__cnot(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__h(%Qubit* %qb)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  %0 = call %Result* @__quantum__qis__measure(%Array* %bases, %Array* %qubits)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rx(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rx(double %0, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctrl(%Array* %ctl, { %TupleHeader, double, %Qubit* }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 1
  %1 = load double, double* %0
  %2 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 2
  %3 = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__crx(%Array* %ctl, double %1, %Qubit* %3)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctrladj(%Array* %ctl, { %TupleHeader, double, %Qubit* }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 1
  %1 = load double, double* %0
  %2 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 2
  %3 = load %Qubit*, %Qubit** %2
  %4 = fsub double -0.000000e+00, %1
  call void @__quantum__qis__crx(%Array* %ctl, double %4, %Qubit* %3)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rz(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rz(double %0, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctrl(%Array* %ctl, { %TupleHeader, double, %Qubit* }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 1
  %1 = load double, double* %0
  %2 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 2
  %3 = load %Qubit*, %Qubit** %2
  call void @__quantum__qis__crz(%Array* %ctl, double %1, %Qubit* %3)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctrladj(%Array* %ctl, { %TupleHeader, double, %Qubit* }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 1
  %1 = load double, double* %0
  %2 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %arg__1, i64 0, i32 2
  %3 = load %Qubit*, %Qubit** %2
  %4 = fsub double -0.000000e+00, %1
  call void @__quantum__qis__crz(%Array* %ctl, double %4, %Qubit* %3)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  call void @__quantum__qis__z(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__z(%Qubit* %qb)
  ret void
}

define %TupleHeader* @Microsoft__Quantum__Core__Attribute__body() {
entry:
  ret %TupleHeader* null
}

define %TupleHeader* @Microsoft__Quantum__Core__EntryPoint__body() {
entry:
  ret %TupleHeader* null
}

define %TupleHeader* @Microsoft__Quantum__Core__Inline__body() {
entry:
  ret %TupleHeader* null
}

define { %TupleHeader, %String* }* @Microsoft__Quantum__Core__Intrinsic__body(%String* %arg0) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %String* }* getelementptr ({ %TupleHeader, %String* }, { %TupleHeader, %String* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %String* }*
  %2 = getelementptr { %TupleHeader, %String* }, { %TupleHeader, %String* }* %1, i64 0, i32 1
  store %String* %arg0, %String** %2
  call void @__quantum__rt__string_reference(%String* %arg0)
  ret { %TupleHeader, %String* }* %1
}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__string_reference(%String*)

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare i64 @Microsoft__Quantum__Core__RangeEnd__body(%Range)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStart__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStep__body(%Range)

define double @Microsoft__Quantum__Convert__IntAsDouble__body(i64 %i) {
entry:
  %0 = call double @__quantum__qis__intAsDouble(i64 %i)
  ret double %0
}

define void @StreamlinedBenchmarks_Benchmark(i64 %angles__count, double* %angles, i64 %nQ, i64 %reps, i1 %linear) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %angles__count)
  %1 = icmp sgt i64 %angles__count, 0
  br i1 %1, label %copy, label %next

copy:                                             ; preds = %entry
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %3 = mul i64 %angles__count, 8
  %4 = bitcast double* %angles to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %2, i8* %4, i64 %3, i1 false)
  br label %next

next:                                             ; preds = %copy, %entry
  call void @StreamlinedBenchmarks__Benchmark__body(%Array* %0, i64 %nQ, i64 %reps, i1 %linear)
  call void @__quantum__rt__array_unreference(%Array* %0)
  ret void
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #1

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind }
