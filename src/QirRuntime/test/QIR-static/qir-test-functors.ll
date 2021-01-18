
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Qubit = type opaque
%Array = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__QIR__Qop = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctladj__wrapper]

@Microsoft__Quantum__Testing__QIR__TestControlled = alias i64 (), i64 ()* @Microsoft__Quantum__Testing__QIR__TestControlled__body

define void @Microsoft__Quantum__Intrinsic__K__body(%Qubit* %q) {
entry:
  call void @__quantum__qis__k__body(%Qubit* %q)
  ret void
}

declare void @__quantum__qis__k__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__K__adj(%Qubit* %q) {
entry:
  call void @__quantum__qis__k__body(%Qubit* %q)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__K__ctl(%Array* %__controlQubits__, %Qubit* %q) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %__controlQubits__)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_remove_access(%Array* %__controlQubits__)
  ret void
}

declare void @__quantum__rt__array_add_access(%Array*)

declare void @__quantum__qis__k__ctl(%Array*, %Qubit*)

declare void @__quantum__rt__array_remove_access(%Array*)

define void @Microsoft__Quantum__Intrinsic__K__ctladj(%Array* %__controlQubits__, %Qubit* %q) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %__controlQubits__)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_remove_access(%Array* %__controlQubits__)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %q, i64 %n) {
entry:
  %0 = srem i64 %n, 2
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__k__body(%Qubit* %q)
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
  call void @__quantum__qis__k__body(%Qubit* %q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctl(%Array* %ctrls, { %Qubit*, i64 }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctrls)
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %n = load i64, i64* %2
  %3 = srem i64 %n, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__array_add_access(%Array* %ctrls)
  call void @__quantum__qis__k__ctl(%Array* %ctrls, %Qubit* %q)
  call void @__quantum__rt__array_remove_access(%Array* %ctrls)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  call void @__quantum__rt__array_remove_access(%Array* %ctrls)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctladj(%Array* %__controlQubits__, { %Qubit*, i64 }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %__controlQubits__)
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %n = load i64, i64* %2
  %3 = srem i64 %n, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__array_add_access(%Array* %__controlQubits__)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_remove_access(%Array* %__controlQubits__)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  call void @__quantum__rt__array_remove_access(%Array* %__controlQubits__)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__TestControlled__body() #0 {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 0
  %3 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__QIR__Qop, %Tuple* null)
  store %Callable* %4, %Callable** %2
  store i64 1, i64* %3
  %qop = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, %Tuple* %0)
  %adj_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 true)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_qop)
  %ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_qop)
  %adj_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_ctl_qop)
  %ctl_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_qop, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_ctl_qop)
  %error_code = alloca i64
  store i64 0, i64* %error_code
  %q1 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q2 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q3 = call %Qubit* @__quantum__rt__qubit_allocate()
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %6 = bitcast %Tuple* %5 to { %Qubit* }*
  %7 = getelementptr { %Qubit* }, { %Qubit* }* %6, i64 0, i32 0
  store %Qubit* %q1, %Qubit** %7
  call void @__quantum__rt__callable_invoke(%Callable* %qop, %Tuple* %5, %Tuple* null)
  %8 = call %Result* @__quantum__qis__mz(%Qubit* %q1)
  %9 = load %Result*, %Result** @ResultOne
  %10 = call i1 @__quantum__rt__result_equal(%Result* %8, %Result* %9)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  store i64 1, i64* %error_code
  br label %continue__1

else__1:                                          ; preds = %entry
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %13 = bitcast %Tuple* %12 to { %Qubit* }*
  %14 = getelementptr { %Qubit* }, { %Qubit* }* %13, i64 0, i32 0
  store %Qubit* %q2, %Qubit** %14
  call void @__quantum__rt__callable_invoke(%Callable* %adj_qop, %Tuple* %12, %Tuple* null)
  %15 = call %Result* @__quantum__qis__mz(%Qubit* %q2)
  %16 = load %Result*, %Result** @ResultOne
  %17 = call i1 @__quantum__rt__result_equal(%Result* %15, %Result* %16)
  %18 = xor i1 %17, true
  br i1 %18, label %then0__2, label %else__2

then0__2:                                         ; preds = %else__1
  store i64 2, i64* %error_code
  br label %continue__2

