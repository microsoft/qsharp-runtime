// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using Microsoft.Quantum.Qir.Utility;
using Moq;
using Xunit;

namespace Tests.Microsoft.Quantum.Qir.Tools
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

        // N.B. Since the logger is meant for internal use, these tests do not verify whether the logger produced a
        //      specific output. Instead it is verified that the produced output contains certain elements.
        [Fact]
        public void TestLogInfo()
        {
            using var consoleOutput = new StringWriter();
            var message = "some message";
            var time = DateTimeOffset.MinValue;
            clockMock.SetupGet(obj => obj.Now).Returns(time);
            Console.SetOut(consoleOutput);
            logger.LogInfo(message);
            var actualLog = consoleOutput.ToString();

            // Verify that the expected elements are present in the produced output.
            Assert.Contains(time.ToString(), actualLog);
            Assert.Contains("INFO", actualLog);
            Assert.Contains(message, actualLog);
            Assert.EndsWith(Environment.NewLine, actualLog);
        }

        [Fact]
        public void TestLogError()
        {
            using var consoleOutput = new StringWriter();
            var message = "some message";
            var time = DateTimeOffset.MinValue;
            clockMock.SetupGet(obj => obj.Now).Returns(time);
            Console.SetOut(consoleOutput);
            logger.LogError(message);
            var actualLog = consoleOutput.ToString();

            // Verify that the expected elements are present in the produced output.
            Assert.Contains(time.ToString(), actualLog);
            Assert.Contains("ERROR", actualLog);
            Assert.Contains(message, actualLog);
            Assert.EndsWith(Environment.NewLine, actualLog);
        }

        [Fact]
        public void TestLogExceptionWithoutStackTrace()
        {
            using var consoleOutput = new StringWriter();
            var time = DateTimeOffset.MinValue;
            clockMock.SetupGet(obj => obj.Now).Returns(time);
            var exception = new InvalidOperationException();
            Console.SetOut(consoleOutput);
            logger.LogException(exception);
            var actualLog = consoleOutput.ToString();

            // Verify that the expected elements are present in the produced output.
            Assert.Contains(time.ToString(), actualLog);
            Assert.Contains("ERROR", actualLog);
            Assert.Contains(exception.Message, actualLog);
            Assert.EndsWith(Environment.NewLine, actualLog);
        }

        [Fact]
        public void TestLogExceptionWithStackTrace()
        {
            using var consoleOutput = new StringWriter();
            var time = DateTimeOffset.MinValue;
            clockMock.SetupGet(obj => obj.Now).Returns(time);
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

            Console.SetOut(consoleOutput);
            logger.LogException(exception);
            var actualLog = consoleOutput.ToString();

            // Verify that the expected elements are present in the produced output.
            Assert.Contains(time.ToString(), actualLog);
            Assert.Contains("ERROR", actualLog);
            Assert.Contains(exception.Message, actualLog);
            Assert.Contains(exception.StackTrace, actualLog);
            Assert.EndsWith(Environment.NewLine, actualLog);
        }
    }
}
