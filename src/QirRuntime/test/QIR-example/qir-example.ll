
%Result = type opaque
%Range = type { i64, i64, i64 }
%Tuple = type opaque
%String = type opaque
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
@0 = internal constant [26 x i8] c"Modulus must be positive.\00"
@Microsoft__Quantum__Random__DrawRandomSingleQubitClifford = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Random__DrawRandomSingleQubitClifford__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@Microsoft__Quantum__Synthesis__Times1C = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Synthesis__Times1C__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@PartialApplication__1 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__1__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null, void (%Tuple*, %Tuple*, %Tuple*)* null]
@MemoryManagement__1 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__1__RefCount, void (%Tuple*, i64)* @MemoryManagement__1__AliasCount]
@Microsoft__Quantum__Synthesis__Apply1C = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Synthesis__Apply1C__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Synthesis__Apply1C__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Synthesis__Apply1C__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Microsoft__Quantum__Synthesis__Apply1C__ctladj__wrapper]
@PartialApplication__2 = constant [4 x void (%Tuple*, %Tuple*, %Tuple*)*] [void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__body__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__adj__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__ctl__wrapper, void (%Tuple*, %Tuple*, %Tuple*)* @Lifted__PartialApplication__2__ctladj__wrapper]
@MemoryManagement__2 = constant [2 x void (%Tuple*, i64)*] [void (%Tuple*, i64)* @MemoryManagement__2__RefCount, void (%Tuple*, i64)* @MemoryManagement__2__AliasCount]
@1 = internal constant [20 x i8] c"Survival at length \00"
@2 = internal constant [3 x i8] c": \00"

@Microsoft__Quantum__Experimental__RunRBExperiment = alias void (), void ()* @Microsoft__Quantum__Experimental__RunRBExperiment__body

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Times1C__body({ i64, i64, i64, i64 }* %left, { i64, i64, i64, i64 }* %right) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %left to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = bitcast { i64, i64, i64, i64 }* %right to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 1)
  %2 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %left)
  %3 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %2, i64 0, i32 0
  %e1 = load i64, i64* %3
  %4 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %2, i64 0, i32 1
  %x1 = load i64, i64* %4
  %5 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %2, i64 0, i32 2
  %s1 = load i64, i64* %5
  %6 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %2, i64 0, i32 3
  %w1 = load i64, i64* %6
  %7 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %right)
  %8 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 0
  %e2 = load i64, i64* %8
  %9 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 1
  %x2 = load i64, i64* %9
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 2
  %s2 = load i64, i64* %10
  %11 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 3
  %w2 = load i64, i64* %11
  %12 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__XSECommutation__body(i64 %x1, i64 %s1, i64 %e2)
  %13 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %12, i64 0, i32 0
  %e3 = load i64, i64* %13
  %14 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %12, i64 0, i32 1
  %x3 = load i64, i64* %14
  %15 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %12, i64 0, i32 2
  %s3 = load i64, i64* %15
  %16 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %12, i64 0, i32 3
  %w3 = load i64, i64* %16
  %17 = call { i64, i64 }* @Microsoft__Quantum__Synthesis__XSCommutation__body(i64 %s3, i64 %x2)
  %18 = getelementptr { i64, i64 }, { i64, i64 }* %17, i64 0, i32 0
  %s4 = load i64, i64* %18
  %19 = getelementptr { i64, i64 }, { i64, i64 }* %17, i64 0, i32 1
  %w4 = load i64, i64* %19
  %20 = add i64 %e1, %e3
  %21 = add i64 %x3, %x2
  %22 = add i64 %s4, %s2
  %23 = add i64 %w4, %w3
  %24 = add i64 %23, %w1
  %25 = add i64 %24, %w2
  %26 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 %20, i64 %21, i64 %22, i64 %25)
  %27 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %26)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 -1)
  %28 = bitcast { i64, i64, i64, i64 }* %2 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %28, i64 -1)
  %29 = bitcast { i64, i64, i64, i64 }* %7 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %29, i64 -1)
  %30 = bitcast { i64, i64, i64, i64 }* %12 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %30, i64 -1)
  %31 = bitcast { i64, i64 }* %17 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %31, i64 -1)
  %32 = bitcast { i64, i64, i64, i64 }* %26 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %32, i64 -1)
  ret { i64, i64, i64, i64 }* %27
}

declare void @__quantum__rt__tuple_update_alias_count(%Tuple*, i64)

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %op) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 0
  %2 = load i64, i64* %1
  %3 = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %2, i64 3)
  %4 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 1
  %5 = load i64, i64* %4
  %6 = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %5, i64 2)
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 2
  %8 = load i64, i64* %7
  %9 = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %8, i64 4)
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 3
  %11 = load i64, i64* %10
  %12 = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %11, i64 8)
  %13 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 %3, i64 %6, i64 %9, i64 %12)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  ret { i64, i64, i64, i64 }* %13
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__XSECommutation__body(i64 %x, i64 %s, i64 %e) {
entry:
  %i = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %e, i64 3)
  %j = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %x, i64 2)
  %k = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %s, i64 4)
  %0 = icmp eq i64 %j, 0
  %1 = icmp eq i64 %k, 0
  %2 = and i1 %0, %1
  %3 = icmp eq i64 %i, 0
  %4 = and i1 %2, %3
  br i1 %4, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %6 = bitcast %Tuple* %5 to { i64, i64, i64, i64 }*
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 0
  %8 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 1
  %9 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 2
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 3
  store i64 0, i64* %7
  store i64 0, i64* %8
  store i64 0, i64* %9
  store i64 0, i64* %10
  ret { i64, i64, i64, i64 }* %6

test1__1:                                         ; preds = %entry
  %11 = icmp eq i64 %j, 0
  %12 = icmp eq i64 %k, 0
  %13 = and i1 %11, %12
  %14 = icmp eq i64 %i, 1
  %15 = and i1 %13, %14
  br i1 %15, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %16 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %17 = bitcast %Tuple* %16 to { i64, i64, i64, i64 }*
  %18 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 0
  %19 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 1
  %20 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 2
  %21 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 3
  store i64 1, i64* %18
  store i64 0, i64* %19
  store i64 0, i64* %20
  store i64 0, i64* %21
  ret { i64, i64, i64, i64 }* %17

test2__1:                                         ; preds = %test1__1
  %22 = icmp eq i64 %j, 0
  %23 = icmp eq i64 %k, 0
  %24 = and i1 %22, %23
  %25 = icmp eq i64 %i, 2
  %26 = and i1 %24, %25
  br i1 %26, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %27 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %28 = bitcast %Tuple* %27 to { i64, i64, i64, i64 }*
  %29 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 0
  %30 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 1
  %31 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 2
  %32 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 3
  store i64 2, i64* %29
  store i64 0, i64* %30
  store i64 0, i64* %31
  store i64 0, i64* %32
  ret { i64, i64, i64, i64 }* %28

test3__1:                                         ; preds = %test2__1
  %33 = icmp eq i64 %j, 0
  %34 = icmp eq i64 %k, 1
  %35 = and i1 %33, %34
  %36 = icmp eq i64 %i, 0
  %37 = and i1 %35, %36
  br i1 %37, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %38 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %39 = bitcast %Tuple* %38 to { i64, i64, i64, i64 }*
  %40 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 0
  %41 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 1
  %42 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 2
  %43 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 3
  store i64 0, i64* %40
  store i64 0, i64* %41
  store i64 1, i64* %42
  store i64 0, i64* %43
  ret { i64, i64, i64, i64 }* %39

test4__1:                                         ; preds = %test3__1
  %44 = icmp eq i64 %j, 0
  %45 = icmp eq i64 %k, 1
  %46 = and i1 %44, %45
  %47 = icmp eq i64 %i, 1
  %48 = and i1 %46, %47
  br i1 %48, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %49 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %50 = bitcast %Tuple* %49 to { i64, i64, i64, i64 }*
  %51 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 0
  %52 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 1
  %53 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 2
  %54 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 3
  store i64 2, i64* %51
  store i64 0, i64* %52
  store i64 3, i64* %53
  store i64 6, i64* %54
  ret { i64, i64, i64, i64 }* %50

test5__1:                                         ; preds = %test4__1
  %55 = icmp eq i64 %j, 0
  %56 = icmp eq i64 %k, 1
  %57 = and i1 %55, %56
  %58 = icmp eq i64 %i, 2
  %59 = and i1 %57, %58
  br i1 %59, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %60 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %61 = bitcast %Tuple* %60 to { i64, i64, i64, i64 }*
  %62 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 0
  %63 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 1
  %64 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 2
  %65 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 3
  store i64 1, i64* %62
  store i64 1, i64* %63
  store i64 3, i64* %64
  store i64 4, i64* %65
  ret { i64, i64, i64, i64 }* %61

test6__1:                                         ; preds = %test5__1
  %66 = icmp eq i64 %j, 0
  %67 = icmp eq i64 %k, 2
  %68 = and i1 %66, %67
  %69 = icmp eq i64 %i, 0
  %70 = and i1 %68, %69
  br i1 %70, label %then6__1, label %test7__1

then6__1:                                         ; preds = %test6__1
  %71 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %72 = bitcast %Tuple* %71 to { i64, i64, i64, i64 }*
  %73 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 0
  %74 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 1
  %75 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 2
  %76 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 3
  store i64 0, i64* %73
  store i64 0, i64* %74
  store i64 2, i64* %75
  store i64 0, i64* %76
  ret { i64, i64, i64, i64 }* %72

test7__1:                                         ; preds = %test6__1
  %77 = icmp eq i64 %j, 0
  %78 = icmp eq i64 %k, 2
  %79 = and i1 %77, %78
  %80 = icmp eq i64 %i, 1
  %81 = and i1 %79, %80
  br i1 %81, label %then7__1, label %test8__1

then7__1:                                         ; preds = %test7__1
  %82 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %83 = bitcast %Tuple* %82 to { i64, i64, i64, i64 }*
  %84 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 0
  %85 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 1
  %86 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 2
  %87 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 3
  store i64 1, i64* %84
  store i64 1, i64* %85
  store i64 2, i64* %86
  store i64 2, i64* %87
  ret { i64, i64, i64, i64 }* %83

test8__1:                                         ; preds = %test7__1
  %88 = icmp eq i64 %j, 0
  %89 = icmp eq i64 %k, 2
  %90 = and i1 %88, %89
  %91 = icmp eq i64 %i, 2
  %92 = and i1 %90, %91
  br i1 %92, label %then8__1, label %test9__1

then8__1:                                         ; preds = %test8__1
  %93 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %94 = bitcast %Tuple* %93 to { i64, i64, i64, i64 }*
  %95 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 0
  %96 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 1
  %97 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 2
  %98 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 3
  store i64 2, i64* %95
  store i64 1, i64* %96
  store i64 0, i64* %97
  store i64 0, i64* %98
  ret { i64, i64, i64, i64 }* %94

test9__1:                                         ; preds = %test8__1
  %99 = icmp eq i64 %j, 0
  %100 = icmp eq i64 %k, 3
  %101 = and i1 %99, %100
  %102 = icmp eq i64 %i, 0
  %103 = and i1 %101, %102
  br i1 %103, label %then9__1, label %test10__1

then9__1:                                         ; preds = %test9__1
  %104 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %105 = bitcast %Tuple* %104 to { i64, i64, i64, i64 }*
  %106 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 0
  %107 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 1
  %108 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 2
  %109 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 3
  store i64 0, i64* %106
  store i64 0, i64* %107
  store i64 3, i64* %108
  store i64 0, i64* %109
  ret { i64, i64, i64, i64 }* %105

test10__1:                                        ; preds = %test9__1
  %110 = icmp eq i64 %j, 0
  %111 = icmp eq i64 %k, 3
  %112 = and i1 %110, %111
  %113 = icmp eq i64 %i, 1
  %114 = and i1 %112, %113
  br i1 %114, label %then10__1, label %test11__1

