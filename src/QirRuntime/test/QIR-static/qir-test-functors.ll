
%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32, i32 }
%Qubit = type opaque
%Array = type opaque
%Callable = type opaque
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__QIR__Qop = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Qop__ctrl__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Qop__ctrladj__wrapper]
@PartialApplication__1 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__1__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__1__adj__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__1__ctrl__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__1__ctrladj__wrapper]

@Microsoft_Quantum_Testing_QIR_TestControlled = alias i64 (), i64 ()* @Microsoft__Quantum__Testing__QIR__TestControlled__body

declare %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit*)

declare void @Microsoft__Quantum__Intrinsic__K____body(%Qubit*)

declare void @Microsoft__Quantum__Intrinsic__KCtl____body(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__K__body(%Qubit* %q) {
entry:
  call void @__quantum__qis__k__(%Qubit* %q)
  ret void
}

declare void @__quantum__qis__k__(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__K__ctrl(%Array* %__controlQubits__, %Qubit* %q) {
entry:
  call void @__quantum__qis__kctl__(%Array* %__controlQubits__, %Qubit* %q)
  ret void
}

declare void @__quantum__qis__kctl__(%Array*, %Qubit*)

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

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

define void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %q, i64 %n) {
entry:
  %0 = srem i64 %n, 2
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__k__(%Qubit* %q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__adj(%Qubit* %q, i64 %n) {
entry:
  %0 = srem i64 %n, 2
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__k__(%Qubit* %q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctrl(%Array* %ctrls, { %TupleHeader, %Qubit*, i64 }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 1
  %.q = load %Qubit*, %Qubit** %0
  %1 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 2
  %2 = load i64, i64* %1
  %3 = srem i64 %2, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__kctl__(%Array* %ctrls, %Qubit* %.q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctrladj(%Array* %__controlQubits__, { %TupleHeader, %Qubit*, i64 }* %arg__1) {
entry:
  %0 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 1
  %.q = load %Qubit*, %Qubit** %0
  %1 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %arg__1, i64 0, i32 2
  %2 = load i64, i64* %1
  %3 = srem i64 %2, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__kctl__(%Array* %__controlQubits__, %Qubit* %.q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__TestControlled__body() #0 {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable*, i64 }* getelementptr ({ %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Callable*, i64 }*
  %2 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 1
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Testing__QIR__Qop, %TupleHeader* null)
  store %Callable* %3, %Callable** %2
  %4 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 2
  store i64 1, i64* %4
  %qop = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__1, %TupleHeader* %0)
  %adj_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_qop)
  %ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_qop)
  %adj_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop)
  call void @__quantum__rt__callable_make_controlled(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_ctl_qop)
  %ctl_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_qop)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_ctl_qop)
  %error_code = alloca i64
  store i64 0, i64* %error_code
  %q1 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q2 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q3 = call %Qubit* @__quantum__rt__qubit_allocate()
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit* }* getelementptr ({ %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, %Qubit* }*
  %7 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %6, i64 0, i32 1
  store %Qubit* %q1, %Qubit** %7
  call void @__quantum__rt__callable_invoke(%Callable* %qop, %TupleHeader* %5, %TupleHeader* null)
  %8 = call %Result* @__quantum__qis__mz(%Qubit* %q1)
  %9 = load %Result*, %Result** @ResultOne
  %10 = call i1 @__quantum__rt__result_equal(%Result* %8, %Result* %9)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  store i64 1, i64* %error_code
  br label %continue__1

else__1:                                          ; preds = %entry
  %12 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit* }* getelementptr ({ %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* null, i32 1) to i64))
  %13 = bitcast %TupleHeader* %12 to { %TupleHeader, %Qubit* }*
  %14 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %13, i64 0, i32 1
  store %Qubit* %q2, %Qubit** %14
  call void @__quantum__rt__callable_invoke(%Callable* %adj_qop, %TupleHeader* %12, %TupleHeader* null)
  %15 = call %Result* @__quantum__qis__mz(%Qubit* %q2)
  %16 = load %Result*, %Result** @ResultOne
  %17 = call i1 @__quantum__rt__result_equal(%Result* %15, %Result* %16)
  %18 = xor i1 %17, true
  br i1 %18, label %then0__2, label %else__2

