using System.Collections.Generic;

namespace ShippingSample
{
    using System;
    using System.Linq;
    using Microsoft.Azure.Quantum.Optimization;
    using Newtonsoft.Json;

    partial class Program
    {
        static void Main(string[] args)
        {
            var workspace = CreateWorkspace();

            // This array contains a list of the weights of the containers
            var containerWeights = new int[] { 1, 5, 9, 21, 35, 5, 3, 5, 10, 11 };

            // Create a problem for the list of containers:
            var problem = CreateProblemForContainerWeights(containerWeights);

            // Submit problem to Azure Quantum using the ParallelTempering solver:
            // Instantiate a solver to solve the problem. 
            var solver = new ParallelTemperingSolver(workspace, timeout: 100);

            // Optimize the problem
            Console.Out.WriteLine("Submitting problem...");
            var startTime = DateTime.Now;
            var result = solver.Optimize(problem);
            var timeElapsed = DateTime.Now.Subtract(startTime);
            Console.Out.WriteLine("Result in {0} seconds:\n{0}", timeElapsed.TotalSeconds, result);

            // Print out a summary of the results:
            PrintResultSummary(result, containerWeights);

            // Improving the Cost Function
            // The cost function we"ve built works well so far, but let"s take a closer look at the `Problem` that was generated:
            Console.Out.WriteLine("The original problem has {0} terms for {1} containers:", problem.Terms.Count(), containerWeights.Length);
            Console.Out.WriteLine(JsonConvert.SerializeObject(problem.Terms));

            // Check that this creates a smaller problem
            // Create the simplified problem
            var simplifiedProblem = CreateSimplifiedProblemForContainerWeights(containerWeights);
            Console.Out.WriteLine("The simplified problem has {0} terms", simplifiedProblem.Terms.Count());

            // Optimize the problem
            Console.Out.WriteLine("Submitting simplified problem...");
            startTime = DateTime.Now;
            var simplifiedResult = solver.Optimize(simplifiedProblem);
            var timeElapsedSimplified = DateTime.Now.Subtract(startTime);
            Console.Out.WriteLine("Result in {0} seconds:\n{1}", timeElapsedSimplified.TotalSeconds, simplifiedResult);
            PrintResultSummary(simplifiedResult, containerWeights);
        }
        static void PrintResultSummary(Result result, int[] containerWeights)
        {
            // Print a summary of the result
            int shipAWeight = 0;
            int shipBWeight = 0;
            foreach (var container in result.Configuration)
            {
                int containerIndex = Int32.Parse(container.Key);
                int containerAssignment = container.Value;

                int containerWeight = containerWeights[containerIndex];

                string ship = String.Empty;
                if (containerAssignment == 1)
                {
                    ship = "A";
                    shipAWeight += containerWeight;
                }
                else
                {
                    ship = "B";
                    shipBWeight += containerWeight;
                }

                Console.Out.WriteLine("Container {0} with weight {1} was placed on Ship {2}", containerIndex, containerWeight, ship);
            }

            Console.Out.WriteLine("Total weights: \n\tShip A: {0} tonnes \n\tShip B: {1} tonnes", shipAWeight, shipBWeight);
        }

        // Take an array of container weights and return a Problem object that represents the cost function
        static Problem CreateProblemForContainerWeights(int[] containerWeights)
        {
            // Create an Ising-type problem
            var problem = new Problem("Ship-Sample-Problem")
            {
                ProblemType = ProblemType.ising
            };

            // Expand the squared summation
            for (int i = 0; i < containerWeights.Length; i++)
                for (int j = 0; j < containerWeights.Length; j++)
                {
                    // Skip the terms where i == j as they form constant terms in an Ising problem and can be disregarded:
                    // w_i∗w_j∗x_i∗x_j = w_i​*w_j∗(x_i)^2 = w_i∗w_j​​
                    // for x_i = x_j, x_i ∈ {1, -1}
                    if (i != j)
                    {
                        problem.Add(i, j, containerWeights[i] * containerWeights[j]);
                    }
                }

            return problem;
        }

        // We can reduce the number of terms by removing duplicates
        // In code, this means a small modification to the createProblemForContainerWeights function:
        static Problem CreateSimplifiedProblemForContainerWeights(int[] containerWeights)
        {
            var terms = new List<Term>();

            // Expand the squared summation
            for (int i = 0; i < containerWeights.Length - 1; i++)
                for (int j = i + 1; j < containerWeights.Length; j++)
                {
                    terms.Add(new Term(i, j, containerWeights[i] * containerWeights[j]));
                }

            // Return an Ising-type problem
            return new Problem("Ship-Sample-Problem-Simplified", terms)
            {
                ProblemType = ProblemType.ising
            };
        }
    }
}
