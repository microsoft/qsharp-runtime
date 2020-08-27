// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Documentation {

    /// # Summary
    /// Used to denote the summary for a callable or type declaration.
    @Attribute()
    newtype Summary = String;

    /// # Summary
    /// Used to denote the description of a callable or type declaration.
    @Attribute()
    newtype Description = String;

    /// # Summary
    /// Used to denote remarks about a callable or type declaration.
    @Attribute()
    newtype Remarks = String;

    /// # Summary
    /// Used to denote a related link for a callable or type declaration.
    /// May appear multiple times.
    @Attribute()
    newtype SeeAlso = String;

    /// # Summary
    /// Used to denote references and citations for a callable or type declaration.
    @Attribute()
    newtype References = String;

    /// # Summary
    /// Used to denote a usage example for a callable or type declaration.
    /// May appear multiple times.
    @Attribute()
    newtype Example = String;

    /// # Summary
    /// Used to denote a single input to a function or operation.
    /// May appear once for each input.
    @Attribute()
    newtype Input = (
        Name: String,
        Summary: String
    );

    /// # Summary
    /// Used to denote the output returned from a function or operation.
    @Attribute()
    newtype Output = (
        Name: String,
        Summary: String
    );

    /// # Summary
    /// Used to denote a single type parameter to a function or operation.
    /// May appear once for each type parameter.
    @Attribute()
    newtype TypeParameter = (
        Name: String,
        Summary: String
    );

}
