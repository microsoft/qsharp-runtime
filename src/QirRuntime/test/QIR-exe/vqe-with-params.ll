
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque
%Tuple = type opaque
%Qubit = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE = alias double (double, double, double, i64), double (double, double, double, i64)* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__TermExpectation__body({ i64, %Array* }* %inputState, %Array* %measOp, i64 %nQubits, i64 %nSamples) {
entry:
  %0 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 1
  %1 = load %Array*, %Array** %0
  %2 = call i64 @__quantum__rt__array_get_size_1d(%Array* %1)
  %3 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %4 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %5 = icmp sle i64 %4, %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %4)
  %7 = bitcast i8* %6 to { { double, double }*, %Array* }**
  %8 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %7
  %9 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %8, i32 0, i32 0
  %10 = load { double, double }*, { double, double }** %9
  %11 = bitcast { double, double }* %10 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %11, i64 1)
  %12 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %8, i32 0, i32 1
  %13 = load %Array*, %Array** %12
  call void @__quantum__rt__array_update_alias_count(%Array* %13, i64 1)
  %14 = bitcast { { double, double }*, %Array* }* %8 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %14, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %4, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %1, i64 1)
  %16 = bitcast { i64, %Array* }* %inputState to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %16, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %measOp, i64 1)
  %nUp = alloca i64
  store i64 0, i64* %nUp
  %17 = sub i64 %nSamples, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %idxMeasurement = phi i64 [ 0, %exit__1 ], [ %25, %exiting__2 ]
  %18 = icmp sle i64 %idxMeasurement, %17
  br i1 %18, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %register = call %Array* @__quantum__rt__qubit_allocate_array(i64 %nQubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  call void @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__StatePrep__PrepareTrialState__body({ i64, %Array* }* %inputState, %Array* %register)
  %result = call %Result* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__JointMeasure__body(%Array* %measOp, %Array* %register)
  %19 = load %Result*, %Result** @ResultZero
  %20 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %19)
  br i1 %20, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__2
  %21 = load i64, i64* %nUp
  %22 = add i64 %21, 1
  store i64 %22, i64* %nUp
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__2
  %23 = call i64 @__quantum__rt__array_get_size_1d(%Array* %register)
  %24 = sub i64 %23, 1
  br label %header__3

exiting__2:                                       ; preds = %exit__3
  %25 = add i64 %idxMeasurement, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %26 = load i64, i64* %nUp
  %27 = sitofp i64 %26 to double
  %28 = sitofp i64 %nSamples to double
  %29 = fdiv double %27, %28
  %30 = sub i64 %2, 1
  br label %header__4

header__3:                                        ; preds = %exiting__3, %continue__1
  %31 = phi i64 [ 0, %continue__1 ], [ %35, %exiting__3 ]
  %32 = icmp sle i64 %31, %24
  br i1 %32, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %31)
  %34 = bitcast i8* %33 to %Qubit**
  %q = load %Qubit*, %Qubit** %34
  %r = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q)
  call void @__quantum__rt__result_update_reference_count(%Result* %r, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %35 = add i64 %31, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__qubit_release_array(%Array* %register)
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %register, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %result, i64 -1)
  br label %exiting__2

header__4:                                        ; preds = %exiting__4, %exit__2
  %36 = phi i64 [ 0, %exit__2 ], [ %47, %exiting__4 ]
  %37 = icmp sle i64 %36, %30
  br i1 %37, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %36)
  %39 = bitcast i8* %38 to { { double, double }*, %Array* }**
  %40 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %39
  %41 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %40, i32 0, i32 0
  %42 = load { double, double }*, { double, double }** %41
  %43 = bitcast { double, double }* %42 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %43, i64 -1)
  %44 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %40, i32 0, i32 1
  %45 = load %Array*, %Array** %44
  call void @__quantum__rt__array_update_alias_count(%Array* %45, i64 -1)
  %46 = bitcast { { double, double }*, %Array* }* %40 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %46, i64 -1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %47 = add i64 %36, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %1, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %16, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %measOp, i64 -1)
  ret double %29
}

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

define void @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__StatePrep__PrepareTrialState__body({ i64, %Array* }* %stateData, %Array* %qubits) {
entry:
  %0 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %stateData, i32 0, i32 1
  %terms = load %Array*, %Array** %0
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %terms)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %14, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %3)
  %6 = bitcast i8* %5 to { { double, double }*, %Array* }**
  %7 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %6
  %8 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %7, i32 0, i32 0
  %9 = load { double, double }*, { double, double }** %8
  %10 = bitcast { double, double }* %9 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %10, i64 1)
  %11 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %7, i32 0, i32 1
  %12 = load %Array*, %Array** %11
  call void @__quantum__rt__array_update_alias_count(%Array* %12, i64 1)
  %13 = bitcast { { double, double }*, %Array* }* %7 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %13, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %14 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %terms, i64 1)
  %15 = bitcast { i64, %Array* }* %stateData to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %15, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %16 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %stateData, i32 0, i32 0
  %stateType = load i64, i64* %16
  %17 = sub i64 %1, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %18 = phi i64 [ 0, %exit__1 ], [ %29, %exiting__2 ]
  %19 = icmp sle i64 %18, %17
  br i1 %19, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %18)
  %21 = bitcast i8* %20 to { { double, double }*, %Array* }**
  %22 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %21
  %23 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %22, i32 0, i32 0
  %24 = load { double, double }*, { double, double }** %23
  %25 = bitcast { double, double }* %24 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %25, i64 1)
  %26 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %22, i32 0, i32 1
  %27 = load %Array*, %Array** %26
  call void @__quantum__rt__array_update_alias_count(%Array* %27, i64 1)
  %28 = bitcast { { double, double }*, %Array* }* %22 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %28, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %29 = add i64 %18, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %terms, i64 1)
  %30 = sub i64 %1, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %31 = phi i64 [ 0, %exit__2 ], [ %43, %exiting__3 ]
  %32 = icmp sle i64 %31, %30
  br i1 %32, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %31)
  %34 = bitcast i8* %33 to { { double, double }*, %Array* }**
  %term = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %34
  %35 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %term, i32 0, i32 0
  %coefficient = load { double, double }*, { double, double }** %35
  %36 = bitcast { double, double }* %coefficient to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %36, i64 1)
  %37 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %term, i32 0, i32 1
  %excitation = load %Array*, %Array** %37
  call void @__quantum__rt__array_update_alias_count(%Array* %excitation, i64 1)
  %38 = bitcast { { double, double }*, %Array* }* %term to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %38, i64 1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %36, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %excitation, i64 1)
  %39 = getelementptr inbounds { double, double }, { double, double }* %coefficient, i32 0, i32 0
  %theta = load double, double* %39
  %40 = getelementptr inbounds { double, double }, { double, double }* %coefficient, i32 0, i32 1
  %phi = load double, double* %40
  %41 = call i64 @__quantum__rt__array_get_size_1d(%Array* %excitation)
  %42 = sub i64 %41, 1
  br label %header__4

exiting__3:                                       ; preds = %continue__1
  %43 = add i64 %31, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %44 = sub i64 %1, 1
  br label %header__6

header__4:                                        ; preds = %exiting__4, %body__3
  %45 = phi i64 [ 0, %body__3 ], [ %51, %exiting__4 ]
  %46 = icmp sle i64 %45, %42
  br i1 %46, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %47 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %excitation, i64 %45)
  %48 = bitcast i8* %47 to i64*
  %i = load i64, i64* %48
  %49 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %i)
  %50 = bitcast i8* %49 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %50
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %51 = add i64 %45, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %52 = fcmp olt double %theta, 1.000000e+00
  br i1 %52, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__4
  %53 = call i64 @__quantum__rt__array_get_size_1d(%Array* %qubits)
  %54 = sub i64 %53, 1
  br label %header__5

continue__1:                                      ; preds = %exit__5, %exit__4
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %36, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %excitation, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %38, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %36, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %excitation, i64 -1)
  br label %exiting__3

header__5:                                        ; preds = %exiting__5, %then0__1
  %55 = phi i64 [ 0, %then0__1 ], [ %59, %exiting__5 ]
  %56 = icmp sle i64 %55, %54
  br i1 %56, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %57 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %55)
  %58 = bitcast i8* %57 to %Qubit**
  %qubit__1 = load %Qubit*, %Qubit** %58
  call void @__quantum__qis__s__body(%Qubit* %qubit__1)
  call void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qubit__1)
  call void @__quantum__qis__s__adj(%Qubit* %qubit__1)
  call void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qubit__1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %59 = add i64 %55, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  br label %continue__1

header__6:                                        ; preds = %exiting__6, %exit__3
  %60 = phi i64 [ 0, %exit__3 ], [ %71, %exiting__6 ]
  %61 = icmp sle i64 %60, %44
  br i1 %61, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %60)
  %63 = bitcast i8* %62 to { { double, double }*, %Array* }**
  %64 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %63
  %65 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %64, i32 0, i32 0
  %66 = load { double, double }*, { double, double }** %65
  %67 = bitcast { double, double }* %66 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %67, i64 -1)
  %68 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %64, i32 0, i32 1
  %69 = load %Array*, %Array** %68
  call void @__quantum__rt__array_update_alias_count(%Array* %69, i64 -1)
  %70 = bitcast { { double, double }*, %Array* }* %64 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %70, i64 -1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %71 = add i64 %60, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_alias_count(%Array* %terms, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %15, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  %72 = sub i64 %1, 1
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %73 = phi i64 [ 0, %exit__6 ], [ %84, %exiting__7 ]
  %74 = icmp sle i64 %73, %72
  br i1 %74, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %73)
  %76 = bitcast i8* %75 to { { double, double }*, %Array* }**
  %77 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %76
  %78 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %77, i32 0, i32 0
  %79 = load { double, double }*, { double, double }** %78
  %80 = bitcast { double, double }* %79 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %80, i64 -1)
  %81 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %77, i32 0, i32 1
  %82 = load %Array*, %Array** %81
  call void @__quantum__rt__array_update_alias_count(%Array* %82, i64 -1)
  %83 = bitcast { { double, double }*, %Array* }* %77 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %83, i64 -1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %84 = add i64 %73, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  call void @__quantum__rt__array_update_alias_count(%Array* %terms, i64 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__JointMeasure__body(%Array* %ops, %Array* %qbs) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ops, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qbs, i64 1)
  %aux = call %Qubit* @__quantum__rt__qubit_allocate()
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %qbs)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %13, %exiting__1 ]
  %2 = icmp sle i64 %i, %1
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %i)
  %4 = bitcast i8* %3 to i2*
  %op = load i2, i2* %4
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qbs, i64 %i)
  %6 = bitcast i8* %5 to %Qubit**
  %qb = load %Qubit*, %Qubit** %6
  %7 = load i2, i2* @PauliX
  %8 = icmp eq i2 %op, %7
  br i1 %8, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__qis__h__body(%Qubit* %qb)
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %qb, %Qubit* %aux)
  call void @__quantum__qis__h__body(%Qubit* %qb)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %9 = load i2, i2* @PauliY
  %10 = icmp eq i2 %op, %9
  br i1 %10, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__s__body(%Qubit* %qb)
  call void @__quantum__qis__h__body(%Qubit* %qb)
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %qb, %Qubit* %aux)
  call void @__quantum__qis__h__body(%Qubit* %qb)
  call void @__quantum__qis__s__body(%Qubit* %qb)
  call void @__quantum__qis__z__body(%Qubit* %qb)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %11 = load i2, i2* @PauliZ
  %12 = icmp eq i2 %op, %11
  br i1 %12, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %qb, %Qubit* %aux)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %13 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %14 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %aux)
  call void @__quantum__rt__qubit_release(%Qubit* %aux)
  call void @__quantum__rt__array_update_alias_count(%Array* %ops, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qbs, i64 -1)
  ret %Result* %14
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qubit) {
entry:
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliZ
  store i2 %2, i2* %1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %qubit, %Qubit** %4
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  ret %Result* %5
}

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__SumTermExpectation__body({ i64, %Array* }* %inputState, %Array* %ops, %Array* %coeffs, i64 %nQubits, i64 %nSamples) {
entry:
  %0 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 1
  %1 = load %Array*, %Array** %0
  %2 = call i64 @__quantum__rt__array_get_size_1d(%Array* %1)
  %3 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %4 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %5 = icmp sle i64 %4, %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %4)
  %7 = bitcast i8* %6 to { { double, double }*, %Array* }**
  %8 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %7
  %9 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %8, i32 0, i32 0
  %10 = load { double, double }*, { double, double }** %9
  %11 = bitcast { double, double }* %10 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %11, i64 1)
  %12 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %8, i32 0, i32 1
  %13 = load %Array*, %Array** %12
  call void @__quantum__rt__array_update_alias_count(%Array* %13, i64 1)
  %14 = bitcast { { double, double }*, %Array* }* %8 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %14, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %4, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %1, i64 1)
  %16 = bitcast { i64, %Array* }* %inputState to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %16, i64 1)
  %17 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ops)
  %18 = sub i64 %17, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %19 = phi i64 [ 0, %exit__1 ], [ %24, %exiting__2 ]
  %20 = icmp sle i64 %19, %18
  br i1 %20, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %19)
  %22 = bitcast i8* %21 to %Array**
  %23 = load %Array*, %Array** %22
  call void @__quantum__rt__array_update_alias_count(%Array* %23, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %24 = add i64 %19, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %ops, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coeffs, i64 1)
  %jwTermEnergy = alloca double
  store double 0.000000e+00, double* %jwTermEnergy
  %25 = call i64 @__quantum__rt__array_get_size_1d(%Array* %coeffs)
  %26 = sub i64 %25, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %i = phi i64 [ 0, %exit__2 ], [ %40, %exiting__3 ]
  %27 = icmp sle i64 %i, %26
  br i1 %27, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeffs, i64 %i)
  %29 = bitcast i8* %28 to double*
  %coeff = load double, double* %29
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %i)
  %31 = bitcast i8* %30 to %Array**
  %op = load %Array*, %Array** %31
  call void @__quantum__rt__array_update_alias_count(%Array* %op, i64 1)
  %32 = fcmp oge double %coeff, 1.000000e-10
  %33 = fcmp ole double %coeff, -1.000000e-10
  %34 = or i1 %32, %33
  br i1 %34, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__3
  %termExpectation = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__TermExpectation__body({ i64, %Array* }* %inputState, %Array* %op, i64 %nQubits, i64 %nSamples)
  %35 = load double, double* %jwTermEnergy
  %36 = fmul double 2.000000e+00, %termExpectation
  %37 = fsub double %36, 1.000000e+00
  %38 = fmul double %37, %coeff
  %39 = fadd double %35, %38
  store double %39, double* %jwTermEnergy
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__3
  call void @__quantum__rt__array_update_alias_count(%Array* %op, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %continue__1
  %40 = add i64 %i, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %41 = load double, double* %jwTermEnergy
  %42 = sub i64 %2, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %43 = phi i64 [ 0, %exit__3 ], [ %54, %exiting__4 ]
  %44 = icmp sle i64 %43, %42
  br i1 %44, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %45 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %43)
  %46 = bitcast i8* %45 to { { double, double }*, %Array* }**
  %47 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %46
  %48 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %47, i32 0, i32 0
  %49 = load { double, double }*, { double, double }** %48
  %50 = bitcast { double, double }* %49 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %50, i64 -1)
  %51 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %47, i32 0, i32 1
  %52 = load %Array*, %Array** %51
  call void @__quantum__rt__array_update_alias_count(%Array* %52, i64 -1)
  %53 = bitcast { { double, double }*, %Array* }* %47 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %53, i64 -1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %54 = add i64 %43, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %1, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %16, i64 -1)
  %55 = sub i64 %17, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %56 = phi i64 [ 0, %exit__4 ], [ %61, %exiting__5 ]
  %57 = icmp sle i64 %56, %55
  br i1 %57, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %56)
  %59 = bitcast i8* %58 to %Array**
  %60 = load %Array*, %Array** %59
  call void @__quantum__rt__array_update_alias_count(%Array* %60, i64 -1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %61 = add i64 %56, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_alias_count(%Array* %ops, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coeffs, i64 -1)
  ret double %41
}

declare void @__quantum__qis__h__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %__controlQubits__ = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__controlQubits__, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__body(%Qubit*)

declare void @__quantum__qis__z__body(%Qubit*)

declare void @__quantum__rt__qubit_release(%Qubit*)

define { %Array*, %Array*, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JWOptimizedHTerms__body(%Array* %__Item1__, %Array* %__Item2__, %Array* %__Item3__, %Array* %__Item4__) {
entry:
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item1__)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %12, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item1__, i64 %2)
  %5 = bitcast i8* %4 to { %Array*, %Array* }**
  %6 = load { %Array*, %Array* }*, { %Array*, %Array* }** %5
  %7 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %6, i32 0, i32 0
  %8 = load %Array*, %Array** %7
  call void @__quantum__rt__array_update_alias_count(%Array* %8, i64 1)
  %9 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %6, i32 0, i32 1
  %10 = load %Array*, %Array** %9
  call void @__quantum__rt__array_update_alias_count(%Array* %10, i64 1)
  %11 = bitcast { %Array*, %Array* }* %6 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %11, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %12 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item1__, i64 1)
  %13 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item2__)
  %14 = sub i64 %13, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %15 = phi i64 [ 0, %exit__1 ], [ %25, %exiting__2 ]
  %16 = icmp sle i64 %15, %14
  br i1 %16, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item2__, i64 %15)
  %18 = bitcast i8* %17 to { %Array*, %Array* }**
  %19 = load { %Array*, %Array* }*, { %Array*, %Array* }** %18
  %20 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %19, i32 0, i32 0
  %21 = load %Array*, %Array** %20
  call void @__quantum__rt__array_update_alias_count(%Array* %21, i64 1)
  %22 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %19, i32 0, i32 1
  %23 = load %Array*, %Array** %22
  call void @__quantum__rt__array_update_alias_count(%Array* %23, i64 1)
  %24 = bitcast { %Array*, %Array* }* %19 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %24, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %25 = add i64 %15, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item2__, i64 1)
  %26 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item3__)
  %27 = sub i64 %26, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %28 = phi i64 [ 0, %exit__2 ], [ %38, %exiting__3 ]
  %29 = icmp sle i64 %28, %27
  br i1 %29, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item3__, i64 %28)
  %31 = bitcast i8* %30 to { %Array*, %Array* }**
  %32 = load { %Array*, %Array* }*, { %Array*, %Array* }** %31
  %33 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %32, i32 0, i32 0
  %34 = load %Array*, %Array** %33
  call void @__quantum__rt__array_update_alias_count(%Array* %34, i64 1)
  %35 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %32, i32 0, i32 1
  %36 = load %Array*, %Array** %35
  call void @__quantum__rt__array_update_alias_count(%Array* %36, i64 1)
  %37 = bitcast { %Array*, %Array* }* %32 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %37, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %38 = add i64 %28, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item3__, i64 1)
  %39 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item4__)
  %40 = sub i64 %39, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %41 = phi i64 [ 0, %exit__3 ], [ %51, %exiting__4 ]
  %42 = icmp sle i64 %41, %40
  br i1 %42, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %43 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item4__, i64 %41)
  %44 = bitcast i8* %43 to { %Array*, %Array* }**
  %45 = load { %Array*, %Array* }*, { %Array*, %Array* }** %44
  %46 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %45, i32 0, i32 0
  %47 = load %Array*, %Array** %46
  call void @__quantum__rt__array_update_alias_count(%Array* %47, i64 1)
  %48 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %45, i32 0, i32 1
  %49 = load %Array*, %Array** %48
  call void @__quantum__rt__array_update_alias_count(%Array* %49, i64 1)
  %50 = bitcast { %Array*, %Array* }* %45 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %50, i64 1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %51 = add i64 %41, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item4__, i64 1)
  %52 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 4))
  %53 = bitcast %Tuple* %52 to { %Array*, %Array*, %Array*, %Array* }*
  %54 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %53, i32 0, i32 0
  %55 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %53, i32 0, i32 1
  %56 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %53, i32 0, i32 2
  %57 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %53, i32 0, i32 3
  store %Array* %__Item1__, %Array** %54
  store %Array* %__Item2__, %Array** %55
  store %Array* %__Item3__, %Array** %56
  store %Array* %__Item4__, %Array** %57
  %58 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item1__)
  %59 = sub i64 %58, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %60 = phi i64 [ 0, %exit__4 ], [ %70, %exiting__5 ]
  %61 = icmp sle i64 %60, %59
  br i1 %61, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item1__, i64 %60)
  %63 = bitcast i8* %62 to { %Array*, %Array* }**
  %64 = load { %Array*, %Array* }*, { %Array*, %Array* }** %63
  %65 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %64, i32 0, i32 0
  %66 = load %Array*, %Array** %65
  call void @__quantum__rt__array_update_reference_count(%Array* %66, i64 1)
  %67 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %64, i32 0, i32 1
  %68 = load %Array*, %Array** %67
  call void @__quantum__rt__array_update_reference_count(%Array* %68, i64 1)
  %69 = bitcast { %Array*, %Array* }* %64 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %69, i64 1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %70 = add i64 %60, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item1__, i64 1)
  %71 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item2__)
  %72 = sub i64 %71, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %73 = phi i64 [ 0, %exit__5 ], [ %83, %exiting__6 ]
  %74 = icmp sle i64 %73, %72
  br i1 %74, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item2__, i64 %73)
  %76 = bitcast i8* %75 to { %Array*, %Array* }**
  %77 = load { %Array*, %Array* }*, { %Array*, %Array* }** %76
  %78 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %77, i32 0, i32 0
  %79 = load %Array*, %Array** %78
  call void @__quantum__rt__array_update_reference_count(%Array* %79, i64 1)
  %80 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %77, i32 0, i32 1
  %81 = load %Array*, %Array** %80
  call void @__quantum__rt__array_update_reference_count(%Array* %81, i64 1)
  %82 = bitcast { %Array*, %Array* }* %77 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %82, i64 1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %83 = add i64 %73, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item2__, i64 1)
  %84 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item3__)
  %85 = sub i64 %84, 1
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %86 = phi i64 [ 0, %exit__6 ], [ %96, %exiting__7 ]
  %87 = icmp sle i64 %86, %85
  br i1 %87, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item3__, i64 %86)
  %89 = bitcast i8* %88 to { %Array*, %Array* }**
  %90 = load { %Array*, %Array* }*, { %Array*, %Array* }** %89
  %91 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %90, i32 0, i32 0
  %92 = load %Array*, %Array** %91
  call void @__quantum__rt__array_update_reference_count(%Array* %92, i64 1)
  %93 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %90, i32 0, i32 1
  %94 = load %Array*, %Array** %93
  call void @__quantum__rt__array_update_reference_count(%Array* %94, i64 1)
  %95 = bitcast { %Array*, %Array* }* %90 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %95, i64 1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %96 = add i64 %86, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item3__, i64 1)
  %97 = call i64 @__quantum__rt__array_get_size_1d(%Array* %__Item4__)
  %98 = sub i64 %97, 1
  br label %header__8

