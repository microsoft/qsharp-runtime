
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Qubit = type opaque
%Array = type opaque
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

@Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS = alias i64 (), i64 ()* @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body

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

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qb) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qb)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

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

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

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

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
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

declare %Tuple* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

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

define i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %op) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 1)
  %res = alloca i64
  store i64 0, i64* %res
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
  %7 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %8 = load %Result*, %Result** @ResultZero
  %9 = call i1 @__quantum__rt__result_equal(%Result* %7, %Result* %8)
  %10 = xor i1 %9, true
  br i1 %10, label %then0__1, label %else__1

then0__1:                                         ; preds = %entry
  store i64 1, i64* %res
  br label %continue__1

else__1:                                          ; preds = %entry
  %11 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %12 = bitcast i8* %11 to %Qubit**
  %qb__inline__1 = load %Qubit*, %Qubit** %12
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__1)
  %13 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %14 = bitcast i8* %13 to %Qubit**
  %qb__inline__2 = load %Qubit*, %Qubit** %14
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__2)
  %15 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %15)
  %16 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %17 = bitcast %Tuple* %16 to { %Array*, %Qubit* }*
  %18 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %17, i64 0, i32 0
  %19 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %17, i64 0, i32 1
  store %Array* %ctls, %Array** %18
  store %Qubit* %target, %Qubit** %19
  call void @__quantum__rt__callable_invoke(%Callable* %15, %Tuple* %16, %Tuple* null)
  %20 = call %Callable* @__quantum__rt__callable_copy(%Callable* %op, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %20, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %20)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %20)
  %21 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %22 = bitcast %Tuple* %21 to { %Array*, %Qubit* }*
  %23 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i64 0, i32 0
  %24 = getelementptr { %Array*, %Qubit* }, { %Array*, %Qubit* }* %22, i64 0, i32 1
  store %Array* %ctls, %Array** %23
  store %Qubit* %target, %Qubit** %24
  call void @__quantum__rt__callable_invoke(%Callable* %20, %Tuple* %21, %Tuple* null)
  %25 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %26 = load %Result*, %Result** @ResultZero
  %27 = call i1 @__quantum__rt__result_equal(%Result* %25, %Result* %26)
  %28 = xor i1 %27, true
  br i1 %28, label %then0__2, label %continue__2

then0__2:                                         ; preds = %else__1
  store i64 2, i64* %res
  br label %continue__2

continue__2:                                      ; preds = %then0__2, %else__1
  %29 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %30 = bitcast i8* %29 to %Qubit**
  %qb__inline__3 = load %Qubit*, %Qubit** %30
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__3)
  %31 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %32 = bitcast i8* %31 to %Qubit**
  %qb__inline__4 = load %Qubit*, %Qubit** %32
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__4)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %16, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %20, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %20, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %21, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %25, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %continue__2, %then0__1
  call void @__quantum__rt__qubit_release(%Qubit* %target)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %7, i64 -1)
  %33 = load i64, i64* %res
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 -1)
  ret i64 %33
}

declare void @__quantum__rt__callable_memory_management(i32, %Callable*, i64)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i64)

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__qubit_release_array(%Array*)

define i64 @Microsoft__Quantum__Testing__QIR__Test_Simulator_QIS__body() #0 {
entry:
  %res = alloca i64
  store i64 0, i64* %res
  %0 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__X, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %1 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %0)
  store i64 %1, i64* %res
  %2 = icmp ne i64 %1, 0
  br i1 %2, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  ret i64 %1

continue__1:                                      ; preds = %entry
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Y, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %4 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %3)
  store i64 %4, i64* %res
  %5 = icmp ne i64 %4, 0
  br i1 %5, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  %6 = add i64 10, %4
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  ret i64 %6

continue__2:                                      ; preds = %continue__1
  %7 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__Z, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %8 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %7)
  store i64 %8, i64* %res
  %9 = icmp ne i64 %8, 0
  br i1 %9, label %then0__3, label %continue__3

then0__3:                                         ; preds = %continue__2
  %10 = add i64 20, %8
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  ret i64 %10

continue__3:                                      ; preds = %continue__2
  %11 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__H, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %12 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %11)
  store i64 %12, i64* %res
  %13 = icmp ne i64 %12, 0
  br i1 %13, label %then0__4, label %continue__4

then0__4:                                         ; preds = %continue__3
  %14 = add i64 30, %12
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  ret i64 %14

continue__4:                                      ; preds = %continue__3
  %15 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__S, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %16 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %15)
  store i64 %16, i64* %res
  %17 = icmp ne i64 %16, 0
  br i1 %17, label %then0__5, label %continue__5

then0__5:                                         ; preds = %continue__4
  %18 = add i64 40, %16
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  ret i64 %18

continue__5:                                      ; preds = %continue__4
  %19 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__T, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %20 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %19)
  store i64 %20, i64* %res
  %21 = icmp ne i64 %20, 0
  br i1 %21, label %then0__6, label %continue__6

then0__6:                                         ; preds = %continue__5
  %22 = add i64 50, %20
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %19, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i64 -1)
  ret i64 %22

