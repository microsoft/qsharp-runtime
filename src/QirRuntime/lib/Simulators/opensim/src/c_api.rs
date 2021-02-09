
#[no_mangle]
pub extern fn init(initial_capacity: usize) -> usize {
    0
}

#[no_mangle]
pub extern fn destroy(sim_id: usize) -> i64 { 0 }

#[no_mangle]
pub extern fn dump_to_console() -> () {}

#[no_mangle]
pub extern fn x(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub extern fn y(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub extern fn z(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub extern fn h(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub fn s(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub fn s_adj(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub fn t(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub fn t_adj(sim_id: usize, idx: usize) -> i64 { 0 }

#[no_mangle]
pub fn cnot(sim_id: usize, idx_control: usize, idx_target: usize) -> i64 { 0 }

#[no_mangle]
pub extern fn m(sim_id: usize, idx: usize, result_out: *mut usize) -> i64 {
    unsafe { *result_out = 0; }
    0
}
