// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

use qdk_sim::{Pauli, Process, State, Tableau};

#[test]
fn pauli_channel_applies_correctly() -> Result<(), String> {
    let x = Process::new_pauli_channel(Pauli::X);
    let state = State::new_stabilizer(1);
    let output_state = x.apply(&state)?;

    let tableau = output_state.get_tableau().unwrap();
    tableau.assert_meas(0, true)
}
