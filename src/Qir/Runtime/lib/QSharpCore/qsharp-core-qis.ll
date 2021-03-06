; Copyright (c) Microsoft Corporation.
; Licensed under the MIT License.

;=======================================================================================================================
; QIR types
;
%Array = type opaque
%Callable = type opaque
%Qubit = type opaque
%Range = type { i64, i64, i64 }
%Result = type opaque
%String = type opaque
%Pauli = type i2

;=======================================================================================================================
; Native types
; NB: there is no overloading at IR level, so a call/invoke will be made even
; if the definition of the function mismatches the declaration of the arguments.
; It means we could declare here the bridge's C-functions using QIR types
; and avoid bitcasts. However, it seems prudent to be more explicit about
; what's going on and declare the true signatures, as generated by Clang.
;
%class.QUBIT = type opaque
%class.RESULT = type opaque
%struct.QirArray = type opaque
%struct.QirCallable = type opaque
%struct.QirRange = type { i64, i64, i64 }
%struct.QirString = type opaque
%PauliId = type i32

; The __quantum__qis__* definitions should be automatically generated by QIR, depending on the specific target.
; However, for simulator targets we provide an optional simple bridge that covers commonly used intrinsics. 

;===============================================================================
; declarations of the native methods this bridge delegates to
;
declare void @quantum__qis__exp__body(%struct.QirArray*, double, %struct.QirArray*)
declare void @quantum__qis__exp__adj(%struct.QirArray*, double, %struct.QirArray*)
declare void @quantum__qis__exp__ctl(%struct.QirArray*, %struct.QirArray*, double, %struct.QirArray*)
declare void @quantum__qis__exp__ctladj(%struct.QirArray*, %struct.QirArray*, double, %struct.QirArray*)
declare void @quantum__qis__h__body(%class.QUBIT*)
declare void @quantum__qis__h__ctl(%struct.QirArray*, %class.QUBIT*)
declare %class.RESULT* @quantum__qis__measure__body(%struct.QirArray*, %struct.QirArray*)
declare void @quantum__qis__r__body(i32, double, %class.QUBIT*)
declare void @quantum__qis__r__adj(i32, double, %class.QUBIT*)
declare void @quantum__qis__r__ctl(%struct.QirArray*, i32, double, %class.QUBIT*)
declare void @quantum__qis__r__ctladj(%struct.QirArray*, i32, double, %class.QUBIT*)
declare void @quantum__qis__s__body(%class.QUBIT*)
declare void @quantum__qis__s__adj(%class.QUBIT*)
declare void @quantum__qis__s__ctl(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__s__ctladj(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__t__body(%class.QUBIT*)
declare void @quantum__qis__t__adj(%class.QUBIT*)
declare void @quantum__qis__t__ctl(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__t__ctladj(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__x__body(%class.QUBIT*)
declare void @quantum__qis__x__ctl(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__y__body(%class.QUBIT*)
declare void @quantum__qis__y__ctl(%struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__z__body(%class.QUBIT*)
declare void @quantum__qis__z__ctl(%struct.QirArray*, %class.QUBIT*)

;===============================================================================
; quantum.qis dump functions declarations
;
; Must be `const void* %location`, but `void *` is invalid (LLVM), and `const` is not supported.
declare void @quantum__qis__dumpmachine__body(i8* %location)  
declare void @quantum__qis__dumpregister__body(i8* %location, %struct.QirArray* %qubits)


;===============================================================================
; quantum.qis namespace implementations
;

define dllexport void @__quantum__qis__exp__body(%Array* %.paulis, double %angle, %Array* %.qubits) {
  %paulis = bitcast %Array* %.paulis to %struct.QirArray*
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*
  call void @quantum__qis__exp__body(%struct.QirArray* %paulis, double %angle, %struct.QirArray* %qubits)
  ret void
}

define dllexport void @__quantum__qis__exp__adj(%Array* %.paulis, double %angle, %Array* %.qubits) {
  %paulis = bitcast %Array* %.paulis to %struct.QirArray*
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*
  call void @quantum__qis__exp__adj(%struct.QirArray* %paulis, double %angle, %struct.QirArray* %qubits)
  ret void
}

define dllexport void @__quantum__qis__exp__ctl(%Array* %.ctls, {%Array*, double, %Array*}* %.args) {
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*

  %.ppaulis = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 0
  %.paulis = load %Array*, %Array** %.ppaulis
  %paulis = bitcast %Array* %.paulis to %struct.QirArray*

  %.pangle = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 1
  %angle = load double, double* %.pangle

  %.pqubits = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 2
  %.qubits = load %Array*, %Array** %.pqubits
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*

  call void @quantum__qis__exp__ctl(
    %struct.QirArray* %ctls, %struct.QirArray* %paulis, double %angle, %struct.QirArray* %qubits)
  ret void
}

define dllexport void @__quantum__qis__exp__ctladj(%Array* %.ctls, { %Array*, double, %Array* }* %.args) {
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*

  %.ppaulis = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 0
  %.paulis = load %Array*, %Array** %.ppaulis
  %paulis = bitcast %Array* %.paulis to %struct.QirArray*

  %.pangle = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 1
  %angle = load double, double* %.pangle

  %.pqubits = getelementptr inbounds {%Array*, double, %Array*}, {%Array*, double, %Array*}* %.args, i32 0, i32 2
  %.qubits = load %Array*, %Array** %.pqubits
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*

  call void @quantum__qis__exp__ctladj(
    %struct.QirArray* %ctls, %struct.QirArray* %paulis, double %angle, %struct.QirArray* %qubits)
  ret void
}

define dllexport void @__quantum__qis__h__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__h__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__h__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__h__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport %Result* @__quantum__qis__measure__body(%Array* %.paulis, %Array* %.qubits) {
  %paulis = bitcast %Array* %.paulis to %struct.QirArray*
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*
  %r = call %class.RESULT* @quantum__qis__measure__body(%struct.QirArray* %paulis, %struct.QirArray* %qubits)
  %.r = bitcast %class.RESULT* %r to %Result*
  ret %Result* %.r
}

define dllexport void @__quantum__qis__r__body(%Pauli %.pauli, double %theta, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %pauli = zext %Pauli %.pauli to %PauliId
  call void @quantum__qis__r__body(%PauliId %pauli, double %theta, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__r__adj(%Pauli %.pauli, double %theta, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %pauli = zext %Pauli %.pauli to %PauliId
  call void @quantum__qis__r__adj(%PauliId %pauli, double %theta, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__r__ctl(%Array* %.ctls, {%Pauli, double, %Qubit*}* %.args) {
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*

  %.ppauli = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 0
  %.pauli = load %Pauli, %Pauli* %.ppauli
  %pauli = zext %Pauli %.pauli to %PauliId

  %.ptheta = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 1
  %theta = load double, double* %.ptheta

  %.pq = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 2
  %.q = load %Qubit*, %Qubit** %.pq
  %q = bitcast %Qubit* %.q to %class.QUBIT*

  call void @quantum__qis__r__ctl(%struct.QirArray* %ctls, %PauliId %pauli, double %theta, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__r__ctladj(%Array* %.ctls, {%Pauli, double, %Qubit*}* %.args) {
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*

  %.ppauli = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 0
  %.pauli = load %Pauli, %Pauli* %.ppauli
  %pauli = zext %Pauli %.pauli to %PauliId

  %.ptheta = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 1
  %theta = load double, double* %.ptheta

  %.pq = getelementptr inbounds {%Pauli, double, %Qubit*}, {%Pauli, double, %Qubit*}* %.args, i32 0, i32 2
  %.q = load %Qubit*, %Qubit** %.pq
  %q = bitcast %Qubit* %.q to %class.QUBIT*

  call void @quantum__qis__r__ctladj(%struct.QirArray* %ctls, %PauliId %pauli, double %theta, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__s__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__s__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__s__adj(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__s__adj(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__s__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__s__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__s__ctladj(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__s__ctladj(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__t__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__t__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__t__adj(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__t__adj(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__t__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__t__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__t__ctladj(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__t__ctladj(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__x__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__x__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__x__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__x__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__y__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__y__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__y__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__y__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__z__body(%Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__z__body(%class.QUBIT* %q)
  ret void
}

define dllexport void @__quantum__qis__z__ctl(%Array* %.ctls, %Qubit* %.q) {
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__z__ctl(%struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}


;===============================================================================
; quantum.qis dump functions implementation
;
define dllexport void @__quantum__qis__dumpmachine__body(i8* %location) {
  call void @quantum__qis__dumpmachine__body(i8* %location)
  ret void
}

define dllexport void @__quantum__qis__dumpregister__body(i8* %location, %Array* %.qubits) {
  %qubits = bitcast %Array* %.qubits to %struct.QirArray*
  call void @quantum__qis__dumpregister__body(i8* %location, %struct.QirArray* %qubits)
  ret void
}