then0__2:                                         ; preds = %else__1
  store i64 2, i64* %error_code
  br label %continue__2

else__2:                                          ; preds = %else__1
  %19 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %20 = bitcast %TupleHeader* %19 to { %TupleHeader, %Array*, %Qubit* }*
  %21 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %21, i64 0)
  %23 = bitcast i8* %22 to %Qubit**
  store %Qubit* %q1, %Qubit** %23
  %24 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %20, i64 0, i32 1
  store %Array* %21, %Array** %24
  %25 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %20, i64 0, i32 2
  store %Qubit* %q3, %Qubit** %25
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_qop, %TupleHeader* %19, %TupleHeader* null)
  %26 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %27 = load %Result*, %Result** @ResultOne
  %28 = call i1 @__quantum__rt__result_equal(%Result* %26, %Result* %27)
  %29 = xor i1 %28, true
  br i1 %29, label %then0__3, label %else__3

then0__3:                                         ; preds = %else__2
  store i64 3, i64* %error_code
  br label %continue__3

else__3:                                          ; preds = %else__2
  %30 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %31 = bitcast %TupleHeader* %30 to { %TupleHeader, %Array*, %Qubit* }*
  %32 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %32, i64 0)
  %34 = bitcast i8* %33 to %Qubit**
  store %Qubit* %q2, %Qubit** %34
  %35 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %31, i64 0, i32 1
  store %Array* %32, %Array** %35
  %36 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %31, i64 0, i32 2
  store %Qubit* %q3, %Qubit** %36
  call void @__quantum__rt__callable_invoke(%Callable* %adj_ctl_qop, %TupleHeader* %30, %TupleHeader* null)
  %37 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %38 = load %Result*, %Result** @ResultZero
  %39 = call i1 @__quantum__rt__result_equal(%Result* %37, %Result* %38)
  %40 = xor i1 %39, true
  br i1 %40, label %then0__4, label %else__4

then0__4:                                         ; preds = %else__3
  store i64 4, i64* %error_code
  br label %continue__4

else__4:                                          ; preds = %else__3
  %41 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* getelementptr ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* null, i32 1) to i64))
  %42 = bitcast %TupleHeader* %41 to { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }*
  %43 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %43, i64 0)
  %45 = bitcast i8* %44 to %Qubit**
  store %Qubit* %q1, %Qubit** %45
  %46 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %42, i64 0, i32 1
  store %Array* %43, %Array** %46
  %47 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %48 = bitcast %TupleHeader* %47 to { %TupleHeader, %Array*, %Qubit* }*
  %49 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %42, i64 0, i32 2
  store { %TupleHeader, %Array*, %Qubit* }* %48, { %TupleHeader, %Array*, %Qubit* }** %49
  %50 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %50, i64 0)
  %52 = bitcast i8* %51 to %Qubit**
  store %Qubit* %q2, %Qubit** %52
  %53 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %48, i64 0, i32 1
  store %Array* %50, %Array** %53
  %54 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %48, i64 0, i32 2
  store %Qubit* %q3, %Qubit** %54
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_ctl_qop, %TupleHeader* %41, %TupleHeader* null)
  %55 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %56 = load %Result*, %Result** @ResultOne
  %57 = call i1 @__quantum__rt__result_equal(%Result* %55, %Result* %56)
  %58 = xor i1 %57, true
  br i1 %58, label %then0__5, label %else__5

then0__5:                                         ; preds = %else__4
  store i64 5, i64* %error_code
  br label %continue__5

