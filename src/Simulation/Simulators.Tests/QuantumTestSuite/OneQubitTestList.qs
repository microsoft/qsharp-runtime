// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite.Math;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    
    newtype SingleQubitOperationDescription = ((Qubit => Unit is Adj + Ctl), RowMajorMatrix, Int, Bool);
    
    
    function FixesComputationalBasis (record : SingleQubitOperationDescription) : Bool {
        
        let (operationMap, operationMatrix, levelOfCliffordHierarchy, fixesComputationalBasis) = record!;
        return fixesComputationalBasis;
    }
    
    
    function OperationMap (record : SingleQubitOperationDescription) : (Qubit => Unit is Adj + Ctl) {
        
        let (operationMap, operationMatrix, levelOfCliffordHierarchy, fixesComputationalBasis) = record!;
        return operationMap;
    }
    
    
    function LevelOfCliffordHierarchy (record : SingleQubitOperationDescription) : Int {
        
        let (operationMap, operationMatrix, levelOfCliffordHierarchy, fixesComputationalBasis) = record!;
        return levelOfCliffordHierarchy;
    }
    
    
    function OperationMatrix (record : SingleQubitOperationDescription) : RowMajorMatrix {
        
        let (operationMap, operationMatrix, levelOfCliffordHierarchy, fixesComputationalBasis) = record!;
        return operationMatrix;
    }
    
    
    function OutsideOfClifforfdHirerarchy () : Int {
        
        return 0x7FFFFFFFFFFFFFFF;
    }
    
    
    function ContinuousParameterTestList () : Double[] {
        
        return [0.1, PI() / 3.0];
    }
    
    
    function RotationsWithDoubleParameterTestList () : SingleQubitOperationDescription[] {
        
        let list = ContinuousParameterTestList();
        mutable res = new SingleQubitOperationDescription[0];
        
        for (phi in list) {
            let level = OutsideOfClifforfdHirerarchy();
            set res = res + [
                SingleQubitOperationDescription(Rx(phi, _), ExpPauliMatrix(PauliX, -phi / 2.0), level, false), 
                SingleQubitOperationDescription(Ry(phi, _), ExpPauliMatrix(PauliY, -phi / 2.0), level, false), 
                SingleQubitOperationDescription(Rz(phi, _), ExpPauliMatrix(PauliZ, -phi / 2.0), level, true), 
                SingleQubitOperationDescription(R1(phi, _), R1Matrix(phi), level, true)
            ];
            
            //TODO: add PauliI here when the bugs are fixed
            let paulies = [PauliX, PauliY, PauliZ];
            
            for (j in 0 .. Length(paulies) - 1) {
                let pauli = paulies[j];
                let fixesCompBasis = j >= 2;
                let expOperation = Exp([pauli], phi, _);
                set res = res + [
                    SingleQubitOperationDescription(R(pauli, phi, _), ExpPauliMatrix(pauli, -phi / 2.0), level, fixesCompBasis), 
                    SingleQubitOperationDescription(OnOneQubitAC(expOperation, _), ExpPauliMatrix(pauli, phi), level, fixesCompBasis)
                ];
            }
        }
        
        return res;
    }
    
    
    function FracParametersTestList () : (Int, Int)[] {
        
        mutable res = new (Int, Int)[0];
        
        for (i in 0 .. MaxDenomiantorPowerToTest()) {
            for (j in 0 .. 2 ^ i) {
                set res = res + [(j, i)];
            }
        }
        
        return res;
    }
    
    
    function R1FracCliffordHierarchyLevel (num : Int, denomPower : Int) : Int {
        if (num == 0) {
            return 0;
        }
        
        let (numPowerOfTwo, reducedNum) = PAdicValuation(num, 2);
        let denomPowerActual = denomPower - numPowerOfTwo;
        
        return denomPowerActual <= 0 ? 0 | denomPowerActual;
    }
    
    
    function RotationsWithFracParameterTestList () : SingleQubitOperationDescription[] {
        
        let list = FracParametersTestList();
        mutable res = new SingleQubitOperationDescription[0];
        
        for (frac in list) {
            let (num, denomPower) = frac;
            let r1Level = R1FracCliffordHierarchyLevel(frac);
            let rzLevel = MaxI(0, r1Level - 1);
            let r1Phi = (PI() * IntAsDouble(num)) * PowD(IntAsDouble(2), IntAsDouble(-denomPower));
            set res = res + [SingleQubitOperationDescription(R1Frac(num, denomPower, _), R1Matrix(r1Phi), r1Level, true)];
            
            // TODO: add PauliI here when the bugs are fixed
            let paulies = [PauliI, PauliY, PauliZ];
            
            for (j in 0 .. Length(paulies) - 1) {
                let pauli = paulies[j];
                let fixesCompBasis = j >= 2;
                let expOperation = ExpFrac([pauli], num, denomPower, _);
                set res = res + [SingleQubitOperationDescription(RFrac(pauli, num, denomPower, _), ExpPauliMatrix(pauli, r1Phi), rzLevel, fixesCompBasis), SingleQubitOperationDescription(OnOneQubitAC(expOperation, _), ExpPauliMatrix(pauli, r1Phi), rzLevel, fixesCompBasis)];
            }
        }
        
        return res;
    }
    
    
    function OneQubitTestList () : SingleQubitOperationDescription[] {
        
        mutable list = [
            (X, PauliMatrix(PauliX), 0, true),
            (Y, PauliMatrix(PauliY), 0, true),
            (Z, PauliMatrix(PauliZ), 0, true),
            (H, HMatrix(), 1, false),
            (S, SMatrix(), 1, true),
            (T, TMatrix(), 2, true)
        ];
        mutable result = new SingleQubitOperationDescription[Length(list)];
        
        for (i in 0 .. Length(list) - 1) {
            set result = result w/ i <- SingleQubitOperationDescription(list[i]);
        }
        
        set result = result + RotationsWithDoubleParameterTestList();
        set result = result + RotationsWithFracParameterTestList();
        return result;
    }
    
}


