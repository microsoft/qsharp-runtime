#pragma once

#include <set>
#include <vector>

using namespace std;

namespace Microsoft
{
namespace Algorithms
{
    // This is the classical "interval-graph coloring problem" or 16.1-3 from Introduction to Algorithms by Cormen's et
    // al (also known as "meetings room scheduling problem"):
    //   Given a set of intervals (in our case both ends are included), find the least number of colors to color them
    //   such that no intervals of the same color overlap.
    //
    // It's obvious that the lower bound on the number of colors is the size of the max cut across all intervals. Let's
    // denote it N. To color the intervals into N colors:
    // 1. sort the intervals by the start-point
    // 2. in this order, add the next interval into group with smallest end point
    // Step 2 is always possible, because otherwise the start point of the interval being added would intercect with
    // the last interval in all N groups (as they all start earlier), thus yielding a N+1 cut.
    template <typename TInterval> struct CompareByEnd
    {
        bool operator()(TInterval* lhs, TInterval* rhs) const
        {
            return lhs->End() < rhs->End();
        }
    };

    template <typename TInterval> long CalculateMinColoringSize(const vector<TInterval>& intervals)
    {
        vector<TInterval> intervalsSortedByStart = intervals;
        std::sort(
            begin(intervalsSortedByStart), end(intervalsSortedByStart),
            [](const TInterval& lhs, const TInterval& rhs) { return lhs.Start() < rhs.Start(); });

        long minColors = 0;

        long point = 0;
        std::multiset<TInterval*, CompareByEnd<TInterval>> cutAtPoint;
        size_t firstIntervalWithStartAtPoint = 0;
        while (firstIntervalWithStartAtPoint < intervalsSortedByStart.size())
        {
            // Set new point for the cut and remove from the cut the intervals that don't reach it.
            point = intervalsSortedByStart[firstIntervalWithStartAtPoint].Start();
            auto eraseUpto = cutAtPoint.end();
            for (auto it = cutAtPoint.begin(); it != cutAtPoint.end(); it++)
            {
                if ((*it)->End() >= point)
                {
                    eraseUpto = it;
                    break;
                }
            }
            cutAtPoint.erase(cutAtPoint.begin(), eraseUpto);

            // Add to the cut intervals that touch the point. Look at each interval exactly once.
            for (size_t i = firstIntervalWithStartAtPoint; i < intervalsSortedByStart.size(); i++)
            {
                assert(intervalsSortedByStart[i].Start() >= point);
                if (intervalsSortedByStart[i].Start() == point)
                {
                    cutAtPoint.insert(&intervalsSortedByStart[i]);
                    firstIntervalWithStartAtPoint++;
                }
                else
                {
                    firstIntervalWithStartAtPoint = i;
                    break;
                }
            }
            minColors = std::max<long>(minColors, cutAtPoint.size());
        }
        return minColors;
    }
} // namespace Algorithms
} // namespace Microsoft