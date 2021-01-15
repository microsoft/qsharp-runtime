
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Testing__Tracer__AllIntrinsics = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body

define void @Microsoft__Quantum__Intrinsic__Sz__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

declare void @__quantum__trc__single_qubit_op(i64, i64, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Sz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Sz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

declare void @__quantum__rt__array_add_access(%Array*)

declare void @__quantum__trc__single_qubit_op_ctl(i64, i64, %Array*, %Qubit*)

declare void @__quantum__rt__array_remove_access(%Array*)

define void @Microsoft__Quantum__Intrinsic__Sz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__1, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__1)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__1)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_unreference(%Array*)

define void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %control, %Qubit* %target) {
entry:
  %ctls__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__1, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  store %Qubit* %control, %Qubit** %1
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__1)
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__1, %Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__1)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Tz__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 23, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 24, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__adj(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctl(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Ry__ctladj(%Array* %ctls, { double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %1 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 0
  %theta = load double, double* %1
  %2 = getelementptr { double, %Qubit* }, { double, %Qubit* }* %0, i64 0, i32 1
  %qb = load %Qubit*, %Qubit** %2
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls, %Qubit* %qb)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qb) {
entry:
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %ctls, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_add_access(%Array* %ctls)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %ctls)
  %1 = icmp eq i64 %0, 1
  br i1 %1, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls, %Qubit* %qb)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls)
  ret void
}

define i1 @Microsoft__Quantum__Testing__Tracer__AllIntrinsics__body() #0 {
entry:
  %res = alloca i1
  store i1 false, i1* %res
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_add_access(%Array* %qs)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %1 = bitcast i8* %0 to %Qubit**
  %qb__inline__1 = load %Qubit*, %Qubit** %1
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__1)
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %3 = bitcast i8* %2 to %Qubit**
  %qb__inline__2 = load %Qubit*, %Qubit** %3
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb__inline__2)
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %5 = bitcast i8* %4 to %Qubit**
  %qb__inline__3 = load %Qubit*, %Qubit** %5
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb__inline__3)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %7 = bitcast i8* %6 to %Qubit**
  %qb__inline__4 = load %Qubit*, %Qubit** %7
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb__inline__4)
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %12 = bitcast i8* %11 to %Qubit**
  %13 = load %Qubit*, %Qubit** %12
  call void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %10, %Qubit* %13)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %15 = bitcast i8* %14 to %Qubit**
  %qb__inline__5 = load %Qubit*, %Qubit** %15
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb__inline__5)
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %17 = bitcast i8* %16 to %Qubit**
  %qb__inline__6 = load %Qubit*, %Qubit** %17
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb__inline__6)
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %19 = bitcast i8* %18 to %Qubit**
  %qb__inline__7 = load %Qubit*, %Qubit** %19
  call void @__quantum__trc__single_qubit_op(i64 23, i64 1, %Qubit* %qb__inline__7)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %21 = bitcast i8* %20 to %Qubit**
  %qb__inline__8 = load %Qubit*, %Qubit** %21
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb__inline__8)
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %23 = bitcast i8* %22 to %Qubit**
  %qb__inline__10 = load %Qubit*, %Qubit** %23
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb__inline__10)
  call void @__quantum__trc__inject_global_barrier(i64 42, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %25 = bitcast i8* %24 to %Qubit**
  %qb__inline__12 = load %Qubit*, %Qubit** %25
  call void @__quantum__trc__single_qubit_op(i64 0, i64 1, %Qubit* %qb__inline__12)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %27 = bitcast i8* %26 to %Qubit**
  %qb__inline__13 = load %Qubit*, %Qubit** %27
  call void @__quantum__trc__single_qubit_op(i64 3, i64 1, %Qubit* %qb__inline__13)
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %29 = bitcast i8* %28 to %Qubit**
  %qb__inline__14 = load %Qubit*, %Qubit** %29
  call void @__quantum__trc__single_qubit_op(i64 6, i64 1, %Qubit* %qb__inline__14)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %31 = bitcast i8* %30 to %Qubit**
  %qb__inline__15 = load %Qubit*, %Qubit** %31
  call void @__quantum__trc__single_qubit_op(i64 9, i64 1, %Qubit* %qb__inline__15)
  %32 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %33 = bitcast i8* %32 to %Qubit**
  %34 = load %Qubit*, %Qubit** %33
  %35 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %36 = bitcast i8* %35 to %Qubit**
  %37 = load %Qubit*, %Qubit** %36
  call void @Microsoft__Quantum__Intrinsic__CNOT__adj(%Qubit* %34, %Qubit* %37)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %39 = bitcast i8* %38 to %Qubit**
  %qb__inline__16 = load %Qubit*, %Qubit** %39
  call void @__quantum__trc__single_qubit_op(i64 19, i64 1, %Qubit* %qb__inline__16)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %41 = bitcast i8* %40 to %Qubit**
  %qb__inline__17 = load %Qubit*, %Qubit** %41
  call void @__quantum__trc__single_qubit_op(i64 21, i64 1, %Qubit* %qb__inline__17)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %43 = bitcast i8* %42 to %Qubit**
  %qb__inline__18 = load %Qubit*, %Qubit** %43
  call void @__quantum__trc__single_qubit_op(i64 24, i64 1, %Qubit* %qb__inline__18)
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %45 = bitcast i8* %44 to %Qubit**
  %qb__inline__19 = load %Qubit*, %Qubit** %45
  call void @__quantum__trc__single_qubit_op(i64 15, i64 1, %Qubit* %qb__inline__19)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %47 = bitcast i8* %46 to %Qubit**
  %qb__inline__21 = load %Qubit*, %Qubit** %47
  call void @__quantum__trc__single_qubit_op(i64 11, i64 1, %Qubit* %qb__inline__21)
  %c = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls__inline__23 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__23, i64 0)
  %49 = bitcast i8* %48 to %Qubit**
  store %Qubit* %c, %Qubit** %49
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__23)
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %51 = bitcast i8* %50 to %Qubit**
  %qb__inline__23 = load %Qubit*, %Qubit** %51
  br i1 true, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %ctls__inline__23, %Qubit* %qb__inline__23)
  br label %continue__1

