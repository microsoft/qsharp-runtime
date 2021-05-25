// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#include <iostream>

#include "catch.hpp"

#include "QubitManagerRestrictedReuse.hpp"

using namespace Microsoft::Quantum;

TEST_CASE("Simple allocation and release of one qubit", "[QubitManagerBasic]")
{
    std::unique_ptr<CQubitManager> qm = std::make_unique<CQubitManager>(1);
    Qubit q = qm->Allocate();
    qm->Release(q);
}

TEST_CASE("Allocation and reallocation of one qubit", "[QubitManagerBasic]")
{
    std::unique_ptr<CQubitManager> qm = std::make_unique<CQubitManager>(1);
    REQUIRE(qm->GetFreeQubitCount() == 1);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);
    Qubit q = qm->Allocate();
    REQUIRE(qm->QubitToId(q) == 0);
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 1);
    REQUIRE_THROWS(qm->Allocate());
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 1);
    qm->Release(q);
    REQUIRE(qm->GetFreeQubitCount() == 1);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);
    Qubit q0 = qm->Allocate();
    REQUIRE(qm->QubitToId(q0) == 0);
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 1);
    qm->Release(q0);
    REQUIRE(qm->GetFreeQubitCount() == 1);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);
}


TEST_CASE("Allocation of released qubits when reuse is encouraged", "[QubitManagerBasic]")
{
    std::unique_ptr<CQubitManager> qm = std::make_unique<CQubitManager>(2);
    REQUIRE(qm->GetFreeQubitCount() == 2);
    Qubit q0 = qm->Allocate();
    Qubit q1 = qm->Allocate();
    REQUIRE(qm->QubitToId(q0) == 0); // Qubit ids should be in order
    REQUIRE(qm->QubitToId(q1) == 1);
    REQUIRE_THROWS(qm->Allocate());
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 2);

    qm->Release(q0);
    Qubit q0a = qm->Allocate();
    REQUIRE(qm->QubitToId(q0a) == 0); // It was the only one available
    REQUIRE_THROWS(qm->Allocate());

    qm->Release(q1);
    qm->Release(q0a);
    REQUIRE(qm->GetFreeQubitCount() == 2);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);

    Qubit q0b = qm->Allocate();
    Qubit q1a = qm->Allocate();
    REQUIRE(qm->QubitToId(q0b) == 0); // By default reuse is encouraged, LIFO is used
    REQUIRE(qm->QubitToId(q1a) == 1);
    REQUIRE_THROWS(qm->Allocate());
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 2);

    qm->Release(q0b);
    qm->Release(q1a);
}

TEST_CASE("Extending capacity", "[QubitManager]")
{
    std::unique_ptr<CQubitManager> qm = std::make_unique<CQubitManager>(1, true);

    Qubit q0 = qm->Allocate();
    REQUIRE(qm->QubitToId(q0) == 0);
    Qubit q1 = qm->Allocate(); // This should double capacity
    REQUIRE(qm->QubitToId(q1) == 1);
    REQUIRE(qm->GetFreeQubitCount() == 0);
    REQUIRE(qm->GetAllocatedQubitCount() == 2);

    qm->Release(q0);
    Qubit q0a = qm->Allocate();
    REQUIRE(qm->QubitToId(q0a) == 0);
    Qubit q2 = qm->Allocate(); // This should double capacity again
    REQUIRE(qm->QubitToId(q2) == 2);
    REQUIRE(qm->GetFreeQubitCount() == 1);
    REQUIRE(qm->GetAllocatedQubitCount() == 3);

    qm->Release(q1);
    qm->Release(q0a);
    qm->Release(q2);
    REQUIRE(qm->GetFreeQubitCount() == 4);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);

    Qubit* qqq = new Qubit[3];
    qm->Allocate(qqq, 3);
    REQUIRE(qm->GetFreeQubitCount() == 1);
    REQUIRE(qm->GetAllocatedQubitCount() == 3);
    qm->Release(qqq, 3);
    delete[] qqq;
    REQUIRE(qm->GetFreeQubitCount() == 4);
    REQUIRE(qm->GetAllocatedQubitCount() == 0);
}

TEST_CASE("Restricted Area", "[QubitManager]")
{
    std::unique_ptr<CQubitManager> qm = std::make_unique<CQubitManager>(3, false, true);

    Qubit q0 = qm->Allocate();
    REQUIRE(qm->QubitToId(q0) == 0);

    qm->StartRestrictedReuseArea();

    // Allocates fresh qubit
    Qubit q1 = qm->Allocate();
    REQUIRE(qm->QubitToId(q1) == 1);
    qm->Release(q1); // Released, but cannot be used in the next segment.

    qm->NextRestrictedReuseSegment();

    // Allocates fresh qubit, q1 cannot be reused - it belongs to a differen segment.
    Qubit q2 = qm->Allocate();
    REQUIRE(qm->QubitToId(q2) == 2);
    qm->Release(q2);

    Qubit q2a = qm->Allocate(); // Getting the same one as the one that's just released.
    REQUIRE(qm->QubitToId(q2a) == 2);
    qm->Release(q2a); // Released, but cannot be used in the next segment.

    qm->NextRestrictedReuseSegment();

    // There's no qubits left here. q0 is allocated, q1 and q2 are from different segments.
    REQUIRE_THROWS(qm->Allocate());

    qm->EndRestrictedReuseArea();

    // Qubits 1 and 2 are available here again.
    Qubit* qqq = new Qubit[2];
    qm->Allocate(qqq, 2);
    // OK to destruct qubit manager while qubits are still allocated.
    REQUIRE_THROWS(qm->Allocate());
}