else__2:                                          ; preds = %else__1
  %19 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %20 = bitcast %Tuple* %19 to { %Array*, %Qubit* }*
  %21 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %20, i64 0, i32 0
  %22 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %20, i64 0, i32 1
  %23 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %23, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  store %Qubit* %q1, %Qubit** %25
  store %Array* %23, %Array** %21
  store %Qubit* %q3, %Qubit** %22
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_qop, %Tuple* %19, %Tuple* null)
  %26 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %27 = load %Result*, %Result** @ResultOne
  %28 = call i1 @__quantum__rt__result_equal(%Result* %26, %Result* %27)
  %29 = xor i1 %28, true
  br i1 %29, label %then0__3, label %else__3

then0__3:                                         ; preds = %else__2
  store i64 3, i64* %error_code
  br label %continue__3

else__3:                                          ; preds = %else__2
  %30 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %31 = bitcast %Tuple* %30 to { %Array*, %Qubit* }*
  %32 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %31, i64 0, i32 0
  %33 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %31, i64 0, i32 1
  %34 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %34, i64 0)
  %36 = bitcast i8* %35 to %Qubit**
  store %Qubit* %q2, %Qubit** %36
  store %Array* %34, %Array** %32
  store %Qubit* %q3, %Qubit** %33
  call void @__quantum__rt__callable_invoke(%Callable* %adj_ctl_qop, %Tuple* %30, %Tuple* null)
  %37 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %38 = load %Result*, %Result** @ResultZero
  %39 = call i1 @__quantum__rt__result_equal(%Result* %37, %Result* %38)
  %40 = xor i1 %39, true
  br i1 %40, label %then0__4, label %else__4

then0__4:                                         ; preds = %else__3
  store i64 4, i64* %error_code
  br label %continue__4

else__4:                                          ; preds = %else__3
  %41 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %42 = bitcast %Tuple* %41 to { %Array*, { %Array*, %Qubit* }* }*
  %43 = getelementptr { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %42, i64 0, i32 0
  %44 = getelementptr { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %42, i64 0, i32 1
  %45 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %45, i64 0)
  %47 = bitcast i8* %46 to %Qubit**
  store %Qubit* %q1, %Qubit** %47
  %48 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %49 = bitcast %Tuple* %48 to { %Array*, %Qubit* }*
  %50 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %49, i64 0, i32 0
  %51 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %49, i64 0, i32 1
  %52 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %52, i64 0)
  %54 = bitcast i8* %53 to %Qubit**
  store %Qubit* %q2, %Qubit** %54
  store %Array* %52, %Array** %50
  store %Qubit* %q3, %Qubit** %51
  store %Array* %45, %Array** %43
  store { %Array*, %Qubit* }* %49, { %Array*, %Qubit* }** %44
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_ctl_qop, %Tuple* %41, %Tuple* null)
  %55 = call %Result* @__quantum__qis__mz(%Qubit* %q3)
  %56 = load %Result*, %Result** @ResultOne
  %57 = call i1 @__quantum__rt__result_equal(%Result* %55, %Result* %56)
  %58 = xor i1 %57, true
  br i1 %58, label %then0__5, label %else__5

then0__5:                                         ; preds = %else__4
  store i64 5, i64* %error_code
  br label %continue__5

