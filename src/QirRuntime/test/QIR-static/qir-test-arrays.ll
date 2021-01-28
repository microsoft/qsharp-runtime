
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)


define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, i64 %index, i64 %val) {
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

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare %Array* @__quantum__rt__array_slice_1d(%Array*, %Range, i1)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays(i64 %array__count, i64* %array, i64 %index, i64 %val) #0 {
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
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %0, i64 %index, i64 %val)
  ret i64 %4
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i64.i64(i8* noalias nocapture writeonly, i64* noalias nocapture readonly, i64, i1 immarg) #1

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind willreturn }
