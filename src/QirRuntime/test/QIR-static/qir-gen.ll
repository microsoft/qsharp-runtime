%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Callable = type opaque
%Qubit = type opaque
%String = type opaque
%Array = type opaque

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
@0 = internal constant [14 x i8] c"error code: 1\00"
@1 = internal constant [14 x i8] c"error code: 2\00"
@2 = internal constant [14 x i8] c"error code: 3\00"
@3 = internal constant [14 x i8] c"error code: 2\00"
@4 = internal constant [14 x i8] c"error code: 5\00"
@5 = internal constant [14 x i8] c"error code: 6\00"
@6 = internal constant [14 x i8] c"error code: 7\00"
@7 = internal constant [5 x i8] c"Test\00"
@8 = internal constant [30 x i8] c"Unexpected measurement result\00"
@Microsoft__Quantum__Testing__QIR__Subtract = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@PartialApplication__2 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@MemoryManagement__2 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__2__RefCount, void (%Tuple*, i64)* @MemoryManagement__2__AliasCount]
@9 = internal constant [20 x i8] c"Pauli value: PauliI\00"
@10 = internal constant [14 x i8] c"Pauli value: \00"
@11 = internal constant [7 x i8] c"PauliX\00"
@12 = internal constant [7 x i8] c"PauliY\00"
@13 = internal constant [7 x i8] c"PauliZ\00"

define void @Microsoft__Quantum__Testing__QIR__TestControlled__body() {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %1, i32 0, i32 0
  %3 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %1, i32 0, i32 1
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
  %q1 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q2 = call %Qubit* @__quantum__rt__qubit_allocate()
  %q3 = call %Qubit* @__quantum__rt__qubit_allocate()
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %6 = bitcast %Tuple* %5 to { %Qubit* }*
  %7 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %6, i32 0, i32 0
  store %Qubit* %q1, %Qubit** %7
  call void @__quantum__rt__callable_invoke(%Callable* %qop, %Tuple* %5, %Tuple* null)
  %8 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q1)
  %9 = load %Result*, %Result** @ResultOne
  %10 = call i1 @__quantum__rt__result_equal(%Result* %8, %Result* %9)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  %12 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @0, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
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
  call void @__quantum__rt__fail(%String* %12)
  unreachable

continue__1:                                      ; preds = %entry
  %13 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %14 = bitcast %Tuple* %13 to { %Qubit* }*
  %15 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %14, i32 0, i32 0
  store %Qubit* %q2, %Qubit** %15
  call void @__quantum__rt__callable_invoke(%Callable* %adj_qop, %Tuple* %13, %Tuple* null)
  %16 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q2)
  %17 = load %Result*, %Result** @ResultOne
  %18 = call i1 @__quantum__rt__result_equal(%Result* %16, %Result* %17)
  %19 = xor i1 %18, true
  br i1 %19, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  %20 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @1, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
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
  call void @__quantum__rt__fail(%String* %20)
  unreachable

continue__2:                                      ; preds = %continue__1
  %21 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %22 = bitcast %Tuple* %21 to { %Array*, %Qubit* }*
  %23 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i32 0, i32 0
  %24 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i32 0, i32 1
  %25 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %25, i64 0)
  %27 = bitcast i8* %26 to %Qubit**
  store %Qubit* %q1, %Qubit** %27
  store %Array* %25, %Array** %23
  store %Qubit* %q3, %Qubit** %24
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_qop, %Tuple* %21, %Tuple* null)
  %28 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %29 = load %Result*, %Result** @ResultOne
  %30 = call i1 @__quantum__rt__result_equal(%Result* %28, %Result* %29)
  %31 = xor i1 %30, true
  br i1 %31, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  %32 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @2, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
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
  call void @__quantum__rt__fail(%String* %32)
  unreachable

continue__3:                                      ; preds = %continue__2
  %33 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %34 = bitcast %Tuple* %33 to { %Array*, %Qubit* }*
  %35 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %34, i32 0, i32 0
  %36 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %34, i32 0, i32 1
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 0)
  %39 = bitcast i8* %38 to %Qubit**
  store %Qubit* %q2, %Qubit** %39
  store %Array* %37, %Array** %35
  store %Qubit* %q3, %Qubit** %36
  call void @__quantum__rt__callable_invoke(%Callable* %adj_ctl_qop, %Tuple* %33, %Tuple* null)
  %40 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %41 = load %Result*, %Result** @ResultZero
  %42 = call i1 @__quantum__rt__result_equal(%Result* %40, %Result* %41)
  %43 = xor i1 %42, true
  br i1 %43, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  %44 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @3, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %40, i64 -1)
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
  call void @__quantum__rt__fail(%String* %44)
  unreachable

