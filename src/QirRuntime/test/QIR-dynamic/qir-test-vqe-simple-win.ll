
%Result = type opaque
%Range = type { i64, i64, i64 }
%Qubit = type opaque
%Array = type opaque
%TupleHeader = type { i32 }
%String = type opaque

@ResultZero = external dllimport global %Result*
@ResultOne = external dllimport global %Result*

@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft_Quantum_Samples_Chemistry_SimpleVQE_GetEnergyHydrogenVQE = alias double (), double ()* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body

declare double @__quantum__qis__intAsDouble(i64)

declare void @__quantum__qis__cnot(%Qubit*, %Qubit*)

declare void @__quantum__qis__h(%Qubit*)

declare %Result* @__quantum__qis__mz(%Qubit*)

declare %Result* @__quantum__qis__measure(%Array*, %Array*)

declare void @__quantum__qis__rx(double, %Qubit*)

declare void @__quantum__qis__rz(double, %Qubit*)

declare void @__quantum__qis__s(%Qubit*)

declare void @__quantum__qis__x(%Qubit*)

declare void @__quantum__qis__z(%Qubit*)

define %TupleHeader* @Microsoft__Quantum__Core__Attribute__body() {
entry:
  ret %TupleHeader* null
}

define %TupleHeader* @Microsoft__Quantum__Core__EntryPoint__body() {
entry:
  ret %TupleHeader* null
}

define %TupleHeader* @Microsoft__Quantum__Core__Inline__body() {
entry:
  ret %TupleHeader* null
}

define { %TupleHeader, %String* }* @Microsoft__Quantum__Core__Intrinsic__body(%String* %arg0) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %String* }* getelementptr ({ %TupleHeader, %String* }, { %TupleHeader, %String* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %String* }*
  %2 = getelementptr inbounds { %TupleHeader, %String* }, { %TupleHeader, %String* }* %1, i32 0, i32 1
  store %String* %arg0, %String** %2
  call void @__quantum__rt__string_reference(%String* %arg0)
  ret { %TupleHeader, %String* }* %1
}

declare %TupleHeader* @__quantum__rt__tuple_create(i64)

declare void @__quantum__rt__string_reference(%String*)

declare i64 @Microsoft__Quantum__Core__Length__body(%Array*)

declare i64 @Microsoft__Quantum__Core__RangeEnd__body(%Range)

declare %Range @Microsoft__Quantum__Core__RangeReverse__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStart__body(%Range)

declare i64 @Microsoft__Quantum__Core__RangeStep__body(%Range)

declare double @Microsoft__Quantum__Instructions__IntAsDoubleImpl__body(i64)

declare void @Microsoft__Quantum__Instructions__PhysCNOT__body(%Qubit*, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysH__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysM__body(%Qubit*)

declare %Result* @Microsoft__Quantum__Instructions__PhysMeasure__body(%Array*, %Array*)

declare void @Microsoft__Quantum__Instructions__PhysRx__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysRz__body(double, %Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysS__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysX__body(%Qubit*)

declare void @Microsoft__Quantum__Instructions__PhysZ__body(%Qubit*)

define %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__ExpandedCoefficients__body(%Array* %coeff, i64 %termType) {
entry:
  %nCoeffs = alloca i64
  store i64 0, i64* %nCoeffs
  %0 = icmp eq i64 %termType, 2
  br i1 %0, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  store i64 2, i64* %nCoeffs
  br label %continue__1

test1__1:                                         ; preds = %entry
  %1 = icmp eq i64 %termType, 3
  br i1 %1, label %then1__1, label %else__1

then1__1:                                         ; preds = %test1__1
  store i64 8, i64* %nCoeffs
  br label %continue__1

else__1:                                          ; preds = %test1__1
  store i64 1, i64* %nCoeffs
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then1__1, %then0__1
  %2 = load i64, i64* %nCoeffs
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 %2)
  %coeffs = alloca %Array*
  store %Array* %3, %Array** %coeffs
  %4 = icmp eq i64 %termType, 0
  %5 = icmp eq i64 %termType, 1
  %6 = or i1 %4, %5
  br i1 %6, label %then0__2, label %test1__2

then0__2:                                         ; preds = %continue__1
  %7 = load %Array*, %Array** %coeffs
  %8 = call %Array* @__quantum__rt__array_copy(%Array* %7)
  %9 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeff, i64 0)
  %10 = bitcast i8* %9 to double*
  %11 = load double, double* %10
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %8, i64 0)
  %13 = bitcast i8* %12 to double*
  store double %11, double* %13
  store %Array* %8, %Array** %coeffs
  call void @__quantum__rt__array_reference(%Array* %8)
  call void @__quantum__rt__array_unreference(%Array* %8)
  br label %continue__2

test1__2:                                         ; preds = %continue__1
  %14 = icmp eq i64 %termType, 2
  %15 = icmp eq i64 %termType, 3
  %16 = or i1 %14, %15
  br i1 %16, label %then1__2, label %continue__2

then1__2:                                         ; preds = %test1__2
  %17 = load i64, i64* %nCoeffs
  %end__1 = sub i64 %17, 1
  br label %preheader__1

continue__2:                                      ; preds = %exit__1, %test1__2, %then0__2
  %18 = load %Array*, %Array** %coeffs
  call void @__quantum__rt__array_unreference(%Array* %3)
  ret %Array* %18

preheader__1:                                     ; preds = %then1__2
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %30, %exiting__1 ]
  %19 = icmp sge i64 %i, %end__1
  %20 = icmp sle i64 %i, %end__1
  %21 = select i1 true, i1 %20, i1 %19
  br i1 %21, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %22 = load %Array*, %Array** %coeffs
  %23 = call %Array* @__quantum__rt__array_copy(%Array* %22)
  %24 = udiv i64 %i, 2
  %25 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeff, i64 %24)
  %26 = bitcast i8* %25 to double*
  %27 = load double, double* %26
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %23, i64 %i)
  %29 = bitcast i8* %28 to double*
  store double %27, double* %29
  store %Array* %23, %Array** %coeffs
  call void @__quantum__rt__array_reference(%Array* %23)
  call void @__quantum__rt__array_unreference(%Array* %23)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %30 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  br label %continue__2
}

declare %Array* @__quantum__rt__array_create_1d(i32, i64)

declare %Array* @__quantum__rt__array_copy(%Array*)

declare i8* @__quantum__rt__array_get_element_ptr_1d(%Array*, i64)

declare void @__quantum__rt__array_reference(%Array*)

declare void @__quantum__rt__array_unreference(%Array*)

define %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__VQEMeasurementOperators__body(i64 %nQubits, %Array* %indices, i64 %termType) {
entry:
  %nOps = alloca i64
  store i64 0, i64* %nOps
  %0 = icmp eq i64 %termType, 2
  br i1 %0, label %then0__1, label %test1__1

then0__1:                                         ; preds = %entry
  store i64 2, i64* %nOps
  br label %continue__1

test1__1:                                         ; preds = %entry
  %1 = icmp eq i64 %termType, 3
  br i1 %1, label %then1__1, label %else__1

then1__1:                                         ; preds = %test1__1
  store i64 8, i64* %nOps
  br label %continue__1

else__1:                                          ; preds = %test1__1
  store i64 1, i64* %nOps
  br label %continue__1

continue__1:                                      ; preds = %else__1, %then1__1, %then0__1
  %2 = load i64, i64* %nOps
  %3 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 %2)
  %ops = alloca %Array*
  store %Array* %3, %Array** %ops
  %4 = icmp eq i64 %termType, 0
  %5 = icmp eq i64 %termType, 1
  %6 = or i1 %4, %5
  br i1 %6, label %then0__2, label %test1__2

then0__2:                                         ; preds = %continue__1
  %7 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %op = alloca %Array*
  store %Array* %7, %Array** %op
  %8 = call i64 @__quantum__rt__array_get_length(%Array* %indices, i32 0)
  %end__1 = sub i64 %8, 1
  br label %preheader__1

test1__2:                                         ; preds = %continue__1
  %9 = icmp eq i64 %termType, 3
  br i1 %9, label %then1__2, label %test2__1

