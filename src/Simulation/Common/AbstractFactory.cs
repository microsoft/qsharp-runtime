// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Common
{
    /// <summary>
    ///     A Base class for Factories used to create and manage instances
    ///     of objects of certain type.
    ///     It takes on creating new instances and caching them.
    ///     It also provides a mechanism to register overrides when a given
    ///     type should be replaced by a subclass.
    /// </summary>
    public abstract class AbstractFactory<T>
    {
        private Dictionary<Type, Type> opsOverrides = new Dictionary<Type, Type>();
        private Dictionary<Type, T> opsCache = new Dictionary<Type, T>();

        /// <summary>
        /// Register an override for the given operation.
        /// The original Type must be a subclass of Operation, and the replacement Type must be a 
        /// subclass of the Type it is overriding, otherwise an ArgumentException is thrown.
        /// It also throws an Exception if either of the parameters is null.
        /// </summary>
        public virtual void Register(Type original, Type replace, Type signature = null)
        {
            if (original == null)
            {
                throw new ArgumentNullException(nameof(original));
            }

            if (replace == null)
            {
                throw new ArgumentNullException(nameof(replace));
            }

            if (signature == null)
            {
                signature = original;
            }

            if (!typeof(T).IsAssignableFrom(original))
            {
                throw new ArgumentException($"Invalid original Type: can only register overrides for classes that extend {typeof(T).FullName}", nameof(original));
            }

            if (!typeof(T).IsAssignableFrom(replace))
            {
                throw new ArgumentException($"Invalid replacement Type: can only override with a Type that extends {typeof(T).FullName}", nameof(replace));
            }

            if (!signature.IsAssignableFrom(original))
            {
                throw new ArgumentException($"Invalid original Type: the original Type must be assignable from {signature.FullName}", nameof(original));
            }

            if (!signature.IsAssignableFrom(replace))
            {
                throw new ArgumentException($"Invalid replace Type: the override Type must be assignable to {signature.FullName}", nameof(replace));
            }

            Type key = (original.IsGenericType && original.ContainsGenericParameters) ? original.GetGenericTypeDefinition() : original;

            this.opsOverrides[key] = replace;
        }

        public virtual T CreateInstance(Type t)
        {
            var result = (T)Activator.CreateInstance(t, this);

            if (CanCache(result))
            {
                this.opsCache[t] = result;
            }

            return result;
        }

        public virtual object GetInstance(Type t)
        {
            if (this.opsCache.ContainsKey(t))
            {
                return this.opsCache[t];
            }

            T result;
            if (this.opsOverrides.ContainsKey(t))
            {
                result = (T)this.GetInstance(this.opsOverrides[t]);

                if (CanCache(result))
                {
                    this.opsCache[t] = result;
                }
            }
            else
            {
                result = this.CreateInstance(t);
            }

            return result;
        }

        /// <summary>
        /// Used to determine if the given instance should be cached.
        /// By default, all instances are cacheable.
        /// </summary>
        public virtual bool CanCache(T obj)
        {
            return true;
        }


    }
}
