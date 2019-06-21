// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.RoslynWrapper

[<AutoOpen>]
module WhiteNoise =
    open Microsoft.CodeAnalysis
    open Microsoft.CodeAnalysis.CSharp
    open Microsoft.CodeAnalysis.CSharp.Syntax

    let ``:`` = None
    let ``,`` = None
    let ``}`` = None
    let ``{`` = None
    let ``<<`` = None
    let ``>>`` = None
    let ``(`` = None
    let ``)`` = None

    let ``of`` = None
    let ``get`` = None
    let ``set`` = None
    let ``in`` = None

    let ``private`` = SyntaxKind.PrivateKeyword
    let ``protected`` = SyntaxKind.ProtectedKeyword
    let ``internal`` = SyntaxKind.InternalKeyword
    let ``public`` = SyntaxKind.PublicKeyword
    let ``partial`` = SyntaxKind.PartialKeyword
    let ``abstract`` = SyntaxKind.AbstractKeyword
    let ``async`` = SyntaxKind.AsyncKeyword
    let ``virtual`` = SyntaxKind.VirtualKeyword
    let ``override`` = SyntaxKind.OverrideKeyword
    let ``static`` = SyntaxKind.StaticKeyword
    let ``readonly`` = SyntaxKind.ReadOnlyKeyword
