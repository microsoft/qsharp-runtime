// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Public implementations and crate-private functions for applying processes
//! in each different representation.

use std::ops::Add;

use cauchy::c64;
use itertools::Itertools;
use ndarray::{Array, Array2, Array3, ArrayView2, Axis, Order};
use rand::{distributions::WeightedIndex, prelude::Distribution, thread_rng};

use crate::{
    chp_decompositions::ChpOperation,
    error::QdkSimError,
    linalg::{zeros_like, ConjBy},
    log, log_as_err, Pauli, Process,
    ProcessData::*,
    State,
    StateData::{self, *},
    Tableau, VariantName, C64,
};

use super::promote_pauli_channel;

impl Process {
    /// Applies this process to a quantum register with a given
    /// state, returning the new state of that register.
    pub fn apply(&self, state: &State) -> Result<State, QdkSimError> {
        if state.n_qubits != self.n_qubits {
            return Err(QdkSimError::WrongNumberOfQubits {
                expected: self.n_qubits,
                actual: state.n_qubits,
            });
        }

        match &self.data {
            Unitary(u) => apply_unitary(u, state),
            KrausDecomposition(ks) => apply_kraus_decomposition(ks, state),
            MixedPauli(paulis) => apply_pauli_channel(paulis, state),
            Sequence(processes) => {
                // TODO[perf]: eliminate the extraneous clone here.
                let mut acc_state = state.clone();
                for process in processes {
                    acc_state = process.apply(state)?;
                }
                Ok(acc_state)
            }
            // TODO: Support applying CHP decompositions and superoperators to
            //       entire registers. Currently only supported acting on
            //       subregisters via [`apply_to`].
            _ => Err(QdkSimError::UnsupportedApply {
                channel_variant: self.variant_name(),
                state_variant: state.variant_name(),
            }),
        }
    }

    /// Applies this process to the given qubits in a register with a given
    /// state, returning the new state of that register.
    pub fn apply_to(&self, idx_qubits: &[usize], state: &State) -> Result<State, QdkSimError> {
        // If we have a sequence, we can apply each in turn and exit early.
        if let Sequence(channels) = &self.data {
            // TODO[perf]: eliminate the extraneous clone here.
            let mut acc_state = state.clone();
            for channel in channels {
                acc_state = channel.apply_to(idx_qubits, &acc_state)?;
            }
            return Ok(acc_state);
        }

        // Fail if there's not enough qubits.
        if state.n_qubits < self.n_qubits {
            return log_as_err(format!(
                "Channel acts on {} qubits, but a state on only {} qubits was given.\n\nChannel:\n{:?}\n\nState:\n{:?}",
                self.n_qubits, state.n_qubits, self, state
            ));
        }

        // Fail if any indices are repeated.
        if idx_qubits.iter().unique().count() < idx_qubits.len() {
            return log_as_err(format!(
                "List of qubit indices {:?} contained repeated elements.",
                idx_qubits
            ));
        }

        // Make sure that there are only as many indices as qubits that this
        // channel acts upon.
        if idx_qubits.len() != self.n_qubits {
            return log_as_err(format!(
                "Qubit indices were specified as {:?}, but this channel only acts on {} qubits.",
                idx_qubits, self.n_qubits
            ));
        }

        // At this point we know that idx_qubits has self.n_qubits many unique
        // indices, such that we can meaningfully apply the channel to the
        // qubits described by idx_qubits.
        //
        // To do so in general, we can proceed to make a new channel
        // that expands this channel to act on the full register and then use
        // the ordinary apply method.
        //
        // In some cases, however, we can do so more efficiently by working
        // with the small channel directly, so we check for those cases first
        // before falling through to the general case.

        // TODO[perf]: For larger systems, we could add another "fast path" using
        //             matrix multiplication kernels to avoid extending
        //             channels to larger Hilbert spaces.
        //             For smaller systems, extending channels and possibly
        //             caching them is likely to be more performant; need to
        //             tune to find crossover point.
        if let ChpDecomposition(operations) = &self.data {
            if let Stabilizer(tableau) = &state.data {
                return apply_chp_decomposition_to(operations, state.n_qubits, idx_qubits, tableau);
            }
        }

        if let Superoperator(mtx) = &self.data {
            return match &state.data {
                StateData::Mixed(rho) => Ok(State {
                    n_qubits: state.n_qubits,
                    data: StateData::Mixed(apply_superoperator_to_density_matrix(
                        state.n_qubits,
                        idx_qubits,
                        mtx.view(),
                        rho.view(),
                    )?),
                }),
                _ => Err(QdkSimError::UnsupportedApply {
                    channel_variant: self.variant_name(),
                    state_variant: state.variant_name(),
                }),
            };
        }

        // Having tried fast paths above, we now fall back to the most general
        // case.
        match self.n_qubits {
            1 => {
                if state.n_qubits == 1 {
                    self.apply(state)
                } else {
                    self.extend_one_to_n(idx_qubits[0], state.n_qubits)
                        .apply(state)
                }
            }
            // TODO[perf]: If the size of the register matches the size of the
            //             channel, permute rather than expanding.
            2 => self
                .extend_two_to_n(idx_qubits[0], idx_qubits[1], state.n_qubits)
                .apply(state),
            _ => {
                log(&format!(
                    "Expanding {}-qubit channels is not yet implemented.",
                    self.n_qubits
                ));
                unimplemented!("");
            }
        }
    }
}

