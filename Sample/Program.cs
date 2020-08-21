namespace Sample
{
    using System;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Simulators;

    class Program 
    {
        public static void Main(string[] args) 
        {
            using (var sim = new QuantumSimulator()) 
            {
                Stopwatch stopWatch = new Stopwatch();
                stopWatch.Start();
                long gates      = Dummy.Run(sim).Result;
                TimeSpan ts     = stopWatch.Elapsed;
                double tSecs    = ts.TotalSeconds;
                double gps      = gates / tSecs;
                Console.WriteLine($"Time: {tSecs:F2} / {gates:F0} = {gps:E2}");

                stopWatch.Restart();
                gates       = Suprem44.Run(sim).Result;
                ts          = stopWatch.Elapsed;
                tSecs       = ts.TotalSeconds;
                gps         = gates / tSecs;
                Console.WriteLine($"Time: {tSecs:F2} / {gates:F0} = {gps:E2}");

                stopWatch.Restart();
                gates       = Suprem55.Run(sim).Result;
                ts          = stopWatch.Elapsed;
                tSecs       = ts.TotalSeconds;
                gps         = gates / tSecs;
                Console.WriteLine($"Time: {tSecs:F2} / {gates:F0} = {gps:E2}");
            }
        }
    }
}