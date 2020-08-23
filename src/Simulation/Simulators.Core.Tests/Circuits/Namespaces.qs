// // Copyright (c) Microsoft Corporation. All rights reserved.
// // Licensed under the MIT License.

// Will cause compilation failure if callable type references in generated C# aren't
// prepended with "global::".
namespace Issue46 {

    operation ReturnZero () : Result {
        
        return Zero;
    }

}

namespace Microsoft.Quantum.Tests.Namespaces.Issue46 {

    operation TestOp () : Result {
        
        return Issue46.ReturnZero();
    }

}
