
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__QIR__Subtract = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@PartialApplication__21 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__21__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]

@Microsoft_Quantum_Testing_QIR_TestPartials = alias i64 (i64, i64), i64 (i64, i64)* @Microsoft__Quantum__Testing__QIR__TestPartials__body

define i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %from, i64 %what) {
entry:
  %0 = sub i64 %from, %what
  ret i64 %0
}

define i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 %x, i64 %y) #0 {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint ({ %Callable*, i64 }* getelementptr ({ %Callable*, i64 }, { %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %Tuple* %0 to { %Callable*, i64 }*
  %2 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 0
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Testing__QIR__Subtract, %Tuple* null)
  store %Callable* %3, %Callable** %2
  call void @__quantum__rt__callable_reference(%Callable* %3)
  %4 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %1, i64 0, i32 1
  store i64 %x, i64* %4
  %subtractor = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__21, %Tuple* %0)
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  %6 = bitcast %Tuple* %5 to { i64 }*
  %7 = getelementptr { i64 }, { i64 }* %6, i64 0, i32 0
  store i64 %y, i64* %7
  %8 = bitcast { i64 }* %6 to %Tuple*
  %9 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64))
  %10 = bitcast %Tuple* %9 to { i64 }*
  call void @__quantum__rt__callable_invoke(%Callable* %subtractor, %Tuple* %8, %Tuple* %9)
  %11 = getelementptr { i64 }, { i64 }* %10, i64 0, i32 0
  %12 = load i64, i64* %11
  call void @__quantum__rt__callable_unreference(%Callable* %3)
  call void @__quantum__rt__callable_unreference(%Callable* %subtractor)
  %13 = bitcast { i64 }* %6 to %Tuple*
  call void @__quantum__rt__tuple_unreference(%Tuple* %13)
  ret i64 %12
}

declare %Tuple* @__quantum__rt__tuple_create(i64)

define void @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { i64, i64 }*
  %1 = getelementptr { i64, i64 }, { i64, i64 }* %0, i64 0, i32 0
  %2 = getelementptr { i64, i64 }, { i64, i64 }* %0, i64 0, i32 1
  %3 = load i64, i64* %1
  %4 = load i64, i64* %2
  %5 = call i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %3, i64 %4)
  %6 = bitcast %Tuple* %result-tuple to { i64 }*
  %7 = getelementptr { i64 }, { i64 }* %6, i64 0, i32 0
  store i64 %5, i64* %7
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, %Tuple*)

declare void @__quantum__rt__callable_reference(%Callable*)

define void @Lifted__PartialApplication__21__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, i64 }*
  %1 = bitcast %Tuple* %arg-tuple to { i64 }*
  %2 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %3 = bitcast %Tuple* %2 to { i64, i64 }*
  %4 = getelementptr { i64, i64 }, { i64, i64 }* %3, i64 0, i32 0
  %5 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 1
  %6 = load i64, i64* %5
  store i64 %6, i64* %4
  %7 = getelementptr { i64, i64 }, { i64, i64 }* %3, i64 0, i32 1
  %8 = getelementptr { i64 }, { i64 }* %1, i64 0, i32 0
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %Callable*, i64 }, { %Callable*, i64 }* %0, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  %12 = bitcast { i64, i64 }* %3 to %Tuple*
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %12, %Tuple* %result-tuple)
  %13 = bitcast { i64, i64 }* %3 to %Tuple*
  call void @__quantum__rt__tuple_unreference(%Tuple* %13)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

declare void @__quantum__rt__tuple_unreference(%Tuple*)

declare void @__quantum__rt__callable_unreference(%Callable*)

attributes #0 = { "EntryPoint" }
