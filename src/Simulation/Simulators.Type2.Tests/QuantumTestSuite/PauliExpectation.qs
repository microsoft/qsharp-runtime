// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.Math {
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Bitwise;
    open Microsoft.Quantum.Convert;

    // Computes expectation of the observable on a given state.
    //
    // Algorithm is based on the following observations:
    // First note that for every bit b, and every single qubit Pauli matrix P
    // it is the case that:
    // P|b⟩ = iʸ(-1)^(b∧z)|b⊕x⟩, where:,
    // x is equal to one when P is X or Y and equal to zero otherwise, we call this function XBit(P)
    // z is equal to one when P is Z or Y and equal to zero otherwise, we call this function ZBit(P)
    // y is equal to one when P is equal to Y and to zero otherwise, we call this function YCount(P)
    // ⊕ is `Xor`
    // For tensor product of Paulies P = P₁⊗…⊗Pₙ and multi-qubit states |b⟩=|bₙ…b₁⟩ this generalizes to:
    // P|bₙ…b₁⟩ = iʸ⋅(-1)^Parity(b∧z)⋅|b⊕x⟩ where :
    // y = Ycount(P) = Ycount(P₁) + … + Ycount(Pₙ),
    // x = XBits(P) = (XBit(Pₙ)…XBit(P₁)) is a bitstring of length n
    // z = ZBits(P) = (ZBit(Pₙ)…ZBit(P₁)) is a bitstring of length n
    // b∧z is bitwise `And`
    // b⊕x is bitwise `Xor`
    // Parity(aₙ…a) of bitstring aₙ…a₁ is a₁⊕…⊕aₙ
    // Using above observations we get:
    // ⟨ψ|P|ψ⟩ = ∑ₐⱼ ⟨ψ|a⟩⟨a|P|j⟩⟨j|ψ⟩ = ∑ₐⱼ ⟨ψ|a⟩⟨a|P|j⟩⟨j|ψ⟩ = ∑ₐⱼ ⟨ψ|a⟩⟨a|( iʸ⋅(-1)^Parity(j∧z)⋅|j⊕x⟩ ) ⟨j|ψ⟩ =
    // = iʸ⋅∑ⱼ⟨ψ|j⊕x⟩⋅(-1)^Parity(j∧z)⋅⟨j|ψ⟩
    //
    // Note the bit order convention used:
    // Consider Pauli[] = [ PauliZ, PauliX ];
    // state[2] is ⟨10|ψ⟩ and state[1] is ⟨01|ψ⟩
    // ZBits([ PauliZ, PauliX ]) is 01 in binary
    // XBits([ PauliZ, PauliX ]) is 10 in binary
    //
    function PauliExpectation (observable : Pauli[], state : Vector) : Double {
        
        
        if (Length(observable) == 0) {
            fail $"observable array must have Length at least 1";
        }
        
        if (2 ^ Length(observable) != Length(state!)) {
            fail $"size of the state does not match the observable length";
        }
        
        let xbits = XBits(observable);
        let zbits = ZBits(observable);
        mutable res = ZeroC();
        let phase = ComplexIPower(YCount(observable));
        
        for (j in 0 .. Length(state!) - 1) {
            mutable mul = ConjugateC(state![Xor(xbits, j)]);
            
            // now mul is ⟨ψ|j⊕x⟩
            if (Parity(And(zbits, j)) == 1) {
                set mul = MinusC(mul);
            }
            
            // now mul is ⟨ψ|j⊕x⟩⋅(-1)^Parity(j∧z)
            // adding ⟨ψ|j⊕x⟩⋅(-1)^Parity(j∧z)⟨j|ψ⟩ to res
            set res = PlusC(res, TimesC(mul, state![j]));
        }
        
        let (reRes, imRes) = (TimesC(res, phase))!;
        
        if (AbsD(imRes) > Accuracy()) {
            fail $"the expectation of the observable must be real number";
        }
        
        return reRes;
    }
    
    
    function YCount (observable : Pauli[]) : Int {
        
        mutable yCount = 0;
        
        for (i in 0 .. Length(observable) - 1) {
            
            if (observable[i] == PauliY) {
                set yCount = yCount + 1;
            }
        }
        
        return yCount;
    }
    
}


