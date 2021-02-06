
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Array = type opaque
%Qubit = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__QIR__Qop = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Qop__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctladj__wrapper]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__1__RefCount, void (%Tuple*, i64)* @MemoryManagement__1__AliasCount]
@Microsoft__Quantum__Testing__QIR__Subtract = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@PartialApplication__2 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@MemoryManagement__2 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__2__RefCount, void (%Tuple*, i64)* @MemoryManagement__2__AliasCount]

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

define double @Microsoft__Quantum__Intrinsic__NAN__body() {
entry:
  %0 = call double @__quantum__qis__nan__body()
  ret double %0
}

declare double @__quantum__qis__nan__body()

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

define double @Microsoft__Quantum__Intrinsic__Sqrt__body(double %d) {
entry:
  %0 = call double @__quantum__qis__sqrt__body(double %d)
  ret double %0
}

declare double @__quantum__qis__sqrt__body(double)

define i1 @Microsoft__Quantum__Intrinsic__IsInf__body(double %d) {
entry:
  %0 = call i1 @__quantum__qis__isinf__body(double %d)
  ret i1 %0
}

declare i1 @__quantum__qis__isinf__body(double)

define double @Microsoft__Quantum__Intrinsic__INFINITY__body() {
entry:
  %0 = call double @__quantum__qis__infinity__body()
  ret double %0
}

declare double @__quantum__qis__infinity__body()

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
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
  store %Qubit* %qb, %Qubit** %4
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  ret %Result* %5
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__x__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

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
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__k__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__K__ctladj(%Array* %__controlQubits__, %Qubit* %q) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define i1 @Microsoft__Quantum__Intrinsic__IsNan__body(double %d) {
entry:
  %0 = call i1 @__quantum__qis__isnan__body(double %d)
  ret i1 %0
}

declare i1 @__quantum__qis__isnan__body(double)

define i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %from, i64 %what) {
entry:
  %0 = sub i64 %from, %what
  ret i64 %0
}

define i1 @Microsoft__Quantum__Testing__QIR__Test_Qubit_Result_Management__body() {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %1 = bitcast i8* %0 to %Qubit**
  %qb = load %Qubit*, %Qubit** %1
  call void @__quantum__qis__x__body(%Qubit* %qb)
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %3 = bitcast i8* %2 to %Qubit**
  %4 = load %Qubit*, %Qubit** %3
  %5 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %4)
  %6 = load %Result*, %Result** @ResultOne
  %7 = call i1 @__quantum__rt__result_equal(%Result* %5, %Result* %6)
  br i1 %7, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__body(%Qubit* %q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9
  %11 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %10)
  %12 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q)
  %13 = call i1 @__quantum__rt__result_equal(%Result* %11, %Result* %12)
  %14 = xor i1 %13, true
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %11, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %12, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  ret i1 %14
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

define i64 @Microsoft__Quantum__Testing__QIR__TestControlled__body() {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 0
  %3 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__QIR__Qop, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %4, %Callable** %2
  store i64 1, i64* %3
  %qop = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i64)*]* @MemoryManagement__1, %Tuple* %0)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %qop, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %qop, i64 1)
  %adj_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %adj_qop, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_qop)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %adj_qop, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %adj_qop, i64 1)
  %ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %ctl_qop, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_qop)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %ctl_qop, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %ctl_qop, i64 1)
  %adj_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %adj_ctl_qop, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %adj_ctl_qop)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %adj_ctl_qop, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %adj_ctl_qop, i64 1)
  %ctl_ctl_qop = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %ctl_ctl_qop, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %ctl_ctl_qop)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %ctl_ctl_qop, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %ctl_ctl_qop, i64 1)
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
  %8 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q1)
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
  %15 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q2)
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
  %26 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
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
  %37 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
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
  %55 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %56 = load %Result*, %Result** @ResultOne
  %57 = call i1 @__quantum__rt__result_equal(%Result* %55, %Result* %56)
  %58 = xor i1 %57, true
  br i1 %58, label %then0__5, label %else__5

