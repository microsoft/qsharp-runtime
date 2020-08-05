// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorPrimitivesTests {
    
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.TestSuite;
    open Microsoft.Quantum.Arrays;
    

    function MaxControls() : Int {
        return 3;
    }

    function MaxQubitsWidth() : Int {
        return 3;
    }

    function NumberOfTestRepetitions() : Int {
        return 1;
    }

    function AnglesToTest() : Double[] {
        let pi = Microsoft.Quantum.Math.PI();
        return [
            0.0, 
            0.1,
            pi/8.0,
            pi/4.0,
            pi/2.0,
            3.0 * pi/4.0,
            pi,
            5.0 * pi/4.0,
            3.0 * pi/2.0,
            2.0 * pi,
            3.0 * pi,
            4.0 * pi,
            0.1984 
        ];
    }

    function FractionsToTest() : (Int,Int)[] {
        return [
            (0,-1),
            (1,1),
            (-1,1),
            (1,2),
            (3,2),
            (-3,2),
            (-1,2),
            (1,3),
            (-1,3),
            (3,4),
            (-1,4),
            //(1, 9223372036854775807),
            (1, 13),
            (1, -13)
        ];
    }

    function FractionsToTestLarge() : (Int, Int)[] {
        mutable fractions =  FractionsToTest(); //new (Int, Int)[0];
        for (i in 0 .. 4) {
            for (j in -2 ^ i .. 2 ^ i) {
                set fractions = fractions + [(j, i)];
			}
		}
        return fractions;
	}

    function PaulisToTest() : Pauli[] {
        return [PauliI, PauliX, PauliY, PauliZ];
    }

    newtype TestEntry = (
        Actual: (Qubit => Unit is Adj + Ctl),
        Expected: (Qubit => Unit is Adj + Ctl), 
        Description: String
    );

    operation ParamFreeSingleQubitIntrinsics() : TestEntry[] {
		return [
            TestEntry(_Decomposer_H, H, "H"),
            TestEntry(_Decomposer_X, X, "X"),
            TestEntry(_Decomposer_Z, Z, "Z"),
            TestEntry(_Decomposer_S, S, "S"),
            TestEntry(_Decomposer_Y, Y, "Y"),
            TestEntry(_Decomposer_T, T, "T")
        ];
    }

    operation DoubleParamSingleQubitIntrinsics() : TestEntry[] {
        let ops = [
            (_Decomposer_Rz, Rz, "Rz"),
            (_Decomposer_Ry, Ry, "Ry"),
            (_Decomposer_Rx, Rx, "Rx"),
            (_Decomposer_R1, R1, "R1")
        ];
        mutable tests = new TestEntry[0];
        for((actual, expected, name) in ops) {
            for (angle in AnglesToTest()) {
                let message = $"{name}({angle})";
                set tests = tests + [TestEntry(actual(angle, _), expected(angle, _), message)];
		    }
		}
        return tests;
	}

    operation PauliDoubleParamSingleQubitIntrinsics() : TestEntry[] {
        let ops = [
            (_Decomposer_R, R, "R"),
        ];
        mutable tests = new TestEntry[0];
        for((actual, expected, name) in ops) {
            for (angle in AnglesToTest()) {
                for(pauli in PaulisToTest()) {
                    let message = $"{name}({pauli}, {angle})";
                    set tests = tests + [TestEntry(actual(pauli, angle, _), expected(pauli, angle, _), message)];
				}
		    }
		}
        return tests;
	}

    operation FracParamSingleQubitIntrinsics() : TestEntry[] {
        let ops = [
            (_Decomposer_R1Frac, R1Frac, "R1Frac")
        ];
        mutable tests = new TestEntry[0];
        for((actual, expected, name) in ops) {
            for ((num, denom) in FractionsToTestLarge()) {
                let message = $"{name}({num}, {denom})";
                set tests = tests + [TestEntry(actual(num, denom, _), expected(num, denom, _), message)
                ];
		    }
		}
        return tests;
	}

    operation PauliFracParamSingleQubitIntrinsics() : TestEntry[] {
        let ops = [
            (_Decomposer_RFrac, RFrac, "RFrac")
        ];
        mutable tests = new TestEntry[0];
        for((actual, expected, name) in ops) {
            for ((num, denom) in FractionsToTestLarge()) {
                for(pauli in PaulisToTest()) {
                    let message = $"{name}({pauli}, {num}, {denom})";
                    set tests = tests + [TestEntry( actual(pauli, num, denom, _), expected(pauli, num, denom, _), message)
                    ];
				}
		    }
		}
        return tests;
	}

    operation AllSingleQubitIntrinsics() : TestEntry[] {
        return ParamFreeSingleQubitIntrinsics() + DoubleParamSingleQubitIntrinsics() + PauliDoubleParamSingleQubitIntrinsics()
            + FracParamSingleQubitIntrinsics() + PauliFracParamSingleQubitIntrinsics();
	}

     operation SingleQubitOperationsWithControlsTest () : Unit {
		let testList = AllSingleQubitIntrinsics();
        for (testEntry in testList) {
            Message($"TESTING: {testEntry::Description}");
            ControlledQubitOperationTester(testEntry::Actual, testEntry::Expected, 3);
        }
        
        for (testEntry in testList) {
            Message($"TESTING: {testEntry::Description}");
            ControlledQubitOperationTester(testEntry::Actual, testEntry::Expected, 5);
        }
    }
    
    operation SingleQubitRotationsWithOneControlTest () : Unit {
        
        mutable testList = [
            (_Decomposer_R1(0.1,_), R1(0.1,_)),  
            (_Decomposer_Rz(0.1,_), Rz(0.1,_)),
            (_Decomposer_Ry(0.1,_), Ry(0.1,_)),
            (_Decomposer_Rx(0.1,_), Rx(0.1,_))
        ];

        let paulies = [PauliI, PauliX, PauliY, PauliZ];
        
        for (k in 0 .. 2) {
            let pauli = paulies[k];
            let phi = 0.1;
            let opExpected = Exp([paulies[k]], phi, _);
            let opActual = _Decomposer_Exp([paulies[k]], phi, _);
            set testList = testList + [
                (OnOneQubitAC(opActual, _), 
                OnOneQubitAC(opExpected, _)),
                (_Decomposer_R(pauli, phi, _), 
                R(pauli, phi, _))
            ];
        }
        
        for (i in 0 .. 4) {
            
            for (j in -2 ^ i .. 2 ^ i) {
                set testList = testList + [
                    (_Decomposer_R1Frac(j, i, _), 
                    R1Frac(j, i, _))
                ];
                
                for (k in 0 .. 2) {
                    let opExpected = ExpFrac([paulies[k]], j, i, _);
                    let opActual = _Decomposer_ExpFrac([paulies[k]], j, i, _);
                    set testList = testList + [
                        (_Decomposer_RFrac(paulies[k], j, i, _), 
                        RFrac(paulies[k], j, i, _)),
                        (OnOneQubitAC(opActual, _), 
                        OnOneQubitAC(opExpected, _))
                    ];
                }
            }
        }
        
        for (i in 0 .. Length(testList) - 1) {
            let (actual, expected) = testList[i];
            ControlledQubitOperationTester(actual, expected, 2);
        }
    }
}


