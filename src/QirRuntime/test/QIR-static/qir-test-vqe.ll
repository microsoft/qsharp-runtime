; Copyright (c) Microsoft Corporation. All rights reserved.
; Licensed under the MIT License.

%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque
%TupleHeader = type { i32 }
%String = type opaque

@PauliI = internal constant i2 0
@PauliX = internal constant i2 1
@PauliY = internal constant i2 -1
@PauliZ = internal constant i2 -2
@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

declare double @__quantum__qis__intAsDouble(i64)

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)

declare void @__quantum__qis__h(%Qubit*)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare %Result* @__quantum__qis__measure(%Array*, %Array*)

declare void @__quantum__qis__rx(double, %Qubit*)

declare void @__quantum__qis__rz(double, %Qubit*)

declare void @__quantum__qis__x(%Qubit*)

declare double @Microsoft__Quantum__Instructions__IntAsDoubleImpl__body(i64)

declare void @Microsoft__Quantum__Instructions__PhysCNOT__body(%Qubit*, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysH__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysM__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysMeasure__body(%Array*, %Array*)

declare void @Microsoft__Quantum__Instructions__PhysRx__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRz__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysX__body(%Qubit*)



;define %TupleHeader* @Microsoft__Quantum__Core__Intrinsic__body(%String*) {
;entry:
;  %1 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %String* }* getelementptr ({ %TupleHeader, %String* }, { %TupleHeader, %String* }* null, i32 1) to i64))
;  %2 = bitcast %TupleHeader* %1 to { %TupleHeader, %String* }*
;  %3 = getelementptr inbounds { %TupleHeader, %String* }, { %TupleHeader, %String* }* %2, i32 0, i32 1
;  store %String* %0, %String** %3
;  ret %TupleHeader* %1
;}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare i64 @Microsoft__Quantum__Core__RangeEnd__body(%Range)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStart__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStep__body(%Range)

define double @Sample__VQE__EstimateFrequency__body(%Array* %state1, %Array* %state2, double %phase, %Array* %measurementOps, i64 %nTrials) {
entry:
  %nUp = alloca i64
  store i64 0, i64* %nUp
  %nQubits = call i64 @__quantum__rt__array_get_length(%Array* %measurementOps, i32 0)
  %end__1 = sub i64 %nTrials, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %idxMeasurement = phi i64 [ 0, %preheader__1 ], [ %8, %exiting__1 ]
  %0 = icmp sge i64 %idxMeasurement, %end__1
  %1 = icmp sle i64 %idxMeasurement, %end__1
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %register = call %Array* @__quantum__rt__qubit_allocate_array(i64 %nQubits)
  %aux = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @Sample__VQE__PrepareTrialState__body(%Array* %state1, %Array* %state2, double %phase, %Array* %register, %Array* %aux)
  %result = call %Result* @__quantum__qis__measure(%Array* %measurementOps, %Array* %register)
  %3 = load %Result*, %Result** @ResultZero
  %4 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %3)
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %5 = load i64, i64* %nUp
  %6 = add i64 %5, 1
  store i64 %6, i64* %nUp
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  %7 = call i64 @__quantum__rt__array_get_length(%Array* %register, i32 0)
  %end__2 = sub i64 %7, 1
  br label %preheader__2

exiting__1:                                       ; preds = %exit__2
  %8 = add i64 %idxMeasurement, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %.i = load i64, i64* %nUp
  %9 = call double @__quantum__qis__intAsDouble(i64 %.i)
  %10 = call double @__quantum__qis__intAsDouble(i64 %nTrials)
  %11 = fdiv double %9, %10
  ret double %11