else__1:                                          ; preds = %entry
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %ctls__inline__23, %Qubit* %qb__inline__23)
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then0__1
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__23)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__23)
  %ctls__inline__24 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__24, i64 0)
  %53 = bitcast i8* %52 to %Qubit**
  store %Qubit* %c, %Qubit** %53
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__24)
  %54 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %55 = bitcast i8* %54 to %Qubit**
  %qb__inline__24 = load %Qubit*, %Qubit** %55
  br i1 true, label %then0__2, label %else__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %ctls__inline__24, %Qubit* %qb__inline__24)
  br label %continue__2

else__2:                                          ; preds = %continue__1
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %ctls__inline__24, %Qubit* %qb__inline__24)
  br label %continue__2

continue__2:                                      ; preds = %else__2, %then0__2
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__24)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__24)
  %ctls__inline__25 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__25, i64 0)
  %57 = bitcast i8* %56 to %Qubit**
  store %Qubit* %c, %Qubit** %57
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__25)
  %58 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %59 = bitcast i8* %58 to %Qubit**
  %qb__inline__25 = load %Qubit*, %Qubit** %59
  br i1 true, label %then0__3, label %else__3

then0__3:                                         ; preds = %continue__2
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %ctls__inline__25, %Qubit* %qb__inline__25)
  br label %continue__3

else__3:                                          ; preds = %continue__2
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %ctls__inline__25, %Qubit* %qb__inline__25)
  br label %continue__3

