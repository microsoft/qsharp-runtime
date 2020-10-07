
%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32 }
%Array = type opaque
%Callable = type opaque
%String = type opaque

@Microsoft__Quantum__Testing__QIR__Adder = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Adder__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]
@PartialApplication__1 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__1__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]

define double @Microsoft__Quantum__Testing__QIR__Adder__body(double %a, double %b) {
entry:
  %0 = fadd double %a, %b
  ret double %0
}

define i64 @Microsoft__Quantum__Testing__QIR__NetPositive__body(%Array* %array) {
entry:
  %count = alloca i64
  store i64 0, i64* %count
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %array, i32 0)
  %end__1 = sub i64 %0, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %12, %exiting__1 ]
  %1 = icmp sge i64 %iter__1, %end__1
  %2 = icmp sle i64 %iter__1, %end__1
  %3 = select i1 true, i1 %2, i1 %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %iter__1)
  %5 = bitcast i8* %4 to double*
  %element = load double, double* %5
  %6 = fcmp ogt double %element, 1.000000e-04
  br i1 %6, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  %7 = load i64, i64* %count
  %8 = add i64 %7, 1
  store i64 %8, i64* %count
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %9 = fcmp olt double %element, -1.000000e-04
  br i1 %9, label %then1__1, label %continue__1

then1__1:                                         ; preds = %test1__1
  %10 = load i64, i64* %count
  %11 = sub i64 %10, 1
  store i64 %11, i64* %count
  br label %continue__1

continue__1:                                      ; preds = %then1__1, %test1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %12 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %13 = load i64, i64* %count
  ret i64 %13
}

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

define i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %array, double %seed, i64 %count) {
entry:
  %current = alloca %Array*
  store %Array* %array, %Array** %current
  %posCount = alloca i64
  store i64 0, i64* %posCount
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 1, %preheader__1 ], [ %15, %exiting__1 ]
  %0 = icmp sge i64 %i, %count
  %1 = icmp sle i64 %i, %count
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %3 = load %Array*, %Array** %current
  %4 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable*, double }* getelementptr ({ %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* null, i32 1) to i64))
  %5 = bitcast %TupleHeader* %4 to { %TupleHeader, %Callable*, double }*
  %6 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %5, i32 0, i32 1
  %7 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Testing__QIR__Adder, %TupleHeader* null)
  store %Callable* %7, %Callable** %6
  %8 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %5, i32 0, i32 2
  store double %seed, double* %8
  %9 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__1, %TupleHeader* %4)
  %10 = call %Array* @Microsoft__Quantum__Testing__QIR__UpdateArray__body(%Array* %3, %Callable* %9)
  store %Array* %10, %Array** %current
  call void @__quantum__rt__array_reference(%Array* %10)
  %11 = load i64, i64* %posCount
  %12 = load %Array*, %Array** %current
  %13 = call i64 @Microsoft__Quantum__Testing__QIR__NetPositive__body(%Array* %12)
  %14 = add i64 %11, %13
  store i64 %14, i64* %posCount
  call void @__quantum__rt__callable_unreference(%Callable* %9)
  call void @__quantum__rt__array_unreference(%Array* %10)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %16 = load i64, i64* %posCount
  ret i64 %16
}

define %Array* @Microsoft__Quantum__Testing__QIR__UpdateArray__body(%Array* %array, %Callable* %mapper) {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 0)
  %result = alloca %Array*
  store %Array* %0, %Array** %result
  %1 = call i64 @__quantum__rt__array_get_length(%Array* %array, i32 0)
  %end__1 = sub i64 %1, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %19, %exiting__1 ]
  %2 = icmp sge i64 %iter__1, %end__1
  %3 = icmp sle i64 %iter__1, %end__1
  %4 = select i1 true, i1 %3, i1 %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %iter__1)
  %6 = bitcast i8* %5 to double*
  %element = load double, double* %6
  %7 = load %Array*, %Array** %result
  %8 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %8, i64 0)
  %10 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double }* getelementptr ({ %TupleHeader, double }, { %TupleHeader, double }* null, i32 1) to i64))
  %11 = bitcast %TupleHeader* %10 to { %TupleHeader, double }*
  %12 = getelementptr { %TupleHeader, double }, { %TupleHeader, double }* %11, i64 0, i32 1
  store double %element, double* %12
  %13 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double }* getelementptr ({ %TupleHeader, double }, { %TupleHeader, double }* null, i32 1) to i64))
  %14 = bitcast %TupleHeader* %13 to { %TupleHeader, double }*
  call void @__quantum__rt__callable_invoke(%Callable* %mapper, %TupleHeader* %10, %TupleHeader* %13)
  %15 = getelementptr { %TupleHeader, double }, { %TupleHeader, double }* %14, i64 0, i32 1
  %16 = load double, double* %15
  %17 = bitcast i8* %9 to double*
  store double %16, double* %17
  %18 = call %Array* @__quantum__rt__array_concatenate(%Array* %7, %Array* %8)
  store %Array* %18, %Array** %result
  call void @__quantum__rt__array_reference(%Array* %18)
  call void @__quantum__rt__array_unreference(%Array* %8)
  call void @__quantum__rt__array_unreference(%Array* %18)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %19 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %20 = load %Array*, %Array** %result
  call void @__quantum__rt__array_unreference(%Array* %0)
  ret %Array* %20
}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