continue__4:                                      ; preds = %continue__3
  %45 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %46 = bitcast %Tuple* %45 to { %Array*, { %Array*, %Qubit* }* }*
  %47 = getelementptr inbounds { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %46, i32 0, i32 0
  %48 = getelementptr inbounds { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %46, i32 0, i32 1
  %49 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %49, i64 0)
  %51 = bitcast i8* %50 to %Qubit**
  store %Qubit* %q1, %Qubit** %51
  %52 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %53 = bitcast %Tuple* %52 to { %Array*, %Qubit* }*
  %54 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %53, i32 0, i32 0
  %55 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %53, i32 0, i32 1
  %56 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %57 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %56, i64 0)
  %58 = bitcast i8* %57 to %Qubit**
  store %Qubit* %q2, %Qubit** %58
  store %Array* %56, %Array** %54
  store %Qubit* %q3, %Qubit** %55
  store %Array* %49, %Array** %47
  store { %Array*, %Qubit* }* %53, { %Array*, %Qubit* }** %48
  call void @__quantum__rt__callable_invoke(%Callable* %ctl_ctl_qop, %Tuple* %45, %Tuple* null)
  %59 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %60 = load %Result*, %Result** @ResultOne
  %61 = call i1 @__quantum__rt__result_equal(%Result* %59, %Result* %60)
  %62 = xor i1 %61, true
  br i1 %62, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  %63 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @4, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %40, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %49, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %56, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %52, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %45, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 -1)
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
  call void @__quantum__rt__fail(%String* %63)
  unreachable

continue__5:                                      ; preds = %continue__4
  %64 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %64, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %64)
  %65 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %66 = bitcast %Tuple* %65 to { %Array*, %Qubit* }*
  %67 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %66, i32 0, i32 0
  %68 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %66, i32 0, i32 1
  %69 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %69, i64 0)
  %71 = bitcast i8* %70 to %Qubit**
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %69, i64 1)
  %73 = bitcast i8* %72 to %Qubit**
  store %Qubit* %q1, %Qubit** %71
  store %Qubit* %q2, %Qubit** %73
  store %Array* %69, %Array** %67
  store %Qubit* %q3, %Qubit** %68
  call void @__quantum__rt__callable_invoke(%Callable* %64, %Tuple* %65, %Tuple* null)
  %74 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q3)
  %75 = load %Result*, %Result** @ResultZero
  %76 = call i1 @__quantum__rt__result_equal(%Result* %74, %Result* %75)
  %77 = xor i1 %76, true
  br i1 %77, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  %78 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @5, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %40, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %49, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %56, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %52, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %45, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %64, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %64, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %69, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %65, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %74, i64 -1)
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
  call void @__quantum__rt__fail(%String* %78)
  unreachable

continue__6:                                      ; preds = %continue__5
  %q4 = call %Qubit* @__quantum__rt__qubit_allocate()
  %79 = call %Callable* @__quantum__rt__callable_copy(%Callable* %qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %79, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %79)
  %80 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %81 = bitcast %Tuple* %80 to { %Qubit* }*
  %82 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %81, i32 0, i32 0
  store %Qubit* %q3, %Qubit** %82
  call void @__quantum__rt__callable_invoke(%Callable* %79, %Tuple* %80, %Tuple* null)
  %83 = call %Callable* @__quantum__rt__callable_copy(%Callable* %ctl_ctl_qop, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %83, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %83)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %83)
  %84 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %85 = bitcast %Tuple* %84 to { %Array*, { %Array*, { %Array*, %Qubit* }* }* }*
  %86 = getelementptr inbounds { %Array*, { %Array*, { %Array*, %Qubit* }* }* }, { %Array*, { %Array*, { %Array*, %Qubit* }* }* }* %85, i32 0, i32 0
  %87 = getelementptr inbounds { %Array*, { %Array*, { %Array*, %Qubit* }* }* }, { %Array*, { %Array*, { %Array*, %Qubit* }* }* }* %85, i32 0, i32 1
  %88 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %89 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %88, i64 0)
  %90 = bitcast i8* %89 to %Qubit**
  store %Qubit* %q1, %Qubit** %90
  %91 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %92 = bitcast %Tuple* %91 to { %Array*, { %Array*, %Qubit* }* }*
  %93 = getelementptr inbounds { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %92, i32 0, i32 0
  %94 = getelementptr inbounds { %Array*, { %Array*, %Qubit* }* }, { %Array*, { %Array*, %Qubit* }* }* %92, i32 0, i32 1
  %95 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %95, i64 0)
  %97 = bitcast i8* %96 to %Qubit**
  store %Qubit* %q2, %Qubit** %97
  %98 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %99 = bitcast %Tuple* %98 to { %Array*, %Qubit* }*
  %100 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %99, i32 0, i32 0
  %101 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %99, i32 0, i32 1
  %102 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %103 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %102, i64 0)
  %104 = bitcast i8* %103 to %Qubit**
  store %Qubit* %q3, %Qubit** %104
  store %Array* %102, %Array** %100
  store %Qubit* %q4, %Qubit** %101
  store %Array* %95, %Array** %93
  store { %Array*, %Qubit* }* %99, { %Array*, %Qubit* }** %94
  store %Array* %88, %Array** %86
  store { %Array*, { %Array*, %Qubit* }* }* %92, { %Array*, { %Array*, %Qubit* }* }** %87
  call void @__quantum__rt__callable_invoke(%Callable* %83, %Tuple* %84, %Tuple* null)
  %105 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q4)
  %106 = load %Result*, %Result** @ResultOne
  %107 = call i1 @__quantum__rt__result_equal(%Result* %105, %Result* %106)
  %108 = xor i1 %107, true
  br i1 %108, label %then0__7, label %continue__7

