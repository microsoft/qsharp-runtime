// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Base class containing information about a Q# entry point.
    /// </summary>
    public class EntryPointInfo<I, O>
    {
        public Type Operation { get; }
        public Type InType => typeof(I);
        public Type OutType => typeof(O);

        public EntryPointInfo(Type operation) => 
            this.Operation = operation;
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a Alfred quantum processor.
    /// </summary>
    public class AlfredEntryPointInfo<I, O> 
    : EntryPointInfo<I, O>
    {
        public AlfredEntryPointInfo(Type operation) 
        : base(operation)
        { }
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a Bruno quantum processor.
    /// </summary>
    public class BrunoEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public BrunoEntryPointInfo(Type operation)
        : base(operation)
        { }
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a Clementine quantum processor.
    /// </summary>
    public class ClementineEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public ClementineEntryPointInfo(Type operation)
        : base(operation)
        { }
    }
}
