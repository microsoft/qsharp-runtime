// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    operation AlwaysFail() : Unit is Adj + Ctl{
		Fail();
	}
    
    operation AlwaysFail1() : Unit is Adj + Ctl{
        AlwaysFail();
    }
    operation AlwaysFail2() : Unit is Adj + Ctl {
        Controlled AlwaysFail1(new Qubit[0],());
    }
    operation AlwaysFail3() : Unit is Adj + Ctl {
        Adjoint AlwaysFail2();
    }

    operation AlwaysFail4() : Unit is Adj + Ctl {
        Adjoint AlwaysFail3();
    }

    operation GenericFail<'T,'U>( a : 'T, b : 'U ) :  Unit is Adj + Ctl {
        AlwaysFail();
    }

    operation GenericFail1() :  Unit is Adj + Ctl {
        GenericFail(5,6);
    }

    operation PartialFail( a : Int, b : Int ) : Unit is Adj + Ctl {
        AlwaysFail();
    }

    operation PartialFail1() : Unit is Adj + Ctl {
        let op = PartialFail(0,_);
        op(2);
    }

    operation PartialAdjFail1() : Unit is Adj + Ctl {
        let op = PartialFail(0,_);
        Adjoint op(2);
    }

    operation PartialCtlFail1() : Unit is Adj + Ctl {
        let op = PartialFail(0,_);
        Controlled op(new Qubit[0], 2);
    }

    operation GenericAdjFail1() :  Unit is Adj + Ctl {
        Adjoint GenericFail(5,6);
    }

    operation GenericCtlFail1() :  Unit is Adj + Ctl {
        Controlled GenericFail( new Qubit[0], (5,6));
    }

    function Fail() : Unit {
        fail "Always fail";
    }

    operation RecursionFail( a : Int) : Unit is Adj {
        if ( a >= 1 ) 
        {
            RecursionFail(a-1);
        }
        else 
        {
            Fail();
        }
    }

    operation RecursionFail1() : Unit {
        RecursionFail(2);
    }

	operation DivideBy0() : Int {
		let z = 0;
		return 3 / z;
	}

	operation AllGood() : Unit  {
		Microsoft.Quantum.Intrinsic.Message("All good!");
	}

	operation AllGood1() : Unit  {
		AllGood();
	}

    operation AllocateQubit2 () : Unit {
        using (q = Qubit()) {
            Microsoft.Quantum.Intrinsic.H(q);
            Microsoft.Quantum.Diagnostics.AssertMeasurementProbability(
                [PauliZ], [q], One, 1.0, "", 1e-5
            );
        }
    }
}
