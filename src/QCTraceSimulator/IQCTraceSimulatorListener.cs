using Microsoft.Quantum.Simulation.Core;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime
{
    /// <summary>
    /// The interface used to receive notifications about events from <see cref="QCTraceSimulatorCore"/>.
    /// See <see cref="DistinctInputsChecker"/> for a simple example of the class implementing this interface. 
    /// </summary>
    public interface IQCTraceSimulatorListener
    {
        /// <summary>
        /// Called every time qubits are allocated by the <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to allocated qubits. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnAllocate(object[] qubitsTraceData);

        /// <summary>
        /// Called every time qubits are released by the <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to released qubits. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnRelease(object[] qubitsTraceData);

        /// <summary>
        /// Called every time qubits are borrowed by the <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to borrowed qubits. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnBorrow(object[] qubitsTraceData, long newQubitsAllocated );

        /// <summary>
        /// Called every time qubits are returned by the <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to returned qubits. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnReturn(object[] qubitsTraceData, long qubitReleased );

        /// <summary>
        /// Called every time primitive operation is executed by <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to qubits passed to the operation. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnPrimitiveOperation(int id, object[] qubitsTraceData, double primitiveOperationDuration);

        /// <summary>
        /// Called before an operation is going to be executed by <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="name">Name of the operation that is going to be executed</param>
        /// <param name="qubitsTraceData"> Data attached to qubits passed to the operation. Each instance of the attached data is created by the call to <see cref="NewTracingData"/>.
        /// If <see cref="NeedsTracingDataInQubits"/> returns false this argument will be null. </param>
        void OnOperationStart(HashedString name, OperationFunctor variant, object[] qubitsTraceData);

        /// <summary>
        /// Called after an operation was executed by <see cref="QCTraceSimulatorCore"/>
        /// </summary>
        /// <param name="qubitsTraceData"> Data attached to the returned qubits. Each instance of the attached data is created by the call to <see cref="NewTracingData"/></param>
        void OnOperationEnd(object[] returnedQubitsTraceData);

        /// <summary>
        /// Returns an object containing data that the listener would like to attach to the given qubit.
        /// </summary>
        /// <param name="qubitId">Id of the qubit to which the data is going to be attached to.</param>
        object NewTracingData(long qubitId);

        /// <summary>
        /// Returns true if the listener needs tracing data associated to each qubit.
        /// </summary>
        /// <returns></returns>
        bool NeedsTracingDataInQubits { get; }
    }
}