then10__1:                                        ; preds = %test10__1
  %115 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %116 = bitcast %Tuple* %115 to { i64, i64, i64, i64 }*
  %117 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 0
  %118 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 1
  %119 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 2
  %120 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 3
  store i64 2, i64* %117
  store i64 1, i64* %118
  store i64 3, i64* %119
  store i64 6, i64* %120
  ret { i64, i64, i64, i64 }* %116

test11__1:                                        ; preds = %test10__1
  %121 = icmp eq i64 %j, 0
  %122 = icmp eq i64 %k, 3
  %123 = and i1 %121, %122
  %124 = icmp eq i64 %i, 2
  %125 = and i1 %123, %124
  br i1 %125, label %then11__1, label %test12__1

then11__1:                                        ; preds = %test11__1
  %126 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %127 = bitcast %Tuple* %126 to { i64, i64, i64, i64 }*
  %128 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 0
  %129 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 1
  %130 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 2
  %131 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 3
  store i64 1, i64* %128
  store i64 0, i64* %129
  store i64 1, i64* %130
  store i64 2, i64* %131
  ret { i64, i64, i64, i64 }* %127

test12__1:                                        ; preds = %test11__1
  %132 = icmp eq i64 %j, 1
  %133 = icmp eq i64 %k, 0
  %134 = and i1 %132, %133
  %135 = icmp eq i64 %i, 0
  %136 = and i1 %134, %135
  br i1 %136, label %then12__1, label %test13__1

then12__1:                                        ; preds = %test12__1
  %137 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %138 = bitcast %Tuple* %137 to { i64, i64, i64, i64 }*
  %139 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 0
  %140 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 1
  %141 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 2
  %142 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 3
  store i64 0, i64* %139
  store i64 1, i64* %140
  store i64 0, i64* %141
  store i64 0, i64* %142
  ret { i64, i64, i64, i64 }* %138

test13__1:                                        ; preds = %test12__1
  %143 = icmp eq i64 %j, 1
  %144 = icmp eq i64 %k, 0
  %145 = and i1 %143, %144
  %146 = icmp eq i64 %i, 1
  %147 = and i1 %145, %146
  br i1 %147, label %then13__1, label %test14__1

then13__1:                                        ; preds = %test13__1
  %148 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %149 = bitcast %Tuple* %148 to { i64, i64, i64, i64 }*
  %150 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 0
  %151 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 1
  %152 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 2
  %153 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 3
  store i64 1, i64* %150
  store i64 0, i64* %151
  store i64 2, i64* %152
  store i64 0, i64* %153
  ret { i64, i64, i64, i64 }* %149

test14__1:                                        ; preds = %test13__1
  %154 = icmp eq i64 %j, 1
  %155 = icmp eq i64 %k, 0
  %156 = and i1 %154, %155
  %157 = icmp eq i64 %i, 2
  %158 = and i1 %156, %157
  br i1 %158, label %then14__1, label %test15__1

then14__1:                                        ; preds = %test14__1
  %159 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %160 = bitcast %Tuple* %159 to { i64, i64, i64, i64 }*
  %161 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 0
  %162 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 1
  %163 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 2
  %164 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 3
  store i64 2, i64* %161
  store i64 1, i64* %162
  store i64 2, i64* %163
  store i64 2, i64* %164
  ret { i64, i64, i64, i64 }* %160

test15__1:                                        ; preds = %test14__1
  %165 = icmp eq i64 %j, 1
  %166 = icmp eq i64 %k, 1
  %167 = and i1 %165, %166
  %168 = icmp eq i64 %i, 0
  %169 = and i1 %167, %168
  br i1 %169, label %then15__1, label %test16__1

then15__1:                                        ; preds = %test15__1
  %170 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %171 = bitcast %Tuple* %170 to { i64, i64, i64, i64 }*
  %172 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 0
  %173 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 1
  %174 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 2
  %175 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 3
  store i64 0, i64* %172
  store i64 1, i64* %173
  store i64 1, i64* %174
  store i64 0, i64* %175
  ret { i64, i64, i64, i64 }* %171

test16__1:                                        ; preds = %test15__1
  %176 = icmp eq i64 %j, 1
  %177 = icmp eq i64 %k, 1
  %178 = and i1 %176, %177
  %179 = icmp eq i64 %i, 1
  %180 = and i1 %178, %179
  br i1 %180, label %then16__1, label %test17__1

then16__1:                                        ; preds = %test16__1
  %181 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %182 = bitcast %Tuple* %181 to { i64, i64, i64, i64 }*
  %183 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 0
  %184 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 1
  %185 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 2
  %186 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 3
  store i64 2, i64* %183
  store i64 1, i64* %184
  store i64 1, i64* %185
  store i64 0, i64* %186
  ret { i64, i64, i64, i64 }* %182

test17__1:                                        ; preds = %test16__1
  %187 = icmp eq i64 %j, 1
  %188 = icmp eq i64 %k, 1
  %189 = and i1 %187, %188
  %190 = icmp eq i64 %i, 2
  %191 = and i1 %189, %190
  br i1 %191, label %then17__1, label %test18__1

then17__1:                                        ; preds = %test17__1
  %192 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %193 = bitcast %Tuple* %192 to { i64, i64, i64, i64 }*
  %194 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 0
  %195 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 1
  %196 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 2
  %197 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 3
  store i64 1, i64* %194
  store i64 1, i64* %195
  store i64 1, i64* %196
  store i64 0, i64* %197
  ret { i64, i64, i64, i64 }* %193

test18__1:                                        ; preds = %test17__1
  %198 = icmp eq i64 %j, 1
  %199 = icmp eq i64 %k, 2
  %200 = and i1 %198, %199
  %201 = icmp eq i64 %i, 0
  %202 = and i1 %200, %201
  br i1 %202, label %then18__1, label %test19__1

then18__1:                                        ; preds = %test18__1
  %203 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %204 = bitcast %Tuple* %203 to { i64, i64, i64, i64 }*
  %205 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 0
  %206 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 1
  %207 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 2
  %208 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 3
  store i64 0, i64* %205
  store i64 1, i64* %206
  store i64 2, i64* %207
  store i64 0, i64* %208
  ret { i64, i64, i64, i64 }* %204

test19__1:                                        ; preds = %test18__1
  %209 = icmp eq i64 %j, 1
  %210 = icmp eq i64 %k, 2
  %211 = and i1 %209, %210
  %212 = icmp eq i64 %i, 1
  %213 = and i1 %211, %212
  br i1 %213, label %then19__1, label %test20__1

then19__1:                                        ; preds = %test19__1
  %214 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %215 = bitcast %Tuple* %214 to { i64, i64, i64, i64 }*
  %216 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 0
  %217 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 1
  %218 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 2
  %219 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 3
  store i64 1, i64* %216
  store i64 1, i64* %217
  store i64 0, i64* %218
  store i64 6, i64* %219
  ret { i64, i64, i64, i64 }* %215

test20__1:                                        ; preds = %test19__1
  %220 = icmp eq i64 %j, 1
  %221 = icmp eq i64 %k, 2
  %222 = and i1 %220, %221
  %223 = icmp eq i64 %i, 2
  %224 = and i1 %222, %223
  br i1 %224, label %then20__1, label %test21__1

then20__1:                                        ; preds = %test20__1
  %225 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %226 = bitcast %Tuple* %225 to { i64, i64, i64, i64 }*
  %227 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 0
  %228 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 1
  %229 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 2
  %230 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 3
  store i64 2, i64* %227
  store i64 0, i64* %228
  store i64 2, i64* %229
  store i64 6, i64* %230
  ret { i64, i64, i64, i64 }* %226

test21__1:                                        ; preds = %test20__1
  %231 = icmp eq i64 %j, 1
  %232 = icmp eq i64 %k, 3
  %233 = and i1 %231, %232
  %234 = icmp eq i64 %i, 0
  %235 = and i1 %233, %234
  br i1 %235, label %then21__1, label %test22__1

then21__1:                                        ; preds = %test21__1
  %236 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %237 = bitcast %Tuple* %236 to { i64, i64, i64, i64 }*
  %238 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 0
  %239 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 1
  %240 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 2
  %241 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 3
  store i64 0, i64* %238
  store i64 1, i64* %239
  store i64 3, i64* %240
  store i64 0, i64* %241
  ret { i64, i64, i64, i64 }* %237

test22__1:                                        ; preds = %test21__1
  %242 = icmp eq i64 %j, 1
  %243 = icmp eq i64 %k, 3
  %244 = and i1 %242, %243
  %245 = icmp eq i64 %i, 1
  %246 = and i1 %244, %245
  br i1 %246, label %then22__1, label %test23__1

then22__1:                                        ; preds = %test22__1
  %247 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %248 = bitcast %Tuple* %247 to { i64, i64, i64, i64 }*
  %249 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 0
  %250 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 1
  %251 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 2
  %252 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 3
  store i64 2, i64* %249
  store i64 0, i64* %250
  store i64 1, i64* %251
  store i64 4, i64* %252
  ret { i64, i64, i64, i64 }* %248

test23__1:                                        ; preds = %test22__1
  %253 = icmp eq i64 %j, 1
  %254 = icmp eq i64 %k, 3
  %255 = and i1 %253, %254
  %256 = icmp eq i64 %i, 2
  %257 = and i1 %255, %256
  br i1 %257, label %then23__1, label %else__1

then23__1:                                        ; preds = %test23__1
  %258 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %259 = bitcast %Tuple* %258 to { i64, i64, i64, i64 }*
  %260 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 0
  %261 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 1
  %262 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 2
  %263 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 3
  store i64 1, i64* %260
  store i64 0, i64* %261
  store i64 3, i64* %262
  store i64 2, i64* %263
  ret { i64, i64, i64, i64 }* %259

else__1:                                          ; preds = %test23__1
  %264 = call %String* @__quantum__rt__string_create(i32 0, i8* null)
  call void @__quantum__rt__fail(%String* %264)
  unreachable
}

define { i64, i64 }* @Microsoft__Quantum__Synthesis__XSCommutation__body(i64 %s, i64 %x) {
entry:
  %k = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %s, i64 4)
  %j = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %x, i64 2)
  %0 = icmp eq i64 %k, 0
  %1 = icmp eq i64 %j, 0
  %2 = and i1 %0, %1
  br i1 %2, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  %3 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %4 = bitcast %Tuple* %3 to { i64, i64 }*
  %5 = getelementptr { i64, i64 }, { i64, i64 }* %4, i64 0, i32 0
  %6 = getelementptr { i64, i64 }, { i64, i64 }* %4, i64 0, i32 1
  store i64 0, i64* %5
  store i64 0, i64* %6
  ret { i64, i64 }* %4

test1__1:                                         ; preds = %entry
  %7 = icmp eq i64 %k, 0
  %8 = icmp eq i64 %j, 1
  %9 = and i1 %7, %8
  br i1 %9, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %10 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %11 = bitcast %Tuple* %10 to { i64, i64 }*
  %12 = getelementptr { i64, i64 }, { i64, i64 }* %11, i64 0, i32 0
  %13 = getelementptr { i64, i64 }, { i64, i64 }* %11, i64 0, i32 1
  store i64 0, i64* %12
  store i64 0, i64* %13
  ret { i64, i64 }* %11

test2__1:                                         ; preds = %test1__1
  %14 = icmp eq i64 %k, 1
  %15 = icmp eq i64 %j, 0
  %16 = and i1 %14, %15
  br i1 %16, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %17 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %18 = bitcast %Tuple* %17 to { i64, i64 }*
  %19 = getelementptr { i64, i64 }, { i64, i64 }* %18, i64 0, i32 0
  %20 = getelementptr { i64, i64 }, { i64, i64 }* %18, i64 0, i32 1
  store i64 1, i64* %19
  store i64 0, i64* %20
  ret { i64, i64 }* %18

