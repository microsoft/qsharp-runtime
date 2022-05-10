// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use crate::c64;
use crate::processes::generators::*;

// # Notes
// To obtain the decompositions below using QuTiP and Python together:
//
// ```python
// >>> import numpy as np
// >>> import qutip as qt
// >>> eye = qt.qeye(2)
// >>> def to_liouvillian(h):
// ...     return qt.tensor(eye, h) - qt.tensor(h, eye)
// >>> def to_generator(h):
// ...     l = to_liouvillian(h)
// ...     g = -1j * l
// ...     vals, vecs = g.eigenstates()
// ...     idxs_nonzero = ~np.isclose(vals, 0)
// ...     vals = vals[idxs_nonzero]
// ...     vecs = vecs[idxs_nonzero]
// ...     return vals, vecs
// >>> # Example for 𝐻 = −½𝑋:
// >>> hx = -0.5 * qt.sigmax()
// >>> to_generator(hx)
// (array([0.00000000e+00-1.j, 2.77555756e-17+1.j]),
//  array([Quantum object: dims = [[2, 2], [1, 1]], shape = (4, 1), type = ket
//  Qobj data =
//  [[ 0.5]
//   [-0.5]
//   [ 0.5]
//   [-0.5]]                                                           ,
//  Quantum object: dims = [[2, 2], [1, 1]], shape = (4, 1), type = ket
//  Qobj data =
//  [[ 0.5]
//   [ 0.5]
//   [-0.5]
//   [-0.5]]                                                           ],
// dtype=object))
// ```

impl Generator {
    /// Returns a generator representing the Hamiltonian $H = -\frac12 X$ as the
    /// Liouvillian
    /// $-\mathrm{i}L = -\mathrm{i}\left(𝟙 \otimes H - H \otimes 𝟙\right)$.
    pub fn hx() -> Generator {
        Generator {
            n_qubits: 1,
            data: crate::GeneratorData::ExplicitEigenvalueDecomposition {
                values: array![c64!(-1.0 i), c64!(1.0 i)],
                vectors: array![
                    [c64!(0.5), c64!(-0.5), c64!(0.5), c64!(-0.5)],
                    [c64!(0.5), c64!(0.5), c64!(-0.5), c64!(-0.5)],
                ],
            },
        }
    }

    /// Returns a generator representing the Hamiltonian $H = -\frac12 Y$ as the
    /// Liouvillian
    /// $-\mathrm{i}L = -\mathrm{i}\left(𝟙 \otimes H - H \otimes 𝟙\right)$.
    pub fn hy() -> Generator {
        Generator {
            n_qubits: 1,
            data: crate::GeneratorData::ExplicitEigenvalueDecomposition {
                values: array![c64!(-1.0 i), c64!(1.0 i)],
                vectors: array![
                    [c64!(-0.5 i), c64!(-0.5), c64!(0.5), c64!(-0.5 i)],
                    [c64!(0.5), c64!(0.5 i), c64!(-0.5 i), c64!(0.5)],
                ],
            },
        }
    }

    /// Returns a generator representing the Hamiltonian $H = -\frac12 Z$ as the
    /// Liouvillian
    /// $-\mathrm{i}L = -\mathrm{i}\left(𝟙 \otimes H - H \otimes 𝟙\right)$.
    pub fn hz() -> Generator {
        Generator {
            n_qubits: 1,
            data: crate::GeneratorData::ExplicitEigenvalueDecomposition {
                values: array![c64!(-1.0 i), c64!(1.0 i)],
                vectors: array![
                    [c64!(0.0), c64!(1.0), c64!(0.0), c64!(0.0)],
                    [c64!(0.0), c64!(0.0), c64!(1.0), c64!(0.0)],
                ],
            },
        }
    }
}
