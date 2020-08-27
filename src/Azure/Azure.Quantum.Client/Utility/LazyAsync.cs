// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.
//
// Based on https://gist.github.com/johnazariah/ab269f7e005d538ed706b7a9cdb15bf1

using System;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Utility
{
    internal sealed class LazyAsync<T> : Lazy<Task<T>>
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="LazyAsync{T}"/> class.
        /// Constructor for use with asynchronous factories.
        /// </summary>
        /// <param name="taskFactory">Async value factory.</param>
        public LazyAsync(Func<Task<T>> taskFactory)
            : base(() => Task.Run(taskFactory))
        { }

        /// <summary>
        /// Initializes a new instance of the <see cref="LazyAsync{T}"/> class.
        /// Constructor for use with synchronous factories.
        /// </summary>
        /// <param name="valueFactory">Sync value factory.</param>
        public LazyAsync(Func<T> valueFactory)
            : base(() => Task.Run(valueFactory))
        { }

        public TaskAwaiter<T> GetAwaiter() => Value.GetAwaiter();
    }
}