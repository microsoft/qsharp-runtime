; Copyright (c) Microsoft Corporation. All rights reserved.
; Licensed under the MIT License.

%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32 }
%Qubit = type opaque
%Array = type opaque
%String = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Intrinsic__K = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Intrinsic__K__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Intrinsic__K__ctrl__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]
@PartialApplication__cnt1 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt1__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt1__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt1__ctrl__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt1__ctrladj__wrapper]
@PartialApplication__cnt2 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt2__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt2__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt2__ctrl__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__cnt2__ctrladj__wrapper]

@Microsoft_Quantum_Testing_QIR_TestControlled = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__QIR__TestControlled__body

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)

; we'll cut corners here and rely on Clang not validating argument types
declare void @quantum__qis__k(%Qubit* %.q, i64 %t)
define void @__quantum__qis__k(%Qubit* %.q, i64 %t) {
    call void @quantum__qis__k(%Qubit* %.q, i64 %t)
    ret void
}

declare void @quantum__qis__ck(%Array*, %Qubit*, i64)
define void @__quantum__qis__ck(%Array* %.c, %Qubit* %.q, i64 %t) {
    call void @quantum__qis__ck(%Array* %.c, %Qubit* %.q, i64 %t)
    ret void
}

declare void @__quantum__qis__h(%Qubit*)



declare %Result* @__quantum__qis__mz(%Qubit*)

declare void @__quantum__qis__rx(double, %Qubit*)

declare void @__quantum__qis__rz(double, %Qubit*)

declare void @__quantum__qis__s(%Qubit*)

declare void @__quantum__qis__t(%Qubit*)

declare void @__quantum__qis__x(%Qubit*)

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
  %2 = getelementptr inbounds { %TupleHeader, %String* }, { %TupleHeader, %String* }* %1, i32 0, i32 1
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

