// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.TestSuite.Math {
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Math;
    open Microsoft.Quantum.Convert;
    
    
    newtype RowMajorMatrix = Complex[][];
    
    newtype RowVector = Complex[];
    
    newtype Vector = Complex[];
    
    
    function ZeroState () : Vector {
        return Vector([OneC(), ZeroC()]);
    }
    
    
    function OneState () : Vector {
        return Vector([ZeroC(), OneC()]);
    }
    
    
    function PlusState () : Vector {
        return Vector([Complex(1.0 / Sqrt(2.0), 0.0), Complex(1.0 / Sqrt(2.0), 0.0)]);
    }
    
    
    function IState () : Vector {
        return Vector([Complex(1.0 / Sqrt(2.0), 0.0), Complex(0.0, 1.0 / Sqrt(2.0))]);
    }
    
    
    function NumberOfTestStates () : Int {
        return 4;
    }
    
    
    function NumberOfComputationalBasisTestStates () : Int {
        return 2;
    }
    
    
    function NumberOfPaulies () : Int {
        return 4;
    }
    
    
    function TensorProduct (vector1 : Vector, vector2 : Vector) : Vector {
        let len1 = Length(vector1!);
        let len2 = Length(vector2!);
        
        if (len1 == 0) {
            fail $"The tensor product is not defined when the length of vector1 is 0";
        }
        
        if (len2 == 0) {
            fail $"The tensor product is not defined when the length of vector2 is 0";
        }
        
        mutable res = new Complex[Length(vector1!) * Length(vector2!)];
        
        for (i in 0 .. len1 - 1) {
            
            for (j in 0 .. len2 - 1) {
                set res = res w/ i * len2 + j <- TimesC(vector1![i], vector2![j]);
            }
        }
        
        return Vector(res);
    }
    
    
    function StateIdToVector (id : Int) : Vector {
        let stateMaps = [ZeroState, OneState, PlusState, IState];
        return stateMaps[id]();
    }
    
    
    function StateById (stateId : Int[]) : Vector {
        
        
        if (Length(stateId) == 0) {
            fail $"Length of stateId must be at least 1";
        }
        
        mutable res = StateIdToVector(stateId[0]);
        
        for (i in 1 .. Length(stateId) - 1) {
            set res = TensorProduct(StateIdToVector(stateId[i]), res);
        }
        
        return res;
    }
    
    
    function TensorProductOfArray (states : Vector[]) : Vector {
        
        
        if (Length(states) == 0) {
            fail $"Length of stateId must be at least 1";
        }
        
        mutable res = states[0];
        
        for (i in 1 .. Length(states) - 1) {
            set res = TensorProduct(states[i], res);
        }
        
        return res;
    }
    
    
    function PauliById (pauliId : Int[]) : Pauli[] {
        
        let paulies = [PauliX, PauliY, PauliZ, PauliI];
        mutable arr = new Pauli[Length(pauliId)];
        
        for (i in 0 .. Length(pauliId) - 1) {
            set arr = arr w/ i <- paulies[pauliId[i]];
        }
        
        return arr;
    }
    
    
    /// # Summary
    /// Returns the expectation of measuring observable on the qubit in state given by stateId.
    ///
    /// # Remarks
    /// The correspondence between
    /// value of stateId and the qubit state is the following:
    /// 0 -- |0⟩
    /// 1 -- |1⟩
    /// 2 -- |+⟩
    /// 3 -- |i⟩ ( +1 eigenstate of Pauli Y )
    function ExpectedValueForPauli (observable : Pauli, stateId : Int) : Double {
        if (stateId < 0 or stateId > 3) {
            fail $"stateId must have value between 0 and 3";
        }
        
        let XpauliArr = [0.0, 0.0, 1.0, 0.0];
        let YpauliArr = [0.0, 0.0, 0.0, 1.0];
        let ZpauliArr = [1.0, -1.0, 0.0, 0.0];
        
        if (observable == PauliI) {
            return 1.0;
        } elif (observable == PauliX) {
            return XpauliArr[stateId];
        } elif (observable == PauliY) {
            return YpauliArr[stateId];
        } elif (observable == PauliZ) {
            return ZpauliArr[stateId];
        }
        
        fail $"this line should never be reached";
    }
    
    
    /// <summary>
    /// Expectation of the observable P₁⊗…⊗Pₙ with respect to state |ψ₁⟩⊗…⊗|ψₙ⟩ given by stateId array.
    /// The correspondence between
    /// the values of stateId array and the qubit state is the following:
    /// 0 -- |0⟩
    /// 1 -- |1⟩
    /// 2 -- |+⟩
    /// 3 -- |i⟩ ( +1 eigenstate of Pauli Y )
    /// </summary>
    function ExpectedValueForMultiPauliByStateId (observable : Pauli[], stateId : Int[]) : Double {
        
        
        if (Length(observable) != Length(stateId)) {
            fail $"arrays observable and stateId must have the same length";
        }
        
        //note that writing 1.0 here will cause code gen to fail.
        mutable res = IntAsDouble(1);
        
        for (i in 0 .. Length(observable) - 1) {
            set res = res * ExpectedValueForPauli(observable[i], stateId[i]);
        }
        
        return res;
    }
    
    
    function DotProduct (vector1 : Complex[], vector2 : Vector) : Complex {
        
        mutable res = ZeroC();
        let dimension = Length(vector1);
        
        if (dimension != Length(vector2!)) {
            fail $"vector1 and vector2 must have he same dimension";
        }
        
        for (i in 0 .. dimension - 1) {
            set res = PlusC(res, TimesC(vector1[i], vector2![i]));
        }
        
        return res;
    }
    
    
    function HermitianProduct (vector1 : Vector, vector2 : Vector) : Complex {
        
        mutable res = ZeroC();
        let dimension = Length(vector1!);
        
        if (dimension != Length(vector2!)) {
            fail $"vector1 and vector2 must have he same dimension";
        }
        
        for (i in 0 .. dimension - 1) {
            set res = PlusC(res, TimesC(ConjugateC(vector1![i]), vector2![i]));
        }
        
        return res;
    }
    
    
    function ApplyMatrix (matrixRowMajor : RowMajorMatrix, columnVector : Vector) : Vector {
        
        let rowCount = Length(matrixRowMajor!);
        mutable res = new Complex[rowCount];
        
        for (i in 0 .. rowCount - 1) {
            set res = res w/ i <- DotProduct(matrixRowMajor![i], columnVector);
        }
        
        return Vector(res);
    }
    
    
    function AssertUnitaryMatrix (unitaryMatrix : RowMajorMatrix) : Unit {
        
        let rowCount = Length(unitaryMatrix!);
        
        for (i in 0 .. rowCount - 1) {
            
            if (Length(unitaryMatrix![i]) != rowCount) {
                fail $"matrix is not square";
            }
            
            let norm = HermitianProduct(Vector(unitaryMatrix![i]), Vector(unitaryMatrix![i]));
            
            if (AbsSquaredC(PlusC(norm, MinusC(OneC()))) >= Accuracy()) {
                fail $"one of the rows does not have norm 1";
            }
        }
        
        for (i in 0 .. rowCount - 1) {
            
            for (j in 0 .. rowCount - 1) {
                
                if (i != j) {
                    let hermProd = HermitianProduct(Vector(unitaryMatrix![i]), Vector(unitaryMatrix![j]));
                    
                    if (AbsSquaredC(hermProd) >= Accuracy()) {
                        fail $"some of the matrix rows are non-orthogonal with respect to hermitian product";
                    }
                }
            }
        }
    }
    
    
    function IdentityMatrix (size : Int) : RowMajorMatrix {
        
        mutable result = new Complex[][size];
        
        for (i in 0 .. size - 1) {
            set result = result w/ 
                i <- (new Complex[size] w/ i <- OneC());
        }
        
        return RowMajorMatrix(result);
    }
    
    
    function DirectSum (left : RowMajorMatrix, right : RowMajorMatrix) : RowMajorMatrix {
        
        let leftDimension = Length(left!);
        let rightDimension = Length(right!);
        let resultDimension = leftDimension + rightDimension;
        mutable result = new Complex[][resultDimension];
        
        for (i in 0 .. resultDimension - 1) {
            mutable row = new Complex[resultDimension];
            
            if (i < leftDimension) {
                
                for (j in 0 .. leftDimension - 1) {
                    set row = row w/ j <- left![i][j];
                }
            }
            else {
                
                for (j in 0 .. rightDimension - 1) {
                    set row = row w/ j + leftDimension <- right![i - leftDimension][j];
                }
            }
            set result = result w/ i <- row;
        }
        
        return RowMajorMatrix(result);
    }
    
    
    function ControlledMatrix (numberOfControls : Int, matrix : RowMajorMatrix) : RowMajorMatrix {
        
        
        if (numberOfControls < 1) {
            fail $"Number of controls must be at least 1";
        }
        
        let (matrixQubits, nonPowerOfTwo) = PAdicValuation(Length(matrix!), 2);
        
        if (nonPowerOfTwo != 1) {
            fail $"Dimension of the matrix must be power of two";
        }
        
        let identityMatrixDimension = 2 ^ (matrixQubits + numberOfControls) - Length(matrix!);
        return DirectSum(IdentityMatrix(identityMatrixDimension), matrix);
    }
    
}


