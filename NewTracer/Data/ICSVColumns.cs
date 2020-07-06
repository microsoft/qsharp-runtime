// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace NewTracer
{
    /// <summary>
    /// Indicates that a type can be serialized as columns of a CSV file.
    /// </summary>
    public interface ICSVColumns
    {
        /// <summary>
        /// Number of columns
        /// </summary>
        int Count { get; }
        /// <summary>
        /// Column names.  Must be of length <see cref="Count"/>.
        /// </summary>
        string[] GetColumnNames();

        /// <summary>
        /// Row corresponding to given type values. Must be of length <see cref="Count"/>.
        /// </summary>
        string[] GetRow();
    }
}
