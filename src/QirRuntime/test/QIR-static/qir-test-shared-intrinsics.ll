; QIR is generated on the assumption of a single IR file per project (as users won't be touching them). However, it's 
; more convenient for the tests to have multiple separate IR files, which means we have to extract some common bits
; into shared.ll and manually delete them from the auto-generated QIR to avoid the linker errors about duplicated defs.
;
; The tests that need to use custom implementation of intrinsics must be compiled into a separate executable.

%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32 }
%Qubit = type opaque
%String = type opaque
%Array = type opaque
%Callable = type opaque

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)
declare void @__quantum__qis__h(%Qubit*)
declare %Result* @__quantum__qis__mz(%Qubit*)
declare void @__quantum__qis__rx(double, %Qubit*)
declare void @__quantum__qis__rz(double, %Qubit*)
declare void @__quantum__qis__s(%Qubit*)
declare void @__quantum__qis__t(%Qubit*)
declare void @__quantum__qis__x(%Qubit*)
declare double @__quantum__qis__intAsDouble(i64)
declare %Result* @__quantum__qis__measure(%Array*, %Array*)


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


define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  call void @__quantum__qis__cnot(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__h(%Qubit* %qb)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rx(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rx(double %0, %Qubit* %qb)
  ret void
}


define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rz(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rz(double %0, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__t(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x(%Qubit* %qb)
  ret void
}

define double @Microsoft__Quantum__Intrinsic__IntAsDouble__body(i64 %i) {
entry:
  %0 = call double @__quantum__qis__intAsDouble(i64 %i)
  ret double %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  %0 = call %Result* @__quantum__qis__measure(%Array* %bases, %Array* %qubits)
  ret %Result* %0
}