then1__2:                                         ; preds = %test1__2
  %compactOps = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 8)
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 0)
  %11 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %11, i64 0)
  %13 = load i2, i2* @PauliX
  %14 = bitcast i8* %12 to i2*
  store i2 %13, i2* %14
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %11, i64 1)
  %16 = load i2, i2* @PauliX
  %17 = bitcast i8* %15 to i2*
  store i2 %16, i2* %17
  %18 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %11, i64 2)
  %19 = load i2, i2* @PauliX
  %20 = bitcast i8* %18 to i2*
  store i2 %19, i2* %20
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %11, i64 3)
  %22 = load i2, i2* @PauliX
  %23 = bitcast i8* %21 to i2*
  store i2 %22, i2* %23
  %24 = bitcast i8* %10 to %Array**
  store %Array* %11, %Array** %24
  %25 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 1)
  %26 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %27 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 0)
  %28 = load i2, i2* @PauliY
  %29 = bitcast i8* %27 to i2*
  store i2 %28, i2* %29
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 1)
  %31 = load i2, i2* @PauliY
  %32 = bitcast i8* %30 to i2*
  store i2 %31, i2* %32
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 2)
  %34 = load i2, i2* @PauliY
  %35 = bitcast i8* %33 to i2*
  store i2 %34, i2* %35
  %36 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %26, i64 3)
  %37 = load i2, i2* @PauliY
  %38 = bitcast i8* %36 to i2*
  store i2 %37, i2* %38
  %39 = bitcast i8* %25 to %Array**
  store %Array* %26, %Array** %39
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 2)
  %41 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %41, i64 0)
  %43 = load i2, i2* @PauliX
  %44 = bitcast i8* %42 to i2*
  store i2 %43, i2* %44
  %45 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %41, i64 1)
  %46 = load i2, i2* @PauliX
  %47 = bitcast i8* %45 to i2*
  store i2 %46, i2* %47
  %48 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %41, i64 2)
  %49 = load i2, i2* @PauliY
  %50 = bitcast i8* %48 to i2*
  store i2 %49, i2* %50
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %41, i64 3)
  %52 = load i2, i2* @PauliY
  %53 = bitcast i8* %51 to i2*
  store i2 %52, i2* %53
  %54 = bitcast i8* %40 to %Array**
  store %Array* %41, %Array** %54
  %55 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 3)
  %56 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %57 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %56, i64 0)
  %58 = load i2, i2* @PauliY
  %59 = bitcast i8* %57 to i2*
  store i2 %58, i2* %59
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %56, i64 1)
  %61 = load i2, i2* @PauliY
  %62 = bitcast i8* %60 to i2*
  store i2 %61, i2* %62
  %63 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %56, i64 2)
  %64 = load i2, i2* @PauliX
  %65 = bitcast i8* %63 to i2*
  store i2 %64, i2* %65
  %66 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %56, i64 3)
  %67 = load i2, i2* @PauliX
  %68 = bitcast i8* %66 to i2*
  store i2 %67, i2* %68
  %69 = bitcast i8* %55 to %Array**
  store %Array* %56, %Array** %69
  %70 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 4)
  %71 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %72 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %71, i64 0)
  %73 = load i2, i2* @PauliX
  %74 = bitcast i8* %72 to i2*
  store i2 %73, i2* %74
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %71, i64 1)
  %76 = load i2, i2* @PauliY
  %77 = bitcast i8* %75 to i2*
  store i2 %76, i2* %77
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %71, i64 2)
  %79 = load i2, i2* @PauliX
  %80 = bitcast i8* %78 to i2*
  store i2 %79, i2* %80
  %81 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %71, i64 3)
  %82 = load i2, i2* @PauliY
  %83 = bitcast i8* %81 to i2*
  store i2 %82, i2* %83
  %84 = bitcast i8* %70 to %Array**
  store %Array* %71, %Array** %84
  %85 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 5)
  %86 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %87 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 0)
  %88 = load i2, i2* @PauliY
  %89 = bitcast i8* %87 to i2*
  store i2 %88, i2* %89
  %90 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 1)
  %91 = load i2, i2* @PauliX
  %92 = bitcast i8* %90 to i2*
  store i2 %91, i2* %92
  %93 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 2)
  %94 = load i2, i2* @PauliY
  %95 = bitcast i8* %93 to i2*
  store i2 %94, i2* %95
  %96 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %86, i64 3)
  %97 = load i2, i2* @PauliX
  %98 = bitcast i8* %96 to i2*
  store i2 %97, i2* %98
  %99 = bitcast i8* %85 to %Array**
  store %Array* %86, %Array** %99
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 6)
  %101 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %102 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %101, i64 0)
  %103 = load i2, i2* @PauliY
  %104 = bitcast i8* %102 to i2*
  store i2 %103, i2* %104
  %105 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %101, i64 1)
  %106 = load i2, i2* @PauliX
  %107 = bitcast i8* %105 to i2*
  store i2 %106, i2* %107
  %108 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %101, i64 2)
  %109 = load i2, i2* @PauliX
  %110 = bitcast i8* %108 to i2*
  store i2 %109, i2* %110
  %111 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %101, i64 3)
  %112 = load i2, i2* @PauliY
  %113 = bitcast i8* %111 to i2*
  store i2 %112, i2* %113
  %114 = bitcast i8* %100 to %Array**
  store %Array* %101, %Array** %114
  %115 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 7)
  %116 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 4)
  %117 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 0)
  %118 = load i2, i2* @PauliX
  %119 = bitcast i8* %117 to i2*
  store i2 %118, i2* %119
  %120 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 1)
  %121 = load i2, i2* @PauliY
  %122 = bitcast i8* %120 to i2*
  store i2 %121, i2* %122
  %123 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 2)
  %124 = load i2, i2* @PauliY
  %125 = bitcast i8* %123 to i2*
  store i2 %124, i2* %125
  %126 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 3)
  %127 = load i2, i2* @PauliX
  %128 = bitcast i8* %126 to i2*
  store i2 %127, i2* %128
  %129 = bitcast i8* %115 to %Array**
  store %Array* %116, %Array** %129
  br label %preheader__2

test2__1:                                         ; preds = %test1__2
  %130 = icmp eq i64 %termType, 2
  br i1 %130, label %then2__1, label %continue__2

then2__1:                                         ; preds = %test2__1
  %compactOps5 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %131 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps5, i64 0)
  %132 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %133 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %132, i64 0)
  %134 = load i2, i2* @PauliX
  %135 = bitcast i8* %133 to i2*
  store i2 %134, i2* %135
  %136 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %132, i64 1)
  %137 = load i2, i2* @PauliX
  %138 = bitcast i8* %136 to i2*
  store i2 %137, i2* %138
  %139 = bitcast i8* %131 to %Array**
  store %Array* %132, %Array** %139
  %140 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps5, i64 1)
  %141 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 2)
  %142 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %141, i64 0)
  %143 = load i2, i2* @PauliY
  %144 = bitcast i8* %142 to i2*
  store i2 %143, i2* %144
  %145 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %141, i64 1)
  %146 = load i2, i2* @PauliY
  %147 = bitcast i8* %145 to i2*
  store i2 %146, i2* %147
  %148 = bitcast i8* %140 to %Array**
  store %Array* %141, %Array** %148
  br label %preheader__6

continue__2:                                      ; preds = %exit__6, %test2__1, %exit__2, %exit__1
  %149 = load %Array*, %Array** %ops
  call void @__quantum__rt__array_unreference(%Array* %3)
  ret %Array* %149

preheader__1:                                     ; preds = %then0__2
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %160, %exiting__1 ]
  %150 = icmp sge i64 %iter__1, %end__1
  %151 = icmp sle i64 %iter__1, %end__1
  %152 = select i1 true, i1 %151, i1 %150
  br i1 %152, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %153 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %iter__1)
  %154 = bitcast i8* %153 to i64*
  %idx = load i64, i64* %154
  %155 = load %Array*, %Array** %op
  %156 = call %Array* @__quantum__rt__array_copy(%Array* %155)
  %157 = load i2, i2* @PauliZ
  %158 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %156, i64 %idx)
  %159 = bitcast i8* %158 to i2*
  store i2 %157, i2* %159
  store %Array* %156, %Array** %op
  call void @__quantum__rt__array_reference(%Array* %156)
  call void @__quantum__rt__array_unreference(%Array* %156)
  br label %exiting__1

