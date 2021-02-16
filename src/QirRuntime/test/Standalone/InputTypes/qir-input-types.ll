
%Result = type opaque
%Range = type { i64, i64, i64 }

@ResultZero = external global %Result*
@ResultOne = external global %Result*
@PauliI = constant i2 0
@PauliX = constant i2 1
@PauliY = constant i2 -1
@PauliZ = constant i2 -2
@EmptyRange = internal constant %Range { i64 0, i64 1, i64 -1 }

@Microsoft__Quantum__Testing__QIR__InputTypes = alias void (), void ()* @Microsoft__Quantum__Testing__QIR__InputTypes__body

define void @Microsoft__Quantum__Testing__QIR__InputTypes__body() #0 {
entry:
  ret void
}

attributes #0 = { "EntryPoint" }