define void @Microsoft__Quantum__Testing__QIR__Adder__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, double, double }*
  %1 = getelementptr { %TupleHeader, double, double }, { %TupleHeader, double, double }* %0, i64 0, i32 1
  %2 = load double, double* %1
  %3 = getelementptr { %TupleHeader, double, double }, { %TupleHeader, double, double }* %0, i64 0, i32 2
  %4 = load double, double* %3
  %5 = call double @Microsoft__Quantum__Testing__QIR__Adder__body(double %2, double %4)
  %6 = bitcast %TupleHeader* %result-tuple to { %TupleHeader, double }*
  %7 = getelementptr { %TupleHeader, double }, { %TupleHeader, double }* %6, i64 0, i32 1
  store double %5, double* %7
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)

define void @Lifted__PartialApplication__1__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, double }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, double }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, double }* getelementptr ({ %TupleHeader, double, double }, { %TupleHeader, double, double }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, double, double }*
  %4 = getelementptr { %TupleHeader, double, double }, { %TupleHeader, double, double }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i64 0, i32 2
  %6 = load double, double* %5
  store double %6, double* %4
  %7 = getelementptr { %TupleHeader, double, double }, { %TupleHeader, double, double }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, double }, { %TupleHeader, double }* %1, i64 0, i32 1
  %9 = load double, double* %8
  store double %9, double* %7
  %10 = getelementptr inbounds { %TupleHeader, %Callable*, double }, { %TupleHeader, %Callable*, double }* %0, i32 0, i32 1
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %TupleHeader*, %TupleHeader*)

declare void @__quantum__rt__tuple_unreference(%TupleHeader*)

declare void @__quantum__rt__array_reference(%Array*)

declare void @__quantum__rt__callable_unreference(%Callable*)

declare void @__quantum__rt__array_unreference(%Array*)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare i64 @Microsoft__Quantum__Core__RangeEnd__body(%Range)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStart__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStep__body(%Range)


define i64 @Microsoft_Quantum_Testing_QIR_Test_Arrays(i64 %array__count, double* %array, double %seed, i64 %count) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %array__count)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = mul i64 %array__count, 8
  %3 = bitcast double* %array to i8*
  call void @llvm.memcpy.p0i8.p0i8.i64(i8* %1, i8* %3, i64 %2, i1 false)
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__Test_Arrays__body(%Array* %0, double %seed, i64 %count)
  call void @__quantum__rt__array_unreference(%Array* %0)
  ret i64 %4
}

; Function Attrs: argmemonly nounwind
declare void @llvm.memcpy.p0i8.p0i8.i64(i8* nocapture writeonly, i8* nocapture readonly, i64, i1) #1

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind }


; manually authored test for multi-dimensional arrays
declare %Array* @__quantum__rt__array_create(i32, i32, ...)
declare i8* @__quantum__rt__array_get_element_ptr(%Array*, ...)
declare i32 @__quantum__rt__array_get_dim(%Array*)
declare %Array* @__quantum__rt__array_project(%Array*, i32, i64)
declare void @DebugLog(i64)

define i64 @TestMultidimArrays(i8 %val, i64 %dim0, i64 %dim1, i64 %dim2)
{
  %.ar = call %Array* (i32, i32, ...) @__quantum__rt__array_create(i32 1, i32 3, i64 %dim0, i64 %dim1, i64 %dim2)
  %elem_ptr = call i8* (%Array*, ...) @__quantum__rt__array_get_element_ptr(%Array* %.ar, i64 1, i64 1, i64 1)
  store i8 %val, i8* %elem_ptr
  %.project = call %Array* @__quantum__rt__array_project(%Array* %.ar, i32 1, i64 1)
  %project_dims = call i32 @__quantum__rt__array_get_dim(%Array* %.project)
  %project_dim0 = call i64 @__quantum__rt__array_get_length(%Array* %.project, i32 0)
  %project_dim1 = call i64 @__quantum__rt__array_get_length(%Array* %.project, i32 1)
  %project_elem_ptr = call i8* (%Array*, ...) @__quantum__rt__array_get_element_ptr(%Array* %.project, i64 1, i64 1)
  %project_val = load i8, i8* %project_elem_ptr
  %val64 = sext i8 %project_val to i64

  %t1 = add i64 %project_dim0, %project_dim1
  %t2 = sext i32 %project_dims to i64
  %av = udiv i64 %t1, %t2
  %t3 = add i64 %av, %val64
  ret i64 %t3
}