then0__7:                                         ; preds = %continue__6
  %109 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @6, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q4)
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
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
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %79, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %79, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %80, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %83, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %83, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %88, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %95, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %102, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %98, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %91, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %84, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %105, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %40, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %49, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %56, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %52, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %45, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %64, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %64, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %69, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %65, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %74, i64 -1)
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
  call void @__quantum__rt__fail(%String* %109)
  unreachable

continue__7:                                      ; preds = %continue__6
  call void @__quantum__rt__qubit_release(%Qubit* %q4)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %79, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %79, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %80, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %83, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %83, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %88, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %95, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %102, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %98, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %91, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %84, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %105, i64 -1)
  call void @__quantum__rt__qubit_release(%Qubit* %q1)
  call void @__quantum__rt__qubit_release(%Qubit* %q2)
  call void @__quantum__rt__qubit_release(%Qubit* %q3)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %16, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %25, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %28, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %37, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %40, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %49, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %56, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %52, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %45, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %59, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %64, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %64, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %69, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %65, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %74, i64 -1)
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
  ret void
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

define void @Microsoft__Quantum__Testing__QIR__Qop__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit*, i64 }*
  %1 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 1
  %3 = load %Qubit*, %Qubit** %1
  %4 = load i64, i64* %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %3, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit*, i64 }*
  %1 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 1
  %3 = load %Qubit*, %Qubit** %1
  %4 = load i64, i64* %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__adj(%Qubit* %3, i64 %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { %Qubit*, i64 }* }*
  %1 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { %Qubit*, i64 }*, { %Qubit*, i64 }** %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctl(%Array* %3, { %Qubit*, i64 }* %4)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { %Qubit*, i64 }* }*
  %1 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { %Qubit*, i64 }*, { %Qubit*, i64 }** %2
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctladj(%Array* %3, { %Qubit*, i64 }* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i64)*]*, %Tuple*)

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %4 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %3, i32 0, i32 1
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Qubit*, i64 }*
  %8 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i32 0, i32 0
  %9 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i32 0, i32 1
  store %Qubit* %2, %Qubit** %8
  store i64 %5, i64* %9
  %10 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %3, i32 0, i32 0
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr inbounds { %Qubit* }, { %Qubit* }* %0, i32 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %4 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %3, i32 0, i32 1
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Qubit*, i64 }*
  %8 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i32 0, i32 0
  %9 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %7, i32 0, i32 1
  store %Qubit* %2, %Qubit** %8
  store i64 %5, i64* %9
  %10 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %3, i32 0, i32 0
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
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %6 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %5, i32 0, i32 1
  %7 = load i64, i64* %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { %Qubit*, i64 }*
  %10 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i32 0, i32 1
  store %Qubit* %4, %Qubit** %10
  store i64 %7, i64* %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { %Qubit*, i64 }* }*
  %14 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i32 0, i32 0
  %15 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i32 0, i32 1
  store %Array* %3, %Array** %14
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  %16 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %5, i32 0, i32 0
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
  %1 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i32 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %6 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %5, i32 0, i32 1
  %7 = load i64, i64* %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { %Qubit*, i64 }*
  %10 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i32 0, i32 0
  %11 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %9, i32 0, i32 1
  store %Qubit* %4, %Qubit** %10
  store i64 %7, i64* %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { %Qubit*, i64 }* }*
  %14 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i32 0, i32 0
  %15 = getelementptr inbounds { %Array*, { %Qubit*, i64 }* }, { %Array*, { %Qubit*, i64 }* }* %13, i32 0, i32 1
  store %Array* %3, %Array** %14
  store { %Qubit*, i64 }* %9, { %Qubit*, i64 }** %15
  %16 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %5, i32 0, i32 0
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
  %1 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 0
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

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

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

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare %String* @__quantum__rt__string_create(i32, i8*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__fail(%String*)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, i64 %index, i64 %val, i1 %compilerDecoy) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %local = alloca %Array*
  store %Array* %array, %Array** %local
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  call void @__quantum__rt__array_update_reference_count(%Array* %array, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  %0 = call %Array* @__quantum__rt__array_copy(%Array* %array, i1 false)
  %1 = icmp ne %Array* %array, %0
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %index)
  %3 = bitcast i8* %2 to i64*
  store i64 %val, i64* %3
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %0, i64 1)
  store %Array* %0, %Array** %local
  %n = call i64 @__quantum__rt__array_get_size_1d(%Array* %0)
  %4 = sub i64 %n, 1
  %5 = load %Range, %Range* @EmptyRange
  %6 = insertvalue %Range %5, i64 %index, 0
  %7 = insertvalue %Range %6, i64 1, 1
  %8 = insertvalue %Range %7, i64 %4, 2
  %slice1 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %8, i1 false)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice1, i64 1)
  %9 = load %Range, %Range* @EmptyRange
  %10 = insertvalue %Range %9, i64 %index, 0
  %11 = insertvalue %Range %10, i64 -2, 1
  %12 = insertvalue %Range %11, i64 0, 2
  %slice2 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %12, i1 false)
  call void @__quantum__rt__array_update_alias_count(%Array* %slice2, i64 1)
  %result = call %Array* @__quantum__rt__array_concatenate(%Array* %slice2, %Array* %slice1)
  call void @__quantum__rt__array_update_alias_count(%Array* %result, i64 1)
  %sum = alloca i64
  store i64 0, i64* %sum
  %13 = call i64 @__quantum__rt__array_get_size_1d(%Array* %result)
  %14 = sub i64 %13, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %21, %exiting__1 ]
  %15 = icmp sle i64 %i, %14
  br i1 %15, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %16 = load i64, i64* %sum
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %result, i64 %i)
  %18 = bitcast i8* %17 to i64*
  %19 = load i64, i64* %18
  %20 = add i64 %16, %19
  store i64 %20, i64* %sum
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %21 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  br i1 %compilerDecoy, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__1
  call void @Microsoft__Quantum__Testing__QIR__TestControlled__body()
  %res2 = call i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 17, i64 42)
  call void @Microsoft__Quantum__Testing__QIR__TestQubitResultManagement__body()
  %res4 = call i64 @Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body()
  %res5 = call i64 @Microsoft__Quantum__Testing__QIR__Math__LogTest__body()
  %res6 = call i64 @Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body()
  %res7 = call i64 @Microsoft__Quantum__Testing__QIR__Str__PauliToStringTest__body()
  %res8 = call i64 @Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(i64 0, i64 1)
  %22 = call %String* @__quantum__rt__string_create(i32 4, i8* getelementptr inbounds ([5 x i8], [5 x i8]* @7, i32 0, i32 0))
  call void @Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(%String* %22)
  call void @__quantum__rt__string_update_reference_count(%String* %22, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %exit__1
  %23 = load i64, i64* %sum
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
  ret i64 %23
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare %Array* @__quantum__rt__array_slice_1d(%Array*, %Range, i1)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

define i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 %x, i64 %y) {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %1, i32 0, i32 0
  %3 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %1, i32 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__QIR__Subtract, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %4, %Callable** %2
  store i64 %x, i64* %3
  %subtractor = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__2, [2 x void (%Tuple*, i64)*]* @MemoryManagement__2, %Tuple* %0)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %subtractor, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %subtractor, i64 1)
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  %6 = bitcast %Tuple* %5 to { i64 }*
  %7 = getelementptr inbounds { i64 }, { i64 }* %6, i32 0, i32 0
  store i64 %y, i64* %7
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %subtractor, %Tuple* %5, %Tuple* %8)
  %9 = bitcast %Tuple* %8 to { i64 }*
  %10 = getelementptr inbounds { i64 }, { i64 }* %9, i32 0, i32 0
  %11 = load i64, i64* %10
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %subtractor, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %subtractor, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %5, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  ret i64 %11
}