define void @Microsoft__Quantum__Intrinsic__K__body(%Qubit* %qb, i64 %n) {
entry:
  call void @__quantum__qis__k(%Qubit* %qb, i64 %n)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__K__ctrl(%Array* %ctrls, { %TupleHeader, %Qubit*, i64 }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 1
  %1 = load %Qubit*, %Qubit** %0
  %2 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 2
  %3 = load i64, i64* %2
  call void @__quantum__qis__ck(%Array* %ctrls, %Qubit* %1, i64 %3)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
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

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__t(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x(%Qubit* %qb)
  ret void
}

declare void @Microsoft__Quantum__Instructions__PhysCNOT__body(%Qubit*, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysCtrlK__body(%Array*, %Qubit*, i64)

declare void @Microsoft__Quantum__Instructions__PhysH__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysK__body(%Qubit*, i64)

declare %Result* @Microsoft__Quantum__Instructions__PhysM__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRx__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRz__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysS__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysT__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysX__body(%Qubit*)

define i1 @Microsoft__Quantum__Testing__QIR__TestControlled__body() #0 {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable*, i64 }* getelementptr ({ %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Callable*, i64 }*
  %2 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 1
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Intrinsic__K, %TupleHeader* null)
  store %Callable* %3, %Callable** %2
  %4 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 2
  store i64 2, i64* %4
  %k2 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__cnt1, %TupleHeader* %0)
  %ck2 = call %Callable* @__quantum__rt__callable_copy(%Callable* %k2)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ck2)
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable* }* getelementptr ({ %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Callable* }*
  %7 = getelementptr { %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* %6, i64 0, i32 1
  %8 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Intrinsic__K, %TupleHeader* null)
  store %Callable* %8, %Callable** %7
  %ck1 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__cnt2, %TupleHeader* %5)
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %40, %exiting__1 ]
  %9 = icmp sge i64 %i, 0
  %10 = icmp sle i64 %i, 0
  %11 = select i1 true, i1 %10, i1 %9
  br i1 %11, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %ctrls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  %qb = call %Qubit* @__quantum__rt__qubit_allocate()
  %12 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %13 = bitcast %TupleHeader* %12 to { %TupleHeader, %Array*, %Qubit* }*
  %14 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %13, i64 0, i32 1
  store %Array* %ctrls, %Array** %14
  %15 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %13, i64 0, i32 2
  store %Qubit* %qb, %Qubit** %15
  call void @__quantum__rt__callable_invoke(%Callable* %ck2, %TupleHeader* %12, %TupleHeader* null)
  %moreCtrls = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  %16 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* getelementptr ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* null, i32 1) to i64))
  %17 = bitcast %TupleHeader* %16 to { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }*
  %18 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %17, i64 0, i32 1
  store %Array* %moreCtrls, %Array** %18
  %19 = call %TupleHeader* @__quantum__rt__tuple_create(i64 8)
  %20 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %17, i64 0, i32 2
  %21 = bitcast %TupleHeader* %19 to { %TupleHeader, %Array*, %Qubit* }*
  store { %TupleHeader, %Array*, %Qubit* }* %21, { %TupleHeader, %Array*, %Qubit* }** %20
  %22 = bitcast %TupleHeader* %19 to { %TupleHeader, %Array*, %Qubit* }*
  %23 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %22, i64 0, i32 1
  store %Array* %ctrls, %Array** %23
  %24 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %22, i64 0, i32 2
  store %Qubit* %qb, %Qubit** %24
  %25 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ck2)
  call void @__quantum__rt__callable_make_controlled(%Callable* %25)
  call void @__quantum__rt__callable_invoke(%Callable* %25, %TupleHeader* %16, %TupleHeader* null)
  %26 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* getelementptr ({ %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* null, i32 1) to i64))
  %27 = bitcast %TupleHeader* %26 to { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }*
  %28 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %27, i64 0, i32 1
  store %Array* %ctrls, %Array** %28
  %29 = call %TupleHeader* @__quantum__rt__tuple_create(i64 8)
  %30 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %27, i64 0, i32 2
  %31 = bitcast %TupleHeader* %29 to { %TupleHeader, %Qubit*, i64 }*
  store { %TupleHeader, %Qubit*, i64 }* %31, { %TupleHeader, %Qubit*, i64 }** %30
  %32 = bitcast %TupleHeader* %29 to { %TupleHeader, %Qubit*, i64 }*
  %33 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %32, i64 0, i32 1
  store %Qubit* %qb, %Qubit** %33
  %34 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %32, i64 0, i32 2
  store i64 1, i64* %34
  %35 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ck1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %35)
  call void @__quantum__rt__callable_invoke(%Callable* %35, %TupleHeader* %26, %TupleHeader* null)
  call void @__quantum__rt__qubit_release_array(%Array* %moreCtrls)
  call void @__quantum__rt__callable_unreference(%Callable* %25)
  call void @__quantum__rt__callable_unreference(%Callable* %35)
  %36 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
  %37 = load %Result*, %Result** @ResultZero
  %38 = call i1 @__quantum__rt__result_equal(%Result* %36, %Result* %37)
  %39 = xor i1 %38, true
  br i1 %39, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__rt__qubit_release_array(%Array* %ctrls)
  call void @__quantum__rt__qubit_release(%Qubit* %qb)
  call void @__quantum__rt__callable_unreference(%Callable* %k2)
  call void @__quantum__rt__callable_unreference(%Callable* %ck2)
  call void @__quantum__rt__callable_unreference(%Callable* %ck1)
  ret i1 false

continue__1:                                      ; preds = %body__1
  call void @__quantum__rt__qubit_release_array(%Array* %ctrls)
  call void @__quantum__rt__qubit_release(%Qubit* %qb)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %40 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__callable_unreference(%Callable* %k2)
  call void @__quantum__rt__callable_unreference(%Callable* %ck2)
  call void @__quantum__rt__callable_unreference(%Callable* %ck1)
  ret i1 true
}

