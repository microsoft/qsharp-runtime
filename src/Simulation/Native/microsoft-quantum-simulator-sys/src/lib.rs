// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use std::os::raw::c_double;

extern "C" {
    pub fn init() -> u32;
    pub fn seed(id: u32, seed: u32);

    pub fn allocate(id: u32) -> u32;
    pub fn release(id: u32, q: u32) -> bool;

    pub fn X(id: u32, q: u32);
    pub fn Y(id: u32, q: u32);
    pub fn Z(id: u32, q: u32);
    pub fn H(id: u32, q: u32);
    pub fn S(id: u32, q: u32);
    pub fn T(id: u32, q: u32);
    pub fn AdjS(id: u32, q: u32);
    pub fn AdjT(id: u32, q: u32);
    pub fn R(id: u32, basis: u32, angle: c_double, q: u32);
    pub fn Exp(id: u32, len: u32, bases: *const u32, angle: c_double, qs: *const u32);

    pub fn MCX(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCY(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCZ(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCH(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCS(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCT(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCAdjS(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCAdjT(id: u32, len: u32, ctrls: *const u32, q: u32);
    pub fn MCR(id: u32, basis: u32, angle: c_double, len: u32, ctrls: *const u32, q: u32);
    pub fn MCExp(
        id: u32,
        len: u32,
        bases: *const u32,
        angle: c_double,
        len_ctrls: u32,
        ctrls: *const u32,
        qs: *const u32,
    );

    pub fn M(id: u32, q: u32) -> u32;
    pub fn Measure(id: u32, len: u32, bases: *const u32, qs: *const u32) -> u32;
}