test3__1:                                         ; preds = %test2__1
  %21 = icmp eq i64 %k, 1
  %22 = icmp eq i64 %j, 1
  %23 = and i1 %21, %22
  br i1 %23, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %24 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %25 = bitcast %Tuple* %24 to { i64, i64 }*
  %26 = getelementptr { i64, i64 }, { i64, i64 }* %25, i64 0, i32 0
  %27 = getelementptr { i64, i64 }, { i64, i64 }* %25, i64 0, i32 1
  store i64 3, i64* %26
  store i64 2, i64* %27
  ret { i64, i64 }* %25

test4__1:                                         ; preds = %test3__1
  %28 = icmp eq i64 %k, 2
  %29 = icmp eq i64 %j, 0
  %30 = and i1 %28, %29
  br i1 %30, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %31 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %32 = bitcast %Tuple* %31 to { i64, i64 }*
  %33 = getelementptr { i64, i64 }, { i64, i64 }* %32, i64 0, i32 0
  %34 = getelementptr { i64, i64 }, { i64, i64 }* %32, i64 0, i32 1
  store i64 2, i64* %33
  store i64 0, i64* %34
  ret { i64, i64 }* %32

test5__1:                                         ; preds = %test4__1
  %35 = icmp eq i64 %k, 2
  %36 = icmp eq i64 %j, 1
  %37 = and i1 %35, %36
  br i1 %37, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %38 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %39 = bitcast %Tuple* %38 to { i64, i64 }*
  %40 = getelementptr { i64, i64 }, { i64, i64 }* %39, i64 0, i32 0
  %41 = getelementptr { i64, i64 }, { i64, i64 }* %39, i64 0, i32 1
  store i64 2, i64* %40
  store i64 4, i64* %41
  ret { i64, i64 }* %39

test6__1:                                         ; preds = %test5__1
  %42 = icmp eq i64 %k, 3
  %43 = icmp eq i64 %j, 0
  %44 = and i1 %42, %43
  br i1 %44, label %then6__1, label %test7__1

then6__1:                                         ; preds = %test6__1
  %45 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %46 = bitcast %Tuple* %45 to { i64, i64 }*
  %47 = getelementptr { i64, i64 }, { i64, i64 }* %46, i64 0, i32 0
  %48 = getelementptr { i64, i64 }, { i64, i64 }* %46, i64 0, i32 1
  store i64 3, i64* %47
  store i64 0, i64* %48
  ret { i64, i64 }* %46

test7__1:                                         ; preds = %test6__1
  %49 = icmp eq i64 %k, 3
  %50 = icmp eq i64 %j, 1
  %51 = and i1 %49, %50
  br i1 %51, label %then7__1, label %else__1

then7__1:                                         ; preds = %test7__1
  %52 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 2))
  %53 = bitcast %Tuple* %52 to { i64, i64 }*
  %54 = getelementptr { i64, i64 }, { i64, i64 }* %53, i64 0, i32 0
  %55 = getelementptr { i64, i64 }, { i64, i64 }* %53, i64 0, i32 1
  store i64 1, i64* %54
  store i64 6, i64* %55
  ret { i64, i64 }* %53

else__1:                                          ; preds = %test7__1
  %56 = call %String* @__quantum__rt__string_create(i32 0, i8* null)
  call void @__quantum__rt__fail(%String* %56)
  unreachable
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 %E, i64 %X, i64 %S, i64 %"?") {
entry:
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %1 = bitcast %Tuple* %0 to { i64, i64, i64, i64 }*
  %2 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %1, i64 0, i32 0
  %3 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %1, i64 0, i32 1
  %4 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %1, i64 0, i32 2
  %5 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %1, i64 0, i32 3
  store i64 %E, i64* %2
  store i64 %X, i64* %3
  store i64 %S, i64* %4
  store i64 %"?", i64* %5
  ret { i64, i64, i64, i64 }* %1
}

declare void @__quantum__rt__tuple_update_reference_count(%Tuple*, i64)

declare %Tuple* @__quantum__rt__tuple_create(i64)

define i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %x, i64 %n) {
entry:
  %0 = icmp sgt i64 %n, 0
  %1 = call %String* @__quantum__rt__string_create(i32 25, i8* getelementptr inbounds ([26 x i8], [26 x i8]* @0, i32 0, i32 0))
  call void @Microsoft__Quantum__Diagnostics__Fact__body(i1 %0, %String* %1)
  %2 = add i64 %x, %n
  %3 = srem i64 %2, %n
  call void @__quantum__rt__string_update_reference_count(%String* %1, i64 -1)
  ret i64 %3
}

define void @Microsoft__Quantum__Diagnostics__Fact__body(i1 %actual, %String* %message) {
entry:
  %0 = xor i1 %actual, true
  br i1 %0, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__string_update_reference_count(%String* %message, i64 1)
  call void @__quantum__rt__fail(%String* %message)
  unreachable

continue__1:                                      ; preds = %entry
  ret void
}

declare %String* @__quantum__rt__string_create(i32, i8*)

declare void @__quantum__rt__string_update_reference_count(%String*, i64)

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Inverse1C__body({ i64, i64, i64, i64 }* %op) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 0
  %2 = load i64, i64* %1
  %3 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 1
  %4 = load i64, i64* %3
  %5 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 2
  %6 = load i64, i64* %5
  %7 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__InverseWithoutPhase__body(i64 %2, i64 %4, i64 %6)
  %8 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 0
  %i2 = load i64, i64* %8
  %9 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 1
  %j2 = load i64, i64* %9
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 2
  %k2 = load i64, i64* %10
  %11 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %7, i64 0, i32 3
  %l2 = load i64, i64* %11
  %12 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %op, i64 0, i32 3
  %13 = load i64, i64* %12
  %14 = sub i64 %l2, %13
  %15 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 %i2, i64 %j2, i64 %k2, i64 %14)
  %16 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %15)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  %17 = bitcast { i64, i64, i64, i64 }* %7 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %17, i64 -1)
  %18 = bitcast { i64, i64, i64, i64 }* %15 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %18, i64 -1)
  ret { i64, i64, i64, i64 }* %16
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__InverseWithoutPhase__body(i64 %e, i64 %x, i64 %s) {
entry:
  %i = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %e, i64 3)
  %j = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %x, i64 2)
  %k = call i64 @Microsoft__Quantum__Synthesis__RingRepresentative__body(i64 %s, i64 4)
  %0 = icmp eq i64 %i, 0
  %1 = icmp eq i64 %j, 0
  %2 = and i1 %0, %1
  %3 = icmp eq i64 %k, 0
  %4 = and i1 %2, %3
  br i1 %4, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  %5 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %6 = bitcast %Tuple* %5 to { i64, i64, i64, i64 }*
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 0
  %8 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 1
  %9 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 2
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %6, i64 0, i32 3
  store i64 0, i64* %7
  store i64 0, i64* %8
  store i64 0, i64* %9
  store i64 0, i64* %10
  ret { i64, i64, i64, i64 }* %6

test1__1:                                         ; preds = %entry
  %11 = icmp eq i64 %i, 0
  %12 = icmp eq i64 %j, 0
  %13 = and i1 %11, %12
  %14 = icmp eq i64 %k, 1
  %15 = and i1 %13, %14
  br i1 %15, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  %16 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %17 = bitcast %Tuple* %16 to { i64, i64, i64, i64 }*
  %18 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 0
  %19 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 1
  %20 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 2
  %21 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %17, i64 0, i32 3
  store i64 0, i64* %18
  store i64 0, i64* %19
  store i64 3, i64* %20
  store i64 0, i64* %21
  ret { i64, i64, i64, i64 }* %17

test2__1:                                         ; preds = %test1__1
  %22 = icmp eq i64 %i, 0
  %23 = icmp eq i64 %j, 0
  %24 = and i1 %22, %23
  %25 = icmp eq i64 %k, 2
  %26 = and i1 %24, %25
  br i1 %26, label %then2__1, label %test3__1

then2__1:                                         ; preds = %test2__1
  %27 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %28 = bitcast %Tuple* %27 to { i64, i64, i64, i64 }*
  %29 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 0
  %30 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 1
  %31 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 2
  %32 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %28, i64 0, i32 3
  store i64 0, i64* %29
  store i64 0, i64* %30
  store i64 2, i64* %31
  store i64 0, i64* %32
  ret { i64, i64, i64, i64 }* %28

test3__1:                                         ; preds = %test2__1
  %33 = icmp eq i64 %i, 0
  %34 = icmp eq i64 %j, 0
  %35 = and i1 %33, %34
  %36 = icmp eq i64 %k, 3
  %37 = and i1 %35, %36
  br i1 %37, label %then3__1, label %test4__1

then3__1:                                         ; preds = %test3__1
  %38 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %39 = bitcast %Tuple* %38 to { i64, i64, i64, i64 }*
  %40 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 0
  %41 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 1
  %42 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 2
  %43 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %39, i64 0, i32 3
  store i64 0, i64* %40
  store i64 0, i64* %41
  store i64 1, i64* %42
  store i64 0, i64* %43
  ret { i64, i64, i64, i64 }* %39

test4__1:                                         ; preds = %test3__1
  %44 = icmp eq i64 %i, 0
  %45 = icmp eq i64 %j, 1
  %46 = and i1 %44, %45
  %47 = icmp eq i64 %k, 0
  %48 = and i1 %46, %47
  br i1 %48, label %then4__1, label %test5__1

then4__1:                                         ; preds = %test4__1
  %49 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %50 = bitcast %Tuple* %49 to { i64, i64, i64, i64 }*
  %51 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 0
  %52 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 1
  %53 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 2
  %54 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %50, i64 0, i32 3
  store i64 0, i64* %51
  store i64 1, i64* %52
  store i64 0, i64* %53
  store i64 0, i64* %54
  ret { i64, i64, i64, i64 }* %50

test5__1:                                         ; preds = %test4__1
  %55 = icmp eq i64 %i, 0
  %56 = icmp eq i64 %j, 1
  %57 = and i1 %55, %56
  %58 = icmp eq i64 %k, 1
  %59 = and i1 %57, %58
  br i1 %59, label %then5__1, label %test6__1

then5__1:                                         ; preds = %test5__1
  %60 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %61 = bitcast %Tuple* %60 to { i64, i64, i64, i64 }*
  %62 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 0
  %63 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 1
  %64 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 2
  %65 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %61, i64 0, i32 3
  store i64 0, i64* %62
  store i64 1, i64* %63
  store i64 1, i64* %64
  store i64 6, i64* %65
  ret { i64, i64, i64, i64 }* %61

test6__1:                                         ; preds = %test5__1
  %66 = icmp eq i64 %i, 0
  %67 = icmp eq i64 %j, 1
  %68 = and i1 %66, %67
  %69 = icmp eq i64 %k, 2
  %70 = and i1 %68, %69
  br i1 %70, label %then6__1, label %test7__1

then6__1:                                         ; preds = %test6__1
  %71 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %72 = bitcast %Tuple* %71 to { i64, i64, i64, i64 }*
  %73 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 0
  %74 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 1
  %75 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 2
  %76 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %72, i64 0, i32 3
  store i64 0, i64* %73
  store i64 1, i64* %74
  store i64 2, i64* %75
  store i64 4, i64* %76
  ret { i64, i64, i64, i64 }* %72

test7__1:                                         ; preds = %test6__1
  %77 = icmp eq i64 %i, 0
  %78 = icmp eq i64 %j, 1
  %79 = and i1 %77, %78
  %80 = icmp eq i64 %k, 3
  %81 = and i1 %79, %80
  br i1 %81, label %then7__1, label %test8__1

