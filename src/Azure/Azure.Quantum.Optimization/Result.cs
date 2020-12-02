using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace Microsoft.Azure.Quantum.Optimization
{
    public class Result
    {
        [JsonProperty(PropertyName = "version")]
        public string Version
        { get; set; }

        [JsonProperty(PropertyName = "configuration")]
        public Dictionary<string, int> Configuration
        { get; set; }

        [JsonProperty(PropertyName = "cost")]
        public float Cost
        { get; set; }

        [JsonProperty(PropertyName = "parameters")]
        public Dictionary<string, object> Parameters
        { get; set; }
    }
}