preheader__2:                                     ; preds = %continue__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iter__1 = phi i64 [ 0, %preheader__2 ], [ %20, %exiting__2 ]
  %12 = icmp sge i64 %iter__1, %end__2
  %13 = icmp sle i64 %iter__1, %end__2
  %14 = select i1 true, i1 %13, i1 %12
  br i1 %14, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %iter__1)
  %16 = bitcast i8* %15 to %Qubit**
  %r = load %Qubit*, %Qubit** %16
  %17 = call %Result* @__quantum__qis__mz(%Qubit* %r)
  %18 = load %Result*, %Result** @ResultOne
  %19 = call i1 @__quantum__rt__result_equal(%Result* %17, %Result* %18)
  br i1 %19, label %then0__2, label %continue__2

then0__2:                                         ; preds = %body__2
  call void @__quantum__qis__x(%Qubit* %r)
  br label %continue__2

continue__2:                                      ; preds = %then0__2, %body__2
  br label %exiting__2

exiting__2:                                       ; preds = %continue__2
  %20 = add i64 %iter__1, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__qubit_release_array(%Array* %register)
  call void @__quantum__rt__qubit_release_array(%Array* %aux)
  br label %exiting__1
}

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

define void @Sample__VQE__PrepareTrialState__body(%Array* %state1, %Array* %state2, double %phase, %Array* %qubits, %Array* %aux) {
entry:
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %.qb = load %Qubit*, %Qubit** %1
  call void @__quantum__qis__h(%Qubit* %.qb)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %.qb1 = load %Qubit*, %Qubit** %3
  call void @__quantum__qis__rz(double %phase, %Qubit* %.qb1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 0)
  %5 = bitcast i8* %4 to %Qubit**
  %.control = load %Qubit*, %Qubit** %5
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %.target = load %Qubit*, %Qubit** %7
  call void @__quantum__qis__cnot(%Qubit* %.control, %Qubit* %.target)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 0)
  %9 = bitcast i8* %8 to %Qubit**
  %.qb2 = load %Qubit*, %Qubit** %9
  call void @__quantum__qis__x(%Qubit* %.qb2)
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 1)
  %11 = bitcast i8* %10 to %Qubit**
  %.qb3 = load %Qubit*, %Qubit** %11
  call void @__quantum__qis__x(%Qubit* %.qb3)
  %12 = call i64 @__quantum__rt__array_get_length(%Array* %state1, i32 0)
  %end__1 = sub i64 %12, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %20, %exiting__1 ]
  %13 = icmp sge i64 %iter__1, %end__1
  %14 = icmp sle i64 %iter__1, %end__1
  %15 = select i1 true, i1 %14, i1 %13
  br i1 %15, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %state1, i64 %iter__1)
  %17 = bitcast i8* %16 to i64*
  %__qsVar0__n__ = load i64, i64* %17
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %__qsVar0__n__)
  %19 = bitcast i8* %18 to %Qubit**
  %.qb4 = load %Qubit*, %Qubit** %19
  call void @__quantum__qis__x(%Qubit* %.qb4)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %20 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 1)
  %22 = bitcast i8* %21 to %Qubit**
  %.qb5 = load %Qubit*, %Qubit** %22
  call void @__quantum__qis__x(%Qubit* %.qb5)
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 0)
  %24 = bitcast i8* %23 to %Qubit**
  %.qb6 = load %Qubit*, %Qubit** %24
  call void @__quantum__qis__x(%Qubit* %.qb6)
  %25 = call i64 @__quantum__rt__array_get_length(%Array* %state2, i32 0)
  %end__2 = sub i64 %25, 1
  br label %preheader__2

preheader__2:                                     ; preds = %exit__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iter__2 = phi i64 [ 0, %preheader__2 ], [ %33, %exiting__2 ]
  %26 = icmp sge i64 %iter__2, %end__2
  %27 = icmp sle i64 %iter__2, %end__2
  %28 = select i1 true, i1 %27, i1 %26
  br i1 %28, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %29 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %state2, i64 %iter__2)
  %30 = bitcast i8* %29 to i64*
  %n = load i64, i64* %30
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %n)
  %32 = bitcast i8* %31 to %Qubit**
  %.qb7 = load %Qubit*, %Qubit** %32
  call void @__quantum__qis__x(%Qubit* %.qb7)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %33 = add i64 %iter__2, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %34 = call i64 @__quantum__rt__array_get_length(%Array* %aux, i32 0)
  %end__3 = sub i64 %34, 1
  br label %preheader__3