exiting__1:                                       ; preds = %body__1
  %160 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %161 = load %Array*, %Array** %ops
  %162 = call %Array* @__quantum__rt__array_copy(%Array* %161)
  %163 = load %Array*, %Array** %op
  %164 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %162, i64 0)
  %165 = bitcast i8* %164 to %Array**
  store %Array* %163, %Array** %165
  store %Array* %162, %Array** %ops
  call void @__quantum__rt__array_reference(%Array* %162)
  call void @__quantum__rt__array_unreference(%Array* %7)
  call void @__quantum__rt__array_unreference(%Array* %162)
  br label %continue__2

preheader__2:                                     ; preds = %then1__2
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iOp = phi i64 [ 0, %preheader__2 ], [ %174, %exiting__2 ]
  %166 = icmp sge i64 %iOp, 7
  %167 = icmp sle i64 %iOp, 7
  %168 = select i1 true, i1 %167, i1 %166
  br i1 %168, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %169 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps, i64 %iOp)
  %170 = bitcast i8* %169 to %Array**
  %171 = load %Array*, %Array** %170
  %compactOp = alloca %Array*
  store %Array* %171, %Array** %compactOp
  %172 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %op1 = alloca %Array*
  store %Array* %172, %Array** %op1
  %173 = call i64 @__quantum__rt__array_get_length(%Array* %indices, i32 0)
  %end__3 = sub i64 %173, 1
  br label %preheader__3

exiting__2:                                       ; preds = %exit__5
  %174 = add i64 %iOp, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__array_unreference(%Array* %11)
  call void @__quantum__rt__array_unreference(%Array* %26)
  call void @__quantum__rt__array_unreference(%Array* %41)
  call void @__quantum__rt__array_unreference(%Array* %56)
  call void @__quantum__rt__array_unreference(%Array* %71)
  call void @__quantum__rt__array_unreference(%Array* %86)
  call void @__quantum__rt__array_unreference(%Array* %101)
  call void @__quantum__rt__array_unreference(%Array* %116)
  call void @__quantum__rt__array_unreference(%Array* %compactOps)
  br label %continue__2

preheader__3:                                     ; preds = %body__2
  br label %header__3

header__3:                                        ; preds = %exiting__3, %preheader__3
  %i = phi i64 [ 0, %preheader__3 ], [ %187, %exiting__3 ]
  %175 = icmp sge i64 %i, %end__3
  %176 = icmp sle i64 %i, %end__3
  %177 = select i1 true, i1 %176, i1 %175
  br i1 %177, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %178 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %i)
  %179 = bitcast i8* %178 to i64*
  %idx2 = load i64, i64* %179
  %180 = load %Array*, %Array** %compactOp
  %181 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %180, i64 %i)
  %182 = bitcast i8* %181 to i2*
  %pauli = load i2, i2* %182
  %183 = load %Array*, %Array** %op1
  %184 = call %Array* @__quantum__rt__array_copy(%Array* %183)
  %185 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %184, i64 %idx2)
  %186 = bitcast i8* %185 to i2*
  store i2 %pauli, i2* %186
  store %Array* %184, %Array** %op1
  call void @__quantum__rt__array_reference(%Array* %184)
  call void @__quantum__rt__array_unreference(%Array* %184)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %187 = add i64 %i, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  %188 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %189 = bitcast i8* %188 to i64*
  %190 = load i64, i64* %189
  %end__4 = sub i64 %190, 1
  %191 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %192 = bitcast i8* %191 to i64*
  %193 = load i64, i64* %192
  %start__4 = add i64 %193, 1
  br label %preheader__4

preheader__4:                                     ; preds = %exit__3
  br label %header__4

header__4:                                        ; preds = %exiting__4, %preheader__4
  %i3 = phi i64 [ %start__4, %preheader__4 ], [ %202, %exiting__4 ]
  %194 = icmp sge i64 %i3, %end__4
  %195 = icmp sle i64 %i3, %end__4
  %196 = select i1 true, i1 %195, i1 %194
  br i1 %196, label %body__4, label %exit__4

body__4:                                          ; preds = %header__4
  %197 = load %Array*, %Array** %op1
  %198 = call %Array* @__quantum__rt__array_copy(%Array* %197)
  %199 = load i2, i2* @PauliZ
  %200 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %198, i64 %i3)
  %201 = bitcast i8* %200 to i2*
  store i2 %199, i2* %201
  store %Array* %198, %Array** %op1
  call void @__quantum__rt__array_reference(%Array* %198)
  call void @__quantum__rt__array_unreference(%Array* %198)
  br label %exiting__4

exiting__4:                                       ; preds = %body__4
  %202 = add i64 %i3, 1
  br label %header__4

exit__4:                                          ; preds = %header__4
  %203 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 3)
  %204 = bitcast i8* %203 to i64*
  %205 = load i64, i64* %204
  %end__5 = sub i64 %205, 1
  %206 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 2)
  %207 = bitcast i8* %206 to i64*
  %208 = load i64, i64* %207
  %start__5 = add i64 %208, 1
  br label %preheader__5

preheader__5:                                     ; preds = %exit__4
  br label %header__5

header__5:                                        ; preds = %exiting__5, %preheader__5
  %i4 = phi i64 [ %start__5, %preheader__5 ], [ %217, %exiting__5 ]
  %209 = icmp sge i64 %i4, %end__5
  %210 = icmp sle i64 %i4, %end__5
  %211 = select i1 true, i1 %210, i1 %209
  br i1 %211, label %body__5, label %exit__5

body__5:                                          ; preds = %header__5
  %212 = load %Array*, %Array** %op1
  %213 = call %Array* @__quantum__rt__array_copy(%Array* %212)
  %214 = load i2, i2* @PauliZ
  %215 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %213, i64 %i4)
  %216 = bitcast i8* %215 to i2*
  store i2 %214, i2* %216
  store %Array* %213, %Array** %op1
  call void @__quantum__rt__array_reference(%Array* %213)
  call void @__quantum__rt__array_unreference(%Array* %213)
  br label %exiting__5

exiting__5:                                       ; preds = %body__5
  %217 = add i64 %i4, 1
  br label %header__5

exit__5:                                          ; preds = %header__5
  %218 = load %Array*, %Array** %ops
  %219 = call %Array* @__quantum__rt__array_copy(%Array* %218)
  %220 = load %Array*, %Array** %op1
  %221 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %219, i64 %iOp)
  %222 = bitcast i8* %221 to %Array**
  store %Array* %220, %Array** %222
  store %Array* %219, %Array** %ops
  call void @__quantum__rt__array_reference(%Array* %219)
  call void @__quantum__rt__array_unreference(%Array* %172)
  call void @__quantum__rt__array_unreference(%Array* %219)
  br label %exiting__2

preheader__6:                                     ; preds = %then2__1
  br label %header__6

header__6:                                        ; preds = %exiting__6, %preheader__6
  %iOp6 = phi i64 [ 0, %preheader__6 ], [ %260, %exiting__6 ]
  %223 = icmp sge i64 %iOp6, 1
  %224 = icmp sle i64 %iOp6, 1
  %225 = select i1 true, i1 %224, i1 %223
  br i1 %225, label %body__6, label %exit__6

body__6:                                          ; preds = %header__6
  %226 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %compactOps5, i64 %iOp6)
  %227 = bitcast i8* %226 to %Array**
  %228 = load %Array*, %Array** %227
  %compactOp7 = alloca %Array*
  store %Array* %228, %Array** %compactOp7
  %229 = call %Array* @__quantum__rt__array_create_1d(i32 1, i64 %nQubits)
  %op8 = alloca %Array*
  store %Array* %229, %Array** %op8
  %nIndices = call i64 @__quantum__rt__array_get_length(%Array* %indices, i32 0)
  %230 = load %Array*, %Array** %op8
  %231 = call %Array* @__quantum__rt__array_copy(%Array* %230)
  %232 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %233 = bitcast i8* %232 to i64*
  %234 = load i64, i64* %233
  %235 = load %Array*, %Array** %compactOp7
  %236 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %235, i64 0)
  %237 = bitcast i8* %236 to i2*
  %238 = load i2, i2* %237
  %239 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %231, i64 %234)
  %240 = bitcast i8* %239 to i2*
  store i2 %238, i2* %240
  store %Array* %231, %Array** %op8
  call void @__quantum__rt__array_reference(%Array* %231)
  %241 = load %Array*, %Array** %op8
  %242 = call %Array* @__quantum__rt__array_copy(%Array* %241)
  %243 = sub i64 %nIndices, 1
  %244 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %243)
  %245 = bitcast i8* %244 to i64*
  %246 = load i64, i64* %245
  %247 = load %Array*, %Array** %compactOp7
  %248 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %247, i64 1)
  %249 = bitcast i8* %248 to i2*
  %250 = load i2, i2* %249
  %251 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %242, i64 %246)
  %252 = bitcast i8* %251 to i2*
  store i2 %250, i2* %252
  store %Array* %242, %Array** %op8
  call void @__quantum__rt__array_reference(%Array* %242)
  %253 = sub i64 %nIndices, 1
  %254 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 %253)
  %255 = bitcast i8* %254 to i64*
  %256 = load i64, i64* %255
  %end__7 = sub i64 %256, 1
  %257 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %258 = bitcast i8* %257 to i64*
  %259 = load i64, i64* %258
  %start__7 = add i64 %259, 1
  br label %preheader__7