define void @Microsoft__Quantum__Testing__QIR__TestQubitResultManagement__body() {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %1 = bitcast i8* %0 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %1
  call void @__quantum__qis__x__body(%Qubit* %qubit)
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
  br i1 %13, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  %14 = call %String* @__quantum__rt__string_create(i32 29, i8* getelementptr inbounds ([30 x i8], [30 x i8]* @8, i32 0, i32 0))
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %11, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %12, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__fail(%String* %14)
  unreachable

continue__2:                                      ; preds = %continue__1
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__result_update_reference_count(%Result* %5, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %11, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %12, i64 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__Math__SqrtTest__body() {
entry:
  %0 = call double @__quantum__qis__sqrt__body(double 4.000000e+00)
  %1 = fcmp one double 2.000000e+00, %0
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  ret i64 1

continue__1:                                      ; preds = %entry
  %2 = call double @__quantum__qis__sqrt__body(double 9.000000e+00)
  %3 = fcmp one double 3.000000e+00, %2
  br i1 %3, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  ret i64 2

continue__2:                                      ; preds = %continue__1
  %4 = call double @__quantum__qis__sqrt__body(double 1.000000e+02)
  %5 = fcmp one double 1.000000e+01, %4
  br i1 %5, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  ret i64 3

continue__3:                                      ; preds = %continue__2
  %d__4 = call double @__quantum__qis__sqrt__body(double -5.000000e+00)
  %6 = call i1 @__quantum__qis__isnan__body(double %d__4)
  %7 = xor i1 %6, true
  br i1 %7, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  ret i64 4

continue__4:                                      ; preds = %continue__3
  %d__5 = call double @__quantum__qis__nan__body()
  %d__6 = call double @__quantum__qis__sqrt__body(double %d__5)
  %8 = call i1 @__quantum__qis__isnan__body(double %d__6)
  %9 = xor i1 %8, true
  br i1 %9, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  ret i64 5

continue__5:                                      ; preds = %continue__4
  %d__7 = call double @__quantum__qis__infinity__body()
  %d__8 = call double @__quantum__qis__sqrt__body(double %d__7)
  %10 = call i1 @__quantum__qis__isinf__body(double %d__8)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  ret i64 6

continue__6:                                      ; preds = %continue__5
  ret i64 0
}

define i64 @Microsoft__Quantum__Testing__QIR__Math__LogTest__body() {
entry:
  %input = call double @Microsoft__Quantum__Math__E__body()
  %0 = call double @__quantum__qis__log__body(double %input)
  %1 = fcmp one double 1.000000e+00, %0
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  ret i64 1

continue__1:                                      ; preds = %entry
  %2 = call double @Microsoft__Quantum__Math__E__body()
  %3 = call double @Microsoft__Quantum__Math__E__body()
  %input__1 = fmul double %2, %3
  %4 = call double @__quantum__qis__log__body(double %input__1)
  %5 = fcmp one double 2.000000e+00, %4
  br i1 %5, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  ret i64 2

continue__2:                                      ; preds = %continue__1
  %d = call double @__quantum__qis__log__body(double 0.000000e+00)
  %6 = call i1 @__quantum__qis__isnegativeinfinity__body(double %d)
  %7 = xor i1 %6, true
  br i1 %7, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  ret i64 3

continue__3:                                      ; preds = %continue__2
  %d__1 = call double @__quantum__qis__log__body(double -5.000000e+00)
  %8 = call i1 @__quantum__qis__isnan__body(double %d__1)
  %9 = xor i1 %8, true
  br i1 %9, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  ret i64 4

continue__4:                                      ; preds = %continue__3
  %input__4 = call double @__quantum__qis__nan__body()
  %d__2 = call double @__quantum__qis__log__body(double %input__4)
  %10 = call i1 @__quantum__qis__isnan__body(double %d__2)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  ret i64 5

continue__5:                                      ; preds = %continue__4
  %input__5 = call double @__quantum__qis__infinity__body()
  %d__3 = call double @__quantum__qis__log__body(double %input__5)
  %12 = call i1 @__quantum__qis__isinf__body(double %d__3)
  %13 = xor i1 %12, true
  br i1 %13, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  ret i64 6

continue__6:                                      ; preds = %continue__5
  ret i64 0
}

define i64 @Microsoft__Quantum__Testing__QIR__Math__ArcTan2Test__body() {
entry:
  %0 = call double @__quantum__qis__arctan2__body(double 0.000000e+00, double 1.000000e+00)
  %1 = fcmp one double 0.000000e+00, %0
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  ret i64 1

continue__1:                                      ; preds = %entry
  %2 = call double @Microsoft__Quantum__Math__PI__body()
  %3 = call double @__quantum__qis__arctan2__body(double 0.000000e+00, double -1.000000e+00)
  %4 = fcmp one double %2, %3
  br i1 %4, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  ret i64 2

continue__2:                                      ; preds = %continue__1
  %5 = call double @Microsoft__Quantum__Math__PI__body()
  %6 = fdiv double %5, 2.000000e+00
  %7 = call double @__quantum__qis__arctan2__body(double 1.000000e+00, double 0.000000e+00)
  %8 = fcmp one double %6, %7
  br i1 %8, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  ret i64 3

continue__3:                                      ; preds = %continue__2
  %9 = call double @Microsoft__Quantum__Math__PI__body()
  %10 = fneg double %9
  %11 = fdiv double %10, 2.000000e+00
  %12 = call double @__quantum__qis__arctan2__body(double -1.000000e+00, double 0.000000e+00)
  %13 = fcmp one double %11, %12
  br i1 %13, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  ret i64 4

continue__4:                                      ; preds = %continue__3
  %14 = call double @Microsoft__Quantum__Math__PI__body()
  %15 = fdiv double %14, 4.000000e+00
  %16 = call double @__quantum__qis__arctan2__body(double 1.000000e+00, double 1.000000e+00)
  %17 = fcmp one double %15, %16
  br i1 %17, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  ret i64 5

continue__5:                                      ; preds = %continue__4
  %18 = call double @Microsoft__Quantum__Math__PI__body()
  %19 = fmul double %18, 3.000000e+00
  %20 = fdiv double %19, 4.000000e+00
  %21 = call double @__quantum__qis__arctan2__body(double 1.000000e+00, double -1.000000e+00)
  %22 = fcmp one double %20, %21
  br i1 %22, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  ret i64 6

continue__6:                                      ; preds = %continue__5
  %23 = call double @Microsoft__Quantum__Math__PI__body()
  %24 = fneg double %23
  %25 = fmul double %24, 3.000000e+00
  %26 = fdiv double %25, 4.000000e+00
  %27 = call double @__quantum__qis__arctan2__body(double -1.000000e+00, double -1.000000e+00)
  %28 = fcmp one double %26, %27
  br i1 %28, label %then0__7, label %continue__7

then0__7:                                         ; preds = %continue__6
  ret i64 7

continue__7:                                      ; preds = %continue__6
  %29 = call double @Microsoft__Quantum__Math__PI__body()
  %30 = fneg double %29
  %31 = fdiv double %30, 4.000000e+00
  %32 = call double @__quantum__qis__arctan2__body(double -1.000000e+00, double 1.000000e+00)
  %33 = fcmp one double %31, %32
  br i1 %33, label %then0__8, label %continue__8

then0__8:                                         ; preds = %continue__7
  ret i64 8

continue__8:                                      ; preds = %continue__7
  %34 = call double @__quantum__qis__arctan2__body(double 0.000000e+00, double 0.000000e+00)
  %35 = fcmp one double 0.000000e+00, %34
  br i1 %35, label %then0__9, label %continue__9

then0__9:                                         ; preds = %continue__8
  ret i64 9

continue__9:                                      ; preds = %continue__8
  %y__9 = call double @__quantum__qis__nan__body()
  %d = call double @__quantum__qis__arctan2__body(double %y__9, double 0.000000e+00)
  %36 = call i1 @__quantum__qis__isnan__body(double %d)
  %37 = xor i1 %36, true
  br i1 %37, label %then0__10, label %continue__10

then0__10:                                        ; preds = %continue__9
  ret i64 11

continue__10:                                     ; preds = %continue__9
  %x__10 = call double @__quantum__qis__nan__body()
  %d__1 = call double @__quantum__qis__arctan2__body(double 0.000000e+00, double %x__10)
  %38 = call i1 @__quantum__qis__isnan__body(double %d__1)
  %39 = xor i1 %38, true
  br i1 %39, label %then0__11, label %continue__11

then0__11:                                        ; preds = %continue__10
  ret i64 12

continue__11:                                     ; preds = %continue__10
  %y__11 = call double @__quantum__qis__nan__body()
  %x__11 = call double @__quantum__qis__nan__body()
  %d__2 = call double @__quantum__qis__arctan2__body(double %y__11, double %x__11)
  %40 = call i1 @__quantum__qis__isnan__body(double %d__2)
  %41 = xor i1 %40, true
  br i1 %41, label %then0__12, label %continue__12

then0__12:                                        ; preds = %continue__11
  ret i64 13

continue__12:                                     ; preds = %continue__11
  ret i64 0
}

define i64 @Microsoft__Quantum__Testing__QIR__Str__PauliToStringTest__body() {
entry:
  %0 = call %String* @__quantum__rt__string_create(i32 19, i8* getelementptr inbounds ([20 x i8], [20 x i8]* @9, i32 0, i32 0))
  %1 = call %String* @__quantum__rt__string_create(i32 13, i8* getelementptr inbounds ([14 x i8], [14 x i8]* @10, i32 0, i32 0))
  %2 = load i2, i2* @PauliI
  %3 = call %String* @__quantum__rt__pauli_to_string(i2 %2)
  %4 = call %String* @__quantum__rt__string_concatenate(%String* %1, %String* %3)
  call void @__quantum__rt__string_update_reference_count(%String* %1, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %3, i64 -1)
  %5 = call i1 @__quantum__rt__string_equal(%String* %0, %String* %4)
  %6 = xor i1 %5, true
  br i1 %6, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  ret i64 1

continue__1:                                      ; preds = %entry
  %7 = call %String* @__quantum__rt__string_create(i32 6, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @11, i32 0, i32 0))
  %8 = load i2, i2* @PauliX
  %9 = call %String* @__quantum__rt__pauli_to_string(i2 %8)
  %10 = call i1 @__quantum__rt__string_equal(%String* %7, %String* %9)
  %11 = xor i1 %10, true
  br i1 %11, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %7, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i64 -1)
  ret i64 2

continue__2:                                      ; preds = %continue__1
  %12 = call %String* @__quantum__rt__string_create(i32 6, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @12, i32 0, i32 0))
  %13 = load i2, i2* @PauliY
  %14 = call %String* @__quantum__rt__pauli_to_string(i2 %13)
  %15 = call i1 @__quantum__rt__string_equal(%String* %12, %String* %14)
  %16 = xor i1 %15, true
  br i1 %16, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %7, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %14, i64 -1)
  ret i64 3

