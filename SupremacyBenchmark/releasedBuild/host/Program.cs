namespace quantum
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
                long        gates = 1;
                TimeSpan    ts;
                double      tSecs;
                double      gps;
                Stopwatch stopWatch = new Stopwatch();

                for (int tst=0; tst<4; tst++) {
                    Console.WriteLine($"Starting test: {tst}...");
                    for (int loop=0; loop<10; loop++) {
                        stopWatch.Restart();
                        switch (tst) {
                            case 0: gates = Dummy.Run(sim).Result; break;
                            case 1: gates = Suprem44.Run(sim).Result; break;
                            case 2: gates = Suprem55.Run(sim).Result; break;
                            case 3: gates = Suprem56.Run(sim).Result; break;
                        }
			stopWatch.Stop();
                        ts 	    = stopWatch.Elapsed;
                        tSecs 	    = ts.TotalSeconds;
                        gps 	    = gates / tSecs;
                        Console.WriteLine($"    {loop:D2}: Time: {tSecs:F2} / {gates:E2} = {gps:E2}");
                    }
                }
            }
        }
    }
}
