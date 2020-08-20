namespace Sample
{
    using System;
    using Microsoft.Quantum.Simulation.Simulators;
    using Microsoft.Quantum.Simulation.Core;

    class Program 
    {
        public static void Main(string[] args) 
        {
            using (var sim = new QuantumSimulator()) 
            {
                var result = HelloQ.Run(sim).Result;

                Console.WriteLine($"Result: {result}");
            }
        }
    }
}