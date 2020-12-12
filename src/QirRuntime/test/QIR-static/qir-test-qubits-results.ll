
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%TupleHeader = type { i32, i32 }
%Array = type opaque
%String = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft_Quantum_Testing_QIR_Test_Qubit_Result_Management = alias i1 (), i1 ()* @Microsoft__Quantum__Testing__QIR__Test_Qubit_Result_Management__body

declare void @__quantum__qis__x__(%Qubit*)


define i1 @Microsoft__Quantum__Testing__QIR__Test_Qubit_Result_Management__body() #0 {
entry:
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %1 = bitcast i8* %0 to %Qubit**
  %.qb = load %Qubit*, %Qubit** %1
  call void @__quantum__qis__x__(%Qubit* %.qb)
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 1)
  %3 = bitcast i8* %2 to %Qubit**
  %4 = load %Qubit*, %Qubit** %3
  %5 = call %Result* @__quantum__qis__mz(%Qubit* %4)
  %6 = load %Result*, %Result** @ResultOne
  %7 = call i1 @__quantum__rt__result_equal(%Result* %5, %Result* %6)
  br i1 %7, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__(%Qubit* %q)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %9 = bitcast i8* %8 to %Qubit**
  %10 = load %Qubit*, %Qubit** %9
  %11 = call %Result* @__quantum__qis__mz(%Qubit* %10)
  %12 = call %Result* @__quantum__qis__mz(%Qubit* %q)
  %13 = call i1 @__quantum__rt__result_equal(%Result* %11, %Result* %12)
  %14 = xor i1 %13, true
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  ret i1 %14
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)


attributes #0 = { "EntryPoint" }
