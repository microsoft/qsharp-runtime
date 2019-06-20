using System;
using System.Diagnostics;

namespace Microsoft.Quantum.Simulation.Core
{
    public static class IgnorableAssert
    {
        /// <summary>
        /// This flag allows to enable or disable IgnorableAssert.Assert from firing.
        /// </summary>
        [ThreadStatic]
        static int disabled = 0;

        /// <summary>
        /// Equivalent of Debug.Assert, but can be disabled for the purposes of testing error cases.
        /// </summary>
        /// <param name="condition">The conditional expression to evaluate. If the condition is true, a failure message is not sent.</param>
        /// <param name="message">The message to output</param>
        [Conditional("DEBUG")]
        public static void Assert(bool condition, string message)
        {
            if (disabled == 0)
            {
                Debug.Assert(condition, message);
            }
        }

        public static void Disable()
        {
            Debug.Assert(disabled < int.MaxValue, "Too many requests to disable asserts");
            disabled++;
        }

        public static void Enable()
        {
            if (disabled > 0) { disabled--; }
        }
    }
}
