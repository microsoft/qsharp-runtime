using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime {

    /// <summary>
    /// Time to track qubit availability (DepthTime). Time is also used to track dependencies:
    /// Gates that happen later on a qubit cannot be scheduled before gates on the same qubit.
    /// This is tracked transitively via time, but zero gate depth prevents this from happening.
    /// This is solved by having additional time component - DependencyTime.
    /// </summary>
    internal struct ComplexTime
    {
        /// <summary>
        /// Time used to track qubit availability time. Double to match configuration interface.
        /// </summary>
        internal double DepthTime { get; private set; }

        /// <summary>
        /// This is only used for comparisons when DepthTime is equal. This time tracks dependencies.
        /// </summary>
        private long DependencyTime;

        internal ComplexTime(double time) {
            DepthTime = time;
            DependencyTime = 0;
        }

        private ComplexTime(double depthTime, long dependencyTime) {
            DepthTime = depthTime;
            DependencyTime = dependencyTime;
        }

        public override string ToString() {
            return $"{DepthTime}d+{DependencyTime}";
        }
        /// <summary>
        /// Add gate time to availability time. If gate time is zero, advance dependency time.
        /// </summary>
        /// <param name="time">Gate time to advance by. Assumed to be precise for comparison with 0.</param>
        /// <returns>ComplexTime advanced by provided gate time</returns>
        internal ComplexTime AdvanceBy(double time) {
            if (time == 0.0) {
                return new ComplexTime(DepthTime, DependencyTime + 1);
            }
            return new ComplexTime(DepthTime + time);
        }

        /// <summary>
        /// Subtracts argument ComplexTime from "this" ComplexTime. Returns the result.
        /// Depth times are assumed to be precise  for comparison.
        /// </summary>
        /// <param name="time">Time to subtract from this object.</param>
        /// <returns>Result of subtraction.</returns>
        internal ComplexTime Subtract(ComplexTime time) {
            if (DepthTime < time.DepthTime) {
                throw new ArgumentException("Result of ComplexTime subtraction is negative.");
            }
            if (DepthTime == time.DepthTime) {
                return new ComplexTime(0, DependencyTime - time.DependencyTime);
            }
            return new ComplexTime(DepthTime - time.DepthTime, 0);
        }

        /// <summary>
        /// Compares two complex times. First DepthTime is compared, then DependencyTime is compared.
        /// </summary>
        /// <returns>0 when a = b, -1 when a&lt; b, and 1 when a &gt; b</returns>
        internal static int Compare(ComplexTime a, ComplexTime b) {
            int result = a.DepthTime.CompareTo(b.DepthTime);
            if (result != 0) {
                return result;
            }
            return a.DependencyTime.CompareTo(b.DependencyTime);
        }

        /// <summary>
        /// Finds smallest of the two ComplexTime arguments.
        /// </summary>
        /// <returns>Smallest of the two arguments according to comparison.</returns>
        internal static ComplexTime Min(ComplexTime a, ComplexTime b) {
            return Compare(a, b) < 0 ? a : b;
        }

        /// <summary>
        /// Finds largest of the two ComplexTime arguments.
        /// </summary>
        /// <returns>Largest of the two arguments according to comparison.</returns>
        internal static ComplexTime Max(ComplexTime a, ComplexTime b) {
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
    /// Stores qubits sorted by corresponding times. Instantiated to store interval start points and end points.
    /// Supports queries to retrieve qubit with maximum time less than given and minimum time greater than given Sample.
    /// Also supports addition (Add) and removal (Remove) of qubits identified by time. Time is <c>ComplexTime</c>.
    /// Multiple entries per time is supported. Implemented via SortedSet.
    /// </summary>
    internal class SortedQubitPool {

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
            internal QubitTimeNode() {
            }

            internal QubitTimeNode(long qubitId, ComplexTime time) {
                QubitId = qubitId;
                Time = time;
                NextNode = null;
            }

            public override string ToString() {
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
            internal void ResetForComparison(QubitTimeNode sample) {
                MaxLowerBound = ComplexTime.MinValue;
                MinUpperBound = ComplexTime.MaxValue;
                Sample = sample;
            }

            /// <summary>
            /// Compares Time field of two nodes. Also updates MaxLowerBound and MinUpperBound.
            /// </summary>
            /// <returns>Result of comparison of Time field of QubitTimeNode</returns>
            public int Compare(QubitTimeNode a, QubitTimeNode b) {
                // Note that comparison of a and b nodes to Sample is "by reference" in this function.
                int result = ComplexTime.Compare(a.Time, b.Time);
                if (result > 0) {
                    if (a == Sample && b != Sample) {
                        MaxLowerBound = ComplexTime.Max(MaxLowerBound, b.Time);
                    } else if (a != Sample && b == Sample) {
                        MinUpperBound = ComplexTime.Min(MinUpperBound, a.Time);
                    }
                } else if (result < 0) {
                    if (a == Sample && b != Sample) {
                        MinUpperBound = ComplexTime.Min(MinUpperBound, b.Time);
                    } else if (a != Sample && b == Sample) {
                        MaxLowerBound = ComplexTime.Max(MaxLowerBound, a.Time);
                    }
                } else {
                    // We found the value if one argument is the sample and nother is not.
                    if ((a == Sample) != (b == Sample)) {
                        MaxLowerBound = b.Time;
                        MinUpperBound = b.Time;
                    }
                }
                return result;
            }
        }

        /// <summary>
        /// QubitTimeNodes sorted by Time field. Nodes with the same Time field are stored in a linked list.
        /// </summary>
        private readonly SortedSet<QubitTimeNode> QubitTime;

        /// <summary>
        /// Comparer of two nodes, which compares them by Time field and collects additional data.
        /// </summary>
        private readonly VisitingComparer NodeComparer;

        /// <summary>
        /// Sample which is been compared to the nodes stored in the set.
        /// Multiple comparisons are done by SortedSet to find if this Sample is present in the set.
        /// </summary>
        private readonly QubitTimeNode Sample = new QubitTimeNode(); // We reuse same object to avoid allocations.

        public SortedQubitPool() {
            NodeComparer = new VisitingComparer();
            QubitTime = new SortedSet<QubitTimeNode>(NodeComparer);
        }

        /// <summary>
        /// Add Qubit to the set with specified time. Multiple qubits with the same time can be added.
        /// Complexity is log(N), where N - number of nodes.
        /// </summary>
        /// <param name="qubitId">Id of a qubit to add to the set.</param>
        /// <param name="time">Time of the qubit.</param>
        public void Add(long qubitId, ComplexTime time) {
            QubitTimeNode newNode = new QubitTimeNode(qubitId, time);
            if (QubitTime.Add(newNode)) {
                // New item was added to the set, we are done.
                return;
            }
            if (!QubitTime.TryGetValue(newNode, out QubitTimeNode existingNode)) {
                // We cannot add, but we cannot find a node with the same value.
                // Is it a floating point glitch? We'll just ignore this one.
                // If this happens reuse will be hindered, but program will still work.
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
        /// <param name="getLowerBound">"true" to find maximum value less than sample</param>
        /// <param name="actualTime">Time found in the set</param>
        /// <returns>"true" if sample was found in the set.</returns>
        public bool FindBound(ComplexTime requestedTime, bool getLowerBound, out ComplexTime actualTime) {
            // We use the following approach:
            // We call function TryGetValue on a sorted set. If value is found, we go with it.
            // Otherwise TryGetValue must make conclusion that the value is absent.
            // Any comparison-based algorithm without caching must inspect both
            // maximum value less than the sample and minimum value greater than the sample.
            // So they must be among the values seen since reset.
            // So we just need to harvest them from VisitingComparer.
            Sample.Time = requestedTime;
            NodeComparer.ResetForComparison(Sample);
            if (QubitTime.TryGetValue(Sample, out QubitTimeNode foundValue)) {
                actualTime = foundValue.Time;
                return true;
            }
            if (getLowerBound) {
                actualTime = NodeComparer.MaxLowerBound;
                return ComplexTime.Compare(actualTime, ComplexTime.MinValue) != 0;
            } else {
                actualTime = NodeComparer.MinUpperBound;
                return ComplexTime.Compare(actualTime, ComplexTime.MaxValue) != 0;
            }
        }

        /// <summary>
        /// Remove one qubit with given time from the set. Complexity is log(N), where N - number of nodes.
        /// </summary>
        /// <param name="time">Remove qubit with this time.</param>
        /// <returns>QubitId if qubit is found. Throws exception if it is not found.</returns>
        public long Remove(ComplexTime time) {
            Sample.Time = time;
            if (!QubitTime.TryGetValue(Sample, out QubitTimeNode foundValue)) {
                throw new ApplicationException("Cannot get qubit that should be present in a qubit pool.");
            }
            if (foundValue.NextNode == null) {
                // Remove only node from the tree.
                long qubitId = foundValue.QubitId;
                QubitTime.Remove(Sample);
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
