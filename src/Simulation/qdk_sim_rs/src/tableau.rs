// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::fmt::Display;

use crate::utils::{set_row_to_row_sum, set_vec_to_row_sum, swap_columns};
use ndarray::{s, Array, Array1, Array2};
use serde::{Deserialize, Serialize};

#[cfg(feature = "python")]
use pyo3::{prelude::*, PyObjectProtocol};

#[cfg(feature = "python")]
use std::io::{Error, ErrorKind};

/// Represents a stabilizer group with logical dimension 1;
/// that is, a single stabilizer state expressed in terms
/// of the generators of its stabilizer group, and those
/// generators of the Pauli group that anticommute with
/// each stabilizer generator (colloquially, the destabilizers
/// of the represented state).
#[cfg_attr(feature = "python", pyclass(name = "Tableau"))]
#[derive(Clone, Debug, Serialize, Deserialize)]
pub struct Tableau {
    // TODO[code quality]: This is redundant with the n_qubits field in
    //                     QubitSized, such that this type should be refactored
    //                     to only have the table itself.
    n_qubits: usize,
    table: Array2<bool>,
}

impl Display for Tableau {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        write!(
            f,
            "Stabilizer tableau on {} qubits:\n{:?}",
            self.n_qubits, self.table
        )
    }
}

impl Tableau {
    const fn idx_phase(&self) -> usize {
        2 * self.n_qubits
    }

    /// Returns a new stabilizer tableau representing
    /// the $\ket{00\cdots 0}$ state of an $n$-qubit
    /// register.
    pub fn new(n_qubits: usize) -> Self {
        Tableau {
            n_qubits,
            table: Array::from_shape_fn((2 * n_qubits, 2 * n_qubits + 1), |(i, j)| i == j),
        }
    }

    fn idx_x(&self, idx_col: usize) -> usize {
        idx_col
    }

    fn idx_z(&self, idx_col: usize) -> usize {
        idx_col + self.n_qubits
    }

    /// Returns the determinstic result that would be obtained from measuring
    /// the given qubit in the 𝑍 basis, or `None` if the result is random.
    fn determinstic_result(&self, idx_target: usize) -> Option<bool> {
        let determined = !self
            .table
            .slice(s![self.n_qubits.., idx_target])
            .iter()
            .any(|b| *b);
        if determined {
            // What was it determined to be?
            let mut vector: Array1<bool> = Array::default(2 * self.n_qubits + 1);
            for idx_destabilizer in 0..self.n_qubits {
                if self.table[(idx_destabilizer, self.idx_x(idx_target))] {
                    set_vec_to_row_sum(&mut vector, &self.table, idx_destabilizer + self.n_qubits);
                }
            }
            Some(vector[2 * self.n_qubits])
        } else {
            None
        }
    }
}

impl Tableau {
    /// Asserts whether a hypothetical single-qubit $Z$-basis measurement
    /// would agree with an expected result.
    ///
    /// If the assertion would pass, `Ok(())` is returned, otherwise an [`Err`]
    /// describing the assertion failure is returned.
    pub fn assert_meas(&self, idx_target: usize, expected: bool) -> Result<(), String> {
        let actual = self.determinstic_result(idx_target).ok_or(format!(
            "Expected {}, but measurement result would be random.",
            expected
        ))?;
        if actual != expected {
            Err(format!(
                "Expected {}, but measurement result would actually be {}.",
                expected, actual
            ))
        } else {
            Ok(())
        }
    }
}

#[cfg_attr(feature = "python", pymethods)]
impl Tableau {
    /// Returns a serialization of this stabilizer tableau as a JSON object.
    #[cfg(feature = "python")]
    pub fn as_json(&self) -> PyResult<String> {
        serde_json::to_string(self)
            .map_err(|e| PyErr::from(Error::new(ErrorKind::Other, e.to_string())))
    }

    /// Applies a Hadamard operation in-place to the given qubit.
    pub fn apply_h_mut(&mut self, idx_target: usize) {
        let idxs = (self.idx_x(idx_target), self.idx_z(idx_target));
        swap_columns(&mut self.table, idxs);
        let idx_phase = self.idx_phase();
        for idx_row in 0..2 * self.n_qubits {
            let a = self.table[(idx_row, self.idx_x(idx_target))];
            let b = self.table[(idx_row, self.idx_z(idx_target))];
            self.table[(idx_row, idx_phase)] ^= a && b;
        }
    }

    /// Applies a phase operation ($S$) in-place to the given qubit.
    pub fn apply_s_mut(&mut self, idx_target: usize) {
        let idx_phase = self.idx_phase();
        for idx_row in 0..2 * self.n_qubits {
            self.table[(idx_row, idx_phase)] ^= self.table[(idx_row, self.idx_x(idx_target))]
                && self.table[(idx_row, self.idx_z(idx_target))];
        }

        for idx_row in 0..2 * self.n_qubits {
            let idx_x_target = self.idx_x(idx_target);
            let idx_z_target = self.idx_z(idx_target);
            self.table[(idx_row, idx_z_target)] ^= self.table[(idx_row, idx_x_target)];
        }
    }

