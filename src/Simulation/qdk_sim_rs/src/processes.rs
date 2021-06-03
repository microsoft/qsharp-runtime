// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::linalg::{extend_one_to_n, extend_two_to_n, zeros_like};
use crate::log_as_err;
use crate::states::StateData::{Mixed, Pure, Stabilizer};
use crate::NoiseModel;
use crate::QubitSized;
use crate::State;
use crate::C64;
use crate::{linalg::ConjBy, AsUnitary, Pauli};
use crate::{
    log,
    processes::ProcessData::{KrausDecomposition, MixedPauli, Unitary},
};
use itertools::Itertools;
use ndarray::{Array, Array2, Array3, ArrayView2, Axis, NewAxis};
use num_complex::Complex;
use num_traits::{One, Zero};
use rand::{distributions::WeightedIndex, prelude::Distribution, thread_rng};
use serde::{Deserialize, Serialize};
use std::convert::TryInto;
use std::ops::Add;
use std::ops::Mul;

/// A linear function from quantum states to quantum states.
///
/// # Remarks
/// A process that is completely positive and trace preserving is a channel.
pub type Process = QubitSized<ProcessData>;

/// Data used to represent a given process.
#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum ProcessData {
    /// Representation of a process as a mixture of Pauli operators
    /// $\{(p_i, P_i)\}$ such that the channel acts as $\rho \mapsto
    /// \sum_i p_i P_i \rho P_i^{\dagger}$.
    MixedPauli(Vec<(f64, Vec<Pauli>)>),

    /// Representation of the process by an arbitrary unitary matrix.
    Unitary(Array2<C64>),

    /// Representation of the process by the singular vectors of its Choi
    /// representation (colloquially, the Kraus decomposition).
    ///
    /// The first index denotes each Kraus operator, with the second and third
    /// indices representing the indices of each operator.
    KrausDecomposition(Array3<C64>), // TODO: Superoperator and Choi reps.

    /// Represents a process that is not supported by a given noise model,
    /// and thus always fails when applied.
    Unsupported,
}

impl Process {
    /// Returns a new Pauli channel, given a mixture of Pauli operators.
    pub fn new_pauli_channel<T: IntoPauliMixture>(data: T) -> Self {
        let data = data.into_pauli_mixture();
        // How many qubits?
        // TODO: check that every Pauli is supported on the same number of
        //       qubits.
        let n_qubits = data[0].1.len();
        Process {
            n_qubits,
            data: MixedPauli(data),
        }
    }
    // TODO: methods to forcibly convert representations.

    /// Applies this process to a quantum register with a given
    /// state, returning the new state of that register.
    pub fn apply(&self, state: &State) -> Result<State, String> {
        if state.n_qubits != self.n_qubits {
            return Err(format!(
                "Channel acts on {} qubits, but was applied to {}-qubit state.",
                self.n_qubits, state.n_qubits
            ));
        }

        return match &self.data {
            Unitary(u) => apply_unitary(&u, state),
            KrausDecomposition(ks) => apply_kraus_decomposition(&ks, state),
            MixedPauli(paulis) => apply_pauli_channel(&paulis, state),
            ProcessData::Unsupported => return Err(format!("Unsupported quantum process.")),
        };
    }

