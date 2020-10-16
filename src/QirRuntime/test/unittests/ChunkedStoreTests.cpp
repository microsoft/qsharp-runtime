#include <algorithm>
#include <vector>

#include "catch.hpp"

#include "ChunkedStore.hpp"

using namespace std;
using namespace Microsoft::Quantum;

struct Complex
{
    double re = 0.0;
    double im = 0.0;
};
struct TestQubit
{
    int id = 0;
    Complex state = {0.0, 0.0}; // to test that the store handles bigger qubits
};

typedef CChunkedStore<TestQubit> QSTORE;

TEST_CASE("Indexes mapping", "[qubit_store]")
{
    long id0 = 0;
    REQUIRE(QSTORE::GetChunkIndex(id0) == 0);
    REQUIRE(QSTORE::GetIndexInChunk(id0) == 0);

    long idFirstInChunk = QSTORE::items_in_chunk * 2;
    REQUIRE(QSTORE::GetChunkIndex(idFirstInChunk) == 2);
    REQUIRE(QSTORE::GetIndexInChunk(idFirstInChunk) == 0);

    long id = QSTORE::items_in_chunk * 2 + 17;
    REQUIRE(QSTORE::GetChunkIndex(id) == 2);
    REQUIRE(QSTORE::GetIndexInChunk(id) == 17);
}

TEST_CASE("Allocate and release a single qubit", "[qubit_store]")
{
    QSTORE store;

    TestQubit* q = store.Allocate(0);
    REQUIRE(q->id == 0);
    vector<TestQubit*> allocated = store.GetAllItems();
    REQUIRE(allocated.size() == 1);
    REQUIRE(allocated[0] == q);

    store.Release(q);
    REQUIRE(store.GetAllItems().empty());
}

TEST_CASE("Allocate and release a single qubit with small non-zero id", "[qubit_store]")
{
    QSTORE store;

    TestQubit* q = store.Allocate(17);
    REQUIRE(q->id == 17);
    vector<TestQubit*> allocated = store.GetAllItems();
    REQUIRE(allocated.size() == 1);
    REQUIRE(allocated[0] == q);

    store.Release(q);
    REQUIRE(store.GetAllItems().empty());
}

TEST_CASE("Allocation skips a few chunks", "[qubit_store]")
{
    QSTORE store;

    const long id = QSTORE::items_in_chunk * 2 + 1;
    TestQubit* q = store.Allocate(id);
    REQUIRE(q->id == id);
    vector<TestQubit*> allocated = store.GetAllItems();
    REQUIRE(allocated.size() == 1);
    REQUIRE(allocated[0] == q);

    store.Release(q);
    REQUIRE(store.GetAllItems().empty());
}

TEST_CASE("Allocate in multiple chunks out of order", "[qubit_store]")
{
    QSTORE store;

    const long id1 = QSTORE::items_in_chunk * 2 + 1;
    const long id2 = id1 + 1;
    const long id3 = QSTORE::items_in_chunk + 1;
    const long id4 = 17;

    TestQubit* q1 = store.Allocate(id1);
    TestQubit* q2 = store.Allocate(id2);
    TestQubit* q3 = store.Allocate(id3);
    TestQubit* q4 = store.Allocate(id4);

    vector<TestQubit*> allocated = store.GetAllItems();
    REQUIRE(allocated.size() == 4);
    std::sort(allocated.begin(), allocated.end(), [](TestQubit* q1, TestQubit* q2) { return q1->id < q2->id; });

    // id2 > id1 > id3 > id4
    REQUIRE(allocated[0] == q4);
    REQUIRE(allocated[1] == q3);
    REQUIRE(allocated[2] == q1);
    REQUIRE(allocated[3] == q2);
}