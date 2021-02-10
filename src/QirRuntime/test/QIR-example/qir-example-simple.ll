
%Result = type opaque
%Range = type { i64, i64, i64 }

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE = alias double (), double ()* @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body

define double @Microsoft__Quantum__Samples__Chemistry__SimpleVQE__GetEnergyHydrogenVQE__body() #0 {
entry:
  ret double 1.000000e+00
}

attributes #0 = { "EntryPoint" }
