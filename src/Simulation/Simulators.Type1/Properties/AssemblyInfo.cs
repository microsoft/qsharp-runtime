// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// Allow the test assembly to use our internal methods
[assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.Simulators.Type1" + SigningConstants.PUBLIC_KEY)]