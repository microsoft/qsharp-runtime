// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Xunit.Abstractions;
using Xunit.Sdk;

namespace Microsoft.Quantum.Simulation.XUnit
{
    [Serializable]
    public class TestCase : XunitTestCase
    {
        TestOperation testOperation;

        [EditorBrowsable(EditorBrowsableState.Never)]
        [Obsolete("Called by the de-serializer; should only be called by deriving classes for de-serialization purposes")]
        public TestCase() : base()
        {
        }

        public TestCase(IMessageSink messageSink, TestMethodDisplay defaultTestMethodDisplay, ITestMethod testMethod, TestOperation testOperation)
        : base(messageSink, defaultTestMethodDisplay, testMethod, new[] { testOperation })
        {
            this.testOperation = testOperation;
        }

        protected override string GetDisplayName(IAttributeInfo factAttribute, string displayName)
        {
            if (testOperation.className == "")
            {
                return displayName;
            }
            else
            {
                return testOperation.testCaseNamePrefix + testOperation.className;
            }
        }

        protected override string GetSkipReason(IAttributeInfo factAttribute)
        {
            return testOperation.skipReason;
        }

        #region implementation of IXUnitSerializable interface
        public override void Serialize(IXunitSerializationInfo data)
        {
            data.AddValue("testOperation", testOperation);
            base.Serialize(data);
        }

        public override void Deserialize(IXunitSerializationInfo data)
        {
            base.Deserialize(data);
            testOperation = data.GetValue<TestOperation>("testOperation");
            this.TestMethodArguments = new[] { testOperation };
        }
        #endregion
    }
}
