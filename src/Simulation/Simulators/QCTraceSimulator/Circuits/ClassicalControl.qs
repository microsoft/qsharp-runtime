// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    // Private helper operations.
    operation ApplyIfElseIntrinsic(measurementResult : Result, onResultZeroOp : (Unit => Unit) , onResultOneOp : (Unit => Unit)) : Unit {
        body (...) {
            // ToDo
        }
    }

    operation ApplyIfElseIntrinsicA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Adj) , onResultOneOp : (Unit => Unit is Adj)) : Unit {
        body (...) {
            // ToDo
        }
        
        adjoint (...) {
            // ToDo
        }
    }

    operation ApplyIfElseIntrinsicC(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl) , onResultOneOp : (Unit => Unit is Ctl)) : Unit {
        body (...) {
            // ToDo
        }

        controlled (ctrls, ...) {
            // ToDo
        }
    }

    operation ApplyIfElseIntrinsicCA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl + Adj) , onResultOneOp : (Unit => Unit is Ctl + Adj)) : Unit {
        body (...) {
            // ToDo
        }
        
        adjoint (...) {
            // ToDo
        }

        controlled (ctrls, ...) {
            // ToDo
        }

        controlled adjoint (ctrls, ...) {
            // ToDo
        }
    }


    // Private helper operations.
    operation ApplyConditionallyIntrinsic(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit) , onNonEqualOp : (Unit => Unit)) : Unit {
        body (...) {
            // ToDo
        }
    }

    operation ApplyConditionallyIntrinsicA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Adj) , onNonEqualOp : (Unit => Unit is Adj)) : Unit is Adj {
        body (...) {
            // ToDo
        }
        
        adjoint (...) {
            // ToDo
        }
    }

    operation ApplyConditionallyIntrinsicC(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl) , onNonEqualOp : (Unit => Unit is Ctl)) : Unit is Ctl {
        body (...) {
            // ToDo
        }

        controlled (ctrls, ...) {
            // ToDo
        }
    }

    operation ApplyConditionallyIntrinsicCA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl + Adj) , onNonEqualOp : (Unit => Unit is Ctl + Adj)) : Unit is Ctl + Adj {
        body (...) {
            // ToDo
        }
        
        adjoint (...) {
            // ToDo
        }

        controlled (ctrls, ...) {
            // ToDo
        }

        controlled adjoint (ctrls, ...) {
            // ToDo
        }
    }
    
}


