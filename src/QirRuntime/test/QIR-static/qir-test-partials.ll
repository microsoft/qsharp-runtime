
%Result = type opaque
%Range = type { i64, i64, i64 }
%TupleHeader = type { i32, i32 }
%String = type opaque
%Array = type opaque
%Callable = type opaque

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }
@Microsoft__Quantum__Testing__QIR__Subtract = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]
@PartialApplication__2 = constant [4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*] [void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* @Lifted__PartialApplication__2__body__wrapper, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null, void (%TupleHeader*, %TupleHeader*, %TupleHeader*)* null]

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

define i64 @Microsoft__Quantum__Testing__QIR__TestPartials__body(i64 %x, i64 %y) #0 {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Callable*, i64 }* getelementptr ({ %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Callable*, i64 }*
  %2 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 1
  %3 = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @Microsoft__Quantum__Testing__QIR__Subtract, %TupleHeader* null)
  store %Callable* %3, %Callable** %2
  %4 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %1, i64 0, i32 2
  store i64 %x, i64* %4
  %subtractor = call %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]* @PartialApplication__2, %TupleHeader* %0)
  %5 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, i64 }* getelementptr ({ %TupleHeader, i64 }, { %TupleHeader, i64 }* null, i32 1) to i64))
  %6 = bitcast %TupleHeader* %5 to { %TupleHeader, i64 }*
  %7 = getelementptr { %TupleHeader, i64 }, { %TupleHeader, i64 }* %6, i64 0, i32 1
  store i64 %y, i64* %7
  %8 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, i64 }* getelementptr ({ %TupleHeader, i64 }, { %TupleHeader, i64 }* null, i32 1) to i64))
  %9 = bitcast %TupleHeader* %8 to { %TupleHeader, i64 }*
  call void @__quantum__rt__callable_invoke(%Callable* %subtractor, %TupleHeader* %5, %TupleHeader* %8)
  %10 = getelementptr { %TupleHeader, i64 }, { %TupleHeader, i64 }* %9, i64 0, i32 1
  %11 = load i64, i64* %10
  call void @__quantum__rt__callable_unreference(%Callable* %subtractor)
  ret i64 %11
}

define void @Microsoft__Quantum__Testing__QIR__Subtract__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, i64, i64 }*
  %1 = getelementptr { %TupleHeader, i64, i64 }, { %TupleHeader, i64, i64 }* %0, i64 0, i32 1
  %2 = load i64, i64* %1
  %3 = getelementptr { %TupleHeader, i64, i64 }, { %TupleHeader, i64, i64 }* %0, i64 0, i32 2
  %4 = load i64, i64* %3
  %5 = call i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %2, i64 %4)
  %6 = bitcast %TupleHeader* %result-tuple to { %TupleHeader, i64 }*
  %7 = getelementptr { %TupleHeader, i64 }, { %TupleHeader, i64 }* %6, i64 0, i32 1
  store i64 %5, i64* %7
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%TupleHeader*, %TupleHeader*, %TupleHeader*)*]*, %TupleHeader*)

define void @Lifted__PartialApplication__2__body__wrapper(%TupleHeader* %capture-tuple, %TupleHeader* %arg-tuple, %TupleHeader* %result-tuple) {
entry:
  %0 = bitcast %TupleHeader* %capture-tuple to { %TupleHeader, %Callable*, i64 }*
  %1 = bitcast %TupleHeader* %arg-tuple to { %TupleHeader, i64 }*
  %2 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, i64, i64 }* getelementptr ({ %TupleHeader, i64, i64 }, { %TupleHeader, i64, i64 }* null, i32 1) to i64))
  %3 = bitcast %TupleHeader* %2 to { %TupleHeader, i64, i64 }*
  %4 = getelementptr { %TupleHeader, i64, i64 }, { %TupleHeader, i64, i64 }* %3, i64 0, i32 1
  %5 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 2
  %6 = load i64, i64* %5
  store i64 %6, i64* %4
  %7 = getelementptr { %TupleHeader, i64, i64 }, { %TupleHeader, i64, i64 }* %3, i64 0, i32 2
  %8 = getelementptr { %TupleHeader, i64 }, { %TupleHeader, i64 }* %1, i64 0, i32 1
  %9 = load i64, i64* %8
  store i64 %9, i64* %7
  %10 = getelementptr { %TupleHeader, %Callable*, i64 }, { %TupleHeader, %Callable*, i64 }* %0, i64 0, i32 1
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %TupleHeader* %2, %TupleHeader* %result-tuple)
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %2)
  ret void
}

declare void @__quantum__rt__callable_invoke(%Callable*, %TupleHeader*, %TupleHeader*)

declare void @__quantum__rt__tuple_unreference(%TupleHeader*)

declare void @__quantum__rt__callable_unreference(%Callable*)

define i64 @Microsoft__Quantum__Testing__QIR__Subtract__body(i64 %from, i64 %what) {
entry:
  %0 = sub i64 %from, %what
  ret i64 %0
}

attributes #0 = { "EntryPoint" }