continue__6:                                      ; preds = %continue__5
  %23 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i2, double }* getelementptr ({ %Callable*, i2, double }, { %Callable*, i2, double }* null, i32 1) to i64))
  %24 = bitcast %Tuple* %23 to { %Callable*, i2, double }*
  %25 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i64 0, i32 0
  %26 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i64 0, i32 1
  %27 = getelementptr { %Callable*, i2, double }, { %Callable*, i2, double }* %24, i64 0, i32 2
  %28 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Intrinsic__R, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %29 = load i2, i2* @PauliX
  store %Callable* %28, %Callable** %25
  store i2 %29, i2* %26
  store double 4.200000e-01, double* %27
  %30 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i64)*]* @MemoryManagement__1, %Tuple* %23)
  %31 = call i64 @Microsoft__Quantum__Testing__QIR__InvokeAllVariants__body(%Callable* %30)
  store i64 %31, i64* %res
  %32 = icmp ne i64 %31, 0
  br i1 %32, label %then0__7, label %continue__7

then0__7:                                         ; preds = %continue__6
  %33 = add i64 60, %31
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %19, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %30, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i64 -1)
  ret i64 %33

continue__7:                                      ; preds = %continue__6
  %targets = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %ctls = call %Array* @__quantum__rt__qubit_allocate_array(i64 2)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__1 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %34 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__1, i64 0)
  %35 = bitcast i8* %34 to i2*
  %36 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__1, i64 1)
  %37 = bitcast i8* %36 to i2*
  %38 = load i2, i2* @PauliX
  %39 = load i2, i2* @PauliY
  store i2 %38, i2* %35
  store i2 %39, i2* %37
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__1, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  call void @__quantum__qis__exp__body(%Array* %paulis__inline__1, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__1, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__1, i64 -1)
  %paulis__inline__2 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__2, i64 0)
  %41 = bitcast i8* %40 to i2*
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__2, i64 1)
  %43 = bitcast i8* %42 to i2*
  %44 = load i2, i2* @PauliX
  %45 = load i2, i2* @PauliY
  store i2 %44, i2* %41
  store i2 %45, i2* %43
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__2, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  call void @__quantum__qis__exp__adj(%Array* %paulis__inline__2, double 4.200000e-01, %Array* %targets)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__2, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__2, i64 -1)
  %46 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 0)
  %47 = bitcast i8* %46 to %Qubit**
  %48 = load %Qubit*, %Qubit** %47
  %49 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %48)
  %50 = load %Result*, %Result** @ResultZero
  %51 = call i1 @__quantum__rt__result_equal(%Result* %49, %Result* %50)
  %52 = xor i1 %51, true
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 1)
  %54 = bitcast i8* %53 to %Qubit**
  %55 = load %Qubit*, %Qubit** %54
  %56 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %55)
  %57 = load %Result*, %Result** @ResultZero
  %58 = call i1 @__quantum__rt__result_equal(%Result* %56, %Result* %57)
  %59 = xor i1 %58, true
  %60 = or i1 %52, %59
  br i1 %60, label %then0__8, label %else__1

then0__8:                                         ; preds = %continue__7
  store i64 1, i64* %res
  br label %continue__8

else__1:                                          ; preds = %continue__7
  %61 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %62 = bitcast i8* %61 to %Qubit**
  %qb__inline__3 = load %Qubit*, %Qubit** %62
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__3)
  %63 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %64 = bitcast i8* %63 to %Qubit**
  %qb__inline__4 = load %Qubit*, %Qubit** %64
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__4)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__5 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %65 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__5, i64 0)
  %66 = bitcast i8* %65 to i2*
  %67 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__5, i64 1)
  %68 = bitcast i8* %67 to i2*
  %69 = load i2, i2* @PauliX
  %70 = load i2, i2* @PauliY
  store i2 %69, i2* %66
  store i2 %70, i2* %68
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__5, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %71 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %72 = bitcast %Tuple* %71 to { %Array*, double, %Array* }*
  %73 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %72, i64 0, i32 0
  %74 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %72, i64 0, i32 1
  %75 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %72, i64 0, i32 2
  store %Array* %paulis__inline__5, %Array** %73
  store double 4.200000e-01, double* %74
  store %Array* %targets, %Array** %75
  call void @__quantum__qis__exp__ctl(%Array* %ctls, { %Array*, double, %Array* }* %72)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__5, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__5, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %71, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 1)
  %paulis__inline__6 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %76 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__6, i64 0)
  %77 = bitcast i8* %76 to i2*
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %paulis__inline__6, i64 1)
  %79 = bitcast i8* %78 to i2*
  %80 = load i2, i2* @PauliX
  %81 = load i2, i2* @PauliY
  store i2 %80, i2* %77
  store i2 %81, i2* %79
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__6, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 1)
  %82 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Array*, double, %Array* }* getelementptr ({ %Array*, double, %Array* }, { %Array*, double, %Array* }* null, i32 1) to i64))
  %83 = bitcast %Tuple* %82 to { %Array*, double, %Array* }*
  %84 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %83, i64 0, i32 0
  %85 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %83, i64 0, i32 1
  %86 = getelementptr { %Array*, double, %Array* }, { %Array*, double, %Array* }* %83, i64 0, i32 2
  store %Array* %paulis__inline__6, %Array** %84
  store double 4.200000e-01, double* %85
  store %Array* %targets, %Array** %86
  call void @__quantum__qis__exp__ctladj(%Array* %ctls, { %Array*, double, %Array* }* %83)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %paulis__inline__6, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %paulis__inline__6, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %82, i64 -1)
  %87 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 0)
  %88 = bitcast i8* %87 to %Qubit**
  %qb__inline__7 = load %Qubit*, %Qubit** %88
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__7)
  %89 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ctls, i64 1)
  %90 = bitcast i8* %89 to %Qubit**
  %qb__inline__8 = load %Qubit*, %Qubit** %90
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__8)
  %91 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 0)
  %92 = bitcast i8* %91 to %Qubit**
  %93 = load %Qubit*, %Qubit** %92
  %94 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %93)
  %95 = load %Result*, %Result** @ResultZero
  %96 = call i1 @__quantum__rt__result_equal(%Result* %94, %Result* %95)
  %97 = xor i1 %96, true
  %98 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %targets, i64 1)
  %99 = bitcast i8* %98 to %Qubit**
  %100 = load %Qubit*, %Qubit** %99
  %101 = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %100)
  %102 = load %Result*, %Result** @ResultZero
  %103 = call i1 @__quantum__rt__result_equal(%Result* %101, %Result* %102)
  %104 = xor i1 %103, true
  %105 = or i1 %97, %104
  br i1 %105, label %then0__9, label %continue__9

