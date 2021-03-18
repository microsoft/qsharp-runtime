// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::channels::ChannelData::{KrausDecomposition, Unitary};
use crate::linalg::ConjBy;
use crate::linalg::{extend_one_to_n, extend_two_to_n};
use crate::states::StateData::{Mixed, Pure};
use crate::zeros_like;
use crate::NoiseModel;
use crate::QubitSized;
use crate::State;
use crate::C64;
use crate::{log_as_err, log_message};
use itertools::Itertools;
use ndarray::{Array, Array2, Array3, ArrayView2, Axis};
use num_traits::{One, Zero};
use serde::{Deserialize, Serialize};
use std::convert::TryInto;
use std::ops::Add;
use std::ops::Mul;

pub type Channel = QubitSized<ChannelData>;

#[derive(Clone, Debug, Serialize, Deserialize)]
pub enum ChannelData {
    Unitary(Array2<C64>),
    KrausDecomposition(Array3<C64>), // TODO: Superoperator and Choi reps.
}

impl Channel {
    // TODO: methods to forcibly convert representations.
    pub fn apply(self: &Self, state: &State) -> Result<State, String> {
        if state.n_qubits == self.n_qubits {
            Ok(State {
                n_qubits: self.n_qubits,
                data: match &state.data {
                    Pure(psi) => match &self.data {
                        Unitary(u) => Pure(u.dot(psi)),
                        KrausDecomposition(ks) => {
                            // We can't apply a channel with more than one Kraus operator (Choi rank > 1) to a
                            // pure state directly, so if the Choi rank is bigger than 1, promote to
                            // Mixed and recurse.
                            if ks.shape()[0] == 1 {
                                Pure({ let k: ArrayView2<C64> = ks.slice(s![0, .., ..]); k.dot(psi) })
                            } else {
                                self.apply(&state.to_mixed())?.data
                            }
                        }
                    },
                    Mixed(rho) => match &self.data {
                        Unitary(u) => Mixed(rho.conjugate_by(&u.into())),
                        KrausDecomposition(ks) => Mixed({
                            let mut sum: Array2<C64> =
                                Array::zeros((rho.shape()[0], rho.shape()[1]));
                            for k in ks.axis_iter(Axis(0)) {
                                sum = sum + rho.conjugate_by(&k);
                            }
                            sum
                        }),
                    },
                },
            })
        } else {
            Err(format!(
                "Channel acts on {} qubits, but was applied to {}-qubit state.",
                self.n_qubits, state.n_qubits
            ))
        }
    }

    pub fn apply_to(self: &Self, idx_qubits: &[usize], state: &State) -> Result<State, String> {
        // Fail if there's not enough qubits.
        if state.n_qubits < self.n_qubits {
            return log_as_err(format!(
                "Channel acts on {} qubits, but a state on only {} qubits was given.",
                self.n_qubits, state.n_qubits
            ));
        }

        // Fail if any indices are repeated.
        if idx_qubits.into_iter().unique().count() < idx_qubits.len() {
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
        let expanded = match self.n_qubits {
            1 => self.extend_one_to_n(idx_qubits[0], state.n_qubits),
            2 => self.extend_two_to_n(idx_qubits[0], idx_qubits[1], state.n_qubits),
            _ => {
                log_message(&format!(
                    "Expanding {}-qubit channels is not yet implemented.",
                    self.n_qubits
                ));
                unimplemented!("");
            }
        };
        expanded.apply(state)
    }

    pub fn extend_one_to_n(self: &Self, idx_qubit: usize, n_qubits: usize) -> Channel {
        assert_eq!(self.n_qubits, 1);
        Channel {
            n_qubits: n_qubits,
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
                }
            },
        }
    }

    pub fn extend_two_to_n(
        self: &Self,
        idx_qubit1: usize,
        idx_qubit2: usize,
        n_qubits: usize,
    ) -> Channel {
        assert_eq!(self.n_qubits, 2);
        Channel {
            n_qubits: n_qubits,
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
                }
            },
        }
    }
}

impl Mul<&Channel> for C64 {
    type Output = Channel;

    fn mul(self, channel: &Channel) -> Self::Output {
        Channel {
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
            },
        }
    }
}

impl Mul<Channel> for C64 {
    type Output = Channel;
    fn mul(self, channel: Channel) -> Self::Output {
        self * (&channel)
    }
}

impl Mul<&Channel> for f64 {
    type Output = Channel;
    fn mul(self, chanel: &Channel) -> Self::Output {
        C64::new(self, 0f64) * chanel
    }
}

impl Mul<Channel> for f64 {
    type Output = Channel;
    fn mul(self, channel: Channel) -> Self::Output {
        self * (&channel)
    }
}

// Base case: both channels that we're composing are borrowed.
impl Mul<&Channel> for &Channel {
    type Output = Channel;

    fn mul(self, rhs: &Channel) -> Self::Output {
        assert_eq!(self.n_qubits, rhs.n_qubits);
        Channel {
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

impl Add<&Channel> for &Channel {
    type Output = Channel;

    fn add(self, rhs: &Channel) -> Self::Output {
        assert_eq!(self.n_qubits, rhs.n_qubits);
        Channel {
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

impl Mul<Channel> for &Channel {
    type Output = Channel;

    fn mul(self, rhs: Channel) -> Self::Output {
        self * &rhs
    }
}

impl Mul<&Channel> for Channel {
    type Output = Channel;

    fn mul(self, rhs: &Channel) -> Self::Output {
        &self * rhs
    }
}

impl Mul<Channel> for Channel {
    type Output = Channel;

    fn mul(self, rhs: Channel) -> Self::Output {
        &self * &rhs
    }
}

impl Add<Channel> for &Channel {
    type Output = Channel;

    fn add(self, rhs: Channel) -> Self::Output {
        self + &rhs
    }
}

impl Add<&Channel> for Channel {
    type Output = Channel;

    fn add(self, rhs: &Channel) -> Self::Output {
        &self + rhs
    }
}

impl Add<Channel> for Channel {
    type Output = Channel;

    fn add(self, rhs: Channel) -> Self::Output {
        &self + &rhs
    }
}

pub fn depolarizing_channel(p: f64) -> Channel {
    let ideal = NoiseModel::ideal();
    (1.0 - p) * ideal.i + p / 3.0 * ideal.x + p / 3.0 * ideal.y + p / 3.0 * ideal.z
}

pub fn amplitude_damping_channel(gamma: f64) -> Channel {
    Channel {
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
