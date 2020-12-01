namespace Microsoft.Quantum.Core
{
    /// # Summary
    /// Enables to emulate an operation with an alternative operation for a given simulator
    ///
    /// # Named Items
    /// ## AlternativeOperation
    /// Fully qualified name of alternative operation to emulate operation with.
    ///
    /// ## InSimulator
    /// One of `QuantumSimulator`, `ToffoliSimulator`, or `ResourcesEstimator`, or a fully qualified name
    /// of a custom simulator.
    @Attribute()
    newtype EmulateWith = (AlternativeOperation : String, InSimulator : String);
}
