// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    /// An interface for implementing QDK target quantum machines that work on a quantum circuit level. 
    /// </summary>
    /// <remarks>
    /// To implement a target machine that executes quantum commands, implement this interface.
    /// Consider using <see cref="QuantumProcessorBase"/> as a stub for easy impementation of this interface.
    /// Implementors of <see cref="IQuantumProcessor"/> interface do not manage qubits on their own.
    /// All qubit management (allocation, dealocation, etc.) is done by the caller of this interface.
    /// Implementors are notified when qubits are allocated, released, borrowed and returned allowing them to react to these events if necessary.
    /// </remarks>
    public interface IQuantumProcessor
    {
        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.x">Microsoft.Quantum.Intrinsic.X</a> is called in Q#.
        /// When this is invoked, it is expected that the X gate gets applied to the given <paramref name="qubit"/>. The gate is given by matrix X=((0,1),(1,0)).
        /// </summary>
        /// <remarks>
        /// When adjoint of X is called in Q#, this same method is called because X is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void X(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.x">Microsoft.Quantum.Intrinsic.X</a> is called in Q#.
        /// When this is invoked, it is expected that the X gate gets applied to the given <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix X=((0,1),(1,0)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled X is called in Q#, this same method is called because X is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledX(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.y">Microsoft.Quantum.Intrinsic.Y</a> is called in Q#.
        /// When this is invoked, it is expected that the Y gate gets applied to the given <paramref name="qubit"/>. The gate is given by matrix Y=((0,-𝑖),(𝑖,0)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Y is called in Q#, this same method is called because Y is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void Y(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.y">Microsoft.Quantum.Intrinsic.Y</a> is called in Q#.
        /// When this is invoked, it is expected that the Y gate gets applied to the given <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix Y=((0,-𝑖),(𝑖,0)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled Y is called in Q#, this same method is called because Y is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledY(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.z">Microsoft.Quantum.Intrinsic.Z</a> is called in Q#.
        /// When this is invoked, it is expected that the Z gate gets applied to the given <paramref name="qubit"/>. The gate is given by matrix Z=((1,0),(0,-1)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Z is called in Q#, this same method is called because Z is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void Z(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.z">Microsoft.Quantum.Intrinsic.Z</a> is called in Q#.
        /// When this is invoked, it is expected that the Z gate gets applied to the given <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix Z=((1,0),(0,-1)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled Z is called in Q#, this same method is called because Z is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledZ(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.swap">Microsoft.Quantum.Intrinsic.SWAP</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by rule |ψ⟩⊗|ϕ⟩ ↦ |ϕ⟩⊗|ψ⟩ where |ϕ⟩,|ψ⟩ arbitrary one qubit states gets applied.
        /// </summary>
        /// <remarks>
        /// When adjoint of SWAP is called in Q#, this same method is called because SWAP is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit1">First qubit to be swapped.</param>
        /// <param name="qubit2">Second qubit to be swapped.</param>
        void SWAP(Qubit qubit1, Qubit qubit2);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.swap">Microsoft.Quantum.Intrinsic.SWAP</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by rule |ψ⟩⊗|ϕ⟩ ↦ |ϕ⟩⊗|ψ⟩ where |ϕ⟩,|ψ⟩ arbitrary one qubit states gets applied, controlled on <paramref name="controls"/>.
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled SWAP is called in Q#, this same method is called because SWAP is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit1">First qubit to be swapped.</param>
        /// <param name="qubit2">Second qubit to be swapped.</param>
        void ControlledSWAP(IQArray<Qubit> controls, Qubit qubit1, Qubit qubit2);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.h">Microsoft.Quantum.Intrinsic.H</a> is called in Q#.
        /// When this is invoked, it is expected that the Hadamard gate gets applied to <paramref name="qubit"/>. The gate is given by matrix H=((1,1),(1,-1))/√2.
        /// </summary>
        /// <remarks>
        /// When adjoint of H is called in Q#, this same method is called because Hadamard is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void H(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.h">Microsoft.Quantum.Intrinsic.H</a> is called in Q#.
        /// When this is invoked, it is expected that the Hadamard gate gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix H=((1,1),(1,-1))/√2.
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled H is called in Q#, this same method is called because Hadamard is self-adjoint.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledH(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.s">Microsoft.Quantum.Intrinsic.S</a> is called in Q#.
        /// When this is invoked, it is expected that the S gate gets applied to <paramref name="qubit"/>. The gate is given by matrix S=((1,0),(0,𝑖)).
        /// </summary>
        /// <remarks>
        /// When adjoint of S is called in Q#, <see cref="SAdjoint(Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void S(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.s">Microsoft.Quantum.Intrinsic.S</a> is called in Q#.
        /// When this is invoked, it is expected that the S gate gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix S=((1,0),(0,𝑖)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled S is called in Q#, <see cref="ControlledSAdjoint(IQArray{Qubit}, Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledS(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when adjoint <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.s">Microsoft.Quantum.Intrinsic.S</a> is called in Q#.
        /// When this is invoked, it is expected that the S† gate gets applied to <paramref name="qubit"/>. The gate is given by matrix S†=((1,0),(0,-𝑖)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Adjoint S is called in Q#, <see cref="S(Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void SAdjoint(Qubit qubit);

        /// <summary>
        /// Called when controlled adjoint <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.s">Microsoft.Quantum.Intrinsic.S</a> is called in Q#.
        /// When this is invoked, it is expected that the S† gate gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix S†=((1,0),(0,𝑖)).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled S† is called in Q#, <see cref="ControlledS(IQArray{Qubit}, Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledSAdjoint(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.t">Microsoft.Quantum.Intrinsic.T</a> is called in Q#.
        /// When this is invoked, it is expected that the T gate gets applied to <paramref name="qubit"/>. The gate is given by matrix T=((1,0),(0,𝑒𝑥𝑝(𝑖⋅π/4))).
        /// </summary>
        /// <remarks>
        /// When adjoint of T is called in Q#, <see cref="TAdjoint(Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void T(Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.t">Microsoft.Quantum.Intrinsic.T</a> is called in Q#.
        /// When this is invoked, it is expected that the T gate gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix T=((1,0),(0,𝑒𝑥𝑝(𝑖⋅π/4))).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled T is called in Q#, <see cref="ControlledTAdjoint(IQArray{Qubit}, Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledT(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when adjoint <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.t">Microsoft.Quantum.Intrinsic.T</a> is called in Q#.
        /// When this is invoked, it is expected that the T† gate gets applied to <paramref name="qubit"/>. The gate is given by matrix T†=((1,0),(0,𝑒𝑥𝑝(-𝑖⋅π/4))).
        /// </summary>
        /// <remarks>
        /// When adjoint of Adjoint T is called in Q#, <see cref="T(Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void TAdjoint(Qubit qubit);

        /// <summary>
        /// Called when controlled adjoint <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.t">Microsoft.Quantum.Intrinsic.T</a> is called in Q#.
        /// When this is invoked, it is expected that the T† gate gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>. The gate is given by matrix T†=((1,0),(0,𝑒𝑥𝑝(-𝑖⋅π/4))).
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled T† is called in Q#, <see cref="ControlledT(IQArray{Qubit}, Qubit)"/> is called.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledTAdjoint(IQArray<Qubit> controls, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r">Microsoft.Quantum.Intrinsic.R</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(-𝑖⋅<paramref name="theta"/>⋅<paramref name="axis"/>/2) gets applied to <paramref name="qubit"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of R is called in Q#, <see cref="R(Pauli, double, Qubit)"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="axis">Pauli operator to be exponentiated to form the rotation.</param>
        /// <param name="theta">Angle about which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void R(Pauli axis, double theta, Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r">Microsoft.Quantum.Intrinsic.R</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(-𝑖⋅<paramref name="theta"/>⋅<paramref name="axis"/>/2) gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled R is called in Q#, <see cref="ControlledR(IQArray{Qubit}, Pauli, double, Qubit)"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="axis">Pauli operator to be exponentiated to form the rotation.</param>
        /// <param name="theta">Angle about which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledR(IQArray<Qubit> controls, Pauli axis, double theta, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.rfrac">Microsoft.Quantum.Intrinsic.RFrac</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>⋅<paramref name="axis"/>/2^<paramref name="power"/>) gets applied to <paramref name="qubit"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of RFrac is called in Q#, <see cref="RFrac(Pauli, long, long, Qubit)"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="axis">Pauli operator to be exponentiated to form the rotation.</param>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void RFrac(Pauli axis, long numerator, long power, Qubit qubit);

        /// <summary>
        /// Called when a controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.rfrac">Microsoft.Quantum.Intrinsic.RFrac</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>⋅<paramref name="axis"/>/2^<paramref name="power"/>) gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>.
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled RFrac is called in Q#, <see cref="ControlledRFrac(IQArray{Qubit}, Pauli, long, long, Qubit)"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="axis">Pauli operator to be exponentiated to form the rotation.</param>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledRFrac(IQArray<Qubit> controls, Pauli axis, long numerator, long power, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r1">Microsoft.Quantum.Intrinsic.R1</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by matrix ((1,0),(0,𝑒𝑥𝑝(𝑖⋅<paramref name="theta"/>))) gets applied to <paramref name="qubit"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of R1 is called in Q#, <see cref="R1(double, Qubit)"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="theta">Angle about which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void R1(double theta, Qubit qubit);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r">Microsoft.Quantum.Intrinsic.R</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by matrix ((1,0),(0,𝑒𝑥𝑝(𝑖⋅<paramref name="theta"/>))) gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled R1 is called in Q#, <see cref="ControlledR1(IQArray{Qubit}, double, Qubit)"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="theta">Angle about which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledR1(IQArray<Qubit> controls, double theta, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r1frac">Microsoft.Quantum.Intrinsic.R1Frac</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by matrix ((1,0),(0,𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>/2^<paramref name="power"/>))) gets applied to <paramref name="qubit"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of R1Frac is called in Q#, <see cref="R1Frac(long, long, Qubit)"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void R1Frac(long numerator, long power, Qubit qubit);

        /// <summary>
        /// Called when a controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.r1frac">Microsoft.Quantum.Intrinsic.R1Frac</a> is called in Q#.
        /// When this is invoked, it is expected that the gate given by matrix ((1,0),(0,𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>/2^<paramref name="power"/>))) gets applied to <paramref name="qubit"/> controlled on <paramref name="controls"/>.
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled RFrac is called in Q#, <see cref="ControlledR1Frac(IQArray{Qubit}, long, long, Qubit)"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit is to be rotated.</param>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void ControlledR1Frac(IQArray<Qubit> controls, long numerator, long power, Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.exp">Microsoft.Quantum.Intrinsic.Exp</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅<paramref name="theta"/>⋅<paramref name="paulis"/>) gets applied to <paramref name="qubits"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of Exp is called in Q#, <see cref="Exp(IQArray{Pauli}, double, IQArray{Qubit})"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="paulis">Array of single-qubit Pauli values representing a multi-qubit Pauli to be applied.</param>
        /// <param name="theta">Angle about the given multi-qubit Pauli operator by which the target register is to be rotated.</param>
        /// <param name="qubits">Register to apply the exponent to.</param>
        void Exp(IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits);

        /// <summary>
        /// Called when a controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.exp">Microsoft.Quantum.Intrinsic.Exp</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅<paramref name="theta"/>⋅<paramref name="paulis"/>) gets applied to <paramref name="qubits"/> controlled on <paramref name="controls"/>.  
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled Exp is called in Q#, <see cref="ControlledExp(IQArray{Qubit}, IQArray{Pauli}, double, IQArray{Qubit})"/> is called with <paramref name="theta"/> replaced by -<paramref name="theta"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="paulis">Array of single-qubit Pauli values representing a multi-qubit Pauli to be applied.</param>
        /// <param name="theta">Angle about the given multi-qubit Pauli operator by which the target register is to be rotated.</param>
        /// <param name="qubits">Register to apply the exponent to.</param>
        void ControlledExp(IQArray<Qubit> controls, IQArray<Pauli> paulis, double theta, IQArray<Qubit> qubits);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.expfrac">Microsoft.Quantum.Intrinsic.ExpFrac</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>⋅<paramref name="paulis"/>/2^<paramref name="power"/>) gets applied to <paramref name="qubits"/>.
        /// </summary>
        /// <remarks>
        /// When adjoint of ExpFrac is called in Q#, <see cref="ExpFrac(IQArray{Pauli}, long, long, IQArray{Qubit})"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="paulis">Array of single-qubit Pauli values representing a multi-qubit Pauli to be applied.</param>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit register is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit register is to be rotated.</param>
        /// <param name="qubits">Register to apply the exponent to.</param>
        void ExpFrac(IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits);

        /// <summary>
        /// Called when controlled <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.expfrac">Microsoft.Quantum.Intrinsic.ExpFrac</a> is called in Q#.
        /// When this is invoked, it is expected that the 𝑒𝑥𝑝(𝑖⋅π⋅<paramref name="numerator"/>⋅<paramref name="paulis"/>/2^<paramref name="power"/>) gets applied to <paramref name="qubits"/> controlled on <paramref name="controls"/>.
        /// </summary>
        /// <remarks>
        /// When adjoint of Controlled ExpFrac is called in Q#, <see cref="ControlledExpFrac(IQArray{Qubit}, IQArray{Pauli}, long, long, IQArray{Qubit})"/> is called with <paramref name="numerator"/> replaced by -<paramref name="numerator"/>.
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="controls">The array of qubits on which the operation is controlled.</param>
        /// <param name="paulis">Array of single-qubit Pauli values representing a multi-qubit Pauli to be applied.</param>
        /// <param name="numerator">Numerator in the dyadic fraction representation of the angle by which the qubit register is to be rotated.</param>
        /// <param name="power">Power of two specifying the denominator of the angle by which the qubit register is to be rotated.</param>
        /// <param name="qubits">Register to apply the exponent to.</param>
        void ControlledExpFrac(IQArray<Qubit> controls, IQArray<Pauli> paulis, long numerator, long power, IQArray<Qubit> qubits);

        /// <summary>
        /// Used as extensibility mechanism to add custom operations to IQuantumProcessor. 
        /// </summary>
        /// <remarks>
        /// The custom operation may use only some of the parameters. Depending on the nature of the operation, all of them may be optional. 
        /// A variety of parameter types are provided for flexibility.
        /// </remarks>
        /// <param name="operationId">The id of the custom operation. It is up to the custom operation implementor to define the meaning.</param>
        /// <param name="qubits">Array of qubits to apply the operation to. Their meaning is specific to the custom operation.</param>
        /// <param name="paulis">Array of single-qubit Pauli values. Their meaning is specific to the custom operation.</param>
        /// <param name="longs">Array of long parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="doubles">Array of double parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="bools">Array of bool parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="results">Array of Result parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="strings">Array of string parameters. Their meaning is specific to the custom operation.</param>
        void CustomOperation(long operationId, IQArray<Qubit> qubits, IQArray<Pauli> paulis, IQArray<long> longs, IQArray<double> doubles, IQArray<bool> bools, IQArray<Result> results, IQArray<string> strings);

        /// <summary>
        /// Used as extensibility mechanism to add custom operations to IQuantumProcessor. Implements controlled version.
        /// </summary>
        /// <remarks>
        /// The custom operation may use only some of the parameters. Depending on the nature of the operation, all of them may be optional. 
        /// A variety of parameter types are provided for flexibility.
        /// </remarks>
        /// <param name="operationId">The id of the custom operation. It is up to the custom operation implementor to define the meaning.</param>
        /// <param name="controls">Array of control qubits for this operation.</param>
        /// <param name="qubits">Array of qubits to apply the operation to. Their meaning is specific to the custom operation.</param>
        /// <param name="paulis">Array of single-qubit Pauli values. Their meaning is specific to the custom operation.</param>
        /// <param name="longs">Array of long parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="doubles">Array of double parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="bools">Array of bool parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="results">Array of Result parameters. Their meaning is specific to the custom operation.</param>
        /// <param name="strings">Array of string parameters. Their meaning is specific to the custom operation.</param>
        void ControlledCustomOperation(long operationId, IQArray<Qubit> controls, IQArray<Qubit> qubits, IQArray<Pauli> paulis, IQArray<long> longs, IQArray<double> doubles, IQArray<bool> bools, IQArray<Result> results, IQArray<string> strings);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.m">Microsoft.Quantum.Intrinsic.M</a> is called in Q#.
        /// When this is invoked, it is expected that the <paramref name="qubit"/> is measured in Z basis, in other words in the computational basis.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// Class implementing <see cref="IQuantumProcessor"/> interface can return any class derived from <see cref="Result"/>.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        /// <returns> Zero if the +1 eigenvalue is observed, and One if the -1 eigenvalue is observed.</returns>
        Result M(Qubit qubit);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.measure">Microsoft.Quantum.Intrinsic.Measure</a> is called in Q#.
        /// When this is invoked, it is expected that the multi-qubit Pauli observable given by <paramref name="bases"/> is measured on <paramref name="qubits"/>.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// Class implementing <see cref="IQuantumProcessor"/> interface can return any class derived from <see cref="Result"/>.
        /// </remarks>
        /// <param name="qubits">Qubits to which the gate should be applied.</param>
        /// <param name="bases">Array of single-qubit Pauli values describing multi-qubit Pauli observable.</param>
        /// <returns> Zero if the +1 eigenvalue is observed, and One if the -1 eigenvalue is observed.</returns>
        Result Measure(IQArray<Pauli> bases, IQArray<Qubit> qubits);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.reset">Microsoft.Quantum.Intrinsic.Reset</a> is called in Q#.
        /// When this is invoked, it is expected that the <paramref name="qubit"/> is measured and ensured to be in the |0⟩ state such that it can be safely released.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="qubit">Qubit to which the gate should be applied.</param>
        void Reset(Qubit qubit);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when a conditional statement on measurement results is invoked.
        /// </summary>
        /// <param name="measurementResults">The actual results of the measurements of a number of qubits upon which branching is to be performed.</param>
        /// <param name="resultsValues">The expected values of results of the measurements of these qubits.</param>
        /// <returns> A value representing this conditional statement and encoding the result of condition.</returns>
        /// <remarks>
        /// A typical implementation will compare all <paramref name="measurementResults"/> to <paramref name="resultsValues"/> and return the result of this comparison.
        /// </remarks>
        long StartConditionalStatement(IQArray<Result> measurementResults, IQArray<Result> resultsValues);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when a conditional statement on a measurement result is invoked.
        /// </summary>
        /// <param name="measurementResult">The actual result of the measurement of a qubit upon which branching is to be performed.</param>
        /// <param name="resultValue">The expected value of result of the measurement of this qubit.</param>
        /// <returns> A value representing this conditional statement and encoding the result of the condition. It will be passed through to the other branching related APIs such as RunThenClause.</returns>
        /// <remarks>
        /// A typical implementation will compare <paramref name="measurementResult"/> to <paramref name="resultValue"/> and return the result of this comparison.
        /// </remarks>
        long StartConditionalStatement(Result measurementResult, Result resultValue);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when the "then" statement of a conditional statement is about to be executed.
        /// </summary>
        /// <param name="statement">A value representing this conditional statement and encoding the result of condition.</param>
        /// <returns> If true is returned, the "then" statement will be executed, otherwise it will be skipped and RepeatThenClause will not be called.</returns>
        /// <remarks>
        /// A typical implementation will use <paramref name="statement"/> to return whether condition was evaluated to true.
        /// </remarks>
        bool RunThenClause(long statement);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when the "then" statement of a conditional statement has finished executing.
        /// </summary>
        /// <param name="statement">A value representing this conditional statement and encoding the result of the condition. This is the value returned from the StartConditionalStatement.</param>
        /// <returns> If true is returned, the "then" statement will be executed again (without calling RunThenClause), folowed by another call to RepeatThenClause.</returns>
        /// <remarks>
        /// A typical implementation will return false.
        /// </remarks>
        bool RepeatThenClause(long statement);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when the "else" statement of a conditional statement is about to be executed.
        /// </summary>
        /// <param name="statement">A value representing this conditional statement and encoding the result of the condition. This is the value returned from the StartConditionalStatement.</param>
        /// <returns> If true is returned, the "else" statement will be executed, otherwise it will be skipped and RepeatElseClause will not be called.</returns>
        /// <remarks>
        /// A typical implementation will use <paramref name="statement"/> to return whether condition was evaluated to false.
        /// </remarks>
        bool RunElseClause(long statement);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when the "else" statement of a conditional statement has finished executing.
        /// </summary>
        /// <param name="statement">A value representing this conditional statement and encoding the result of the condition. This is the value returned from the StartConditionalStatement.</param>
        /// <returns> If true is returned, the "else" statement will be executed again (without calling RunElseClause), folowed by another call to RepeatElseClause.</returns>
        /// <remarks>
        /// A typical implementation will return false.
        /// </remarks>
        bool RepeatElseClause(long statement);

        /// <summary>
        /// Intended for a limited support of branching upon measurement results on a target machine level.
        /// Called when a conditional statement on measurement results has finished executing.
        /// </summary>
        /// <param name="statement">A value representing this conditional statement and encoding the result of the condition. This is the value returned from the StartConditionalStatement.</param>
        /// <remarks>
        /// A typical implementation will clean up any data structures associated with statement.
        /// </remarks>
        void EndConditionalStatement(long statement);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.assert">Microsoft.Quantum.Intrinsic.Assert</a> is called in Q#.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are the same as for the corresponding Q# operation.
        /// </remarks>
        /// <param name="bases">A multi-qubit Pauli operator, for which the measurement outcome is asserted.</param>
        /// <param name="qubits">A register on which to make the assertion.</param>
        /// <param name="result">The expected result of <c>Measure(bases, qubits)</c> </param>
        /// <param name="msg">A message to be reported if the assertion fails.</param>
        void Assert(IQArray<Pauli> bases, IQArray<Qubit> qubits, Result result, string msg);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.assertprob">Microsoft.Quantum.Intrinsic.Assert</a> is called in Q#.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters is similar to the corresponding Q# operation./
        /// </remarks>
        /// <param name="bases">A multi-qubit Pauli operator, for which the measurement outcome is asserted.</param>
        /// <param name="qubits">A register on which to make the assertion.</param>
        /// <param name="probabilityOfZero">The probability with which result Zero is expected.</param>
        /// <param name="msg">A message to be reported if the assertion fails.</param>
        /// <param name="tol">The precision with which the probability of Zero outcome is specified.</param>
        void AssertProb(IQArray<Pauli> bases, IQArray<Qubit> qubits, double probabilityOfZero, string msg, double tol);

        /// <summary>
        /// Called before a call to any Q# operation.
        /// </summary>
        /// <param name="operation">Information about operation being called.</param>
        /// <param name="arguments">Information about the arguments passed to the operation.</param>
        /// <remarks>
        /// Implement this interface if you want to be notified every time a Q# operation starts.
        /// To get the fully qualified Q# name of operation being called use <see cref="ICallable.FullName"/>.
        /// For the variant of operation, that is to find if Adjoint, Controlled or Controlled Adjoint being called use <see cref="ICallable.Variant"/>.
        /// To get a sequence of all qubits passed to the operation use <see cref="IApplyData.Qubits"/>.
        /// </remarks>
        void OnOperationStart(ICallable operation, IApplyData arguments);

        /// <summary>
        /// Called when returning from a call to any Q# operation.
        /// </summary>
        /// <param name="operation">Information about operation being called.</param>
        /// <param name="arguments">Information about the arguments passed to the operation.</param>
        /// <remarks>
        /// Implement this interface if you want to be notified every time a Q# operation ends.
        /// To get the fully qualified Q# name of operation being called use <see cref="ICallable.FullName"/>.
        /// For the variant of operation, that is to find if Adjoint, Controlled or Controlled Adjoint being called use <see cref="ICallable.Variant"/>.
        /// To get a sequence of all qubits passed to the operation use <see cref="IApplyData.Qubits"/>.
        /// </remarks>
        void OnOperationEnd(ICallable operation, IApplyData arguments);

        /// <summary>
        /// Called when an exception occurs. This could be Fail statement in Q#, or any other exception.
        /// </summary>
        /// <param name="exceptionDispatchInfo">Information about exception that was raised.</param>
        /// <remarks>
        /// </remarks>
        void OnFail(System.Runtime.ExceptionServices.ExceptionDispatchInfo exceptionDispatchInfo);

        /// <summary>
        /// Called when qubits are allocated by Q# <a href="https://docs.microsoft.com/quantum/language/statements#clean-qubits"><c>using</c></a> block. 
        /// </summary>
        /// <param name="qubits">Qubits that are being allocated</param>.
        /// <remarks>
        /// Every qubit has a unique identifier <see cref="Qubit.Id"/>.
        /// All newly allocated qubits are in |0⟩ state.
        /// </remarks>
        void OnAllocateQubits(IQArray<Qubit> qubits);

        /// <summary>
        /// Called when qubits are released in Q# in the end of <a href="https://docs.microsoft.com/quantum/language/statements#clean-qubits"><c>using</c></a> block. 
        /// </summary>
        /// <param name="qubits">Qubits that are being released</param>.
        /// <remarks>
        /// Every qubit has a unique identifier <see cref="Qubit.Id"/>.
        /// All qubits are expected to be released in |0⟩ state.
        /// </remarks>
        void OnReleaseQubits(IQArray<Qubit> qubits);

        /// <summary>
        /// Called when qubits are borrowed by Q# <a href="https://docs.microsoft.com/quantum/language/statements#dirty-qubits"><c>borrowing</c></a> block. 
        /// </summary>
        /// <param name="qubits">Qubits that are being borrowed</param>.
        /// <param name="allocatedForBorrowingCount">Number of qubits that have been allocated for borrowing. This might happen if there have not been enough already allocated qubits available for borrowing.</param>.
        /// <remarks>
        /// Every qubit has a unique identifier <see cref="Qubit.Id"/>.
        /// Borrowed qubits can be in any state.
        /// </remarks>
        void OnBorrowQubits(IQArray<Qubit> qubits, long allocatedForBorrowingCount);

        /// <summary>
        /// Called when qubits are returned in the end of Q# <a href="https://docs.microsoft.com/quantum/language/statements#dirty-qubits"><c>borrowing</c></a> block. 
        /// </summary>
        /// <param name="qubits">Qubits that have been borrowed and are now being returned</param>.
        /// <param name="releasedOnReturnCount">Number of qubits that have been released once returned. This might happen if they have been allocated only for borrowing.</param>.
        /// <remarks>
        /// Every qubit has a unique identifier <see cref="Qubit.Id"/>.
        /// Borrowed qubits are expected to be returned in the same state as the state they have been borrowed in.
        /// </remarks>
        void OnReturnQubits(IQArray<Qubit> qubits, long releasedOnReturnCount);

        /// <summary>
        /// Called when 
        /// <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.diagnostics.dumpmachine">Microsoft.Quantum.Diagnostics.DumpMachine</a>
        /// is called in Q#.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are similar to corresponding Q# operation. 
        /// </remarks>
        /// <typeparam name="T"></typeparam>
        /// <param name="location">Provides information on where to generate the DumpMachine state.</param>
        void OnDumpMachine<T>(T location);

        /// <summary>
        /// Called when 
        /// <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.diagnostics.dumpregister">Microsoft.Quantum.Diagnostics.DumpRegister</a>
        /// is called in Q#.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are similar to corresponding Q# operation. 
        /// </remarks>
        /// <typeparam name="T"></typeparam>
        /// <param name="location">Provides information on where to generate the DumpRegister state.</param>
        /// <param name="qubits">The list of qubits to report. </param>
        void OnDumpRegister<T>(T location, IQArray<Qubit> qubits);

        /// <summary>
        /// Called when <a href="https://docs.microsoft.com/qsharp/api/qsharp/microsoft.quantum.intrinsic.message">Microsoft.Quantum.Intrinsic.Message</a> is called in Q#.
        /// </summary>
        /// <remarks>
        /// The names and the order of the parameters are the same as corresponding Q# operations. 
        /// </remarks>
        /// <param name="msg">The message to be reported.</param>
        void OnMessage(string msg);
    }
}