else__5:                                          ; preds = %else__4
  %59 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %60 = bitcast %TupleHeader* %59 to { %TupleHeader, %Array*, %Qubit* }*
  %61 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %61, i64 0)
  %63 = bitcast i8* %62 to %Qubit**
  store %Qubit* %q1, %Qubit** %63
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %61, i64 1)
  %65 = bitcast i8* %64 to %Qubit**
  store %Qubit* %q2, %Qubit** %65
  %66 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %60, i64 0, i32 1
  store %Array* %61, %Array** %66
  %67 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %60, i64 0, i32 2
  store %Qubit* %q3, %Qubit** %67
  %68 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop)
  call void @__quantum__rt__callable_make_controlled(%Callable* %68)
  call void @__quantum__rt__callable_invoke(%Callable* %68, %TupleHeader* %59, %TupleHeader* null)
  %69 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %70 = load %Result*, %Result** @ResultZero
  %71 = call i1 @__quantum__rt__result_equal(%Result* %69, %Result* %70)
  %72 = xor i1 %71, true
  br i1 %72, label %then0__6, label %else__6

then0__6:                                         ; preds = %else__5
  store i64 6, i64* %error_code
  br label %continue__6

else__6:                                          ; preds = %else__5
  %q4 = call %Qubit* @__quantum__rt__qubit_allocate()
  %73 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Qubit* }* getelementptr ({ %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* null, i32 1) to i64))
  %74 = bitcast %TupleHeader* %73 to { %TupleHeader, %Qubit* }*
  %75 = getelementptr { %TupleHeader, %Qubit* }, { %TupleHeader, %Qubit* }* %74, i64 0, i32 1
  store %Qubit* %q3, %Qubit** %75
  %76 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %76)
  call void @__quantum__rt__callable_invoke(%Callable* %76, %TupleHeader* %73, %TupleHeader* null)
  %77 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }* getelementptr ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }* null, i32 1) to i64))
  %78 = bitcast %TupleHeader* %77 to { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }*
  %79 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %79, i64 0)
  %81 = bitcast i8* %80 to %Qubit**
  store %Qubit* %q1, %Qubit** %81
  %82 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }* %78, i64 0, i32 1
  store %Array* %79, %Array** %82
  %83 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* getelementptr ({ %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* null, i32 1) to i64))
  %84 = bitcast %TupleHeader* %83 to { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }*
  %85 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* }* %78, i64 0, i32 2
  store { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %84, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }** %85
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %87 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 0)
  %88 = bitcast i8* %87 to %Qubit**
  store %Qubit* %q2, %Qubit** %88
  %89 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %84, i64 0, i32 1
  store %Array* %86, %Array** %89
  %90 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Qubit* }* getelementptr ({ %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* null, i32 1) to i64))
  %91 = bitcast %TupleHeader* %90 to { %TupleHeader, %Array*, %Qubit* }*
  %92 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }, { %TupleHeader, %Array*, { %TupleHeader, %Array*, %Qubit* }* }* %84, i64 0, i32 2
  store { %TupleHeader, %Array*, %Qubit* }* %91, { %TupleHeader, %Array*, %Qubit* }** %92
  %93 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %94 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %93, i64 0)
  %95 = bitcast i8* %94 to %Qubit**
  store %Qubit* %q3, %Qubit** %95
  %96 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %91, i64 0, i32 1
  store %Array* %93, %Array** %96
  %97 = getelementptr { %TupleHeader, %Array*, %Qubit* }, { %TupleHeader, %Array*, %Qubit* }* %91, i64 0, i32 2
  store %Qubit* %q4, %Qubit** %97
  %98 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_ctl_qop)
  call void @__quantum__rt__callable_make_controlled(%Callable* %98)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %98)
  call void @__quantum__rt__callable_invoke(%Callable* %98, %TupleHeader* %77, %TupleHeader* null)
  %99 = call %Result* @__quantum__qis__mz(%Qubit* %q4)
  %100 = load %Result*, %Result** @ResultOne
  %101 = call i1 @__quantum__rt__result_equal(%Result* %99, %Result* %100)
  %102 = xor i1 %101, true
  br i1 %102, label %then0__7, label %continue__7