then0__9:                                         ; preds = %else__1
  store i64 72, i64* %res
  br label %continue__9

continue__9:                                      ; preds = %then0__9, %else__1
  call void @__quantum__rt__result_update_reference_count(%Result* %94, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %101, i64 -1)
  br label %continue__8

continue__8:                                      ; preds = %continue__9, %then0__8
  call void @__quantum__rt__qubit_release_array(%Array* %targets)
  call void @__quantum__rt__qubit_release_array(%Array* %ctls)
  call void @__quantum__rt__array_update_alias_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %targets, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %ctls, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %49, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %56, i64 -1)
  %106 = load i64, i64* %res
  %107 = icmp ne i64 %106, 0
  br i1 %107, label %then0__10, label %continue__10

then0__10:                                        ; preds = %continue__8
  %108 = add i64 70, %106
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %19, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %30, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i64 -1)
  ret i64 %108

continue__10:                                     ; preds = %continue__8
  %qs = call %Array* @__quantum__rt__qubit_allocate_array(i64 3)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %109 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %110 = bitcast i8* %109 to %Qubit**
  %qb__inline__9 = load %Qubit*, %Qubit** %110
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__9)
  %111 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %112 = bitcast i8* %111 to %Qubit**
  %qb__inline__10 = load %Qubit*, %Qubit** %112
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__10)
  %bases__inline__11 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 3)
  %113 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__11, i64 0)
  %114 = bitcast i8* %113 to i2*
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__11, i64 1)
  %116 = bitcast i8* %115 to i2*
  %117 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases__inline__11, i64 2)
  %118 = bitcast i8* %117 to i2*
  %119 = load i2, i2* @PauliX
  %120 = load i2, i2* @PauliZ
  %121 = load i2, i2* @PauliX
  store i2 %119, i2* %114
  store i2 %120, i2* %116
  store i2 %121, i2* %118
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__11, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 1)
  %122 = call %Result* @__quantum__qis__measure__body(%Array* %bases__inline__11, %Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases__inline__11, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases__inline__11, i64 -1)
  %123 = load %Result*, %Result** @ResultZero
  %124 = call i1 @__quantum__rt__result_equal(%Result* %122, %Result* %123)
  %125 = xor i1 %124, true
  br i1 %125, label %then0__11, label %continue__11

then0__11:                                        ; preds = %continue__10
  store i64 80, i64* %res
  br label %continue__11

continue__11:                                     ; preds = %then0__11, %continue__10
  %126 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 0)
  %127 = bitcast i8* %126 to %Qubit**
  %qb__inline__12 = load %Qubit*, %Qubit** %127
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__12)
  %128 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qs, i64 2)
  %129 = bitcast i8* %128 to %Qubit**
  %qb__inline__13 = load %Qubit*, %Qubit** %129
  call void @__quantum__qis__h__body(%Qubit* %qb__inline__13)
  call void @__quantum__rt__qubit_release_array(%Array* %qs)
  call void @__quantum__rt__array_update_alias_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qs, i64 -1)
  call void @__quantum__rt__result_update_reference_count(%Result* %122, i64 -1)
  %130 = load i64, i64* %res
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %3, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %3, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %7, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %7, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %11, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %11, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %15, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %15, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %19, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %19, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %30, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %30, i64 -1)
  ret i64 %130
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

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

attributes #0 = { "EntryPoint" }
