using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// Allow the test assembly to use our internal methods
[assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.Simulation.Simulators" + SigningConstants.PUBLIC_KEY)]