then0__7:                                         ; preds = %else__6
  store i64 7, i64* %error_code
  br label %continue__7

continue__7:                                      ; preds = %then0__7, %else__6
  call void @__quantum__rt__qubit_release(%Qubit* %q4)
  call void @__quantum__rt__callable_unreference(%Callable* %76)
  call void @__quantum__rt__array_unreference(%Array* %79)
  call void @__quantum__rt__array_unreference(%Array* %86)
  call void @__quantum__rt__array_unreference(%Array* %93)
  call void @__quantum__rt__callable_unreference(%Callable* %98)
  br label %continue__6

continue__6:                                      ; preds = %continue__7, %then0__6
  call void @__quantum__rt__array_unreference(%Array* %61)
  call void @__quantum__rt__callable_unreference(%Callable* %68)
  br label %continue__5

continue__5:                                      ; preds = %continue__6, %then0__5
  call void @__quantum__rt__array_unreference(%Array* %43)
  call void @__quantum__rt__array_unreference(%Array* %50)
  br label %continue__4

continue__4:                                      ; preds = %continue__5, %then0__4
  call void @__quantum__rt__array_unreference(%Array* %32)
  br label %continue__3

continue__3:                                      ; preds = %continue__4, %then0__3
  call void @__quantum__rt__array_unreference(%Array* %21)
  br label %continue__2

continue__2:                                      ; preds = %continue__3, %then0__2
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
  %103 = load i64, i64* %error_code
  call void @__quantum__rt__callable_unreference(%Callable* %qop)
  call void @__quantum__rt__callable_unreference(%Callable* %adj_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %ctl_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %ctl_ctl_qop)
  ret i64 %103
}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

define void @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit*, i64 }*
  %1 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 1
  %2 = load %Qubit*, %Qubit** %1
  %3 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 2
  %4 = load i64, i64* %3
  call void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %2, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Qubit*, i64 }*
  %1 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 1
  %2 = load %Qubit*, %Qubit** %1
  %3 = getelementptr { %TupleHeader, %Qubit*, i64 }, { %TupleHeader, %Qubit*, i64 }* %0, i64 0, i32 2
  %4 = load i64, i64* %3
  call void @Microsoft__Quantum__Testing__QIR__Qop__adj(%Qubit* %2, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctrl__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }*
  %1 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 1
  %2 = load %Array*, %Array** %1
  %3 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 2
  %4 = load { %TupleHeader, %Qubit*, i64 }*, { %TupleHeader, %Qubit*, i64 }** %3
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctrl(%Array* %2, { %TupleHeader, %Qubit*, i64 }* %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctrladj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }*
  %1 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 1
  %2 = load %Array*, %Array** %1
  %3 = getelementptr { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }, { %TupleHeader, %Array*, { %TupleHeader, %Qubit*, i64 }* }* %0, i64 0, i32 2
  %4 = load { %TupleHeader, %Qubit*, i64 }*, { %TupleHeader, %Qubit*, i64 }** %3
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctrladj(%Array* %2, { %TupleHeader, %Qubit*, i64 }* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)

define void @Lifted__PartialApplication__1__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
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

define void @Lifted__PartialApplication__1__adj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
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

define void @Lifted__PartialApplication__1__ctrl__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
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

define void @Lifted__PartialApplication__1__ctrladj__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
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

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__array_unreference(%Array*)

define { %TupleHeader, %String* }* @Microsoft__Quantum__Targeting__TargetInstruction__body(%String* %arg0) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %String* }* getelementptr ({ %TupleHeader, %String* }, { %TupleHeader, %String* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %String* }*
  %2 = getelementptr { %TupleHeader, %String* }, { %TupleHeader, %String* }* %1, i64 0, i32 1
  store %String* %arg0, %String** %2
  call void @__quantum__rt__string_reference(%String* %arg0)
  ret { %TupleHeader, %String* }* %1
}

declare void @__quantum__rt__string_reference(%String*)

attributes #0 = { "EntryPoint" }
