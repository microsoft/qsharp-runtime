// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Generic;


namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Corresponds to Q# Range type. For example, the Q# value of <code>start .. step .. end</code> 
    /// is of the QRange type.
    /// </summary>
    public class QRange : IEnumerable<long>
    {
        public QRange() : this(0, 1, 0)
        {
        }

        /// <summary>
        /// Creates a range corresponding to Q# value <code>start .. step .. end</code>
        /// </summary>
        public QRange(long start, long step, long end)
        {
            if (step == 0)
            {
                throw new ArgumentException("Step can't be 0", nameof(step));
            }

            this.Start = start;
            this.Step = step;
            this.End = end;
        }

        /// <summary>
        /// Creates a range with step equal to 1, corresponding to 
        ///  Q# value of <code>[start .. end]</code> 
        /// </summary>
        public QRange(long start, long end) : this(start, 1, end)
        {
        }

        /// <summary>
        /// First element (inclusive)
        /// </summary>
        public long Start { get; }

        /// <summary>
        /// Number to increment on each step. 
        /// If negative, the absolute value of the number will
        /// be subtracted on each step.
        /// </summary>
        public long Step { get; }

        /// <summary>
        /// The last element (inclusive)
        /// </summary>
        public long End { get; }

        /// <summary>
        /// Returns an empty range.
        /// </summary>
        public static QRange Empty =>
            new QRange(0L, -1L);

        /// <summary>
        /// Returns true if the range is empty.
        /// </summary>
        public bool IsEmpty =>
            (End < Start && Step >= 0) || (End > Start && Step <= 0);

        public QRange Reverse()
        {
            if (IsEmpty) return QRange.Empty; 
            long newStart = Start + ((End - Start) / Step) * Step;
            return new QRange(newStart, -Step, Start);
        }

        /// <summary>
        /// Implementation of <see cref="IEnumerable.GetEnumerator"/>.
        /// </summary>
        IEnumerator IEnumerable.GetEnumerator()
        {
            return this.GetEnumerator();
        }

        /// <summary>
        /// Implementation of <see cref="IEnumerable{T}.GetEnumerator"/>.
        /// </summary>
        public IEnumerator<long> GetEnumerator()
        {
            var current = this.Start;

            if (this.Step > 0)
            {
                while (current <= this.End )
                {
                    yield return current;
                    current += this.Step;
                }
            }
            else
            {
                while (current >= this.End)
                {
                    yield return current;
                    current += this.Step;
                }
            }
        }

        /// <summary>
        /// Prints Q# representation of the value.
        /// </summary>
        public override string ToString()
        {
            return Start.ToString() + ".." + Step.ToString() + ".." + End.ToString();
        }
    }
}
