#include <map>
#include <set>
#include <sstream>
#include <string>

#include "catch.hpp"

#include "QubitInterferences.hpp"

using namespace std;

static string InterferencesToString(const unordered_map<long, unordered_set<long>>& unordered)
{
    // to make tests more readable and predictable, output in sorted order
    map<long, set<long>> ordered;
    for (const auto& item : unordered)
    {
        set<long> orderedValues;
        orderedValues.insert(item.second.begin(), item.second.end());
        ordered[item.first] = std::move(orderedValues);
    }

    ostringstream os;
    os << "[";
    for (const auto& item : ordered)
    {
        os << "{" << item.first << ":";
        size_t count = 0;
        for (long value : item.second)
        {
            count++;
            os << value << (count == item.second.size() ? "" : ",");
        }
        os << "},";
    }
    os << "]";

    return os.str();
}

TEST_CASE("Qubit interference: no dependencies", "[qubit_interference]")
{
    algo::CQubitInterferences interferences;
    for (long i = 0; i < 10; i++)
    {
        interferences.AddOperation(i, {}, {i});
    }

    REQUIRE(interferences.UseOperations().size() == 10);
    REQUIRE(interferences.UseInterferences().empty());
    REQUIRE(interferences.EstimateCirquitWidth() == 1);
}

TEST_CASE("Qubit interference: single op across all qubits", "[qubit_interference]")
{
    algo::CQubitInterferences interferences;
    for (long i = 0; i < 5; i++)
    {
        interferences.AddOperation(i, {}, {i});
    }
    interferences.AddOperation(5, {0,1,2,3,4}, {0,1,2,3,4});

    REQUIRE(interferences.UseOperations().size() == 6);
    INFO(InterferencesToString(interferences.UseInterferences()));
    // [{0:1,2,3,4},{1:0,2,3,4},{2:0,1,3,4},{3:0,1,2,4},{4:0,1,2,3},]
    REQUIRE(interferences.EstimateCirquitWidth() == 5);
}

TEST_CASE("Qubit interference: cascading dependency", "[qubit_interference]")
{
    algo::CQubitInterferences interferences;
    interferences.AddOperation(0, {}, {0, 1});
    for (long i = 1; i < 10; i++)
    {
        interferences.AddOperation(i, {i - 1}, {i, i + 1});
    }

    REQUIRE(interferences.UseOperations().size() == 10);
    INFO(InterferencesToString(interferences.UseInterferences()));
    // [{0:1,2},{1:0,2,3},{2:0,1,3,4},{3:1,2,4,5},{4:2,3,5,6},{5:3,4,6,7},{6:4,5,7,8},{7:5,6,8,9},{8:6,7,9,10},
    //  {9:7,8,10},{10:8,9},]
    REQUIRE(interferences.EstimateCirquitWidth() == 3);
}