    /// Applies a controlled-NOT operation in-place, given control and target
    /// qubits.
    pub fn apply_cnot_mut(&mut self, idx_control: usize, idx_target: usize) {
        let idx_phase = self.idx_phase();
        for idx_row in 0..2 * self.n_qubits {
            self.table[(idx_row, idx_phase)] ^= self.table[(idx_row, self.idx_x(idx_control))]
                && self.table[(idx_row, self.idx_z(idx_target))]
                && (self.table[(idx_row, self.idx_x(idx_target))]
                    ^ self.table[(idx_row, self.idx_z(idx_control))]
                    ^ true);
        }

        for idx_row in 0..2 * self.n_qubits {
            let idx_x_target = self.idx_x(idx_target);
            let idx_x_control = self.idx_x(idx_control);
            self.table[(idx_row, idx_x_target)] ^= self.table[(idx_row, idx_x_control)];
        }

        for idx_row in 0..2 * self.n_qubits {
            let idx_z_target = self.idx_z(idx_target);
            let idx_z_control = self.idx_z(idx_control);
            self.table[(idx_row, idx_z_control)] ^= self.table[(idx_row, idx_z_target)];
        }
    }

    /// Applies a Pauli $X$ operation in-place to the given qubit.
    pub fn apply_x_mut(&mut self, idx_target: usize) {
        self.apply_h_mut(idx_target);
        self.apply_z_mut(idx_target);
        self.apply_h_mut(idx_target);
    }

    /// Applies an adjoint phase operation ($S^{\dagger}$) in-place to the
    /// given qubit.
    pub fn apply_s_adj_mut(&mut self, idx_target: usize) {
        self.apply_s_mut(idx_target);
        self.apply_s_mut(idx_target);
        self.apply_s_mut(idx_target);
    }

    /// Applies a Pauli $Y$ operation in-place to the given qubit.
    pub fn apply_y_mut(&mut self, idx_target: usize) {
        self.apply_s_adj_mut(idx_target);
        self.apply_x_mut(idx_target);
        self.apply_s_mut(idx_target);
    }

    /// Applies a Pauli $Z$ operation in-place to the given qubit.
    pub fn apply_z_mut(&mut self, idx_target: usize) {
        self.apply_s_mut(idx_target);
        self.apply_s_mut(idx_target);
    }

    /// Applies a SWAP operation in-place between two qubits.
    pub fn apply_swap_mut(&mut self, idx_1: usize, idx_2: usize) {
        self.apply_cnot_mut(idx_1, idx_2);
        self.apply_cnot_mut(idx_2, idx_1);
        self.apply_cnot_mut(idx_1, idx_2);
    }

    /// Measures a single qubit in the Pauli $Z$-basis, returning the result,
    /// and updating the stabilizer tableau in-place.
    pub fn meas_mut(&mut self, idx_target: usize) -> bool {
        if let Some(result) = self.determinstic_result(idx_target) {
            return result;
        }

        // If we're still here, we know the measurement result is random;
        // thus we need to pick a random result and use that to update the
        // tableau.
        let idx_phase = self.idx_phase();
        let result = rand::random();
        let collisions: Vec<usize> = self
            .table
            .slice(s![.., self.idx_x(idx_target)])
            .indexed_iter()
            .filter(|(_i, b)| **b)
            .map(|(i, _b)| i)
            .collect();
        // Find the first stabilizer that intersects with idx_target in the X
        // sector.
        let idx_first: usize = self.n_qubits
            + self
                .table
                .slice(s![self.n_qubits.., self.idx_x(idx_target)])
                .indexed_iter()
                .find(|(_i, b)| **b)
                .unwrap()
                .0;
        // Make an owned copy of the first colliding stabilizer, as we'll
        // need that later.
        let old_stab = self.table.slice(s![idx_first, ..]).to_owned();

        // For all collisions other than the first stabilizer, take the row
        // sum of that row with the first stabilizer.
        for idx_collision in collisions.iter() {
            if *idx_collision != idx_first {
                set_row_to_row_sum(&mut self.table, *idx_collision, idx_first);
            }
        }

        // Move the old stabilizer into being a destabilizer, then make a new
        // stabilizer that's constrained to agree with our random result.
        self.table
            .slice_mut(s![idx_first - self.n_qubits, ..])
            .assign(&old_stab);
        self.table.slice_mut(s![idx_first, ..]).fill(false);
        let idx_z_target = self.idx_z(idx_target);
        self.table[(idx_first, idx_z_target)] = true;
        self.table[(idx_first, idx_phase)] = result;
        result
    }
}

// Forward the ::new method onto Python.
#[cfg(feature = "python")]
#[pymethods]
impl Tableau {
    /// Returns a new stabilizer tableau representing
    /// the $\ket{00\cdots 0}$ state of an $n$-qubit
    /// register.
    #[new]
    pub fn new_py(n_qubits: usize) -> Self {
        Self::new(n_qubits)
    }
}

#[cfg(feature = "python")]
#[pyproto]
impl PyObjectProtocol for Tableau {
    fn __repr__(&self) -> String {
        format!("<{:?}>", self)
    }

    fn __str__(&self) -> String {
        format!("{}", self)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bell_pair_meas_agree() {
        let mut t = Tableau::new(2);
        t.apply_h_mut(0);
        t.apply_cnot_mut(0, 1);
        let left = t.meas_mut(0);
        let right = t.meas_mut(1);
        assert_eq!(left, right)
    }
}
