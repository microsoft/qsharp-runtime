// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Qir.Utility
{
    /// <summary>
    /// Logger for internal traces and errors.
    /// </summary>
    /// <remarks>For now, this thinly wraps console logging. In the future, this might be extended to log to files or other systems.</remarks>
    public interface ILogger
    {
        /// <summary>
        /// Logs a message at the "information" level.
        /// </summary>
        /// <param name="message">Message to log.</param>
        void LogInfo(string message);

        /// <summary>
        /// Logs a message at the "warning" level.
        /// </summary>
        /// <param name="message">Message to log.</param>
        void LogWarning(string message);

        /// <summary>
        /// Logs a message at the "error" level.
        /// </summary>
        /// <param name="message">Message to log.</param>
        void LogError(string message);

        /// <summary>
        /// Formats an exception into an error log. Logs the exception type, message, and stack trace.
        /// </summary>
        /// <param name="e">Exception to log.</param>
        void LogException(Exception e);
    }
}