then7__1:                                         ; preds = %test7__1
  %82 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %83 = bitcast %Tuple* %82 to { i64, i64, i64, i64 }*
  %84 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 0
  %85 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 1
  %86 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 2
  %87 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %83, i64 0, i32 3
  store i64 0, i64* %84
  store i64 1, i64* %85
  store i64 3, i64* %86
  store i64 2, i64* %87
  ret { i64, i64, i64, i64 }* %83

test8__1:                                         ; preds = %test7__1
  %88 = icmp eq i64 %i, 1
  %89 = icmp eq i64 %j, 0
  %90 = and i1 %88, %89
  %91 = icmp eq i64 %k, 0
  %92 = and i1 %90, %91
  br i1 %92, label %then8__1, label %test9__1

then8__1:                                         ; preds = %test8__1
  %93 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %94 = bitcast %Tuple* %93 to { i64, i64, i64, i64 }*
  %95 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 0
  %96 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 1
  %97 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 2
  %98 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %94, i64 0, i32 3
  store i64 2, i64* %95
  store i64 0, i64* %96
  store i64 0, i64* %97
  store i64 0, i64* %98
  ret { i64, i64, i64, i64 }* %94

test9__1:                                         ; preds = %test8__1
  %99 = icmp eq i64 %i, 1
  %100 = icmp eq i64 %j, 0
  %101 = and i1 %99, %100
  %102 = icmp eq i64 %k, 1
  %103 = and i1 %101, %102
  br i1 %103, label %then9__1, label %test10__1

then9__1:                                         ; preds = %test9__1
  %104 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %105 = bitcast %Tuple* %104 to { i64, i64, i64, i64 }*
  %106 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 0
  %107 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 1
  %108 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 2
  %109 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %105, i64 0, i32 3
  store i64 1, i64* %106
  store i64 0, i64* %107
  store i64 1, i64* %108
  store i64 2, i64* %109
  ret { i64, i64, i64, i64 }* %105

test10__1:                                        ; preds = %test9__1
  %110 = icmp eq i64 %i, 1
  %111 = icmp eq i64 %j, 0
  %112 = and i1 %110, %111
  %113 = icmp eq i64 %k, 2
  %114 = and i1 %112, %113
  br i1 %114, label %then10__1, label %test11__1

then10__1:                                        ; preds = %test10__1
  %115 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %116 = bitcast %Tuple* %115 to { i64, i64, i64, i64 }*
  %117 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 0
  %118 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 1
  %119 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 2
  %120 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %116, i64 0, i32 3
  store i64 2, i64* %117
  store i64 1, i64* %118
  store i64 0, i64* %119
  store i64 0, i64* %120
  ret { i64, i64, i64, i64 }* %116

test11__1:                                        ; preds = %test10__1
  %121 = icmp eq i64 %i, 1
  %122 = icmp eq i64 %j, 0
  %123 = and i1 %121, %122
  %124 = icmp eq i64 %k, 3
  %125 = and i1 %123, %124
  br i1 %125, label %then11__1, label %test12__1

then11__1:                                        ; preds = %test11__1
  %126 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %127 = bitcast %Tuple* %126 to { i64, i64, i64, i64 }*
  %128 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 0
  %129 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 1
  %130 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 2
  %131 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %127, i64 0, i32 3
  store i64 1, i64* %128
  store i64 1, i64* %129
  store i64 3, i64* %130
  store i64 4, i64* %131
  ret { i64, i64, i64, i64 }* %127

test12__1:                                        ; preds = %test11__1
  %132 = icmp eq i64 %i, 1
  %133 = icmp eq i64 %j, 1
  %134 = and i1 %132, %133
  %135 = icmp eq i64 %k, 0
  %136 = and i1 %134, %135
  br i1 %136, label %then12__1, label %test13__1

then12__1:                                        ; preds = %test12__1
  %137 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %138 = bitcast %Tuple* %137 to { i64, i64, i64, i64 }*
  %139 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 0
  %140 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 1
  %141 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 2
  %142 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %138, i64 0, i32 3
  store i64 2, i64* %139
  store i64 1, i64* %140
  store i64 2, i64* %141
  store i64 2, i64* %142
  ret { i64, i64, i64, i64 }* %138

test13__1:                                        ; preds = %test12__1
  %143 = icmp eq i64 %i, 1
  %144 = icmp eq i64 %j, 1
  %145 = and i1 %143, %144
  %146 = icmp eq i64 %k, 1
  %147 = and i1 %145, %146
  br i1 %147, label %then13__1, label %test14__1

then13__1:                                        ; preds = %test13__1
  %148 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %149 = bitcast %Tuple* %148 to { i64, i64, i64, i64 }*
  %150 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 0
  %151 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 1
  %152 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 2
  %153 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %149, i64 0, i32 3
  store i64 1, i64* %150
  store i64 1, i64* %151
  store i64 1, i64* %152
  store i64 6, i64* %153
  ret { i64, i64, i64, i64 }* %149

test14__1:                                        ; preds = %test13__1
  %154 = icmp eq i64 %i, 1
  %155 = icmp eq i64 %j, 1
  %156 = and i1 %154, %155
  %157 = icmp eq i64 %k, 2
  %158 = and i1 %156, %157
  br i1 %158, label %then14__1, label %test15__1

then14__1:                                        ; preds = %test14__1
  %159 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %160 = bitcast %Tuple* %159 to { i64, i64, i64, i64 }*
  %161 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 0
  %162 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 1
  %163 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 2
  %164 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %160, i64 0, i32 3
  store i64 2, i64* %161
  store i64 0, i64* %162
  store i64 2, i64* %163
  store i64 2, i64* %164
  ret { i64, i64, i64, i64 }* %160

test15__1:                                        ; preds = %test14__1
  %165 = icmp eq i64 %i, 1
  %166 = icmp eq i64 %j, 1
  %167 = and i1 %165, %166
  %168 = icmp eq i64 %k, 3
  %169 = and i1 %167, %168
  br i1 %169, label %then15__1, label %test16__1

then15__1:                                        ; preds = %test15__1
  %170 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %171 = bitcast %Tuple* %170 to { i64, i64, i64, i64 }*
  %172 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 0
  %173 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 1
  %174 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 2
  %175 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %171, i64 0, i32 3
  store i64 1, i64* %172
  store i64 0, i64* %173
  store i64 3, i64* %174
  store i64 4, i64* %175
  ret { i64, i64, i64, i64 }* %171

test16__1:                                        ; preds = %test15__1
  %176 = icmp eq i64 %i, 2
  %177 = icmp eq i64 %j, 0
  %178 = and i1 %176, %177
  %179 = icmp eq i64 %k, 0
  %180 = and i1 %178, %179
  br i1 %180, label %then16__1, label %test17__1

then16__1:                                        ; preds = %test16__1
  %181 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %182 = bitcast %Tuple* %181 to { i64, i64, i64, i64 }*
  %183 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 0
  %184 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 1
  %185 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 2
  %186 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %182, i64 0, i32 3
  store i64 1, i64* %183
  store i64 0, i64* %184
  store i64 0, i64* %185
  store i64 0, i64* %186
  ret { i64, i64, i64, i64 }* %182

test17__1:                                        ; preds = %test16__1
  %187 = icmp eq i64 %i, 2
  %188 = icmp eq i64 %j, 0
  %189 = and i1 %187, %188
  %190 = icmp eq i64 %k, 1
  %191 = and i1 %189, %190
  br i1 %191, label %then17__1, label %test18__1

then17__1:                                        ; preds = %test17__1
  %192 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %193 = bitcast %Tuple* %192 to { i64, i64, i64, i64 }*
  %194 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 0
  %195 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 1
  %196 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 2
  %197 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %193, i64 0, i32 3
  store i64 2, i64* %194
  store i64 1, i64* %195
  store i64 3, i64* %196
  store i64 6, i64* %197
  ret { i64, i64, i64, i64 }* %193

test18__1:                                        ; preds = %test17__1
  %198 = icmp eq i64 %i, 2
  %199 = icmp eq i64 %j, 0
  %200 = and i1 %198, %199
  %201 = icmp eq i64 %k, 2
  %202 = and i1 %200, %201
  br i1 %202, label %then18__1, label %test19__1

then18__1:                                        ; preds = %test18__1
  %203 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %204 = bitcast %Tuple* %203 to { i64, i64, i64, i64 }*
  %205 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 0
  %206 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 1
  %207 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 2
  %208 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %204, i64 0, i32 3
  store i64 1, i64* %205
  store i64 1, i64* %206
  store i64 2, i64* %207
  store i64 2, i64* %208
  ret { i64, i64, i64, i64 }* %204

test19__1:                                        ; preds = %test18__1
  %209 = icmp eq i64 %i, 2
  %210 = icmp eq i64 %j, 0
  %211 = and i1 %209, %210
  %212 = icmp eq i64 %k, 3
  %213 = and i1 %211, %212
  br i1 %213, label %then19__1, label %test20__1

then19__1:                                        ; preds = %test19__1
  %214 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %215 = bitcast %Tuple* %214 to { i64, i64, i64, i64 }*
  %216 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 0
  %217 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 1
  %218 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 2
  %219 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %215, i64 0, i32 3
  store i64 2, i64* %216
  store i64 0, i64* %217
  store i64 3, i64* %218
  store i64 6, i64* %219
  ret { i64, i64, i64, i64 }* %215

test20__1:                                        ; preds = %test19__1
  %220 = icmp eq i64 %i, 2
  %221 = icmp eq i64 %j, 1
  %222 = and i1 %220, %221
  %223 = icmp eq i64 %k, 0
  %224 = and i1 %222, %223
  br i1 %224, label %then20__1, label %test21__1

then20__1:                                        ; preds = %test20__1
  %225 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %226 = bitcast %Tuple* %225 to { i64, i64, i64, i64 }*
  %227 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 0
  %228 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 1
  %229 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 2
  %230 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %226, i64 0, i32 3
  store i64 1, i64* %227
  store i64 0, i64* %228
  store i64 2, i64* %229
  store i64 0, i64* %230
  ret { i64, i64, i64, i64 }* %226

test21__1:                                        ; preds = %test20__1
  %231 = icmp eq i64 %i, 2
  %232 = icmp eq i64 %j, 1
  %233 = and i1 %231, %232
  %234 = icmp eq i64 %k, 1
  %235 = and i1 %233, %234
  br i1 %235, label %then21__1, label %test22__1

then21__1:                                        ; preds = %test21__1
  %236 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %237 = bitcast %Tuple* %236 to { i64, i64, i64, i64 }*
  %238 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 0
  %239 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 1
  %240 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 2
  %241 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %237, i64 0, i32 3
  store i64 2, i64* %238
  store i64 1, i64* %239
  store i64 1, i64* %240
  store i64 6, i64* %241
  ret { i64, i64, i64, i64 }* %237

test22__1:                                        ; preds = %test21__1
  %242 = icmp eq i64 %i, 2
  %243 = icmp eq i64 %j, 1
  %244 = and i1 %242, %243
  %245 = icmp eq i64 %k, 2
  %246 = and i1 %244, %245
  br i1 %246, label %then22__1, label %test23__1

then22__1:                                        ; preds = %test22__1
  %247 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %248 = bitcast %Tuple* %247 to { i64, i64, i64, i64 }*
  %249 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 0
  %250 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 1
  %251 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 2
  %252 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %248, i64 0, i32 3
  store i64 1, i64* %249
  store i64 1, i64* %250
  store i64 0, i64* %251
  store i64 2, i64* %252
  ret { i64, i64, i64, i64 }* %248

test23__1:                                        ; preds = %test22__1
  %253 = icmp eq i64 %i, 2
  %254 = icmp eq i64 %j, 1
  %255 = and i1 %253, %254
  %256 = icmp eq i64 %k, 3
  %257 = and i1 %255, %256
  br i1 %257, label %then23__1, label %else__1

