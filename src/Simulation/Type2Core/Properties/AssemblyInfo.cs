// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;

// Allow the test assembly to use our internal methods
[assembly: InternalsVisibleTo("Microsoft.Quantum.Simulators.Type2" + SigningConstants.PUBLIC_KEY)]