header__8:                                        ; preds = %exiting__8, %exit__7
  %99 = phi i64 [ 0, %exit__7 ], [ %109, %exiting__8 ]
  %100 = icmp sle i64 %99, %98
  br i1 %100, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %101 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item4__, i64 %99)
  %102 = bitcast i8* %101 to { %Array*, %Array* }**
  %103 = load { %Array*, %Array* }*, { %Array*, %Array* }** %102
  %104 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %103, i32 0, i32 0
  %105 = load %Array*, %Array** %104
  call void @__quantum__rt__array_update_reference_count(%Array* %105, i64 1)
  %106 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %103, i32 0, i32 1
  %107 = load %Array*, %Array** %106
  call void @__quantum__rt__array_update_reference_count(%Array* %107, i64 1)
  %108 = bitcast { %Array*, %Array* }* %103 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %108, i64 1)
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %109 = add i64 %99, 1
  br label %header__8

exit__8:                                          ; preds = %header__8
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item4__, i64 1)
  %110 = sub i64 %0, 1
  br label %header__9

header__9:                                        ; preds = %exiting__9, %exit__8
  %111 = phi i64 [ 0, %exit__8 ], [ %121, %exiting__9 ]
  %112 = icmp sle i64 %111, %110
  br i1 %112, label %body__9, label %exit__9

body__9:                                          ; preds = %header__9
  %113 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item1__, i64 %111)
  %114 = bitcast i8* %113 to { %Array*, %Array* }**
  %115 = load { %Array*, %Array* }*, { %Array*, %Array* }** %114
  %116 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %115, i32 0, i32 0
  %117 = load %Array*, %Array** %116
  call void @__quantum__rt__array_update_alias_count(%Array* %117, i64 -1)
  %118 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %115, i32 0, i32 1
  %119 = load %Array*, %Array** %118
  call void @__quantum__rt__array_update_alias_count(%Array* %119, i64 -1)
  %120 = bitcast { %Array*, %Array* }* %115 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %120, i64 -1)
  br label %exiting__9

exiting__9:                                       ; preds = %body__9
  %121 = add i64 %111, 1
  br label %header__9

exit__9:                                          ; preds = %header__9
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item1__, i64 -1)
  %122 = sub i64 %13, 1
  br label %header__10

header__10:                                       ; preds = %exiting__10, %exit__9
  %123 = phi i64 [ 0, %exit__9 ], [ %133, %exiting__10 ]
  %124 = icmp sle i64 %123, %122
  br i1 %124, label %body__10, label %exit__10

body__10:                                         ; preds = %header__10
  %125 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item2__, i64 %123)
  %126 = bitcast i8* %125 to { %Array*, %Array* }**
  %127 = load { %Array*, %Array* }*, { %Array*, %Array* }** %126
  %128 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %127, i32 0, i32 0
  %129 = load %Array*, %Array** %128
  call void @__quantum__rt__array_update_alias_count(%Array* %129, i64 -1)
  %130 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %127, i32 0, i32 1
  %131 = load %Array*, %Array** %130
  call void @__quantum__rt__array_update_alias_count(%Array* %131, i64 -1)
  %132 = bitcast { %Array*, %Array* }* %127 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %132, i64 -1)
  br label %exiting__10

exiting__10:                                      ; preds = %body__10
  %133 = add i64 %123, 1
  br label %header__10

exit__10:                                         ; preds = %header__10
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item2__, i64 -1)
  %134 = sub i64 %26, 1
  br label %header__11

header__11:                                       ; preds = %exiting__11, %exit__10
  %135 = phi i64 [ 0, %exit__10 ], [ %145, %exiting__11 ]
  %136 = icmp sle i64 %135, %134
  br i1 %136, label %body__11, label %exit__11

body__11:                                         ; preds = %header__11
  %137 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item3__, i64 %135)
  %138 = bitcast i8* %137 to { %Array*, %Array* }**
  %139 = load { %Array*, %Array* }*, { %Array*, %Array* }** %138
  %140 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %139, i32 0, i32 0
  %141 = load %Array*, %Array** %140
  call void @__quantum__rt__array_update_alias_count(%Array* %141, i64 -1)
  %142 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %139, i32 0, i32 1
  %143 = load %Array*, %Array** %142
  call void @__quantum__rt__array_update_alias_count(%Array* %143, i64 -1)
  %144 = bitcast { %Array*, %Array* }* %139 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %144, i64 -1)
  br label %exiting__11

exiting__11:                                      ; preds = %body__11
  %145 = add i64 %135, 1
  br label %header__11

exit__11:                                         ; preds = %header__11
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item3__, i64 -1)
  %146 = sub i64 %39, 1
  br label %header__12

header__12:                                       ; preds = %exiting__12, %exit__11
  %147 = phi i64 [ 0, %exit__11 ], [ %157, %exiting__12 ]
  %148 = icmp sle i64 %147, %146
  br i1 %148, label %body__12, label %exit__12

body__12:                                         ; preds = %header__12
  %149 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %__Item4__, i64 %147)
  %150 = bitcast i8* %149 to { %Array*, %Array* }**
  %151 = load { %Array*, %Array* }*, { %Array*, %Array* }** %150
  %152 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %151, i32 0, i32 0
  %153 = load %Array*, %Array** %152
  call void @__quantum__rt__array_update_alias_count(%Array* %153, i64 -1)
  %154 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %151, i32 0, i32 1
  %155 = load %Array*, %Array** %154
  call void @__quantum__rt__array_update_alias_count(%Array* %155, i64 -1)
  %156 = bitcast { %Array*, %Array* }* %151 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %156, i64 -1)
  br label %exiting__12

exiting__12:                                      ; preds = %body__12
  %157 = add i64 %147, 1
  br label %header__12

exit__12:                                         ; preds = %header__12
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item4__, i64 -1)
  ret { %Array*, %Array*, %Array*, %Array* }* %53
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

define { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerEncodingData__body(i64 %__Item1__, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, { i64, %Array* }* %0, double %__Item5__) {
entry:
  %1 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 0
  %2 = load %Array*, %Array** %1
  %3 = call i64 @__quantum__rt__array_get_size_1d(%Array* %2)
  %4 = sub i64 %3, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %5 = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %6 = icmp sle i64 %5, %4
  br i1 %6, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %2, i64 %5)
  %8 = bitcast i8* %7 to { %Array*, %Array* }**
  %9 = load { %Array*, %Array* }*, { %Array*, %Array* }** %8
  %10 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %9, i32 0, i32 0
  %11 = load %Array*, %Array** %10
  call void @__quantum__rt__array_update_alias_count(%Array* %11, i64 1)
  %12 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %9, i32 0, i32 1
  %13 = load %Array*, %Array** %12
  call void @__quantum__rt__array_update_alias_count(%Array* %13, i64 1)
  %14 = bitcast { %Array*, %Array* }* %9 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %14, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %5, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %2, i64 1)
  %16 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 1
  %17 = load %Array*, %Array** %16
  %18 = call i64 @__quantum__rt__array_get_size_1d(%Array* %17)
  %19 = sub i64 %18, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %20 = phi i64 [ 0, %exit__1 ], [ %30, %exiting__2 ]
  %21 = icmp sle i64 %20, %19
  br i1 %21, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %17, i64 %20)
  %23 = bitcast i8* %22 to { %Array*, %Array* }**
  %24 = load { %Array*, %Array* }*, { %Array*, %Array* }** %23
  %25 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %24, i32 0, i32 0
  %26 = load %Array*, %Array** %25
  call void @__quantum__rt__array_update_alias_count(%Array* %26, i64 1)
  %27 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %24, i32 0, i32 1
  %28 = load %Array*, %Array** %27
  call void @__quantum__rt__array_update_alias_count(%Array* %28, i64 1)
  %29 = bitcast { %Array*, %Array* }* %24 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %29, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %30 = add i64 %20, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %17, i64 1)
  %31 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 2
  %32 = load %Array*, %Array** %31
  %33 = call i64 @__quantum__rt__array_get_size_1d(%Array* %32)
  %34 = sub i64 %33, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %35 = phi i64 [ 0, %exit__2 ], [ %45, %exiting__3 ]
  %36 = icmp sle i64 %35, %34
  br i1 %36, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %32, i64 %35)
  %38 = bitcast i8* %37 to { %Array*, %Array* }**
  %39 = load { %Array*, %Array* }*, { %Array*, %Array* }** %38
  %40 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %39, i32 0, i32 0
  %41 = load %Array*, %Array** %40
  call void @__quantum__rt__array_update_alias_count(%Array* %41, i64 1)
  %42 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %39, i32 0, i32 1
  %43 = load %Array*, %Array** %42
  call void @__quantum__rt__array_update_alias_count(%Array* %43, i64 1)
  %44 = bitcast { %Array*, %Array* }* %39 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %44, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %45 = add i64 %35, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %32, i64 1)
  %46 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 3
  %47 = load %Array*, %Array** %46
  %48 = call i64 @__quantum__rt__array_get_size_1d(%Array* %47)
  %49 = sub i64 %48, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %50 = phi i64 [ 0, %exit__3 ], [ %60, %exiting__4 ]
  %51 = icmp sle i64 %50, %49
  br i1 %51, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 %50)
  %53 = bitcast i8* %52 to { %Array*, %Array* }**
  %54 = load { %Array*, %Array* }*, { %Array*, %Array* }** %53
  %55 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %54, i32 0, i32 0
  %56 = load %Array*, %Array** %55
  call void @__quantum__rt__array_update_alias_count(%Array* %56, i64 1)
  %57 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %54, i32 0, i32 1
  %58 = load %Array*, %Array** %57
  call void @__quantum__rt__array_update_alias_count(%Array* %58, i64 1)
  %59 = bitcast { %Array*, %Array* }* %54 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %59, i64 1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %60 = add i64 %50, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %47, i64 1)
  %61 = bitcast { %Array*, %Array*, %Array*, %Array* }* %__Item2__ to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %61, i64 1)
  %62 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* getelementptr ({ i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* null, i32 1) to i64))
  %63 = bitcast %Tuple* %62 to { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }*
  %64 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %63, i32 0, i32 0
  %65 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %63, i32 0, i32 1
  %66 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %63, i32 0, i32 2
  %67 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %63, i32 0, i32 3
  store i64 %__Item1__, i64* %64
  store { %Array*, %Array*, %Array*, %Array* }* %__Item2__, { %Array*, %Array*, %Array*, %Array* }** %65
  store { i64, %Array* }* %0, { i64, %Array* }** %66
  store double %__Item5__, double* %67
  %68 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 0
  %69 = load %Array*, %Array** %68
  %70 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 1
  %71 = load %Array*, %Array** %70
  %72 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 2
  %73 = load %Array*, %Array** %72
  %74 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %__Item2__, i32 0, i32 3
  %75 = load %Array*, %Array** %74
  %76 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %0, i32 0, i32 1
  %77 = load %Array*, %Array** %76
  %78 = call i64 @__quantum__rt__array_get_size_1d(%Array* %69)
  %79 = sub i64 %78, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %80 = phi i64 [ 0, %exit__4 ], [ %90, %exiting__5 ]
  %81 = icmp sle i64 %80, %79
  br i1 %81, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %69, i64 %80)
  %83 = bitcast i8* %82 to { %Array*, %Array* }**
  %84 = load { %Array*, %Array* }*, { %Array*, %Array* }** %83
  %85 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %84, i32 0, i32 0
  %86 = load %Array*, %Array** %85
  call void @__quantum__rt__array_update_reference_count(%Array* %86, i64 1)
  %87 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %84, i32 0, i32 1
  %88 = load %Array*, %Array** %87
  call void @__quantum__rt__array_update_reference_count(%Array* %88, i64 1)
  %89 = bitcast { %Array*, %Array* }* %84 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %89, i64 1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %90 = add i64 %80, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_reference_count(%Array* %69, i64 1)
  %91 = call i64 @__quantum__rt__array_get_size_1d(%Array* %71)
  %92 = sub i64 %91, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %93 = phi i64 [ 0, %exit__5 ], [ %103, %exiting__6 ]
  %94 = icmp sle i64 %93, %92
  br i1 %94, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %95 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %71, i64 %93)
  %96 = bitcast i8* %95 to { %Array*, %Array* }**
  %97 = load { %Array*, %Array* }*, { %Array*, %Array* }** %96
  %98 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %97, i32 0, i32 0
  %99 = load %Array*, %Array** %98
  call void @__quantum__rt__array_update_reference_count(%Array* %99, i64 1)
  %100 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %97, i32 0, i32 1
  %101 = load %Array*, %Array** %100
  call void @__quantum__rt__array_update_reference_count(%Array* %101, i64 1)
  %102 = bitcast { %Array*, %Array* }* %97 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %102, i64 1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %103 = add i64 %93, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_reference_count(%Array* %71, i64 1)
  %104 = call i64 @__quantum__rt__array_get_size_1d(%Array* %73)
  %105 = sub i64 %104, 1
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %106 = phi i64 [ 0, %exit__6 ], [ %116, %exiting__7 ]
  %107 = icmp sle i64 %106, %105
  br i1 %107, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %108 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 %106)
  %109 = bitcast i8* %108 to { %Array*, %Array* }**
  %110 = load { %Array*, %Array* }*, { %Array*, %Array* }** %109
  %111 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %110, i32 0, i32 0
  %112 = load %Array*, %Array** %111
  call void @__quantum__rt__array_update_reference_count(%Array* %112, i64 1)
  %113 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %110, i32 0, i32 1
  %114 = load %Array*, %Array** %113
  call void @__quantum__rt__array_update_reference_count(%Array* %114, i64 1)
  %115 = bitcast { %Array*, %Array* }* %110 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %115, i64 1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %116 = add i64 %106, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  call void @__quantum__rt__array_update_reference_count(%Array* %73, i64 1)
  %117 = call i64 @__quantum__rt__array_get_size_1d(%Array* %75)
  %118 = sub i64 %117, 1
  br label %header__8

header__8:                                        ; preds = %exiting__8, %exit__7
  %119 = phi i64 [ 0, %exit__7 ], [ %129, %exiting__8 ]
  %120 = icmp sle i64 %119, %118
  br i1 %120, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %121 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %75, i64 %119)
  %122 = bitcast i8* %121 to { %Array*, %Array* }**
  %123 = load { %Array*, %Array* }*, { %Array*, %Array* }** %122
  %124 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %123, i32 0, i32 0
  %125 = load %Array*, %Array** %124
  call void @__quantum__rt__array_update_reference_count(%Array* %125, i64 1)
  %126 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %123, i32 0, i32 1
  %127 = load %Array*, %Array** %126
  call void @__quantum__rt__array_update_reference_count(%Array* %127, i64 1)
  %128 = bitcast { %Array*, %Array* }* %123 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %128, i64 1)
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %129 = add i64 %119, 1
  br label %header__8

exit__8:                                          ; preds = %header__8
  call void @__quantum__rt__array_update_reference_count(%Array* %75, i64 1)
  %130 = bitcast { %Array*, %Array*, %Array*, %Array* }* %__Item2__ to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %130, i64 1)
  %131 = call i64 @__quantum__rt__array_get_size_1d(%Array* %77)
  %132 = sub i64 %131, 1
  br label %header__9

header__9:                                        ; preds = %exiting__9, %exit__8
  %133 = phi i64 [ 0, %exit__8 ], [ %144, %exiting__9 ]
  %134 = icmp sle i64 %133, %132
  br i1 %134, label %body__9, label %exit__9

body__9:                                          ; preds = %header__9
  %135 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %77, i64 %133)
  %136 = bitcast i8* %135 to { { double, double }*, %Array* }**
  %137 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %136
  %138 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %137, i32 0, i32 0
  %139 = load { double, double }*, { double, double }** %138
  %140 = bitcast { double, double }* %139 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %140, i64 1)
  %141 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %137, i32 0, i32 1
  %142 = load %Array*, %Array** %141
  call void @__quantum__rt__array_update_reference_count(%Array* %142, i64 1)
  %143 = bitcast { { double, double }*, %Array* }* %137 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %143, i64 1)
  br label %exiting__9

exiting__9:                                       ; preds = %body__9
  %144 = add i64 %133, 1
  br label %header__9

exit__9:                                          ; preds = %header__9
  call void @__quantum__rt__array_update_reference_count(%Array* %77, i64 1)
  %145 = bitcast { i64, %Array* }* %0 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %145, i64 1)
  %146 = sub i64 %3, 1
  br label %header__10

header__10:                                       ; preds = %exiting__10, %exit__9
  %147 = phi i64 [ 0, %exit__9 ], [ %157, %exiting__10 ]
  %148 = icmp sle i64 %147, %146
  br i1 %148, label %body__10, label %exit__10

body__10:                                         ; preds = %header__10
  %149 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %2, i64 %147)
  %150 = bitcast i8* %149 to { %Array*, %Array* }**
  %151 = load { %Array*, %Array* }*, { %Array*, %Array* }** %150
  %152 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %151, i32 0, i32 0
  %153 = load %Array*, %Array** %152
  call void @__quantum__rt__array_update_alias_count(%Array* %153, i64 -1)
  %154 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %151, i32 0, i32 1
  %155 = load %Array*, %Array** %154
  call void @__quantum__rt__array_update_alias_count(%Array* %155, i64 -1)
  %156 = bitcast { %Array*, %Array* }* %151 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %156, i64 -1)
  br label %exiting__10

exiting__10:                                      ; preds = %body__10
  %157 = add i64 %147, 1
  br label %header__10

exit__10:                                         ; preds = %header__10
  call void @__quantum__rt__array_update_alias_count(%Array* %2, i64 -1)
  %158 = sub i64 %18, 1
  br label %header__11

header__11:                                       ; preds = %exiting__11, %exit__10
  %159 = phi i64 [ 0, %exit__10 ], [ %169, %exiting__11 ]
  %160 = icmp sle i64 %159, %158
  br i1 %160, label %body__11, label %exit__11

body__11:                                         ; preds = %header__11
  %161 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %17, i64 %159)
  %162 = bitcast i8* %161 to { %Array*, %Array* }**
  %163 = load { %Array*, %Array* }*, { %Array*, %Array* }** %162
  %164 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %163, i32 0, i32 0
  %165 = load %Array*, %Array** %164
  call void @__quantum__rt__array_update_alias_count(%Array* %165, i64 -1)
  %166 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %163, i32 0, i32 1
  %167 = load %Array*, %Array** %166
  call void @__quantum__rt__array_update_alias_count(%Array* %167, i64 -1)
  %168 = bitcast { %Array*, %Array* }* %163 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %168, i64 -1)
  br label %exiting__11

exiting__11:                                      ; preds = %body__11
  %169 = add i64 %159, 1
  br label %header__11

exit__11:                                         ; preds = %header__11
  call void @__quantum__rt__array_update_alias_count(%Array* %17, i64 -1)
  %170 = sub i64 %33, 1
  br label %header__12

header__12:                                       ; preds = %exiting__12, %exit__11
  %171 = phi i64 [ 0, %exit__11 ], [ %181, %exiting__12 ]
  %172 = icmp sle i64 %171, %170
  br i1 %172, label %body__12, label %exit__12

body__12:                                         ; preds = %header__12
  %173 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %32, i64 %171)
  %174 = bitcast i8* %173 to { %Array*, %Array* }**
  %175 = load { %Array*, %Array* }*, { %Array*, %Array* }** %174
  %176 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %175, i32 0, i32 0
  %177 = load %Array*, %Array** %176
  call void @__quantum__rt__array_update_alias_count(%Array* %177, i64 -1)
  %178 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %175, i32 0, i32 1
  %179 = load %Array*, %Array** %178
  call void @__quantum__rt__array_update_alias_count(%Array* %179, i64 -1)
  %180 = bitcast { %Array*, %Array* }* %175 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %180, i64 -1)
  br label %exiting__12

exiting__12:                                      ; preds = %body__12
  %181 = add i64 %171, 1
  br label %header__12

exit__12:                                         ; preds = %header__12
  call void @__quantum__rt__array_update_alias_count(%Array* %32, i64 -1)
  %182 = sub i64 %48, 1
  br label %header__13

header__13:                                       ; preds = %exiting__13, %exit__12
  %183 = phi i64 [ 0, %exit__12 ], [ %193, %exiting__13 ]
  %184 = icmp sle i64 %183, %182
  br i1 %184, label %body__13, label %exit__13

body__13:                                         ; preds = %header__13
  %185 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 %183)
  %186 = bitcast i8* %185 to { %Array*, %Array* }**
  %187 = load { %Array*, %Array* }*, { %Array*, %Array* }** %186
  %188 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %187, i32 0, i32 0
  %189 = load %Array*, %Array** %188
  call void @__quantum__rt__array_update_alias_count(%Array* %189, i64 -1)
  %190 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %187, i32 0, i32 1
  %191 = load %Array*, %Array** %190
  call void @__quantum__rt__array_update_alias_count(%Array* %191, i64 -1)
  %192 = bitcast { %Array*, %Array* }* %187 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %192, i64 -1)
  br label %exiting__13

exiting__13:                                      ; preds = %body__13
  %193 = add i64 %183, 1
  br label %header__13

exit__13:                                         ; preds = %header__13
  call void @__quantum__rt__array_update_alias_count(%Array* %47, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %61, i64 -1)
  ret { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %63
}

define { { double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ double, double }* %0, %Array* %__Item3__) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item3__, i64 1)
  %1 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %2 = bitcast %Tuple* %1 to { { double, double }*, %Array* }*
  %3 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %2, i32 0, i32 0
  %4 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %2, i32 0, i32 1
  store { double, double }* %0, { double, double }** %3
  store %Array* %__Item3__, %Array** %4
  %5 = bitcast { double, double }* %0 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item3__, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item3__, i64 -1)
  ret { { double, double }*, %Array* }* %2
}

declare void @__quantum__qis__x__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliX
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__s__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliZ
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

define %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__VQEMeasurementOperators__body(i64 %nQubits, %Array* %indices, i64 %termType) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %indices, i64 1)
  %nOps = alloca i64
  store i64 0, i64* %nOps
  %0 = icmp eq i64 %termType, 2
  br i1 %0, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  store i64 2, i64* %nOps
  br label %continue__1

