// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using System.Collections.Generic;
    using Microsoft.Quantum.Simulation.Core;
    using System.Diagnostics;

    public class MeasurementConstraint
    {
        public enum ConstraintType
        {
            /// <summary>
            /// Indicates that constraint corresponds to the assertion that given
            /// measurement outcome should happen with given probability. Assertion
            /// is the fact that the user knows about the computation they are writing.
            /// </summary>
            Assert,
            /// <summary>
            /// Indicated that constraint corresponds to the user wanting to enforce
            /// the measurement outcome for debugging purposes. User does not know that
            /// this particular outcome will happen, but they want to observe execution path
            /// when this outcome happens.
            /// </summary>
            Force
        }

        public ConstraintType Type { get; private set; }

        /// <summary>
        /// The observable being measured
        /// </summary>
        public List<Pauli> Observable { get; private set; }

        /// <summary>
        /// The measurement outcome that should be forced or
        /// should happen with the given probability
        /// </summary>
        public Result ConstrainToResult { get; private set; }

        /// <summary>
        /// Probability with which asserted outcome should happen.
        /// </summary>
        public double Probability { get; private set; }

        /// <summary>
        /// Returns measurement constraint object corresponding to
        /// a given qubit being in zero state
        /// </summary>
        public static MeasurementConstraint ZeroStateAssert()
        {
            MeasurementConstraint m = new MeasurementConstraint
            {
                Type = ConstraintType.Assert,
                Observable = new List<Pauli> { Pauli.PauliZ },
                ConstrainToResult = Result.Zero,
                Probability = 1.0,
            };
            return m;
        }

        /// <summary>
        /// Returns measurement constraint corresponding to the user enforcing given outcome.
        /// </summary>
        public static MeasurementConstraint ForceMeasurement(List<Pauli> observable, Result result)
        {
            Debug.Assert(observable != null);

            MeasurementConstraint m = new MeasurementConstraint
            {
                Type = ConstraintType.Force,
                Observable = observable,
                ConstrainToResult = result,
            };
            return m;
        }

        /// <summary>
        /// Returns measurement constraint corresponding to user asserting that given measurement should
        /// happen with given probability.
        /// </summary>
        public static MeasurementConstraint AssertMeasurement(List<Pauli> observable, Result result, double probability)
        {
            Debug.Assert(observable != null);

            MeasurementConstraint m = new MeasurementConstraint
            {
                Type = ConstraintType.Assert,
                Observable = observable,
                ConstrainToResult = result,
                Probability = probability
            };
            return m;
        }
    }
}