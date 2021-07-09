namespace Quantum.MicrosoftSimulatorExe {

    open Microsoft.Quantum.Arrays;
    open Microsoft.Quantum.Canon;
    open Microsoft.Quantum.Intrinsic;
    open Microsoft.Quantum.Measurement;

    
    @EntryPoint()
    operation HelloQ () : Unit {
        use qubits = Qubit[10]
        {
            ApplyToEachA(H, qubits);
            let resuls = ForEach(MResetZ, qubits);
        }
    }
}
