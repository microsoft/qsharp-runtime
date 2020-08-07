// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

#nullable enable

using System;
using System.Collections.Generic;
using System.Linq;

namespace Microsoft.Quantum.Simulation.Core
{
    /// <summary>
    /// Contains the metadata associated with an operation's runtime execution path.
    /// </summary>
    public class RuntimeMetadata
    {
        /// <summary>
        /// Label of gate.
        /// </summary>
        public string Label { get; set; } = "";

        /// <summary>
        /// Non-qubit arguments provided to gate, formatted as string.
        /// </summary>
        public string FormattedNonQubitArgs { get; set; } = "";

        /// <summary>
        /// True if operation is an adjoint operation.
        /// </summary>
        public bool IsAdjoint { get; set; }

        /// <summary>
        /// True if operation is a controlled operation.
        /// </summary>
        public bool IsControlled { get; set; }

        /// <summary>
        /// True if operation is a measurement operation.
        /// </summary>
        public bool IsMeasurement { get; set; }

        /// <summary>
        /// True if operation is composed of multiple operations.
        /// </summary>
        /// <remarks>
        /// This is used in composite operations, such as <c>ApplyToEach</c>.
        /// </remarks>
        public bool IsComposite { get; set; }

        /// <summary>
        /// True if operation is a classically-controlled conditional operation.
        /// </summary>
        public bool IsConditional { get; set; }

        /// <summary>
        /// Group of operations for each classical branch (<c>true</c> and <c>false</c>).
        /// </summary>
        /// <remarks>
        /// This is used in classically-controlled operations.
        /// </remarks>
        public IEnumerable<IEnumerable<RuntimeMetadata>>? Children { get; set; }

        /// <summary>
        /// List of control registers.
        /// </summary>
        public IEnumerable<Qubit> Controls { get; set; } = new List<Qubit>();

        /// <summary>
        /// List of target registers.
        /// </summary>
        public IEnumerable<Qubit> Targets { get; set; } = new List<Qubit>();

        private static bool OnlyOneNull(object? a, object? b) =>
            (a == null && b != null) || (b == null && a != null);
        
        private static bool IsBothNull(object? a, object? b) =>
            a == null && b == null;

        private static bool ListEquals<T>(IEnumerable<T> a, IEnumerable<T> b) =>
            IsBothNull(a, b) || (!OnlyOneNull(a, b) && a.SequenceEqual(b));

        public override bool Equals(object? obj)
        {
            var other = obj as RuntimeMetadata;

            if (other is null) return false;

            if (this.Label != other.Label || this.FormattedNonQubitArgs != other.FormattedNonQubitArgs ||
                this.IsAdjoint != other.IsAdjoint || this.IsControlled != other.IsControlled ||
                this.IsMeasurement != other.IsMeasurement || this.IsComposite != other.IsComposite ||
                this.IsConditional != other.IsConditional)
                return false;

            if (!ListEquals<Qubit>(this.Controls, other.Controls)) return false;

            if (!ListEquals<Qubit>(this.Targets, other.Targets)) return false;
            
            // If only one children is null, return false
            if (OnlyOneNull(this.Children, other.Children)) return false;
            
            // If both children are not null, compare each child element-wise and return
            // false if any of them are not equal
            if (!IsBothNull(this.Children, other.Children))
            {
                if (this.Children.Count() != other.Children.Count() ||
                    this.Children.Zip(other.Children, ListEquals<RuntimeMetadata>).Contains(false))
                    return false;
            }

            return true;
        }

        public override int GetHashCode()
        {
            // Stringify qubits, concatenate as string, and get resulting hashcode
            var controlsHash = string.Join(",", this.Controls.Select(q => q?.ToString() ?? "")).GetHashCode();
            var targetsHash = string.Join(",", this.Targets.Select(q => q?.ToString() ?? "")).GetHashCode();

            // Recursively get hashcode of inner `RuntimeMetadata` objects, concatenate into a string,
            // and get resulting hashcode
            var childrenHash = (this.Children != null)
                ? string.Join(", ", this.Children.Select(child => (child != null)
                    ? string.Join(",", child.Select(m => m?.GetHashCode().ToString() ?? "0"))
                    : "0"
                )).GetHashCode()
                : 0;
            
            // Combine all other properties and get the resulting hashcode
            var otherHash = HashCode.Combine(this.Label, this.FormattedNonQubitArgs, this.IsAdjoint, this.IsControlled,
                this.IsMeasurement, this.IsComposite, this.IsConditional);
            
            // Combine them all together to get the final hashcode
            return HashCode.Combine(controlsHash, targetsHash, childrenHash, otherHash);
        }

        public static bool operator ==(RuntimeMetadata? x, RuntimeMetadata? y) =>
            IsBothNull(x, y) || (x?.Equals(y) ?? false);
    
        public static bool operator !=(RuntimeMetadata? x, RuntimeMetadata? y) => !(x == y);
    }
}
