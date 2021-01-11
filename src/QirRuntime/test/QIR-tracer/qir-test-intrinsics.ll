
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque
%Tuple = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft_Quantum_Testing_Tracer_AllIntrinsics = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

declare void @__quantum__trc__single_qubit_op(i64, i64, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
;  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %ctls, i32 0)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
;  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

declare void @__quantum__rt__array_add_access(%Array*)

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

declare void @__quantum__trc__single_qubit_op_ctl(i64, i64, %Array*, %Qubit*)

declare void @__quantum__rt__array_remove_access(%Array*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
;  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %ctls, i32 0)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
;  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define i1 @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body() #0 {
entry:
  %res = alloca i1
  store i1 false, i1* %res
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
;  call void @__quantum__rt__array_add_access(%Array* %qs)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb__inline__1 = load %Qubit*, %Qubit** %1
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__1)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__inline__2 = load %Qubit*, %Qubit** %3
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__2)
  %c = call %Qubit* @__quantum__rt__qubit_allocate()
  %4 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %4, i64 0)
  %6 = bitcast i8* %5 to %Qubit**
  store %Qubit* %c, %Qubit** %6
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %8 = bitcast i8* %7 to %Qubit**
  %9 = load %Qubit*, %Qubit** %8
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %11 = bitcast %Tuple* %10 to { %Array*, %Qubit* }*
  %12 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %11, i64 0, i32 0
  %13 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %11, i64 0, i32 1
  store %Array* %4, %Array** %12
  call void @__quantum__rt__array_reference(%Array* %4)
  store %Qubit* %9, %Qubit** %13
  %14 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %11, i64 0, i32 0
  %ctls__inline__3 = load %Array*, %Array** %14
;  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__3)
  %15 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %11, i64 0, i32 1
  %qb__inline__3 = load %Qubit*, %Qubit** %15
  %16 = call i64 @__quantum__rt__array_get_length(%Array* %ctls__inline__3, i32 0)
  %17 = icmp eq i64 %16, 1
  br i1 %17, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__3, %Qubit* %qb__inline__3)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__3, %Qubit* %qb__inline__3)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
;  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__3)
  call void @__quantum__rt__array_unreference(%Array* %4)
  %18 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %11, i64 0, i32 0
  %19 = load %Array*, %Array** %18
  call void @__quantum__rt__array_unreference(%Array* %19)
  call void @__quantum__rt__tuple_unreference(%Tuple* %10)
  call void @__quantum__rt__qubit_release(%Qubit* %c)
  %cc = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
;  call void @__quantum__rt__array_add_access(%Array* %cc)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %21 = bitcast i8* %20 to %Qubit**
  %22 = load %Qubit*, %Qubit** %21
  %23 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %24 = bitcast %Tuple* %23 to { %Array*, %Qubit* }*
  %25 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %24, i64 0, i32 0
  %26 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %24, i64 0, i32 1
  store %Array* %cc, %Array** %25
  call void @__quantum__rt__array_reference(%Array* %cc)
  store %Qubit* %22, %Qubit** %26
  %27 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %24, i64 0, i32 0
  %ctls__inline__4 = load %Array*, %Array** %27
;  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__4)
  %28 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %24, i64 0, i32 1
  %qb__inline__4 = load %Qubit*, %Qubit** %28
  %29 = call i64 @__quantum__rt__array_get_length(%Array* %ctls__inline__4, i32 0)
  %30 = icmp eq i64 %29, 1
  br i1 %30, label %then0__2, label %else__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__4, %Qubit* %qb__inline__4)
  br label %continue__2

else__2:                                          ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__4, %Qubit* %qb__inline__4)
  br label %continue__2

continue__2:                                      ; preds = %else__2, %then0__2
;  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__4)
  %31 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %24, i64 0, i32 0
  %32 = load %Array*, %Array** %31
  call void @__quantum__rt__array_unreference(%Array* %32)
  call void @__quantum__rt__tuple_unreference(%Tuple* %23)
  call void @__quantum__rt__qubit_release_array(%Array* %cc)
;  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_unreference(%Array* %cc)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
;  call void @__quantum__rt__array_remove_access(%Array* %qs)
  call void @__quantum__rt__array_unreference(%Array* %qs)
  ret i1 true
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__array_reference(%Array*)

declare void @__quantum__rt__array_unreference(%Array*)

declare void @__quantum__rt__tuple_unreference(%Tuple*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

attributes #0 = { "EntryPoint" }
