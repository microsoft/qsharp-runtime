// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Returns the natural logarithmic base to double-precision.
    ///
    /// # Output
    /// A double-precision approximation of the natural logarithic base,
    /// $e \approx 2.7182818284590452354$.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.PI
    function E() : Double {
        return 2.7182818284590452354;
    }

    /// # Summary
    /// Represents the ratio of the circumference of a circle to its diameter.
    ///
    /// # Ouptut
    /// A double-precision approximation of the the circumference of a circle
    /// to its diameter, $\pi \approx 3.14159265358979323846$.
    ///
    /// # See Also
    /// - Microsoft.Quantum.Math.E
    function PI() : Double {
        return 3.14159265358979323846;
    }

}
