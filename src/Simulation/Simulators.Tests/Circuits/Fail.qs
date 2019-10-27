// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.Tests.Circuits {
    
    operation AlwaysFail() : Unit is Adj + Ctl {
		fail "Always fail";
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

}