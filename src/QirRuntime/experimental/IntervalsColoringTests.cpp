#include <vector>

#include "catch.hpp"

#include "IntervalsColoring.hpp"

using namespace std;

struct Interval
{
    long start = 0;
    long end = 0;
    inline long Start() const
    {
        return start;
    }
    inline long End() const
    {
        return end;
    }
};

TEST_CASE("Meetings Schedule: empty list of intervals", "[intervals_coloring]")
{
    vector<Interval> intervals{};
    REQUIRE(0 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: single interval", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 1}};
    REQUIRE(1 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: no overlaps", "[intervals_coloring]")
{
    vector<Interval> intervals{{5, 5}, {0, 1}, {2, 4}};
    REQUIRE(1 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: dupes", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 2}, {0, 2}, {0, 2}};
    REQUIRE(3 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: all overlap", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 4}, {2, 4}, {1, 6}, {4, 4}, {4, 5}};
    REQUIRE(5 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: staircase", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 2}, {1, 3}, {2, 4}, {3, 5}, {4, 6}, {5, 7}};
    REQUIRE(3 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: staircase with a rail", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 2}, {1, 3}, {2, 4}, {3, 5}, {4, 6}, {5, 7}, {0, 3}, {4, 7}};
    REQUIRE(4 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}

TEST_CASE("Meetings Schedule: packed staircases", "[intervals_coloring]")
{
    vector<Interval> intervals{{0, 2}, {1, 3}, {2, 4}, {3, 5}, {4, 6}, {3, 4}, {4, 5},
                               {5, 6}, {5, 5}, {6, 6}, {0, 0}, {1, 1}, {2, 2}};
    REQUIRE(5 == Microsoft::Algorithms::CalculateMinColoringSize(intervals));
}