// <copyright file="LazyAsync.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>
// Based on https://gist.github.com/johnazariah/ab269f7e005d538ed706b7a9cdb15bf1

using System;
using System.Runtime.CompilerServices;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Utility
{
    internal sealed class LazyAsync<T>
    {
        private readonly Lazy<Task<T>> instance;
        private readonly Lazy<T> valueL;

        /// <summary>
        /// Constructor for use with synchronous factories
        /// </summary>
        public LazyAsync(Func<T> synchronousFactory)
            : this(new Lazy<Task<T>>(() => Task.Run(synchronousFactory)))
        {
        }

        /// <summary>
        /// Constructor for use with asynchronous factories
        /// </summary>
        public LazyAsync(Func<Task<T>> asynchronousFactory)
            : this(new Lazy<Task<T>>(() => asynchronousFactory()))
        {
        }

        // private constructor which sets both fields
        private LazyAsync(Lazy<Task<T>> instance)
        {
            this.instance = instance;
            this.valueL = new Lazy<T>(() => this.instance.Value.GetAwaiter().GetResult());
        }

        public T Value => valueL.Value;

        public TaskAwaiter<T> GetAwaiter() => instance.Value.GetAwaiter();
    }
}