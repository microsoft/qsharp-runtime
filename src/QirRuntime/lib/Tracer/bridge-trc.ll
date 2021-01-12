; Copyright (c) Microsoft Corporation. All rights reserved.
; Licensed under the MIT License.

;=======================================================================================================================
; QIR types
;
%Array = type opaque
%Qubit = type opaque
%Result = type opaque


;=======================================================================================================================
; Native types
;
%class.QUBIT = type opaque
%class.RESULT = type opaque
%struct.QirArray = type opaque


;===============================================================================
; declarations of the native methods this bridge delegates to
;

declare void @quantum__trc__single_qubit_op(i32 %id, i32 %duration, %class.QUBIT*)
declare void @quantum__trc__single_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray*, %class.QUBIT*)
declare void @quantum__trc__multi_qubit_op(i32 %id, i32 %duration, %struct.QirArray*)
declare void @quantum__trc__multi_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray*, %struct.QirArray*)
declare void @quantum__trc__inject_global_barrier(i8* %name, i32 %duration)

;===============================================================================
; quantum__trc namespace implementations
;
define void @__quantum__trc__single_qubit_op(i32 %id, i32 %duration, %Qubit* %.q)
{
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__trc__single_qubit_op(i32 %id, i32 %duration, %class.QUBIT* %q)
  ret void
}

define void @__quantum__trc__single_qubit_op_ctl(i32 %id, i32 %duration, %Array* %.ctls, %Qubit* %.q)
{
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__trc__single_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define void @__quantum__trc__multi_qubit_op(i32 %id, i32 %duration, %Array* %.qs)
{
  %qs = bitcast %Array* %.qs to %struct.QirArray*
  call void @quantum__trc__multi_qubit_op(i32 %id, i32 %duration, %struct.QirArray* %qs)
  ret void
}

define void @__quantum__trc__multi_qubit_op_ctl(i32 %id, i32 %duration, %Array* %.ctls, %Array* %.qs)
{
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  %qs = bitcast %Array* %.qs to %struct.QirArray*
  call void @quantum__trc__multi_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray* %ctls, %struct.QirArray* %qs)
  ret void
}

define void @__quantum__trc__inject_global_barrier(i8* %name, i32 %duration)
{
  call void @quantum__trc__inject_global_barrier(i8* %name, i32 %duration)
  ret void
}