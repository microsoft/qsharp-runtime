// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

#pragma once

namespace Microsoft::Quantum::SPARSESIMULATOR
{

// Used to track differnet kind of gates,
// mainly for timing summary data
enum class OP {
    MCPhase,
    Phase,
    T,
    AdjT,
    S,
    AdjS,
    H,
    MCH,
    X,
    MCX,
    Y,
    MCY,
    Z,
    MCZ,
    M,
    Measure,
    Exp,
    MCExp,
    R1,
    MCR1,
    Rx,
    Rz,
    Ry,
    MCRx,
    MCRz,
    MCRy,
    SWAP,
    MCSWAP,
    PermuteSmall,
    PermuteLarge,
    Proj,
    MCProj,
    Allocate,
    Release,
    NUM_OPS // counts gate types; do not add gates after this!
};

// Strings for the names of the various gate types
const static std::string op_name(OP gate_type) {
    switch (gate_type) {
        case OP::MCPhase:
            return "MCPhase";
        case OP::Phase:
            return "Phase";
        case OP::T:
            return "T";
        case OP::AdjT:
            return "AdjT";
        case OP::S:
            return "S";
        case OP::AdjS:
            return "AdjS";
        case OP::H:
            return "H";
            case OP::MCH:
            return "MCH";
        case OP::X:
            return "X";
        case OP::MCX:
            return "MCX";
        case OP::Y:
            return "Y";
        case OP::MCY:
            return "MCY";
        case OP::Z:
            return "Z";
        case OP::MCZ:
            return "MCZ";
        case OP::M:
            return "M";
        case OP::Measure:
            return "Measure";
        case OP::Exp:
            return "Exp";
        case OP::MCExp:
            return "MCExp";
        case OP::R1:
            return "R1";
        case OP::MCR1:
            return "MCR1";
        case OP::Rx:
            return "Rx";
        case OP::Rz:
            return "Rz";
        case OP::Ry:
            return "Ry";
        case OP::MCRx:
            return "MCRx";
        case OP::MCRz:
            return "MCRz";
        case OP::MCRy:
            return "MCRy";
        case OP::SWAP:
            return "SWAP";
        case OP::MCSWAP:
            return "MCSWAP";
        case OP::PermuteSmall:
            return "Perm_S";
        case OP::PermuteLarge:
            return "Perm_L";
        case OP::Proj:
            return "Project";
        case OP::MCProj:
            return "MCProj";
        case OP::Allocate:
            return "Alloc";
        case OP::Release:
            return "Release";
        default:
            return "Not a gate";
    }
}

// Used in operation queues for phases/permutations
// Different constructors correspond to different 
// kinds of gates, so some data is not initialized 
// for certain types of gates
struct operation {
    OP gate_type;
    logical_qubit_id target;
    operation(OP gate_type_arg,
        logical_qubit_id target_arg) :
        gate_type(gate_type_arg),
        target(target_arg) {}

    std::vector<logical_qubit_id> controls;
    operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        std::vector<logical_qubit_id> controls_arg
        ) : gate_type(gate_type_arg),
            target(target_arg),
            controls(controls_arg){}

    logical_qubit_id shift;
    logical_qubit_id target_2;
    //swap
    operation (OP gate_type_arg, 
        logical_qubit_id target1_arg,
        logical_qubit_id shift_arg,
        logical_qubit_id target_2_arg
        ) :gate_type(gate_type_arg),
            target(target1_arg),
            shift(shift_arg),
            target_2(target_2_arg){}
    //mcswap
    operation(OP gate_type_arg, 
        logical_qubit_id target1_arg,
        logical_qubit_id shift_arg,
        std::vector<logical_qubit_id> controls_arg, 
        logical_qubit_id target_2_arg
        ) : gate_type(gate_type_arg),
            target(target1_arg),
            shift(shift_arg),
            controls(controls_arg), 
            target_2(target_2_arg){}
    amplitude phase;
    // Phase
    operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        amplitude phase_arg
        ) :gate_type(gate_type_arg),
            target(target_arg),
            phase(phase_arg){}
    // MCPhase
    operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        std::vector<logical_qubit_id> controls_arg, 
        amplitude phase_arg
        ) : gate_type(gate_type_arg),
            target(target_arg),
            controls(controls_arg),
            phase(phase_arg)
        {}
};

// Also represents operations, but uses
// bitsets instead of vectors of qubit ids
// to save time/space
template<size_t num_qubits>
struct condensed_operation {
    OP gate_type;
    logical_qubit_id target;
    condensed_operation(OP gate_type_arg,
        logical_qubit_id target_arg) :
        gate_type(gate_type_arg),
        target(target_arg)
        {}

    std::bitset<num_qubits> controls;
    condensed_operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        std::bitset<num_qubits> const& controls_arg
        ) : gate_type(gate_type_arg),
            target(target_arg),
            controls(controls_arg){}

    logical_qubit_id target_2;
    //swap
    condensed_operation (OP gate_type_arg, 
        logical_qubit_id target1_arg,
        logical_qubit_id target_2_arg
        ) :gate_type(gate_type_arg),
            target(target1_arg),
            target_2(target_2_arg){}
    //mcswap
    condensed_operation(OP gate_type_arg, 
        logical_qubit_id target1_arg,
        std::bitset<num_qubits> const& controls_arg, 
        logical_qubit_id target_2_arg
        ) : gate_type(gate_type_arg),
            target(target1_arg),
            controls(controls_arg), 
            target_2(target_2_arg){}
    amplitude phase;
    // Phase
    condensed_operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        amplitude phase_arg
        ) :gate_type(gate_type_arg),
            target(target_arg),
            phase(phase_arg){}
    // MCPhase
    condensed_operation(OP gate_type_arg, 
        logical_qubit_id target_arg, 
        std::bitset<num_qubits> const& controls_arg, 
        amplitude phase_arg
        ) : gate_type(gate_type_arg),
            target(target_arg),
            controls(controls_arg),
            phase(phase_arg)
        {}
};

namespace Gates
{
    /// a type for runtime basis specification
    enum class Basis
    {
        PauliI = 0,
        PauliX = 1,
        PauliY = 3,
        PauliZ = 2
    };
} // namespace Gates

} // namespace Microsoft::Quantum::SPARSESIMULATOR