fn apply_superoperator_to_density_matrix<'a, O, M>(
    n_qubits: usize,
    idx_qubits: &[usize],
    superop: O,
    state: M,
) -> Result<Array2<c64>, QdkSimError>
where
    O: Into<ArrayView2<'a, c64>>,
    M: Into<ArrayView2<'a, c64>>,
{
    let superop: ArrayView2<c64> = superop.into();
    let state: ArrayView2<c64> = state.into();
    match idx_qubits.len() {
        1 => {
            let idx_qubit = idx_qubits[0];
            if idx_qubit >= n_qubits {
                return Err(QdkSimError::MiscError(format!(
                    "Invalid qubit index {} for {} qubit register.",
                    idx_qubit, n_qubits
                )));
            }
            if superop.shape() != [4, 4] {
                return Err(QdkSimError::MiscError(format!(
                    "Expected 4x4 superoperator but got {:?}.",
                    superop.shape()
                )));
            }
            let superop = superop.to_shape(((2, 2, 2, 2), Order::RowMajor)).unwrap();
            // In the column-stacking basis, `superop` is indexed as
            // `rho_out[i, j] = sum_{k, l} S[j, i, l, k] rho_in[k, l]`.
            // For applying to multiple qubits, we'll represent this by
            // reshaping such that:
            // `rho_out[:, i, :, :, j, :] = sum_{k, l} S[j, i, l, k] rho_in[:, k, :, :, l, :]`.
            let n_left = idx_qubit;
            let n_right = n_qubits - idx_qubit - 1;
            let rho_in = state
                .to_shape((
                    (
                        2usize.pow(n_left as u32),
                        2,
                        2usize.pow(n_right as u32),
                        2usize.pow(n_left as u32),
                        2,
                        2usize.pow(n_right as u32),
                    ),
                    Order::RowMajor,
                ))
                .map_err(QdkSimError::InternalShapeError)?;
            let mut rho_out = zeros_like(&rho_in);
            for i in 0..2usize {
                for j in 0..2usize {
                    for k in 0..2usize {
                        for l in 0..2usize {
                            let sl_out = s![.., i, .., .., j, ..];
                            let this_submatrix =
                                superop[(j, i, l, k)] * &rho_in.slice(s![.., k, .., .., l, ..]);
                            let this_submatrix = &this_submatrix.add(rho_out.slice(sl_out));
                            rho_out.slice_mut(sl_out).assign(this_submatrix);
                        }
                    }
                }
            }
            let shape = state.shape();
            let rho_out = rho_out.into_shape((shape[0], shape[1])).unwrap();
            Ok(rho_out)
        }
        _ => Err(QdkSimError::NotYetImplemented(
            "Superoperators can currently only be applied to one-qubit density operators."
                .to_string(),
        )),
    }
}

fn apply_chp_decomposition_to(
    operations: &[ChpOperation],
    n_qubits: usize,
    idx_qubits: &[usize],
    tableau: &Tableau,
) -> Result<State, QdkSimError> {
    let mut new_tableau = tableau.clone();
    for operation in operations {
        match *operation {
            ChpOperation::Phase(idx) => new_tableau.apply_s_mut(idx_qubits[idx]),
            ChpOperation::AdjointPhase(idx) => new_tableau.apply_s_adj_mut(idx_qubits[idx]),
            ChpOperation::Hadamard(idx) => new_tableau.apply_h_mut(idx_qubits[idx]),
            ChpOperation::Cnot(idx_control, idx_target) => {
                new_tableau.apply_cnot_mut(idx_qubits[idx_control], idx_qubits[idx_target])
            }
        };
    }
    Ok(State {
        n_qubits,
        data: Stabilizer(new_tableau),
    })
}

