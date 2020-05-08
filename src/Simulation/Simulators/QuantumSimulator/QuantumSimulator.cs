// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Linq;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using System.Threading;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using System.Collections.Generic;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Simulators
{
    public partial class QuantumSimulator : SimulatorBase, IDisposable
    {
        public const string QSIM_DLL_NAME = "Microsoft.Quantum.Simulator.Runtime.dll";

        private delegate void IdsCallback(uint id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "DumpIds")]
        private static extern void sim_QubitsIds(uint id, IdsCallback callback);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "init")]
        private static extern uint Init();

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "destroy")]
        private static extern uint Destroy(uint id);

        [DllImport(QSIM_DLL_NAME, ExactSpelling = true, CallingConvention = CallingConvention.Cdecl, EntryPoint = "seed")]
        private static extern void SetSeed(uint id, UInt32 seedValue);

        public uint Seed{ get; private set; }

        /// <summary>
        /// Creates a an instance of a quantum simulator.
        /// </summary>
        /// <param name="throwOnReleasingQubitsNotInZeroState"> If set to true, the exception is thrown when trying to release qubits not in zero state. </param>
        /// <param name="randomNumberGeneratorSeed"> Seed for the random number generator used by a simulator for measurement outcomes and the Random operation. </param>
        /// <param name="disableBorrowing"> If true, Borrowing qubits will be disabled, and a new qubit will be allocated instead every time borrowing is requested. Performance may improve. </param>
        public QuantumSimulator(
            bool throwOnReleasingQubitsNotInZeroState = true,
            UInt32? randomNumberGeneratorSeed = null,
            bool disableBorrowing = false)
            : base(new QSimQubitManager(throwOnReleasingQubitsNotInZeroState, disableBorrowing : disableBorrowing))
        {
            Seed = (randomNumberGeneratorSeed.HasValue)
             ? randomNumberGeneratorSeed.Value
             : (uint)Guid.NewGuid().GetHashCode();

            Console.WriteLine("@@@DBG: Made it to the simulator"); //@@@DBG
            Id = Init();
            SetSeed(this.Id, this.Seed);
            ((QSimQubitManager)QubitManager).Init(Id);
        }

        public uint Id { get; }

        public override string Name
        {
            get
            {
                return "Quantum Simulator";
            }
        }

        static void CheckQubitInUse(Qubit q, bool[] used)
        {
            if (q == null) throw new ArgumentNullException(nameof(q), "Trying to perform a primitive operation on a null Qubit");

            if (used[q.Id])
            {
                throw new NotDistinctQubits(q);
            }

            used[q.Id] = true;
        }

        /// <summary>
        ///     Makes sure the angle for a rotation or exp operation is not NaN or Infinity.
        /// </summary>
        static void CheckAngle(double angle)
        {
            IgnorableAssert.Assert(!(double.IsNaN(angle) || double.IsInfinity(angle)), "Invalid angle for rotation/exponentiation.");

            if (double.IsNaN(angle)) throw new ArgumentOutOfRangeException("angle", "Angle can't be NaN.");
            if (double.IsInfinity(angle)) throw new ArgumentOutOfRangeException("angle", "Angle can't be Infity.");
        }

        /// <summary>
        ///     Makes sure the target qubit of an operation is valid. In particular it checks that the qubit instance is not null.
        /// </summary>
        void CheckQubit(Qubit q1)
        {
            if (q1 == null) throw new ArgumentNullException(nameof(q1), "Trying to perform a primitive operation on a null Qubit");
        }

        /// <summary>
        ///     Makes sure all qubits are valid as parameter of an intrinsic quantum operation. In particular it checks that 
        ///         - none of the qubits are null
        ///         - there are no duplicated qubits
        /// </summary>
        bool[] CheckQubits(IQArray<Qubit> ctrls, Qubit q1)
        {
            bool[] used = new bool[((QSimQubitManager)QubitManager).MaxId];

            CheckQubitInUse(q1, used);

            if (ctrls != null && ctrls.Length > 0)
            {
                foreach (var q in ctrls)
                {
                    CheckQubitInUse(q, used);
                }
            }

            return used;
        }


        /// <summary>
        ///     Makes sure all qubits are valid as parameter of an intrinsic quantum operation. In particular it checks that 
        ///         - none of the qubits are null
        ///         - there are no duplicated qubits
        /// </summary>
        bool[] CheckQubits(IQArray<Qubit> targets)
        {
            if (targets == null) throw new ArgumentNullException(nameof(targets), "Trying to perform an intrinsic operation on a null Qubit array.");
            if (targets.Length == 0) throw new ArgumentNullException(nameof(targets), "Trying to perform an intrinsic operation on an empty Qubit array.");

            bool[] used = new bool[((QSimQubitManager)QubitManager).MaxId];

            foreach (var q in targets)
            {
                CheckQubitInUse(q, used);
            }

            return used;
        }

        /// <summary>
        ///     Makes sure all qubits are valid as parameter of an intrinsic quantum operation. In particular it checks that 
        ///         - none of the qubits are null
        ///         - there are no duplicated qubits
        /// </summary>
        bool[] CheckQubits(IQArray<Qubit> ctrls, IQArray<Qubit> targets)
        {
            bool[] used = CheckQubits(targets);

            if (ctrls != null)
            {
                foreach (var q in ctrls)
                {
                    CheckQubitInUse(q, used);
                }
            }

            return used;
        }

        /// <summary>
        ///     Returns the list of the qubits' ids currently allocated in the simulator.
        /// </summary>
        public uint[] QubitIds
        {
            get
            {
                var ids = new List<uint>();
                sim_QubitsIds(this.Id, ids.Add);
                Debug.Assert(ids.Count == this.QubitManager.GetAllocatedQubitsCount());
                return ids.ToArray();
            }
        }

        static void SafeControlled(IQArray<Qubit> ctrls, Action noControlsAction, Action<uint, uint[]> controlledAction)
        {
            if (ctrls == null || ctrls.Length == 0)
            {
                noControlsAction();
            }
            else
            {
                uint count = (uint)ctrls.Length;                
                controlledAction(count, ctrls.GetIds());
            }
        }

        public void Dispose()
        {
            Destroy(this.Id);
        }
    }
}