then23__1:                                        ; preds = %test23__1
  %258 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %259 = bitcast %Tuple* %258 to { i64, i64, i64, i64 }*
  %260 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 0
  %261 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 1
  %262 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 2
  %263 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %259, i64 0, i32 3
  store i64 2, i64* %260
  store i64 0, i64* %261
  store i64 1, i64* %262
  store i64 6, i64* %263
  ret { i64, i64, i64, i64 }* %259

else__1:                                          ; preds = %test23__1
  %264 = call %String* @__quantum__rt__string_create(i32 0, i8* null)
  call void @__quantum__rt__fail(%String* %264)
  unreachable
}

declare void @__quantum__rt__fail(%String*)

define void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__body({ i64, i64, i64, i64 }* %op, %Qubit* %target) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %cOp = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %op)
  %1 = bitcast { i64, i64, i64, i64 }* %cOp to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 1)
  %2 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 2
  %3 = load i64, i64* %2
  %4 = icmp eq i64 %3, 1
  br i1 %4, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__s__body(%Qubit* %target)
  br label %continue__1

test1__1:                                         ; preds = %entry
  %5 = icmp eq i64 %3, 2
  br i1 %5, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__z__body(%Qubit* %target)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %6 = icmp eq i64 %3, 3
  br i1 %6, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__s__adj(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 1
  %8 = load i64, i64* %7
  %9 = icmp eq i64 %8, 1
  br i1 %9, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__qis__x__body(%Qubit* %target)
  br label %continue__2

continue__2:                                      ; preds = %then0__2, %continue__1
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 0
  %11 = load i64, i64* %10
  br label %header__1

header__1:                                        ; preds = %exiting__1, %continue__2
  %12 = phi i64 [ 1, %continue__2 ], [ %14, %exiting__1 ]
  %13 = icmp sle i64 %12, %11
  br i1 %13, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  call void @__quantum__qis__s__adj(%Qubit* %target)
  call void @__quantum__qis__h__body(%Qubit* %target)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %14 = add i64 %12, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %15 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 3
  %16 = load i64, i64* %15
  %17 = mul i64 3, %11
  %18 = add i64 %16, %17
  %"actual?" = srem i64 %18, 8
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %1, i64 -1)
  ret void
}

declare void @__quantum__qis__s__body(%Qubit*)

declare void @__quantum__qis__z__body(%Qubit*)

declare void @__quantum__qis__s__adj(%Qubit*)

declare void @__quantum__qis__x__body(%Qubit*)

declare void @__quantum__qis__h__body(%Qubit*)

define void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__adj({ i64, i64, i64, i64 }* %op, %Qubit* %target) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %__qsVar0__cOp__ = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %op)
  %1 = bitcast { i64, i64, i64, i64 }* %__qsVar0__cOp__ to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 1)
  %2 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 3
  %3 = load i64, i64* %2
  %4 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 0
  %5 = load i64, i64* %4
  %6 = mul i64 3, %5
  %7 = add i64 %3, %6
  %"__qsVar1__actual?__" = srem i64 %7, 8
  %8 = sub i64 %5, 1
  %9 = udiv i64 %8, 1
  %10 = mul i64 1, %9
  %11 = add i64 1, %10
  %12 = load %Range, %Range* @EmptyRange
  %13 = insertvalue %Range %12, i64 %11, 0
  %14 = insertvalue %Range %13, i64 -1, 1
  %15 = insertvalue %Range %14, i64 1, 2
  %16 = extractvalue %Range %15, 0
  %17 = extractvalue %Range %15, 1
  %18 = extractvalue %Range %15, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %19 = icmp sgt i64 %17, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %20 = phi i64 [ %16, %preheader__1 ], [ %24, %exiting__1 ]
  %21 = icmp sle i64 %20, %18
  %22 = icmp sge i64 %20, %18
  %23 = select i1 %19, i1 %21, i1 %22
  br i1 %23, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  call void @__quantum__qis__h__body(%Qubit* %target)
  call void @__quantum__qis__s__body(%Qubit* %target)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %24 = add i64 %20, %17
  br label %header__1

exit__1:                                          ; preds = %header__1
  %25 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 1
  %26 = load i64, i64* %25
  %27 = icmp eq i64 %26, 1
  br i1 %27, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__1
  call void @__quantum__qis__x__body(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %exit__1
  %28 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 2
  %29 = load i64, i64* %28
  %30 = icmp eq i64 %29, 1
  br i1 %30, label %then0__2, label %test1__1

then0__2:                                         ; preds = %continue__1
  call void @__quantum__qis__s__adj(%Qubit* %target)
  br label %continue__2

test1__1:                                         ; preds = %continue__1
  %31 = icmp eq i64 %29, 2
  br i1 %31, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__z__body(%Qubit* %target)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  %32 = icmp eq i64 %29, 3
  br i1 %32, label %then2__1, label %continue__2

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__s__body(%Qubit* %target)
  br label %continue__2

continue__2:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__2
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %1, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__ctl(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %op = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %2 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 1)
  %3 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %target = load %Qubit*, %Qubit** %3
  %cOp = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %op)
  %4 = bitcast { i64, i64, i64, i64 }* %cOp to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %4, i64 1)
  %5 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 2
  %6 = load i64, i64* %5
  %7 = icmp eq i64 %6, 1
  br i1 %7, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test1__1:                                         ; preds = %entry
  %8 = icmp eq i64 %6, 2
  br i1 %8, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %9 = icmp eq i64 %6, 3
  br i1 %9, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  %10 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 1
  %11 = load i64, i64* %10
  %12 = icmp eq i64 %11, 1
  br i1 %12, label %then0__2, label %continue__2

then0__2:                                         ; preds = %continue__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__2

continue__2:                                      ; preds = %then0__2, %continue__1
  %13 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 0
  %14 = load i64, i64* %13
  br label %header__1

header__1:                                        ; preds = %exiting__1, %continue__2
  %15 = phi i64 [ 1, %continue__2 ], [ %17, %exiting__1 ]
  %16 = icmp sle i64 %15, %14
  br i1 %16, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %17 = add i64 %15, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %18 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %cOp, i64 0, i32 3
  %19 = load i64, i64* %18
  %20 = mul i64 3, %14
  %21 = add i64 %19, %20
  %"actual?" = srem i64 %21, 8
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %4, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

declare void @__quantum__rt__array_update_alias_count(%Array*, i64)

declare void @__quantum__qis__s__ctl(%Array*, %Qubit*)

declare void @__quantum__qis__z__ctl(%Array*, %Qubit*)

declare void @__quantum__qis__s__ctladj(%Array*, %Qubit*)

declare void @__quantum__qis__x__ctl(%Array*, %Qubit*)

declare void @__quantum__qis__h__ctl(%Array*, %Qubit*)

define void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__ctladj(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %op = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %2 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 1)
  %3 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %target = load %Qubit*, %Qubit** %3
  %__qsVar0__cOp__ = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__CanonicalForm1C__body({ i64, i64, i64, i64 }* %op)
  %4 = bitcast { i64, i64, i64, i64 }* %__qsVar0__cOp__ to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %4, i64 1)
  %5 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 3
  %6 = load i64, i64* %5
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 0
  %8 = load i64, i64* %7
  %9 = mul i64 3, %8
  %10 = add i64 %6, %9
  %"__qsVar1__actual?__" = srem i64 %10, 8
  %11 = sub i64 %8, 1
  %12 = udiv i64 %11, 1
  %13 = mul i64 1, %12
  %14 = add i64 1, %13
  %15 = load %Range, %Range* @EmptyRange
  %16 = insertvalue %Range %15, i64 %14, 0
  %17 = insertvalue %Range %16, i64 -1, 1
  %18 = insertvalue %Range %17, i64 1, 2
  %19 = extractvalue %Range %18, 0
  %20 = extractvalue %Range %18, 1
  %21 = extractvalue %Range %18, 2
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  %22 = icmp sgt i64 %20, 0
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %23 = phi i64 [ %19, %preheader__1 ], [ %27, %exiting__1 ]
  %24 = icmp sle i64 %23, %21
  %25 = icmp sge i64 %23, %21
  %26 = select i1 %22, i1 %24, i1 %25
  br i1 %26, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %27 = add i64 %23, %20
  br label %header__1

exit__1:                                          ; preds = %header__1
  %28 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 1
  %29 = load i64, i64* %28
  %30 = icmp eq i64 %29, 1
  br i1 %30, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %exit__1
  %31 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %__qsVar0__cOp__, i64 0, i32 2
  %32 = load i64, i64* %31
  %33 = icmp eq i64 %32, 1
  br i1 %33, label %then0__2, label %test1__1

then0__2:                                         ; preds = %continue__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__2

test1__1:                                         ; preds = %continue__1
  %34 = icmp eq i64 %32, 2
  br i1 %34, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__2

test2__1:                                         ; preds = %test1__1
  %35 = icmp eq i64 %32, 3
  br i1 %35, label %then2__1, label %continue__2

then2__1:                                         ; preds = %test2__1
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %target)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  br label %continue__2

continue__2:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__2
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %4, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__body({ i64, i64, i64, i64 }* %op, %Qubit* %target) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  call void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__body({ i64, i64, i64, i64 }* %op, %Qubit* %target)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__adj({ i64, i64, i64, i64 }* %op, %Qubit* %target) {
entry:
  %0 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Inverse1C__body({ i64, i64, i64, i64 }* %op)
  call void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__body({ i64, i64, i64, i64 }* %1, %Qubit* %target)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  %2 = bitcast { i64, i64, i64, i64 }* %1 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %2, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__ctl(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %op = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %2 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 1)
  %3 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %target = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %5 = bitcast %Tuple* %4 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %6 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %5, i64 0, i32 0
  %7 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %5, i64 0, i32 1
  store { i64, i64, i64, i64 }* %op, { i64, i64, i64, i64 }** %6
  store %Qubit* %target, %Qubit** %7
  call void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__ctl(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__ctladj(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %0) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %op = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %2 = bitcast { i64, i64, i64, i64 }* %op to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 1)
  %3 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %target = load %Qubit*, %Qubit** %3
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %5 = bitcast %Tuple* %4 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %6 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %5, i64 0, i32 0
  %7 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %5, i64 0, i32 1
  %8 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Inverse1C__body({ i64, i64, i64, i64 }* %op)
  store { i64, i64, i64, i64 }* %8, { i64, i64, i64, i64 }** %6
  store %Qubit* %target, %Qubit** %7
  call void @Microsoft__Quantum__Synthesis__ApplyDirectly1C__ctl(%Array* %__controlQubits__, { { i64, i64, i64, i64 }*, %Qubit* }* %5)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %2, i64 -1)
  %9 = bitcast { i64, i64, i64, i64 }* %8 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %9, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %4, i64 -1)
  ret void
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Identity1C__body() {
entry:
  %0 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 0, i64 0, i64 0, i64 0)
  ret { i64, i64, i64, i64 }* %0
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall__body(%Callable* %fn, { i64, i64, i64, i64 }* %right, { i64, i64, i64, i64 }* %left) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %fn, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %fn, i64 1)
  %0 = bitcast { i64, i64, i64, i64 }* %right to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = bitcast { i64, i64, i64, i64 }* %left to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 1)
  %2 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %3 = bitcast %Tuple* %2 to { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %4 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %3, i64 0, i32 0
  %5 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %3, i64 0, i32 1
  store { i64, i64, i64, i64 }* %left, { i64, i64, i64, i64 }** %4
  store { i64, i64, i64, i64 }* %right, { i64, i64, i64, i64 }** %5
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %fn, %Tuple* %2, %Tuple* %6)
  %7 = bitcast %Tuple* %6 to { { i64, i64, i64, i64 }* }*
  %8 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %7, i64 0, i32 0
  %9 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %8
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %fn, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %fn, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %1, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %2, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  ret { i64, i64, i64, i64 }* %9
}

