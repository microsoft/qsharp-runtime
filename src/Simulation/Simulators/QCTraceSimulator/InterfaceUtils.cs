// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Diagnostics;

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators
{
    /// <summary>
    /// Utility functions for extracting Type related to ICallalble, IAdjointable, IControllable
    /// and IUnitary
    /// </summary>
    public static partial class Extensions
    {
        /// <summary>
        /// For a type t implementing generic  
        /// interface given by genericInterfaceDefinition
        /// return type corresponding to genericInterface with filled in 
        /// generic parameters. Returns null if type does not implement generic interface
        /// and causes Debug.Assert if type implements more than one of the generic interfaces. 
        /// </summary>
        static Type? InterfaceType(Type t, Type genericInterfaceDefinition)
        {
            Type? interfaceTypeResult = null;
            int interfaceCount = 0;
            foreach (Type interfaceType in t.GetInterfaces())
            {
                if (interfaceType.IsGenericType && interfaceType.GetGenericTypeDefinition()
                    == genericInterfaceDefinition)
                {
                    interfaceCount++;
                    interfaceTypeResult = interfaceType;
                }
            }
            Debug.Assert(interfaceCount <= 1, "Expecting type to implement at most one specialization of the interface");
            return interfaceTypeResult;
        }

        /// <summary>
        /// Returns type of ICallable interface implemented by a given type.
        /// If given type does not implement ICallable return null
        /// </summary>
        public static Type? ICallableType(this Type t)
        {
            return InterfaceType(t, typeof(ICallable<,>));
        }

        /// <summary>
        /// Returns type of IUnitary interface implemented by a given type.
        /// If given type does not implement ICallable return null
        /// </summary>
        public static Type? IUnitatryType(this Type t)
        {
            return InterfaceType(t, typeof(IUnitary<>));
        }

        /// <summary>
        /// Returns type of IUnitary interface implemented by a given type.
        /// If given type does not implement ICallable return null
        /// </summary>
        public static Type? IAdjointableType(this Type t)
        {
            return InterfaceType(t, typeof(IAdjointable<>));
        }

        /// <summary>
        /// Returns type of IControllable interface implemented by a given type.
        /// If given type does not implement ICallable return null
        /// </summary>
        public static Type? IControllableType(Type t)
        {
            return InterfaceType(t, typeof(IControllable<>));
        }
    }
}