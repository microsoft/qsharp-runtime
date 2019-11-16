// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace QsCompiler.AssemblyInfo

open System.Runtime.CompilerServices

[<assembly: InternalsVisibleTo("Microsoft.Quantum.CsharpGeneration.App" + SigningConstants.PUBLIC_KEY)>]
[<assembly: InternalsVisibleTo("Tests.Microsoft.Quantum.CsharpGeneration" + SigningConstants.PUBLIC_KEY)>]

do ()