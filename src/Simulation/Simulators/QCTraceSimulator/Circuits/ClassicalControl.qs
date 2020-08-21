// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits
{
    open Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Implementation;

    // Private helper operations.
    operation ApplyIfElseIntrinsic(measurementResult : Result, onResultZeroOp : (Unit => Unit) , onResultOneOp : (Unit => Unit)) : Unit {
        Interface_ApplyIfElse(measurementResult, onResultZeroOp, onResultOneOp);
    }

    operation ApplyIfElseIntrinsicA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Adj) , onResultOneOp : (Unit => Unit is Adj)) : Unit is Adj {
        Interface_ApplyIfElseA(measurementResult, onResultZeroOp, onResultOneOp);
    }

    operation ApplyIfElseIntrinsicC(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl) , onResultOneOp : (Unit => Unit is Ctl)) : Unit is Ctl {
        Interface_ApplyIfElseC(measurementResult, onResultZeroOp, onResultOneOp);
    }

    operation ApplyIfElseIntrinsicCA(measurementResult : Result, onResultZeroOp : (Unit => Unit is Ctl + Adj) , onResultOneOp : (Unit => Unit is Ctl + Adj)) : Unit is Ctl + Adj {
        Interface_ApplyIfElseCA(measurementResult, onResultZeroOp, onResultOneOp);
    }


    // Private helper operations.
    operation ApplyConditionallyIntrinsic(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit) , onNonEqualOp : (Unit => Unit)) : Unit {
        Interface_ApplyConditionally(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
    }

    operation ApplyConditionallyIntrinsicA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Adj) , onNonEqualOp : (Unit => Unit is Adj)) : Unit is Adj {
        Interface_ApplyConditionallyA(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
    }

    operation ApplyConditionallyIntrinsicC(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl) , onNonEqualOp : (Unit => Unit is Ctl)) : Unit is Ctl {
        Interface_ApplyConditionallyC(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
    }

    operation ApplyConditionallyIntrinsicCA(measurementResults : Result[], resultsValues : Result[], onEqualOp : (Unit => Unit is Ctl + Adj) , onNonEqualOp : (Unit => Unit is Ctl + Adj)) : Unit is Ctl + Adj {
        Interface_ApplyConditionallyCA(measurementResults, resultsValues, onEqualOp, onNonEqualOp);
    }

}