continue__3:                                      ; preds = %continue__2
  %17 = call %String* @__quantum__rt__string_create(i32 6, i8* getelementptr inbounds ([7 x i8], [7 x i8]* @13, i32 0, i32 0))
  %18 = load i2, i2* @PauliZ
  %19 = call %String* @__quantum__rt__pauli_to_string(i2 %18)
  %20 = call i1 @__quantum__rt__string_equal(%String* %17, %String* %19)
  %21 = xor i1 %20, true
  br i1 %21, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %7, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %14, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i64 -1)
  ret i64 4

continue__4:                                      ; preds = %continue__3
  call void @__quantum__rt__string_update_reference_count(%String* %0, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %4, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %7, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %14, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %17, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %19, i64 -1)
  ret i64 0
}

define i64 @Microsoft__Quantum__Testing__QIR__Math__TestDrawRandomInt__body(i64 %min, i64 %max) {
entry:
  %0 = call i64 @__quantum__qis__drawrandomint__body(i64 %min, i64 %max)
  ret i64 %0
}

define void @Microsoft__Quantum__Testing__QIR__Out__MessageTest__body(%String* %msg) {
entry:
  call void @__quantum__qis__message__body(%String* %msg)
  ret void
}

declare void @__quantum__rt__string_update_reference_count(%String*, i64)

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

