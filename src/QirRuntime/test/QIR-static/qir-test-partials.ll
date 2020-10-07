
%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32 }
%Qubit = type opaque
%String = type opaque
%Array = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*

@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Intrinsic__Rz = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Intrinsic__Rz__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Intrinsic__Rz__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]
@PartialApplication__2 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__2__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__2__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]

@Microsoft_Quantum_Testing_QIR_TestPartials = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__QIR__TestPartials__body

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)

declare void @__quantum__qis__h(%Qubit*)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare void @__quantum__qis__rx(double, %Qubit*)

declare void @__quantum__qis__rz(double, %Qubit*)

declare void @__quantum__qis__s(%Qubit*)

declare void @__quantum__qis__t(%Qubit*)

declare void @__quantum__qis__x(%Qubit*)


declare void @Microsoft__Quantum__Instructions__PhysCNOT__body(%Qubit*, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysH__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysM__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRx__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRz__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysS__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysT__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysX__body(%Qubit*)


declare void @Microsoft__Quantum__Intrinsic__Rz__adj(double, %Qubit*)

declare void @Microsoft__Quantum__Intrinsic__Rz__body(double, %Qubit*)


;define { %TupleHeader, %String* }* @Microsoft__Quantum__Core__Intrinsic__body(%String* %arg0) {
;entry:
;  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %String* }* getelementptr ({ %TupleHeader, %String* }, { %TupleHeader, %String* }* null, i32 1) to i64))
;  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %String* }*
;  %2 = getelementptr inbounds { %TupleHeader, %String* }, { %TupleHeader, %String* }* %1, i32 0, i32 1
;  store %String* %arg0, %String** %2
;  call void @__quantum__rt__string_reference(%String* %arg0)
;  ret { %TupleHeader, %String* }* %1
;}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__string_reference(%String*)

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare i64 @Microsoft__Quantum__Core__RangeEnd__body(%Range)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStart__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStep__body(%Range)

define i1 @Microsoft__Quantum__Testing__QIR__TestPartials__body() #0 {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable*, double }* getelementptr ({ %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Callable*, double }*
  %2 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %1, i32 0, i32 1
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Intrinsic__Rz, %TupleHeader* null)
  store %Callable* %3, %Callable** %2
  %4 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %1, i32 0, i32 2
  store double 2.500000e-01, double* %4
  %rotate = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__2, %TupleHeader* %0)
  %unrotate = call %Callable* @__quantum__rt__callable_copy(%Callable* %rotate)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %unrotate)
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %18, %exiting__1 ]
  %5 = icmp sge i64 %i, 100
  %6 = icmp sle i64 %i, 100
  %7 = select i1 true, i1 %6, i1 %5
  br i1 %7, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %qb = call %Qubit* @__quantum__rt__qubit_allocate()
  %8 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit* }* getelementptr ({ %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* null, i32 1) to i64))
  %9 = bitcast %TupleHeader* %8 to { %TupleHeader, %Qubit* }*
  %10 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %9, i64 0, i32 1
  store %Qubit* %qb, %Qubit** %10
  call void @__quantum__rt__callable_invoke(%Callable* %rotate, %TupleHeader* %8, %TupleHeader* null)
  %11 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit* }* getelementptr ({ %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* null, i32 1) to i64))
  %12 = bitcast %TupleHeader* %11 to { %TupleHeader, %Qubit* }*
  %13 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %12, i64 0, i32 1
  store %Qubit* %qb, %Qubit** %13
  call void @__quantum__rt__callable_invoke(%Callable* %unrotate, %TupleHeader* %11, %TupleHeader* null)
  %14 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
  %15 = load %Result*, %Result** @ResultZero
  %16 = call i1 @__quantum__rt__result_equal(%Result* %14, %Result* %15)
  %17 = xor i1 %16, true
  br i1 %17, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__rt__qubit_release(%Qubit* %qb)
  call void @__quantum__rt__callable_unreference(%Callable* %rotate)
  call void @__quantum__rt__callable_unreference(%Callable* %unrotate)
  ret i1 false

continue__1:                                      ; preds = %body__1
  call void @__quantum__rt__qubit_release(%Qubit* %qb)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %18 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__callable_unreference(%Callable* %rotate)
  call void @__quantum__rt__callable_unreference(%Callable* %unrotate)
  ret i1 true
}

define void @Microsoft__Quantum__Intrinsic__Rz__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, double, %Qubit* }*
  %1 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %0, i64 0, i32 1
  %2 = load double, double* %1
  %3 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %0, i64 0, i32 2
  %4 = load %Qubit*, %Qubit** %3
  call void @Microsoft__Quantum__Intrinsic__Rz__body(double %2, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, double, %Qubit* }*
  %1 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %0, i64 0, i32 1
  %2 = load double, double* %1
  %3 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %0, i64 0, i32 2
  %4 = load %Qubit*, %Qubit** %3
  call void @Microsoft__Quantum__Intrinsic__Rz__adj(double %2, %Qubit* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)

define void @Lifted__PartialApplication__2__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, double }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit* }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, %Qubit* }* getelementptr ({ %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, double, %Qubit* }*
  %4 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i64 0, i32 2
  %6 = load double, double* %5
  store double %6, double* %4
  %7 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %1, i64 0, i32 1
  %9 = load %Qubit*, %Qubit** %8
  store %Qubit* %9, %Qubit** %7
  %10 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i32 0, i32 1
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %TupleHeader*, %TupleHeader*)

declare void @__quantum__rt__tuple_unreference(%TupleHeader*)

define void @Lifted__PartialApplication__2__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, double }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit* }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, %Qubit* }* getelementptr ({ %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, double, %Qubit* }*
  %4 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i64 0, i32 2
  %6 = load double, double* %5
  store double %6, double* %4
  %7 = getelementptr { %TupleHeader, double, %Qubit* }, { %TupleHeader, double, %Qubit* }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %1, i64 0, i32 1
  %9 = load %Qubit*, %Qubit** %8
  store %Qubit* %9, %Qubit** %7
  %10 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i32 0, i32 1
  %11 = load %Callable*, %Callable** %10
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %11)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  call void @__quantum__rt__callable_invoke(%Callable* %12, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  call void @__quantum__rt__callable_unreference(%Callable* %12)
  ret void
}

declare %Callable* @__quantum__rt__callable_copy(%Callable*)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__callable_unreference(%Callable*)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

attributes #0 = { "EntryPoint" }