else__5:                                          ; preds = %else__4
  %59 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %59)
  %60 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %61 = bitcast %Tuple* %60 to { %Array*, %Qubit* }*
  %62 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %61, i64 0, i32 0
  %63 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %61, i64 0, i32 1
  %64 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %64, i64 0)
  %66 = bitcast i8* %65 to %Qubit**
  %67 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %64, i64 1)
  %68 = bitcast i8* %67 to %Qubit**
  store %Qubit* %q1, %Qubit** %66
  store %Qubit* %q2, %Qubit** %68
  store %Array* %64, %Array** %62
  store %Qubit* %q3, %Qubit** %63
  call void @__quantum__rt__callable_invoke(%Callable* %59, %Tuple* %60, %Tuple* null)
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
  %73 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 true)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %73)
  %74 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %75 = bitcast %Tuple* %74 to { %Qubit* }*
  %76 = getelementptr { %Qubit* }, { %Qubit* }* %75, i64 0, i32 0
  store %Qubit* %q3, %Qubit** %76
  call void @__quantum__rt__callable_invoke(%Callable* %73, %Tuple* %74, %Tuple* null)
  %77 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_ctl_qop, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %77)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %77)
  %78 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %79 = bitcast %Tuple* %78 to { %Array*, { %Array*, { %Array*, %Qubit* }* }* }*
  %80 = getelementptr { %Array*, { %Array*, { %Array*, %Qubit* }* }* }, { %Array*, { %Array*, { %Array*, %Qubit* }* }* }* %79, i64 0, i32 0
  %81 = getelementptr { %Array*, { %Array*, { %Array*, %Qubit* }* }* }, { %Array*, { %Array*, { %Array*, %Qubit* }* }* }* %79, i64 0, i32 1
  %82 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %83 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %82, i64 0)
  %84 = bitcast i8* %83 to %Qubit**
  store %Qubit* %q1, %Qubit** %84
  %85 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %86 = bitcast %Tuple* %85 to { %Array*, { %Array*, %Qubit* }* }*
  %87 = getelementptr { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %86, i64 0, i32 0
  %88 = getelementptr { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %86, i64 0, i32 1
  %89 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %90 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %89, i64 0)
  %91 = bitcast i8* %90 to %Qubit**
  store %Qubit* %q2, %Qubit** %91
  %92 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %93 = bitcast %Tuple* %92 to { %Array*, %Qubit* }*
  %94 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %93, i64 0, i32 0
  %95 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %93, i64 0, i32 1
  %96 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %97 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %96, i64 0)
  %98 = bitcast i8* %97 to %Qubit**
  store %Qubit* %q3, %Qubit** %98
  store %Array* %96, %Array** %94
  store %Qubit* %q4, %Qubit** %95
  store %Array* %89, %Array** %87
  store { %Array*, %Qubit* }* %93, { %Array*, %Qubit* }** %88
  store %Array* %82, %Array** %80
  store { %Array*, { %Array*, %Qubit* }* }* %86, { %Array*, { %Array*, %Qubit* }* }** %81
  call void @__quantum__rt__callable_invoke(%Callable* %77, %Tuple* %78, %Tuple* null)
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
  call void @__quantum__rt__callable_unreference(%Callable* %73)
  call void @__quantum__rt__tuple_unreference(%Tuple* %74)
  call void @__quantum__rt__callable_unreference(%Callable* %77)
  call void @__quantum__rt__array_unreference(%Array* %82)
  call void @__quantum__rt__array_unreference(%Array* %89)
  call void @__quantum__rt__array_unreference(%Array* %96)
  call void @__quantum__rt__tuple_unreference(%Tuple* %92)
  call void @__quantum__rt__tuple_unreference(%Tuple* %85)
  call void @__quantum__rt__tuple_unreference(%Tuple* %78)
  call void @__quantum__rt__result_unreference(%Result* %99)
  br label %continue__6

continue__6:                                      ; preds = %continue__7, %then0__6
  call void @__quantum__rt__callable_unreference(%Callable* %59)
  call void @__quantum__rt__array_unreference(%Array* %64)
  call void @__quantum__rt__tuple_unreference(%Tuple* %60)
  call void @__quantum__rt__result_unreference(%Result* %69)
  br label %continue__5

continue__5:                                      ; preds = %continue__6, %then0__5
  call void @__quantum__rt__array_unreference(%Array* %45)
  call void @__quantum__rt__array_unreference(%Array* %52)
  call void @__quantum__rt__tuple_unreference(%Tuple* %48)
  call void @__quantum__rt__tuple_unreference(%Tuple* %41)
  call void @__quantum__rt__result_unreference(%Result* %55)
  br label %continue__4

continue__4:                                      ; preds = %continue__5, %then0__4
  call void @__quantum__rt__array_unreference(%Array* %34)
  call void @__quantum__rt__tuple_unreference(%Tuple* %30)
  call void @__quantum__rt__result_unreference(%Result* %37)
  br label %continue__3

continue__3:                                      ; preds = %continue__4, %then0__3
  call void @__quantum__rt__array_unreference(%Array* %23)
  call void @__quantum__rt__tuple_unreference(%Tuple* %19)
  call void @__quantum__rt__result_unreference(%Result* %26)
  br label %continue__2