declare void @__quantum__rt__callable_memory_management(i32, %Callable*, i64)

declare void @__quantum__rt__callable_update_alias_count(%Callable*, i64)

declare void @__quantum__rt__callable_invoke(%Callable*, %Tuple*, %Tuple*)

define i64 @Microsoft__Quantum__Characterization__MeasureSingleQubitRBSequenceLength__body(i64 %nOperators, i64 %nSequences) {
entry:
  %nUp = alloca i64
  store i64 0, i64* %nUp
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %idxSequence = phi i64 [ 1, %entry ], [ %7, %exiting__1 ]
  %0 = icmp sle i64 %idxSequence, %nSequences
  br i1 %0, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  %1 = load i64, i64* %nUp
  %2 = call %Result* @Microsoft__Quantum__Characterization__MeasureSingleQubitRBSequence__body(i64 %nOperators)
  %3 = load %Result*, %Result** @ResultZero
  %4 = call i1 @__quantum__rt__result_equal(%Result* %2, %Result* %3)
  %5 = select i1 %4, i64 1, i64 0
  %6 = add i64 %1, %5
  store i64 %6, i64* %nUp
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__result_update_reference_count(%Result* %2, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %7 = add i64 %idxSequence, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %8 = load i64, i64* %nUp
  ret i64 %8
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

define %Result* @Microsoft__Quantum__Characterization__MeasureSingleQubitRBSequence__body(i64 %nOperators) {
entry:
  %q = call %Qubit* @__quantum__rt__qubit_allocate()
  %0 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %1 = bitcast %Tuple* %0 to { %Callable*, %Qubit* }*
  %2 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %1, i64 0, i32 0
  %3 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %1, i64 0, i32 1
  %4 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Synthesis__Apply1C, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %4, %Callable** %2
  store %Qubit* %q, %Qubit** %3
  %5 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__2, [2 x void (%Tuple*, i64)*]* @MemoryManagement__2, %Tuple* %0)
  %6 = call %Array* @Microsoft__Quantum__Characterization__DrawRandomSingleQubitRBSequence__body(i64 %nOperators)
  call void @Microsoft__Quantum__Canon___a4ef41c67b3046139bab7031b2c4a59f_ApplyToEach__body(%Callable* %5, %Array* %6)
  %7 = call %Result* @Microsoft__Quantum__Measurement__MResetZ__body(%Qubit* %q)
  call void @__quantum__rt__qubit_release(%Qubit* %q)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %5, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %5, i64 -1)
  %8 = call i64 @__quantum__rt__array_get_size_1d(%Array* %6)
  %9 = sub i64 %8, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %10 = phi i64 [ 0, %entry ], [ %16, %exiting__1 ]
  %11 = icmp sle i64 %10, %9
  br i1 %11, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %6, i64 %10)
  %13 = bitcast i8* %12 to { i64, i64, i64, i64 }**
  %14 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %13
  %15 = bitcast { i64, i64, i64, i64 }* %14 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %15, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %16 = add i64 %10, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_reference_count(%Array* %6, i64 -1)
  ret %Result* %7
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release(%Qubit*)

declare void @__quantum__rt__result_update_reference_count(%Result*, i64)

define %Array* @Microsoft__Quantum__Characterization__DrawRandomSingleQubitRBSequence__body(i64 %nOperators) {
entry:
  %0 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Random__DrawRandomSingleQubitClifford, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %1 = sub i64 %nOperators, 1
  %root = call %Array* @Microsoft__Quantum__Arrays___219deda89b8f48a7aed55f2ff421793d_DrawMany__body(%Callable* %0, i64 %1, %Tuple* null)
  %2 = call i64 @__quantum__rt__array_get_size_1d(%Array* %root)
  %3 = sub i64 %2, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %4 = phi i64 [ 0, %entry ], [ %10, %exiting__1 ]
  %5 = icmp sle i64 %4, %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %root, i64 %4)
  %7 = bitcast i8* %6 to { i64, i64, i64, i64 }**
  %8 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %7
  %9 = bitcast { i64, i64, i64, i64 }* %8 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %9, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %10 = add i64 %4, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %root, i64 1)
  %11 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %12 = bitcast %Tuple* %11 to { %Callable*, %Callable* }*
  %13 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %12, i64 0, i32 0
  %14 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %12, i64 0, i32 1
  %15 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  %16 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @Microsoft__Quantum__Synthesis__Times1C, [2 x void (%Tuple*, i64)*]* null, %Tuple* null)
  store %Callable* %15, %Callable** %13
  store %Callable* %16, %Callable** %14
  %17 = call %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]* @PartialApplication__1, [2 x void (%Tuple*, i64)*]* @MemoryManagement__1, %Tuple* %11)
  %18 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Identity1C__body()
  %product = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Arrays___3105249e0272475dbb8dc712435f219f_Fold__body(%Callable* %17, { i64, i64, i64, i64 }* %18, %Array* %root)
  %19 = bitcast { i64, i64, i64, i64 }* %product to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %19, i64 1)
  %20 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %20, i64 0)
  %22 = bitcast i8* %21 to { i64, i64, i64, i64 }**
  %23 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Inverse1C__body({ i64, i64, i64, i64 }* %product)
  store { i64, i64, i64, i64 }* %23, { i64, i64, i64, i64 }** %22
  %24 = call %Array* @__quantum__rt__array_concatenate(%Array* %root, %Array* %20)
  %25 = sub i64 %2, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %26 = phi i64 [ 0, %exit__1 ], [ %32, %exiting__2 ]
  %27 = icmp sle i64 %26, %25
  br i1 %27, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %root, i64 %26)
  %29 = bitcast i8* %28 to { i64, i64, i64, i64 }**
  %30 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %29
  %31 = bitcast { i64, i64, i64, i64 }* %30 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %31, i64 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %32 = add i64 %26, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %root, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %19, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %0, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %0, i64 -1)
  %33 = sub i64 %2, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %34 = phi i64 [ 0, %exit__2 ], [ %40, %exiting__3 ]
  %35 = icmp sle i64 %34, %33
  br i1 %35, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %36 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %root, i64 %34)
  %37 = bitcast i8* %36 to { i64, i64, i64, i64 }**
  %38 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %37
  %39 = bitcast { i64, i64, i64, i64 }* %38 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %39, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %40 = add i64 %34, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_reference_count(%Array* %root, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %17, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %17, i64 -1)
  %41 = bitcast { i64, i64, i64, i64 }* %18 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %41, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %19, i64 -1)
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %42 = phi i64 [ 0, %exit__3 ], [ %48, %exiting__4 ]
  %43 = icmp sle i64 %42, 0
  br i1 %43, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %44 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %20, i64 %42)
  %45 = bitcast i8* %44 to { i64, i64, i64, i64 }**
  %46 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %45
  %47 = bitcast { i64, i64, i64, i64 }* %46 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %47, i64 -1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %48 = add i64 %42, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  call void @__quantum__rt__array_update_reference_count(%Array* %20, i64 -1)
  ret %Array* %24
}

define %Array* @Microsoft__Quantum__Arrays___219deda89b8f48a7aed55f2ff421793d_DrawMany__body(%Callable* %op, i64 %nSamples, %Tuple* %input) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 1)
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %nSamples)
  %1 = sub i64 %nSamples, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %12, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i64* getelementptr (i64, i64* null, i32 1) to i64), i64 4))
  %5 = bitcast %Tuple* %4 to { i64, i64, i64, i64 }*
  %6 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %5, i64 0, i32 0
  %7 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %5, i64 0, i32 1
  %8 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %5, i64 0, i32 2
  %9 = getelementptr { i64, i64, i64, i64 }, { i64, i64, i64, i64 }* %5, i64 0, i32 3
  store i64 0, i64* %6
  store i64 0, i64* %7
  store i64 0, i64* %8
  store i64 0, i64* %9
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %2)
  %11 = bitcast i8* %10 to { i64, i64, i64, i64 }**
  store { i64, i64, i64, i64 }* %5, { i64, i64, i64, i64 }** %11
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %12 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %outputs = alloca %Array*
  store %Array* %0, %Array** %outputs
  %13 = sub i64 %nSamples, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %14 = phi i64 [ 0, %exit__1 ], [ %20, %exiting__2 ]
  %15 = icmp sle i64 %14, %13
  br i1 %15, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %16 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %14)
  %17 = bitcast i8* %16 to { i64, i64, i64, i64 }**
  %18 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %17
  %19 = bitcast { i64, i64, i64, i64 }* %18 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %19, i64 1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %20 = add i64 %14, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %0, i64 1)
  %21 = sub i64 %nSamples, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %22 = phi i64 [ 0, %exit__2 ], [ %28, %exiting__3 ]
  %23 = icmp sle i64 %22, %21
  br i1 %23, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %22)
  %25 = bitcast i8* %24 to { i64, i64, i64, i64 }**
  %26 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %25
  %27 = bitcast { i64, i64, i64, i64 }* %26 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %27, i64 1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %28 = add i64 %22, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 1)
  %29 = sub i64 %nSamples, 1
  br label %header__4

header__4:                                        ; preds = %exiting__4, %exit__3
  %idx = phi i64 [ 0, %exit__3 ], [ %42, %exiting__4 ]
  %30 = icmp sle i64 %idx, %29
  br i1 %30, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %31 = load %Array*, %Array** %outputs
  call void @__quantum__rt__array_update_alias_count(%Array* %31, i64 -1)
  %32 = call %Array* @__quantum__rt__array_copy(%Array* %31, i1 false)
  %33 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %op, %Tuple* null, %Tuple* %33)
  %34 = bitcast %Tuple* %33 to { { i64, i64, i64, i64 }* }*
  %35 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %34, i64 0, i32 0
  %36 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %35
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %32, i64 %idx)
  %38 = bitcast i8* %37 to { i64, i64, i64, i64 }**
  %39 = bitcast { i64, i64, i64, i64 }* %36 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %39, i64 1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %39, i64 1)
  %40 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %38
  %41 = bitcast { i64, i64, i64, i64 }* %40 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %41, i64 -1)
  store { i64, i64, i64, i64 }* %36, { i64, i64, i64, i64 }** %38
  call void @__quantum__rt__array_update_reference_count(%Array* %32, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %32, i64 1)
  store %Array* %32, %Array** %outputs
  call void @__quantum__rt__array_update_reference_count(%Array* %31, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %39, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %33, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %41, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %32, i64 -1)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %42 = add i64 %idx, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %43 = load %Array*, %Array** %outputs
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %op, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %op, i64 -1)
  %44 = call i64 @__quantum__rt__array_get_size_1d(%Array* %43)
  %45 = sub i64 %44, 1
  br label %header__5

header__5:                                        ; preds = %exiting__5, %exit__4
  %46 = phi i64 [ 0, %exit__4 ], [ %52, %exiting__5 ]
  %47 = icmp sle i64 %46, %45
  br i1 %47, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %43, i64 %46)
  %49 = bitcast i8* %48 to { i64, i64, i64, i64 }**
  %50 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %49
  %51 = bitcast { i64, i64, i64, i64 }* %50 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %51, i64 -1)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %52 = add i64 %46, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  call void @__quantum__rt__array_update_alias_count(%Array* %43, i64 -1)
  %53 = sub i64 %nSamples, 1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %exit__5
  %54 = phi i64 [ 0, %exit__5 ], [ %60, %exiting__6 ]
  %55 = icmp sle i64 %54, %53
  br i1 %55, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 %54)
  %57 = bitcast i8* %56 to { i64, i64, i64, i64 }**
  %58 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %57
  %59 = bitcast { i64, i64, i64, i64 }* %58 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %59, i64 -1)
  br label %exiting__6