fn apply_unitary(u: &Array2<C64>, state: &State) -> Result<State, QdkSimError> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(psi) => Pure(u.dot(psi)),
            Mixed(rho) => Mixed(rho.conjugate_by(&u.into())),
            Stabilizer(_tableau) => {
                return Err(QdkSimError::NotYetImplemented(
                    "TODO: Promote stabilizer state to state vector and recurse.".to_string(),
                ))
            }
        },
    })
}

fn apply_kraus_decomposition(ks: &Array3<C64>, state: &State) -> Result<State, QdkSimError> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(psi) => {
                // We can't apply a channel with more than one Kraus operator (Choi rank > 1) to a
                // pure state directly, so if the Choi rank is bigger than 1, promote to
                // Mixed and recurse.
                if ks.shape()[0] == 1 {
                    Pure({
                        let k: ArrayView2<C64> = ks.slice(s![0, .., ..]);
                        k.dot(psi)
                    })
                } else {
                    apply_kraus_decomposition(ks, &state.to_mixed())?.data
                }
            }
            Mixed(rho) => Mixed({
                let mut sum: Array2<C64> = Array::zeros((rho.shape()[0], rho.shape()[1]));
                for k in ks.axis_iter(Axis(0)) {
                    sum = sum + rho.conjugate_by(&k);
                }
                sum
            }),
            Stabilizer(_tableau) => {
                return Err(QdkSimError::NotYetImplemented(
                    "TODO: Promote stabilizer state to state vector and recurse.".to_string(),
                ))
            }
        },
    })
}

fn apply_pauli_channel(paulis: &[(f64, Vec<Pauli>)], state: &State) -> Result<State, QdkSimError> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(_) | Mixed(_) => {
                // Promote and recurse.
                let promoted = promote_pauli_channel(paulis)?;
                return promoted.apply(state);
            }
            Stabilizer(tableau) => {
                // TODO[perf]: Introduce an apply_mut method to
                //             avoid extraneous cloning.
                let mut new_tableau = tableau.clone();
                // Sample a Pauli and apply it.
                let weighted = WeightedIndex::new(paulis.iter().map(|(pr, _)| pr)).unwrap();
                let idx = weighted.sample(&mut thread_rng());
                let pauli = &paulis[idx].1;
                // TODO: Consider moving the following to a method
                //       on Tableau itself.
                for (idx_qubit, p) in pauli.iter().enumerate() {
                    match p {
                        Pauli::I => (),
                        Pauli::X => new_tableau.apply_x_mut(idx_qubit),
                        Pauli::Y => new_tableau.apply_y_mut(idx_qubit),
                        Pauli::Z => new_tableau.apply_z_mut(idx_qubit),
                    }
                }
                Stabilizer(new_tableau)
            }
        },
    })
}

#[cfg(test)]
mod tests {
    use core::panic;

    use approx::assert_abs_diff_eq;

    use super::*;
    use crate::{c64, common_matrices, Generator, ProcessData};

