
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Array = type opaque
%Qubit = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Intrinsic__X = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__X__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__Y = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Y__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__Z = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__Z__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__H = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__H__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__S = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__S__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__T = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__T__ctladj__wrapper]
@Microsoft__Quantum__Intrinsic__R = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Intrinsic__R__ctladj__wrapper]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__ctladj__wrapper]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__1__RefCount, void (%Tuple*, i64)* @MemoryManagement__1__AliasCount]

@Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS = alias void (), void ()* @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

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

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__z__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__z__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__s__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s__adj(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__s__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__s__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__x__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__t__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__t__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__t__adj(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__t__adj(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__t__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__t__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__t__ctladj(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__t__ctladj(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qb)
  ret void
}

declare void @__quantum__qis__y__body(%Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__y__body(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

declare void @__quantum__qis__y__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__y__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Exp__body(%Array* %paulis, double %theta, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  call void @__quantum__qis__exp__body(%Array* %paulis, double %theta, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret void
}

declare void @__quantum__qis__exp__body(%Array*, double, %Array*)

define void @Microsoft__Quantum__Intrinsic__Exp__adj(%Array* %paulis, double %theta, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  call void @__quantum__qis__exp__adj(%Array* %paulis, double %theta, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret void
}

declare void @__quantum__qis__exp__adj(%Array*, double, %Array*)

define void @Microsoft__Quantum__Intrinsic__Exp__ctl(%Array* %__controlQubits__, { %Array*, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 0
  %paulis = load %Array*, %Array** %1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  %2 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 2
  %qubits = load %Array*, %Array** %3
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Array*, double, %Array* }*
  %6 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 0
  %7 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 1
  %8 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 2
  store %Array* %paulis, %Array** %6
  store double %theta, double* %7
  store %Array* %qubits, %Array** %8
  call void @__quantum__qis__exp__ctl(%Array* %__controlQubits__, { %Array*, double, %Array* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__exp__ctl(%Array*, { %Array*, double, %Array* }*)

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

define void @Microsoft__Quantum__Intrinsic__Exp__ctladj(%Array* %__controlQubits__, { %Array*, double, %Array* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 0
  %paulis = load %Array*, %Array** %1
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 1)
  %2 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %0, i64 0, i32 2
  %qubits = load %Array*, %Array** %3
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Array*, double, %Array* }*
  %6 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 0
  %7 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 1
  %8 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %5, i64 0, i32 2
  store %Array* %paulis, %Array** %6
  store double %theta, double* %7
  store %Array* %qubits, %Array** %8
  call void @__quantum__qis__exp__ctladj(%Array* %__controlQubits__, { %Array*, double, %Array* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__exp__ctladj(%Array*, { %Array*, double, %Array* }*)

define void @Microsoft__Quantum__Intrinsic__R__body(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__body(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__body(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__adj(i2 %pauli, double %theta, %Qubit* %qubit) {
entry:
  call void @__quantum__qis__r__adj(i2 %pauli, double %theta, %Qubit* %qubit)
  ret void
}

declare void @__quantum__qis__r__adj(i2, double, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 0
  %pauli = load i2, i2* %1
  %2 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 0
  %7 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 1
  %8 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 2
  store i2 %pauli, i2* %6
  store double %theta, double* %7
  store %Qubit* %qubit, %Qubit** %8
  call void @__quantum__qis__r__ctl(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__r__ctl(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 0
  %pauli = load i2, i2* %1
  %2 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 1
  %theta = load double, double* %2
  %3 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 2
  %qubit = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { i2, double, %Qubit* }*
  %6 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 0
  %7 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 1
  %8 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %5, i64 0, i32 2
  store i2 %pauli, i2* %6
  store double %theta, double* %7
  store %Qubit* %qubit, %Qubit** %8
  call void @__quantum__qis__r__ctladj(%Array* %__controlQubits__, { i2, double, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__qis__r__ctladj(%Array*, { i2, double, %Qubit* }*)

define void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %op) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 1)
  %target = call %Qubit* @__quantum__rt__qubit_allocate()
  %ctls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Qubit* }*
  %2 = getelementptr { %Qubit* }, { %Qubit* }* %1, i64 0, i32 0
  store %Qubit* %target, %Qubit** %2
  call void @__quantum__rt__callable_invoke(%Callable* %op, %Tuple* %0, %Tuple* null)
  %3 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %3)
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  %5 = bitcast %Tuple* %4 to { %Qubit* }*
  %6 = getelementptr { %Qubit* }, { %Qubit* }* %5, i64 0, i32 0
  store %Qubit* %target, %Qubit** %6
  call void @__quantum__rt__callable_invoke(%Callable* %3, %Tuple* %4, %Tuple* null)
  %7 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %7)
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %9 = bitcast %Tuple* %8 to { %Array*, %Qubit* }*
  %10 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %9, i64 0, i32 0
  %11 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %9, i64 0, i32 1
  store %Array* %ctls, %Array** %10
  store %Qubit* %target, %Qubit** %11
  call void @__quantum__rt__callable_invoke(%Callable* %7, %Tuple* %8, %Tuple* null)
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %12)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  %13 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %14 = bitcast %Tuple* %13 to { %Array*, %Qubit* }*
  %15 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %14, i64 0, i32 0
  %16 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %14, i64 0, i32 1
  store %Array* %ctls, %Array** %15
  store %Qubit* %target, %Qubit** %16
  call void @__quantum__rt__callable_invoke(%Callable* %12, %Tuple* %13, %Tuple* null)
  call void @__quantum__rt__qubit_release(%Qubit* %target)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %12, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %13, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 -1)
  ret void
}

declare void @__quantum__rt__callable_memory_management(i32, %Callable*, i64)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i64)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define void @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body() #0 {
entry:
  %0 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__X, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %0)
  %1 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Y, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %1)
  %2 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Z, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %2)
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__H, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %3)
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__S, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %4)
  %5 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__T, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %5)
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i2, double }* getelementptr ({ %Callable*, i2, double }, { %Callable*, i2, double }* null, i32 1) to i64))
  %7 = bitcast %Tuple* %6 to { %Callable*, i2, double }*
  %8 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %7, i64 0, i32 0
  %9 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %7, i64 0, i32 1
  %10 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %7, i64 0, i32 2
  %11 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__R, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %12 = load i2, i2* @PauliX
  store %Callable* %11, %Callable** %8
  store i2 %12, i2* %9
  store double 4.200000e-01, double* %10
  %13 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i64)*]* @MemoryManagement__1, %Tuple* %6)
  call void @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %13)
  %targets = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %ctls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %14 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__1, i64 0)
  %15 = bitcast i8* %14 to i2*
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__1, i64 1)
  %17 = bitcast i8* %16 to i2*
  %18 = load i2, i2* @PauliX
  %19 = load i2, i2* @PauliY
  store i2 %18, i2* %15
  store i2 %19, i2* %17
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__1, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  call void @__quantum__qis__exp__body(%Array* %paulis__inline__1, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__1, i64 -1)
  %paulis__inline__2 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %20 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__2, i64 0)
  %21 = bitcast i8* %20 to i2*
  %22 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__2, i64 1)
  %23 = bitcast i8* %22 to i2*
  %24 = load i2, i2* @PauliX
  %25 = load i2, i2* @PauliY
  store i2 %24, i2* %21
  store i2 %25, i2* %23
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__2, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  call void @__quantum__qis__exp__adj(%Array* %paulis__inline__2, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__2, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__2, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__3 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %26 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__3, i64 0)
  %27 = bitcast i8* %26 to i2*
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__3, i64 1)
  %29 = bitcast i8* %28 to i2*
  %30 = load i2, i2* @PauliX
  %31 = load i2, i2* @PauliY
  store i2 %30, i2* %27
  store i2 %31, i2* %29
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__3, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %32 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %33 = bitcast %Tuple* %32 to { %Array*, double, %Array* }*
  %34 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %33, i64 0, i32 0
  %35 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %33, i64 0, i32 1
  %36 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %33, i64 0, i32 2
  store %Array* %paulis__inline__3, %Array** %34
  store double 4.200000e-01, double* %35
  store %Array* %targets, %Array** %36
  call void @__quantum__qis__exp__ctl(%Array* %ctls, { %Array*, double, %Array* }* %33)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__3, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__3, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %32, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__4 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__4, i64 0)
  %38 = bitcast i8* %37 to i2*
  %39 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__4, i64 1)
  %40 = bitcast i8* %39 to i2*
  %41 = load i2, i2* @PauliX
  %42 = load i2, i2* @PauliY
  store i2 %41, i2* %38
  store i2 %42, i2* %40
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__4, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %43 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %44 = bitcast %Tuple* %43 to { %Array*, double, %Array* }*
  %45 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %44, i64 0, i32 0
  %46 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %44, i64 0, i32 1
  %47 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %44, i64 0, i32 2
  store %Array* %paulis__inline__4, %Array** %45
  store double 4.200000e-01, double* %46
  store %Array* %targets, %Array** %47
  call void @__quantum__qis__exp__ctladj(%Array* %ctls, { %Array*, double, %Array* }* %44)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__4, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__4, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %43, i64 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %targets)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %bases__inline__5 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 3)
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__5, i64 0)
  %49 = bitcast i8* %48 to i2*
  %50 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__5, i64 1)
  %51 = bitcast i8* %50 to i2*
  %52 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__5, i64 2)
  %53 = bitcast i8* %52 to i2*
  %54 = load i2, i2* @PauliX
  %55 = load i2, i2* @PauliY
  %56 = load i2, i2* @PauliZ
  store i2 %54, i2* %49
  store i2 %55, i2* %51
  store i2 %56, i2* %53
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__5, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %res = call %Result* @__quantum__qis__measure__body(%Array* %bases__inline__5, %Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__5, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases__inline__5, i64 -1)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %res, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %1, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %1, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %4, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %4, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %5, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %5, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %13, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %13, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i64)*]*, %Tuple*)

