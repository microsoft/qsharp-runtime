// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.Common;
using System.Runtime.InteropServices;
using Microsoft.Quantum.Simulation.Simulators.Exceptions;
using Microsoft.Quantum.Intrinsic.Interfaces;
using System.Collections.Generic;
using System.Diagnostics;
using Microsoft.Quantum.Telemetry;

#nullable enable

namespace Microsoft.Quantum.Simulation.Simulators
{
    using QubitIdType = System.UInt32;

    public partial class SparseSimulator : CommonNativeSimulator
    {
        protected TelemetryManagerConfig TelemetryConfig { get; private set; }
        IDisposable TelemetryManagerDisposer;

        /// <summary>
        /// Creates a an instance of a sparse simulator.
        /// </summary>
        /// <param name="throwOnReleasingQubitsNotInZeroState"> If set to true, the exception is thrown when trying to release qubits not in zero state. </param>
        /// <param name="randomNumberGeneratorSeed"> Seed for the random number generator used by a simulator for measurement outcomes and the Random operation. </param>
        /// <param name="disableBorrowing"> If true, Borrowing qubits will be disabled, and a new qubit will be allocated instead every time borrowing is requested. Performance may improve. </param>
        /// <param name="numQubits"> Qubit capacity. </param>
        public SparseSimulator(
            bool throwOnReleasingQubitsNotInZeroState = true,
            UInt32? randomNumberGeneratorSeed = null,
            bool disableBorrowing = false,
            uint numQubits = 64)
        : base(throwOnReleasingQubitsNotInZeroState,
               randomNumberGeneratorSeed,
               disableBorrowing)
        {
            // Init the telemetry first, to catch/log the construction issues:
            TelemetryConfig = new TelemetryManagerConfig()
            {
                AppId = this.Name,
                SendTelemetryInitializedEvent = true,
                SendTelemetryTearDownEvent = true,
            };
            TelemetryManagerDisposer = TelemetryManager.Initialize(TelemetryConfig);

            Microsoft.Applications.Events.EventProperties eventProperties = new Applications.Events.EventProperties()
                {
                    Name = "Quantum.SparseSim.Constructed",
                };
            eventProperties.SetProperty("throwOnReleasingQubitsNotInZeroState", throwOnReleasingQubitsNotInZeroState);
            eventProperties.SetProperty("randomNumberGeneratorSeed", randomNumberGeneratorSeed);
            eventProperties.SetProperty("disableBorrowing", disableBorrowing);
            eventProperties.SetProperty("numQubits", numQubits);
            TelemetryManager.LogEvent(eventProperties);

            try
            {
                Id = init_cpp((QubitIdType)numQubits);

                // Make sure that the same seed used by the built-in System.Random
                // instance is also used by the native simulator itself.
                seed_cpp(this.Id, (uint)this.Seed);
            }
            catch (Exception exception)
            {
                TelemetryManager.LogObject(exception);
            }
        }

        public override void Dispose()
        {
            try
            {
                destroy_cpp(this.Id);
            }
            catch (Exception exception)
            {
                TelemetryManager.LogObject(exception);
            }
            TelemetryManagerDisposer.Dispose();
        }

        public override string Name
        {
            get
            {
                return "SparseSimulator";
            }
        }
    }
}
