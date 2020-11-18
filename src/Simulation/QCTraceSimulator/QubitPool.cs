using System;
using System.Collections.Generic;
using System.Text;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime {

    internal struct ComplexTime {
        internal double DepthTime { get; private set; }
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

        internal ComplexTime Advance(double time) {
            if (time == 0.0) {
                return new ComplexTime(DepthTime, DependencyTime + 1);
            }
            return new ComplexTime(DepthTime + time);
        }

        // TODO: Verify!
        internal ComplexTime Retreat(ComplexTime time) {
            if (DepthTime < time.DepthTime) {
                throw new ArgumentException("Cannot retreat depth to a negative time.");
            }
            if (DepthTime == time.DepthTime) {
                return new ComplexTime(0, DependencyTime - time.DependencyTime);
            }
            return new ComplexTime(DepthTime - time.DepthTime, 0);
        }

        internal static int Compare(ComplexTime a, ComplexTime b) {
            int result = a.DepthTime.CompareTo(b.DepthTime);
            if (result != 0) {
                return result;
            }
            return a.DependencyTime.CompareTo(b.DependencyTime);
        }

        internal static ComplexTime Min(ComplexTime a, ComplexTime b) {
            return Compare(a, b) < 0 ? a : b;
        }

        internal static ComplexTime Max(ComplexTime a, ComplexTime b) {
            return Compare(a, b) > 0 ? a : b;
        }

        internal static ComplexTime MinValue { get; } = new ComplexTime(double.MinValue, long.MinValue);
        internal static ComplexTime MaxValue { get; } = new ComplexTime(double.MaxValue, long.MaxValue);
        internal static ComplexTime Zero { get; } = new ComplexTime();
    }

    internal class QubitPool {

        private class QubitTimeNode {
            internal readonly long QubitId;
            // TODO: Consider making this readonly if possible... Currently gets updated on sample.
            internal ComplexTime Time;
            // TODO: If qubits with the same time are common consider array instead of a linked list.
            internal QubitTimeNode NextNode;

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

        private readonly SortedSet<QubitTimeNode> QubitAvailability;
        private readonly VisitingComparer Comparer;
        private readonly QubitTimeNode Sample = new QubitTimeNode();

        private class VisitingComparer : IComparer<QubitTimeNode> {
            internal ComplexTime MaxLowerBound = ComplexTime.MinValue;
            internal ComplexTime MinUpperBound = ComplexTime.MaxValue;
            private QubitTimeNode Sample;

            internal void ResetForComparison(QubitTimeNode sample) {
                MaxLowerBound = ComplexTime.MinValue;
                MinUpperBound = ComplexTime.MaxValue;
                Sample = sample;
            }

            public int Compare(QubitTimeNode a, QubitTimeNode b) {
                // Comparison of a and b nodes to Sample is "by reference" in this function.
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
                    if ((a == Sample) != (b == Sample)) {
                        MaxLowerBound = b.Time;
                        MinUpperBound = b.Time;
                    }
                }
                return result;
            }
        }

        public QubitPool() {
            Comparer = new VisitingComparer();
            QubitAvailability = new SortedSet<QubitTimeNode>(Comparer);
        }

        public void Add(long qubitId, ComplexTime time) {
            QubitTimeNode newNode = new QubitTimeNode(qubitId, time);
            if (QubitAvailability.Add(newNode)) {
                // New item was added to the set, we are done.
                return;
            }
            if (!QubitAvailability.TryGetValue(newNode, out QubitTimeNode existingNode)) {
                // We cannot add, but we cannot find a node with the same value.
                // Is it a floating point glitch? We'll just ignore this one (it will cause reuse).
                // TODO: Is this OK?
                return;
            }
            // Add new node to the linked list as a second element.
            newNode.NextNode = existingNode.NextNode;
            existingNode.NextNode = newNode;
        }

        public bool FindBound(ComplexTime requestedTime, bool getLowerBound, out ComplexTime actualTime) {
            Sample.Time = requestedTime;
            Comparer.ResetForComparison(Sample);
            if (QubitAvailability.TryGetValue(Sample, out QubitTimeNode foundValue)) {
                actualTime = foundValue.Time;
                return true;
            }
            if (getLowerBound) {
                actualTime = Comparer.MaxLowerBound;
                return ComplexTime.Compare(actualTime, ComplexTime.MinValue) != 0;
            } else {
                actualTime = Comparer.MinUpperBound;
                return ComplexTime.Compare(actualTime, ComplexTime.MaxValue) != 0;
            }
        }

        public long Remove(ComplexTime time) {
            Sample.Time = time;
            if (!QubitAvailability.TryGetValue(Sample, out QubitTimeNode foundValue)) {
                throw new ApplicationException("Cannot get qubit that should be present in a qubit pool.");
            }
            if (foundValue.NextNode == null) {
                // Remove only node from the tree.
                long qubitId = foundValue.QubitId;
                QubitAvailability.Remove(Sample);
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
