// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace Microsoft.Quantum.Qir.Utility
{
    public class Logger : ILogger
    {
        private readonly IClock clock;

        public Logger(IClock clock)
        {
            this.clock = clock;
        }

        // {timestamp} [{log level}]: {message}.
        private const string LogFormat = "{0} [{1}]: {2}";

        // ...{exception type}: {exception message}{Environment.NewLine}{stack trace}.
        private const string ExceptionMessageFormat = "Exception encountered: {0}: {1}{2}{3}";
        private const string InfoLevel = "INFO";
        private const string WarningLevel = "WARNING";
        private const string ErrorLevel = "ERROR";

        public void LogInfo(string message)
        {
            Console.WriteLine(LogFormat, clock.Now, InfoLevel, message);
        }

        public void LogWarning(string message)
        {
            Console.WriteLine(LogFormat, clock.Now, WarningLevel, message);
        }

        public void LogError(string message)
        {
            Console.WriteLine(LogFormat, clock.Now, ErrorLevel, message);
        }

        public void LogException(Exception e)
        {
            var message = string.Format(ExceptionMessageFormat, e.GetType(), e.Message, Environment.NewLine, e.StackTrace);
            LogError(message);
        }
    }
}