exiting__6:                                       ; preds = %continue__3
  %260 = add i64 %iOp6, 1
  br label %header__6

exit__6:                                          ; preds = %header__6
  call void @__quantum__rt__array_unreference(%Array* %132)
  call void @__quantum__rt__array_unreference(%Array* %141)
  call void @__quantum__rt__array_unreference(%Array* %compactOps5)
  br label %continue__2

preheader__7:                                     ; preds = %body__6
  br label %header__7

header__7:                                        ; preds = %exiting__7, %preheader__7
  %i9 = phi i64 [ %start__7, %preheader__7 ], [ %269, %exiting__7 ]
  %261 = icmp sge i64 %i9, %end__7
  %262 = icmp sle i64 %i9, %end__7
  %263 = select i1 true, i1 %262, i1 %261
  br i1 %263, label %body__7, label %exit__7

body__7:                                          ; preds = %header__7
  %264 = load %Array*, %Array** %op8
  %265 = call %Array* @__quantum__rt__array_copy(%Array* %264)
  %266 = load i2, i2* @PauliZ
  %267 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %265, i64 %i9)
  %268 = bitcast i8* %267 to i2*
  store i2 %266, i2* %268
  store %Array* %265, %Array** %op8
  call void @__quantum__rt__array_reference(%Array* %265)
  call void @__quantum__rt__array_unreference(%Array* %265)
  br label %exiting__7

exiting__7:                                       ; preds = %body__7
  %269 = add i64 %i9, 1
  br label %header__7

exit__7:                                          ; preds = %header__7
  %270 = icmp eq i64 %nIndices, 4
  br i1 %270, label %then0__3, label %continue__3

then0__3:                                         ; preds = %exit__7
  %271 = load %Array*, %Array** %op8
  %272 = call %Array* @__quantum__rt__array_copy(%Array* %271)
  %273 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %274 = bitcast i8* %273 to i64*
  %275 = load i64, i64* %274
  %276 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 0)
  %277 = bitcast i8* %276 to i64*
  %278 = load i64, i64* %277
  %279 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %280 = bitcast i8* %279 to i64*
  %281 = load i64, i64* %280
  %282 = icmp slt i64 %278, %281
  %283 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 1)
  %284 = bitcast i8* %283 to i64*
  %285 = load i64, i64* %284
  %286 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %indices, i64 3)
  %287 = bitcast i8* %286 to i64*
  %288 = load i64, i64* %287
  %289 = icmp slt i64 %285, %288
  %290 = and i1 %282, %289
  %291 = load i2, i2* @PauliI
  %292 = load i2, i2* @PauliZ
  %293 = select i1 %290, i2 %291, i2 %292
  %294 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %272, i64 %275)
  %295 = bitcast i8* %294 to i2*
  store i2 %293, i2* %295
  store %Array* %272, %Array** %op8
  call void @__quantum__rt__array_reference(%Array* %272)
  call void @__quantum__rt__array_unreference(%Array* %272)
  br label %continue__3

continue__3:                                      ; preds = %then0__3, %exit__7
  %296 = load %Array*, %Array** %ops
  %297 = call %Array* @__quantum__rt__array_copy(%Array* %296)
  %298 = load %Array*, %Array** %op8
  %299 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %297, i64 %iOp6)
  %300 = bitcast i8* %299 to %Array**
  store %Array* %298, %Array** %300
  store %Array* %297, %Array** %ops
  call void @__quantum__rt__array_reference(%Array* %297)
  call void @__quantum__rt__array_unreference(%Array* %229)
  call void @__quantum__rt__array_unreference(%Array* %231)
  call void @__quantum__rt__array_unreference(%Array* %242)
  call void @__quantum__rt__array_unreference(%Array* %297)
  br label %exiting__6
}

declare i64 @__quantum__rt__array_get_length(%Array*, i32)

define void @Microsoft__Quantum__Intrinsic__CNOT__body(%Qubit* %control, %Qubit* %target) {
entry:
  call void @__quantum__qis__cnot(%Qubit* %control, %Qubit* %target)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__H__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__h(%Qubit* %qb)
  ret void
}

