// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use serde::{Deserialize, Serialize};

/// Represents a single step of a decomposition of
/// a Clifford operation into CNOT, Hadamard, and phase operations.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ChpOperation {
    /// The controlled-NOT operation between two qubits.
    Cnot(usize, usize),

    /// The Hadamard operation.
    Hadamard(usize),

    /// The phase operation, represented by the matrix
    /// $$
    /// \begin{align}
    ///     S = \left( \begin{matrix}
    ///         1 & 0 \\\\
    ///         0 & i
    ///     \end{matrix} \right).
    /// \end{align}
    /// $$
    Phase(usize),

    /// The phase operation, represented by the matrix
    /// $$
    /// \begin{align}
    ///     S = \left( \begin{matrix}
    ///         1 & 0 \\\\
    ///         0 & i
    ///     \end{matrix} \right).
    /// \end{align}
    /// $$
    AdjointPhase(usize),
}
