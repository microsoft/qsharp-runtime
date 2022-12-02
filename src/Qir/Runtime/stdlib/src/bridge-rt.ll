; Copyright (c) Microsoft Corporation.
; Licensed under the MIT License.

%Array = type opaque
%Range = type { i64, i64, i64 }
%String = type opaque

%"struct.QirArray" = type opaque
%"struct.QirRange" = type { i64, i64, i64 }
%"struct.QirString" = type opaque

declare %"struct.QirArray"* @quantum__rt__array_slice_1d(%"struct.QirArray"*, %"struct.QirRange"* dereferenceable(24), 
                                                      i1 %forceNewInstance)
declare %"struct.QirString"* @quantum__rt__range_to_string(%"struct.QirRange"* dereferenceable(24) %range)

; NOTE: These three functions can be converted to extern C once the spec and compiler are updated to pass %Range by
; pointer instead of by value (see https://github.com/microsoft/qsharp-language/issues/108). Once that
; happens, this file can be removed. 

define dllexport %Array* @__quantum__rt__array_slice_1d(%Array* %.ar, %Range %.range, i1 %forceNewInstance) {
  %ar = bitcast %Array* %.ar to %"struct.QirArray"*
  %.prange = alloca %Range
  store %Range %.range, %Range* %.prange
  %range = bitcast %Range* %.prange to %"struct.QirRange"*
  %slice = call %"struct.QirArray"* @quantum__rt__array_slice_1d(
      %"struct.QirArray"* %ar, %"struct.QirRange"* dereferenceable(24) %range, i1 %forceNewInstance)
  %.slice = bitcast  %"struct.QirArray"* %slice to %Array*
  ret %Array* %.slice
}

define dllexport %String* @__quantum__rt__range_to_string(%Range %.range) {
  %.prange = alloca %Range
  store %Range %.range, %Range* %.prange
  %range = bitcast %Range* %.prange to %"struct.QirRange"*
  %str = call %"struct.QirString"* @quantum__rt__range_to_string(%"struct.QirRange"* dereferenceable(24) %range)
  %.str = bitcast %"struct.QirString"* %str to %String*
  ret %String* %.str
} 