continue__2:                                      ; preds = %continue__3, %then0__2
  call void @__quantum__rt__tuple_unreference(%Tuple* %12)
  call void @__quantum__rt__result_unreference(%Result* %15)
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
  call void @__quantum__rt__tuple_unreference(%Tuple* %5)
  call void @__quantum__rt__result_unreference(%Result* %8)
  %103 = load i64, i64* %error_code
  call void @__quantum__rt__callable_unreference(%Callable* %qop)
  call void @__quantum__rt__callable_unreference(%Callable* %adj_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %ctl_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_unreference(%Callable* %ctl_ctl_qop)
  ret i64 %103
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, %Tuple*)

define void @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit*, i64 }*
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %3 = load %Qubit*, %Qubit** %1
  %4 = load i64, i64* %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %3, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit*, i64 }*
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %3 = load %Qubit*, %Qubit** %1
  %4 = load i64, i64* %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__adj(%Qubit* %3, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { %Qubit*, i64 }* }*
  %1 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { %Qubit*, i64 }*, { %Qubit*, i64 }** %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctl(%Array* %3, { %Qubit*, i64 }* %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { %Qubit*, i64 }* }*
  %1 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { %Qubit*, i64 }*, { %Qubit*, i64 }** %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctladj(%Array* %3, { %Qubit*, i64 }* %4)
  ret void
}

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %4 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %3, i64 0, i32 1
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Qubit*, i64 }*
  %8 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i64 0, i32 0
  %9 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i64 0, i32 1
  store %Qubit* %2, %Qubit** %8
  store i64 %5, i64* %9
  %10 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %3, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%Tuple* %6)
  ret void
}

define void @Lifted__PartialApplication__1__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %4 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %3, i64 0, i32 1
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Qubit*, i64 }*
  %8 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i64 0, i32 0
  %9 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i64 0, i32 1
  store %Qubit* %2, %Qubit** %8
  store i64 %5, i64* %9
  %10 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %3, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %11, i1 true)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  call void @__quantum__rt__callable_invoke(%Callable* %12, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%Tuple* %6)
  call void @__quantum__rt__callable_unreference(%Callable* %12)
  ret void
}

define void @Lifted__PartialApplication__1__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %6 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 1
  %7 = load i64, i64* %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { %Qubit*, i64 }*
  %10 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i64 0, i32 0
  %11 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i64 0, i32 1
  store %Qubit* %4, %Qubit** %10
  store i64 %7, i64* %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { %Qubit*, i64 }* }*
  %14 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i64 0, i32 0
  %15 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i64 0, i32 1
  store %Array* %3, %Array** %14
  call void @__quantum__rt__array_reference(%Array* %3)
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  call void @__quantum__rt__tuple_reference(%Tuple* %8)
  %16 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 true)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%Tuple* %8)
  call void @__quantum__rt__array_unreference(%Array* %3)
  call void @__quantum__rt__tuple_unreference(%Tuple* %8)
  call void @__quantum__rt__tuple_unreference(%Tuple* %12)
  call void @__quantum__rt__callable_unreference(%Callable* %18)
  ret void
}

define void @Lifted__PartialApplication__1__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %6 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 1
  %7 = load i64, i64* %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { %Qubit*, i64 }*
  %10 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i64 0, i32 0
  %11 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i64 0, i32 1
  store %Qubit* %4, %Qubit** %10
  store i64 %7, i64* %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { %Qubit*, i64 }* }*
  %14 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i64 0, i32 0
  %15 = getelementptr { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i64 0, i32 1
  store %Array* %3, %Array** %14
  call void @__quantum__rt__array_reference(%Array* %3)
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  call void @__quantum__rt__tuple_reference(%Tuple* %8)
  %16 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 true)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %18)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%Tuple* %8)
  call void @__quantum__rt__array_unreference(%Array* %3)
  call void @__quantum__rt__tuple_unreference(%Tuple* %8)
  call void @__quantum__rt__tuple_unreference(%Tuple* %12)
  call void @__quantum__rt__callable_unreference(%Callable* %18)
  ret void
}

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__callable_unreference(%Callable*)

declare void @__quantum__rt__tuple_unreference(%Tuple*)

declare void @__quantum__rt__array_unreference(%Array*)

declare void @__quantum__rt__result_unreference(%Result*)

declare void @__quantum__rt__array_reference(%Array*)

declare void @__quantum__rt__tuple_reference(%Tuple*)

attributes #0 = { "EntryPoint" }
