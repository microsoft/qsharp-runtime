// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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
        /// Logs a message at the "error" level.
        /// </summary>
        /// <param name="message">Message to log.</param>
        void LogError(string message);
    }
}
