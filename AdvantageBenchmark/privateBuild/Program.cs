namespace quantum
{
    using System;
    using System.Diagnostics;
    using Microsoft.Quantum.Simulation.Simulators;

    class Program 
    {
        public static void Main(string[] args) 
        {
            Console.WriteLine($"CSV,test,loop,secs,gates,THREADS,FUSESPAN,FUSEDEPTH,Gates/sec");
            var envThr  = System.Environment.GetEnvironmentVariable("OMP_NUM_THREADS");
            var envFus  = System.Environment.GetEnvironmentVariable("QDK_SIM_FUSESPAN");
            var envDep  = System.Environment.GetEnvironmentVariable("QDK_SIM_FUSEDEPTH");
            if (envThr == null || envThr.Length == 0) envThr = "Default";
            if (envFus == null || envFus.Length == 0) envFus = "Default";
            if (envDep == null || envDep.Length == 0) envDep = "99";

            int tstMin  = 0;
            int tstMax  = 3;
            int loopCnt = 10;

            if (args.Length > 0) tstMin  = Convert.ToInt32(args[0]);
            if (args.Length > 1) tstMax  = Convert.ToInt32(args[1]);
            if (args.Length > 2) loopCnt = Convert.ToInt32(args[2]);

            using (var sim = new QuantumSimulator()) 
            {
                long        gates = 1;
                TimeSpan    ts;
                double      tSecs;
                double      gps;
                string      tstName = "";
                Stopwatch stopWatch = new Stopwatch();
                double totalSecs = 0;

                for (int tst = tstMin; tst <= tstMax; tst++)
                {
                    for (int loop = 0; loop < loopCnt; loop++)
                    {
                        stopWatch.Restart();
                        switch (tst) 
                        {
                            case 0: 
                                gates   = Dummy.Run(sim).Result; 
                                tstName = "Dummy";
                                break;
                            case 1: 
                                gates = Advantage44.Run(sim).Result; 
                                tstName = "4x4";
                                break;
                            case 2: 
                                gates = Advantage55.Run(sim).Result; 
                                tstName = "5x5";
                                break;
                            case 3: 
                                gates = Advantage56.Run(sim).Result; 
                                tstName = "5x6";
                                break;
                            case 4:
                                gates = HGate.Run(sim).Result;
                                tstName = "HGate30";
                                break;
                            case 5:
                                gates = CNOTGate.Run(sim).Result;
                                tstName = "CNOTGate30";
                                break;
                            case 6:
                                gates = CCNOTGate.Run(sim).Result;
                                tstName = "CCNOTGate30";
                                break;
                        }
			            stopWatch.Stop();
                        ts 	    = stopWatch.Elapsed;
                        tSecs 	    = ts.TotalSeconds;
                        gps 	    = gates / tSecs;
                        totalSecs += tSecs;

                        Console.WriteLine($"CSV,{tstName},{loop:D2},{tSecs:F2},{gates:E2},{envThr},{envFus},{envDep},{gps:E2}");
                    }
                }

                Process currentProcess = Process.GetCurrentProcess();
                var cpuTime = currentProcess.TotalProcessorTime;
                double cpuUsage = cpuTime.TotalSeconds / (totalSecs * Environment.ProcessorCount);
                Console.WriteLine($"CPU Usage Ratio: {cpuUsage}, Total CPU Time: {cpuTime.TotalSeconds} seconds, Elapsed Time: {totalSecs} seconds, cores: {Environment.ProcessorCount}");
            }
        }
    }
}