define double @Microsoft__Quantum__Intrinsic__IntAsDouble__body(i64 %i) {
entry:
  %0 = call double @__quantum__qis__intAsDouble(i64 %i)
  ret double %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Measure__body(%Array* %bases, %Array* %qubits) {
entry:
  %0 = call %Result* @__quantum__qis__measure(%Array* %bases, %Array* %qubits)
  ret %Result* %0
}

define %Result* @Microsoft__Quantum__Intrinsic__Mz__body(%Qubit* %qb) {
entry:
  %0 = call %Result* @__quantum__qis__mz(%Qubit* %qb)
  ret %Result* %0
}

define void @Microsoft__Quantum__Intrinsic__Rx__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rx(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rx__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rx(double %0, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__body(double %theta, %Qubit* %qb) {
entry:
  call void @__quantum__qis__rz(double %theta, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Rz__adj(double %theta, %Qubit* %qb) {
entry:
  %0 = fsub double -0.000000e+00, %theta
  call void @__quantum__qis__rz(double %0, %Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__S__adj(%Qubit* %qb) {
entry:
  call void @__quantum__qis__s(%Qubit* %qb)
  call void @__quantum__qis__z(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__X__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__x(%Qubit* %qb)
  ret void
}

define void @Microsoft__Quantum__Intrinsic__Z__body(%Qubit* %qb) {
entry:
  call void @__quantum__qis__z(%Qubit* %qb)
  ret void
}

define %Result* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__JointMeasure__body(%Array* %ops, %Array* %qbs) {
entry:
  %aux = call %Qubit* @__quantum__rt__qubit_allocate()
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %qbs, i32 0)
  %end__1 = sub i64 %0, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %14, %exiting__1 ]
  %1 = icmp sge i64 %i, %end__1
  %2 = icmp sle i64 %i, %end__1
  %3 = select i1 true, i1 %2, i1 %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %i)
  %5 = bitcast i8* %4 to i2*
  %op = load i2, i2* %5
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qbs, i64 %i)
  %7 = bitcast i8* %6 to %Qubit**
  %qb = load %Qubit*, %Qubit** %7
  %8 = load i2, i2* @PauliX
  %9 = icmp eq i2 %op, %8
  br i1 %9, label %then0__1, label %test1__1

then0__1:                                         ; preds = %body__1
  call void @__quantum__qis__h(%Qubit* %qb)
  call void @__quantum__qis__cnot(%Qubit* %qb, %Qubit* %aux)
  call void @__quantum__qis__h(%Qubit* %qb)
  br label %continue__1

test1__1:                                         ; preds = %body__1
  %10 = load i2, i2* @PauliY
  %11 = icmp eq i2 %op, %10
  br i1 %11, label %then1__1, label %test2__1

then1__1:                                         ; preds = %test1__1
  call void @__quantum__qis__s(%Qubit* %qb)
  call void @__quantum__qis__h(%Qubit* %qb)
  call void @__quantum__qis__cnot(%Qubit* %qb, %Qubit* %aux)
  call void @__quantum__qis__h(%Qubit* %qb)
  call void @__quantum__qis__s(%Qubit* %qb)
  call void @__quantum__qis__z(%Qubit* %qb)
  br label %continue__1

test2__1:                                         ; preds = %test1__1
  %12 = load i2, i2* @PauliZ
  %13 = icmp eq i2 %op, %12
  br i1 %13, label %then2__1, label %continue__1

then2__1:                                         ; preds = %test2__1
  call void @__quantum__qis__cnot(%Qubit* %qb, %Qubit* %aux)
  br label %continue__1

continue__1:                                      ; preds = %then2__1, %test2__1, %then1__1, %then0__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %14 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %15 = call %Result* @__quantum__qis__mz(%Qubit* %aux)
  call void @__quantum__rt__qubit_release(%Qubit* %aux)
  ret %Result* %15
}

declare %Qubit* @__quantum__rt__qubit_allocate()

declare %Array* @__quantum__rt__qubit_allocate_array(i64)

declare void @__quantum__rt__qubit_release(%Qubit*)

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__SumTermExpectation__body({ %TupleHeader, i64, %Array* }* %inputState, %Array* %ops, %Array* %coeffs, i64 %nQubits, i64 %nSamples) {
entry:
  %jwTermEnergy = alloca double
  store double 0.000000e+00, double* %jwTermEnergy
  %0 = call i64 @__quantum__rt__array_get_length(%Array* %coeffs, i32 0)
  %end__1 = sub i64 %0, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %i = phi i64 [ 0, %preheader__1 ], [ %16, %exiting__1 ]
  %1 = icmp sge i64 %i, %end__1
  %2 = icmp sle i64 %i, %end__1
  %3 = select i1 true, i1 %2, i1 %1
  br i1 %3, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %4 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %coeffs, i64 %i)
  %5 = bitcast i8* %4 to double*
  %coeff = load double, double* %5
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %ops, i64 %i)
  %7 = bitcast i8* %6 to %Array**
  %op = load %Array*, %Array** %7
  %8 = fcmp oge double %coeff, 1.000000e-10
  %9 = fcmp ole double %coeff, -1.000000e-10
  %10 = or i1 %8, %9
  br i1 %10, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %termExpectation = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__TermExpectation__body({ %TupleHeader, i64, %Array* }* %inputState, %Array* %op, i64 %nQubits, i64 %nSamples)
  %11 = load double, double* %jwTermEnergy
  %12 = fmul double 2.000000e+00, %termExpectation
  %13 = fsub double %12, 1.000000e+00
  %14 = fmul double %13, %coeff
  %15 = fadd double %11, %14
  store double %15, double* %jwTermEnergy
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  br label %exiting__1

exiting__1:                                       ; preds = %continue__1
  %16 = add i64 %i, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %17 = load double, double* %jwTermEnergy
  ret double %17
}

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__TermExpectation__body({ %TupleHeader, i64, %Array* }* %inputState, %Array* %measOp, i64 %nQubits, i64 %nSamples) {
entry:
  %nUp = alloca i64
  store i64 0, i64* %nUp
  %end__1 = sub i64 %nSamples, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %idxMeasurement = phi i64 [ 0, %preheader__1 ], [ %8, %exiting__1 ]
  %0 = icmp sge i64 %idxMeasurement, %end__1
  %1 = icmp sle i64 %idxMeasurement, %end__1
  %2 = select i1 true, i1 %1, i1 %0
  br i1 %2, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %register = call %Array* @__quantum__rt__qubit_allocate_array(i64 %nQubits)
  call void @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__StatePrep__PrepareTrialState__body({ %TupleHeader, i64, %Array* }* %inputState, %Array* %register)
  %result = call %Result* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__JointMeasure__body(%Array* %measOp, %Array* %register)
  %3 = load %Result*, %Result** @ResultZero
  %4 = call i1 @__quantum__rt__result_equal(%Result* %result, %Result* %3)
  br i1 %4, label %then0__1, label %continue__1

then0__1:                                         ; preds = %body__1
  %5 = load i64, i64* %nUp
  %6 = add i64 %5, 1
  store i64 %6, i64* %nUp
  br label %continue__1

continue__1:                                      ; preds = %then0__1, %body__1
  %7 = call i64 @__quantum__rt__array_get_length(%Array* %register, i32 0)
  %end__2 = sub i64 %7, 1
  br label %preheader__2

exiting__1:                                       ; preds = %exit__2
  %8 = add i64 %idxMeasurement, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %.i = load i64, i64* %nUp
  %9 = call double @__quantum__qis__intAsDouble(i64 %.i)
  %10 = call double @__quantum__qis__intAsDouble(i64 %nSamples)
  %11 = fdiv double %9, %10
  ret double %11

preheader__2:                                     ; preds = %continue__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iter__1 = phi i64 [ 0, %preheader__2 ], [ %17, %exiting__2 ]
  %12 = icmp sge i64 %iter__1, %end__2
  %13 = icmp sle i64 %iter__1, %end__2
  %14 = select i1 true, i1 %13, i1 %12
  br i1 %14, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %register, i64 %iter__1)
  %16 = bitcast i8* %15 to %Qubit**
  %q = load %Qubit*, %Qubit** %16
  %r = call %Result* @__quantum__qis__mz(%Qubit* %q)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %17 = add i64 %iter__1, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  call void @__quantum__rt__qubit_release_array(%Array* %register)
  call void @__quantum__rt__result_unreference(%Result* %result)
  br label %exiting__1
}

define void @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__StatePrep__PrepareTrialState__body({ %TupleHeader, i64, %Array* }* %stateData, %Array* %qubits) {
entry:
  %0 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %stateData, i32 0, i32 1
  %stateType = load i64, i64* %0
  %1 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %stateData, i32 0, i32 2
  %terms = load %Array*, %Array** %1
  %2 = call i64 @__quantum__rt__array_get_length(%Array* %terms, i32 0)
  %end__1 = sub i64 %2, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %iter__1 = phi i64 [ 0, %preheader__1 ], [ %13, %exiting__1 ]
  %3 = icmp sge i64 %iter__1, %end__1
  %4 = icmp sle i64 %iter__1, %end__1
  %5 = select i1 true, i1 %4, i1 %3
  br i1 %5, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %terms, i64 %iter__1)
  %7 = bitcast i8* %6 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }**
  %term = load { %TupleHeader, { %TupleHeader, double, double }*, %Array* }*, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }** %7
  %8 = getelementptr inbounds { %TupleHeader, { %TupleHeader, double, double }*, %Array* }, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %term, i32 0, i32 1
  %coefficient = load { %TupleHeader, double, double }*, { %TupleHeader, double, double }** %8
  %9 = getelementptr inbounds { %TupleHeader, { %TupleHeader, double, double }*, %Array* }, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %term, i32 0, i32 2
  %excitation = load %Array*, %Array** %9
  %10 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %coefficient, i32 0, i32 1
  %theta = load double, double* %10
  %11 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %coefficient, i32 0, i32 2
  %phi = load double, double* %11
  %12 = call i64 @__quantum__rt__array_get_length(%Array* %excitation, i32 0)
  %end__2 = sub i64 %12, 1
  br label %preheader__2

exiting__1:                                       ; preds = %continue__1
  %13 = add i64 %iter__1, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  ret void

preheader__2:                                     ; preds = %body__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iter__2 = phi i64 [ 0, %preheader__2 ], [ %21, %exiting__2 ]
  %14 = icmp sge i64 %iter__2, %end__2
  %15 = icmp sle i64 %iter__2, %end__2
  %16 = select i1 true, i1 %15, i1 %14
  br i1 %16, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %17 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %excitation, i64 %iter__2)
  %18 = bitcast i8* %17 to i64*
  %i = load i64, i64* %18
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %i)
  %20 = bitcast i8* %19 to %Qubit**
  %.qb = load %Qubit*, %Qubit** %20
  call void @__quantum__qis__x(%Qubit* %.qb)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %21 = add i64 %iter__2, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  %22 = fcmp olt double %theta, 1.000000e+00
  br i1 %22, label %then0__1, label %continue__1

then0__1:                                         ; preds = %exit__2
  %23 = call i64 @__quantum__rt__array_get_length(%Array* %qubits, i32 0)
  %end__3 = sub i64 %23, 1
  br label %preheader__3

continue__1:                                      ; preds = %exit__3, %exit__2
  br label %exiting__1

preheader__3:                                     ; preds = %then0__1
  br label %header__3

header__3:                                        ; preds = %exiting__3, %preheader__3
  %iter__3 = phi i64 [ 0, %preheader__3 ], [ %29, %exiting__3 ]
  %24 = icmp sge i64 %iter__3, %end__3
  %25 = icmp sle i64 %iter__3, %end__3
  %26 = select i1 true, i1 %25, i1 %24
  br i1 %26, label %body__3, label %exit__3