define void @Microsoft__Quantum__Intrinsic__Y__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__Y__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__Y__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__Y__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Y__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__Y__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__T__body(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %1 = getelementptr { %Qubit* }, { %Qubit* }* %0, i64 0, i32 0
  %2 = load %Qubit*, %Qubit** %1
  call void @Microsoft__Quantum__Intrinsic__T__adj(%Qubit* %2)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__T__ctl(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__T__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Intrinsic__T__ctladj(%Array* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i2, double, %Qubit* }*
  %1 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 1
  %3 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 2
  %4 = load i2, i2* %1
  %5 = load double, double* %2
  %6 = load %Qubit*, %Qubit** %3
  call void @Microsoft__Quantum__Intrinsic__R__body(i2 %4, double %5, %Qubit* %6)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i2, double, %Qubit* }*
  %1 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 1
  %3 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %0, i64 0, i32 2
  %4 = load i2, i2* %1
  %5 = load double, double* %2
  %6 = load %Qubit*, %Qubit** %3
  call void @Microsoft__Quantum__Intrinsic__R__adj(i2 %4, double %5, %Qubit* %6)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i2, double, %Qubit* }* }*
  %1 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { i2, double, %Qubit* }*, { i2, double, %Qubit* }** %2
  call void @Microsoft__Quantum__Intrinsic__R__ctl(%Array* %3, { i2, double, %Qubit* }* %4)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__R__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i2, double, %Qubit* }* }*
  %1 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { i2, double, %Qubit* }*, { i2, double, %Qubit* }** %2
  call void @Microsoft__Quantum__Intrinsic__R__ctladj(%Array* %3, { i2, double, %Qubit* }* %4)
  ret void
}

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 1
  %2 = load i2, i2* %1
  %3 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 2
  %4 = load double, double* %3
  %5 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %6 = getelementptr { %Qubit* }, { %Qubit* }* %5, i64 0, i32 0
  %7 = load %Qubit*, %Qubit** %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { i2, double, %Qubit* }*
  %10 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 0
  %11 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 1
  %12 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 2
  store i2 %2, i2* %10
  store double %4, double* %11
  store %Qubit* %7, %Qubit** %12
  %13 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 0
  %14 = load %Callable*, %Callable** %13
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 1
  %2 = load i2, i2* %1
  %3 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 2
  %4 = load double, double* %3
  %5 = bitcast %Tuple* %arg-tuple to { %Qubit* }*
  %6 = getelementptr { %Qubit* }, { %Qubit* }* %5, i64 0, i32 0
  %7 = load %Qubit*, %Qubit** %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %9 = bitcast %Tuple* %8 to { i2, double, %Qubit* }*
  %10 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 0
  %11 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 1
  %12 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %9, i64 0, i32 2
  store i2 %2, i2* %10
  store double %4, double* %11
  store %Qubit* %7, %Qubit** %12
  %13 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 0
  %14 = load %Callable*, %Callable** %13
  %15 = call %Callable* @__quantum__rt__callable_copy(%Callable* %14, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %15)
  call void @__quantum__rt__callable_invoke(%Callable* %15, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %6 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 1
  %7 = load i2, i2* %6
  %8 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 2
  %9 = load double, double* %8
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %11 = bitcast %Tuple* %10 to { i2, double, %Qubit* }*
  %12 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 0
  %13 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 1
  %14 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 2
  store i2 %7, i2* %12
  store double %9, double* %13
  store %Qubit* %4, %Qubit** %14
  %15 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %16 = bitcast %Tuple* %15 to { %Array*, { i2, double, %Qubit* }* }*
  %17 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i64 0, i32 0
  %18 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i64 0, i32 1
  store %Array* %3, %Array** %17
  store { i2, double, %Qubit* }* %11, { i2, double, %Qubit* }** %18
  %19 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 0
  %20 = load %Callable*, %Callable** %19
  %21 = call %Callable* @__quantum__rt__callable_copy(%Callable* %20, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %21, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %21)
  call void @__quantum__rt__callable_invoke(%Callable* %21, %Tuple* %15, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %10, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %21, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %21, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__1__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, %Qubit* }*
  %1 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load %Qubit*, %Qubit** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %6 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 1
  %7 = load i2, i2* %6
  %8 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 2
  %9 = load double, double* %8
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ i2, double, %Qubit* }* getelementptr ({ i2, double, %Qubit* }, { i2, double, %Qubit* }* null, i32 1) to i64))
  %11 = bitcast %Tuple* %10 to { i2, double, %Qubit* }*
  %12 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 0
  %13 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 1
  %14 = getelementptr { i2, double, %Qubit* }, { i2, double, %Qubit* }* %11, i64 0, i32 2
  store i2 %7, i2* %12
  store double %9, double* %13
  store %Qubit* %4, %Qubit** %14
  %15 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %16 = bitcast %Tuple* %15 to { %Array*, { i2, double, %Qubit* }* }*
  %17 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i64 0, i32 0
  %18 = getelementptr { %Array*, { i2, double, %Qubit* }* }, { %Array*, { i2, double, %Qubit* }* }* %16, i64 0, i32 1
  store %Array* %3, %Array** %17
  store { i2, double, %Qubit* }* %11, { i2, double, %Qubit* }** %18
  %19 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %5, i64 0, i32 0
  %20 = load %Callable*, %Callable** %19
  %21 = call %Callable* @__quantum__rt__callable_copy(%Callable* %20, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %21, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %21)
  call void @__quantum__rt__callable_make_controlled(%Callable* %21)
  call void @__quantum__rt__callable_invoke(%Callable* %21, %Tuple* %15, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %10, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %21, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %21, i64 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i2, double }*
  %1 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

attributes #0 = { "EntryPoint" }
