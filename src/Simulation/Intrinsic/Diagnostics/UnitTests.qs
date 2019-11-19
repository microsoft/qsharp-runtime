// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Diagnostics {

    /// # Summary
    /// Compiler recognized attribute used to mark a unit test.
    /// 
    /// # Input
    /// ## ExecutionTarget
    /// The name of the target to execute the test on. 
    /// Possible values are: QuantumSimulator, TraceSimulator, ToffoliSimulator
    ///
    @Attribute()
    newtype TestOperation = (ExecutionTarget : String);
}


