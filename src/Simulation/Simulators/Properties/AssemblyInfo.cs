// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Runtime.CompilerServices;

// Allow the test assembly to use our internal methods
[assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.Simulators" + SigningConstants.PUBLIC_KEY)]