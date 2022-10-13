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
    /// for a Q# executable targeted for a IonQ quantum processor.
    /// </summary>
    public class IonQEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public IonQEntryPointInfo(Type operation)
        : base(operation)
        { }
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a QCI quantum processor.
    /// </summary>
    public class QCIEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public QCIEntryPointInfo(Type operation)
        : base(operation)
        { }
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a Quantinuum quantum processor.
    /// </summary>
    public class QuantinuumEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public QuantinuumEntryPointInfo(Type operation)
        : base(operation)
        { }
    }

    /// <summary>
    /// Base class containing information about an entry point 
    /// for a Q# executable targeted for a Rigetti quantum processor.
    /// </summary>
    public class RigettiEntryPointInfo<I, O>
    : EntryPointInfo<I, O>
    {
        public RigettiEntryPointInfo(Type operation)
        : base(operation)
        { }
    }
}