test1__1:                                         ; preds = %entry
  %1 = icmp eq i64 %termType, 3
  br i1 %1, label %then1__1, label %else__1

then1__1:                                         ; preds = %test1__1
  store i64 8, i64* %nOps
  br label %continue__1

else__1:                                          ; preds = %test1__1
  store i64 1, i64* %nOps
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then1__1, %then0__1
  %2 = load i64, i64* %nOps
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %2)
  %4 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %continue__1
  %5 = phi i64 [ 0, %continue__1 ], [ %10, %exiting__1 ]
  %6 = icmp sle i64 %5, %4
  br i1 %6, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %7 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 0)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %5)
  %9 = bitcast i8* %8 to %Array**
  store %Array* %7, %Array** %9
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %10 = add i64 %5, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %ops = alloca %Array*
  store %Array* %3, %Array** %ops
  %11 = sub i64 %2, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %12 = phi i64 [ 0, %exit__1 ], [ %17, %exiting__2 ]
  %13 = icmp sle i64 %12, %11
  br i1 %13, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %12)
  %15 = bitcast i8* %14 to %Array**
  %16 = load %Array*, %Array** %15
  call void @__quantum__rt__array_update_alias_count(%Array* %16, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %17 = add i64 %12, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %3, i64 1)
  %18 = sub i64 %2, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %19 = phi i64 [ 0, %exit__2 ], [ %24, %exiting__3 ]
  %20 = icmp sle i64 %19, %18
  br i1 %20, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %19)
  %22 = bitcast i8* %21 to %Array**
  %23 = load %Array*, %Array** %22
  call void @__quantum__rt__array_update_reference_count(%Array* %23, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %24 = add i64 %19, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 1)
  %25 = icmp eq i64 %termType, 0
  %26 = icmp eq i64 %termType, 1
  %27 = or i1 %25, %26
  br i1 %27, label %then0__2, label %test1__2

then0__2:                                         ; preds = %exit__3
  %28 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %29 = sub i64 %nQubits, 1
  br label %header__4

test1__2:                                         ; preds = %exit__3
  %30 = icmp eq i64 %termType, 3
  br i1 %30, label %then1__2, label %test2__1

then1__2:                                         ; preds = %test1__2
  %compactOps = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 8)
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 0)
  %32 = bitcast i8* %31 to %Array**
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 1)
  %34 = bitcast i8* %33 to %Array**
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 2)
  %36 = bitcast i8* %35 to %Array**
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 3)
  %38 = bitcast i8* %37 to %Array**
  %39 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 4)
  %40 = bitcast i8* %39 to %Array**
  %41 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 5)
  %42 = bitcast i8* %41 to %Array**
  %43 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 6)
  %44 = bitcast i8* %43 to %Array**
  %45 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 7)
  %46 = bitcast i8* %45 to %Array**
  %47 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 0)
  %49 = bitcast i8* %48 to i2*
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 1)
  %51 = bitcast i8* %50 to i2*
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 2)
  %53 = bitcast i8* %52 to i2*
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %47, i64 3)
  %55 = bitcast i8* %54 to i2*
  %56 = load i2, i2* @PauliX
  %57 = load i2, i2* @PauliX
  %58 = load i2, i2* @PauliX
  %59 = load i2, i2* @PauliX
  store i2 %56, i2* %49
  store i2 %57, i2* %51
  store i2 %58, i2* %53
  store i2 %59, i2* %55
  %60 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %61 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %60, i64 0)
  %62 = bitcast i8* %61 to i2*
  %63 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %60, i64 1)
  %64 = bitcast i8* %63 to i2*
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %60, i64 2)
  %66 = bitcast i8* %65 to i2*
  %67 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %60, i64 3)
  %68 = bitcast i8* %67 to i2*
  %69 = load i2, i2* @PauliY
  %70 = load i2, i2* @PauliY
  %71 = load i2, i2* @PauliY
  %72 = load i2, i2* @PauliY
  store i2 %69, i2* %62
  store i2 %70, i2* %64
  store i2 %71, i2* %66
  store i2 %72, i2* %68
  %73 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 0)
  %75 = bitcast i8* %74 to i2*
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 1)
  %77 = bitcast i8* %76 to i2*
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 2)
  %79 = bitcast i8* %78 to i2*
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 3)
  %81 = bitcast i8* %80 to i2*
  %82 = load i2, i2* @PauliX
  %83 = load i2, i2* @PauliX
  %84 = load i2, i2* @PauliY
  %85 = load i2, i2* @PauliY
  store i2 %82, i2* %75
  store i2 %83, i2* %77
  store i2 %84, i2* %79
  store i2 %85, i2* %81
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %87 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 0)
  %88 = bitcast i8* %87 to i2*
  %89 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 1)
  %90 = bitcast i8* %89 to i2*
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 2)
  %92 = bitcast i8* %91 to i2*
  %93 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 3)
  %94 = bitcast i8* %93 to i2*
  %95 = load i2, i2* @PauliY
  %96 = load i2, i2* @PauliY
  %97 = load i2, i2* @PauliX
  %98 = load i2, i2* @PauliX
  store i2 %95, i2* %88
  store i2 %96, i2* %90
  store i2 %97, i2* %92
  store i2 %98, i2* %94
  %99 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %99, i64 0)
  %101 = bitcast i8* %100 to i2*
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %99, i64 1)
  %103 = bitcast i8* %102 to i2*
  %104 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %99, i64 2)
  %105 = bitcast i8* %104 to i2*
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %99, i64 3)
  %107 = bitcast i8* %106 to i2*
  %108 = load i2, i2* @PauliX
  %109 = load i2, i2* @PauliY
  %110 = load i2, i2* @PauliX
  %111 = load i2, i2* @PauliY
  store i2 %108, i2* %101
  store i2 %109, i2* %103
  store i2 %110, i2* %105
  store i2 %111, i2* %107
  %112 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %113 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %112, i64 0)
  %114 = bitcast i8* %113 to i2*
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %112, i64 1)
  %116 = bitcast i8* %115 to i2*
  %117 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %112, i64 2)
  %118 = bitcast i8* %117 to i2*
  %119 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %112, i64 3)
  %120 = bitcast i8* %119 to i2*
  %121 = load i2, i2* @PauliY
  %122 = load i2, i2* @PauliX
  %123 = load i2, i2* @PauliY
  %124 = load i2, i2* @PauliX
  store i2 %121, i2* %114
  store i2 %122, i2* %116
  store i2 %123, i2* %118
  store i2 %124, i2* %120
  %125 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %126 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %125, i64 0)
  %127 = bitcast i8* %126 to i2*
  %128 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %125, i64 1)
  %129 = bitcast i8* %128 to i2*
  %130 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %125, i64 2)
  %131 = bitcast i8* %130 to i2*
  %132 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %125, i64 3)
  %133 = bitcast i8* %132 to i2*
  %134 = load i2, i2* @PauliY
  %135 = load i2, i2* @PauliX
  %136 = load i2, i2* @PauliX
  %137 = load i2, i2* @PauliY
  store i2 %134, i2* %127
  store i2 %135, i2* %129
  store i2 %136, i2* %131
  store i2 %137, i2* %133
  %138 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %139 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %138, i64 0)
  %140 = bitcast i8* %139 to i2*
  %141 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %138, i64 1)
  %142 = bitcast i8* %141 to i2*
  %143 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %138, i64 2)
  %144 = bitcast i8* %143 to i2*
  %145 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %138, i64 3)
  %146 = bitcast i8* %145 to i2*
  %147 = load i2, i2* @PauliX
  %148 = load i2, i2* @PauliY
  %149 = load i2, i2* @PauliY
  %150 = load i2, i2* @PauliX
  store i2 %147, i2* %140
  store i2 %148, i2* %142
  store i2 %149, i2* %144
  store i2 %150, i2* %146
  store %Array* %47, %Array** %32
  store %Array* %60, %Array** %34
  store %Array* %73, %Array** %36
  store %Array* %86, %Array** %38
  store %Array* %99, %Array** %40
  store %Array* %112, %Array** %42
  store %Array* %125, %Array** %44
  store %Array* %138, %Array** %46
  br label %header__6

test2__1:                                         ; preds = %test1__2
  %151 = icmp eq i64 %termType, 2
  br i1 %151, label %then2__1, label %continue__2

then2__1:                                         ; preds = %test2__1
  %compactOps__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %152 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 0)
  %153 = bitcast i8* %152 to %Array**
  %154 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 1)
  %155 = bitcast i8* %154 to %Array**
  %156 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %157 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %156, i64 0)
  %158 = bitcast i8* %157 to i2*
  %159 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %156, i64 1)
  %160 = bitcast i8* %159 to i2*
  %161 = load i2, i2* @PauliX
  %162 = load i2, i2* @PauliX
  store i2 %161, i2* %158
  store i2 %162, i2* %160
  %163 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %164 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %163, i64 0)
  %165 = bitcast i8* %164 to i2*
  %166 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %163, i64 1)
  %167 = bitcast i8* %166 to i2*
  %168 = load i2, i2* @PauliY
  %169 = load i2, i2* @PauliY
  store i2 %168, i2* %165
  store i2 %169, i2* %167
  store %Array* %156, %Array** %153
  store %Array* %163, %Array** %155
  br label %header__14

continue__2:                                      ; preds = %exit__19, %test2__1, %exit__13, %condContinue__1
  %170 = load %Array*, %Array** %ops
  call void @__quantum__rt__array_update_alias_count(%Array* %indices, i64 -1)
  %171 = call i64 @__quantum__rt__array_get_size_1d(%Array* %170)
  %172 = sub i64 %171, 1
  br label %header__20

header__4:                                        ; preds = %exiting__4, %then0__2
  %173 = phi i64 [ 0, %then0__2 ], [ %178, %exiting__4 ]
  %174 = icmp sle i64 %173, %29
  br i1 %174, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %175 = load i2, i2* @PauliI
  %176 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %28, i64 %173)
  %177 = bitcast i8* %176 to i2*
  store i2 %175, i2* %177
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %178 = add i64 %173, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %op = alloca %Array*
  store %Array* %28, %Array** %op
  call void @__quantum__rt__array_update_alias_count(%Array* %28, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %28, i64 1)
  %179 = call i64 @__quantum__rt__array_get_size_1d(%Array* %indices)
  %180 = sub i64 %179, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %181 = phi i64 [ 0, %exit__4 ], [ %191, %exiting__5 ]
  %182 = icmp sle i64 %181, %180
  br i1 %182, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %183 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %181)
  %184 = bitcast i8* %183 to i64*
  %idx = load i64, i64* %184
  %185 = load %Array*, %Array** %op
  call void @__quantum__rt__array_update_alias_count(%Array* %185, i64 -1)
  %186 = call %Array* @__quantum__rt__array_copy(%Array* %185, i1 false)
  %187 = icmp ne %Array* %185, %186
  %188 = load i2, i2* @PauliZ
  %189 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %186, i64 %idx)
  %190 = bitcast i8* %189 to i2*
  store i2 %188, i2* %190
  call void @__quantum__rt__array_update_reference_count(%Array* %186, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %186, i64 1)
  store %Array* %186, %Array** %op
  call void @__quantum__rt__array_update_reference_count(%Array* %185, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %186, i64 -1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %191 = add i64 %181, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_alias_count(%Array* %3, i64 -1)
  %192 = call %Array* @__quantum__rt__array_copy(%Array* %3, i1 false)
  %193 = icmp ne %Array* %3, %192
  %194 = load %Array*, %Array** %op
  %195 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %192, i64 0)
  %196 = bitcast i8* %195 to %Array**
  call void @__quantum__rt__array_update_reference_count(%Array* %194, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %194, i64 1)
  %197 = load %Array*, %Array** %196
  call void @__quantum__rt__array_update_alias_count(%Array* %197, i64 -1)
  br i1 %193, label %condContinue__1, label %condFalse__1

condFalse__1:                                     ; preds = %exit__5
  call void @__quantum__rt__array_update_reference_count(%Array* %194, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %197, i64 -1)
  br label %condContinue__1

condContinue__1:                                  ; preds = %condFalse__1, %exit__5
  store %Array* %194, %Array** %196
  call void @__quantum__rt__array_update_reference_count(%Array* %192, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %192, i64 1)
  store %Array* %192, %Array** %ops
  call void @__quantum__rt__array_update_alias_count(%Array* %194, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %197, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %192, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %194, i64 -1)
  br label %continue__2

header__6:                                        ; preds = %exiting__6, %then1__2
  %198 = phi i64 [ 0, %then1__2 ], [ %203, %exiting__6 ]
  %199 = icmp sle i64 %198, 7
  br i1 %199, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %200 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 %198)
  %201 = bitcast i8* %200 to %Array**
  %202 = load %Array*, %Array** %201
  call void @__quantum__rt__array_update_alias_count(%Array* %202, i64 1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %203 = add i64 %198, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_alias_count(%Array* %compactOps, i64 1)
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %iOp = phi i64 [ 0, %exit__6 ], [ %210, %exiting__7 ]
  %204 = icmp sle i64 %iOp, 7
  br i1 %204, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %205 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 %iOp)
  %206 = bitcast i8* %205 to %Array**
  %207 = load %Array*, %Array** %206
  %compactOp = alloca %Array*
  store %Array* %207, %Array** %compactOp
  call void @__quantum__rt__array_update_alias_count(%Array* %207, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %207, i64 1)
  %208 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %209 = sub i64 %nQubits, 1
  br label %header__8

exiting__7:                                       ; preds = %condContinue__2
  %210 = add i64 %iOp, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  br label %header__12

header__8:                                        ; preds = %exiting__8, %body__7
  %211 = phi i64 [ 0, %body__7 ], [ %216, %exiting__8 ]
  %212 = icmp sle i64 %211, %209
  br i1 %212, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %213 = load i2, i2* @PauliI
  %214 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %208, i64 %211)
  %215 = bitcast i8* %214 to i2*
  store i2 %213, i2* %215
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %216 = add i64 %211, 1
  br label %header__8

exit__8:                                          ; preds = %header__8
  %op__1 = alloca %Array*
  store %Array* %208, %Array** %op__1
  call void @__quantum__rt__array_update_alias_count(%Array* %208, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %208, i64 1)
  %217 = call i64 @__quantum__rt__array_get_size_1d(%Array* %indices)
  %218 = sub i64 %217, 1
  br label %header__9

header__9:                                        ; preds = %exiting__9, %exit__8
  %i = phi i64 [ 0, %exit__8 ], [ %230, %exiting__9 ]
  %219 = icmp sle i64 %i, %218
  br i1 %219, label %body__9, label %exit__9

body__9:                                          ; preds = %header__9
  %220 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %i)
  %221 = bitcast i8* %220 to i64*
  %idx__1 = load i64, i64* %221
  %222 = load %Array*, %Array** %compactOp
  %223 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %222, i64 %i)
  %224 = bitcast i8* %223 to i2*
  %pauli = load i2, i2* %224
  %225 = load %Array*, %Array** %op__1
  call void @__quantum__rt__array_update_alias_count(%Array* %225, i64 -1)
  %226 = call %Array* @__quantum__rt__array_copy(%Array* %225, i1 false)
  %227 = icmp ne %Array* %225, %226
  %228 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %226, i64 %idx__1)
  %229 = bitcast i8* %228 to i2*
  store i2 %pauli, i2* %229
  call void @__quantum__rt__array_update_reference_count(%Array* %226, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %226, i64 1)
  store %Array* %226, %Array** %op__1
  call void @__quantum__rt__array_update_reference_count(%Array* %225, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %226, i64 -1)
  br label %exiting__9

exiting__9:                                       ; preds = %body__9
  %230 = add i64 %i, 1
  br label %header__9

exit__9:                                          ; preds = %header__9
  %231 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %232 = bitcast i8* %231 to i64*
  %233 = load i64, i64* %232
  %234 = add i64 %233, 1
  %235 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %236 = bitcast i8* %235 to i64*
  %237 = load i64, i64* %236
  %238 = sub i64 %237, 1
  br label %header__10

header__10:                                       ; preds = %exiting__10, %exit__9
  %i__1 = phi i64 [ %234, %exit__9 ], [ %246, %exiting__10 ]
  %239 = icmp sle i64 %i__1, %238
  br i1 %239, label %body__10, label %exit__10

body__10:                                         ; preds = %header__10
  %240 = load %Array*, %Array** %op__1
  call void @__quantum__rt__array_update_alias_count(%Array* %240, i64 -1)
  %241 = call %Array* @__quantum__rt__array_copy(%Array* %240, i1 false)
  %242 = icmp ne %Array* %240, %241
  %243 = load i2, i2* @PauliZ
  %244 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %241, i64 %i__1)
  %245 = bitcast i8* %244 to i2*
  store i2 %243, i2* %245
  call void @__quantum__rt__array_update_reference_count(%Array* %241, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %241, i64 1)
  store %Array* %241, %Array** %op__1
  call void @__quantum__rt__array_update_reference_count(%Array* %240, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %241, i64 -1)
  br label %exiting__10

exiting__10:                                      ; preds = %body__10
  %246 = add i64 %i__1, 1
  br label %header__10

exit__10:                                         ; preds = %header__10
  %247 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 2)
  %248 = bitcast i8* %247 to i64*
  %249 = load i64, i64* %248
  %250 = add i64 %249, 1
  %251 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 3)
  %252 = bitcast i8* %251 to i64*
  %253 = load i64, i64* %252
  %254 = sub i64 %253, 1
  br label %header__11

header__11:                                       ; preds = %exiting__11, %exit__10
  %i__2 = phi i64 [ %250, %exit__10 ], [ %262, %exiting__11 ]
  %255 = icmp sle i64 %i__2, %254
  br i1 %255, label %body__11, label %exit__11

body__11:                                         ; preds = %header__11
  %256 = load %Array*, %Array** %op__1
  call void @__quantum__rt__array_update_alias_count(%Array* %256, i64 -1)
  %257 = call %Array* @__quantum__rt__array_copy(%Array* %256, i1 false)
  %258 = icmp ne %Array* %256, %257
  %259 = load i2, i2* @PauliZ
  %260 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %257, i64 %i__2)
  %261 = bitcast i8* %260 to i2*
  store i2 %259, i2* %261
  call void @__quantum__rt__array_update_reference_count(%Array* %257, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %257, i64 1)
  store %Array* %257, %Array** %op__1
  call void @__quantum__rt__array_update_reference_count(%Array* %256, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %257, i64 -1)
  br label %exiting__11

exiting__11:                                      ; preds = %body__11
  %262 = add i64 %i__2, 1
  br label %header__11

exit__11:                                         ; preds = %header__11
  %263 = load %Array*, %Array** %ops
  call void @__quantum__rt__array_update_alias_count(%Array* %263, i64 -1)
  %264 = call %Array* @__quantum__rt__array_copy(%Array* %263, i1 false)
  %265 = icmp ne %Array* %263, %264
  %266 = load %Array*, %Array** %op__1
  %267 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %264, i64 %iOp)
  %268 = bitcast i8* %267 to %Array**
  call void @__quantum__rt__array_update_reference_count(%Array* %266, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %266, i64 1)
  %269 = load %Array*, %Array** %268
  call void @__quantum__rt__array_update_alias_count(%Array* %269, i64 -1)
  br i1 %265, label %condContinue__2, label %condFalse__2

condFalse__2:                                     ; preds = %exit__11
  call void @__quantum__rt__array_update_reference_count(%Array* %266, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %269, i64 -1)
  br label %condContinue__2

condContinue__2:                                  ; preds = %condFalse__2, %exit__11
  store %Array* %266, %Array** %268
  call void @__quantum__rt__array_update_reference_count(%Array* %264, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %264, i64 1)
  store %Array* %264, %Array** %ops
  %270 = load %Array*, %Array** %compactOp
  call void @__quantum__rt__array_update_alias_count(%Array* %270, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %266, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %208, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %263, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %269, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %264, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %270, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %266, i64 -1)
  br label %exiting__7

header__12:                                       ; preds = %exiting__12, %exit__7
  %271 = phi i64 [ 0, %exit__7 ], [ %276, %exiting__12 ]
  %272 = icmp sle i64 %271, 7
  br i1 %272, label %body__12, label %exit__12

body__12:                                         ; preds = %header__12
  %273 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 %271)
  %274 = bitcast i8* %273 to %Array**
  %275 = load %Array*, %Array** %274
  call void @__quantum__rt__array_update_alias_count(%Array* %275, i64 -1)
  br label %exiting__12

exiting__12:                                      ; preds = %body__12
  %276 = add i64 %271, 1
  br label %header__12

exit__12:                                         ; preds = %header__12
  call void @__quantum__rt__array_update_alias_count(%Array* %compactOps, i64 -1)
  br label %header__13

header__13:                                       ; preds = %exiting__13, %exit__12
  %277 = phi i64 [ 0, %exit__12 ], [ %282, %exiting__13 ]
  %278 = icmp sle i64 %277, 7
  br i1 %278, label %body__13, label %exit__13

body__13:                                         ; preds = %header__13
  %279 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 %277)
  %280 = bitcast i8* %279 to %Array**
  %281 = load %Array*, %Array** %280
  call void @__quantum__rt__array_update_reference_count(%Array* %281, i64 -1)
  br label %exiting__13

exiting__13:                                      ; preds = %body__13
  %282 = add i64 %277, 1
  br label %header__13

exit__13:                                         ; preds = %header__13
  call void @__quantum__rt__array_update_reference_count(%Array* %compactOps, i64 -1)
  br label %continue__2

header__14:                                       ; preds = %exiting__14, %then2__1
  %283 = phi i64 [ 0, %then2__1 ], [ %288, %exiting__14 ]
  %284 = icmp sle i64 %283, 1
  br i1 %284, label %body__14, label %exit__14

body__14:                                         ; preds = %header__14
  %285 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 %283)
  %286 = bitcast i8* %285 to %Array**
  %287 = load %Array*, %Array** %286
  call void @__quantum__rt__array_update_alias_count(%Array* %287, i64 1)
  br label %exiting__14

exiting__14:                                      ; preds = %body__14
  %288 = add i64 %283, 1
  br label %header__14

exit__14:                                         ; preds = %header__14
  call void @__quantum__rt__array_update_alias_count(%Array* %compactOps__1, i64 1)
  br label %header__15

header__15:                                       ; preds = %exiting__15, %exit__14
  %iOp__1 = phi i64 [ 0, %exit__14 ], [ %295, %exiting__15 ]
  %289 = icmp sle i64 %iOp__1, 1
  br i1 %289, label %body__15, label %exit__15

