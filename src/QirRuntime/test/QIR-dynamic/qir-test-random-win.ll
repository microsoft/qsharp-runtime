
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque

@ResultZero = external dllimport global %Result*
@ResultOne = external dllimport global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator = alias i64 (), i64 ()* @Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qb) {
entry:
  %bases__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__1, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliZ
  store i2 %2, i2* %1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__1, i64 1)
  %qubits__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits__inline__1, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %qb, %Qubit** %4
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits__inline__1, i64 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases__inline__1, %Array* %qubits__inline__1)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits__inline__1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases__inline__1, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits__inline__1, i64 -1)
  ret %Result* %5
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__h__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__h__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define i64 @Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body() #0 {
entry:
  %randomNumber = alloca i64
  store i64 0, i64* %randomNumber
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 1, %entry ], [ %8, %exiting__1 ]
  %0 = icmp sle i64 %i, 64
  br i1 %0, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  call void @__quantum__qis__h__body(%Qubit* %q)
  %1 = load i64, i64* %randomNumber
  %2 = shl i64 %1, 1
  store i64 %2, i64* %randomNumber
  %3 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %q)
  %4 = load %Result*, %Result** @ResultOne
  %5 = call i1 @__quantum__rt__result_equal(%Result* %3, %Result* %4)
  br i1 %5, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %6 = load i64, i64* %randomNumber
  %7 = add i64 %6, 1
  store i64 %7, i64* %randomNumber
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__result_update_reference_count(%Result* %3, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %8 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %9 = load i64, i64* %randomNumber
  ret i64 %9
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

attributes #0 = { "EntryPoint" }