declare void @__quantum__qis__k__body(%Qubit*)

define void @Microsoft__Quantum__Testing__QIR__Qop__adj(%Qubit* %q, i64 %n) {
entry:
  call void @Microsoft__Quantum__Testing__QIR__Qop__body(%Qubit* %q, i64 %n)
  ret void
}

define void @Microsoft__Quantum__Testing__QIR__Qop__ctl(%Array* %ctrls, { %Qubit*, i64 }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %ctrls, i64 1)
  %1 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 1
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

declare void @__quantum__qis__k__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Testing__QIR__Qop__ctladj(%Array* %__controlQubits__, { %Qubit*, i64 }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 0
  %q = load %Qubit*, %Qubit** %1
  %2 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %0, i32 0, i32 1
  %n = load i64, i64* %2
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Qubit*, i64 }* getelementptr ({ %Qubit*, i64 }, { %Qubit*, i64 }* null, i32 1) to i64))
  %4 = bitcast %Tuple* %3 to { %Qubit*, i64 }*
  %5 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %4, i32 0, i32 0
  %6 = getelementptr inbounds { %Qubit*, i64 }, { %Qubit*, i64 }* %4, i32 0, i32 1
  store %Qubit* %q, %Qubit** %5
  store i64 %n, i64* %6
  call void @Microsoft__Quantum__Testing__QIR__Qop__ctl(%Array* %__controlQubits__, { %Qubit*, i64 }* %4)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %3, i64 -1)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %from, i64 %what) {
entry:
  %0 = sub i64 %from, %what
  ret i64 %0
}

