// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Core;

    /// <summary>
    /// Holds data describing measurement constraint associated to a 
    /// given qubit at a given execution moment. 
    /// </summary>
    public class QubitConstraint
    {
        public QubitConstraint(MeasurementConstraint constraint, uint qubitPosition)
        {
            Debug.Assert(constraint != null);
            this.Set(constraint, qubitPosition);
        }

        public void Set(MeasurementConstraint constraint, uint qubitPosition)
        {
            Debug.Assert(constraint != null);
            Debug.Assert(qubitPosition < constraint.Observable.Count);
            Constraint = constraint;
            QubitPositionInConstraint = qubitPosition;
        }

        public static QubitConstraint ZeroStateConstraint()
        {
            return new QubitConstraint(MeasurementConstraint.ZeroStateAssert(), 0);
        }

        /// <summary>
        /// If qubit was used, in other words some unitary or measurement were applied to it, 
        /// the constraint gets invalidated.
        /// </summary>
        public void OnUseQubit()
        {
            Constraint = null;
        }

        /// <summary>
        /// Released qubits assumed to be in a zero state
        /// </summary>
        public void OnRelease()
        {
            Constraint = MeasurementConstraint.ZeroStateAssert();
            QubitPositionInConstraint = 0;
        }

        /// <summary>
        /// Pauli in the constraint assigned to this qubit
        /// </summary>
        /// <returns></returns>
        public Pauli QubitPauli
        {
            get
            {
                return Constraint.Observable[(int)QubitPositionInConstraint];
            }
        }

        public static void SetConstraint(QubitConstraint[] qubitConstraints, MeasurementConstraint constraint)
        {
            Debug.Assert(qubitConstraints != null);
            Debug.Assert(constraint != null);

            for (uint i = 0; i < qubitConstraints.Length; ++i)
            {
                qubitConstraints[i].Set(constraint, i);
            }
        }

        public MeasurementConstraint Constraint { get; private set; }
        public uint QubitPositionInConstraint { get; private set; }
    }
}