define void @Microsoft__Quantum__Intrinsic__K__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit*, i64 }*
  %1 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 1
  %2 = load %Qubit*, %Qubit** %1
  %3 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 2
  %4 = load i64, i64* %3
  call void @Microsoft__Quantum__Intrinsic__K__body(%Qubit* %2, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__K__ctrl__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }*
  %1 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 1
  %2 = load %Array*, %Array** %1
  %3 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 2
  %4 = load { %TupleHeader, %Qubit*, i64 }*, { %TupleHeader, %Qubit*, i64 }** %3
  call void @Microsoft__Quantum__Intrinsic__K__ctrl(%Array* %2, { %TupleHeader, %Qubit*, i64 }* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)

define void @Lifted__PartialApplication__cnt1__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, i64 }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit* }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, %Qubit*, i64 }*
  %4 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %1, i64 0, i32 1
  %6 = load %Qubit*, %Qubit** %5
  store %Qubit* %6, %Qubit** %4
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 2
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 1
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %TupleHeader*, %TupleHeader*)

declare void @__quantum__rt__tuple_unreference(%TupleHeader*)

define void @Lifted__PartialApplication__cnt1__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, i64 }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit* }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, %Qubit*, i64 }*
  %4 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %1, i64 0, i32 1
  %6 = load %Qubit*, %Qubit** %5
  store %Qubit* %6, %Qubit** %4
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 2
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 1
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

define void @Lifted__PartialApplication__cnt1__ctrl__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, i64 }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, %Qubit* }*
  %2 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %1, i64 0, i32 1
  %3 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %1, i64 0, i32 2
  %4 = load %Qubit*, %Qubit** %3
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Qubit*, i64 }*
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 1
  store %Qubit* %4, %Qubit** %7
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 2
  %9 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 2
  %10 = load i64, i64* %9
  store i64 %10, i64* %8
  %11 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %TupleHeader* }* getelementptr ({ %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* null, i32 1) to i64))
  %12 = bitcast %TupleHeader* %11 to { %TupleHeader, %Array*, %TupleHeader* }*
  %13 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %12, i64 0, i32 1
  %14 = load %Array*, %Array** %2
  store %Array* %14, %Array** %13
  %15 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %12, i64 0, i32 2
  store %TupleHeader* %5, %TupleHeader** %15
  %16 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 1
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %TupleHeader* %11, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %5)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %11)
  call void @__quantum__rt__callable_unreference(%Callable* %18)
  ret void
}

declare void @__quantum__rt__callable_make_controlled(%Callable*)

define void @Lifted__PartialApplication__cnt1__ctrladj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, i64 }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, %Qubit* }*
  %2 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %1, i64 0, i32 1
  %3 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %1, i64 0, i32 2
  %4 = load %Qubit*, %Qubit** %3
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Qubit*, i64 }*
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 1
  store %Qubit* %4, %Qubit** %7
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 2
  %9 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 2
  %10 = load i64, i64* %9
  store i64 %10, i64* %8
  %11 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %TupleHeader* }* getelementptr ({ %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* null, i32 1) to i64))
  %12 = bitcast %TupleHeader* %11 to { %TupleHeader, %Array*, %TupleHeader* }*
  %13 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %12, i64 0, i32 1
  %14 = load %Array*, %Array** %2
  store %Array* %14, %Array** %13
  %15 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %12, i64 0, i32 2
  store %TupleHeader* %5, %TupleHeader** %15
  %16 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 1
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %18)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %TupleHeader* %11, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %5)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %11)
  call void @__quantum__rt__callable_unreference(%Callable* %18)
  ret void
}

define void @Lifted__PartialApplication__cnt2__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable* }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit*, i64 }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, %Qubit*, i64 }*
  %4 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %1, i64 0, i32 1
  %6 = load %Qubit*, %Qubit** %5
  store %Qubit* %6, %Qubit** %4
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %1, i64 0, i32 2
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* %0, i64 0, i32 1
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  ret void
}