then0__5:                                         ; preds = %else__4
  store i64 5, i64* %error_code
  br label %continue__5

else__5:                                          ; preds = %else__4
  %59 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %59, i64 1)
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
  %69 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %70 = load %Result*, %Result** @ResultZero
  %71 = call i1 @__quantum__rt__result_equal(%Result* %69, %Result* %70)
  %72 = xor i1 %71, true
  br i1 %72, label %then0__6, label %else__6

then0__6:                                         ; preds = %else__5
  store i64 6, i64* %error_code
  br label %continue__6

else__6:                                          ; preds = %else__5
  %q4 = call %Qubit* @__quantum__rt__qubit_allocate()
  %73 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %73, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %73)
  %74 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %75 = bitcast %Tuple* %74 to { %Qubit* }*
  %76 = getelementptr { %Qubit* }, { %Qubit* }* %75, i64 0, i32 0
  store %Qubit* %q3, %Qubit** %76
  call void @__quantum__rt__callable_invoke(%Callable* %73, %Tuple* %74, %Tuple* null)
  %77 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_ctl_qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %77, i64 1)
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
  %99 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q4)
  %100 = load %Result*, %Result** @ResultOne
  %101 = call i1 @__quantum__rt__result_equal(%Result* %99, %Result* %100)
  %102 = xor i1 %101, true
  br i1 %102, label %then0__7, label %continue__7

then0__7:                                         ; preds = %else__6
  store i64 7, i64* %error_code
  br label %continue__7

continue__7:                                      ; preds = %then0__7, %else__6
  call void @__quantum__rt__qubit_release(%Qubit* %q4)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %73, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %73, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %74, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %77, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %77, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %82, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %89, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %96, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %92, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %85, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %78, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %99, i64 -1)
  br label %continue__6

continue__6:                                      ; preds = %continue__7, %then0__6
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %59, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %59, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %64, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %60, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %69, i64 -1)
  br label %continue__5

continue__5:                                      ; preds = %continue__6, %then0__5
  call void @__quantum__rt__array_update_reference_count(%Array* %45, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %52, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %48, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %41, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %55, i64 -1)
  br label %continue__4

continue__4:                                      ; preds = %continue__5, %then0__4
  call void @__quantum__rt__array_update_reference_count(%Array* %34, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %30, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %37, i64 -1)
  br label %continue__3

continue__3:                                      ; preds = %continue__4, %then0__3
  call void @__quantum__rt__array_update_reference_count(%Array* %23, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %19, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %26, i64 -1)
  br label %continue__2

continue__2:                                      ; preds = %continue__3, %then0__2
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %15, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  %103 = load i64, i64* %error_code
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %qop, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %adj_qop, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %adj_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %ctl_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %adj_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %adj_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %ctl_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %ctl_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %qop, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %adj_qop, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %adj_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %ctl_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %adj_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %adj_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %ctl_ctl_qop, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %ctl_ctl_qop, i64 -1)
  ret i64 %103
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

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

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i64)*]*, %Tuple*)

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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
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
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %11, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  call void @__quantum__rt__callable_invoke(%Callable* %12, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %12, i64 -1)
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
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  %16 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %18, i64 -1)
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
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  %16 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %18)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %18, i64 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

declare void @__quantum__rt__callable_memory_management(i32, %Callable*, i64)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i64)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

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
  call void @__quantum__rt__array_update_alias_count(%Array* %ctrls, i64 1)
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %n = load i64, i64* %2
  %3 = srem i64 %n, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__array_update_alias_count(%Array* %ctrls, i64 1)
  call void @__quantum__qis__k__ctl(%Array* %ctrls, %Qubit* %q)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctrls, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  call void @__quantum__rt__array_update_alias_count(%Array* %ctrls, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctladj(%Array* %__controlQubits__, { %Qubit*, i64 }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i64 0, i32 1
  %n = load i64, i64* %2
  %3 = srem i64 %n, 2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 %x, i64 %y) {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 0
  %3 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__QIR__Subtract, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %4, %Callable** %2
  store i64 %x, i64* %3
  %subtractor = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__2, [2 x void (%Tuple*, i64)*]* @MemoryManagement__2, %Tuple* %0)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %subtractor, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %subtractor, i64 1)
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  %6 = bitcast %Tuple* %5 to { i64 }*
  %7 = getelementptr { i64 }, { i64 }* %6, i64 0, i32 0
  store i64 %y, i64* %7
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %subtractor, %Tuple* %5, %Tuple* %8)
  %9 = bitcast %Tuple* %8 to { i64 }*
  %10 = getelementptr { i64 }, { i64 }* %9, i64 0, i32 0
  %11 = load i64, i64* %10
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %subtractor, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  ret i64 %11
}

