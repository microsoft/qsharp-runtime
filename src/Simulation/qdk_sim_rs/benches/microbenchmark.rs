// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

//! The benchmarks in this module exercise the internals of the simulator at
//! a low level, and thus are not indicative of user-facing performance.
//! Rather, these microbenchmarks are intended to help diagnose what the root
//! cause may be when user-facing performance is degraded.
//! In particular, optimizing these benchmarks may not translate into improved
//! performance in user code.

use cauchy::c64;
use criterion::{criterion_group, criterion_main, Criterion};
use ndarray::array;
use qdk_sim::{
    common_matrices,
    common_matrices::nq_eye,
    linalg::{extend_one_to_n, extend_two_to_n, Inv, Tensor},
};

fn linalg(c: &mut Criterion) {
    let mut group = c.benchmark_group("linalg");
    for n_qubits in [1usize, 2, 3, 4].iter() {
        group.bench_with_input(format!("nq_eye({})", n_qubits), n_qubits, |b, nq| {
            b.iter(|| {
                let _eye = nq_eye(*nq);
            })
        });
    }
    for idx_qubit in [0usize, 1, 2].iter() {
        group.bench_with_input(
            format!(
                "extend_one_to_n(n_left: {}, n_right: {})",
                idx_qubit,
                2 - idx_qubit
            ),
            idx_qubit,
            |b, i| {
                // Create some test data.
                let data = nq_eye(1);
                b.iter(|| {
                    let _extended = extend_one_to_n(data.view(), *i, 3);
                })
            },
        );
    }
    for idx_qubit in [0usize, 1, 2].iter() {
        group.bench_with_input(
            format!(
                "extend_two_to_n(n_left: {}, n_right: {})",
                idx_qubit,
                2 - idx_qubit
            ),
            idx_qubit,
            |b, i| {
                // Create some test data.
                let data = common_matrices::cnot();
                b.iter(|| {
                    let _extended = extend_two_to_n(data.view(), *i, 3, 4).unwrap();
                })
            },
        );
    }
    group.bench_function("tensor 2x2 with 2x2", |b| {
        let x = common_matrices::x();
        let y = common_matrices::y();
        b.iter(|| {
            let _result = x.tensor(&y);
        })
    });
    group.bench_function("tensor 2x2 with 4x4", |b| {
        let x = common_matrices::x();
        let cnot = common_matrices::cnot();
        b.iter(|| {
            let _result = x.tensor(&cnot);
        })
    });
    group.bench_function("tensor 4x4 with 2x2", |b| {
        let x = common_matrices::x();
        let cnot = common_matrices::cnot();
        b.iter(|| {
            let _result = cnot.tensor(&x);
        })
    });
    group.bench_function("inv 4x4 f64", |b| {
        let x = array![
            [
                0.23935896217435304,
                0.34333031120985236,
                0.8201953415286973,
                0.8074588350909441
            ],
            [
                0.11957583380425751,
                0.16906445210054732,
                0.21728173861409317,
                0.7120594445167554
            ],
            [
                0.04023516190513021,
                0.9635112441739464,
                0.9209190516642924,
                0.114251355434274
            ],
            [
                0.8749507948480983,
                0.2661348079904513,
                0.17485566324545554,
                0.2934138616881069
            ],
        ];
        b.iter(|| {
            let _inv = x.inv();
        });
    });
    group.bench_function("inv 4x4 c64", |b| {
        let x = array![
            [
                c64::new(0.30874277550419704, 0.8167808814398533),
                c64::new(0.9303782008146939, 0.8925538040143673),
                c64::new(0.11573522743286513, 0.6357551264716991),
                c64::new(0.7869240102858357, 0.28376515716360073)
            ],
            [
                c64::new(0.9638410081049803, 0.4460520369459663),
                c64::new(0.043516097874141346, 0.1652124014187376),
                c64::new(0.05938096491956191, 0.7696366269843138),
                c64::new(0.9636976605227736, 0.8125701401805293)
            ],
            [
                c64::new(0.9548859426476123, 0.7825350828251003),
                c64::new(0.4223649577868721, 0.4522018603906839),
                c64::new(0.36001119456757835, 0.22138920205104395),
                c64::new(0.0044511389785256705, 0.14148562531641973)
            ],
            [
                c64::new(0.6066852151129799, 0.5140547256960247),
                c64::new(0.23439110687939924, 0.3064074735518828),
                c64::new(0.9963759728056912, 0.401859040365666),
                c64::new(0.7176238235495955, 0.3948597214947167)
            ],
        ];
        b.iter(|| {
            let _inv = x.inv();
        });
    });
    group.finish();
}

criterion_group!(benches, linalg);
criterion_main!(benches);
