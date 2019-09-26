// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    ///     An OperationFactory allows the creation at runtime
    ///     of Operation instances.
    /// </summary>
    public interface IOperationFactory
    {
        /// <summary>
        /// Name of the operation factory. Usually this corresponds to the names of the 
        /// simulator.
        /// </summary>
        string Name { get; }

        /// <summary>
        /// Returns an instance of the requested operation.
        /// </summary>
        I Get<I>(Type T);

        /// <summary>
        /// Returns an instance of the requested operation.
        /// </summary>
        I Get<I, T>() where T : AbstractCallable, I;

        /// <summary>
        ///     Executes an Operation. The execution may be asynchronous, 
        ///     so it returns a Task.
        /// </summary>
        Task<O> Run<T, I, O>(I args) where T : AbstractCallable, ICallable;

        /// <summary>
        /// Called by operation, before the start of every operation. Used to enable OnOperationStart
        /// event in simulators.
        /// </summary>
        void StartOperation(ICallable operation, IApplyData inputValue);

        /// <summary>
        /// Called by operation, at the end of every operation. Used to enable OnOperationEnd
        /// event in simulators.
        /// </summary>
        void EndOperation(ICallable operation, IApplyData resultValue);

        /// <summary>
        /// Called by operation, when an exception occurs. Used to enable OnFail
        /// event in simulators. 
        /// </summary>
        void Fail(System.Runtime.ExceptionServices.ExceptionDispatchInfo e);
    }
}