define void @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i64, i64 }*
  %1 = getelementptr { i64, i64 }, { i64, i64 }* %0, i64 0, i32 0
  %2 = getelementptr { i64, i64 }, { i64, i64 }* %0, i64 0, i32 1
  %3 = load i64, i64* %1
  %4 = load i64, i64* %2
  %5 = call i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %3, i64 %4)
  %6 = bitcast %Tuple* %result-tuple to { i64 }*
  %7 = getelementptr { i64 }, { i64 }* %6, i64 0, i32 0
  store i64 %5, i64* %7
  ret void
}

define void @Lifted__PartialApplication__2__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 1
  %2 = load i64, i64* %1
  %3 = bitcast %Tuple* %arg-tuple to { i64 }*
  %4 = getelementptr { i64 }, { i64 }* %3, i64 0, i32 0
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %7 = bitcast %Tuple* %6 to { i64, i64 }*
  %8 = getelementptr { i64, i64 }, { i64, i64 }* %7, i64 0, i32 0
  %9 = getelementptr { i64, i64 }, { i64, i64 }* %7, i64 0, i32 1
  store i64 %2, i64* %8
  store i64 %5, i64* %9
  %10 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  ret void
}

define void @MemoryManagement__2__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__2__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, i64 %index, i64 %val, i1 %dummy) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %local = alloca %Array*
  store %Array* %array, %Array** %local
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %array, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  %0 = call %Array* @__quantum__rt__array_copy(%Array* %array, i1 false)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %index)
  %2 = bitcast i8* %1 to i64*
  store i64 %val, i64* %2
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %0, i64 1)
  store %Array* %0, %Array** %local
  %n = call i64 @__quantum__rt__array_get_size_1d(%Array* %0)
  %3 = sub i64 %n, 1
  %4 = load %Range, %Range* @EmptyRange
  %5 = insertvalue %Range %4, i64 %index, 0
  %6 = insertvalue %Range %5, i64 1, 1
  %7 = insertvalue %Range %6, i64 %3, 2
  %slice1 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %7, i1 false)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice1, i64 1)
  %8 = load %Range, %Range* @EmptyRange
  %9 = insertvalue %Range %8, i64 %index, 0
  %10 = insertvalue %Range %9, i64 -2, 1
  %11 = insertvalue %Range %10, i64 0, 2
  %slice2 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %11, i1 false)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice2, i64 1)
  %result = call %Array* @__quantum__rt__array_concatenate(%Array* %slice2, %Array* %slice1)
  call void @__quantum__rt__array_update_alias_count(%Array* %result, i64 1)
  %sum = alloca i64
  store i64 0, i64* %sum
  %12 = call i64 @__quantum__rt__array_get_size_1d(%Array* %result)
  %13 = sub i64 %12, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %20, %exiting__1 ]
  %14 = icmp sle i64 %i, %13
  br i1 %14, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %15 = load i64, i64* %sum
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %result, i64 %i)
  %17 = bitcast i8* %16 to i64*
  %18 = load i64, i64* %17
  %19 = add i64 %15, %18
  store i64 %19, i64* %sum
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %20 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  br i1 %dummy, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__1
  %res1 = call i64 @Microsoft__Quantum__Testing__QIR__TestControlled__body()
  %res2 = call i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 17, i64 42)
  %res3 = call i1 @Microsoft__Quantum__Testing__QIR__Test_Qubit_Result_Management__body()
  %res4 = call i64 @Microsoft__Quantum__Testing__QIR__Math__TestSqrt__body()
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %exit__1
  %21 = load i64, i64* %sum
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %0, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice2, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %result, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %array, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %slice1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %slice2, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %result, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  ret i64 %21
}

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare %Array* @__quantum__rt__array_slice_1d(%Array*, %Range, i1)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