preheader__3:                                     ; preds = %exit__2
  br label %header__3

header__3:                                        ; preds = %exiting__3, %preheader__3
  %iter__3 = phi i64 [ 0, %preheader__3 ], [ %43, %exiting__3 ]
  %35 = icmp sge i64 %iter__3, %end__3
  %36 = icmp sle i64 %iter__3, %end__3
  %37 = select i1 true, i1 %36, i1 %35
  br i1 %37, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %aux, i64 %iter__3)
  %39 = bitcast i8* %38 to %Qubit**
  %a = load %Qubit*, %Qubit** %39
  %40 = call %Result* @__quantum__qis__mz(%Qubit* %a)
  %41 = load %Result*, %Result** @ResultOne
  %42 = call i1 @__quantum__rt__result_equal(%Result* %40, %Result* %41)
  br i1 %42, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__3
  call void @__quantum__qis__x(%Qubit* %a)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__3
  br label %exiting__3

exiting__3:                                       ; preds = %continue__1
  %43 = add i64 %iter__3, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  ret void
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__qubit_release_array(%Array*)

define double @Sample__VQE__EstimateTermExpectation__body(%Array* %state1, %Array* %state2, double %phase, %Array* %ops, double %coeff, i64 %nSamples) {
entry:
  %jwTermEnergy = alloca double
  store double 0.000000e+00, double* %jwTermEnergy
  %termExpectation = call double @Sample__VQE__EstimateFrequency__body(%Array* %state1, %Array* %state2, double %phase, %Array* %ops, i64 %nSamples)
  %0 = load double, double* %jwTermEnergy
  %1 = fmul double 2.000000e+00, %termExpectation
  %2 = fsub double %1, 1.000000e+00
  %3 = fmul double %2, %coeff
  %4 = fadd double %0, %3
  store double %4, double* %jwTermEnergy
  %5 = load double, double* %jwTermEnergy
  ret double %5
}

declare i32 @printf(i8* noalias nocapture, ...)

define double @Sample_VQE_EstimateTermExpectation(
  i64 %state1__count, i64* %state1,
  i64 %state2__count, i64* %state2,
  double %phase,
  i64 %ops__count, i2* %ops,
  double %coeff,
  i64 %nSamples) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %state1__count)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = mul i64 %state1__count, 8
  call void @llvm.memcpy.p0i8.p0i64.i64(i8* %1, i64* %state1, i64 %2, i1 false)
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %state2__count)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 0)
  %5 = mul i64 %state2__count, 8
  call void @llvm.memcpy.p0i8.p0i64.i64(i8* %4, i64* %state2, i64 %5, i1 false)
  %6 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %ops__count)
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %6, i64 0)
  %8 = mul i64 %ops__count, 1
  call void @llvm.memcpy.p0i8.p0i2.i64(i8* %7, i2* %ops, i64 %8, i1 false)
  %9 = call double @Sample__VQE__EstimateTermExpectation__body(%Array* %0, %Array* %3, double %phase, %Array* %6, double %coeff, i64 %nSamples)
  call void @__quantum__rt__array_unreference(%Array* %0)
  call void @__quantum__rt__array_unreference(%Array* %3)
  call void @__quantum__rt__array_unreference(%Array* %6)
  ret double %9
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i64.i64(i8* nocapture writeonly, i64* nocapture readonly, i64, i1) #1

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i2.i64(i8* nocapture writeonly, i2* nocapture readonly, i64, i1) #1

declare void @__quantum__rt__array_unreference(%Array*)

declare void @DebugLog(i32 %step)

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind }
