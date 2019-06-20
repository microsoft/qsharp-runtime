// these are all the static methods and const fields  form System.Math class of .NET CLR
// that are not exposed as language operators and are relevant within type System.
// If there are two versions of the function for Int and Double types, the corresponding
// functions have suffix I or D. ExpD also has a suffix to avoid name clash with Primitives.Exp.

namespace Microsoft.Quantum.Math {

    /// # Summary
    /// Returns the natural logarithmic base $e$.
    ///
    /// # Remarks
    /// See [System.Math.E](https://docs.microsoft.com/dotnet/api/system.math.e) for more details.
    function E () : Double {
        body intrinsic;
    }

    /// # Summary
    /// Represents the ratio of the circumference of a circle to its diameter, specified by the constant, π.
    ///
    /// # Remarks
    /// See [System.Math.PI](https://docs.microsoft.com/dotnet/api/system.math.pi) for more details.
    function PI () : Double {
        body intrinsic;
    }

}