body__15:                                         ; preds = %header__15
  %290 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 %iOp__1)
  %291 = bitcast i8* %290 to %Array**
  %292 = load %Array*, %Array** %291
  %compactOp__1 = alloca %Array*
  store %Array* %292, %Array** %compactOp__1
  call void @__quantum__rt__array_update_alias_count(%Array* %292, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %292, i64 1)
  %293 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %294 = sub i64 %nQubits, 1
  br label %header__16

exiting__15:                                      ; preds = %condContinue__3
  %295 = add i64 %iOp__1, 1
  br label %header__15

exit__15:                                         ; preds = %header__15
  br label %header__18

header__16:                                       ; preds = %exiting__16, %body__15
  %296 = phi i64 [ 0, %body__15 ], [ %301, %exiting__16 ]
  %297 = icmp sle i64 %296, %294
  br i1 %297, label %body__16, label %exit__16

body__16:                                         ; preds = %header__16
  %298 = load i2, i2* @PauliI
  %299 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %293, i64 %296)
  %300 = bitcast i8* %299 to i2*
  store i2 %298, i2* %300
  br label %exiting__16

exiting__16:                                      ; preds = %body__16
  %301 = add i64 %296, 1
  br label %header__16

exit__16:                                         ; preds = %header__16
  %op__2 = alloca %Array*
  store %Array* %293, %Array** %op__2
  call void @__quantum__rt__array_update_alias_count(%Array* %293, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %293, i64 1)
  %nIndices = call i64 @__quantum__rt__array_get_size_1d(%Array* %indices)
  call void @__quantum__rt__array_update_alias_count(%Array* %293, i64 -1)
  %302 = call %Array* @__quantum__rt__array_copy(%Array* %293, i1 false)
  %303 = icmp ne %Array* %293, %302
  %304 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %292, i64 0)
  %305 = bitcast i8* %304 to i2*
  %306 = load i2, i2* %305
  %307 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %308 = bitcast i8* %307 to i64*
  %309 = load i64, i64* %308
  %310 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %302, i64 %309)
  %311 = bitcast i8* %310 to i2*
  store i2 %306, i2* %311
  call void @__quantum__rt__array_update_reference_count(%Array* %302, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %302, i64 1)
  store %Array* %302, %Array** %op__2
  call void @__quantum__rt__array_update_alias_count(%Array* %302, i64 -1)
  %312 = call %Array* @__quantum__rt__array_copy(%Array* %302, i1 false)
  %313 = icmp ne %Array* %302, %312
  %314 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %292, i64 1)
  %315 = bitcast i8* %314 to i2*
  %316 = load i2, i2* %315
  %317 = sub i64 %nIndices, 1
  %318 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %317)
  %319 = bitcast i8* %318 to i64*
  %320 = load i64, i64* %319
  %321 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %312, i64 %320)
  %322 = bitcast i8* %321 to i2*
  store i2 %316, i2* %322
  call void @__quantum__rt__array_update_reference_count(%Array* %312, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %312, i64 1)
  store %Array* %312, %Array** %op__2
  %323 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %324 = bitcast i8* %323 to i64*
  %325 = load i64, i64* %324
  %326 = add i64 %325, 1
  %327 = sub i64 %nIndices, 1
  %328 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %327)
  %329 = bitcast i8* %328 to i64*
  %330 = load i64, i64* %329
  %331 = sub i64 %330, 1
  br label %header__17

header__17:                                       ; preds = %exiting__17, %exit__16
  %i__3 = phi i64 [ %326, %exit__16 ], [ %339, %exiting__17 ]
  %332 = icmp sle i64 %i__3, %331
  br i1 %332, label %body__17, label %exit__17

body__17:                                         ; preds = %header__17
  %333 = load %Array*, %Array** %op__2
  call void @__quantum__rt__array_update_alias_count(%Array* %333, i64 -1)
  %334 = call %Array* @__quantum__rt__array_copy(%Array* %333, i1 false)
  %335 = icmp ne %Array* %333, %334
  %336 = load i2, i2* @PauliZ
  %337 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %334, i64 %i__3)
  %338 = bitcast i8* %337 to i2*
  store i2 %336, i2* %338
  call void @__quantum__rt__array_update_reference_count(%Array* %334, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %334, i64 1)
  store %Array* %334, %Array** %op__2
  call void @__quantum__rt__array_update_reference_count(%Array* %333, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %334, i64 -1)
  br label %exiting__17

exiting__17:                                      ; preds = %body__17
  %339 = add i64 %i__3, 1
  br label %header__17

exit__17:                                         ; preds = %header__17
  %340 = icmp eq i64 %nIndices, 4
  br i1 %340, label %then0__3, label %continue__3

then0__3:                                         ; preds = %exit__17
  %341 = load %Array*, %Array** %op__2
  call void @__quantum__rt__array_update_alias_count(%Array* %341, i64 -1)
  %342 = call %Array* @__quantum__rt__array_copy(%Array* %341, i1 false)
  %343 = icmp ne %Array* %341, %342
  %344 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %345 = bitcast i8* %344 to i64*
  %346 = load i64, i64* %345
  %347 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %348 = bitcast i8* %347 to i64*
  %349 = load i64, i64* %348
  %350 = icmp slt i64 %346, %349
  %351 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %352 = bitcast i8* %351 to i64*
  %353 = load i64, i64* %352
  %354 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 3)
  %355 = bitcast i8* %354 to i64*
  %356 = load i64, i64* %355
  %357 = icmp slt i64 %353, %356
  %358 = and i1 %350, %357
  %359 = load i2, i2* @PauliI
  %360 = load i2, i2* @PauliZ
  %361 = select i1 %358, i2 %359, i2 %360
  %362 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %363 = bitcast i8* %362 to i64*
  %364 = load i64, i64* %363
  %365 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %342, i64 %364)
  %366 = bitcast i8* %365 to i2*
  store i2 %361, i2* %366
  call void @__quantum__rt__array_update_reference_count(%Array* %342, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %342, i64 1)
  store %Array* %342, %Array** %op__2
  call void @__quantum__rt__array_update_reference_count(%Array* %341, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %342, i64 -1)
  br label %continue__3

continue__3:                                      ; preds = %then0__3, %exit__17
  %367 = load %Array*, %Array** %ops
  call void @__quantum__rt__array_update_alias_count(%Array* %367, i64 -1)
  %368 = call %Array* @__quantum__rt__array_copy(%Array* %367, i1 false)
  %369 = icmp ne %Array* %367, %368
  %370 = load %Array*, %Array** %op__2
  %371 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %368, i64 %iOp__1)
  %372 = bitcast i8* %371 to %Array**
  call void @__quantum__rt__array_update_reference_count(%Array* %370, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %370, i64 1)
  %373 = load %Array*, %Array** %372
  call void @__quantum__rt__array_update_alias_count(%Array* %373, i64 -1)
  br i1 %369, label %condContinue__3, label %condFalse__3

condFalse__3:                                     ; preds = %continue__3
  call void @__quantum__rt__array_update_reference_count(%Array* %370, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %373, i64 -1)
  br label %condContinue__3

condContinue__3:                                  ; preds = %condFalse__3, %continue__3
  store %Array* %370, %Array** %372
  call void @__quantum__rt__array_update_reference_count(%Array* %368, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %368, i64 1)
  store %Array* %368, %Array** %ops
  call void @__quantum__rt__array_update_alias_count(%Array* %292, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %370, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %293, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %293, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %302, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %302, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %312, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %367, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %373, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %368, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %292, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %370, i64 -1)
  br label %exiting__15

header__18:                                       ; preds = %exiting__18, %exit__15
  %374 = phi i64 [ 0, %exit__15 ], [ %379, %exiting__18 ]
  %375 = icmp sle i64 %374, 1
  br i1 %375, label %body__18, label %exit__18

body__18:                                         ; preds = %header__18
  %376 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 %374)
  %377 = bitcast i8* %376 to %Array**
  %378 = load %Array*, %Array** %377
  call void @__quantum__rt__array_update_alias_count(%Array* %378, i64 -1)
  br label %exiting__18

exiting__18:                                      ; preds = %body__18
  %379 = add i64 %374, 1
  br label %header__18

exit__18:                                         ; preds = %header__18
  call void @__quantum__rt__array_update_alias_count(%Array* %compactOps__1, i64 -1)
  br label %header__19

header__19:                                       ; preds = %exiting__19, %exit__18
  %380 = phi i64 [ 0, %exit__18 ], [ %385, %exiting__19 ]
  %381 = icmp sle i64 %380, 1
  br i1 %381, label %body__19, label %exit__19

body__19:                                         ; preds = %header__19
  %382 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps__1, i64 %380)
  %383 = bitcast i8* %382 to %Array**
  %384 = load %Array*, %Array** %383
  call void @__quantum__rt__array_update_reference_count(%Array* %384, i64 -1)
  br label %exiting__19

exiting__19:                                      ; preds = %body__19
  %385 = add i64 %380, 1
  br label %header__19

exit__19:                                         ; preds = %header__19
  call void @__quantum__rt__array_update_reference_count(%Array* %compactOps__1, i64 -1)
  br label %continue__2

header__20:                                       ; preds = %exiting__20, %continue__2
  %386 = phi i64 [ 0, %continue__2 ], [ %391, %exiting__20 ]
  %387 = icmp sle i64 %386, %172
  br i1 %387, label %body__20, label %exit__20

body__20:                                         ; preds = %header__20
  %388 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %170, i64 %386)
  %389 = bitcast i8* %388 to %Array**
  %390 = load %Array*, %Array** %389
  call void @__quantum__rt__array_update_alias_count(%Array* %390, i64 -1)
  br label %exiting__20

exiting__20:                                      ; preds = %body__20
  %391 = add i64 %386, 1
  br label %header__20

exit__20:                                         ; preds = %header__20
  call void @__quantum__rt__array_update_alias_count(%Array* %170, i64 -1)
  %392 = sub i64 %2, 1
  br label %header__21

header__21:                                       ; preds = %exiting__21, %exit__20
  %393 = phi i64 [ 0, %exit__20 ], [ %398, %exiting__21 ]
  %394 = icmp sle i64 %393, %392
  br i1 %394, label %body__21, label %exit__21

body__21:                                         ; preds = %header__21
  %395 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %393)
  %396 = bitcast i8* %395 to %Array**
  %397 = load %Array*, %Array** %396
  call void @__quantum__rt__array_update_reference_count(%Array* %397, i64 -1)
  br label %exiting__21

exiting__21:                                      ; preds = %body__21
  %398 = add i64 %393, 1
  br label %header__21

exit__21:                                         ; preds = %header__21
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  ret %Array* %170
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

define %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__ExpandedCoefficients__body(%Array* %coeff, i64 %termType) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %coeff, i64 1)
  %nCoeffs = alloca i64
  store i64 0, i64* %nCoeffs
  %0 = icmp eq i64 %termType, 2
  br i1 %0, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  store i64 2, i64* %nCoeffs
  br label %continue__1

test1__1:                                         ; preds = %entry
  %1 = icmp eq i64 %termType, 3
  br i1 %1, label %then1__1, label %else__1

then1__1:                                         ; preds = %test1__1
  store i64 8, i64* %nCoeffs
  br label %continue__1

else__1:                                          ; preds = %test1__1
  store i64 1, i64* %nCoeffs
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then1__1, %then0__1
  %2 = load i64, i64* %nCoeffs
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %2)
  %4 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %continue__1
  %5 = phi i64 [ 0, %continue__1 ], [ %9, %exiting__1 ]
  %6 = icmp sle i64 %5, %4
  br i1 %6, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 %5)
  %8 = bitcast i8* %7 to double*
  store double 0.000000e+00, double* %8
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %9 = add i64 %5, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %coeffs = alloca %Array*
  store %Array* %3, %Array** %coeffs
  call void @__quantum__rt__array_update_alias_count(%Array* %3, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 1)
  %10 = icmp eq i64 %termType, 0
  %11 = icmp eq i64 %termType, 1
  %12 = or i1 %10, %11
  br i1 %12, label %then0__2, label %test1__2

then0__2:                                         ; preds = %exit__1
  call void @__quantum__rt__array_update_alias_count(%Array* %3, i64 -1)
  %13 = call %Array* @__quantum__rt__array_copy(%Array* %3, i1 false)
  %14 = icmp ne %Array* %3, %13
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeff, i64 0)
  %16 = bitcast i8* %15 to double*
  %17 = load double, double* %16
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %13, i64 0)
  %19 = bitcast i8* %18 to double*
  store double %17, double* %19
  call void @__quantum__rt__array_update_reference_count(%Array* %13, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %13, i64 1)
  store %Array* %13, %Array** %coeffs
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %13, i64 -1)
  br label %continue__2

test1__2:                                         ; preds = %exit__1
  %20 = icmp eq i64 %termType, 2
  %21 = icmp eq i64 %termType, 3
  %22 = or i1 %20, %21
  br i1 %22, label %then1__2, label %continue__2

then1__2:                                         ; preds = %test1__2
  %23 = sub i64 %2, 1
  br label %header__2

