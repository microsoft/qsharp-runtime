using System;
using System.Collections.Generic;
using System.IO;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace Microsoft.Azure.Quantum.Optimization
{
    public enum ProblemType : int
    {
        pubo = 0,
        ising = 1
    }

    public class Problem
    {
        [JsonIgnore]
        public string Name
        { get; private set; }

        [JsonProperty(PropertyName = "version")]
        public string Version
        { get => (initialConfiguration == null) ? "1.0" : "1.1"; }

        [JsonProperty(PropertyName = "type")]
        [JsonConverter(typeof(StringEnumConverter))]
        public ProblemType ProblemType
        { get; set; }

        [JsonProperty(PropertyName = "terms")]
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

        public void SerializeTo(Stream stream)
        {
            var root = new
            {
                cost_function = this
            };

            // Save to the writer
            var jsonSerializer = new JsonSerializer
            {
                NullValueHandling = NullValueHandling.Ignore
            };

            using var textWriter = new StreamWriter(stream);
            using var jsonWriter = new JsonTextWriter(textWriter);
            jsonSerializer.Serialize(jsonWriter, root);
        }

        public override string ToString()
        {
            var root = new
            {
                cost_function = this
            };
            return JsonConvert.SerializeObject(root);
        }
    }
}
