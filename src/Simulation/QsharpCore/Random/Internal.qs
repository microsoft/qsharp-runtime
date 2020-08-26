// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {

    // This operation duplicates an operation from the Q# standard libraries
    // and is used to support partially applying all inputs to a given
    // operation without actually executing it.
    internal operation Delay<'TInput, 'TOutput>(op : ('TInput => 'TOutput), input : 'TInput, delay : Unit) : 'TOutput {
        return op(input);
    }
}
