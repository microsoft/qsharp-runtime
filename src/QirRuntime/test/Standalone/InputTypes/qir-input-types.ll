
%Result = type opaque
%Range = type { i64, i64, i64 }
%Array = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

define void @Microsoft__Quantum__Testing__QIR__InputTypes__body(i64 %anInt, double %aDouble, %Array* %anArray) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %anArray, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %anArray, i64 -1)
  ret void
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

define void @Microsoft__Quantum__Testing__QIR__InputTypes(i64 %anInt, double %aDouble, i64 %anArray__count, i64* %anArray) #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %anArray__count)
  %1 = icmp sgt i64 %anArray__count, 0
  br i1 %1, label %copy, label %next

copy:                                             ; preds = %entry
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %3 = mul i64 %anArray__count, 8
  call void @llvm.memcpy.p0i8.p0i64.i64(i8* %2, i64* %anArray, i64 %3, i1 false)
  br label %next

next:                                             ; preds = %copy, %entry
  call void @Microsoft__Quantum__Testing__QIR__InputTypes__body(i64 %anInt, double %aDouble, %Array* %0)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

; Function Attrs: argmemonly nounwind willreturn
declare void @llvm.memcpy.p0i8.p0i64.i64(i8* noalias nocapture writeonly, i64* noalias nocapture readonly, i64, i1 immarg) #1

attributes #0 = { "EntryPoint" }
attributes #1 = { argmemonly nounwind willreturn }
