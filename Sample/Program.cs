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
                long gateCnt = HelloQ.Run(sim).Result;
                stopWatch.Stop();
                TimeSpan ts = stopWatch.Elapsed;
                double tSecs = ts.TotalSeconds;
                double gates = (double)gateCnt;
                double gps = gates / tSecs;
                Console.WriteLine($"Time: {tSecs:F2} / {gates:F0} = {gps:E2}");
            }
        }
    }
}