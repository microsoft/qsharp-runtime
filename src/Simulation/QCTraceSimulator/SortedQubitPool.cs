using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Text;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{

    /// <summary>
    /// Either length of a time interval or a point in time on the timeline of the program.
    /// </summary>
    internal struct ComplexTime
    {
        /// <summary>
        /// Tracer configuration interface uses type "double" to provide duration of gates (aka depth).
        /// When a gate is performed, time advances by the depth of the gate. DepthTime is used to count
        /// time cosistent with the depth configuration settings. As a result, if a gate time is set to zero,
        /// DepthTime won't increase after such gate is performed.
        /// </summary>
        internal double DepthTime { get; private set; }

        /// <summary>
        /// TrailingZeroDepthGateCount counts number of zero-depth gates after last non-zero depth gate is performed.
        /// Generally, gates that happen later on a qubit cannot be scheduled before gates on the same qubit.
        /// This is tracked transitively via qubit availability time, but zero-depth gates do not allow such calculation.
        /// The situation is resolved by having this time component - TrailingZeroDepthGateCount.
        /// </summary>
        private long TrailingZeroDepthGateCount;

        internal ComplexTime(double time)
        {
            DepthTime = time;
            TrailingZeroDepthGateCount = 0;
        }

        private ComplexTime(double depthTime, long trailingZeroDepthGateCount)
        {
            DepthTime = depthTime;
            TrailingZeroDepthGateCount = trailingZeroDepthGateCount;
        }

        public override string ToString()
        {
            return $"{DepthTime}d+{TrailingZeroDepthGateCount}";
        }
        /// <summary>
        /// Add gate time to availability time. If gate time is zero, advance dependency time.
        /// </summary>
        /// <param name="gateTime">Gate time to advance by. Assumed to be set from literals so comparison with 0 should be precise.</param>
        /// <returns>ComplexTime advanced by provided gate time</returns>
        internal ComplexTime AdvanceBy(double gateTime)
        {
            if (gateTime == 0.0)
            {
                return new ComplexTime(DepthTime, TrailingZeroDepthGateCount + 1);
            }
            return new ComplexTime(DepthTime + gateTime);
        }

        /// <summary>
        /// Subtracts argument ComplexTime from "this" ComplexTime. Returns the result.
        /// Depth times are assumed to be precise for comparison.
        /// </summary>
        /// <param name="time">Time to subtract from this object.</param>
        /// <returns>Result of subtraction.</returns>
        internal ComplexTime Subtract(ComplexTime time)
        {
            if (DepthTime == time.DepthTime)
            {
                return new ComplexTime(0, TrailingZeroDepthGateCount - time.TrailingZeroDepthGateCount);
            }
            double result = DepthTime - time.DepthTime;
            if (result <= 0)
            {
                // This could happen due to insufficient floating point calculation precision.
                throw new ArgumentException("Result of ComplexTime subtraction is not positive.");
            }
            return new ComplexTime(result, 0);
        }

        /// <summary>
        /// Compares two complex times. First DepthTime is compared, then TrailingZeroDepthGateCount is compared.
        /// </summary>
        /// <returns>0 when a = b, -1 when a&lt; b, and 1 when a &gt; b</returns>
        internal static int Compare(ComplexTime a, ComplexTime b)
        {
            int result = a.DepthTime.CompareTo(b.DepthTime);
            if (result != 0)
            {
                return result;
            }
            return a.TrailingZeroDepthGateCount.CompareTo(b.TrailingZeroDepthGateCount);
        }

        /// <summary>
        /// Returns true if this ComplexTime is the same as the argument.
        /// </summary>
        internal bool IsEqualTo(ComplexTime t)
        {
            return Compare(this, t) == 0;
        }

        /// <summary>
        /// Finds smallest of the two ComplexTime arguments.
        /// </summary>
        /// <returns>Smallest of the two arguments according to comparison.</returns>
        internal static ComplexTime Min(ComplexTime a, ComplexTime b)
        {
            return Compare(a, b) < 0 ? a : b;
        }

        /// <summary>
        /// Finds largest of the two ComplexTime arguments.
        /// </summary>
        /// <returns>Largest of the two arguments according to comparison.</returns>
        internal static ComplexTime Max(ComplexTime a, ComplexTime b)
        {
            return Compare(a, b) > 0 ? a : b;
        }

        /// <summary>
        /// Minimal value of ComplexTime.
        /// </summary>
        internal static ComplexTime MinValue { get; } = new ComplexTime(double.MinValue, long.MinValue);

        /// <summary>
        /// Maximum value of ComplexTime.
        /// </summary>
        internal static ComplexTime MaxValue { get; } = new ComplexTime(double.MaxValue, long.MaxValue);

        /// <summary>
        /// Zero ComplexTime.
        /// </summary>
        internal static ComplexTime Zero { get; } = new ComplexTime(0.0, 0);
    }

    /// <summary>
    /// Stores qubits sorted by corresponding ComplexTime values. For example, a ComplexTime value that correponds to a qubit
    /// could be the qubit availability time: the end time of the last gate on the qubit.
    /// Supports queries to retrieve qubit with maximum time less than given and minimum time greater than given Sample.
    /// Also supports addition (Add) and removal (Remove) of qubits identified by time. Time is <c>ComplexTime</c>.
    /// Multiple entries per time is supported. Implemented via SortedSet.
    /// </summary>
    internal class SortedQubitPool
    {

        /// <summary>
        /// Auxilliary class to be placed into SortedSet, which is sorted by time.
        /// We use class rather than record because we want to be able to compare by reference.
        /// </summary>
        private class QubitTimeNode
        {
            /// <summary>
            /// Id of a qubit which this record represents
            /// </summary>
            internal readonly long QubitId;
            
            /// <summary>
            /// Time on which these nodes are sorted.
            /// </summary>
            internal ComplexTime Time; // This can be readonly if Sample handling is changed.

            /// <summary>
            /// Multiple nodes can correspond to the same time. They are added to the linked list via this field.
            /// If qubits with the same time are common, array may be more efficient than the linked list.
            /// </summary>
            internal QubitTimeNode NextNode;

            /// <summary>
            /// This is only used for Sample.
            /// </summary>
            internal QubitTimeNode() {}

            internal QubitTimeNode(long qubitId, ComplexTime time)
            {
                QubitId = qubitId;
                Time = time;
                NextNode = null;
            }

            public override string ToString()
            {
                return $"{QubitId} @ {Time}";
            }
        }

        /// <summary>
        /// Compares two QubitTimeNode objects for SortedSet.
        /// It also collects minimum and maximum Time value of nodes been compared to the
        /// sample Time since ResetForComparison is called.
        /// </summary>
        private class VisitingComparer : IComparer<QubitTimeNode>
        {
            /// <summary>
            /// Maximum of all values, that are less than or equal than sample, among values seen after reset.
            /// </summary>
            internal ComplexTime MaxLowerBound = ComplexTime.MinValue;

            /// <summary>
            /// Minimum of all values, that are greater or equal than sample, among values seen after reset.
            /// </summary>
            internal ComplexTime MinUpperBound = ComplexTime.MaxValue;

            /// <summary>
            /// Sample, that will be passed to a series of comparisons.
            /// Sample is not an object that's stored in the set so it is excluded from the values seen.
            /// </summary>
            private QubitTimeNode Sample;

            /// <summary>
            /// Resets minimum and maximum value of nodes seen from the set.
            /// Also sets sample object, which should not be counted because it is not an object from the set.
            /// </summary>
            /// <param name="sample">Sample object that is not considered for minimum and maximum.</param>
            internal void ResetForComparison(QubitTimeNode sample)
            {
                MaxLowerBound = ComplexTime.MinValue;
                MinUpperBound = ComplexTime.MaxValue;
                Sample = sample;
            }

            /// <summary>
            /// Compares Time field of two nodes. Also updates MaxLowerBound and MinUpperBound.
            /// </summary>
            /// <returns>Result of comparison of Time field of QubitTimeNode</returns>
            public int Compare(QubitTimeNode a, QubitTimeNode b)
            {
                // Note that comparison of a and b nodes to Sample is "by reference" in this function.
                int result = ComplexTime.Compare(a.Time, b.Time);
                if (result > 0)
                {
                    if (a == Sample && b != Sample)
                    {
                        MaxLowerBound = ComplexTime.Max(MaxLowerBound, b.Time);
                    }
                    else if (a != Sample && b == Sample)
                    {
                        MinUpperBound = ComplexTime.Min(MinUpperBound, a.Time);
                    }
                }
                else if (result < 0)
                {
                    if (a == Sample && b != Sample)
                    {
                        MinUpperBound = ComplexTime.Min(MinUpperBound, b.Time);
                    }
                    else if (a != Sample && b == Sample)
                    {
                        MaxLowerBound = ComplexTime.Max(MaxLowerBound, a.Time);
                    }
                }
                else
                {
                    // We found the value if one argument is the sample and the other is not.
                    if ((a == Sample) != (b == Sample))
                    {
                        MaxLowerBound = b.Time;
                        MinUpperBound = b.Time;
                    }
                }
                return result;
            }
        }

        /// <summary>
        /// QubitTimeNodes sorted by Time field. SortedSet won't accept values with the same Time field.
        /// When QubitPool needs to store multiple qubits with the same Time, additional QubitTimeNode instances
        /// are linked to the head node from this set.
        /// </summary>
        private readonly SortedSet<QubitTimeNode> QubitsSortedByTime;

        /// <summary>
        /// Comparer of two nodes, which compares them by Time field and collects additional data.
        /// </summary>
        private readonly VisitingComparer NodeComparer;

        /// <summary>
        /// Sample which is being compared to the nodes stored in the set.
        /// Multiple comparisons are done by SortedSet to find if this Sample is present in the set.
        /// </summary>
        private readonly QubitTimeNode Sample = new QubitTimeNode(); // We reuse same object to avoid allocations.

        public SortedQubitPool()
        {
            NodeComparer = new VisitingComparer();
            QubitsSortedByTime = new SortedSet<QubitTimeNode>(NodeComparer);
        }

        /// <summary>
        /// Add Qubit to the set with specified time. Multiple qubits with the same time can be added.
        /// Complexity is log(N), where N - number of nodes.
        /// </summary>
        /// <param name="qubitId">Id of a qubit to add to the set.</param>
        /// <param name="time">Time of the qubit.</param>
        public void Add(long qubitId, ComplexTime time)
        {
            QubitTimeNode newNode = new QubitTimeNode(qubitId, time);
            if (QubitsSortedByTime.Add(newNode))
            {
                // New item was added to the set, we are done.
                return;
            }
            if (!QubitsSortedByTime.TryGetValue(newNode, out QubitTimeNode existingNode))
            {
                // We cannot add, but we cannot find a node with the same value. Is this a floating point glitch?
                Debug.Assert(false, "Cannot add a value to SortedSet<QubitTimeNode> that isn't in the set.");
                return;
            }
            // Add new node to the linked list as a second element.
            newNode.NextNode = existingNode.NextNode;
            existingNode.NextNode = newNode;
        }

        /// <summary>
        /// Find qubit with the specified time in the set. If such qubit is not present,
        /// find either maximum value less than it or minimum value greater than it.
        /// This function uses one call to SortedSet.TryGetValue() so it takes log(N) time, where N - number of nodes.
        /// </summary>
        /// <param name="requestedTime">Sample time to find</param>
        /// <param name="getLowerBound">"true" to find maximum value &lt;= requestedTime, "false" to find minimum value &gt;= requestedTime</param>
        /// <param name="actualTime">Time found in the set</param>
        /// <returns>"true" if the requested bound was found in the set, "false" otherwise</returns>
        public bool FindBound(ComplexTime requestedTime, bool getLowerBound, out ComplexTime actualTime)
        {
            // We use the following approach:
            // We call function TryGetValue on a sorted set. If value is found, we return it.
            // Otherwise TryGetValue must make conclusion that the value is absent.
            // Any comparison-based algorithm without caching must inspect both
            // maximum value less than the sample and minimum value greater than the sample.
            // So they must be among the values seen since reset.
            // So we just need to harvest them from VisitingComparer.
            Sample.Time = requestedTime;
            NodeComparer.ResetForComparison(Sample);
            if (QubitsSortedByTime.TryGetValue(Sample, out QubitTimeNode foundValue))
            {
                actualTime = foundValue.Time;
                return true;
            }
            if (getLowerBound)
            {
                actualTime = NodeComparer.MaxLowerBound;
                return !actualTime.IsEqualTo(ComplexTime.MinValue);
            }
            else
            {
                actualTime = NodeComparer.MinUpperBound;
                return !actualTime.IsEqualTo(ComplexTime.MaxValue);
            }
        }

        /// <summary>
        /// Remove one qubit with given time from the set. Complexity is log(N), where N - number of nodes.
        /// </summary>
        /// <param name="time">Remove qubit with this time.</param>
        /// <returns>QubitId if qubit is found. Throws exception if it is not found.</returns>
        public long Remove(ComplexTime time)
        {
            Sample.Time = time;
            if (!QubitsSortedByTime.TryGetValue(Sample, out QubitTimeNode foundValue))
            {
                throw new ApplicationException("Cannot get qubit that should be present in a qubit pool.");
            }
            if (foundValue.NextNode == null)
            {
                // Remove only node from the tree.
                long qubitId = foundValue.QubitId;
                QubitsSortedByTime.Remove(Sample);
                return qubitId;
            }
            // Get second node in the list.
            QubitTimeNode nodeToRemove = foundValue.NextNode;
            // Remove second node from the list.
            foundValue.NextNode = nodeToRemove.NextNode;
            return nodeToRemove.QubitId;
        }
    }

}