continue__2:                                      ; preds = %exit__2, %test1__2, %then0__2
  %24 = load %Array*, %Array** %coeffs
  call void @__quantum__rt__array_update_alias_count(%Array* %coeff, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %24, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  ret %Array* %24

header__2:                                        ; preds = %exiting__2, %then1__2
  %i = phi i64 [ 0, %then1__2 ], [ %35, %exiting__2 ]
  %25 = icmp sle i64 %i, %23
  br i1 %25, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %26 = load %Array*, %Array** %coeffs
  call void @__quantum__rt__array_update_alias_count(%Array* %26, i64 -1)
  %27 = call %Array* @__quantum__rt__array_copy(%Array* %26, i1 false)
  %28 = icmp ne %Array* %26, %27
  %29 = udiv i64 %i, 2
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeff, i64 %29)
  %31 = bitcast i8* %30 to double*
  %32 = load double, double* %31
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %27, i64 %i)
  %34 = bitcast i8* %33 to double*
  store double %32, double* %34
  call void @__quantum__rt__array_update_reference_count(%Array* %27, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %27, i64 1)
  store %Array* %27, %Array** %coeffs
  call void @__quantum__rt__array_update_reference_count(%Array* %26, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %27, i64 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %35 = add i64 %i, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  br label %continue__2
}

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body(double %theta1, double %theta2, double %theta3, i64 %nSamples) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = bitcast i8* %1 to { %Array*, %Array* }**
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 1)
  %4 = bitcast i8* %3 to { %Array*, %Array* }**
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 2)
  %6 = bitcast i8* %5 to { %Array*, %Array* }**
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 3)
  %8 = bitcast i8* %7 to { %Array*, %Array* }**
  %9 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %9, i64 0)
  %11 = bitcast i8* %10 to i64*
  store i64 0, i64* %11
  %12 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %12, i64 0)
  %14 = bitcast i8* %13 to double*
  store double 0x3FC5E9EC780DD8B0, double* %14
  %15 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %9, %Array* %12)
  call void @__quantum__rt__array_update_reference_count(%Array* %9, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %12, i64 -1)
  %16 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %16, i64 0)
  %18 = bitcast i8* %17 to i64*
  store i64 1, i64* %18
  %19 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %19, i64 0)
  %21 = bitcast i8* %20 to double*
  store double 0x3FC5E9EC780DD8B0, double* %21
  %22 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %16, %Array* %19)
  call void @__quantum__rt__array_update_reference_count(%Array* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %19, i64 -1)
  %23 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %23, i64 0)
  %25 = bitcast i8* %24 to i64*
  store i64 2, i64* %25
  %26 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %27 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 0)
  %28 = bitcast i8* %27 to double*
  store double 0xBFCC8498CDE41B6A, double* %28
  %29 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %23, %Array* %26)
  call void @__quantum__rt__array_update_reference_count(%Array* %23, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %26, i64 -1)
  %30 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %30, i64 0)
  %32 = bitcast i8* %31 to i64*
  store i64 3, i64* %32
  %33 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %34 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %33, i64 0)
  %35 = bitcast i8* %34 to double*
  store double 0xBFCC8498CDE41B6A, double* %35
  %36 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %30, %Array* %33)
  call void @__quantum__rt__array_update_reference_count(%Array* %30, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %33, i64 -1)
  store { %Array*, %Array* }* %15, { %Array*, %Array* }** %2
  store { %Array*, %Array* }* %22, { %Array*, %Array* }** %4
  store { %Array*, %Array* }* %29, { %Array*, %Array* }** %6
  store { %Array*, %Array* }* %36, { %Array*, %Array* }** %8
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 6)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 0)
  %39 = bitcast i8* %38 to { %Array*, %Array* }**
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 1)
  %41 = bitcast i8* %40 to { %Array*, %Array* }**
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 2)
  %43 = bitcast i8* %42 to { %Array*, %Array* }**
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 3)
  %45 = bitcast i8* %44 to { %Array*, %Array* }**
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 4)
  %47 = bitcast i8* %46 to { %Array*, %Array* }**
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 5)
  %49 = bitcast i8* %48 to { %Array*, %Array* }**
  %50 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %50, i64 0)
  %52 = bitcast i8* %51 to i64*
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %50, i64 1)
  %54 = bitcast i8* %53 to i64*
  store i64 0, i64* %52
  store i64 1, i64* %54
  %55 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %55, i64 0)
  %57 = bitcast i8* %56 to double*
  store double 0x3FC59572B12B0E54, double* %57
  %58 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %50, %Array* %55)
  call void @__quantum__rt__array_update_reference_count(%Array* %50, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %55, i64 -1)
  %59 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %59, i64 0)
  %61 = bitcast i8* %60 to i64*
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %59, i64 1)
  %63 = bitcast i8* %62 to i64*
  store i64 0, i64* %61
  store i64 2, i64* %63
  %64 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %64, i64 0)
  %66 = bitcast i8* %65 to double*
  store double 0x3FBEDC1CB9A7B498, double* %66
  %67 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %59, %Array* %64)
  call void @__quantum__rt__array_update_reference_count(%Array* %59, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %64, i64 -1)
  %68 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %69 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %68, i64 0)
  %70 = bitcast i8* %69 to i64*
  %71 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %68, i64 1)
  %72 = bitcast i8* %71 to i64*
  store i64 0, i64* %70
  store i64 3, i64* %72
  %73 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %73, i64 0)
  %75 = bitcast i8* %74 to double*
  store double 0x3FC53B29D7F34F20, double* %75
  %76 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %68, %Array* %73)
  call void @__quantum__rt__array_update_reference_count(%Array* %68, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %73, i64 -1)
  %77 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %77, i64 0)
  %79 = bitcast i8* %78 to i64*
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %77, i64 1)
  %81 = bitcast i8* %80 to i64*
  store i64 1, i64* %79
  store i64 2, i64* %81
  %82 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %83 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %82, i64 0)
  %84 = bitcast i8* %83 to double*
  store double 0x3FC53B29D7F34F20, double* %84
  %85 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %77, %Array* %82)
  call void @__quantum__rt__array_update_reference_count(%Array* %77, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %82, i64 -1)
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %87 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 0)
  %88 = bitcast i8* %87 to i64*
  %89 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 1)
  %90 = bitcast i8* %89 to i64*
  store i64 1, i64* %88
  store i64 3, i64* %90
  %91 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %92 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %91, i64 0)
  %93 = bitcast i8* %92 to double*
  store double 0x3FBEDC1CB9A7B498, double* %93
  %94 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %86, %Array* %91)
  call void @__quantum__rt__array_update_reference_count(%Array* %86, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %91, i64 -1)
  %95 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %95, i64 0)
  %97 = bitcast i8* %96 to i64*
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %95, i64 1)
  %99 = bitcast i8* %98 to i64*
  store i64 2, i64* %97
  store i64 3, i64* %99
  %100 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %101 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %100, i64 0)
  %102 = bitcast i8* %101 to double*
  store double 0x3FC65115A1A7DAFB, double* %102
  %103 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %95, %Array* %100)
  call void @__quantum__rt__array_update_reference_count(%Array* %95, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %100, i64 -1)
  store { %Array*, %Array* }* %58, { %Array*, %Array* }** %39
  store { %Array*, %Array* }* %67, { %Array*, %Array* }** %41
  store { %Array*, %Array* }* %76, { %Array*, %Array* }** %43
  store { %Array*, %Array* }* %85, { %Array*, %Array* }** %45
  store { %Array*, %Array* }* %94, { %Array*, %Array* }** %47
  store { %Array*, %Array* }* %103, { %Array*, %Array* }** %49
  %104 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 0)
  %105 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %105, i64 0)
  %107 = bitcast i8* %106 to { %Array*, %Array* }**
  %108 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %109 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %108, i64 0)
  %110 = bitcast i8* %109 to i64*
  %111 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %108, i64 1)
  %112 = bitcast i8* %111 to i64*
  %113 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %108, i64 2)
  %114 = bitcast i8* %113 to i64*
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %108, i64 3)
  %116 = bitcast i8* %115 to i64*
  store i64 0, i64* %110
  store i64 1, i64* %112
  store i64 2, i64* %114
  store i64 3, i64* %116
  %117 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %118 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %117, i64 0)
  %119 = bitcast i8* %118 to double*
  %120 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %117, i64 1)
  %121 = bitcast i8* %120 to double*
  %122 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %117, i64 2)
  %123 = bitcast i8* %122 to double*
  %124 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %117, i64 3)
  %125 = bitcast i8* %124 to double*
  store double 0.000000e+00, double* %119
  store double 0xBFA7346DEC7DD351, double* %121
  store double 0.000000e+00, double* %123
  store double 0x3FA7346DEC7DD351, double* %125
  %126 = call { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %108, %Array* %117)
  call void @__quantum__rt__array_update_reference_count(%Array* %108, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %117, i64 -1)
  store { %Array*, %Array* }* %126, { %Array*, %Array* }** %107
  %hamiltonian = call { %Array*, %Array*, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JWOptimizedHTerms__body(%Array* %0, %Array* %37, %Array* %104, %Array* %105)
  %127 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, i32 0, i32 0
  %128 = load %Array*, %Array** %127
  %129 = call i64 @__quantum__rt__array_get_size_1d(%Array* %128)
  %130 = sub i64 %129, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %131 = phi i64 [ 0, %entry ], [ %141, %exiting__1 ]
  %132 = icmp sle i64 %131, %130
  br i1 %132, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %133 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %128, i64 %131)
  %134 = bitcast i8* %133 to { %Array*, %Array* }**
  %135 = load { %Array*, %Array* }*, { %Array*, %Array* }** %134
  %136 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %135, i32 0, i32 0
  %137 = load %Array*, %Array** %136
  call void @__quantum__rt__array_update_alias_count(%Array* %137, i64 1)
  %138 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %135, i32 0, i32 1
  %139 = load %Array*, %Array** %138
  call void @__quantum__rt__array_update_alias_count(%Array* %139, i64 1)
  %140 = bitcast { %Array*, %Array* }* %135 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %140, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %141 = add i64 %131, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %128, i64 1)
  %142 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, i32 0, i32 1
  %143 = load %Array*, %Array** %142
  %144 = call i64 @__quantum__rt__array_get_size_1d(%Array* %143)
  %145 = sub i64 %144, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %146 = phi i64 [ 0, %exit__1 ], [ %156, %exiting__2 ]
  %147 = icmp sle i64 %146, %145
  br i1 %147, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %148 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %143, i64 %146)
  %149 = bitcast i8* %148 to { %Array*, %Array* }**
  %150 = load { %Array*, %Array* }*, { %Array*, %Array* }** %149
  %151 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %150, i32 0, i32 0
  %152 = load %Array*, %Array** %151
  call void @__quantum__rt__array_update_alias_count(%Array* %152, i64 1)
  %153 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %150, i32 0, i32 1
  %154 = load %Array*, %Array** %153
  call void @__quantum__rt__array_update_alias_count(%Array* %154, i64 1)
  %155 = bitcast { %Array*, %Array* }* %150 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %155, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %156 = add i64 %146, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %143, i64 1)
  %157 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, i32 0, i32 2
  %158 = load %Array*, %Array** %157
  %159 = call i64 @__quantum__rt__array_get_size_1d(%Array* %158)
  %160 = sub i64 %159, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %161 = phi i64 [ 0, %exit__2 ], [ %171, %exiting__3 ]
  %162 = icmp sle i64 %161, %160
  br i1 %162, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %163 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %158, i64 %161)
  %164 = bitcast i8* %163 to { %Array*, %Array* }**
  %165 = load { %Array*, %Array* }*, { %Array*, %Array* }** %164
  %166 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %165, i32 0, i32 0
  %167 = load %Array*, %Array** %166
  call void @__quantum__rt__array_update_alias_count(%Array* %167, i64 1)
  %168 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %165, i32 0, i32 1
  %169 = load %Array*, %Array** %168
  call void @__quantum__rt__array_update_alias_count(%Array* %169, i64 1)
  %170 = bitcast { %Array*, %Array* }* %165 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %170, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %171 = add i64 %161, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %158, i64 1)
  %172 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, i32 0, i32 3
  %173 = load %Array*, %Array** %172
  %174 = call i64 @__quantum__rt__array_get_size_1d(%Array* %173)
  %175 = sub i64 %174, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %176 = phi i64 [ 0, %exit__3 ], [ %186, %exiting__4 ]
  %177 = icmp sle i64 %176, %175
  br i1 %177, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %178 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %173, i64 %176)
  %179 = bitcast i8* %178 to { %Array*, %Array* }**
  %180 = load { %Array*, %Array* }*, { %Array*, %Array* }** %179
  %181 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %180, i32 0, i32 0
  %182 = load %Array*, %Array** %181
  call void @__quantum__rt__array_update_alias_count(%Array* %182, i64 1)
  %183 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %180, i32 0, i32 1
  %184 = load %Array*, %Array** %183
  call void @__quantum__rt__array_update_alias_count(%Array* %184, i64 1)
  %185 = bitcast { %Array*, %Array* }* %180 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %185, i64 1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %186 = add i64 %176, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %173, i64 1)
  %187 = bitcast { %Array*, %Array*, %Array*, %Array* }* %hamiltonian to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %187, i64 1)
  %188 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i64, %Array* }* getelementptr ({ i64, %Array* }, { i64, %Array* }* null, i32 1) to i64))
  %inputState = bitcast %Tuple* %188 to { i64, %Array* }*
  %189 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 0
  %190 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 1
  %191 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %192 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 0)
  %193 = bitcast i8* %192 to { { double, double }*, %Array* }**
  %194 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 1)
  %195 = bitcast i8* %194 to { { double, double }*, %Array* }**
  %196 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 2)
  %197 = bitcast i8* %196 to { { double, double }*, %Array* }**
  %198 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 3)
  %199 = bitcast i8* %198 to { { double, double }*, %Array* }**
  %200 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (double* getelementptr (double, double* null, i32 1) to i64), i64 2))
  %201 = bitcast %Tuple* %200 to { double, double }*
  %202 = getelementptr inbounds { double, double }, { double, double }* %201, i32 0, i32 0
  %203 = getelementptr inbounds { double, double }, { double, double }* %201, i32 0, i32 1
  store double %theta1, double* %202
  store double 0.000000e+00, double* %203
  %204 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %205 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %204, i64 0)
  %206 = bitcast i8* %205 to i64*
  %207 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %204, i64 1)
  %208 = bitcast i8* %207 to i64*
  store i64 2, i64* %206
  store i64 0, i64* %208
  %209 = call { { double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ double, double }* %201, %Array* %204)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %200, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %204, i64 -1)
  %210 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (double* getelementptr (double, double* null, i32 1) to i64), i64 2))
  %211 = bitcast %Tuple* %210 to { double, double }*
  %212 = getelementptr inbounds { double, double }, { double, double }* %211, i32 0, i32 0
  %213 = getelementptr inbounds { double, double }, { double, double }* %211, i32 0, i32 1
  store double %theta2, double* %212
  store double 0.000000e+00, double* %213
  %214 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %215 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %214, i64 0)
  %216 = bitcast i8* %215 to i64*
  %217 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %214, i64 1)
  %218 = bitcast i8* %217 to i64*
  store i64 3, i64* %216
  store i64 1, i64* %218
  %219 = call { { double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ double, double }* %211, %Array* %214)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %210, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %214, i64 -1)
  %220 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (double* getelementptr (double, double* null, i32 1) to i64), i64 2))
  %221 = bitcast %Tuple* %220 to { double, double }*
  %222 = getelementptr inbounds { double, double }, { double, double }* %221, i32 0, i32 0
  %223 = getelementptr inbounds { double, double }, { double, double }* %221, i32 0, i32 1
  store double %theta3, double* %222
  store double 0.000000e+00, double* %223
  %224 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %225 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %224, i64 0)
  %226 = bitcast i8* %225 to i64*
  %227 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %224, i64 1)
  %228 = bitcast i8* %227 to i64*
  %229 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %224, i64 2)
  %230 = bitcast i8* %229 to i64*
  %231 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %224, i64 3)
  %232 = bitcast i8* %231 to i64*
  store i64 2, i64* %226
  store i64 3, i64* %228
  store i64 1, i64* %230
  store i64 0, i64* %232
  %233 = call { { double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ double, double }* %221, %Array* %224)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %220, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %224, i64 -1)
  %234 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (double* getelementptr (double, double* null, i32 1) to i64), i64 2))
  %235 = bitcast %Tuple* %234 to { double, double }*
  %236 = getelementptr inbounds { double, double }, { double, double }* %235, i32 0, i32 0
  %237 = getelementptr inbounds { double, double }, { double, double }* %235, i32 0, i32 1
  store double 1.000000e+00, double* %236
  store double 0.000000e+00, double* %237
  %238 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %239 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %238, i64 0)
  %240 = bitcast i8* %239 to i64*
  %241 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %238, i64 1)
  %242 = bitcast i8* %241 to i64*
  store i64 0, i64* %240
  store i64 1, i64* %242
  %243 = call { { double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ double, double }* %235, %Array* %238)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %234, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %238, i64 -1)
  store { { double, double }*, %Array* }* %209, { { double, double }*, %Array* }** %193
  store { { double, double }*, %Array* }* %219, { { double, double }*, %Array* }** %195
  store { { double, double }*, %Array* }* %233, { { double, double }*, %Array* }** %197
  store { { double, double }*, %Array* }* %243, { { double, double }*, %Array* }** %199
  store i64 3, i64* %189
  store %Array* %191, %Array** %190
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %244 = phi i64 [ 0, %exit__4 ], [ %255, %exiting__5 ]
  %245 = icmp sle i64 %244, 3
  br i1 %245, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %246 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 %244)
  %247 = bitcast i8* %246 to { { double, double }*, %Array* }**
  %248 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %247
  %249 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %248, i32 0, i32 0
  %250 = load { double, double }*, { double, double }** %249
  %251 = bitcast { double, double }* %250 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %251, i64 1)
  %252 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %248, i32 0, i32 1
  %253 = load %Array*, %Array** %252
  call void @__quantum__rt__array_update_alias_count(%Array* %253, i64 1)
  %254 = bitcast { { double, double }*, %Array* }* %248 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %254, i64 1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %255 = add i64 %244, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_alias_count(%Array* %191, i64 1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %188, i64 1)
  %JWEncodedData = call { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerEncodingData__body(i64 4, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, { i64, %Array* }* %inputState, double 0xBFB94D36D949CC98)
  %256 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %JWEncodedData, i32 0, i32 1
  %257 = load { %Array*, %Array*, %Array*, %Array* }*, { %Array*, %Array*, %Array*, %Array* }** %256
  %258 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %257, i32 0, i32 0
  %259 = load %Array*, %Array** %258
  %260 = call i64 @__quantum__rt__array_get_size_1d(%Array* %259)
  %261 = sub i64 %260, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %262 = phi i64 [ 0, %exit__5 ], [ %272, %exiting__6 ]
  %263 = icmp sle i64 %262, %261
  br i1 %263, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %264 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %259, i64 %262)
  %265 = bitcast i8* %264 to { %Array*, %Array* }**
  %266 = load { %Array*, %Array* }*, { %Array*, %Array* }** %265
  %267 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %266, i32 0, i32 0
  %268 = load %Array*, %Array** %267
  call void @__quantum__rt__array_update_alias_count(%Array* %268, i64 1)
  %269 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %266, i32 0, i32 1
  %270 = load %Array*, %Array** %269
  call void @__quantum__rt__array_update_alias_count(%Array* %270, i64 1)
  %271 = bitcast { %Array*, %Array* }* %266 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %271, i64 1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %272 = add i64 %262, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_alias_count(%Array* %259, i64 1)
  %273 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %257, i32 0, i32 1
  %274 = load %Array*, %Array** %273
  %275 = call i64 @__quantum__rt__array_get_size_1d(%Array* %274)
  %276 = sub i64 %275, 1
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %277 = phi i64 [ 0, %exit__6 ], [ %287, %exiting__7 ]
  %278 = icmp sle i64 %277, %276
  br i1 %278, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %279 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %274, i64 %277)
  %280 = bitcast i8* %279 to { %Array*, %Array* }**
  %281 = load { %Array*, %Array* }*, { %Array*, %Array* }** %280
  %282 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %281, i32 0, i32 0
  %283 = load %Array*, %Array** %282
  call void @__quantum__rt__array_update_alias_count(%Array* %283, i64 1)
  %284 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %281, i32 0, i32 1
  %285 = load %Array*, %Array** %284
  call void @__quantum__rt__array_update_alias_count(%Array* %285, i64 1)
  %286 = bitcast { %Array*, %Array* }* %281 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %286, i64 1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %287 = add i64 %277, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  call void @__quantum__rt__array_update_alias_count(%Array* %274, i64 1)
  %288 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %257, i32 0, i32 2
  %289 = load %Array*, %Array** %288
  %290 = call i64 @__quantum__rt__array_get_size_1d(%Array* %289)
  %291 = sub i64 %290, 1
  br label %header__8

header__8:                                        ; preds = %exiting__8, %exit__7
  %292 = phi i64 [ 0, %exit__7 ], [ %302, %exiting__8 ]
  %293 = icmp sle i64 %292, %291
  br i1 %293, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %294 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %289, i64 %292)
  %295 = bitcast i8* %294 to { %Array*, %Array* }**
  %296 = load { %Array*, %Array* }*, { %Array*, %Array* }** %295
  %297 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %296, i32 0, i32 0
  %298 = load %Array*, %Array** %297
  call void @__quantum__rt__array_update_alias_count(%Array* %298, i64 1)
  %299 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %296, i32 0, i32 1
  %300 = load %Array*, %Array** %299
  call void @__quantum__rt__array_update_alias_count(%Array* %300, i64 1)
  %301 = bitcast { %Array*, %Array* }* %296 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %301, i64 1)
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %302 = add i64 %292, 1
  br label %header__8

exit__8:                                          ; preds = %header__8
  call void @__quantum__rt__array_update_alias_count(%Array* %289, i64 1)
  %303 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %257, i32 0, i32 3
  %304 = load %Array*, %Array** %303
  %305 = call i64 @__quantum__rt__array_get_size_1d(%Array* %304)
  %306 = sub i64 %305, 1
  br label %header__9

header__9:                                        ; preds = %exiting__9, %exit__8
  %307 = phi i64 [ 0, %exit__8 ], [ %317, %exiting__9 ]
  %308 = icmp sle i64 %307, %306
  br i1 %308, label %body__9, label %exit__9

body__9:                                          ; preds = %header__9
  %309 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %304, i64 %307)
  %310 = bitcast i8* %309 to { %Array*, %Array* }**
  %311 = load { %Array*, %Array* }*, { %Array*, %Array* }** %310
  %312 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %311, i32 0, i32 0
  %313 = load %Array*, %Array** %312
  call void @__quantum__rt__array_update_alias_count(%Array* %313, i64 1)
  %314 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %311, i32 0, i32 1
  %315 = load %Array*, %Array** %314
  call void @__quantum__rt__array_update_alias_count(%Array* %315, i64 1)
  %316 = bitcast { %Array*, %Array* }* %311 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %316, i64 1)
  br label %exiting__9

exiting__9:                                       ; preds = %body__9
  %317 = add i64 %307, 1
  br label %header__9

exit__9:                                          ; preds = %header__9
  call void @__quantum__rt__array_update_alias_count(%Array* %304, i64 1)
  %318 = bitcast { %Array*, %Array*, %Array*, %Array* }* %257 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %318, i64 1)
  %319 = getelementptr inbounds { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }, { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %JWEncodedData, i32 0, i32 2
  %320 = load { i64, %Array* }*, { i64, %Array* }** %319
  %321 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %320, i32 0, i32 1
  %322 = load %Array*, %Array** %321
  %323 = call i64 @__quantum__rt__array_get_size_1d(%Array* %322)
  %324 = sub i64 %323, 1
  br label %header__10

header__10:                                       ; preds = %exiting__10, %exit__9
  %325 = phi i64 [ 0, %exit__9 ], [ %336, %exiting__10 ]
  %326 = icmp sle i64 %325, %324
  br i1 %326, label %body__10, label %exit__10

body__10:                                         ; preds = %header__10
  %327 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %322, i64 %325)
  %328 = bitcast i8* %327 to { { double, double }*, %Array* }**
  %329 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %328
  %330 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %329, i32 0, i32 0
  %331 = load { double, double }*, { double, double }** %330
  %332 = bitcast { double, double }* %331 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %332, i64 1)
  %333 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %329, i32 0, i32 1
  %334 = load %Array*, %Array** %333
  call void @__quantum__rt__array_update_alias_count(%Array* %334, i64 1)
  %335 = bitcast { { double, double }*, %Array* }* %329 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %335, i64 1)
  br label %exiting__10

exiting__10:                                      ; preds = %body__10
  %336 = add i64 %325, 1
  br label %header__10

exit__10:                                         ; preds = %header__10
  call void @__quantum__rt__array_update_alias_count(%Array* %322, i64 1)
  %337 = bitcast { i64, %Array* }* %320 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %337, i64 1)
  %338 = bitcast { i64, { %Array*, %Array*, %Array*, %Array* }*, { i64, %Array* }*, double }* %JWEncodedData to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %338, i64 1)
  %339 = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__VariationalQuantumEigensolver__EstimateEnergy__body(i64 5, { %Array*, %Array*, %Array*, %Array* }* %hamiltonian, { i64, %Array* }* %inputState, double 0xBFB94D36D949CC98, i64 %nSamples)
  %340 = sub i64 %129, 1
  br label %header__11

header__11:                                       ; preds = %exiting__11, %exit__10
  %341 = phi i64 [ 0, %exit__10 ], [ %351, %exiting__11 ]
  %342 = icmp sle i64 %341, %340
  br i1 %342, label %body__11, label %exit__11

body__11:                                         ; preds = %header__11
  %343 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %128, i64 %341)
  %344 = bitcast i8* %343 to { %Array*, %Array* }**
  %345 = load { %Array*, %Array* }*, { %Array*, %Array* }** %344
  %346 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %345, i32 0, i32 0
  %347 = load %Array*, %Array** %346
  call void @__quantum__rt__array_update_alias_count(%Array* %347, i64 -1)
  %348 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %345, i32 0, i32 1
  %349 = load %Array*, %Array** %348
  call void @__quantum__rt__array_update_alias_count(%Array* %349, i64 -1)
  %350 = bitcast { %Array*, %Array* }* %345 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %350, i64 -1)
  br label %exiting__11

exiting__11:                                      ; preds = %body__11
  %351 = add i64 %341, 1
  br label %header__11

exit__11:                                         ; preds = %header__11
  call void @__quantum__rt__array_update_alias_count(%Array* %128, i64 -1)
  %352 = sub i64 %144, 1
  br label %header__12

header__12:                                       ; preds = %exiting__12, %exit__11
  %353 = phi i64 [ 0, %exit__11 ], [ %363, %exiting__12 ]
  %354 = icmp sle i64 %353, %352
  br i1 %354, label %body__12, label %exit__12

body__12:                                         ; preds = %header__12
  %355 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %143, i64 %353)
  %356 = bitcast i8* %355 to { %Array*, %Array* }**
  %357 = load { %Array*, %Array* }*, { %Array*, %Array* }** %356
  %358 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %357, i32 0, i32 0
  %359 = load %Array*, %Array** %358
  call void @__quantum__rt__array_update_alias_count(%Array* %359, i64 -1)
  %360 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %357, i32 0, i32 1
  %361 = load %Array*, %Array** %360
  call void @__quantum__rt__array_update_alias_count(%Array* %361, i64 -1)
  %362 = bitcast { %Array*, %Array* }* %357 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %362, i64 -1)
  br label %exiting__12

exiting__12:                                      ; preds = %body__12
  %363 = add i64 %353, 1
  br label %header__12

exit__12:                                         ; preds = %header__12
  call void @__quantum__rt__array_update_alias_count(%Array* %143, i64 -1)
  %364 = sub i64 %159, 1
  br label %header__13

header__13:                                       ; preds = %exiting__13, %exit__12
  %365 = phi i64 [ 0, %exit__12 ], [ %375, %exiting__13 ]
  %366 = icmp sle i64 %365, %364
  br i1 %366, label %body__13, label %exit__13

body__13:                                         ; preds = %header__13
  %367 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %158, i64 %365)
  %368 = bitcast i8* %367 to { %Array*, %Array* }**
  %369 = load { %Array*, %Array* }*, { %Array*, %Array* }** %368
  %370 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %369, i32 0, i32 0
  %371 = load %Array*, %Array** %370
  call void @__quantum__rt__array_update_alias_count(%Array* %371, i64 -1)
  %372 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %369, i32 0, i32 1
  %373 = load %Array*, %Array** %372
  call void @__quantum__rt__array_update_alias_count(%Array* %373, i64 -1)
  %374 = bitcast { %Array*, %Array* }* %369 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %374, i64 -1)
  br label %exiting__13

exiting__13:                                      ; preds = %body__13
  %375 = add i64 %365, 1
  br label %header__13

exit__13:                                         ; preds = %header__13
  call void @__quantum__rt__array_update_alias_count(%Array* %158, i64 -1)
  %376 = sub i64 %174, 1
  br label %header__14

header__14:                                       ; preds = %exiting__14, %exit__13
  %377 = phi i64 [ 0, %exit__13 ], [ %387, %exiting__14 ]
  %378 = icmp sle i64 %377, %376
  br i1 %378, label %body__14, label %exit__14

body__14:                                         ; preds = %header__14
  %379 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %173, i64 %377)
  %380 = bitcast i8* %379 to { %Array*, %Array* }**
  %381 = load { %Array*, %Array* }*, { %Array*, %Array* }** %380
  %382 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %381, i32 0, i32 0
  %383 = load %Array*, %Array** %382
  call void @__quantum__rt__array_update_alias_count(%Array* %383, i64 -1)
  %384 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %381, i32 0, i32 1
  %385 = load %Array*, %Array** %384
  call void @__quantum__rt__array_update_alias_count(%Array* %385, i64 -1)
  %386 = bitcast { %Array*, %Array* }* %381 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %386, i64 -1)
  br label %exiting__14

exiting__14:                                      ; preds = %body__14
  %387 = add i64 %377, 1
  br label %header__14

exit__14:                                         ; preds = %header__14
  call void @__quantum__rt__array_update_alias_count(%Array* %173, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %187, i64 -1)
  br label %header__15

header__15:                                       ; preds = %exiting__15, %exit__14
  %388 = phi i64 [ 0, %exit__14 ], [ %399, %exiting__15 ]
  %389 = icmp sle i64 %388, 3
  br i1 %389, label %body__15, label %exit__15

body__15:                                         ; preds = %header__15
  %390 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 %388)
  %391 = bitcast i8* %390 to { { double, double }*, %Array* }**
  %392 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %391
  %393 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %392, i32 0, i32 0
  %394 = load { double, double }*, { double, double }** %393
  %395 = bitcast { double, double }* %394 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %395, i64 -1)
  %396 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %392, i32 0, i32 1
  %397 = load %Array*, %Array** %396
  call void @__quantum__rt__array_update_alias_count(%Array* %397, i64 -1)
  %398 = bitcast { { double, double }*, %Array* }* %392 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %398, i64 -1)
  br label %exiting__15

exiting__15:                                      ; preds = %body__15
  %399 = add i64 %388, 1
  br label %header__15

exit__15:                                         ; preds = %header__15
  call void @__quantum__rt__array_update_alias_count(%Array* %191, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %188, i64 -1)
  %400 = sub i64 %260, 1
  br label %header__16

header__16:                                       ; preds = %exiting__16, %exit__15
  %401 = phi i64 [ 0, %exit__15 ], [ %411, %exiting__16 ]
  %402 = icmp sle i64 %401, %400
  br i1 %402, label %body__16, label %exit__16

