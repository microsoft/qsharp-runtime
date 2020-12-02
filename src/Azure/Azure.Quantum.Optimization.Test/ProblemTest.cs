using System.Text.Json;
using Microsoft.Azure.Quantum.Optimization;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Microsoft.Azure.Quantum.Optimization.Test
{
    [TestClass]
    public class ProblemTest
    {
        [TestMethod]
        public void TestToString()
        {
            var problem = new Problem("Container Problem");
            problem.Add(new Term(new int[]{ 1, 2 }, 3));
            problem.Add(new Term(new int[]{ 4, 5 }, 4.5f));

            string dump = problem.ToString();

            var document = JsonDocument.Parse(dump);

            bool versionMatch = document.RootElement.GetProperty("cost_function").GetProperty("version").ValueEquals("1.0");

            Assert.IsTrue(versionMatch);
        }
    }
}