continue__3:                                      ; preds = %else__3, %then0__3
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__25)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__25)
  %ctls__inline__26 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__26, i64 0)
  %61 = bitcast i8* %60 to %Qubit**
  store %Qubit* %c, %Qubit** %61
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__26)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %63 = bitcast i8* %62 to %Qubit**
  %qb__inline__26 = load %Qubit*, %Qubit** %63
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %ctls__inline__26, %Qubit* %qb__inline__26)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__26)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__26)
  %ctls__inline__27 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__27, i64 0)
  %65 = bitcast i8* %64 to %Qubit**
  store %Qubit* %c, %Qubit** %65
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__27)
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %67 = bitcast i8* %66 to %Qubit**
  %qb__inline__27 = load %Qubit*, %Qubit** %67
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %ctls__inline__27, %Qubit* %qb__inline__27)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__27)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__27)
  %ctls__inline__28 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %68 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__28, i64 0)
  %69 = bitcast i8* %68 to %Qubit**
  store %Qubit* %c, %Qubit** %69
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__28)
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %71 = bitcast i8* %70 to %Qubit**
  %qb__inline__28 = load %Qubit*, %Qubit** %71
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %ctls__inline__28, %Qubit* %qb__inline__28)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__28)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__28)
  %ctls__inline__29 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__29, i64 0)
  %73 = bitcast i8* %72 to %Qubit**
  store %Qubit* %c, %Qubit** %73
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__29)
  %74 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %75 = bitcast i8* %74 to %Qubit**
  %qb__inline__29 = load %Qubit*, %Qubit** %75
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %ctls__inline__29, %Qubit* %qb__inline__29)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__29)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__29)
  %ctls__inline__30 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__30, i64 0)
  %77 = bitcast i8* %76 to %Qubit**
  store %Qubit* %c, %Qubit** %77
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__30)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %79 = bitcast i8* %78 to %Qubit**
  %qb__inline__30 = load %Qubit*, %Qubit** %79
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__30)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %ctls__inline__30, %Qubit* %qb__inline__30)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__30)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__30)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__30)
  %ctls__inline__32 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %80 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls__inline__32, i64 0)
  %81 = bitcast i8* %80 to %Qubit**
  store %Qubit* %c, %Qubit** %81
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__32)
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %83 = bitcast i8* %82 to %Qubit**
  %qb__inline__32 = load %Qubit*, %Qubit** %83
  call void @__quantum__rt__array_add_access(%Array* %ctls__inline__32)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %ctls__inline__32, %Qubit* %qb__inline__32)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__32)
  call void @__quantum__rt__array_remove_access(%Array* %ctls__inline__32)
  call void @__quantum__rt__array_unreference(%Array* %ctls__inline__32)
  call void @__quantum__rt__qubit_release(%Qubit* %c)
  %cc = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %84 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %85 = bitcast i8* %84 to %Qubit**
  %qb__inline__34 = load %Qubit*, %Qubit** %85
  %86 = call i64 @__quantum__rt__array_get_size_1d(%Array* %cc)
  %87 = icmp eq i64 %86, 1
  br i1 %87, label %then0__4, label %else__4

then0__4:                                         ; preds = %continue__3
  call void @__quantum__trc__single_qubit_op_ctl(i64 1, i64 1, %Array* %cc, %Qubit* %qb__inline__34)
  br label %continue__4

else__4:                                          ; preds = %continue__3
  call void @__quantum__trc__single_qubit_op_ctl(i64 2, i64 1, %Array* %cc, %Qubit* %qb__inline__34)
  br label %continue__4

continue__4:                                      ; preds = %else__4, %then0__4
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %88 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %89 = bitcast i8* %88 to %Qubit**
  %qb__inline__35 = load %Qubit*, %Qubit** %89
  %90 = icmp eq i64 %86, 1
  br i1 %90, label %then0__5, label %else__5

then0__5:                                         ; preds = %continue__4
  call void @__quantum__trc__single_qubit_op_ctl(i64 4, i64 1, %Array* %cc, %Qubit* %qb__inline__35)
  br label %continue__5

