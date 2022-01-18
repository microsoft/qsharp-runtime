%Range = type { i64, i64, i64 }
%Array = type opaque
%String = type opaque

@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
declare %Array* @__quantum__rt__array_create(i32, i32, ...)
declare i64 @__quantum__rt__array_get_size(%Array*, i32)
declare i8* @__quantum__rt__array_get_element_ptr(%Array*, ...)
declare i32 @__quantum__rt__array_get_dim(%Array*)
declare %Array* @__quantum__rt__array_project(%Array*, i32, i64)
declare void @__quantum__rt__array_update_reference_count(%Array*, i32)

; manually authored test for dumping range into a string and raising a failure with it
declare %String* @__quantum__rt__range_to_string(%Range)
declare i8* @__quantum__rt__string_get_data(%String*)
declare void @__quantum__rt__fail_cstr(i8*)
define void @TestFailWithRangeString(i64 %start, i64 %step, i64 %end){
  %re = load %Range, %Range* @EmptyRange
  %r0 = insertvalue %Range %re, i64 %start, 0
  %r1 = insertvalue %Range %r0, i64 %step, 1
  %r2 = insertvalue %Range %r1, i64 %end, 2
  %str = call %String* @__quantum__rt__range_to_string(%Range %r2)
  %cstr = call i8* @__quantum__rt__string_get_data(%String* %str)
  call void @__quantum__rt__fail_cstr(i8* %cstr)   ; Leaks the `%cstr`. TODO: Extract into a separate file compiled with leak check off.
  ret void
}
