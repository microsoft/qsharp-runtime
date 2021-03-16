// This set of benchmarks exercises the open systems simulator exclusively via
// its C API, so as to gauge any potential issues for C-based consumers of the
// simulator.

use std::ffi::CString;
use criterion::{criterion_group, criterion_main, Criterion};
use opensim::{ c_api };

// Use include_str! to store test case JSON as a string into the compiled
// test executable.
static BENCHMARK_NOISE_MODEL_JSON: &str = include_str!("data/benchmark-noise-model.json");

fn with_test_suite<T: criterion::measurement::Measurement>(sim_id: usize, group: &mut criterion::BenchmarkGroup<T>) {
    group.bench_function("apply x", |b| b.iter(|| {
        c_api::x(sim_id, 0);
    }));
    group.bench_function("apply z", |b| b.iter(|| {
        c_api::z(sim_id, 0);
    }));
    group.bench_function("apply cnot", |b| b.iter(|| {
        c_api::cnot(sim_id, 0, 1);
    }));
    group.bench_function("measure", |b| b.iter(|| {
        let mut result: usize = 0;
        c_api::m(sim_id, 0, &mut result);
    }));
}

fn ideal(c: &mut Criterion) {
    let sim_id = c_api::init(3);
    let mut group = c.benchmark_group("ideal");
    with_test_suite(sim_id, &mut group);
    group.finish();
    c_api::destroy(sim_id);
}

fn noisy(c: &mut Criterion) {
    let sim_id = c_api::init(3);
    c_api::set_noise_model(sim_id, CString::new(BENCHMARK_NOISE_MODEL_JSON).unwrap().as_ptr());
    let mut group = c.benchmark_group("noisy");
    with_test_suite(sim_id, &mut group);
    group.finish();
    c_api::destroy(sim_id);
}

criterion_group!(benches, ideal, noisy);
criterion_main!(benches);