exiting__6:                                       ; preds = %body__6
  %60 = add i64 %54, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_update_reference_count(%Array* %0, i64 -1)
  ret %Array* %43
}

define void @Microsoft__Quantum__Random__DrawRandomSingleQubitClifford__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Random__DrawRandomSingleQubitClifford__body()
  %1 = bitcast %Tuple* %result-tuple to { { i64, i64, i64, i64 }* }*
  %2 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %1, i64 0, i32 0
  store { i64, i64, i64, i64 }* %0, { i64, i64, i64, i64 }** %2
  ret void
}

declare %Callable* @__quantum__rt__callable_create([4 x void (%Tuple*, %Tuple*, %Tuple*)*]*, [2 x void (%Tuple*, i64)*]*, %Tuple*)

declare i64 @__quantum__rt__array_get_size_1d(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Arrays___3105249e0272475dbb8dc712435f219f_Fold__body(%Callable* %folder, { i64, i64, i64, i64 }* %state, %Array* %array) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %folder, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %folder, i64 1)
  %0 = bitcast { i64, i64, i64, i64 }* %state to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  %1 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %2 = sub i64 %1, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %3 = phi i64 [ 0, %entry ], [ %9, %exiting__1 ]
  %4 = icmp sle i64 %3, %2
  br i1 %4, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %5 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %3)
  %6 = bitcast i8* %5 to { i64, i64, i64, i64 }**
  %7 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %6
  %8 = bitcast { i64, i64, i64, i64 }* %7 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %8, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %9 = add i64 %3, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %current = alloca { i64, i64, i64, i64 }*
  store { i64, i64, i64, i64 }* %state, { i64, i64, i64, i64 }** %current
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %0, i64 1)
  %10 = call %Range @Microsoft__Quantum__Arrays___e071bc1ab59e41a1ac06ff16f6819b41_IndexRange__body(%Array* %array)
  %11 = extractvalue %Range %10, 0
  %12 = extractvalue %Range %10, 1
  %13 = extractvalue %Range %10, 2
  br label %preheader__1

preheader__1:                                     ; preds = %exit__1
  %14 = icmp sgt i64 %12, 0
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__1
  %idxElement = phi i64 [ %11, %preheader__1 ], [ %32, %exiting__2 ]
  %15 = icmp sle i64 %idxElement, %13
  %16 = icmp sge i64 %idxElement, %13
  %17 = select i1 %14, i1 %15, i1 %16
  br i1 %17, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %18 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %19 = bitcast %Tuple* %18 to { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %20 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %19, i64 0, i32 0
  %21 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %19, i64 0, i32 1
  %22 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %current
  %23 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %idxElement)
  %24 = bitcast i8* %23 to { i64, i64, i64, i64 }**
  %25 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %24
  store { i64, i64, i64, i64 }* %22, { i64, i64, i64, i64 }** %20
  store { i64, i64, i64, i64 }* %25, { i64, i64, i64, i64 }** %21
  %26 = call %Tuple* @__quantum__rt__tuple_create(i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64))
  call void @__quantum__rt__callable_invoke(%Callable* %folder, %Tuple* %18, %Tuple* %26)
  %27 = bitcast %Tuple* %26 to { { i64, i64, i64, i64 }* }*
  %28 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %27, i64 0, i32 0
  %29 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %28
  %30 = bitcast { i64, i64, i64, i64 }* %29 to %Tuple*
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %30, i64 1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %30, i64 1)
  %31 = bitcast { i64, i64, i64, i64 }* %22 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %31, i64 -1)
  store { i64, i64, i64, i64 }* %29, { i64, i64, i64, i64 }** %current
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %18, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %30, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %26, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %31, i64 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %32 = add i64 %idxElement, %12
  br label %header__2

exit__2:                                          ; preds = %header__2
  %33 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %current
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %folder, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %folder, i64 -1)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %0, i64 -1)
  %34 = sub i64 %1, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %35 = phi i64 [ 0, %exit__2 ], [ %41, %exiting__3 ]
  %36 = icmp sle i64 %35, %34
  br i1 %36, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %37 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %35)
  %38 = bitcast i8* %37 to { i64, i64, i64, i64 }**
  %39 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %38
  %40 = bitcast { i64, i64, i64, i64 }* %39 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %40, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %41 = add i64 %35, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  %42 = bitcast { i64, i64, i64, i64 }* %33 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %42, i64 -1)
  ret { i64, i64, i64, i64 }* %33
}

define void @Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %1 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 1
  %3 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 2
  %4 = load %Callable*, %Callable** %1
  %5 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %2
  %6 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %3
  %7 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Characterization___b398c2dd87114340b44ecdf33d8203d0_FlippedCall__body(%Callable* %4, { i64, i64, i64, i64 }* %5, { i64, i64, i64, i64 }* %6)
  %8 = bitcast %Tuple* %result-tuple to { { i64, i64, i64, i64 }* }*
  %9 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %8, i64 0, i32 0
  store { i64, i64, i64, i64 }* %7, { i64, i64, i64, i64 }** %9
  ret void
}

define void @Microsoft__Quantum__Synthesis__Times1C__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %1 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 1
  %3 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %4 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %2
  %5 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__Times1C__body({ i64, i64, i64, i64 }* %3, { i64, i64, i64, i64 }* %4)
  %6 = bitcast %Tuple* %result-tuple to { { i64, i64, i64, i64 }* }*
  %7 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %6, i64 0, i32 0
  store { i64, i64, i64, i64 }* %5, { i64, i64, i64, i64 }** %7
  ret void
}

define void @Lifted__PartialApplication__1__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable* }*
  %1 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 1
  %2 = load %Callable*, %Callable** %1
  %3 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %4 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %3, i64 0, i32 0
  %5 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %4
  %6 = getelementptr { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %3, i64 0, i32 1
  %7 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 3))
  %9 = bitcast %Tuple* %8 to { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }*
  %10 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %9, i64 0, i32 0
  %11 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %9, i64 0, i32 1
  %12 = getelementptr { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }, { %Callable*, { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }* }* %9, i64 0, i32 2
  store %Callable* %2, %Callable** %10
  store { i64, i64, i64, i64 }* %5, { i64, i64, i64, i64 }** %11
  store { i64, i64, i64, i64 }* %7, { i64, i64, i64, i64 }** %12
  %13 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 0
  %14 = load %Callable*, %Callable** %13
  call void @__quantum__rt__callable_invoke(%Callable* %14, %Tuple* %8, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  ret void
}

define void @MemoryManagement__1__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable* }*
  %1 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  %3 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 1
  %4 = load %Callable*, %Callable** %3
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %4, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %4, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__1__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Callable* }*
  %1 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  %3 = getelementptr { %Callable*, %Callable* }, { %Callable*, %Callable* }* %0, i64 0, i32 1
  %4 = load %Callable*, %Callable** %3
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %4, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %4, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Array* @__quantum__rt__array_concatenate(%Array*, %Array*)

declare void @__quantum__rt__callable_update_reference_count(%Callable*, i64)

declare void @__quantum__rt__array_update_reference_count(%Array*, i64)

define void @Microsoft__Quantum__Canon___a4ef41c67b3046139bab7031b2c4a59f_ApplyToEach__body(%Callable* %singleElementOperation, %Array* %register) {
entry:
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %singleElementOperation, i64 1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %singleElementOperation, i64 1)
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %register)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %8, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %2)
  %5 = bitcast i8* %4 to { i64, i64, i64, i64 }**
  %6 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %5
  %7 = bitcast { i64, i64, i64, i64 }* %6 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %7, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %8 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 1)
  %9 = call %Range @Microsoft__Quantum__Arrays___e071bc1ab59e41a1ac06ff16f6819b41_IndexRange__body(%Array* %register)
  %10 = extractvalue %Range %9, 0
  %11 = extractvalue %Range %9, 1
  %12 = extractvalue %Range %9, 2
  br label %preheader__1

preheader__1:                                     ; preds = %exit__1
  %13 = icmp sgt i64 %11, 0
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__1
  %idxQubit = phi i64 [ %10, %preheader__1 ], [ %21, %exiting__2 ]
  %14 = icmp sle i64 %idxQubit, %12
  %15 = icmp sge i64 %idxQubit, %12
  %16 = select i1 %13, i1 %14, i1 %15
  br i1 %16, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %idxQubit)
  %18 = bitcast i8* %17 to { i64, i64, i64, i64 }**
  %19 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %18
  %20 = bitcast { i64, i64, i64, i64 }* %19 to %Tuple*
  call void @__quantum__rt__callable_invoke(%Callable* %singleElementOperation, %Tuple* %20, %Tuple* null)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %21 = add i64 %idxQubit, %11
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %singleElementOperation, i64 -1)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %singleElementOperation, i64 -1)
  %22 = sub i64 %0, 1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %exit__2
  %23 = phi i64 [ 0, %exit__2 ], [ %29, %exiting__3 ]
  %24 = icmp sle i64 %23, %22
  br i1 %24, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %25 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %23)
  %26 = bitcast i8* %25 to { i64, i64, i64, i64 }**
  %27 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %26
  %28 = bitcast { i64, i64, i64, i64 }* %27 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %28, i64 -1)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %29 = add i64 %23, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  call void @__quantum__rt__array_update_alias_count(%Array* %register, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }*, %Qubit* }*
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %3 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Synthesis__Apply1C__body({ i64, i64, i64, i64 }* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }*, %Qubit* }*
  %1 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 0
  %2 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %0, i64 0, i32 1
  %3 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %4 = load %Qubit*, %Qubit** %2
  call void @Microsoft__Quantum__Synthesis__Apply1C__adj({ i64, i64, i64, i64 }* %3, %Qubit* %4)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }*
  %1 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { { i64, i64, i64, i64 }*, %Qubit* }*, { { i64, i64, i64, i64 }*, %Qubit* }** %2
  call void @Microsoft__Quantum__Synthesis__Apply1C__ctl(%Array* %3, { { i64, i64, i64, i64 }*, %Qubit* }* %4)
  ret void
}

define void @Microsoft__Quantum__Synthesis__Apply1C__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }*
  %1 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { { i64, i64, i64, i64 }*, %Qubit* }*, { { i64, i64, i64, i64 }*, %Qubit* }** %2
  call void @Microsoft__Quantum__Synthesis__Apply1C__ctladj(%Array* %3, { { i64, i64, i64, i64 }*, %Qubit* }* %4)
  ret void
}

define void @Lifted__PartialApplication__2__body__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }* }*
  %1 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %4 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %3, i64 0, i32 1
  %5 = load %Qubit*, %Qubit** %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %7 = bitcast %Tuple* %6 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %8 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %7, i64 0, i32 0
  %9 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %7, i64 0, i32 1
  store { i64, i64, i64, i64 }* %2, { i64, i64, i64, i64 }** %8
  store %Qubit* %5, %Qubit** %9
  %10 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %3, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  call void @__quantum__rt__callable_invoke(%Callable* %11, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__2__adj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { { i64, i64, i64, i64 }* }*
  %1 = getelementptr { { i64, i64, i64, i64 }* }, { { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %1
  %3 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %4 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %3, i64 0, i32 1
  %5 = load %Qubit*, %Qubit** %4
  %6 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %7 = bitcast %Tuple* %6 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %8 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %7, i64 0, i32 0
  %9 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %7, i64 0, i32 1
  store { i64, i64, i64, i64 }* %2, { i64, i64, i64, i64 }** %8
  store %Qubit* %5, %Qubit** %9
  %10 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %3, i64 0, i32 0
  %11 = load %Callable*, %Callable** %10
  %12 = call %Callable* @__quantum__rt__callable_copy(%Callable* %11, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %12)
  call void @__quantum__rt__callable_invoke(%Callable* %12, %Tuple* %6, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %6, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %12, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %12, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__2__ctl__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i64, i64, i64, i64 }* }*
  %1 = getelementptr { %Array*, { i64, i64, i64, i64 }* }, { %Array*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { i64, i64, i64, i64 }* }, { %Array*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %6 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %5, i64 0, i32 1
  %7 = load %Qubit*, %Qubit** %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %9 = bitcast %Tuple* %8 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %10 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %9, i64 0, i32 0
  %11 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %9, i64 0, i32 1
  store { i64, i64, i64, i64 }* %4, { i64, i64, i64, i64 }** %10
  store %Qubit* %7, %Qubit** %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }*
  %14 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %13, i64 0, i32 0
  %15 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %13, i64 0, i32 1
  store %Array* %3, %Array** %14
  store { { i64, i64, i64, i64 }*, %Qubit* }* %9, { { i64, i64, i64, i64 }*, %Qubit* }** %15
  %16 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 1)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %18, i64 -1)
  ret void
}

