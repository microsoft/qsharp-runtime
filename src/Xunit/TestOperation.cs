using System;
using Xunit.Abstractions;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.XUnit
{
    [Serializable]
    public class TestOperation : IXunitSerializable
    {
        public string assemblyName;
        public string className;
        public string fullClassName;
        public string skipReason;
        public string testCaseNamePrefix;

        /// <summary>
        /// Returns an action that takes a single argument - the simulator to run against.
        /// </summary>
        public Action<IOperationFactory> TestOperationRunner
        {
            get
            {
                return (IOperationFactory sim) =>
                {
                    if (skipReason == null)
                    {
                        System.Reflection.Assembly assembly = System.Reflection.Assembly.Load(assemblyName);
                        Type operationType = assembly.GetType(fullClassName);
                        ICallable<QVoid, QVoid> op = (typeof(IOperationFactory)
                               .GetMethod("Get", new Type[0])
                               .MakeGenericMethod(typeof(ICallable<QVoid, QVoid>), operationType)
                               .Invoke(sim, null)
                           as ICallable<QVoid, QVoid>);
                        if (op == null)
                        {
                            throw new TestOperationException($"Operation with name: {fullClassName} was not found in assembly {assemblyName}");
                        }
                        op.Apply(QVoid.Instance);
                    }
                };
            }
        }

        #region Implementation of IXunitSerializable
        public void Deserialize(IXunitSerializationInfo info)
        {
            assemblyName = info.GetValue<string>("assemblyName");
            className = info.GetValue<string>("className");
            fullClassName = info.GetValue<string>("fullClassName");
            skipReason = info.GetValue<string>("skipReason");
            testCaseNamePrefix = info.GetValue<string>("testCaseNamePrefix");
        }

        public void Serialize(IXunitSerializationInfo info)
        {
            info.AddValue("assemblyName", assemblyName);
            info.AddValue("className", className);
            info.AddValue("fullClassName", fullClassName);
            info.AddValue("skipReason", skipReason);
            info.AddValue("testCaseNamePrefix", testCaseNamePrefix);
        }
        #endregion
    }
}