    #[test]
    fn super_h_prepares_plus_on_a_single_qubit() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 1,
            data: StateData::Mixed(array![[c64!(1.0), c64!(0.0)], [c64!(0.0), c64!(0.0)],]),
        };
        let super_h = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(
                c64!(0.5)
                    * array![
                        [c64!(1.0), c64!(1.0), c64!(1.0), c64!(1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(1.0), c64!(-1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(-1.0), c64!(1.0)]
                    ],
            ),
        };
        let rho_out = super_h.apply_to(&[0], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(rho_out) => {
                assert_eq!(
                    rho_out,
                    c64!(0.5) * array![[c64!(1.0), c64!(1.0)], [c64!(1.0), c64!(1.0)]]
                );
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    #[test]
    fn super_ry_works_on_a_single_qubit() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 1,
            data: StateData::Mixed(array![[c64!(1.0), c64!(0.0)], [c64!(0.0), c64!(0.0)],]),
        };
        let superop = Generator::hy().at(0.123)?;
        let rho_out = superop.apply_to(&[0], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [c64!(0.99622252), c64!(0.06134505)],
                    [c64!(0.06134505), c64!(0.00377748)],
                ];
                for (actual, expected) in actual.iter().zip(expected.iter()) {
                    assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
                }
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    #[test]
    fn super_h_prepares_plus_on_two_qubits_on_the_left() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 2,
            data: StateData::Mixed(array![
                [c64!(1.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
            ]),
        };
        let super_h = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(
                c64!(0.5)
                    * array![
                        [c64!(1.0), c64!(1.0), c64!(1.0), c64!(1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(1.0), c64!(-1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(-1.0), c64!(1.0)]
                    ],
            ),
        };
        let rho_out = super_h.apply_to(&[0], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(rho_out) => {
                assert_eq!(
                    rho_out,
                    c64!(0.5)
                        * array![
                            [c64!(1.0), c64!(0.0), c64!(1.0), c64!(0.0)],
                            [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0)],
                            [c64!(1.0), c64!(0.0), c64!(1.0), c64!(0.0)],
                            [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0)],
                        ]
                );
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    #[test]
    fn super_h_prepares_plus_on_two_qubits_on_the_right() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 2,
            data: StateData::Mixed(array![
                [c64!(1.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
                [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0),],
            ]),
        };
        let super_h = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(
                c64!(0.5)
                    * array![
                        [c64!(1.0), c64!(1.0), c64!(1.0), c64!(1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(1.0), c64!(-1.0), c64!(-1.0)],
                        [c64!(1.0), c64!(-1.0), c64!(-1.0), c64!(1.0)]
                    ],
            ),
        };
        let rho_out = super_h.apply_to(&[1], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(rho_out) => {
                assert_eq!(
                    rho_out,
                    c64!(0.5)
                        * array![
                            [c64!(1.0), c64!(1.0), c64!(0.0), c64!(0.0)],
                            [c64!(1.0), c64!(1.0), c64!(0.0), c64!(0.0)],
                            [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0)],
                            [c64!(0.0), c64!(0.0), c64!(0.0), c64!(0.0)],
                        ]
                );
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    #[test]
    fn super_rx_works_on_three_qubit_register() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 3,
            data: StateData::Mixed(common_matrices::elementary_matrix((0, 0), (8, 8))),
        };
        let superop = Generator::hx().at(0.123)?;
        let rho_out = superop.apply_to(&[1], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [
                        c64!(0.9962225160675967),
                        c64!(0.0),
                        c64!(0.06134504501215767 i),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(-0.06134504501215767 i),
                        c64!(0.0),
                        c64!(0.003777483932403215),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ],
                    [
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0),
                        c64!(0.0)
                    ]
                ];
                for (actual, expected) in actual.iter().zip(expected.iter()) {
                    assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
                }
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    #[test]
    fn depol_acts_correctly_on_single_qubit() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 1,
            data: StateData::Mixed(array![
                [
                    c64!(0.34223345895877716),
                    c64!(0.09877905307611697-0.4640607904157318 i)
                ],
                [
                    c64!(0.09877905307611697+0.4640607904157318 i),
                    c64!(0.6577665410412227)
                ]
            ]),
        };
        // 0.345 * sum(map(qt.to_super, [I, X, Y, Z])) / 2 + (1 - 0.345) * qt.to_super(I)
        let superop = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(array![
                [c64!(0.8275), c64!(0.0), c64!(0.0), c64!(0.1725)],
                [c64!(0.0), c64!(0.655), c64!(0.0), c64!(0.0)],
                [c64!(0.0), c64!(0.0), c64!(0.655), c64!(0.0)],
                [c64!(0.1725), c64!(0.0), c64!(0.0), c64!(0.8275)]
            ]),
        };
        let rho_out = superop.apply_to(&[0], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [
                        c64!(0.396662915617999),
                        c64!(0.06470027976485662-0.30395981772230435 i)
                    ],
                    [
                        c64!(0.06470027976485662+0.30395981772230435 i),
                        c64!(0.6033370843820008)
                    ]
                ];

                for (actual, expected) in actual.iter().zip(expected.iter()) {
                    assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
                }
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    /// # Remarks
    /// The data for this test case is obtained by using the `rand_super_bcsz`
    /// and `rand_ket_haar` functions provided by QuTiP:
    ///
    /// ```python
    /// import qutip as qt
    /// psi = qt.rand_ket_haar(2)
    /// S = qt.rand_super_bcsz(2)
    /// rho = psi * psi.dag()
    /// print(S(rho))
    /// ```
    #[test]
    fn rand_super_acts_correctly_on_single_qubit() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 1,
            data: StateData::Mixed(array![
                [
                    c64!(0.34223345895877716),
                    c64!(0.09877905307611697-0.4640607904157318 i)
                ],
                [
                    c64!(0.09877905307611697+0.4640607904157318 i),
                    c64!(0.6577665410412227)
                ]
            ]),
        };
        let superop = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(array![
                [
                    c64!(0.5126965471788728+2.7755575615628914e-17 i),
                    c64!(-0.11185186462139712-0.11830398209790755 i),
                    c64!(-0.11185186462139732+0.1183039820979075 i),
                    c64!(0.5333346198994695+9.71445146547012e-17 i)
                ],
                [
                    c64!(0.3538873412962622-0.02898438568140972 i),
                    c64!(0.2856889125732559+0.24653389062572548 i),
                    c64!(0.05545977628918763+0.25432687406837096 i),
                    c64!(-0.23320630304532255-0.07490927866857504 i)
                ],
                [
                    c64!(0.35388734129626215+0.028984385681409725 i),
                    c64!(0.05545977628918767-0.25432687406837096 i),
                    c64!(0.2856889125732559-0.24653389062572542 i),
                    c64!(-0.23320630304532255+0.07490927866857497 i)
                ],
                [
                    c64!(0.4873034528211264-1.3877787807814457e-17 i),
                    c64!(0.11185186462139732+0.11830398209790745 i),
                    c64!(0.11185186462139719-0.11830398209790746 i),
                    c64!(0.46666538010053105+5.204170427930421e-17 i)
                ]
            ]),
        };
        let rho_out = superop.apply_to(&[0], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [
                        c64!(0.6139748172252246),
                        c64!(0.0050315480904939425-0.0971226233309129 i)
                    ],
                    [
                        c64!(0.0050315480904939425+0.09712262333091287 i),
                        c64!(0.3860251827747754)
                    ]
                ];

                for (actual, expected) in actual.iter().zip(expected.iter()) {
                    assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
                }
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }

    /// # Remarks
    /// The data for this test case is obtained by using the `rand_super_bcsz`
    /// and `rand_ket_haar` functions provided by QuTiP:
    ///
    /// ```python
    /// import qutip as qt
    /// psi = qt.tensor([qt.rand_ket_haar(2) for _ in range(3)])
    /// S = qt.rand_super_bcsz(2)
    /// S_ext = qt.super_tensor([qt.to_super(qt.qeye(2)), S, qt.to_super(qt.qeye(2))])
    /// rho = psi * psi.dag()
    /// print(S_ext(rho))
    /// ```
    #[test]
    fn rand_super_acts_correctly_on_three_qubit_register() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 3,
            data: StateData::Mixed(array![
                [
                    c64!(0.15804869908252214),
                    c64!(-0.09311495730811058-0.13334490190738077 i),
                    c64!(0.1850511725130977+0.10458222471963893 i),
                    c64!(-0.02078805805393892-0.21774174691936377 i),
                    c64!(-0.022699862334499964-0.04283969700071039 i),
                    c64!(-0.022769934222904728+0.044390922002814165 i),
                    c64!(0.0017692943971554555-0.06517951950037934 i),
                    c64!(-0.056034022790537846+0.036908002543958186 i)
                ],
                [
                    c64!(-0.09311495730811058+0.13334490190738077 i),
                    c64!(0.1673614417121474),
                    c64!(-0.19725906448993016+0.09451176215534104 i),
                    c64!(0.19595498857060958+0.11074454904183474 i),
                    c64!(0.04951734466597739+0.006087399938080166 i),
                    c64!(-0.024037411943426165-0.04536395107438954 i),
                    c64!(0.05394925052461+0.03989349232278628 i),
                    c64!(0.0018735469690044958-0.06902010846664941 i)
                ],
                [
                    c64!(0.1850511725130977-0.10458222471963893 i),
                    c64!(-0.19725906448993016-0.09451176215534104 i),
                    c64!(0.2858699782918852),
                    c64!(-0.1684213219016811-0.24118707989929883 i),
                    c64!(-0.05492551985513077-0.03513811938063519 i),
                    c64!(0.002713710121661328+0.06704213704269078 i),
                    c64!(-0.041058288935387384-0.07748613764438327 i),
                    c64!(-0.041185031194788585+0.08029190991743244 i)
                ],
                [
                    c64!(-0.02078805805393892+0.21774174691936377 i),
                    c64!(0.19595498857060958-0.11074454904183474 i),
                    c64!(-0.1684213219016811+0.24118707989929883 i),
                    c64!(0.30271436580550126),
                    c64!(0.062005423488744424-0.025638639196665664 i),
                    c64!(-0.05816190986136632-0.037208571489260565 i),
                    c64!(0.08956430724775354+0.011010561290633505 i),
                    c64!(-0.04347757666054865-0.08205187251872782 i)
                ],
                [
                    c64!(-0.022699862334499964+0.04283969700071039 i),
                    c64!(0.04951734466597739-0.006087399938080166 i),
                    c64!(-0.05492551985513077+0.03513811938063519 i),
                    c64!(0.062005423488744424+0.025638639196665664 i),
                    c64!(0.014872146387555168),
                    c64!(-0.008761978326908677-0.012547555992000291 i),
                    c64!(0.017413038783486306+0.009841031053058894 i),
                    c64!(-0.0019561251961318-0.02048917298063907 i)
                ],
                [
                    c64!(-0.022769934222904728-0.044390922002814165 i),
                    c64!(-0.024037411943426165+0.04536395107438954 i),
                    c64!(0.002713710121661328-0.06704213704269078 i),
                    c64!(-0.05816190986136632+0.037208571489260565 i),
                    c64!(-0.008761978326908677+0.012547555992000291 i),
                    c64!(0.015748461551561024),
                    c64!(-0.01856178317440417+0.008893415575576017 i),
                    c64!(0.018439071579274272+0.010420896562482896 i)
                ],
                [
                    c64!(0.0017692943971554555+0.06517951950037934 i),
                    c64!(0.05394925052461-0.03989349232278628 i),
                    c64!(-0.041058288935387384+0.07748613764438327 i),
                    c64!(0.08956430724775354-0.011010561290633505 i),
                    c64!(0.017413038783486306-0.009841031053058894 i),
                    c64!(-0.01856178317440417-0.008893415575576017 i),
                    c64!(0.026899937738458043),
                    c64!(-0.01584819469345664-0.0226953437761387 i)
                ],
                [
                    c64!(-0.056034022790537846-0.036908002543958186 i),
                    c64!(0.0018735469690044958+0.06902010846664941 i),
                    c64!(-0.041185031194788585-0.08029190991743244 i),
                    c64!(-0.04347757666054865+0.08205187251872782 i),
                    c64!(-0.0019561251961318+0.02048917298063907 i),
                    c64!(0.018439071579274272-0.010420896562482896 i),
                    c64!(-0.01584819469345664+0.0226953437761387 i),
                    c64!(0.02848496943036968)
                ]
            ]),
        };
        let superop = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(array![
                [
                    c64!(0.6293495134219425-1.734723475976807e-17 i),
                    c64!(-0.024533943633224718+0.13938660032933953 i),
                    c64!(-0.02453394363322476-0.13938660032933947 i),
                    c64!(0.5247820634430066+1.9081958235744878e-17 i)
                ],
                [
                    c64!(0.2803975281674814-0.18063396704778287 i),
                    c64!(-0.05604391528804912+0.10409667637158168 i),
                    c64!(-0.1685036883643372-0.09634125208349568 i),
                    c64!(-0.02267578453257638+0.0826385973172321 i)
                ],
                [
                    c64!(0.2803975281674815+0.18063396704778284 i),
                    c64!(-0.16850368836433724+0.09634125208349568 i),
                    c64!(-0.05604391528804914-0.1040966763715817 i),
                    c64!(-0.022675784532576366-0.08263859731723212 i)
                ],
                [
                    c64!(0.37065048657805805+1.734723475976807e-18 i),
                    c64!(0.024533943633224895-0.1393866003293396 i),
                    c64!(0.02453394363322485+0.1393866003293397 i),
                    c64!(0.4752179365569933+3.2959746043559335e-17 i)
                ]
            ]),
        };
        let rho_out = superop.apply_to(&[1], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [
                        c64!(0.26956196039468133),
                        c64!(-0.15881339473054268-0.22742808625094846 i),
                        c64!(0.017243585655893613+0.015251212382805343 i),
                        c64!(0.0027082518201749853-0.023533633932642822 i),
                        c64!(-0.03871603769659798-0.07306578778099337 i),
                        c64!(-0.038835549693321744+0.0757114992294755 i),
                        c64!(0.0016572758798486442-0.0068644057972392074 i),
                        c64!(-0.006767855076913281+0.0026459538455627586 i)
                    ],
                    [
                        c64!(-0.15881339473054268+0.22742808625094846 i),
                        c64!(0.28544542653180005),
                        c64!(-0.023026492356263535+0.005563021100450382 i),
                        c64!(0.018259633723087042+0.016149863346307827 i),
                        c64!(0.08445493432837799+0.010382442060839554 i),
                        c64!(-0.04099731237206387-0.07737106128583843 i),
                        c64!(0.004815075032589168+0.0054424246917606145 i),
                        c64!(0.0017549279568661062-0.0072688788796884275 i)
                    ],
                    [
                        c64!(0.017243585655893613-0.015251212382805367 i),
                        c64!(-0.02302649235626354-0.005563021100450368 i),
                        c64!(0.1743567169797261),
                        c64!(-0.10272288447924903-0.14710389555573122 i),
                        c64!(-0.006610521592267539-0.002483472280752108 i),
                        c64!(0.0017993192593965075+0.00704041080461318 i),
                        c64!(-0.02504211357328937-0.047260046864100305 i),
                        c64!(-0.025119415724371583+0.04897133269077113 i)
                    ],
                    [
                        c64!(0.0027082518201749957+0.02353363393264284 i),
                        c64!(0.018259633723087042-0.016149863346307827 i),
                        c64!(-0.10272288447924904+0.1471038955557312 i),
                        c64!(0.18463038098584866),
                        c64!(0.005989905700018602-0.004114117621049974 i),
                        c64!(-0.007000034992844311-0.002629806532870039 i),
                        c64!(0.05462671758535295+0.006715519167874121 i),
                        c64!(-0.026517676231910946-0.050044762307278966 i)
                    ],
                    [
                        c64!(-0.03871603769659798+0.07306578778099337 i),
                        c64!(0.08445493432837799-0.010382442060839553 i),
                        c64!(-0.006610521592267533+0.0024834722807521113 i),
                        c64!(0.005989905700018601+0.00411411762104997 i),
                        c64!(0.025365377625872418),
                        c64!(-0.014944103105233367-0.02140064303597717 i),
                        c64!(0.0016225956405177121+0.001435116293025267 i),
                        c64!(0.00025484244892756214-0.0022144797831879417 i)
                    ],
                    [
                        c64!(-0.038835549693321744-0.0757114992294755 i),
                        c64!(-0.040997312372063874+0.07737106128583843 i),
                        c64!(0.001799319259396504-0.00704041080461318 i),
                        c64!(-0.007000034992844309+0.0026298065328700434 i),
                        c64!(-0.014944103105233367+0.02140064303597717 i),
                        c64!(0.026859988052306022),
                        c64!(-0.0021667585187491217+0.0005234719718873384 i),
                        c64!(0.0017182042452060908+0.0015196780057005993 i)
                    ],
                    [
                        c64!(0.0016572758798486477+0.006864405797239211 i),
                        c64!(0.004815075032589164-0.005442424691760617 i),
                        c64!(-0.025042113573289376+0.047260046864100305 i),
                        c64!(0.05462671758535295-0.0067155191678741144 i),
                        c64!(0.001622595640517712-0.0014351162930252683 i),
                        c64!(-0.002166758518749123-0.0005234719718873377 i),
                        c64!(0.016406706500140797),
                        c64!(-0.009666069915131952-0.013842256732161828 i)
                    ],
                    [
                        c64!(-0.006767855076913282-0.002645953845562754 i),
                        c64!(0.0017549279568661097+0.007268878879688429 i),
                        c64!(-0.025119415724371576-0.04897133269077113 i),
                        c64!(-0.026517676231910956+0.050044762307278966 i),
                        c64!(0.00025484244892756344+0.002214479783187942 i),
                        c64!(0.00171820424520609-0.0015196780057006006 i),
                        c64!(-0.009666069915131954+0.013842256732161827 i),
                        c64!(0.017373442929624686)
                    ]
                ];
                for (actual, expected) in actual.iter().zip(expected.iter()) {
                    assert_abs_diff_eq!(actual, expected, epsilon = 1e-6);
                }
                Ok(())
            }
            _ => panic!("did not return density operator as expected"),
        }
    }
}
