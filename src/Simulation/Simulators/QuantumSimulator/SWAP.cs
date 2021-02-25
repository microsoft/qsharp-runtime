// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using Microsoft.Quantum.Simulation.Core;

namespace Microsoft.Quantum.Simulation.Simulators
{

    public partial class QuantumSimulator
    {
        public virtual void SWAP__Body(Qubit target1, Qubit target2)
        {
            var ctrls1 = new QArray<Qubit>(target1);
            var ctrls2 = new QArray<Qubit>(target2);
            this.CheckQubits(ctrls1, target2);

            MCX(this.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)target2.Id);
            MCX(this.Id, (uint)ctrls2.Length, ctrls2.GetIds(), (uint)target1.Id);
            MCX(this.Id, (uint)ctrls1.Length, ctrls1.GetIds(), (uint)target2.Id);
        }

        public virtual void SWAP__ControlledBody(IQArray<Qubit> controls, Qubit target1, Qubit target2)
        {
            if ((controls == null) || (controls.Count == 0))
            {
                SWAP__Body(target1, target2);
            }
            else
            {
                var ctrls_1 = QArray<Qubit>.Add(controls, new QArray<Qubit>(target1));
                var ctrls_2 = QArray<Qubit>.Add(controls, new QArray<Qubit>(target2));
                this.CheckQubits(ctrls_1, target2);
                
                MCX(this.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)target2.Id);
                MCX(this.Id, (uint)ctrls_2.Length, ctrls_2.GetIds(), (uint)target1.Id);
                MCX(this.Id, (uint)ctrls_1.Length, ctrls_1.GetIds(), (uint)target2.Id);
            }
        }
    }
}