body__16:                                         ; preds = %header__16
  %403 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %259, i64 %401)
  %404 = bitcast i8* %403 to { %Array*, %Array* }**
  %405 = load { %Array*, %Array* }*, { %Array*, %Array* }** %404
  %406 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %405, i32 0, i32 0
  %407 = load %Array*, %Array** %406
  call void @__quantum__rt__array_update_alias_count(%Array* %407, i64 -1)
  %408 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %405, i32 0, i32 1
  %409 = load %Array*, %Array** %408
  call void @__quantum__rt__array_update_alias_count(%Array* %409, i64 -1)
  %410 = bitcast { %Array*, %Array* }* %405 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %410, i64 -1)
  br label %exiting__16

exiting__16:                                      ; preds = %body__16
  %411 = add i64 %401, 1
  br label %header__16

exit__16:                                         ; preds = %header__16
  call void @__quantum__rt__array_update_alias_count(%Array* %259, i64 -1)
  %412 = sub i64 %275, 1
  br label %header__17

header__17:                                       ; preds = %exiting__17, %exit__16
  %413 = phi i64 [ 0, %exit__16 ], [ %423, %exiting__17 ]
  %414 = icmp sle i64 %413, %412
  br i1 %414, label %body__17, label %exit__17

body__17:                                         ; preds = %header__17
  %415 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %274, i64 %413)
  %416 = bitcast i8* %415 to { %Array*, %Array* }**
  %417 = load { %Array*, %Array* }*, { %Array*, %Array* }** %416
  %418 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %417, i32 0, i32 0
  %419 = load %Array*, %Array** %418
  call void @__quantum__rt__array_update_alias_count(%Array* %419, i64 -1)
  %420 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %417, i32 0, i32 1
  %421 = load %Array*, %Array** %420
  call void @__quantum__rt__array_update_alias_count(%Array* %421, i64 -1)
  %422 = bitcast { %Array*, %Array* }* %417 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %422, i64 -1)
  br label %exiting__17

exiting__17:                                      ; preds = %body__17
  %423 = add i64 %413, 1
  br label %header__17

exit__17:                                         ; preds = %header__17
  call void @__quantum__rt__array_update_alias_count(%Array* %274, i64 -1)
  %424 = sub i64 %290, 1
  br label %header__18

header__18:                                       ; preds = %exiting__18, %exit__17
  %425 = phi i64 [ 0, %exit__17 ], [ %435, %exiting__18 ]
  %426 = icmp sle i64 %425, %424
  br i1 %426, label %body__18, label %exit__18

body__18:                                         ; preds = %header__18
  %427 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %289, i64 %425)
  %428 = bitcast i8* %427 to { %Array*, %Array* }**
  %429 = load { %Array*, %Array* }*, { %Array*, %Array* }** %428
  %430 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %429, i32 0, i32 0
  %431 = load %Array*, %Array** %430
  call void @__quantum__rt__array_update_alias_count(%Array* %431, i64 -1)
  %432 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %429, i32 0, i32 1
  %433 = load %Array*, %Array** %432
  call void @__quantum__rt__array_update_alias_count(%Array* %433, i64 -1)
  %434 = bitcast { %Array*, %Array* }* %429 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %434, i64 -1)
  br label %exiting__18

exiting__18:                                      ; preds = %body__18
  %435 = add i64 %425, 1
  br label %header__18

exit__18:                                         ; preds = %header__18
  call void @__quantum__rt__array_update_alias_count(%Array* %289, i64 -1)
  %436 = sub i64 %305, 1
  br label %header__19

header__19:                                       ; preds = %exiting__19, %exit__18
  %437 = phi i64 [ 0, %exit__18 ], [ %447, %exiting__19 ]
  %438 = icmp sle i64 %437, %436
  br i1 %438, label %body__19, label %exit__19

body__19:                                         ; preds = %header__19
  %439 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %304, i64 %437)
  %440 = bitcast i8* %439 to { %Array*, %Array* }**
  %441 = load { %Array*, %Array* }*, { %Array*, %Array* }** %440
  %442 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %441, i32 0, i32 0
  %443 = load %Array*, %Array** %442
  call void @__quantum__rt__array_update_alias_count(%Array* %443, i64 -1)
  %444 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %441, i32 0, i32 1
  %445 = load %Array*, %Array** %444
  call void @__quantum__rt__array_update_alias_count(%Array* %445, i64 -1)
  %446 = bitcast { %Array*, %Array* }* %441 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %446, i64 -1)
  br label %exiting__19

exiting__19:                                      ; preds = %body__19
  %447 = add i64 %437, 1
  br label %header__19

exit__19:                                         ; preds = %header__19
  call void @__quantum__rt__array_update_alias_count(%Array* %304, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %318, i64 -1)
  %448 = sub i64 %323, 1
  br label %header__20

header__20:                                       ; preds = %exiting__20, %exit__19
  %449 = phi i64 [ 0, %exit__19 ], [ %460, %exiting__20 ]
  %450 = icmp sle i64 %449, %448
  br i1 %450, label %body__20, label %exit__20

body__20:                                         ; preds = %header__20
  %451 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %322, i64 %449)
  %452 = bitcast i8* %451 to { { double, double }*, %Array* }**
  %453 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %452
  %454 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %453, i32 0, i32 0
  %455 = load { double, double }*, { double, double }** %454
  %456 = bitcast { double, double }* %455 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %456, i64 -1)
  %457 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %453, i32 0, i32 1
  %458 = load %Array*, %Array** %457
  call void @__quantum__rt__array_update_alias_count(%Array* %458, i64 -1)
  %459 = bitcast { { double, double }*, %Array* }* %453 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %459, i64 -1)
  br label %exiting__20

exiting__20:                                      ; preds = %body__20
  %460 = add i64 %449, 1
  br label %header__20

exit__20:                                         ; preds = %header__20
  call void @__quantum__rt__array_update_alias_count(%Array* %322, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %337, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %338, i64 -1)
  br label %header__21

header__21:                                       ; preds = %exiting__21, %exit__20
  %461 = phi i64 [ 0, %exit__20 ], [ %471, %exiting__21 ]
  %462 = icmp sle i64 %461, 3
  br i1 %462, label %body__21, label %exit__21

body__21:                                         ; preds = %header__21
  %463 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %461)
  %464 = bitcast i8* %463 to { %Array*, %Array* }**
  %465 = load { %Array*, %Array* }*, { %Array*, %Array* }** %464
  %466 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %465, i32 0, i32 0
  %467 = load %Array*, %Array** %466
  call void @__quantum__rt__array_update_reference_count(%Array* %467, i64 -1)
  %468 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %465, i32 0, i32 1
  %469 = load %Array*, %Array** %468
  call void @__quantum__rt__array_update_reference_count(%Array* %469, i64 -1)
  %470 = bitcast { %Array*, %Array* }* %465 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %470, i64 -1)
  br label %exiting__21

exiting__21:                                      ; preds = %body__21
  %471 = add i64 %461, 1
  br label %header__21

exit__21:                                         ; preds = %header__21
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  br label %header__22

header__22:                                       ; preds = %exiting__22, %exit__21
  %472 = phi i64 [ 0, %exit__21 ], [ %482, %exiting__22 ]
  %473 = icmp sle i64 %472, 5
  br i1 %473, label %body__22, label %exit__22

body__22:                                         ; preds = %header__22
  %474 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 %472)
  %475 = bitcast i8* %474 to { %Array*, %Array* }**
  %476 = load { %Array*, %Array* }*, { %Array*, %Array* }** %475
  %477 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %476, i32 0, i32 0
  %478 = load %Array*, %Array** %477
  call void @__quantum__rt__array_update_reference_count(%Array* %478, i64 -1)
  %479 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %476, i32 0, i32 1
  %480 = load %Array*, %Array** %479
  call void @__quantum__rt__array_update_reference_count(%Array* %480, i64 -1)
  %481 = bitcast { %Array*, %Array* }* %476 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %481, i64 -1)
  br label %exiting__22

exiting__22:                                      ; preds = %body__22
  %482 = add i64 %472, 1
  br label %header__22

exit__22:                                         ; preds = %header__22
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %104, i64 -1)
  br label %header__23

header__23:                                       ; preds = %exiting__23, %exit__22
  %483 = phi i64 [ 0, %exit__22 ], [ %493, %exiting__23 ]
  %484 = icmp sle i64 %483, 0
  br i1 %484, label %body__23, label %exit__23

body__23:                                         ; preds = %header__23
  %485 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %105, i64 %483)
  %486 = bitcast i8* %485 to { %Array*, %Array* }**
  %487 = load { %Array*, %Array* }*, { %Array*, %Array* }** %486
  %488 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %487, i32 0, i32 0
  %489 = load %Array*, %Array** %488
  call void @__quantum__rt__array_update_reference_count(%Array* %489, i64 -1)
  %490 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %487, i32 0, i32 1
  %491 = load %Array*, %Array** %490
  call void @__quantum__rt__array_update_reference_count(%Array* %491, i64 -1)
  %492 = bitcast { %Array*, %Array* }* %487 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %492, i64 -1)
  br label %exiting__23

exiting__23:                                      ; preds = %body__23
  %493 = add i64 %483, 1
  br label %header__23

exit__23:                                         ; preds = %header__23
  call void @__quantum__rt__array_update_reference_count(%Array* %105, i64 -1)
  %494 = sub i64 %129, 1
  br label %header__24

header__24:                                       ; preds = %exiting__24, %exit__23
  %495 = phi i64 [ 0, %exit__23 ], [ %505, %exiting__24 ]
  %496 = icmp sle i64 %495, %494
  br i1 %496, label %body__24, label %exit__24

body__24:                                         ; preds = %header__24
  %497 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %128, i64 %495)
  %498 = bitcast i8* %497 to { %Array*, %Array* }**
  %499 = load { %Array*, %Array* }*, { %Array*, %Array* }** %498
  %500 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %499, i32 0, i32 0
  %501 = load %Array*, %Array** %500
  call void @__quantum__rt__array_update_reference_count(%Array* %501, i64 -1)
  %502 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %499, i32 0, i32 1
  %503 = load %Array*, %Array** %502
  call void @__quantum__rt__array_update_reference_count(%Array* %503, i64 -1)
  %504 = bitcast { %Array*, %Array* }* %499 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %504, i64 -1)
  br label %exiting__24

exiting__24:                                      ; preds = %body__24
  %505 = add i64 %495, 1
  br label %header__24

exit__24:                                         ; preds = %header__24
  call void @__quantum__rt__array_update_reference_count(%Array* %128, i64 -1)
  %506 = sub i64 %144, 1
  br label %header__25

header__25:                                       ; preds = %exiting__25, %exit__24
  %507 = phi i64 [ 0, %exit__24 ], [ %517, %exiting__25 ]
  %508 = icmp sle i64 %507, %506
  br i1 %508, label %body__25, label %exit__25

body__25:                                         ; preds = %header__25
  %509 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %143, i64 %507)
  %510 = bitcast i8* %509 to { %Array*, %Array* }**
  %511 = load { %Array*, %Array* }*, { %Array*, %Array* }** %510
  %512 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %511, i32 0, i32 0
  %513 = load %Array*, %Array** %512
  call void @__quantum__rt__array_update_reference_count(%Array* %513, i64 -1)
  %514 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %511, i32 0, i32 1
  %515 = load %Array*, %Array** %514
  call void @__quantum__rt__array_update_reference_count(%Array* %515, i64 -1)
  %516 = bitcast { %Array*, %Array* }* %511 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %516, i64 -1)
  br label %exiting__25

exiting__25:                                      ; preds = %body__25
  %517 = add i64 %507, 1
  br label %header__25

exit__25:                                         ; preds = %header__25
  call void @__quantum__rt__array_update_reference_count(%Array* %143, i64 -1)
  %518 = sub i64 %159, 1
  br label %header__26

header__26:                                       ; preds = %exiting__26, %exit__25
  %519 = phi i64 [ 0, %exit__25 ], [ %529, %exiting__26 ]
  %520 = icmp sle i64 %519, %518
  br i1 %520, label %body__26, label %exit__26

body__26:                                         ; preds = %header__26
  %521 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %158, i64 %519)
  %522 = bitcast i8* %521 to { %Array*, %Array* }**
  %523 = load { %Array*, %Array* }*, { %Array*, %Array* }** %522
  %524 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %523, i32 0, i32 0
  %525 = load %Array*, %Array** %524
  call void @__quantum__rt__array_update_reference_count(%Array* %525, i64 -1)
  %526 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %523, i32 0, i32 1
  %527 = load %Array*, %Array** %526
  call void @__quantum__rt__array_update_reference_count(%Array* %527, i64 -1)
  %528 = bitcast { %Array*, %Array* }* %523 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %528, i64 -1)
  br label %exiting__26

exiting__26:                                      ; preds = %body__26
  %529 = add i64 %519, 1
  br label %header__26

exit__26:                                         ; preds = %header__26
  call void @__quantum__rt__array_update_reference_count(%Array* %158, i64 -1)
  %530 = sub i64 %174, 1
  br label %header__27

header__27:                                       ; preds = %exiting__27, %exit__26
  %531 = phi i64 [ 0, %exit__26 ], [ %541, %exiting__27 ]
  %532 = icmp sle i64 %531, %530
  br i1 %532, label %body__27, label %exit__27

body__27:                                         ; preds = %header__27
  %533 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %173, i64 %531)
  %534 = bitcast i8* %533 to { %Array*, %Array* }**
  %535 = load { %Array*, %Array* }*, { %Array*, %Array* }** %534
  %536 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %535, i32 0, i32 0
  %537 = load %Array*, %Array** %536
  call void @__quantum__rt__array_update_reference_count(%Array* %537, i64 -1)
  %538 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %535, i32 0, i32 1
  %539 = load %Array*, %Array** %538
  call void @__quantum__rt__array_update_reference_count(%Array* %539, i64 -1)
  %540 = bitcast { %Array*, %Array* }* %535 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %540, i64 -1)
  br label %exiting__27

exiting__27:                                      ; preds = %body__27
  %541 = add i64 %531, 1
  br label %header__27

exit__27:                                         ; preds = %header__27
  call void @__quantum__rt__array_update_reference_count(%Array* %173, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %187, i64 -1)
  br label %header__28

header__28:                                       ; preds = %exiting__28, %exit__27
  %542 = phi i64 [ 0, %exit__27 ], [ %553, %exiting__28 ]
  %543 = icmp sle i64 %542, 3
  br i1 %543, label %body__28, label %exit__28

body__28:                                         ; preds = %header__28
  %544 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %191, i64 %542)
  %545 = bitcast i8* %544 to { { double, double }*, %Array* }**
  %546 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %545
  %547 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %546, i32 0, i32 0
  %548 = load { double, double }*, { double, double }** %547
  %549 = bitcast { double, double }* %548 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %549, i64 -1)
  %550 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %546, i32 0, i32 1
  %551 = load %Array*, %Array** %550
  call void @__quantum__rt__array_update_reference_count(%Array* %551, i64 -1)
  %552 = bitcast { { double, double }*, %Array* }* %546 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %552, i64 -1)
  br label %exiting__28

exiting__28:                                      ; preds = %body__28
  %553 = add i64 %542, 1
  br label %header__28

exit__28:                                         ; preds = %header__28
  call void @__quantum__rt__array_update_reference_count(%Array* %191, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %188, i64 -1)
  %554 = sub i64 %260, 1
  br label %header__29

header__29:                                       ; preds = %exiting__29, %exit__28
  %555 = phi i64 [ 0, %exit__28 ], [ %565, %exiting__29 ]
  %556 = icmp sle i64 %555, %554
  br i1 %556, label %body__29, label %exit__29

body__29:                                         ; preds = %header__29
  %557 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %259, i64 %555)
  %558 = bitcast i8* %557 to { %Array*, %Array* }**
  %559 = load { %Array*, %Array* }*, { %Array*, %Array* }** %558
  %560 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %559, i32 0, i32 0
  %561 = load %Array*, %Array** %560
  call void @__quantum__rt__array_update_reference_count(%Array* %561, i64 -1)
  %562 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %559, i32 0, i32 1
  %563 = load %Array*, %Array** %562
  call void @__quantum__rt__array_update_reference_count(%Array* %563, i64 -1)
  %564 = bitcast { %Array*, %Array* }* %559 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %564, i64 -1)
  br label %exiting__29

exiting__29:                                      ; preds = %body__29
  %565 = add i64 %555, 1
  br label %header__29

exit__29:                                         ; preds = %header__29
  call void @__quantum__rt__array_update_reference_count(%Array* %259, i64 -1)
  %566 = sub i64 %275, 1
  br label %header__30

header__30:                                       ; preds = %exiting__30, %exit__29
  %567 = phi i64 [ 0, %exit__29 ], [ %577, %exiting__30 ]
  %568 = icmp sle i64 %567, %566
  br i1 %568, label %body__30, label %exit__30

body__30:                                         ; preds = %header__30
  %569 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %274, i64 %567)
  %570 = bitcast i8* %569 to { %Array*, %Array* }**
  %571 = load { %Array*, %Array* }*, { %Array*, %Array* }** %570
  %572 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %571, i32 0, i32 0
  %573 = load %Array*, %Array** %572
  call void @__quantum__rt__array_update_reference_count(%Array* %573, i64 -1)
  %574 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %571, i32 0, i32 1
  %575 = load %Array*, %Array** %574
  call void @__quantum__rt__array_update_reference_count(%Array* %575, i64 -1)
  %576 = bitcast { %Array*, %Array* }* %571 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %576, i64 -1)
  br label %exiting__30

exiting__30:                                      ; preds = %body__30
  %577 = add i64 %567, 1
  br label %header__30

exit__30:                                         ; preds = %header__30
  call void @__quantum__rt__array_update_reference_count(%Array* %274, i64 -1)
  %578 = sub i64 %290, 1
  br label %header__31

header__31:                                       ; preds = %exiting__31, %exit__30
  %579 = phi i64 [ 0, %exit__30 ], [ %589, %exiting__31 ]
  %580 = icmp sle i64 %579, %578
  br i1 %580, label %body__31, label %exit__31

body__31:                                         ; preds = %header__31
  %581 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %289, i64 %579)
  %582 = bitcast i8* %581 to { %Array*, %Array* }**
  %583 = load { %Array*, %Array* }*, { %Array*, %Array* }** %582
  %584 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %583, i32 0, i32 0
  %585 = load %Array*, %Array** %584
  call void @__quantum__rt__array_update_reference_count(%Array* %585, i64 -1)
  %586 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %583, i32 0, i32 1
  %587 = load %Array*, %Array** %586
  call void @__quantum__rt__array_update_reference_count(%Array* %587, i64 -1)
  %588 = bitcast { %Array*, %Array* }* %583 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %588, i64 -1)
  br label %exiting__31

exiting__31:                                      ; preds = %body__31
  %589 = add i64 %579, 1
  br label %header__31

exit__31:                                         ; preds = %header__31
  call void @__quantum__rt__array_update_reference_count(%Array* %289, i64 -1)
  %590 = sub i64 %305, 1
  br label %header__32

header__32:                                       ; preds = %exiting__32, %exit__31
  %591 = phi i64 [ 0, %exit__31 ], [ %601, %exiting__32 ]
  %592 = icmp sle i64 %591, %590
  br i1 %592, label %body__32, label %exit__32

body__32:                                         ; preds = %header__32
  %593 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %304, i64 %591)
  %594 = bitcast i8* %593 to { %Array*, %Array* }**
  %595 = load { %Array*, %Array* }*, { %Array*, %Array* }** %594
  %596 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %595, i32 0, i32 0
  %597 = load %Array*, %Array** %596
  call void @__quantum__rt__array_update_reference_count(%Array* %597, i64 -1)
  %598 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %595, i32 0, i32 1
  %599 = load %Array*, %Array** %598
  call void @__quantum__rt__array_update_reference_count(%Array* %599, i64 -1)
  %600 = bitcast { %Array*, %Array* }* %595 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %600, i64 -1)
  br label %exiting__32

exiting__32:                                      ; preds = %body__32
  %601 = add i64 %591, 1
  br label %header__32

exit__32:                                         ; preds = %header__32
  call void @__quantum__rt__array_update_reference_count(%Array* %304, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %318, i64 -1)
  %602 = sub i64 %323, 1
  br label %header__33

header__33:                                       ; preds = %exiting__33, %exit__32
  %603 = phi i64 [ 0, %exit__32 ], [ %614, %exiting__33 ]
  %604 = icmp sle i64 %603, %602
  br i1 %604, label %body__33, label %exit__33

body__33:                                         ; preds = %header__33
  %605 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %322, i64 %603)
  %606 = bitcast i8* %605 to { { double, double }*, %Array* }**
  %607 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %606
  %608 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %607, i32 0, i32 0
  %609 = load { double, double }*, { double, double }** %608
  %610 = bitcast { double, double }* %609 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %610, i64 -1)
  %611 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %607, i32 0, i32 1
  %612 = load %Array*, %Array** %611
  call void @__quantum__rt__array_update_reference_count(%Array* %612, i64 -1)
  %613 = bitcast { { double, double }*, %Array* }* %607 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %613, i64 -1)
  br label %exiting__33

exiting__33:                                      ; preds = %body__33
  %614 = add i64 %603, 1
  br label %header__33

exit__33:                                         ; preds = %header__33
  call void @__quantum__rt__array_update_reference_count(%Array* %322, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %337, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %338, i64 -1)
  ret double %339
}

