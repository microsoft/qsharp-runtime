// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! Public implementations and crate-private functions for applying processes
//! in each different representation.

use std::ops::Add;

use cauchy::c64;
use itertools::Itertools;
use ndarray::{Array, Array2, Array3, ArrayView2, Axis};
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
            if superop.shape() != &[4, 4] {
                Err(QdkSimError::MiscError(format!(
                    "Expected 4x4 superoperator but got {:?}.",
                    superop.shape()
                )))?;
            }
            let superop = superop.into_shape((2, 2, 2, 2)).unwrap();
            // In the column-stacking basis, `superop` is indexed as
            // `rho_out[i, j] = sum_{k, l} S[j, i, l, k] rho_in[k, l]`.
            // For applying to multiple qubits, we'll represent this by
            // reshaping such that:
            // `rho_out[:, i, :, :, j, :] = sum_{k, l} S[j, i, l, k] rho_in[:, k, :, :, l, :]`.
            let n_left = idx_qubit;
            let n_right = n_qubits - idx_qubit - 1;
            let rho_in = state
                .into_shape((
                    2usize.pow(n_left as u32),
                    2,
                    2usize.pow(n_right as u32),
                    2usize.pow(n_left as u32),
                    2,
                    2usize.pow(n_right as u32),
                ))
                .map_err(|e| QdkSimError::InternalShapeError(e))?;
            let mut rho_out = zeros_like(&rho_in);
            for i in 0..2usize {
                for j in 0..2usize {
                    for k in 0..2usize {
                        for l in 0..2usize {
                            let sl_out = s![.., i, .., .., j, ..];
                            let this_submatrix =
                                superop[(j, i, k, l)] * &rho_in.slice(s![.., k, .., .., l, ..]);
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
    use crate::{c64, Generator, ProcessData};

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
    #[cfg(any())] // Disable broken test for now.
    #[test]
    fn rand_super_acts_correctly_on_three_qubit_register() -> Result<(), QdkSimError> {
        let rho_in = State {
            n_qubits: 3,
            data: StateData::Mixed(array![
                [
                    c64!(0.0856888085413523),
                    c64!(0.0926301812983617+0.08193361016482166 i),
                    c64!(0.09030571973222659+0.05014481586062699 i),
                    c64!(0.04967380768877985+0.14055507627608643 i),
                    c64!(-0.0561700389052341+0.028861174609884202 i),
                    c64!(-0.08831656368592024-0.02250933659646181 i),
                    c64!(-0.0760859462051226-0.0024543124814563125 i),
                    c64!(-0.07990266670419911-0.07540470891708197 i)
                ],
                [
                    c64!(0.0926301812983617-0.08193361016482166 i),
                    c64!(0.17847683054932312),
                    c64!(0.14556837932420288-0.03214130641718444 i),
                    c64!(0.1880931584024206+0.10444406866697338 i),
                    c64!(-0.03312381985767742+0.0849075863120496 i),
                    c64!(-0.11699369715008227+0.06011346239943223 i),
                    c64!(-0.08459617768892133+0.07009845214936378 i),
                    c64!(-0.15847552042322133-0.0051119617640216775 i)
                ],
                [
                    c64!(0.09030571973222659-0.05014481586062699 i),
                    c64!(0.14556837932420288+0.03214130641718444 i),
                    c64!(0.12451597537270721),
                    c64!(0.13460261111869798+0.11905922791021836 i),
                    c64!(-0.04230701262044968+0.06328674065567409 i),
                    c64!(-0.10624744983255224+0.027960430565202067 i),
                    c64!(-0.08162171116701769+0.041938700842333254 i),
                    c64!(-0.12833441444819774-0.03270872881781795 i)
                ],
                [
                    c64!(0.04967380768877985-0.14055507627608643 i),
                    c64!(0.1880931584024206-0.10444406866697338 i),
                    c64!(0.13460261111869798-0.11905922791021836 i),
                    c64!(0.25934794771424236),
                    c64!(0.014779116547625842+0.1088663583821186 i),
                    c64!(-0.08811910973022977+0.13181671072682477 i),
                    c64!(-0.04813282863722102+0.12338076705880566 i),
                    c64!(-0.17000568173463965+0.08735197199157767 i)
                ],
                [
                    c64!(-0.0561700389052341-0.028861174609884202 i),
                    c64!(-0.03312381985767742-0.0849075863120496 i),
                    c64!(-0.04230701262044968-0.06328674065567409 i),
                    c64!(0.014779116547625842-0.1088663583821186 i),
                    c64!(0.0465409747009513),
                    c64!(0.05031110827350463+0.044501378216717034 i),
                    c64!(0.0490486014329454+0.02723562908716424 i),
                    c64!(0.02697980595479684+0.0763410106921809 i)
                ],
                [
                    c64!(-0.08831656368592024+0.02250933659646181 i),
                    c64!(-0.11699369715008227-0.06011346239943223 i),
                    c64!(-0.10624744983255224-0.027960430565202067 i),
                    c64!(-0.08811910973022977-0.13181671072682477 i),
                    c64!(0.05031110827350463-0.044501378216717034 i),
                    c64!(0.09693781249500533),
                    c64!(0.07906393349041296-0.017457212374423554 i),
                    c64!(0.10216081978085269+0.056727696886440034 i)
                ],
                [
                    c64!(-0.0760859462051226+0.0024543124814563125 i),
                    c64!(-0.08459617768892133-0.07009845214936378 i),
                    c64!(-0.08162171116701769-0.041938700842333254 i),
                    c64!(-0.04813282863722102-0.12338076705880566 i),
                    c64!(0.0490486014329454-0.02723562908716424 i),
                    c64!(0.07906393349041296+0.017457212374423554 i),
                    c64!(0.06762954180753727),
                    c64!(0.07310799187660691+0.06466576684177129 i)
                ],
                [
                    c64!(-0.07990266670419911+0.07540470891708197 i),
                    c64!(-0.15847552042322133+0.0051119617640216775 i),
                    c64!(-0.12833441444819774+0.03270872881781795 i),
                    c64!(-0.17000568173463965-0.08735197199157767 i),
                    c64!(0.02697980595479684-0.0763410106921809 i),
                    c64!(0.10216081978085269-0.056727696886440034 i),
                    c64!(0.07310799187660691-0.06466576684177129 i),
                    c64!(0.14086210881888056)
                ]
            ]),
        };
        let superop = Process {
            n_qubits: 1,
            data: ProcessData::Superoperator(array![
                [
                    c64!(0.25027585998466395+1.734723475976807e-18 i),
                    c64!(0.060170166947201675+0.155821271341433 i),
                    c64!(0.06017016694720173-0.155821271341433 i),
                    c64!(0.4499138625167405+6.331740687315346e-17 i)
                ],
                [
                    c64!(-0.39204179797209954+0.05368378514843615 i),
                    c64!(0.13219948617355545+0.14573952065883514 i),
                    c64!(-0.16481663424715376+0.31177253928622806 i),
                    c64!(0.12365634629284619-0.15217747182519195 i)
                ],
                [
                    c64!(-0.39204179797209954-0.05368378514843615 i),
                    c64!(-0.16481663424715365-0.31177253928622817 i),
                    c64!(0.13219948617355548-0.14573952065883508 i),
                    c64!(0.12365634629284611+0.15217747182519198 i)
                ],
                [
                    c64!(0.7497241400153368-1.3010426069826053e-18 i),
                    c64!(-0.060170166947201884-0.15582127134143314 i),
                    c64!(-0.06017016694720184+0.15582127134143317 i),
                    c64!(0.5500861374832601+6.678685382510707e-17 i)
                ]
            ]),
        };
        let rho_out = superop.apply_to(&[1], &rho_in)?;
        match rho_out.data {
            StateData::Mixed(actual) => {
                let expected = array![
                    [
                        c64!(0.10396198205604266),
                        c64!(0.11238360539627455+0.09940598608780188 i),
                        c64!(-0.029467614175213347-0.012073710446671247 i),
                        c64!(-0.020310094026570802-0.04122799768225873 i),
                        c64!(-0.06814832270581841+0.035015831915332446 i),
                        c64!(-0.1071501070613683-0.027309461844197285 i),
                        c64!(0.02338296603913898-0.0020106379754869733 i),
                        c64!(0.02719966879269007+0.020184725324062163 i)
                    ],
                    [
                        c64!(0.11238360539627457-0.09940598608780188 i),
                        c64!(0.21653708775789304),
                        c64!(-0.0433992862284463+0.015124472457506389 i),
                        c64!(-0.0613765843097739-0.025147713104824186 i),
                        c64!(-0.04018748800795385+0.10301416386639714 i),
                        c64!(-0.1419426509812806+0.07293268287515559 i),
                        c64!(0.023354619926439696-0.024531751811304063 i),
                        c64!(0.04870318234724897-0.004187854859410789 i)
                    ],
                    [
                        c64!(-0.029467614175213333+0.01207371044667124 i),
                        c64!(-0.04339928622844629-0.015124472457506389 i),
                        c64!(0.10624280185801695),
                        c64!(0.1148491870207852+0.10158685198723824 i),
                        c64!(0.015249781056822443-0.017839561193453625 i),
                        c64!(0.03354288249909111-0.004703206618047051 i),
                        c64!(-0.06964342736643343+0.03578404353688503 i),
                        c64!(-0.10950087107274978-0.027908603570082506 i)
                    ],
                    [
                        c64!(-0.0203100940265708+0.04122799768225871 i),
                        c64!(-0.06137658430977388+0.02514771310482418 i),
                        c64!(0.1148491870207852-0.10158685198723823 i),
                        c64!(0.2212876905056726),
                        c64!(-0.0005726496740638548-0.03386616587673704 i),
                        c64!(0.03176298790850037-0.0371571083131792 i),
                        c64!(-0.04106916048694463+0.1052741895044582 i),
                        c64!(-0.14505672790344146+0.07453275151585437 i)
                    ],
                    [
                        c64!(-0.06814832270581841-0.03501583191533245 i),
                        c64!(-0.04018748800795385-0.10301416386639714 i),
                        c64!(0.015249781056822443+0.017839561193453632 i),
                        c64!(-0.0005726496740638548+0.03386616587673705 i),
                        c64!(0.056465856616457005),
                        c64!(0.061039972717388924+0.05399131534665744 i),
                        c64!(-0.016005024567054788-0.006557708783801814 i),
                        c64!(-0.011031213858089852-0.022392553120573484 i)
                    ],
                    [
                        c64!(-0.1071501070613683+0.027309461844197278 i),
                        c64!(-0.1419426509812806-0.07293268287515559 i),
                        c64!(0.033542882499091126+0.004703206618047056 i),
                        c64!(0.03176298790850037+0.0371571083131792 i),
                        c64!(0.061039972717388924-0.05399131534665742 i),
                        c64!(0.11760984070976238),
                        c64!(-0.023571865647107365+0.008214698068422118 i),
                        c64!(-0.033336045934323724-0.013658715756720851 i)
                    ],
                    [
                        c64!(0.02338296603913897+0.002010637975486975 i),
                        c64!(0.023354619926439685+0.02453175181130406 i),
                        c64!(-0.06964342736643343-0.03578404353688504 i),
                        c64!(-0.041069160486944624-0.10527418950445822 i),
                        c64!(-0.01600502456705479+0.006557708783801812 i),
                        c64!(-0.02357186564710736-0.00821469806842212 i),
                        c64!(0.05770465989203162),
                        c64!(0.06237912743272266+0.05517582971183095 i)
                    ],
                    [
                        c64!(0.027199668792690066-0.02018472532406216 i),
                        c64!(0.048703182347248956+0.0041878548594107955 i),
                        c64!(-0.10950087107274978+0.0279086035700825 i),
                        c64!(-0.14505672790344146-0.0745327515158544 i),
                        c64!(-0.01103121385808985+0.022392553120573488 i),
                        c64!(-0.033336045934323724+0.01365871575672084 i),
                        c64!(0.06237912743272267-0.055175829711830944 i),
                        c64!(0.12019008060412362)
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
