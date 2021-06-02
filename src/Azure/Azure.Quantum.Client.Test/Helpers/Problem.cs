using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Test
{
    public enum ProblemType : int
    {
        PUBO = 0,
        Ising = 1,
    }

    /// <summary>
    /// This is the data structure that represents a QIO problem payload on the service.
    /// It's currently not exposed in C#, so we have it here so we can test job submission of
    /// the client libraries without having to serialize Q# programs.
    /// </summary>
    public class Problem
    {
        private readonly HashSet<Term> terms = new HashSet<Term>();

        public Problem(ProblemType type = ProblemType.PUBO)
        {
            ProblemType = type;
        }

        public Problem(IEnumerable<Term> collection)
            : this()
        {
            AddRange(collection);
        }

        [JsonPropertyName("version")]
        public string Version => "1.1";

        [JsonPropertyName("type")]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ProblemType ProblemType { get; }

        [JsonPropertyName("terms")]
        public IEnumerable<Term> Terms => terms;

        public void Add(Term term)
        {
            terms.Add(term);
        }

        public void Add(int i, float c)
        {
            terms.Add(new Term(new int[] { i }, c));
        }

        public void Add(int i, int j, float c)
        {
            terms.Add(new Term(new int[] { i, j }, c));
        }

        public void Add(int i, int j, int k, float c)
        {
            terms.Add(new Term(new int[] { i, j, k }, c));
        }

        public void AddRange(IEnumerable<Term> collection)
        {
            foreach (var term in collection)
            {
                terms.Add(term);
            }
        }

        public Task SerializeAsync(Stream stream)
        {
            var root = new SerializationWrapper
            {
                CostFunction = this,
            };

            // Save to the writer
            return JsonSerializer.SerializeAsync(stream, root);
        }

        public override string ToString()
        {
            var root = new SerializationWrapper
            {
                CostFunction = this,
            };

            return JsonSerializer.Serialize(root);
        }

        private struct SerializationWrapper
        {
            [JsonPropertyName("cost_function")]
            public Problem CostFunction { get; set; }
        }

        public class Term
        {
            public Term(int[] ids, float c)
            {
                this.IDs = ids;
                this.Weight = c;
            }

            [JsonPropertyName("c")]
            public float Weight { get; }

            [JsonPropertyName("ids")]
            public int[] IDs { get; }
        }
    }
}