else__5:                                          ; preds = %continue__4
  call void @__quantum__trc__single_qubit_op_ctl(i64 5, i64 1, %Array* %cc, %Qubit* %qb__inline__35)
  br label %continue__5

continue__5:                                      ; preds = %else__5, %then0__5
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %92 = bitcast i8* %91 to %Qubit**
  %qb__inline__36 = load %Qubit*, %Qubit** %92
  %93 = icmp eq i64 %86, 1
  br i1 %93, label %then0__6, label %else__6

then0__6:                                         ; preds = %continue__5
  call void @__quantum__trc__single_qubit_op_ctl(i64 7, i64 1, %Array* %cc, %Qubit* %qb__inline__36)
  br label %continue__6

else__6:                                          ; preds = %continue__5
  call void @__quantum__trc__single_qubit_op_ctl(i64 8, i64 1, %Array* %cc, %Qubit* %qb__inline__36)
  br label %continue__6

continue__6:                                      ; preds = %else__6, %then0__6
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %94 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %95 = bitcast i8* %94 to %Qubit**
  %qb__inline__37 = load %Qubit*, %Qubit** %95
  call void @__quantum__trc__single_qubit_op_ctl(i64 10, i64 1, %Array* %cc, %Qubit* %qb__inline__37)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %97 = bitcast i8* %96 to %Qubit**
  %qb__inline__38 = load %Qubit*, %Qubit** %97
  call void @__quantum__trc__single_qubit_op_ctl(i64 20, i64 1, %Array* %cc, %Qubit* %qb__inline__38)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %99 = bitcast i8* %98 to %Qubit**
  %qb__inline__39 = load %Qubit*, %Qubit** %99
  call void @__quantum__trc__single_qubit_op_ctl(i64 22, i64 1, %Array* %cc, %Qubit* %qb__inline__39)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %101 = bitcast i8* %100 to %Qubit**
  %qb__inline__40 = load %Qubit*, %Qubit** %101
  call void @__quantum__trc__single_qubit_op_ctl(i64 25, i64 1, %Array* %cc, %Qubit* %qb__inline__40)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %103 = bitcast i8* %102 to %Qubit**
  %qb__inline__41 = load %Qubit*, %Qubit** %103
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__trc__single_qubit_op_ctl(i64 16, i64 1, %Array* %cc, %Qubit* %qb__inline__41)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_add_access(%Array* %cc)
  %104 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %105 = bitcast i8* %104 to %Qubit**
  %qb__inline__43 = load %Qubit*, %Qubit** %105
  call void @__quantum__rt__array_add_access(%Array* %cc)
  call void @__quantum__trc__single_qubit_op_ctl(i64 12, i64 1, %Array* %cc, %Qubit* %qb__inline__43)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__qubit_release_array(%Array* %cc)
  call void @__quantum__rt__array_remove_access(%Array* %cc)
  call void @__quantum__rt__array_unreference(%Array* %cc)
  %qs12 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 0)
  %107 = bitcast i8* %106 to %Qubit**
  %108 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs12, i64 1)
  %109 = bitcast i8* %108 to %Qubit**
  %110 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %111 = bitcast i8* %110 to %Qubit**
  %112 = load %Qubit*, %Qubit** %111
  %113 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %114 = bitcast i8* %113 to %Qubit**
  %115 = load %Qubit*, %Qubit** %114
  store %Qubit* %112, %Qubit** %107
  store %Qubit* %115, %Qubit** %109
  call void @__quantum__rt__array_add_access(%Array* %qs12)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_remove_access(%Array* %qs)
  call void @__quantum__rt__array_remove_access(%Array* %qs12)
  call void @__quantum__rt__array_unreference(%Array* %qs)
  call void @__quantum__rt__array_unreference(%Array* %qs12)
  ret i1 true
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__trc__inject_global_barrier(i64, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

attributes #0 = { "EntryPoint" }
