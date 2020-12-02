using System;
using Newtonsoft.Json;

namespace Microsoft.Azure.Quantum.Optimization
{
    public class Term
    {
        [JsonProperty(PropertyName = "c")]
        public float Weight
        { get; private set; }

        [JsonProperty(PropertyName = "ids")]
        public int[] IDs
        { get; private set; }

        public Term(int[] ids, float c)
        {
            this.IDs = ids;
            this.Weight = c;
        }

        public Term(int i, float c)
        {
            this.IDs = new int[] { i };
            this.Weight = c;
        }

        public Term(int i, int j, float c)
        {
            this.IDs = new int[] { i, j };
            this.Weight = c;
        }

        public Term(int i, int j, int k, float c)
        {
            this.IDs = new int[] { i, j, k };
            this.Weight = c;
        }
    }
}