define void @Lifted__PartialApplication__cnt2__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable* }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit*, i64 }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, %Qubit*, i64 }*
  %4 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %1, i64 0, i32 1
  %6 = load %Qubit*, %Qubit** %5
  store %Qubit* %6, %Qubit** %4
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %1, i64 0, i32 2
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* %0, i64 0, i32 1
  %11 = load %Callable*, %Callable** %10
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %11)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  call void @__quantum__rt__callable_invoke(%Callable* %12, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  call void @__quantum__rt__callable_unreference(%Callable* %12)
  ret void
}

define void @Lifted__PartialApplication__cnt2__ctrl__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable* }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, %TupleHeader* }*
  %2 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %1, i64 0, i32 1
  %3 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %1, i64 0, i32 2
  %4 = bitcast %TupleHeader** %3 to { %TupleHeader, %Qubit*, i64 }*
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Qubit*, i64 }*
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 1
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %4, i64 0, i32 1
  %9 = load %Qubit*, %Qubit** %8
  store %Qubit* %9, %Qubit** %7
  %10 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 2
  %11 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %4, i64 0, i32 2
  %12 = load i64, i64* %11
  store i64 %12, i64* %10
  %13 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %TupleHeader* }* getelementptr ({ %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* null, i32 1) to i64))
  %14 = bitcast %TupleHeader* %13 to { %TupleHeader, %Array*, %TupleHeader* }*
  %15 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %14, i64 0, i32 1
  %16 = load %Array*, %Array** %2
  store %Array* %16, %Array** %15
  %17 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %14, i64 0, i32 2
  store %TupleHeader* %5, %TupleHeader** %17
  %18 = getelementptr { %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* %0, i64 0, i32 1
  %19 = load %Callable*, %Callable** %18
  %20 = call %Callable* @__quantum__rt__callable_copy(%Callable* %19)
  call void @__quantum__rt__callable_make_controlled(%Callable* %20)
  call void @__quantum__rt__callable_invoke(%Callable* %20, %TupleHeader* %13, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %5)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %13)
  call void @__quantum__rt__callable_unreference(%Callable* %20)
  ret void
}

define void @Lifted__PartialApplication__cnt2__ctrladj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable* }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, %TupleHeader* }*
  %2 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %1, i64 0, i32 1
  %3 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %1, i64 0, i32 2
  %4 = bitcast %TupleHeader** %3 to { %TupleHeader, %Qubit*, i64 }*
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit*, i64 }* getelementptr ({ %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Qubit*, i64 }*
  %7 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 1
  %8 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %4, i64 0, i32 1
  %9 = load %Qubit*, %Qubit** %8
  store %Qubit* %9, %Qubit** %7
  %10 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %6, i64 0, i32 2
  %11 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %4, i64 0, i32 2
  %12 = load i64, i64* %11
  store i64 %12, i64* %10
  %13 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %TupleHeader* }* getelementptr ({ %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* null, i32 1) to i64))
  %14 = bitcast %TupleHeader* %13 to { %TupleHeader, %Array*, %TupleHeader* }*
  %15 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %14, i64 0, i32 1
  %16 = load %Array*, %Array** %2
  store %Array* %16, %Array** %15
  %17 = getelementptr { %TupleHeader, %Array*, %TupleHeader* }, { %TupleHeader, %Array*, %TupleHeader* }* %14, i64 0, i32 2
  store %TupleHeader* %5, %TupleHeader** %17
  %18 = getelementptr { %TupleHeader, %Callable* }, { %TupleHeader, %Callable* }* %0, i64 0, i32 1
  %19 = load %Callable*, %Callable** %18
  %20 = call %Callable* @__quantum__rt__callable_copy(%Callable* %19)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %20)
  call void @__quantum__rt__callable_make_controlled(%Callable* %20)
  call void @__quantum__rt__callable_invoke(%Callable* %20, %TupleHeader* %13, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %5)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %13)
  call void @__quantum__rt__callable_unreference(%Callable* %20)
  ret void
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

attributes #0 = { "EntryPoint" }