declare void @__quantum__qis__x__body(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

define void @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i64, i64 }*
  %1 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %0, i32 0, i32 0
  %2 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %0, i32 0, i32 1
  %3 = load i64, i64* %1
  %4 = load i64, i64* %2
  %5 = call i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %3, i64 %4)
  %6 = bitcast %Tuple* %result-tuple to { i64 }*
  %7 = getelementptr inbounds { i64 }, { i64 }* %6, i32 0, i32 0
  store i64 %5, i64* %7
  ret void
}

define void @Lifted__PartialApplication__2__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 1
  %2 = load i64, i64* %1
  %3 = bitcast %Tuple* %arg-tuple to { i64 }*
  %4 = getelementptr inbounds { i64 }, { i64 }* %3, i32 0, i32 0
  %5 = load i64, i64* %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %7 = bitcast %Tuple* %6 to { i64, i64 }*
  %8 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %7, i32 0, i32 0
  %9 = getelementptr inbounds { i64, i64 }, { i64, i64 }* %7, i32 0, i32 1
  store i64 %2, i64* %8
  store i64 %5, i64* %9
  %10 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 0
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  ret void
}

define void @MemoryManagement__2__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__2__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = getelementptr inbounds { %Callable*, i64 }, { %Callable*, i64 }* %0, i32 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Message__body(%String* %msg) {
entry:
  call void @__quantum__qis__message__body(%String* %msg)
  ret void
}