    /// Applies this process to the given qubits in a register with a given
    /// state, returning the new state of that register.
    pub fn apply_to(&self, idx_qubits: &[usize], state: &State) -> Result<State, String> {
        // Fail if there's not enough qubits.
        if state.n_qubits < self.n_qubits {
            return log_as_err(format!(
                "Channel acts on {} qubits, but a state on only {} qubits was given.",
                self.n_qubits, state.n_qubits
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
        // indices in ascending order, so we can proceed to make a new channel
        // that expands this channel to act on the full register and then use
        // the ordinary apply method.
        // TODO[perf]: For larger systems, this could be improved by using
        //             matrix multiplication kernels to avoid extending
        //             channels to larger Hilbert spaces.
        //             For smaller systems, extending channels and possibly
        //             caching them is likely to be more performant; need to
        //             tune to find crossover point.
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

    /// Returns a copy of this process that applies to registers of a given
    /// size.
    pub fn extend_one_to_n(&self, idx_qubit: usize, n_qubits: usize) -> Process {
        assert_eq!(self.n_qubits, 1);
        Process {
            n_qubits,
            data: match &self.data {
                Unitary(u) => Unitary(extend_one_to_n(u.view(), idx_qubit, n_qubits)),
                KrausDecomposition(ks) => {
                    let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
                    let n_kraus = ks.shape()[0];
                    let mut extended: Array3<C64> = Array::zeros((n_kraus, new_dim, new_dim));
                    for (idx_kraus, kraus) in ks.axis_iter(Axis(0)).enumerate() {
                        let mut target = extended.index_axis_mut(Axis(0), idx_kraus);
                        let big_kraus = extend_one_to_n(kraus.view(), idx_qubit, n_qubits);
                        target.assign(&big_kraus);
                    }
                    KrausDecomposition(extended)
                },
                MixedPauli(paulis) => MixedPauli(
                    paulis.iter()
                        .map(|(pr, pauli)| {
                            if pauli.len() != 1 {
                                panic!("Pauli channel acts on more than one qubit, cannot extend to 𝑛 qubits.");
                            }
                            let p = pauli[0];
                            let mut extended = std::iter::repeat(Pauli::I).take(n_qubits).collect_vec();
                            extended[idx_qubit] = p;
                            (*pr, extended)
                        })
                        .collect_vec()
                ),
                ProcessData::Unsupported => ProcessData::Unsupported
            },
        }
    }

    /// Returns a copy of this process that applies to registers of a given
    /// size.
    pub fn extend_two_to_n(
        &self,
        idx_qubit1: usize,
        idx_qubit2: usize,
        n_qubits: usize,
    ) -> Process {
        assert_eq!(self.n_qubits, 2);
        Process {
            n_qubits,
            data: match &self.data {
                Unitary(u) => Unitary(extend_two_to_n(u.view(), idx_qubit1, idx_qubit2, n_qubits)),
                KrausDecomposition(ks) => {
                    // TODO: consolidate with extend_one_to_n, above.
                    let new_dim = 2usize.pow(n_qubits.try_into().unwrap());
                    let n_kraus = ks.shape()[0];
                    let mut extended: Array3<C64> = Array::zeros((n_kraus, new_dim, new_dim));
                    for (idx_kraus, kraus) in ks.axis_iter(Axis(0)).enumerate() {
                        let mut target = extended.index_axis_mut(Axis(0), idx_kraus);
                        let big_kraus = extend_two_to_n(kraus, idx_qubit1, idx_qubit2, n_qubits);
                        target.assign(&big_kraus);
                    }
                    KrausDecomposition(extended)
                },
                MixedPauli(paulis) => MixedPauli(
                    paulis.iter()
                        .map(|(pr, pauli)| {
                            if pauli.len() != 2 {
                                panic!("Pauli channel acts on more than one qubit, cannot extend to 𝑛 qubits.");
                            }
                            let p = (pauli[0], pauli[1]);
                            let mut extended = std::iter::repeat(Pauli::I).take(n_qubits).collect_vec();
                            extended[idx_qubit1] = p.0;
                            extended[idx_qubit2] = p.1;
                            (*pr, extended)
                        })
                        .collect_vec()
                ),
                ProcessData::Unsupported => ProcessData::Unsupported
            },
        }
    }
}

impl Mul<&Process> for C64 {
    type Output = Process;

    fn mul(self, channel: &Process) -> Self::Output {
        Process {
            n_qubits: channel.n_qubits,
            data: match &channel.data {
                // Note that we need to multiply by the square root in
                // both cases, since these representations are both in terms
                // of linear operators, but the multiplication is on
                // superoperators (two copies of the original vectorspace).
                Unitary(u) => KrausDecomposition({
                    let mut ks = Array3::<C64>::zeros((1, u.shape()[0], u.shape()[1]));
                    ks.index_axis_mut(Axis(0), 0).assign(&(self.sqrt() * u));
                    ks
                }),
                KrausDecomposition(ks) => KrausDecomposition(self.sqrt() * ks),
                MixedPauli(paulis) => (self * promote_pauli_channel(paulis)).data,
                ProcessData::Unsupported => ProcessData::Unsupported,
            },
        }
    }
}

impl Mul<Process> for C64 {
    type Output = Process;
    fn mul(self, channel: Process) -> Self::Output {
        self * (&channel)
    }
}

impl Mul<&Process> for f64 {
    type Output = Process;
    fn mul(self, chanel: &Process) -> Self::Output {
        C64::new(self, 0f64) * chanel
    }
}

impl Mul<Process> for f64 {
    type Output = Process;
    fn mul(self, channel: Process) -> Self::Output {
        self * (&channel)
    }
}

// Base case: both channels that we're composing are borrowed.
impl Mul<&Process> for &Process {
    type Output = Process;

    fn mul(self, rhs: &Process) -> Self::Output {
        assert_eq!(self.n_qubits, rhs.n_qubits);
        Process {
            n_qubits: self.n_qubits,
            data: match (&self.data, &rhs.data) {
                (Unitary(u), Unitary(v)) => Unitary(u.dot(v)),
                (Unitary(u), KrausDecomposition(ks)) => {
                    // post-multiply each kraus operator by u.
                    let mut post = zeros_like(ks);
                    for (idx_kraus, kraus) in ks.axis_iter(Axis(0)).enumerate() {
                        post.index_axis_mut(Axis(0), idx_kraus)
                            .assign(&u.dot(&kraus));
                    }
                    KrausDecomposition(post)
                }
                // TODO: product of two kraus decompositions would be... not
                //       fun.
                _ => todo!(),
            },
        }
    }
}

impl Add<&Process> for &Process {
    type Output = Process;

    fn add(self, rhs: &Process) -> Self::Output {
        assert_eq!(self.n_qubits, rhs.n_qubits);
        Process {
            n_qubits: self.n_qubits,
            data: match (&self.data, &rhs.data) {
                (KrausDecomposition(ks1), KrausDecomposition(ks2)) => {
                    let mut sum = Array::zeros([
                        ks1.shape()[0] + ks2.shape()[0],
                        ks1.shape()[1],
                        ks1.shape()[2],
                    ]);
                    for (idx_kraus, kraus) in ks1.axis_iter(Axis(0)).enumerate() {
                        sum.index_axis_mut(Axis(0), idx_kraus).assign(&kraus);
                    }
                    for (idx_kraus, kraus) in ks2.axis_iter(Axis(0)).enumerate() {
                        sum.index_axis_mut(Axis(0), ks1.shape()[0] + idx_kraus)
                            .assign(&kraus);
                    }
                    KrausDecomposition(sum)
                }
                _ => todo!(),
            },
        }
    }
}

impl Mul<Process> for &Process {
    type Output = Process;

    fn mul(self, rhs: Process) -> Self::Output {
        self * &rhs
    }
}

impl Mul<&Process> for Process {
    type Output = Process;

    fn mul(self, rhs: &Process) -> Self::Output {
        &self * rhs
    }
}

impl Mul<Process> for Process {
    type Output = Process;

    fn mul(self, rhs: Process) -> Self::Output {
        &self * &rhs
    }
}

impl Add<Process> for &Process {
    type Output = Process;

    fn add(self, rhs: Process) -> Self::Output {
        self + &rhs
    }
}

impl Add<&Process> for Process {
    type Output = Process;

    fn add(self, rhs: &Process) -> Self::Output {
        &self + rhs
    }
}

impl Add<Process> for Process {
    type Output = Process;

    fn add(self, rhs: Process) -> Self::Output {
        &self + &rhs
    }
}

/// Returns a copy of a depolarizing channel of a given strength (that is, a
/// channel representing relaxation to the maximally mixed state).
pub fn depolarizing_channel(p: f64) -> Process {
    let ideal = NoiseModel::ideal();
    (1.0 - p) * ideal.i + p / 3.0 * ideal.x + p / 3.0 * ideal.y + p / 3.0 * ideal.z
}

/// Returns a copy of an amplitude damping channel of a given strength (that is,
/// a channel representing relaxation to the $\ket{0}$ state in a
/// characteristic time given by $1 / \gamma$).
pub fn amplitude_damping_channel(gamma: f64) -> Process {
    Process {
        n_qubits: 1,
        data: KrausDecomposition(array![
            [
                [C64::one(), C64::zero()],
                [C64::zero(), C64::one() * (1.0 - gamma).sqrt()]
            ],
            [
                [C64::zero(), C64::one() * gamma.sqrt()],
                [C64::zero(), C64::zero()]
            ]
        ]),
    }
}

/// A type that can be converted into a mixture of Pauli operators.
pub trait IntoPauliMixture {
    /// Convert this value into a mixture of multi-qubit Pauli operators.
    fn into_pauli_mixture(self) -> Vec<(f64, Vec<Pauli>)>;
}

impl IntoPauliMixture for Vec<(f64, Vec<Pauli>)> {
    fn into_pauli_mixture(self) -> Vec<(f64, Vec<Pauli>)> {
        self
    }
}

impl IntoPauliMixture for Vec<Pauli> {
    fn into_pauli_mixture(self) -> Vec<(f64, Vec<Pauli>)> {
        vec![(1.0, self)]
    }
}

impl IntoPauliMixture for Vec<(f64, Pauli)> {
    fn into_pauli_mixture(self) -> Vec<(f64, Vec<Pauli>)> {
        self.iter().map(|(pr, p)| (*pr, vec![*p])).collect_vec()
    }
}

impl IntoPauliMixture for Pauli {
    fn into_pauli_mixture(self) -> Vec<(f64, Vec<Pauli>)> {
        vec![(1.0, vec![self])]
    }
}

/// Given a vector of Paulis and the probability of applying each one, promotes
/// that vector to a process that acts on state vectors (e.g.: a unitary matrix,
/// or Kraus decomposition).
///
/// This function is a private utility mainly used in handling the case where
/// a mixed Pauli channel is applied to a pure or mixed state.
fn promote_pauli_channel(paulis: &[(f64, Vec<Pauli>)]) -> Process {
    // TODO: Check that there's at least one Pauli... empty vectors aren't
    //       supported here.
    if paulis.len() == 1 {
        // Just one Pauli, so can box it up into a unitary.
        let (_, pauli) = &paulis[0];
        // TODO[testing]: check that pr is 1.0.
        Process {
            n_qubits: pauli.len(),
            data: Unitary(pauli.as_unitary()),
        }
    } else {
        // To turn a mixed Pauli channel into a Kraus decomposition, we need
        // to take the square root of each probability.
        let matrices = paulis
            .iter()
            .map(|p| {
                p.1.as_unitary()
                    * Complex {
                        re: p.0.sqrt(),
                        im: 0.0f64,
                    }
            })
            .map(|u| {
                let x = u.slice(s![NewAxis, .., ..]);
                x.to_owned()
            })
            .collect_vec();
        Process {
            n_qubits: paulis[0].1.len(),
            data: KrausDecomposition(
                ndarray::concatenate(
                    Axis(0),
                    matrices.iter().map(|u| u.view()).collect_vec().as_slice(),
                )
                .unwrap(),
            ),
        }
    }
}

// Private functions for applying processes of each different representation.

fn apply_unitary(u: &Array2<C64>, state: &State) -> Result<State, String> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(psi) => Pure(u.dot(psi)),
            Mixed(rho) => Mixed(rho.conjugate_by(&u.into())),
            Stabilizer(_tableau) => {
                return Err(format!(
                    "TODO: Promote stabilizer state to state vector and recurse."
                ))
            }
        },
    })
}

fn apply_kraus_decomposition(ks: &Array3<C64>, state: &State) -> Result<State, String> {
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
                return Err(format!(
                    "TODO: Promote stabilizer state to state vector and recurse."
                ))
            }
        },
    })
}

fn apply_pauli_channel(paulis: &[(f64, Vec<Pauli>)], state: &State) -> Result<State, String> {
    Ok(State {
        n_qubits: state.n_qubits,
        data: match &state.data {
            Pure(_) | Mixed(_) => {
                // Promote and recurse.
                let promoted = promote_pauli_channel(paulis);
                return promoted.apply(state);
            }
            Stabilizer(tableau) => {
                // TODO[perf]: Introduce an apply_mut method to
                //             avoid extraneous cloning.
                let mut new_tableau = tableau.clone();
                // Sample a Pauli and apply it.
                let weighted = WeightedIndex::new(paulis.iter().map(|(pr, _)| pr)).unwrap();
                let idx = weighted.sample(&mut thread_rng());
                let pauli = &(&paulis)[idx].1;
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