define void @Lifted__PartialApplication__2__ctladj__wrapper(%Tuple* %capture-tuple, %Tuple* %arg-tuple, %Tuple* %result-tuple) {
entry:
  %0 = bitcast %Tuple* %arg-tuple to { %Array*, { i64, i64, i64, i64 }* }*
  %1 = getelementptr { %Array*, { i64, i64, i64, i64 }* }, { %Array*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 0
  %2 = getelementptr { %Array*, { i64, i64, i64, i64 }* }, { %Array*, { i64, i64, i64, i64 }* }* %0, i64 0, i32 1
  %3 = load %Array*, %Array** %1
  %4 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %2
  %5 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %6 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %5, i64 0, i32 1
  %7 = load %Qubit*, %Qubit** %6
  %8 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %9 = bitcast %Tuple* %8 to { { i64, i64, i64, i64 }*, %Qubit* }*
  %10 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %9, i64 0, i32 0
  %11 = getelementptr { { i64, i64, i64, i64 }*, %Qubit* }, { { i64, i64, i64, i64 }*, %Qubit* }* %9, i64 0, i32 1
  store { i64, i64, i64, i64 }* %4, { i64, i64, i64, i64 }** %10
  store %Qubit* %7, %Qubit** %11
  %12 = call %Tuple* @__quantum__rt__tuple_create(i64 mul nuw (i64 ptrtoint (i1** getelementptr (i1*, i1** null, i32 1) to i64), i64 2))
  %13 = bitcast %Tuple* %12 to { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }*
  %14 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %13, i64 0, i32 0
  %15 = getelementptr { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }, { %Array*, { { i64, i64, i64, i64 }*, %Qubit* }* }* %13, i64 0, i32 1
  store %Array* %3, %Array** %14
  store { { i64, i64, i64, i64 }*, %Qubit* }* %9, { { i64, i64, i64, i64 }*, %Qubit* }** %15
  %16 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %5, i64 0, i32 0
  %17 = load %Callable*, %Callable** %16
  %18 = call %Callable* @__quantum__rt__callable_copy(%Callable* %17, i1 false)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 1)
  call void @__quantum__rt__callable_make_adjoint(%Callable* %18)
  call void @__quantum__rt__callable_make_controlled(%Callable* %18)
  call void @__quantum__rt__callable_invoke(%Callable* %18, %Tuple* %12, %Tuple* %result-tuple)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %8, i64 -1)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %12, i64 -1)
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %18, i64 -1)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %18, i64 -1)
  ret void
}

define void @MemoryManagement__2__RefCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %1 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 0, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_reference_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_reference_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define void @MemoryManagement__2__AliasCount(%Tuple* %capture-tuple, i64 %count-change) {
entry:
  %0 = bitcast %Tuple* %capture-tuple to { %Callable*, %Qubit* }*
  %1 = getelementptr { %Callable*, %Qubit* }, { %Callable*, %Qubit* }* %0, i64 0, i32 0
  %2 = load %Callable*, %Callable** %1
  call void @__quantum__rt__callable_memory_management(i32 1, %Callable* %2, i64 %count-change)
  call void @__quantum__rt__callable_update_alias_count(%Callable* %2, i64 %count-change)
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %capture-tuple, i64 %count-change)
  ret void
}

define %Result* @Microsoft__Quantum__Measurement__MResetZ__body(%Qubit* %target) {
entry:
  %result = call %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %target)
  %0 = load %Result*, %Result** @ResultOne
  %1 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %0)
  br i1 %1, label %then0__1, label %continue__1

then0__1:                                         ; preds = %entry
  call void @__quantum__qis__x__body(%Qubit* %target)
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %entry
  ret %Result* %result
}

define { i64, i64, i64, i64 }* @Microsoft__Quantum__Random__DrawRandomSingleQubitClifford__body() {
entry:
  %0 = call i64 @__quantum__qis__drawrandomint__body(i64 0, i64 2)
  %1 = call i64 @__quantum__qis__drawrandomint__body(i64 0, i64 1)
  %2 = call i64 @__quantum__qis__drawrandomint__body(i64 0, i64 3)
  %3 = call i64 @__quantum__qis__drawrandomint__body(i64 0, i64 7)
  %4 = call { i64, i64, i64, i64 }* @Microsoft__Quantum__Synthesis__SingleQubitClifford__body(i64 %0, i64 %1, i64 %2, i64 %3)
  ret { i64, i64, i64, i64 }* %4
}

declare i64 @__quantum__qis__drawrandomint__body(i64, i64)

define i64 @Microsoft__Quantum__Random__DrawRandomInt__body(i64 %min, i64 %max) {
entry:
  %0 = call i64 @__quantum__qis__drawrandomint__body(i64 %min, i64 %max)
  ret i64 %0
}

define void @Microsoft__Quantum__Experimental__RunRBExperiment__body() #0 {
entry:
  %sequenceLengths = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 3)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %sequenceLengths, i64 0)
  %1 = bitcast i8* %0 to i64*
  %2 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %sequenceLengths, i64 1)
  %3 = bitcast i8* %2 to i64*
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %sequenceLengths, i64 2)
  %5 = bitcast i8* %4 to i64*
  store i64 10, i64* %1
  store i64 100, i64* %3
  store i64 1000, i64* %5
  call void @__quantum__rt__array_update_alias_count(%Array* %sequenceLengths, i64 1)
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %idxLength = phi i64 [ 0, %entry ], [ %15, %exiting__1 ]
  %6 = icmp sle i64 %idxLength, 2
  br i1 %6, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %7 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %sequenceLengths, i64 %idxLength)
  %8 = bitcast i8* %7 to i64*
  %length = load i64, i64* %8
  %survivalAtLength = call i64 @Microsoft__Quantum__Characterization__MeasureSingleQubitRBSequenceLength__body(i64 %length, i64 500)
  %9 = call %String* @__quantum__rt__string_create(i32 19, i8* getelementptr inbounds ([20 x i8], [20 x i8]* @1, i32 0, i32 0))
  %10 = call %String* @__quantum__rt__int_to_string(i64 %length)
  %11 = call %String* @__quantum__rt__string_concatenate(%String* %9, %String* %10)
  call void @__quantum__rt__string_update_reference_count(%String* %9, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %10, i64 -1)
  %12 = call %String* @__quantum__rt__string_create(i32 2, i8* getelementptr inbounds ([3 x i8], [3 x i8]* @2, i32 0, i32 0))
  %13 = call %String* @__quantum__rt__string_concatenate(%String* %11, %String* %12)
  call void @__quantum__rt__string_update_reference_count(%String* %11, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %12, i64 -1)
  %14 = call %String* @__quantum__rt__int_to_string(i64 %survivalAtLength)
  %msg = call %String* @__quantum__rt__string_concatenate(%String* %13, %String* %14)
  call void @__quantum__rt__string_update_reference_count(%String* %13, i64 -1)
  call void @__quantum__rt__string_update_reference_count(%String* %14, i64 -1)
  call void @__quantum__qis__message__body(%String* %msg)
  call void @__quantum__rt__string_update_reference_count(%String* %msg, i64 -1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %15 = add i64 %idxLength, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %sequenceLengths, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %sequenceLengths, i64 -1)
  ret void
}

declare %String* @__quantum__rt__int_to_string(i64)

declare %String* @__quantum__rt__string_concatenate(%String*, %String*)

declare void @__quantum__qis__message__body(%String*)

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__x__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__x__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__s__adj(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__s__ctladj(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Message__body(%String* %msg) {
entry:
  call void @__quantum__qis__message__body(%String* %msg)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %0 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  ret %Result* %0
}

declare %Result* @__quantum__qis__measure__body(%Array*, %Array*)

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__h__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__h__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define %Result* @Microsoft__Quantum__Intrinsic__M__body(%Qubit* %qubit) {
entry:
  %bases = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 1)
  %0 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %bases, i64 0)
  %1 = bitcast i8* %0 to i2*
  %2 = load i2, i2* @PauliZ
  store i2 %2, i2* %1
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 1)
  %qubits = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 0)
  %4 = bitcast i8* %3 to %Qubit**
  store %Qubit* %qubit, %Qubit** %4
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 1)
  %5 = call %Result* @__quantum__qis__measure__body(%Array* %bases, %Array* %qubits)
  call void @__quantum__rt__array_update_alias_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_alias_count(%Array* %qubits, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %bases, i64 -1)
  call void @__quantum__rt__array_update_reference_count(%Array* %qubits, i64 -1)
  ret %Result* %5
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__adj(%Qubit* %qubit) {
entry:
  call void @__quantum__qis__z__body(%Qubit* %qubit)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctl(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__ctladj(%Array* %__controlQubits__, %Qubit* %qubit) {
entry:
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 1)
  call void @__quantum__qis__z__ctl(%Array* %__controlQubits__, %Qubit* %qubit)
  call void @__quantum__rt__array_update_alias_count(%Array* %__controlQubits__, i64 -1)
  ret void
}

define %Range @Microsoft__Quantum__Arrays___e071bc1ab59e41a1ac06ff16f6819b41_IndexRange__body(%Array* %array) {
entry:
  %0 = call i64 @__quantum__rt__array_get_size_1d(%Array* %array)
  %1 = sub i64 %0, 1
  br label %header__1

header__1:                                        ; preds = %exiting__1, %entry
  %2 = phi i64 [ 0, %entry ], [ %8, %exiting__1 ]
  %3 = icmp sle i64 %2, %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %2)
  %5 = bitcast i8* %4 to { i64, i64, i64, i64 }**
  %6 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %5
  %7 = bitcast { i64, i64, i64, i64 }* %6 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %7, i64 1)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %8 = add i64 %2, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 1)
  %9 = sub i64 %0, 1
  %10 = load %Range, %Range* @EmptyRange
  %11 = insertvalue %Range %10, i64 0, 0
  %12 = insertvalue %Range %11, i64 1, 1
  %13 = insertvalue %Range %12, i64 %9, 2
  %14 = sub i64 %0, 1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %exit__1
  %15 = phi i64 [ 0, %exit__1 ], [ %21, %exiting__2 ]
  %16 = icmp sle i64 %15, %14
  br i1 %16, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %array, i64 %15)
  %18 = bitcast i8* %17 to { i64, i64, i64, i64 }**
  %19 = load { i64, i64, i64, i64 }*, { i64, i64, i64, i64 }** %18
  %20 = bitcast { i64, i64, i64, i64 }* %19 to %Tuple*
  call void @__quantum__rt__tuple_update_alias_count(%Tuple* %20, i64 -1)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %21 = add i64 %15, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_update_alias_count(%Array* %array, i64 -1)
  ret %Range %13
}

declare %Array* @__quantum__rt__array_copy(%Array*, i1)

declare %Callable* @__quantum__rt__callable_copy(%Callable*, i1)

declare void @__quantum__rt__callable_make_adjoint(%Callable*)

declare void @__quantum__rt__callable_make_controlled(%Callable*)

attributes #0 = { "EntryPoint" }
