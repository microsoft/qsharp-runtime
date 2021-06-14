// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Represents a complex number by its real and imaginary components.
    /// The first element of the tuple is the real component, the second one - the imaginary component.
    ///
    /// # Example
    /// The following snippet defines the imaginary unit $0 + 1i$:
    /// ```qsharp
    /// let imagUnit = Complex(0.0, 1.0);
    /// ```
    newtype Complex = (Real: Double, Imag: Double);

}
