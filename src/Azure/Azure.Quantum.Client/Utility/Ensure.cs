// <copyright file="Ensure.cs" company="Microsoft Corporation">
// Copyright (c) Microsoft Corporation. All rights reserved.
// </copyright>

using System;

namespace Microsoft.Azure.Quantum.Utility
{
    /// <summary>
    /// Validation class.
    /// </summary>
    internal static class Ensure
    {
        /// <summary>
        /// Ensures not null or whitespace.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <param name="name">The name.</param>
        public static void NotNullOrWhiteSpace(string value, string name)
        {
            if (string.IsNullOrWhiteSpace(value))
            {
                throw new ArgumentException(name);
            }
        }

        /// <summary>
        /// Ensures not null.
        /// </summary>
        /// <param name="value">The value.</param>
        /// <param name="name">The name.</param>
        public static void NotNull(object value, string name)
        {
            if (value == null)
            {
                throw new ArgumentNullException(name);
            }
        }
    }
}
