// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    open Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;

    // Private helper operations.
    operation ApplyIfElseIntrinsic(measurementResult : Result, onResultZeroOp : (Unit => Unit) , onResultOneOp : (Unit => Unit)) : Unit {
        body (...) {
            Interface_ApplyIfElse(measurementResult, onResultZeroOp, onResultOneOp);
        }
    }

    operation ApplyIfElseIntrinsicA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Adj) , onResultOneOp : (Unit => Unit is Adj)) : Unit is Adj {
        body (...) {
            Interface_ApplyIfElse(measurementResult, onResultZeroOp, onResultOneOp);
        }
        
        adjoint (...) {
            Interface_ApplyIfElseA(measurementResult, onResultZeroOp, onResultOneOp);
        }
    }

    operation ApplyIfElseIntrinsicC(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl) , onResultOneOp : (Unit => Unit is Ctl)) : Unit is Ctl {
        body (...) {
            Interface_ApplyIfElse(measurementResult, onResultZeroOp, onResultOneOp);
        }

        controlled (ctrls, ...) {
            Interface_ApplyIfElseC(ctrls, measurementResult, onResultZeroOp, onResultOneOp);
        }
    }

    operation ApplyIfElseIntrinsicCA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl + Adj) , onResultOneOp : (Unit => Unit is Ctl + Adj)) : Unit is Ctl + Adj {
        body (...) {
            Interface_ApplyIfElse(measurementResult, onResultZeroOp, onResultOneOp);
        }
        
        adjoint (...) {
            Interface_ApplyIfElseA(measurementResult, onResultZeroOp, onResultOneOp);
        }

        controlled (ctrls, ...) {
            Interface_ApplyIfElseC(ctrls, measurementResult, onResultZeroOp, onResultOneOp);
        }

        controlled adjoint (ctrls, ...) {
            Interface_ApplyIfElseCA(ctrls, measurementResult, onResultZeroOp, onResultOneOp);
        }
    }


    // Private helper operations.
    operation ApplyConditionallyIntrinsic(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit) , onNonEqualOp : (Unit => Unit)) : Unit {
        body (...) {
            Interface_ApplyConditionally(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
    }

    operation ApplyConditionallyIntrinsicA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Adj) , onNonEqualOp : (Unit => Unit is Adj)) : Unit is Adj {
        body (...) {
            Interface_ApplyConditionally(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
        
        adjoint (...) {
            Interface_ApplyConditionallyA(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
    }

    operation ApplyConditionallyIntrinsicC(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl) , onNonEqualOp : (Unit => Unit is Ctl)) : Unit is Ctl {
        body (...) {
            Interface_ApplyConditionally(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }

        controlled (ctrls, ...) {
            Interface_ApplyConditionallyC(ctrls, measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
    }

    operation ApplyConditionallyIntrinsicCA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl + Adj) , onNonEqualOp : (Unit => Unit is Ctl + Adj)) : Unit is Ctl + Adj {
        body (...) {
            Interface_ApplyConditionally(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
        
        adjoint (...) {
            Interface_ApplyConditionallyA(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }

        controlled (ctrls, ...) {
            Interface_ApplyConditionallyC(ctrls, measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }

        controlled adjoint (ctrls, ...) {
            Interface_ApplyConditionallyCA(ctrls, measurementResults, resultsValues, onEqualOp, onNonEqualOp);
        }
    }
    
}