define { %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %__Item1__, %Array* %__Item2__) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item1__, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item2__, i64 1)
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %1 = bitcast %Tuple* %0 to { %Array*, %Array* }*
  %2 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %1, i32 0, i32 0
  %3 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %1, i32 0, i32 1
  store %Array* %__Item1__, %Array** %2
  store %Array* %__Item2__, %Array** %3
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item1__, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__Item2__, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item1__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__Item2__, i64 -1)
  ret { %Array*, %Array* }* %1
}

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__VariationalQuantumEigensolver__EstimateEnergy__body(i64 %nQubits, { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, { i64, %Array* }* %inputState, double %energyOffset, i64 %nSamples) {
entry:
  %0 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 0
  %ZData = load %Array*, %Array** %0
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ZData)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %13, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZData, i64 %3)
  %6 = bitcast i8* %5 to { %Array*, %Array* }**
  %7 = load { %Array*, %Array* }*, { %Array*, %Array* }** %6
  %8 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %7, i32 0, i32 0
  %9 = load %Array*, %Array** %8
  call void @__quantum__rt__array_update_alias_count(%Array* %9, i64 1)
  %10 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %7, i32 0, i32 1
  %11 = load %Array*, %Array** %10
  call void @__quantum__rt__array_update_alias_count(%Array* %11, i64 1)
  %12 = bitcast { %Array*, %Array* }* %7 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %12, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %13 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %ZData, i64 1)
  %14 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 1
  %ZZData = load %Array*, %Array** %14
  %15 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ZZData)
  %16 = sub i64 %15, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %17 = phi i64 [ 0, %exit__1 ], [ %27, %exiting__2 ]
  %18 = icmp sle i64 %17, %16
  br i1 %18, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZZData, i64 %17)
  %20 = bitcast i8* %19 to { %Array*, %Array* }**
  %21 = load { %Array*, %Array* }*, { %Array*, %Array* }** %20
  %22 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %21, i32 0, i32 0
  %23 = load %Array*, %Array** %22
  call void @__quantum__rt__array_update_alias_count(%Array* %23, i64 1)
  %24 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %21, i32 0, i32 1
  %25 = load %Array*, %Array** %24
  call void @__quantum__rt__array_update_alias_count(%Array* %25, i64 1)
  %26 = bitcast { %Array*, %Array* }* %21 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %26, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %27 = add i64 %17, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %ZZData, i64 1)
  %28 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 2
  %PQandPQQRData = load %Array*, %Array** %28
  %29 = call i64 @__quantum__rt__array_get_size_1d(%Array* %PQandPQQRData)
  %30 = sub i64 %29, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %31 = phi i64 [ 0, %exit__2 ], [ %41, %exiting__3 ]
  %32 = icmp sle i64 %31, %30
  br i1 %32, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %PQandPQQRData, i64 %31)
  %34 = bitcast i8* %33 to { %Array*, %Array* }**
  %35 = load { %Array*, %Array* }*, { %Array*, %Array* }** %34
  %36 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %35, i32 0, i32 0
  %37 = load %Array*, %Array** %36
  call void @__quantum__rt__array_update_alias_count(%Array* %37, i64 1)
  %38 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %35, i32 0, i32 1
  %39 = load %Array*, %Array** %38
  call void @__quantum__rt__array_update_alias_count(%Array* %39, i64 1)
  %40 = bitcast { %Array*, %Array* }* %35 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %40, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %41 = add i64 %31, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %PQandPQQRData, i64 1)
  %42 = getelementptr inbounds { %Array*, %Array*, %Array*, %Array* }, { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 3
  %h0123Data = load %Array*, %Array** %42
  %43 = call i64 @__quantum__rt__array_get_size_1d(%Array* %h0123Data)
  %44 = sub i64 %43, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %45 = phi i64 [ 0, %exit__3 ], [ %55, %exiting__4 ]
  %46 = icmp sle i64 %45, %44
  br i1 %46, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %47 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %h0123Data, i64 %45)
  %48 = bitcast i8* %47 to { %Array*, %Array* }**
  %49 = load { %Array*, %Array* }*, { %Array*, %Array* }** %48
  %50 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %49, i32 0, i32 0
  %51 = load %Array*, %Array** %50
  call void @__quantum__rt__array_update_alias_count(%Array* %51, i64 1)
  %52 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %49, i32 0, i32 1
  %53 = load %Array*, %Array** %52
  call void @__quantum__rt__array_update_alias_count(%Array* %53, i64 1)
  %54 = bitcast { %Array*, %Array* }* %49 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %54, i64 1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %55 = add i64 %45, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_alias_count(%Array* %h0123Data, i64 1)
  %56 = bitcast { %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %56, i64 1)
  %57 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 1
  %inputStateTerms = load %Array*, %Array** %57
  %58 = call i64 @__quantum__rt__array_get_size_1d(%Array* %inputStateTerms)
  %59 = sub i64 %58, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %60 = phi i64 [ 0, %exit__4 ], [ %71, %exiting__5 ]
  %61 = icmp sle i64 %60, %59
  br i1 %61, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %inputStateTerms, i64 %60)
  %63 = bitcast i8* %62 to { { double, double }*, %Array* }**
  %64 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %63
  %65 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %64, i32 0, i32 0
  %66 = load { double, double }*, { double, double }** %65
  %67 = bitcast { double, double }* %66 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %67, i64 1)
  %68 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %64, i32 0, i32 1
  %69 = load %Array*, %Array** %68
  call void @__quantum__rt__array_update_alias_count(%Array* %69, i64 1)
  %70 = bitcast { { double, double }*, %Array* }* %64 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %70, i64 1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %71 = add i64 %60, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_alias_count(%Array* %inputStateTerms, i64 1)
  %72 = bitcast { i64, %Array* }* %inputState to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %72, i64 1)
  %energy = alloca double
  store double 0.000000e+00, double* %energy
  %73 = getelementptr inbounds { i64, %Array* }, { i64, %Array* }* %inputState, i32 0, i32 0
  %inputStateType = load i64, i64* %73
  %74 = sub i64 %58, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %75 = phi i64 [ 0, %exit__5 ], [ %86, %exiting__6 ]
  %76 = icmp sle i64 %75, %74
  br i1 %76, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %77 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %inputStateTerms, i64 %75)
  %78 = bitcast i8* %77 to { { double, double }*, %Array* }**
  %79 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %78
  %80 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %79, i32 0, i32 0
  %81 = load { double, double }*, { double, double }** %80
  %82 = bitcast { double, double }* %81 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %82, i64 1)
  %83 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %79, i32 0, i32 1
  %84 = load %Array*, %Array** %83
  call void @__quantum__rt__array_update_alias_count(%Array* %84, i64 1)
  %85 = bitcast { { double, double }*, %Array* }* %79 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %85, i64 1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %86 = add i64 %75, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_alias_count(%Array* %inputStateTerms, i64 1)
  %87 = sub i64 %1, 1
  br label %header__7

header__7:                                        ; preds = %exiting__7, %exit__6
  %88 = phi i64 [ 0, %exit__6 ], [ %98, %exiting__7 ]
  %89 = icmp sle i64 %88, %87
  br i1 %89, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %90 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZData, i64 %88)
  %91 = bitcast i8* %90 to { %Array*, %Array* }**
  %92 = load { %Array*, %Array* }*, { %Array*, %Array* }** %91
  %93 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %92, i32 0, i32 0
  %94 = load %Array*, %Array** %93
  call void @__quantum__rt__array_update_alias_count(%Array* %94, i64 1)
  %95 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %92, i32 0, i32 1
  %96 = load %Array*, %Array** %95
  call void @__quantum__rt__array_update_alias_count(%Array* %96, i64 1)
  %97 = bitcast { %Array*, %Array* }* %92 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %97, i64 1)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %98 = add i64 %88, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  call void @__quantum__rt__array_update_alias_count(%Array* %ZData, i64 1)
  %99 = sub i64 %15, 1
  br label %header__8

header__8:                                        ; preds = %exiting__8, %exit__7
  %100 = phi i64 [ 0, %exit__7 ], [ %110, %exiting__8 ]
  %101 = icmp sle i64 %100, %99
  br i1 %101, label %body__8, label %exit__8

body__8:                                          ; preds = %header__8
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZZData, i64 %100)
  %103 = bitcast i8* %102 to { %Array*, %Array* }**
  %104 = load { %Array*, %Array* }*, { %Array*, %Array* }** %103
  %105 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %104, i32 0, i32 0
  %106 = load %Array*, %Array** %105
  call void @__quantum__rt__array_update_alias_count(%Array* %106, i64 1)
  %107 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %104, i32 0, i32 1
  %108 = load %Array*, %Array** %107
  call void @__quantum__rt__array_update_alias_count(%Array* %108, i64 1)
  %109 = bitcast { %Array*, %Array* }* %104 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %109, i64 1)
  br label %exiting__8

exiting__8:                                       ; preds = %body__8
  %110 = add i64 %100, 1
  br label %header__8

exit__8:                                          ; preds = %header__8
  call void @__quantum__rt__array_update_alias_count(%Array* %ZZData, i64 1)
  %111 = sub i64 %29, 1
  br label %header__9

header__9:                                        ; preds = %exiting__9, %exit__8
  %112 = phi i64 [ 0, %exit__8 ], [ %122, %exiting__9 ]
  %113 = icmp sle i64 %112, %111
  br i1 %113, label %body__9, label %exit__9

body__9:                                          ; preds = %header__9
  %114 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %PQandPQQRData, i64 %112)
  %115 = bitcast i8* %114 to { %Array*, %Array* }**
  %116 = load { %Array*, %Array* }*, { %Array*, %Array* }** %115
  %117 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %116, i32 0, i32 0
  %118 = load %Array*, %Array** %117
  call void @__quantum__rt__array_update_alias_count(%Array* %118, i64 1)
  %119 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %116, i32 0, i32 1
  %120 = load %Array*, %Array** %119
  call void @__quantum__rt__array_update_alias_count(%Array* %120, i64 1)
  %121 = bitcast { %Array*, %Array* }* %116 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %121, i64 1)
  br label %exiting__9

exiting__9:                                       ; preds = %body__9
  %122 = add i64 %112, 1
  br label %header__9

exit__9:                                          ; preds = %header__9
  call void @__quantum__rt__array_update_alias_count(%Array* %PQandPQQRData, i64 1)
  %123 = sub i64 %43, 1
  br label %header__10

header__10:                                       ; preds = %exiting__10, %exit__9
  %124 = phi i64 [ 0, %exit__9 ], [ %134, %exiting__10 ]
  %125 = icmp sle i64 %124, %123
  br i1 %125, label %body__10, label %exit__10

body__10:                                         ; preds = %header__10
  %126 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %h0123Data, i64 %124)
  %127 = bitcast i8* %126 to { %Array*, %Array* }**
  %128 = load { %Array*, %Array* }*, { %Array*, %Array* }** %127
  %129 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %128, i32 0, i32 0
  %130 = load %Array*, %Array** %129
  call void @__quantum__rt__array_update_alias_count(%Array* %130, i64 1)
  %131 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %128, i32 0, i32 1
  %132 = load %Array*, %Array** %131
  call void @__quantum__rt__array_update_alias_count(%Array* %132, i64 1)
  %133 = bitcast { %Array*, %Array* }* %128 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %133, i64 1)
  br label %exiting__10

exiting__10:                                      ; preds = %body__10
  %134 = add i64 %124, 1
  br label %header__10

exit__10:                                         ; preds = %header__10
  call void @__quantum__rt__array_update_alias_count(%Array* %h0123Data, i64 1)
  %hamiltonianTermArray = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %135 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 0)
  %136 = bitcast i8* %135 to %Array**
  %137 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 1)
  %138 = bitcast i8* %137 to %Array**
  %139 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 2)
  %140 = bitcast i8* %139 to %Array**
  %141 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 3)
  %142 = bitcast i8* %141 to %Array**
  store %Array* %ZData, %Array** %136
  store %Array* %ZZData, %Array** %138
  store %Array* %PQandPQQRData, %Array** %140
  store %Array* %h0123Data, %Array** %142
  br label %header__11

header__11:                                       ; preds = %exiting__11, %exit__10
  %143 = phi i64 [ 0, %exit__10 ], [ %150, %exiting__11 ]
  %144 = icmp sle i64 %143, 3
  br i1 %144, label %body__11, label %exit__11

body__11:                                         ; preds = %header__11
  %145 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 %143)
  %146 = bitcast i8* %145 to %Array**
  %147 = load %Array*, %Array** %146
  %148 = call i64 @__quantum__rt__array_get_size_1d(%Array* %147)
  %149 = sub i64 %148, 1
  br label %header__12

exiting__11:                                      ; preds = %exit__12
  %150 = add i64 %143, 1
  br label %header__11

exit__11:                                         ; preds = %header__11
  call void @__quantum__rt__array_update_alias_count(%Array* %hamiltonianTermArray, i64 1)
  %151 = add i64 %1, %15
  %152 = add i64 %151, %29
  %nTerms = add i64 %152, %43
  br label %header__13

header__12:                                       ; preds = %exiting__12, %body__11
  %153 = phi i64 [ 0, %body__11 ], [ %163, %exiting__12 ]
  %154 = icmp sle i64 %153, %149
  br i1 %154, label %body__12, label %exit__12

body__12:                                         ; preds = %header__12
  %155 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %147, i64 %153)
  %156 = bitcast i8* %155 to { %Array*, %Array* }**
  %157 = load { %Array*, %Array* }*, { %Array*, %Array* }** %156
  %158 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %157, i32 0, i32 0
  %159 = load %Array*, %Array** %158
  call void @__quantum__rt__array_update_alias_count(%Array* %159, i64 1)
  %160 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %157, i32 0, i32 1
  %161 = load %Array*, %Array** %160
  call void @__quantum__rt__array_update_alias_count(%Array* %161, i64 1)
  %162 = bitcast { %Array*, %Array* }* %157 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %162, i64 1)
  br label %exiting__12

exiting__12:                                      ; preds = %body__12
  %163 = add i64 %153, 1
  br label %header__12

exit__12:                                         ; preds = %header__12
  call void @__quantum__rt__array_update_alias_count(%Array* %147, i64 1)
  br label %exiting__11

header__13:                                       ; preds = %exiting__13, %exit__11
  %termType = phi i64 [ 0, %exit__11 ], [ %169, %exiting__13 ]
  %164 = icmp sle i64 %termType, 3
  br i1 %164, label %body__13, label %exit__13

body__13:                                         ; preds = %header__13
  %165 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 %termType)
  %166 = bitcast i8* %165 to %Array**
  %hamiltonianTerms = load %Array*, %Array** %166
  %167 = call i64 @__quantum__rt__array_get_size_1d(%Array* %hamiltonianTerms)
  %168 = sub i64 %167, 1
  br label %header__14

exiting__13:                                      ; preds = %exit__19
  %169 = add i64 %termType, 1
  br label %header__13

exit__13:                                         ; preds = %header__13
  %170 = load double, double* %energy
  %171 = sub i64 %1, 1
  br label %header__20

header__14:                                       ; preds = %exiting__14, %body__13
  %172 = phi i64 [ 0, %body__13 ], [ %182, %exiting__14 ]
  %173 = icmp sle i64 %172, %168
  br i1 %173, label %body__14, label %exit__14

body__14:                                         ; preds = %header__14
  %174 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTerms, i64 %172)
  %175 = bitcast i8* %174 to { %Array*, %Array* }**
  %176 = load { %Array*, %Array* }*, { %Array*, %Array* }** %175
  %177 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %176, i32 0, i32 0
  %178 = load %Array*, %Array** %177
  call void @__quantum__rt__array_update_alias_count(%Array* %178, i64 1)
  %179 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %176, i32 0, i32 1
  %180 = load %Array*, %Array** %179
  call void @__quantum__rt__array_update_alias_count(%Array* %180, i64 1)
  %181 = bitcast { %Array*, %Array* }* %176 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %181, i64 1)
  br label %exiting__14

exiting__14:                                      ; preds = %body__14
  %182 = add i64 %172, 1
  br label %header__14

exit__14:                                         ; preds = %header__14
  call void @__quantum__rt__array_update_alias_count(%Array* %hamiltonianTerms, i64 1)
  %183 = sub i64 %167, 1
  br label %header__15

header__15:                                       ; preds = %exiting__15, %exit__14
  %184 = phi i64 [ 0, %exit__14 ], [ %193, %exiting__15 ]
  %185 = icmp sle i64 %184, %183
  br i1 %185, label %body__15, label %exit__15

body__15:                                         ; preds = %header__15
  %186 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTerms, i64 %184)
  %187 = bitcast i8* %186 to { %Array*, %Array* }**
  %hamiltonianTerm = load { %Array*, %Array* }*, { %Array*, %Array* }** %187
  %188 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %hamiltonianTerm, i32 0, i32 0
  %qubitIndices = load %Array*, %Array** %188
  call void @__quantum__rt__array_update_alias_count(%Array* %qubitIndices, i64 1)
  %189 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %hamiltonianTerm, i32 0, i32 1
  %coefficient = load %Array*, %Array** %189
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficient, i64 1)
  %190 = bitcast { %Array*, %Array* }* %hamiltonianTerm to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %190, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubitIndices, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficient, i64 1)
  %measOps = call %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__VQEMeasurementOperators__body(i64 %nQubits, %Array* %qubitIndices, i64 %termType)
  %191 = call i64 @__quantum__rt__array_get_size_1d(%Array* %measOps)
  %192 = sub i64 %191, 1
  br label %header__16

exiting__15:                                      ; preds = %exit__18
  %193 = add i64 %184, 1
  br label %header__15

exit__15:                                         ; preds = %header__15
  %194 = sub i64 %167, 1
  br label %header__19

header__16:                                       ; preds = %exiting__16, %body__15
  %195 = phi i64 [ 0, %body__15 ], [ %200, %exiting__16 ]
  %196 = icmp sle i64 %195, %192
  br i1 %196, label %body__16, label %exit__16

body__16:                                         ; preds = %header__16
  %197 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %measOps, i64 %195)
  %198 = bitcast i8* %197 to %Array**
  %199 = load %Array*, %Array** %198
  call void @__quantum__rt__array_update_alias_count(%Array* %199, i64 1)
  br label %exiting__16

exiting__16:                                      ; preds = %body__16
  %200 = add i64 %195, 1
  br label %header__16

exit__16:                                         ; preds = %header__16
  call void @__quantum__rt__array_update_alias_count(%Array* %measOps, i64 1)
  %coefficients = call %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__ExpandedCoefficients__body(%Array* %coefficient, i64 %termType)
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficients, i64 1)
  %jwTermEnergy = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__SumTermExpectation__body({ i64, %Array* }* %inputState, %Array* %measOps, %Array* %coefficients, i64 %nQubits, i64 %nSamples)
  %201 = load double, double* %energy
  %202 = fadd double %201, %jwTermEnergy
  store double %202, double* %energy
  call void @__quantum__rt__array_update_alias_count(%Array* %qubitIndices, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficient, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %190, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubitIndices, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficient, i64 -1)
  %203 = sub i64 %191, 1
  br label %header__17

header__17:                                       ; preds = %exiting__17, %exit__16
  %204 = phi i64 [ 0, %exit__16 ], [ %209, %exiting__17 ]
  %205 = icmp sle i64 %204, %203
  br i1 %205, label %body__17, label %exit__17

body__17:                                         ; preds = %header__17
  %206 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %measOps, i64 %204)
  %207 = bitcast i8* %206 to %Array**
  %208 = load %Array*, %Array** %207
  call void @__quantum__rt__array_update_alias_count(%Array* %208, i64 -1)
  br label %exiting__17

exiting__17:                                      ; preds = %body__17
  %209 = add i64 %204, 1
  br label %header__17

exit__17:                                         ; preds = %header__17
  call void @__quantum__rt__array_update_alias_count(%Array* %measOps, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %coefficients, i64 -1)
  %210 = sub i64 %191, 1
  br label %header__18

header__18:                                       ; preds = %exiting__18, %exit__17
  %211 = phi i64 [ 0, %exit__17 ], [ %216, %exiting__18 ]
  %212 = icmp sle i64 %211, %210
  br i1 %212, label %body__18, label %exit__18

body__18:                                         ; preds = %header__18
  %213 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %measOps, i64 %211)
  %214 = bitcast i8* %213 to %Array**
  %215 = load %Array*, %Array** %214
  call void @__quantum__rt__array_update_reference_count(%Array* %215, i64 -1)
  br label %exiting__18

exiting__18:                                      ; preds = %body__18
  %216 = add i64 %211, 1
  br label %header__18

exit__18:                                         ; preds = %header__18
  call void @__quantum__rt__array_update_reference_count(%Array* %measOps, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %coefficients, i64 -1)
  br label %exiting__15

header__19:                                       ; preds = %exiting__19, %exit__15
  %217 = phi i64 [ 0, %exit__15 ], [ %227, %exiting__19 ]
  %218 = icmp sle i64 %217, %194
  br i1 %218, label %body__19, label %exit__19

body__19:                                         ; preds = %header__19
  %219 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTerms, i64 %217)
  %220 = bitcast i8* %219 to { %Array*, %Array* }**
  %221 = load { %Array*, %Array* }*, { %Array*, %Array* }** %220
  %222 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %221, i32 0, i32 0
  %223 = load %Array*, %Array** %222
  call void @__quantum__rt__array_update_alias_count(%Array* %223, i64 -1)
  %224 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %221, i32 0, i32 1
  %225 = load %Array*, %Array** %224
  call void @__quantum__rt__array_update_alias_count(%Array* %225, i64 -1)
  %226 = bitcast { %Array*, %Array* }* %221 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %226, i64 -1)
  br label %exiting__19

exiting__19:                                      ; preds = %body__19
  %227 = add i64 %217, 1
  br label %header__19

exit__19:                                         ; preds = %header__19
  call void @__quantum__rt__array_update_alias_count(%Array* %hamiltonianTerms, i64 -1)
  br label %exiting__13

header__20:                                       ; preds = %exiting__20, %exit__13
  %228 = phi i64 [ 0, %exit__13 ], [ %238, %exiting__20 ]
  %229 = icmp sle i64 %228, %171
  br i1 %229, label %body__20, label %exit__20

body__20:                                         ; preds = %header__20
  %230 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZData, i64 %228)
  %231 = bitcast i8* %230 to { %Array*, %Array* }**
  %232 = load { %Array*, %Array* }*, { %Array*, %Array* }** %231
  %233 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %232, i32 0, i32 0
  %234 = load %Array*, %Array** %233
  call void @__quantum__rt__array_update_reference_count(%Array* %234, i64 1)
  %235 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %232, i32 0, i32 1
  %236 = load %Array*, %Array** %235
  call void @__quantum__rt__array_update_reference_count(%Array* %236, i64 1)
  %237 = bitcast { %Array*, %Array* }* %232 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %237, i64 1)
  br label %exiting__20

exiting__20:                                      ; preds = %body__20
  %238 = add i64 %228, 1
  br label %header__20

exit__20:                                         ; preds = %header__20
  call void @__quantum__rt__array_update_reference_count(%Array* %ZData, i64 1)
  %239 = sub i64 %15, 1
  br label %header__21

header__21:                                       ; preds = %exiting__21, %exit__20
  %240 = phi i64 [ 0, %exit__20 ], [ %250, %exiting__21 ]
  %241 = icmp sle i64 %240, %239
  br i1 %241, label %body__21, label %exit__21

body__21:                                         ; preds = %header__21
  %242 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZZData, i64 %240)
  %243 = bitcast i8* %242 to { %Array*, %Array* }**
  %244 = load { %Array*, %Array* }*, { %Array*, %Array* }** %243
  %245 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %244, i32 0, i32 0
  %246 = load %Array*, %Array** %245
  call void @__quantum__rt__array_update_reference_count(%Array* %246, i64 1)
  %247 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %244, i32 0, i32 1
  %248 = load %Array*, %Array** %247
  call void @__quantum__rt__array_update_reference_count(%Array* %248, i64 1)
  %249 = bitcast { %Array*, %Array* }* %244 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %249, i64 1)
  br label %exiting__21

