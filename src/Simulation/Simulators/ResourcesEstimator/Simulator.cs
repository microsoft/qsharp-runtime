using System;
using System.Collections.Generic;
using System.Data;
using Microsoft.Quantum.Simulation.Simulators;
using Microsoft.Quantum.Simulation.Core;
using Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime;
using Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators;

// using System.IO;
// using System.Threading.Tasks;

namespace Simulator
{
    public class AdvancedSimulator : ResourcesEstimatorWithAdditionalPrimitiveOperations
    {
        // public override Task<O> Run<T, I, O>(I args)
        // {
        //     var result = base.Run<T, I, O>(args).Result;
        //     var name = typeof(T).Name;
        //     File.WriteAllText($"{name}.txt", ToTSV());
        //     return Task.Run(() => result);
        // }

        protected override IDictionary<string, IEnumerable<Type>> AdditionalOperations { get; } =
            new Dictionary<string, IEnumerable<Type>> {
                ["CCZ"] = new [] { typeof(Microsoft.Quantum.Simulation.Simulators.QCTraceSimulators.Circuits.CCZ) },
                ["And"] = new [] { typeof(Microsoft.Quantum.Canon.ApplyAnd), typeof(Microsoft.Quantum.Canon.ApplyLowDepthAnd) },
                ["AdjointAnd"] = Array.Empty<Type>()
            };

        protected override void InitializeQCTracerCoreListeners(IList<IQCTraceSimulatorListener> listeners)
        {
            base.InitializeQCTracerCoreListeners(listeners);
            tCoreConfig.Listeners.Add(new RuntimeCounter());
        }

        // CCNOT(a, b, c);
        // T(a);
        // T(b);

        // Original QDK ResEst. -> 9 Ts
        // New QDK ResEst. -> 1 CCZ, 2 Ts

        public override DataTable Data
        {
            get
            {
                var data = base.Data;

                var androw = data.Rows.Find("And");
                var adjandrow = data.Rows.Find("AdjointAnd");
                var cczrow = data.Rows.Find("CCZ");
                var trow = data.Rows.Find("T");

                // Update T count
                trow["Sum"] = (double)trow["Sum"] - 4 * (double)androw["Sum"] - 7 * (double)cczrow["Sum"];
                trow["Max"] = (double)trow["Max"] - 4 * (double)androw["Max"] - 7 * (double)cczrow["Max"];

                // TODO: update CNOT, QubitClifford, and Measure as well

                return data;
            }
        }

        #region Direct access to counts
        public long CNOT => (long)(double)Data!.Rows!.Find("CNOT")![1];
        public long QubitClifford => (long)(double)Data!.Rows!.Find("QubitClifford")![1];
        public long T => (long)(double)Data!.Rows!.Find("T")![1];
        public long Measure => (long)(double)Data!.Rows!.Find("Measure")![1];
        public long QubitCount => (long)(double)Data!.Rows!.Find("QubitCount")![1];
        public long Depth => (long)(double)Data!.Rows!.Find("Depth")![1];
        public long CCZ => (long)(double)Data!.Rows!.Find("CCZ")![1];
        public long And => (long)(double)Data!.Rows!.Find("And")![1];
        public long AdjointAnd => (long)(double)Data!.Rows!.Find("AdjointAnd")![1];
        #endregion

        public override O Execute<T, I, O>(I args)
        {
            var result = base.Execute<T, I, O>(args);
            Console.WriteLine("");
            Console.WriteLine("---BEGIN TABLE---");
            Console.WriteLine(ToTSV());
            Console.WriteLine("---END TABLE---");
            return result;
        }
    }
}
