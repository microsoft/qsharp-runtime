
%Result = type opaque
%Range = type { i64, i64, i64 }
%String = type opaque
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, i64 %index, i64 %val) {
entry:
  %local = alloca %Array*
  store %Array* %array, %Array** %local
  %0 = load %Array*, %Array** %local
  %1 = call %Array* @__quantum__rt__array_copy(%Array* %0)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %1, i64 %index)
  %3 = bitcast i8* %2 to i64*
  store i64 %val, i64* %3
  store %Array* %1, %Array** %local
  call void @__quantum__rt__array_reference(%Array* %1)
  %4 = load %Array*, %Array** %local
  %n = call i64 @__quantum__rt__array_get_length(%Array* %4, i32 0)
  %5 = load %Array*, %Array** %local
  %6 = load %Array*, %Array** %local
  %7 = call i64 @__quantum__rt__array_get_length(%Array* %6, i32 0)
  %8 = sub i64 %7, 1
  %9 = load %Range, %Range* @EmptyRange
  %10 = insertvalue %Range %9, i64 %index, 0
  %11 = insertvalue %Range %10, i64 1, 1
  %12 = insertvalue %Range %11, i64 %8, 2
  %slice1 = call %Array* @__quantum__rt__array_slice(%Array* %5, i32 0, %Range %12)
  %13 = load %Array*, %Array** %local
  %14 = load %Range, %Range* @EmptyRange
  %15 = insertvalue %Range %14, i64 %index, 0
  %16 = insertvalue %Range %15, i64 -2, 1
  %17 = insertvalue %Range %16, i64 0, 2
  %slice2 = call %Array* @__quantum__rt__array_slice(%Array* %13, i32 0, %Range %17)
  %result = call %Array* @__quantum__rt__array_concatenate(%Array* %slice2, %Array* %slice1)
  %sum = alloca i64
  store i64 0, i64* %sum
  %18 = call i64 @__quantum__rt__array_get_length(%Array* %result, i32 0)
  %end__1 = sub i64 %18, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %27, %exiting__1 ]
  %19 = icmp sge i64 %i, %end__1
  %20 = icmp sle i64 %i, %end__1
  %21 = select i1 true, i1 %20, i1 %19
  br i1 %21, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %22 = load i64, i64* %sum
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %result, i64 %i)
  %24 = bitcast i8* %23 to i64*
  %25 = load i64, i64* %24
  %26 = add i64 %22, %25
  store i64 %26, i64* %sum
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %27 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %28 = load i64, i64* %sum
  call void @__quantum__rt__array_unreference(%Array* %1)
  call void @__quantum__rt__array_unreference(%Array* %slice1)
  call void @__quantum__rt__array_unreference(%Array* %slice2)
  call void @__quantum__rt__array_unreference(%Array* %result)
  ret i64 %28
}

declare %Array* @__quantum__rt__array_copy(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_reference(%Array*)

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

declare %Array* @__quantum__rt__array_slice(%Array*, i32, %Range)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

declare void @__quantum__rt__array_unreference(%Array*)

define i64 @Microsoft_Quantum_Testing_QIR_Test_Arrays(i64 %array__count, i64* %array, i64 %index, i64 %val) #0 {
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