exiting__21:                                      ; preds = %body__21
  %250 = add i64 %240, 1
  br label %header__21

exit__21:                                         ; preds = %header__21
  call void @__quantum__rt__array_update_reference_count(%Array* %ZZData, i64 1)
  %251 = sub i64 %29, 1
  br label %header__22

header__22:                                       ; preds = %exiting__22, %exit__21
  %252 = phi i64 [ 0, %exit__21 ], [ %262, %exiting__22 ]
  %253 = icmp sle i64 %252, %251
  br i1 %253, label %body__22, label %exit__22

body__22:                                         ; preds = %header__22
  %254 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %PQandPQQRData, i64 %252)
  %255 = bitcast i8* %254 to { %Array*, %Array* }**
  %256 = load { %Array*, %Array* }*, { %Array*, %Array* }** %255
  %257 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %256, i32 0, i32 0
  %258 = load %Array*, %Array** %257
  call void @__quantum__rt__array_update_reference_count(%Array* %258, i64 1)
  %259 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %256, i32 0, i32 1
  %260 = load %Array*, %Array** %259
  call void @__quantum__rt__array_update_reference_count(%Array* %260, i64 1)
  %261 = bitcast { %Array*, %Array* }* %256 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %261, i64 1)
  br label %exiting__22

exiting__22:                                      ; preds = %body__22
  %262 = add i64 %252, 1
  br label %header__22

exit__22:                                         ; preds = %header__22
  call void @__quantum__rt__array_update_reference_count(%Array* %PQandPQQRData, i64 1)
  %263 = sub i64 %43, 1
  br label %header__23

header__23:                                       ; preds = %exiting__23, %exit__22
  %264 = phi i64 [ 0, %exit__22 ], [ %274, %exiting__23 ]
  %265 = icmp sle i64 %264, %263
  br i1 %265, label %body__23, label %exit__23

body__23:                                         ; preds = %header__23
  %266 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %h0123Data, i64 %264)
  %267 = bitcast i8* %266 to { %Array*, %Array* }**
  %268 = load { %Array*, %Array* }*, { %Array*, %Array* }** %267
  %269 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %268, i32 0, i32 0
  %270 = load %Array*, %Array** %269
  call void @__quantum__rt__array_update_reference_count(%Array* %270, i64 1)
  %271 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %268, i32 0, i32 1
  %272 = load %Array*, %Array** %271
  call void @__quantum__rt__array_update_reference_count(%Array* %272, i64 1)
  %273 = bitcast { %Array*, %Array* }* %268 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %273, i64 1)
  br label %exiting__23

exiting__23:                                      ; preds = %body__23
  %274 = add i64 %264, 1
  br label %header__23

exit__23:                                         ; preds = %header__23
  call void @__quantum__rt__array_update_reference_count(%Array* %h0123Data, i64 1)
  %275 = sub i64 %1, 1
  br label %header__24

header__24:                                       ; preds = %exiting__24, %exit__23
  %276 = phi i64 [ 0, %exit__23 ], [ %286, %exiting__24 ]
  %277 = icmp sle i64 %276, %275
  br i1 %277, label %body__24, label %exit__24

body__24:                                         ; preds = %header__24
  %278 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZData, i64 %276)
  %279 = bitcast i8* %278 to { %Array*, %Array* }**
  %280 = load { %Array*, %Array* }*, { %Array*, %Array* }** %279
  %281 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %280, i32 0, i32 0
  %282 = load %Array*, %Array** %281
  call void @__quantum__rt__array_update_alias_count(%Array* %282, i64 -1)
  %283 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %280, i32 0, i32 1
  %284 = load %Array*, %Array** %283
  call void @__quantum__rt__array_update_alias_count(%Array* %284, i64 -1)
  %285 = bitcast { %Array*, %Array* }* %280 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %285, i64 -1)
  br label %exiting__24

exiting__24:                                      ; preds = %body__24
  %286 = add i64 %276, 1
  br label %header__24

exit__24:                                         ; preds = %header__24
  call void @__quantum__rt__array_update_alias_count(%Array* %ZData, i64 -1)
  %287 = sub i64 %15, 1
  br label %header__25

header__25:                                       ; preds = %exiting__25, %exit__24
  %288 = phi i64 [ 0, %exit__24 ], [ %298, %exiting__25 ]
  %289 = icmp sle i64 %288, %287
  br i1 %289, label %body__25, label %exit__25

body__25:                                         ; preds = %header__25
  %290 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZZData, i64 %288)
  %291 = bitcast i8* %290 to { %Array*, %Array* }**
  %292 = load { %Array*, %Array* }*, { %Array*, %Array* }** %291
  %293 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %292, i32 0, i32 0
  %294 = load %Array*, %Array** %293
  call void @__quantum__rt__array_update_alias_count(%Array* %294, i64 -1)
  %295 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %292, i32 0, i32 1
  %296 = load %Array*, %Array** %295
  call void @__quantum__rt__array_update_alias_count(%Array* %296, i64 -1)
  %297 = bitcast { %Array*, %Array* }* %292 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %297, i64 -1)
  br label %exiting__25

exiting__25:                                      ; preds = %body__25
  %298 = add i64 %288, 1
  br label %header__25

exit__25:                                         ; preds = %header__25
  call void @__quantum__rt__array_update_alias_count(%Array* %ZZData, i64 -1)
  %299 = sub i64 %29, 1
  br label %header__26

header__26:                                       ; preds = %exiting__26, %exit__25
  %300 = phi i64 [ 0, %exit__25 ], [ %310, %exiting__26 ]
  %301 = icmp sle i64 %300, %299
  br i1 %301, label %body__26, label %exit__26

body__26:                                         ; preds = %header__26
  %302 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %PQandPQQRData, i64 %300)
  %303 = bitcast i8* %302 to { %Array*, %Array* }**
  %304 = load { %Array*, %Array* }*, { %Array*, %Array* }** %303
  %305 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %304, i32 0, i32 0
  %306 = load %Array*, %Array** %305
  call void @__quantum__rt__array_update_alias_count(%Array* %306, i64 -1)
  %307 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %304, i32 0, i32 1
  %308 = load %Array*, %Array** %307
  call void @__quantum__rt__array_update_alias_count(%Array* %308, i64 -1)
  %309 = bitcast { %Array*, %Array* }* %304 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %309, i64 -1)
  br label %exiting__26

exiting__26:                                      ; preds = %body__26
  %310 = add i64 %300, 1
  br label %header__26

exit__26:                                         ; preds = %header__26
  call void @__quantum__rt__array_update_alias_count(%Array* %PQandPQQRData, i64 -1)
  %311 = sub i64 %43, 1
  br label %header__27

header__27:                                       ; preds = %exiting__27, %exit__26
  %312 = phi i64 [ 0, %exit__26 ], [ %322, %exiting__27 ]
  %313 = icmp sle i64 %312, %311
  br i1 %313, label %body__27, label %exit__27

body__27:                                         ; preds = %header__27
  %314 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %h0123Data, i64 %312)
  %315 = bitcast i8* %314 to { %Array*, %Array* }**
  %316 = load { %Array*, %Array* }*, { %Array*, %Array* }** %315
  %317 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %316, i32 0, i32 0
  %318 = load %Array*, %Array** %317
  call void @__quantum__rt__array_update_alias_count(%Array* %318, i64 -1)
  %319 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %316, i32 0, i32 1
  %320 = load %Array*, %Array** %319
  call void @__quantum__rt__array_update_alias_count(%Array* %320, i64 -1)
  %321 = bitcast { %Array*, %Array* }* %316 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %321, i64 -1)
  br label %exiting__27

exiting__27:                                      ; preds = %body__27
  %322 = add i64 %312, 1
  br label %header__27

exit__27:                                         ; preds = %header__27
  call void @__quantum__rt__array_update_alias_count(%Array* %h0123Data, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %56, i64 -1)
  %323 = sub i64 %58, 1
  br label %header__28

header__28:                                       ; preds = %exiting__28, %exit__27
  %324 = phi i64 [ 0, %exit__27 ], [ %335, %exiting__28 ]
  %325 = icmp sle i64 %324, %323
  br i1 %325, label %body__28, label %exit__28

body__28:                                         ; preds = %header__28
  %326 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %inputStateTerms, i64 %324)
  %327 = bitcast i8* %326 to { { double, double }*, %Array* }**
  %328 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %327
  %329 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %328, i32 0, i32 0
  %330 = load { double, double }*, { double, double }** %329
  %331 = bitcast { double, double }* %330 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %331, i64 -1)
  %332 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %328, i32 0, i32 1
  %333 = load %Array*, %Array** %332
  call void @__quantum__rt__array_update_alias_count(%Array* %333, i64 -1)
  %334 = bitcast { { double, double }*, %Array* }* %328 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %334, i64 -1)
  br label %exiting__28

exiting__28:                                      ; preds = %body__28
  %335 = add i64 %324, 1
  br label %header__28

exit__28:                                         ; preds = %header__28
  call void @__quantum__rt__array_update_alias_count(%Array* %inputStateTerms, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %72, i64 -1)
  %336 = sub i64 %58, 1
  br label %header__29

header__29:                                       ; preds = %exiting__29, %exit__28
  %337 = phi i64 [ 0, %exit__28 ], [ %348, %exiting__29 ]
  %338 = icmp sle i64 %337, %336
  br i1 %338, label %body__29, label %exit__29

body__29:                                         ; preds = %header__29
  %339 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %inputStateTerms, i64 %337)
  %340 = bitcast i8* %339 to { { double, double }*, %Array* }**
  %341 = load { { double, double }*, %Array* }*, { { double, double }*, %Array* }** %340
  %342 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %341, i32 0, i32 0
  %343 = load { double, double }*, { double, double }** %342
  %344 = bitcast { double, double }* %343 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %344, i64 -1)
  %345 = getelementptr inbounds { { double, double }*, %Array* }, { { double, double }*, %Array* }* %341, i32 0, i32 1
  %346 = load %Array*, %Array** %345
  call void @__quantum__rt__array_update_alias_count(%Array* %346, i64 -1)
  %347 = bitcast { { double, double }*, %Array* }* %341 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %347, i64 -1)
  br label %exiting__29

exiting__29:                                      ; preds = %body__29
  %348 = add i64 %337, 1
  br label %header__29

exit__29:                                         ; preds = %header__29
  call void @__quantum__rt__array_update_alias_count(%Array* %inputStateTerms, i64 -1)
  %349 = sub i64 %1, 1
  br label %header__30

header__30:                                       ; preds = %exiting__30, %exit__29
  %350 = phi i64 [ 0, %exit__29 ], [ %360, %exiting__30 ]
  %351 = icmp sle i64 %350, %349
  br i1 %351, label %body__30, label %exit__30

body__30:                                         ; preds = %header__30
  %352 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZData, i64 %350)
  %353 = bitcast i8* %352 to { %Array*, %Array* }**
  %354 = load { %Array*, %Array* }*, { %Array*, %Array* }** %353
  %355 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %354, i32 0, i32 0
  %356 = load %Array*, %Array** %355
  call void @__quantum__rt__array_update_alias_count(%Array* %356, i64 -1)
  %357 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %354, i32 0, i32 1
  %358 = load %Array*, %Array** %357
  call void @__quantum__rt__array_update_alias_count(%Array* %358, i64 -1)
  %359 = bitcast { %Array*, %Array* }* %354 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %359, i64 -1)
  br label %exiting__30

exiting__30:                                      ; preds = %body__30
  %360 = add i64 %350, 1
  br label %header__30

exit__30:                                         ; preds = %header__30
  call void @__quantum__rt__array_update_alias_count(%Array* %ZData, i64 -1)
  %361 = sub i64 %15, 1
  br label %header__31

header__31:                                       ; preds = %exiting__31, %exit__30
  %362 = phi i64 [ 0, %exit__30 ], [ %372, %exiting__31 ]
  %363 = icmp sle i64 %362, %361
  br i1 %363, label %body__31, label %exit__31

body__31:                                         ; preds = %header__31
  %364 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ZZData, i64 %362)
  %365 = bitcast i8* %364 to { %Array*, %Array* }**
  %366 = load { %Array*, %Array* }*, { %Array*, %Array* }** %365
  %367 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %366, i32 0, i32 0
  %368 = load %Array*, %Array** %367
  call void @__quantum__rt__array_update_alias_count(%Array* %368, i64 -1)
  %369 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %366, i32 0, i32 1
  %370 = load %Array*, %Array** %369
  call void @__quantum__rt__array_update_alias_count(%Array* %370, i64 -1)
  %371 = bitcast { %Array*, %Array* }* %366 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %371, i64 -1)
  br label %exiting__31

exiting__31:                                      ; preds = %body__31
  %372 = add i64 %362, 1
  br label %header__31

exit__31:                                         ; preds = %header__31
  call void @__quantum__rt__array_update_alias_count(%Array* %ZZData, i64 -1)
  %373 = sub i64 %29, 1
  br label %header__32

header__32:                                       ; preds = %exiting__32, %exit__31
  %374 = phi i64 [ 0, %exit__31 ], [ %384, %exiting__32 ]
  %375 = icmp sle i64 %374, %373
  br i1 %375, label %body__32, label %exit__32

body__32:                                         ; preds = %header__32
  %376 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %PQandPQQRData, i64 %374)
  %377 = bitcast i8* %376 to { %Array*, %Array* }**
  %378 = load { %Array*, %Array* }*, { %Array*, %Array* }** %377
  %379 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %378, i32 0, i32 0
  %380 = load %Array*, %Array** %379
  call void @__quantum__rt__array_update_alias_count(%Array* %380, i64 -1)
  %381 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %378, i32 0, i32 1
  %382 = load %Array*, %Array** %381
  call void @__quantum__rt__array_update_alias_count(%Array* %382, i64 -1)
  %383 = bitcast { %Array*, %Array* }* %378 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %383, i64 -1)
  br label %exiting__32

exiting__32:                                      ; preds = %body__32
  %384 = add i64 %374, 1
  br label %header__32

exit__32:                                         ; preds = %header__32
  call void @__quantum__rt__array_update_alias_count(%Array* %PQandPQQRData, i64 -1)
  %385 = sub i64 %43, 1
  br label %header__33

header__33:                                       ; preds = %exiting__33, %exit__32
  %386 = phi i64 [ 0, %exit__32 ], [ %396, %exiting__33 ]
  %387 = icmp sle i64 %386, %385
  br i1 %387, label %body__33, label %exit__33

body__33:                                         ; preds = %header__33
  %388 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %h0123Data, i64 %386)
  %389 = bitcast i8* %388 to { %Array*, %Array* }**
  %390 = load { %Array*, %Array* }*, { %Array*, %Array* }** %389
  %391 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %390, i32 0, i32 0
  %392 = load %Array*, %Array** %391
  call void @__quantum__rt__array_update_alias_count(%Array* %392, i64 -1)
  %393 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %390, i32 0, i32 1
  %394 = load %Array*, %Array** %393
  call void @__quantum__rt__array_update_alias_count(%Array* %394, i64 -1)
  %395 = bitcast { %Array*, %Array* }* %390 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %395, i64 -1)
  br label %exiting__33

exiting__33:                                      ; preds = %body__33
  %396 = add i64 %386, 1
  br label %header__33

exit__33:                                         ; preds = %header__33
  call void @__quantum__rt__array_update_alias_count(%Array* %h0123Data, i64 -1)
  br label %header__34

header__34:                                       ; preds = %exiting__34, %exit__33
  %397 = phi i64 [ 0, %exit__33 ], [ %404, %exiting__34 ]
  %398 = icmp sle i64 %397, 3
  br i1 %398, label %body__34, label %exit__34

body__34:                                         ; preds = %header__34
  %399 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 %397)
  %400 = bitcast i8* %399 to %Array**
  %401 = load %Array*, %Array** %400
  %402 = call i64 @__quantum__rt__array_get_size_1d(%Array* %401)
  %403 = sub i64 %402, 1
  br label %header__35

exiting__34:                                      ; preds = %exit__35
  %404 = add i64 %397, 1
  br label %header__34

exit__34:                                         ; preds = %header__34
  call void @__quantum__rt__array_update_alias_count(%Array* %hamiltonianTermArray, i64 -1)
  br label %header__36

header__35:                                       ; preds = %exiting__35, %body__34
  %405 = phi i64 [ 0, %body__34 ], [ %415, %exiting__35 ]
  %406 = icmp sle i64 %405, %403
  br i1 %406, label %body__35, label %exit__35

body__35:                                         ; preds = %header__35
  %407 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %401, i64 %405)
  %408 = bitcast i8* %407 to { %Array*, %Array* }**
  %409 = load { %Array*, %Array* }*, { %Array*, %Array* }** %408
  %410 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %409, i32 0, i32 0
  %411 = load %Array*, %Array** %410
  call void @__quantum__rt__array_update_alias_count(%Array* %411, i64 -1)
  %412 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %409, i32 0, i32 1
  %413 = load %Array*, %Array** %412
  call void @__quantum__rt__array_update_alias_count(%Array* %413, i64 -1)
  %414 = bitcast { %Array*, %Array* }* %409 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %414, i64 -1)
  br label %exiting__35

exiting__35:                                      ; preds = %body__35
  %415 = add i64 %405, 1
  br label %header__35

exit__35:                                         ; preds = %header__35
  call void @__quantum__rt__array_update_alias_count(%Array* %401, i64 -1)
  br label %exiting__34

header__36:                                       ; preds = %exiting__36, %exit__34
  %416 = phi i64 [ 0, %exit__34 ], [ %423, %exiting__36 ]
  %417 = icmp sle i64 %416, 3
  br i1 %417, label %body__36, label %exit__36

body__36:                                         ; preds = %header__36
  %418 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 %416)
  %419 = bitcast i8* %418 to %Array**
  %420 = load %Array*, %Array** %419
  %421 = call i64 @__quantum__rt__array_get_size_1d(%Array* %420)
  %422 = sub i64 %421, 1
  br label %header__37

exiting__36:                                      ; preds = %exit__37
  %423 = add i64 %416, 1
  br label %header__36

exit__36:                                         ; preds = %header__36
  call void @__quantum__rt__array_update_reference_count(%Array* %hamiltonianTermArray, i64 -1)
  ret double %170

header__37:                                       ; preds = %exiting__37, %body__36
  %424 = phi i64 [ 0, %body__36 ], [ %434, %exiting__37 ]
  %425 = icmp sle i64 %424, %422
  br i1 %425, label %body__37, label %exit__37

body__37:                                         ; preds = %header__37
  %426 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %420, i64 %424)
  %427 = bitcast i8* %426 to { %Array*, %Array* }**
  %428 = load { %Array*, %Array* }*, { %Array*, %Array* }** %427
  %429 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %428, i32 0, i32 0
  %430 = load %Array*, %Array** %429
  call void @__quantum__rt__array_update_reference_count(%Array* %430, i64 -1)
  %431 = getelementptr inbounds { %Array*, %Array* }, { %Array*, %Array* }* %428, i32 0, i32 1
  %432 = load %Array*, %Array** %431
  call void @__quantum__rt__array_update_reference_count(%Array* %432, i64 -1)
  %433 = bitcast { %Array*, %Array* }* %428 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %433, i64 -1)
  br label %exiting__37

exiting__37:                                      ; preds = %body__37
  %434 = add i64 %424, 1
  br label %header__37

exit__37:                                         ; preds = %header__37
  call void @__quantum__rt__array_update_reference_count(%Array* %420, i64 -1)
  br label %exiting__36
}

declare void @__quantum__qis__r__body(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliX
  %theta__1 = fneg double %theta
  call void @__quantum__qis__r__body(i2 %pauli, double %theta__1, %Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctl(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliX
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5
  store double %theta, double* %6
  store %Qubit* %qubit, %Qubit** %7
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__r__ctl(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Intrinsic__Rx__ctladj(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliX
  %theta__1 = fneg double %theta
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5
  store double %theta__1, double* %6
  store %Qubit* %qubit, %Qubit** %7
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__body(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__adj(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__adj(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__adj(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6
  store double %theta, double* %7
  store %Qubit* %qubit, %Qubit** %8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 0
  %pauli = load i2, i2* %1
  %2 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i32 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 0
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 1
  %8 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i32 0, i32 2
  store i2 %pauli, i2* %6
  store double %theta, double* %7
  store %Qubit* %qubit, %Qubit** %8
  call void @__quantum__qis__r__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__r__ctladj(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qubit) {
entry:
  %pauli = load i2, i2* @PauliZ
  %theta__1 = fneg double %theta
  call void @__quantum__qis__r__body(i2 %pauli, double %theta__1, %Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliZ
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5
  store double %theta, double* %6
  store %Qubit* %qubit, %Qubit** %7
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %__controlQubits__, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr inbounds { double, %Qubit* }, { double, %Qubit* }* %0, i32 0, i32 1
  %qubit = load %Qubit*, %Qubit** %2
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %pauli = load i2, i2* @PauliZ
  %theta__1 = fneg double %theta
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { i2, double, %Qubit* }*
  %5 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 1
  %7 = getelementptr inbounds { i2, double, %Qubit* }, { i2, double, %Qubit* }* %4, i32 0, i32 2
  store i2 %pauli, i2* %5
  store double %theta__1, double* %6
  store %Qubit* %qubit, %Qubit** %7
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__adj(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %3, i64 0)
  %5 = bitcast i8* %4 to %Qubit**
  store %Qubit* %control, %Qubit** %5
  %__controlQubits__1 = call %Array* @__quantum__rt__array_concatenate(%Array* %__controlQubits__, %Array* %3)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__1, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__1, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %3, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %__controlQubits__1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

define void @Microsoft__Quantum__Intrinsic__CNOT__ctladj(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 0
  %control = load %Qubit*, %Qubit** %1
  %2 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %0, i32 0, i32 1
  %target = load %Qubit*, %Qubit** %2
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %4 = bitcast %Tuple* %3 to { %Qubit*, %Qubit* }*
  %5 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { %Qubit*, %Qubit* }, { %Qubit*, %Qubit* }* %4, i32 0, i32 1
  store %Qubit* %control, %Qubit** %5
  store %Qubit* %target, %Qubit** %6
  call void @Microsoft__Quantum__Intrinsic__CNOT__ctl(%Array* %__controlQubits__, { %Qubit*, %Qubit* }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__z__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

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
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__h__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

attributes #0 = { "EntryPoint" }