body__3:                                          ; preds = %header__3
  %27 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %qubits, i64 %iter__3)
  %28 = bitcast i8* %27 to %Qubit**
  %qubit = load %Qubit*, %Qubit** %28
  call void @__quantum__qis__s(%Qubit* %qubit)
  call void @__quantum__qis__rx(double %theta, %Qubit* %qubit)
  call void @__quantum__qis__s(%Qubit* %qubit)
  call void @__quantum__qis__z(%Qubit* %qubit)
  call void @__quantum__qis__rz(double %theta, %Qubit* %qubit)
  br label %exiting__3

exiting__3:                                       ; preds = %body__3
  %29 = add i64 %iter__3, 1
  br label %header__3

exit__3:                                          ; preds = %header__3
  br label %continue__1
}

declare i1 @__quantum__rt__result_equal(%Result*, %Result*)

declare void @__quantum__rt__qubit_release_array(%Array*)

declare void @__quantum__rt__result_unreference(%Result*)

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body() #0 {
entry:
  %0 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %1 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 0)
  %2 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %3 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %2, i64 0)
  %4 = bitcast i8* %3 to i64*
  store i64 0, i64* %4
  %5 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %5, i64 0)
  %7 = bitcast i8* %6 to double*
  store double 0x3FC5E9EC780DD8B0, double* %7
  %8 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %2, %Array* %5)
  %9 = bitcast i8* %1 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %8, { %TupleHeader, %Array*, %Array* }** %9
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 1)
  %11 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %11, i64 0)
  %13 = bitcast i8* %12 to i64*
  store i64 1, i64* %13
  %14 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %15 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %14, i64 0)
  %16 = bitcast i8* %15 to double*
  store double 0x3FC5E9EC780DD8B0, double* %16
  %17 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %11, %Array* %14)
  %18 = bitcast i8* %10 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %17, { %TupleHeader, %Array*, %Array* }** %18
  %19 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 2)
  %20 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %21 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %20, i64 0)
  %22 = bitcast i8* %21 to i64*
  store i64 2, i64* %22
  %23 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %23, i64 0)
  %25 = bitcast i8* %24 to double*
  store double 0xBFCC8498CDE41B6A, double* %25
  %26 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %20, %Array* %23)
  %27 = bitcast i8* %19 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %26, { %TupleHeader, %Array*, %Array* }** %27
  %28 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %0, i64 3)
  %29 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %30 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %29, i64 0)
  %31 = bitcast i8* %30 to i64*
  store i64 3, i64* %31
  %32 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %33 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %32, i64 0)
  %34 = bitcast i8* %33 to double*
  store double 0xBFCC8498CDE41B6A, double* %34
  %35 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %29, %Array* %32)
  %36 = bitcast i8* %28 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %35, { %TupleHeader, %Array*, %Array* }** %36
  %37 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 6)
  %38 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 0)
  %39 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %40 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %39, i64 0)
  %41 = bitcast i8* %40 to i64*
  store i64 0, i64* %41
  %42 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %39, i64 1)
  %43 = bitcast i8* %42 to i64*
  store i64 1, i64* %43
  %44 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %45 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %44, i64 0)
  %46 = bitcast i8* %45 to double*
  store double 0x3FC59572B12B0E54, double* %46
  %47 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %39, %Array* %44)
  %48 = bitcast i8* %38 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %47, { %TupleHeader, %Array*, %Array* }** %48
  %49 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 1)
  %50 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %51 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %50, i64 0)
  %52 = bitcast i8* %51 to i64*
  store i64 0, i64* %52
  %53 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %50, i64 1)
  %54 = bitcast i8* %53 to i64*
  store i64 2, i64* %54
  %55 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %56 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %55, i64 0)
  %57 = bitcast i8* %56 to double*
  store double 0x3FBEDC1CB9A7B498, double* %57
  %58 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %50, %Array* %55)
  %59 = bitcast i8* %49 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %58, { %TupleHeader, %Array*, %Array* }** %59
  %60 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 2)
  %61 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %62 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %61, i64 0)
  %63 = bitcast i8* %62 to i64*
  store i64 0, i64* %63
  %64 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %61, i64 1)
  %65 = bitcast i8* %64 to i64*
  store i64 3, i64* %65
  %66 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %67 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %66, i64 0)
  %68 = bitcast i8* %67 to double*
  store double 0x3FC53B29D7F34F20, double* %68
  %69 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %61, %Array* %66)
  %70 = bitcast i8* %60 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %69, { %TupleHeader, %Array*, %Array* }** %70
  %71 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 3)
  %72 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %73 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %72, i64 0)
  %74 = bitcast i8* %73 to i64*
  store i64 1, i64* %74
  %75 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %72, i64 1)
  %76 = bitcast i8* %75 to i64*
  store i64 2, i64* %76
  %77 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %78 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %77, i64 0)
  %79 = bitcast i8* %78 to double*
  store double 0x3FC53B29D7F34F20, double* %79
  %80 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %72, %Array* %77)
  %81 = bitcast i8* %71 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %80, { %TupleHeader, %Array*, %Array* }** %81
  %82 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 4)
  %83 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %84 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %83, i64 0)
  %85 = bitcast i8* %84 to i64*
  store i64 1, i64* %85
  %86 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %83, i64 1)
  %87 = bitcast i8* %86 to i64*
  store i64 3, i64* %87
  %88 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %89 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %88, i64 0)
  %90 = bitcast i8* %89 to double*
  store double 0x3FBEDC1CB9A7B498, double* %90
  %91 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %83, %Array* %88)
  %92 = bitcast i8* %82 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %91, { %TupleHeader, %Array*, %Array* }** %92
  %93 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %37, i64 5)
  %94 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %95 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %94, i64 0)
  %96 = bitcast i8* %95 to i64*
  store i64 2, i64* %96
  %97 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %94, i64 1)
  %98 = bitcast i8* %97 to i64*
  store i64 3, i64* %98
  %99 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 1)
  %100 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %99, i64 0)
  %101 = bitcast i8* %100 to double*
  store double 0x3FC65115A1A7DAFB, double* %101
  %102 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %94, %Array* %99)
  %103 = bitcast i8* %93 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %102, { %TupleHeader, %Array*, %Array* }** %103
  %104 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 0)
  %105 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 1)
  %106 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %105, i64 0)
  %107 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %108 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %107, i64 0)
  %109 = bitcast i8* %108 to i64*
  store i64 0, i64* %109
  %110 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %107, i64 1)
  %111 = bitcast i8* %110 to i64*
  store i64 1, i64* %111
  %112 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %107, i64 2)
  %113 = bitcast i8* %112 to i64*
  store i64 2, i64* %113
  %114 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %107, i64 3)
  %115 = bitcast i8* %114 to i64*
  store i64 3, i64* %115
  %116 = call %Array* @__quantum__rt__array_create_1d(i32 16, i64 4)
  %117 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 0)
  %118 = bitcast i8* %117 to double*
  store double 0.000000e+00, double* %118
  %119 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 1)
  %120 = bitcast i8* %119 to double*
  store double 0xBFA7346DEC7DD351, double* %120
  %121 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 2)
  %122 = bitcast i8* %121 to double*
  store double 0.000000e+00, double* %122
  %123 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %116, i64 3)
  %124 = bitcast i8* %123 to double*
  store double 0x3FA7346DEC7DD351, double* %124
  %125 = call { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %107, %Array* %116)
  %126 = bitcast i8* %106 to { %TupleHeader, %Array*, %Array* }**
  store { %TupleHeader, %Array*, %Array* }* %125, { %TupleHeader, %Array*, %Array* }** %126
  %hamiltonian = call { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JWOptimizedHTerms__body(%Array* %0, %Array* %37, %Array* %104, %Array* %105)
  %127 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, i64, %Array* }* getelementptr ({ %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* null, i32 1) to i64))
  %inputState = bitcast %TupleHeader* %127 to { %TupleHeader, i64, %Array* }*
  %128 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %inputState, i32 0, i32 1
  store i64 3, i64* %128
  %129 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %130 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %129, i64 0)
  %131 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, double }* getelementptr ({ %TupleHeader, double, double }, { %TupleHeader, double, double }* null, i32 1) to i64))
  %132 = bitcast %TupleHeader* %131 to { %TupleHeader, double, double }*
  %133 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %132, i32 0, i32 1
  store double 1.000000e-03, double* %133
  %134 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %132, i32 0, i32 2
  store double 0.000000e+00, double* %134
  %135 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %136 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %135, i64 0)
  %137 = bitcast i8* %136 to i64*
  store i64 2, i64* %137
  %138 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %135, i64 1)
  %139 = bitcast i8* %138 to i64*
  store i64 0, i64* %139
  %140 = call { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ %TupleHeader, double, double }* %132, %Array* %135)
  %141 = bitcast i8* %130 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }**
  store { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %140, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }** %141
  %142 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %129, i64 1)
  %143 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, double }* getelementptr ({ %TupleHeader, double, double }, { %TupleHeader, double, double }* null, i32 1) to i64))
  %144 = bitcast %TupleHeader* %143 to { %TupleHeader, double, double }*
  %145 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %144, i32 0, i32 1
  store double -1.000000e-03, double* %145
  %146 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %144, i32 0, i32 2
  store double 0.000000e+00, double* %146
  %147 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %148 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %147, i64 0)
  %149 = bitcast i8* %148 to i64*
  store i64 3, i64* %149
  %150 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %147, i64 1)
  %151 = bitcast i8* %150 to i64*
  store i64 1, i64* %151
  %152 = call { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ %TupleHeader, double, double }* %144, %Array* %147)
  %153 = bitcast i8* %142 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }**
  store { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %152, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }** %153
  %154 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %129, i64 2)
  %155 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, double }* getelementptr ({ %TupleHeader, double, double }, { %TupleHeader, double, double }* null, i32 1) to i64))
  %156 = bitcast %TupleHeader* %155 to { %TupleHeader, double, double }*
  %157 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %156, i32 0, i32 1
  store double 1.000000e-03, double* %157
  %158 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %156, i32 0, i32 2
  store double 0.000000e+00, double* %158
  %159 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %160 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %159, i64 0)
  %161 = bitcast i8* %160 to i64*
  store i64 2, i64* %161
  %162 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %159, i64 1)
  %163 = bitcast i8* %162 to i64*
  store i64 3, i64* %163
  %164 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %159, i64 2)
  %165 = bitcast i8* %164 to i64*
  store i64 1, i64* %165
  %166 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %159, i64 3)
  %167 = bitcast i8* %166 to i64*
  store i64 0, i64* %167
  %168 = call { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ %TupleHeader, double, double }* %156, %Array* %159)
  %169 = bitcast i8* %154 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }**
  store { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %168, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }** %169
  %170 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %129, i64 3)
  %171 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, double, double }* getelementptr ({ %TupleHeader, double, double }, { %TupleHeader, double, double }* null, i32 1) to i64))
  %172 = bitcast %TupleHeader* %171 to { %TupleHeader, double, double }*
  %173 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %172, i32 0, i32 1
  store double 1.000000e+00, double* %173
  %174 = getelementptr inbounds { %TupleHeader, double, double }, { %TupleHeader, double, double }* %172, i32 0, i32 2
  store double 0.000000e+00, double* %174
  %175 = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 2)
  %176 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %175, i64 0)
  %177 = bitcast i8* %176 to i64*
  store i64 0, i64* %177
  %178 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %175, i64 1)
  %179 = bitcast i8* %178 to i64*
  store i64 1, i64* %179
  %180 = call { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ %TupleHeader, double, double }* %172, %Array* %175)
  %181 = bitcast i8* %170 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }**
  store { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %180, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }** %181
  %182 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %inputState, i32 0, i32 2
  store %Array* %129, %Array** %182
  %JWEncodedData = call { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerEncodingData__body(i64 4, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonian, { %TupleHeader, i64, %Array* }* %inputState, double 0xBFB94D36D949CC98)
  %183 = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__VariationalQuantumEigensolver__EstimateEnergy__body(i64 5, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonian, { %TupleHeader, i64, %Array* }* %inputState, double 0xBFB94D36D949CC98, i64 100)
  call void @__quantum__rt__array_unreference(%Array* %2)
  call void @__quantum__rt__array_unreference(%Array* %5)
  call void @__quantum__rt__array_unreference(%Array* %11)
  call void @__quantum__rt__array_unreference(%Array* %14)
  call void @__quantum__rt__array_unreference(%Array* %20)
  call void @__quantum__rt__array_unreference(%Array* %23)
  call void @__quantum__rt__array_unreference(%Array* %29)
  call void @__quantum__rt__array_unreference(%Array* %32)
  call void @__quantum__rt__array_unreference(%Array* %0)
  call void @__quantum__rt__array_unreference(%Array* %39)
  call void @__quantum__rt__array_unreference(%Array* %44)
  call void @__quantum__rt__array_unreference(%Array* %50)
  call void @__quantum__rt__array_unreference(%Array* %55)
  call void @__quantum__rt__array_unreference(%Array* %61)
  call void @__quantum__rt__array_unreference(%Array* %66)
  call void @__quantum__rt__array_unreference(%Array* %72)
  call void @__quantum__rt__array_unreference(%Array* %77)
  call void @__quantum__rt__array_unreference(%Array* %83)
  call void @__quantum__rt__array_unreference(%Array* %88)
  call void @__quantum__rt__array_unreference(%Array* %94)
  call void @__quantum__rt__array_unreference(%Array* %99)
  call void @__quantum__rt__array_unreference(%Array* %37)
  call void @__quantum__rt__array_unreference(%Array* %104)
  call void @__quantum__rt__array_unreference(%Array* %107)
  call void @__quantum__rt__array_unreference(%Array* %116)
  call void @__quantum__rt__array_unreference(%Array* %105)
  %184 = bitcast { %TupleHeader, i64, %Array* }* %inputState to %TupleHeader*
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %184)
  %185 = bitcast { %TupleHeader, double, double }* %132 to %TupleHeader*
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %185)
  call void @__quantum__rt__array_unreference(%Array* %135)
  %186 = bitcast { %TupleHeader, double, double }* %144 to %TupleHeader*
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %186)
  call void @__quantum__rt__array_unreference(%Array* %147)
  %187 = bitcast { %TupleHeader, double, double }* %156 to %TupleHeader*
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %187)
  call void @__quantum__rt__array_unreference(%Array* %159)
  %188 = bitcast { %TupleHeader, double, double }* %172 to %TupleHeader*
  call void @__quantum__rt__tuple_unreference(%TupleHeader* %188)
  call void @__quantum__rt__array_unreference(%Array* %175)
  call void @__quantum__rt__array_unreference(%Array* %129)
  ret double %183
}

define { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JWOptimizedHTerms__body(%Array* %arg0, %Array* %arg1, %Array* %arg2, %Array* %arg3) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Array*, %Array*, %Array* }* getelementptr ({ %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*
  %2 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %1, i32 0, i32 1
  store %Array* %arg0, %Array** %2
  call void @__quantum__rt__array_reference(%Array* %arg0)
  %3 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %1, i32 0, i32 2
  store %Array* %arg1, %Array** %3
  call void @__quantum__rt__array_reference(%Array* %arg1)
  %4 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %1, i32 0, i32 3
  store %Array* %arg2, %Array** %4
  call void @__quantum__rt__array_reference(%Array* %arg2)
  %5 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %1, i32 0, i32 4
  store %Array* %arg3, %Array** %5
  call void @__quantum__rt__array_reference(%Array* %arg3)
  ret { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %1
}

define { %TupleHeader, %Array*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__ChemUtils__HTerm__body(%Array* %arg0, %Array* %arg1) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, %Array*, %Array* }* getelementptr ({ %TupleHeader, %Array*, %Array* }, { %TupleHeader, %Array*, %Array* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, %Array*, %Array* }*
  %2 = getelementptr inbounds { %TupleHeader, %Array*, %Array* }, { %TupleHeader, %Array*, %Array* }* %1, i32 0, i32 1
  store %Array* %arg0, %Array** %2
  call void @__quantum__rt__array_reference(%Array* %arg0)
  %3 = getelementptr inbounds { %TupleHeader, %Array*, %Array* }, { %TupleHeader, %Array*, %Array* }* %1, i32 0, i32 2
  store %Array* %arg1, %Array** %3
  call void @__quantum__rt__array_reference(%Array* %arg1)
  ret { %TupleHeader, %Array*, %Array* }* %1
}

define { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerInputState__body({ %TupleHeader, double, double }* %arg0, %Array* %arg1) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, { %TupleHeader, double, double }*, %Array* }* getelementptr ({ %TupleHeader, { %TupleHeader, double, double }*, %Array* }, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, { %TupleHeader, double, double }*, %Array* }*
  %2 = getelementptr inbounds { %TupleHeader, { %TupleHeader, double, double }*, %Array* }, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %1, i32 0, i32 1
  store { %TupleHeader, double, double }* %arg0, { %TupleHeader, double, double }** %2
  %3 = bitcast { %TupleHeader, double, double }* %arg0 to %TupleHeader*
  call void @__quantum__rt__tuple_reference(%TupleHeader* %3)
  %4 = getelementptr inbounds { %TupleHeader, { %TupleHeader, double, double }*, %Array* }, { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %1, i32 0, i32 2
  store %Array* %arg1, %Array** %4
  call void @__quantum__rt__array_reference(%Array* %arg1)
  ret { %TupleHeader, { %TupleHeader, double, double }*, %Array* }* %1
}

define { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__JordanWigner__JordanWignerEncodingData__body(i64 %arg0, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %arg1, { %TupleHeader, i64, %Array* }* %arg2, double %arg3) {
entry:
  %0 = call %TupleHeader* @__quantum__rt__tuple_create(i64 ptrtoint ({ %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* getelementptr ({ %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }, { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* null, i32 1) to i64))
  %1 = bitcast %TupleHeader* %0 to { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }*
  %2 = getelementptr inbounds { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }, { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* %1, i32 0, i32 1
  store i64 %arg0, i64* %2
  %3 = getelementptr inbounds { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }, { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* %1, i32 0, i32 2
  store { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %arg1, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }** %3
  %4 = bitcast { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %arg1 to %TupleHeader*
  call void @__quantum__rt__tuple_reference(%TupleHeader* %4)
  %5 = getelementptr inbounds { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }, { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* %1, i32 0, i32 3
  store { %TupleHeader, i64, %Array* }* %arg2, { %TupleHeader, i64, %Array* }** %5
  %6 = bitcast { %TupleHeader, i64, %Array* }* %arg2 to %TupleHeader*
  call void @__quantum__rt__tuple_reference(%TupleHeader* %6)
  %7 = getelementptr inbounds { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }, { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* %1, i32 0, i32 4
  store double %arg3, double* %7
  ret { %TupleHeader, i64, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }*, { %TupleHeader, i64, %Array* }*, double }* %1
}

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__VariationalQuantumEigensolver__EstimateEnergy__body(i64 %nQubits, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, { %TupleHeader, i64, %Array* }* %inputState, double %energyOffset, i64 %nSamples) {
entry:
  %energy = alloca double
  store double 0.000000e+00, double* %energy
  %0 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %inputState, i32 0, i32 1
  %inputStateType = load i64, i64* %0
  %1 = getelementptr inbounds { %TupleHeader, i64, %Array* }, { %TupleHeader, i64, %Array* }* %inputState, i32 0, i32 2
  %inputStateTerms = load %Array*, %Array** %1
  %2 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 1
  %ZData = load %Array*, %Array** %2
  %3 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 2
  %ZZData = load %Array*, %Array** %3
  %4 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 3
  %PQandPQQRData = load %Array*, %Array** %4
  %5 = getelementptr inbounds { %TupleHeader, %Array*, %Array*, %Array*, %Array* }, { %TupleHeader, %Array*, %Array*, %Array*, %Array* }* %hamiltonianTermList, i32 0, i32 4
  %h0123Data = load %Array*, %Array** %5
  %hamiltonianTermArray = call %Array* @__quantum__rt__array_create_1d(i32 8, i64 4)
  %6 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 0)
  %7 = bitcast i8* %6 to %Array**
  store %Array* %ZData, %Array** %7
  %8 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 1)
  %9 = bitcast i8* %8 to %Array**
  store %Array* %ZZData, %Array** %9
  %10 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 2)
  %11 = bitcast i8* %10 to %Array**
  store %Array* %PQandPQQRData, %Array** %11
  %12 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 3)
  %13 = bitcast i8* %12 to %Array**
  store %Array* %h0123Data, %Array** %13
  %14 = call i64 @__quantum__rt__array_get_length(%Array* %ZData, i32 0)
  %15 = call i64 @__quantum__rt__array_get_length(%Array* %ZZData, i32 0)
  %16 = add i64 %14, %15
  %17 = call i64 @__quantum__rt__array_get_length(%Array* %PQandPQQRData, i32 0)
  %18 = add i64 %16, %17
  %19 = call i64 @__quantum__rt__array_get_length(%Array* %h0123Data, i32 0)
  %nTerms = add i64 %18, %19
  %20 = call i64 @__quantum__rt__array_get_length(%Array* %hamiltonianTermArray, i32 0)
  %end__1 = sub i64 %20, 1
  br label %preheader__1

preheader__1:                                     ; preds = %entry
  br label %header__1

header__1:                                        ; preds = %exiting__1, %preheader__1
  %termType = phi i64 [ 0, %preheader__1 ], [ %27, %exiting__1 ]
  %21 = icmp sge i64 %termType, %end__1
  %22 = icmp sle i64 %termType, %end__1
  %23 = select i1 true, i1 %22, i1 %21
  br i1 %23, label %body__1, label %exit__1

body__1:                                          ; preds = %header__1
  %24 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTermArray, i64 %termType)
  %25 = bitcast i8* %24 to %Array**
  %hamiltonianTerms = load %Array*, %Array** %25
  %26 = call i64 @__quantum__rt__array_get_length(%Array* %hamiltonianTerms, i32 0)
  %end__2 = sub i64 %26, 1
  br label %preheader__2

exiting__1:                                       ; preds = %exit__2
  %27 = add i64 %termType, 1
  br label %header__1

exit__1:                                          ; preds = %header__1
  %28 = load double, double* %energy
  call void @__quantum__rt__array_unreference(%Array* %hamiltonianTermArray)
  ret double %28

preheader__2:                                     ; preds = %body__1
  br label %header__2

header__2:                                        ; preds = %exiting__2, %preheader__2
  %iter__1 = phi i64 [ 0, %preheader__2 ], [ %38, %exiting__2 ]
  %29 = icmp sge i64 %iter__1, %end__2
  %30 = icmp sle i64 %iter__1, %end__2
  %31 = select i1 true, i1 %30, i1 %29
  br i1 %31, label %body__2, label %exit__2

body__2:                                          ; preds = %header__2
  %32 = call i8* @__quantum__rt__array_get_element_ptr_1d(%Array* %hamiltonianTerms, i64 %iter__1)
  %33 = bitcast i8* %32 to { %TupleHeader, %Array*, %Array* }**
  %hamiltonianTerm = load { %TupleHeader, %Array*, %Array* }*, { %TupleHeader, %Array*, %Array* }** %33
  %34 = getelementptr inbounds { %TupleHeader, %Array*, %Array* }, { %TupleHeader, %Array*, %Array* }* %hamiltonianTerm, i32 0, i32 1
  %qubitIndices = load %Array*, %Array** %34
  %35 = getelementptr inbounds { %TupleHeader, %Array*, %Array* }, { %TupleHeader, %Array*, %Array* }* %hamiltonianTerm, i32 0, i32 2
  %coefficient = load %Array*, %Array** %35
  %measOps = call %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__VQEMeasurementOperators__body(i64 %nQubits, %Array* %qubitIndices, i64 %termType)
  %coefficients = call %Array* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__Utils__ExpandedCoefficients__body(%Array* %coefficient, i64 %termType)
  %jwTermEnergy = call double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__EstimateEnergy__SumTermExpectation__body({ %TupleHeader, i64, %Array* }* %inputState, %Array* %measOps, %Array* %coefficients, i64 %nQubits, i64 %nSamples)
  %36 = load double, double* %energy
  %37 = fadd double %36, %jwTermEnergy
  store double %37, double* %energy
  call void @__quantum__rt__array_unreference(%Array* %measOps)
  call void @__quantum__rt__array_unreference(%Array* %coefficients)
  br label %exiting__2

exiting__2:                                       ; preds = %body__2
  %38 = add i64 %iter__1, 1
  br label %header__2

exit__2:                                          ; preds = %header__2
  br label %exiting__1
}

declare void @__quantum__rt__tuple_unreference(%TupleHeader*)

declare void @__quantum__rt__tuple_reference(%TupleHeader*)

attributes #0 = { "EntryPoint" }
