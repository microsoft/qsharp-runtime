// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.QsCompiler.CircuitTransformer.Tests

open System
open System.Collections.Generic
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.Diagnostics
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations

type Logger() =
    inherit LogTracker()
    override this.Print msg =
        Formatting.MsBuildFormat msg |> Console.WriteLine
    override this.OnException ex =
        Console.Error.WriteLine ex


let [<EntryPoint>] main args =
    let logger = new Logger()
    let loadOptions =
        new CompilationLoader.Configuration(
            GenerateFunctorSupport = true,
            DocumentationOutputFolder = "output\\"
        )

    // How do we not hard code these paths?
    let sources = List.toSeq [".\operation.qs"]
    let references = List.toSeq [ """D:\qsharp-hackathon\src\Simulation\Simulators\bin\Debug\netstandard2.0\Microsoft.Quantum.Intrinsic.dll""" ]
    let loaded = new CompilationLoader(sources, references, Nullable(loadOptions), logger)
    let syntaxTree = loaded.GeneratedSyntaxTree |> Seq.toArray
    let allSources = GetSourceFiles.Apply syntaxTree |> Seq.filter (fun fileName -> fileName.Value.EndsWith ".qs")
    for source in allSources do
        try
          let content = syntaxTree |> CircuitTransformer.basicWalk |> CircuitTransformer.generate source
          CompilationLoader.GeneratedFile(source, "output\\", ".g.cs", content) |> ignore
        with | ex -> logger.Log(ex)
    0