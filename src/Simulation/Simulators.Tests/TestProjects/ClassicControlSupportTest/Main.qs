namespace Quantum.ClassicControlSupportTest {
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Simulation.QuantumProcessor.Extensions;
    @EntryPoint()
    operation Main () : Unit {
        using (q = Qubit())
        {
            H(q);
            let result = M(q);
            ApplyIfOne(result, (X, q));
        }
    }
}