define i64 @Microsoft__Quantum__Testing__QIR__Math__TestSqrt__body() {
entry:
  %testResult = alloca i64
  store i64 0, i64* %testResult
  %0 = call double @__quantum__qis__sqrt__body(double 4.000000e+00)
  %1 = fcmp one double 2.000000e+00, %0
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  store i64 1, i64* %testResult
  br label %continue__1

else__1:                                          ; preds = %entry
  %2 = call double @__quantum__qis__sqrt__body(double 9.000000e+00)
  %3 = fcmp one double 3.000000e+00, %2
  br i1 %3, label %then0__2, label %else__2

then0__2:                                         ; preds = %else__1
  store i64 2, i64* %testResult
  br label %continue__2

else__2:                                          ; preds = %else__1
  %4 = call double @__quantum__qis__sqrt__body(double 1.000000e+02)
  %5 = fcmp one double 1.000000e+01, %4
  br i1 %5, label %then0__3, label %else__3

then0__3:                                         ; preds = %else__2
  store i64 3, i64* %testResult
  br label %continue__3

else__3:                                          ; preds = %else__2
  %d__4 = call double @__quantum__qis__sqrt__body(double -5.000000e+00)
  %6 = call i1 @__quantum__qis__isnan__body(double %d__4)
  %7 = xor i1 %6, true
  br i1 %7, label %then0__4, label %else__4

then0__4:                                         ; preds = %else__3
  store i64 4, i64* %testResult
  br label %continue__4

else__4:                                          ; preds = %else__3
  %d__5 = call double @__quantum__qis__nan__body()
  %d__6 = call double @__quantum__qis__sqrt__body(double %d__5)
  %8 = call i1 @__quantum__qis__isnan__body(double %d__6)
  %9 = xor i1 %8, true
  br i1 %9, label %then0__5, label %else__5

then0__5:                                         ; preds = %else__4
  store i64 5, i64* %testResult
  br label %continue__5

else__5:                                          ; preds = %else__4
  %d__7 = call double @__quantum__qis__infinity__body()
  %d__8 = call double @__quantum__qis__sqrt__body(double %d__7)
  %10 = call i1 @__quantum__qis__isinf__body(double %d__8)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__6, label %continue__6

then0__6:                                         ; preds = %else__5
  store i64 6, i64* %testResult
  br label %continue__6

continue__6:                                      ; preds = %then0__6, %else__5
  br label %continue__5

continue__5:                                      ; preds = %continue__6, %then0__5
  br label %continue__4

continue__4:                                      ; preds = %continue__5, %then0__4
  br label %continue__3

continue__3:                                      ; preds = %continue__4, %then0__3
  br label %continue__2

continue__2:                                      ; preds = %continue__3, %then0__2
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  %12 = load i64, i64* %testResult
  ret i64 %12
}

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays(i64 %array__count, i64* %array, i64 %index, i64 %val, i1 %dummy) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %array__count)
  %1 = icmp sgt i64 %array__count, 0
  br i1 %1, label %copy, label %next

copy:                                             ; preds = %entry
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %3 = mul i64 %array__count, 8
  call void @llvm.memcpy.p0i8.p0i64.i64(i8* %2, i64* %array, i64 %3, i1 false)
  br label %next

next:                                             ; preds = %copy, %entry
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %0, i64 %index, i64 %val, i1 %dummy)
  ret i64 %4
}

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i64.i64(i8* noalias nocapture writeonly, i64* noalias nocapture readonly, i64, i1 immarg) #1

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind willreturn }
