using System.Text.Json.Serialization;
using System.Collections.Generic;

namespace Microsoft.Azure.Quantum.Optimization
{
    public class Result
    {
        [JsonPropertyName("version")]
        public string Version
        { get; set; }

        [JsonPropertyName("configuration")]
        public Dictionary<string, int> Configuration
        { get; set; }

        [JsonPropertyName("cost")]
        public float Cost
        { get; set; }

        [JsonPropertyName("parameters")]
        public Dictionary<string, object> Parameters
        { get; set; }
    }
}
