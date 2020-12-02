using System.Collections.Generic;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading.Tasks;

namespace Microsoft.Azure.Quantum.Optimization
{
    public enum ProblemType : int
    {
        pubo = 0,
        ising = 1
    }

    struct ProblemSerializationWrapper
    {
        public Problem cost_function { get; set; }
    }

    public class Problem
    {
        [JsonIgnore]
        public string Name
        { get; private set; }

        [JsonPropertyName("version")]
        public string Version
        { get => (initialConfiguration == null) ? "1.0" : "1.1"; }

        [JsonPropertyName("type")]
        [JsonConverter(typeof(JsonStringEnumConverter))]
        public ProblemType ProblemType
        { get; set; }

        [JsonPropertyName("terms")]
        public IEnumerable<Term> Terms
        { get => terms; }

        HashSet<Term> terms;
        Dictionary<string, int> initialConfiguration;

        public Problem(string name)
        {
            this.Name = name;

            terms = new HashSet<Term>();
        }
        public Problem(string name, IEnumerable<Term> collection)
            : this(name)
        {
            AddRange(collection);
        }

        public Problem(string name, IEnumerable<Term> collection, Dictionary<string, int> initialConfiguration)
            : this(name, collection)
        {
            this.initialConfiguration = initialConfiguration;
        }

        public void Add(Term term)
        {
            terms.Add(term);
        }

        public void Add(int i, float c)
        {
            terms.Add(new Term( new int[] { i }, c));
        }

        public void Add(int i, int j, float c)
        {
            terms.Add(new Term( new int[] { i, j }, c));
        }

        public void Add(int i, int j, int k, float c)
        {
            terms.Add(new Term( new int[] { i, j, k }, c));
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
            var root = new ProblemSerializationWrapper
            {
                cost_function = this
            };

            // Save to the writer
            return JsonSerializer.SerializeAsync(stream, root);
        }

        public override string ToString()
        {
            var root = new ProblemSerializationWrapper
            {
                cost_function = this
            };
            return JsonSerializer.Serialize(root);
        }
    }
}
