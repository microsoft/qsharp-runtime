// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Qir.Utility;
using Moq;
using Xunit;

namespace Tests.QirController
{
    public class LoggerTests
    {
        private readonly Mock<IClock> clockMock;
        private readonly Logger logger;

        public LoggerTests()
        {
            clockMock = new Mock<IClock>();
            logger = new Logger(clockMock.Object);
        }

        [Fact]
        public void TestLogInfo()
        {
            using var consoleOutput = new StringWriter();
            var message = "some message";
            clockMock.SetupGet(obj => obj.Now).Returns(DateTimeOffset.MinValue);
            var expectedLog = "1/1/0001 12:00:00 AM +00:00 [INFO]: some message" + Environment.NewLine;
            Console.SetOut(consoleOutput);
            logger.LogInfo(message);
            var actualLog = consoleOutput.ToString();
            Assert.Equal(expectedLog, actualLog);
        }

        [Fact]
        public void TestLogError()
        {
            using var consoleOutput = new StringWriter();
            var message = "some message";
            clockMock.SetupGet(obj => obj.Now).Returns(DateTimeOffset.MinValue);
            var expectedLog = "1/1/0001 12:00:00 AM +00:00 [ERROR]: some message" + Environment.NewLine;
            Console.SetOut(consoleOutput);
            logger.LogError(message);
            var actualLog = consoleOutput.ToString();
            Assert.Equal(expectedLog, actualLog);
        }

        [Fact]
        public void TestLogExceptionWithoutStackTrace()
        {
            using var consoleOutput = new StringWriter();
            clockMock.SetupGet(obj => obj.Now).Returns(DateTimeOffset.MinValue);
            var exception = new InvalidOperationException();
            var expectedLog = "1/1/0001 12:00:00 AM +00:00 [ERROR]: " +
                "Exception encountered: System.InvalidOperationException: " +
                exception.Message + Environment.NewLine + exception.StackTrace + Environment.NewLine;
            Console.SetOut(consoleOutput);
            logger.LogException(exception);
            var actualLog = consoleOutput.ToString();
            Assert.Equal(expectedLog, actualLog);
        }

        [Fact]
        public void TestLogExceptionWithStackTrace()
        {
            using var consoleOutput = new StringWriter();
            clockMock.SetupGet(obj => obj.Now).Returns(DateTimeOffset.MinValue);
            Exception exception;
            try
            {
                throw new InvalidOperationException();
            }
            // Throw exception to generate stack trace.
            catch (Exception thrownException)
            {
                exception = thrownException;
            }

            var expectedLog = "1/1/0001 12:00:00 AM +00:00 [ERROR]: " +
                "Exception encountered: System.InvalidOperationException: " +
                exception.Message + Environment.NewLine + exception.StackTrace + Environment.NewLine;
            Console.SetOut(consoleOutput);
            logger.LogException(exception);
            var actualLog = consoleOutput.ToString();
            Assert.Equal(expectedLog, actualLog);
        }
    }
}
