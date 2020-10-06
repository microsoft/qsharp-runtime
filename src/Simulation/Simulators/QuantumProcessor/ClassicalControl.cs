// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System;
using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.QuantumProcessor
{
    public partial class QuantumProcessorDispatcher
    {
        public override void ExecuteBranchingBasedOnMeasurement(long condition, Action onEqual, Action onNonEqual)
        {
            bool run = this.QuantumProcessor.RunThenClause(condition);
            while (run)
            {
                onEqual?.Invoke();
                run = this.QuantumProcessor.RepeatThenClause(condition);
            }

            run = this.QuantumProcessor.RunElseClause(condition);
            while (run)
            {
                onNonEqual?.Invoke();
                run = this.QuantumProcessor.RepeatElseClause(condition);
            }
        }

        public override long StartBranchingBasedOnMeasurement(Result result1, Result result2)
        {
            return this.QuantumProcessor.StartConditionalStatement(result1, result2);
        }

        public override long StartBranchingBasedOnMeasurement(IQArray<Result> results1, IQArray<Result> results2)
        {
            return this.QuantumProcessor.StartConditionalStatement(results1, results2);
        }

        public override void EndBranchingBasedOnMeasurement(long statement)
        {
            this.QuantumProcessor.EndConditionalStatement(statement);
        }
    }
}