declare void @__quantum__qis__message__body(%String*)

define void @Microsoft__Quantum__Intrinsic__K__body(%Qubit* %q) {
entry:
  call void @__quantum__qis__k__body(%Qubit* %q)
  ret void
}

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

define void @Microsoft__Quantum__Intrinsic__K__ctladj(%Array* %__controlQubits__, %Qubit* %q) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__k__ctl(%Array* %__controlQubits__, %Qubit* %q)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define i1 @Microsoft__Quantum__Intrinsic__IsNegativeInfinity__body(double %d) {
entry:
  %0 = call i1 @__quantum__qis__isnegativeinfinity__body(double %d)
  ret i1 %0
}

declare i1 @__quantum__qis__isnegativeinfinity__body(double)

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

define i1 @Microsoft__Quantum__Intrinsic__IsNan__body(double %d) {
entry:
  %0 = call i1 @__quantum__qis__isnan__body(double %d)
  ret i1 %0
}

declare i1 @__quantum__qis__isnan__body(double)

define double @Microsoft__Quantum__Intrinsic__NAN__body() {
entry:
  %0 = call double @__quantum__qis__nan__body()
  ret double %0
}

declare double @__quantum__qis__nan__body()

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

declare %String* @__quantum__rt__pauli_to_string(i2)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

declare i1 @__quantum__rt__string_equal(%String*, %String*)

declare i64 @__quantum__qis__drawrandomint__body(i64, i64)

define double @Microsoft__Quantum__Math__E__body() {
entry:
  ret double 0x4005BF0A8B145769
}

declare double @__quantum__qis__log__body(double)

declare double @__quantum__qis__arctan2__body(double, double)

define double @Microsoft__Quantum__Math__PI__body() {
entry:
  ret double 0x400921FB54442D18
}

declare double @__quantum__qis__sqrt__body(double)

define double @Microsoft__Quantum__Math__Sqrt__body(double %d) {
entry:
  %0 = call double @__quantum__qis__sqrt__body(double %d)
  ret double %0
}

define double @Microsoft__Quantum__Math__Log__body(double %input) {
entry:
  %0 = call double @__quantum__qis__log__body(double %input)
  ret double %0
}

define double @Microsoft__Quantum__Math__ArcTan2__body(double %y, double %x) {
entry:
  %0 = call double @__quantum__qis__arctan2__body(double %y, double %x)
  ret double %0
}

define i64 @Microsoft__Quantum__Random__DrawRandomInt__body(i64 %min, i64 %max) {
entry:
  %0 = call i64 @__quantum__qis__drawrandomint__body(i64 %min, i64 %max)
  ret i64 %0
}

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays(i64 %array__count, i64* %array, i64 %index, i64 %val, i1 %compilerDecoy) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %array__count)
  %1 = icmp sgt i64 %array__count, 0
  br i1 %1, label %copy, label %next

copy:                                             ; preds = %entry
  %2 = ptrtoint i64* %array to i64
  %3 = sub i64 %array__count, 1
  br label %header__1

next:                                             ; preds = %exit__1, %entry
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %0, i64 %index, i64 %val, i1 %compilerDecoy)
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  ret i64 %4

header__1:                                        ; preds = %exiting__1, %copy
  %5 = phi i64 [ 0, %copy ], [ %13, %exiting__1 ]
  %6 = icmp sle i64 %5, %3
  br i1 %6, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %7 = mul i64 %5, 8
  %8 = add i64 %2, %7
  %9 = inttoptr i64 %8 to i64*
  %10 = load i64, i64* %9
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %5)
  %12 = bitcast i8* %11 to i64*
  store i64 %10, i64* %12
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %13 = add i64 %5, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  br label %next
}

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

attributes #0 = { "EntryPoint" }
