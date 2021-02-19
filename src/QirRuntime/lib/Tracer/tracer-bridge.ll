; Copyright (c) Microsoft Corporation.
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

declare void @quantum__qis__single_qubit_op(i32 %id, i32 %duration, %class.QUBIT*)
declare void @quantum__qis__single_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray*, %class.QUBIT*)
declare void @quantum__qis__multi_qubit_op(i32 %id, i32 %duration, %struct.QirArray*)
declare void @quantum__qis__multi_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray*, %struct.QirArray*)
declare void @quantum__qis__inject_barrier(i32 %id, i32 %duration)
declare %class.RESULT* @quantum__qis__single_qubit_measure(i32 %id, i32 %duration, %class.QUBIT*)
declare %class.RESULT* @quantum__qis__joint_measure(i32 %id, i32 %duration, %struct.QirArray*)

;===============================================================================
; quantum__trc namespace implementations
;
define void @__quantum__qis__single_qubit_op(i32 %id, i32 %duration, %Qubit* %.q)
{
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  call void @quantum__qis__single_qubit_op(i32 %id, i32 %duration, %class.QUBIT* %q)
  ret void
}

define void @__quantum__qis__single_qubit_op_ctl(i32 %id, i32 %duration, %Array* %.ctls, %Qubit* %.q)
{
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  call void @quantum__qis__single_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray* %ctls, %class.QUBIT* %q)
  ret void
}

define void @__quantum__qis__multi_qubit_op(i32 %id, i32 %duration, %Array* %.qs)
{
  %qs = bitcast %Array* %.qs to %struct.QirArray*
  call void @quantum__qis__multi_qubit_op(i32 %id, i32 %duration, %struct.QirArray* %qs)
  ret void
}

define void @__quantum__qis__multi_qubit_op_ctl(i32 %id, i32 %duration, %Array* %.ctls, %Array* %.qs)
{
  %ctls = bitcast %Array* %.ctls to %struct.QirArray*
  %qs = bitcast %Array* %.qs to %struct.QirArray*
  call void @quantum__qis__multi_qubit_op_ctl(i32 %id, i32 %duration, %struct.QirArray* %ctls, %struct.QirArray* %qs)
  ret void
}

define void @__quantum__qis__inject_barrier(i32 %id, i32 %duration)
{
  call void @quantum__qis__inject_barrier(i32 %id, i32 %duration)
  ret void
}

define %Result* @__quantum__qis__single_qubit_measure(i32 %id, i32 %duration, %Qubit* %.q)
{
  %q = bitcast %Qubit* %.q to %class.QUBIT*
  %r = call %class.RESULT* @quantum__qis__single_qubit_measure(i32 %id, i32 %duration, %class.QUBIT* %q)
  %.r = bitcast %class.RESULT* %r to %Result*
  ret %Result* %.r
}

define %Result* @__quantum__qis__joint_measure(i32 %id, i32 %duration, %Array* %.qs)
{
  %qs = bitcast %Array* %.qs to %struct.QirArray*
  %r = call %class.RESULT* @quantum__qis__joint_measure(i32 %id, i32 %duration, %struct.QirArray* %qs)
  %.r = bitcast %class.RESULT* %r to %Result*
  ret %Result* %.r
}