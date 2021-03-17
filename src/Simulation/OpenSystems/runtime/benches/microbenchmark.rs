//! The benchmarks in this module exercise the internals of the simulator at
//! a low level, and thus are not indicative of user-facing performance.
//! Rather, these microbenchmarks are intended to help diagnose what the root
//! cause may be when user-facing performance is degraded.
//! In particular, optimizing these benchmarks may not translate into improved
//! performance in user code.

use criterion::{criterion_group, criterion_main, BenchmarkId, Criterion};
use opensim::{common_matrices, linalg::extend_one_to_n, linalg::Tensor, nq_eye};

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
    group.finish();
}

criterion_group!(benches, linalg);
criterion_main!(benches);
