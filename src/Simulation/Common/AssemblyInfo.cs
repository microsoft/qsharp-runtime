// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Runtime.CompilerServices;

// Allow the test assembly to use our internal methods
[assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.Simulators" + SigningConstants.PUBLIC_KEY)]
