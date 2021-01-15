
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, i64 %index, i64 %val) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %array)
  %local = alloca %Array*
  store %Array* %array, %Array** %local
  call void @__quantum__rt__array_add_access(%Array* %array)
  %0 = call %Array* @__quantum__rt__array_copy(%Array* %array, i1 false)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %index)
  %2 = bitcast i8* %1 to i64*
  %3 = load i64, i64* %2
  store i64 %val, i64* %2
  call void @__quantum__rt__array_remove_access(%Array* %array)
  store %Array* %0, %Array** %local
  call void @__quantum__rt__array_add_access(%Array* %0)
  %n = call i64 @__quantum__rt__array_get_size_1d(%Array* %0)
  %4 = sub i64 %n, 1
  %5 = load %Range, %Range* @EmptyRange
  %6 = insertvalue %Range %5, i64 %index, 0
  %7 = insertvalue %Range %6, i64 1, 1
  %8 = insertvalue %Range %7, i64 %4, 2
  %slice1 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %8, i1 false)
  call void @__quantum__rt__array_add_access(%Array* %slice1)
  %9 = load %Range, %Range* @EmptyRange
  %10 = insertvalue %Range %9, i64 %index, 0
  %11 = insertvalue %Range %10, i64 -2, 1
  %12 = insertvalue %Range %11, i64 0, 2
  %slice2 = call %Array* @__quantum__rt__array_slice_1d(%Array* %0, %Range %12, i1 false)
  call void @__quantum__rt__array_add_access(%Array* %slice2)
  %result = call %Array* @__quantum__rt__array_concatenate(%Array* %slice2, %Array* %slice1)
  call void @__quantum__rt__array_add_access(%Array* %result)
  %sum = alloca i64
  store i64 0, i64* %sum
  %13 = call i64 @__quantum__rt__array_get_size_1d(%Array* %result)
  %14 = sub i64 %13, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 0, %entry ], [ %23, %exiting__1 ]
  %15 = icmp sge i64 %i, %14
  %16 = icmp sle i64 %i, %14
  %17 = select i1 true, i1 %16, i1 %15
  br i1 %17, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %18 = load i64, i64* %sum
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %result, i64 %i)
  %20 = bitcast i8* %19 to i64*
  %21 = load i64, i64* %20
  %22 = add i64 %18, %21
  store i64 %22, i64* %sum
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %23 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %24 = load i64, i64* %sum
  call void @__quantum__rt__array_remove_access(%Array* %array)
  call void @__quantum__rt__array_remove_access(%Array* %0)
  call void @__quantum__rt__array_remove_access(%Array* %slice1)
  call void @__quantum__rt__array_remove_access(%Array* %slice2)
  call void @__quantum__rt__array_remove_access(%Array* %result)
  call void @__quantum__rt__array_unreference(%Array* %0)
  call void @__quantum__rt__array_unreference(%Array* %slice1)
  call void @__quantum__rt__array_unreference(%Array* %slice2)
  call void @__quantum__rt__array_unreference(%Array* %result)
  ret i64 %24
}

declare void @__quantum__rt__array_add_access(%Array*)

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_remove_access(%Array*)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare %Array* @__quantum__rt__array_slice_1d(%Array*, %Range, i1)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

declare void @__quantum__rt__array_unreference(%Array*)

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
  call void @__quantum__rt__array_unreference(%Array* %0)
  ret i64 %4
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i64.i64(i8* noalias nocapture writeonly, i64* noalias nocapture readonly, i64, i1 immarg) #1

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind willreturn }
