// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Random {

    internal operation Delay<'TInput, 'TOutput>(op : ('TInput => 'TOutput), input : 'TInput, delay : Unit) : 'TOutput {
        return op(input);
    }
}
