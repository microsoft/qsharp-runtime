%Range = type { i64, i64, i64 }
%Array = type opaque
%String = type opaque

@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
declare %Array* @__quantum__rt__array_create(i32, i32, ...)
declare i64 @__quantum__rt__array_get_length(%Array*, i32)
declare i8* @__quantum__rt__array_get_element_ptr(%Array*, ...)
declare i32 @__quantum__rt__array_get_dim(%Array*)
declare %Array* @__quantum__rt__array_project(%Array*, i32, i64)
declare void @DebugLog(i64)

; manually authored test for multi-dimensional arrays (Q# doesn't support multi-dimentional arrays yet)
define i64 @TestMultidimArrays(i8 %val, i64 %dim0, i64 %dim1, i64 %dim2)
{
  %.ar = call %Array* (i32, i32, ...) @__quantum__rt__array_create(i32 1, i32 3, i64 %dim0, i64 %dim1, i64 %dim2)
  %elem_ptr = call i8* (%Array*, ...) @__quantum__rt__array_get_element_ptr(%Array* %.ar, i64 1, i64 1, i64 1)
  store i8 %val, i8* %elem_ptr
  %.project = call %Array* @__quantum__rt__array_project(%Array* %.ar, i32 1, i64 1)
  %project_dims = call i32 @__quantum__rt__array_get_dim(%Array* %.project)
  %project_dim0 = call i64 @__quantum__rt__array_get_length(%Array* %.project, i32 0)
  %project_dim1 = call i64 @__quantum__rt__array_get_length(%Array* %.project, i32 1)
  %project_elem_ptr = call i8* (%Array*, ...) @__quantum__rt__array_get_element_ptr(%Array* %.project, i64 1, i64 1)
  %project_val = load i8, i8* %project_elem_ptr
  %val64 = sext i8 %project_val to i64

  %t1 = add i64 %project_dim0, %project_dim1
  %t2 = sext i32 %project_dims to i64
  %av = udiv i64 %t1, %t2
  %t3 = add i64 %av, %val64
  ret i64 %t3
}

; manually authored test for dumping range into a string and raising a failure with it
declare %String* @__quantum__rt__range_to_string(%Range)
declare void @__quantum__rt__fail(%String*)
define void @TestFailWithRangeString(i64 %start, i64 %step, i64 %end){
  %re = load %Range, %Range* @EmptyRange
  %r0 = insertvalue %Range %re, i64 %start, 0
  %r1 = insertvalue %Range %r0, i64 %step, 1
  %r2 = insertvalue %Range %r1, i64 %end, 2
  %str = call %String* @__quantum__rt__range_to_string(%Range %r2)
  call void @__quantum__rt__fail(%String* %str)
  ret void
}
