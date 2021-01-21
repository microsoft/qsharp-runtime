
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

define i64 @Microsoft__Quantum__Testing__QIR__QuantumRandomNumberGenerator__body() #0 {
entry:
  %randomNumber = alloca i64
  store i64 0, i64* %randomNumber
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %i = phi i64 [ 1, %entry ], [ %10, %exiting__1 ]
  %0 = icmp sge i64 %i, 64
  %1 = icmp sle i64 %i, 64
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  call void @__quantum__qis__h__body(%Qubit* %q)
  %3 = load i64, i64* %randomNumber
  %4 = shl i64 %3, 1
  store i64 %4, i64* %randomNumber
  %5 = call %Result* @__quantum__qis__mz(%Qubit* %q)
  %6 = load %Result*, %Result** @ResultOne
  %7 = call i1 @__quantum__rt__result_equal(%Result* %5, %Result* %6)
  br i1 %7, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %8 = load i64, i64* %randomNumber
  %9 = add i64 %8, 1
  store i64 %9, i64* %randomNumber
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__result_unreference(%Result* %5)
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %10 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %11 = load i64, i64* %randomNumber
  ret i64 %11
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__result_unreference(%Result*)

attributes #0 = { "EntryPoint" }
