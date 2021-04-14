// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.IO;
using System.Threading.Tasks;
using Microsoft.Quantum.Simulation.Core;
using Core = Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Runtime
{
    public interface IQirMachine : IAzureMachine
    {
        /// <summary>
        /// Submits a job to execute a QIR program without waiting for execution to complete.
        /// </summary>
        /// <param name="qir">The QIR program as a byte stream.</param>
        /// <param name="entryPoint">The fully-qualified name of the entry point to execute.</param>
        /// <param name="arguments">The arguments to the entry point.</param>
        /// <returns>The submitted job.</returns>
        Task<IQuantumMachineJob> SubmitAsync(Stream qir, string entryPoint, IReadOnlyList<Argument> arguments);
    }

    public class Argument
    {
        public string Name { get; }

        public ArgumentValue Value { get; }

        public Argument(string name, ArgumentValue value)
        {
            this.Name = name;
            this.Value = value;
        }
    }

    public abstract class ArgumentValue
    {
        private ArgumentValue()
        {
        }

        public class Bool : ArgumentValue
        {
            public bool Value { get; }

            public Bool(bool value) => this.Value = value;
        }

        public class Int : ArgumentValue
        {
            public long Value { get; }

            public Int(long value) => this.Value = value;
        }

        public class Double : ArgumentValue
        {
            public double Value { get; }

            public Double(double value) => this.Value = value;
        }

        public class Pauli : ArgumentValue
        {
            public Core.Pauli Value { get; }

            public Pauli(Core.Pauli value) => this.Value = value;
        }

        public class Range : ArgumentValue
        {
            public QRange Value { get; }

            public Range(QRange value) => this.Value = value;
        }

        public class Result : ArgumentValue
        {
            public Core.Result Value { get; }

            public Result(Core.Result value) => this.Value = value;
        }

        public class String : ArgumentValue
        {
            public string Value { get; }

            public String(string value) => this.Value = value;
        }

        public class Array : ArgumentValue
        {
            public QArray<ArgumentValue> Values { get; }

            public Array(QArray<ArgumentValue> values) => this.Values = values;
        }
    }
}
