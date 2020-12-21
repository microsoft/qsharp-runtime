// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Core{

    @Attribute()
    newtype Attribute = Unit;

    @Attribute()
    newtype Inline = Unit;

    @Attribute()
    newtype EntryPoint = Unit;

}

namespace Microsoft.Quantum.Targeting {

    @Attribute()
    newtype TargetInstruction = String;
}
