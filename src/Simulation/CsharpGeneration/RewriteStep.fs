// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.IO
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


type Emitter() =

    let _AssemblyConstants = new Dictionary<string, string>()

    interface IRewriteStep with

        member this.Name = "CsharpGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.AssemblyConstants = _AssemblyConstants :> IDictionary<string, string> 
        member this.GeneratedDiagnostics = null
        
        member this.ImplementsPreconditionVerification = false
        member this.ImplementsPostconditionVerification = false
        member this.ImplementsTransformation = true

        member this.PreconditionVerification _ = NotImplementedException() |> raise
        member this.PostconditionVerification _ = NotImplementedException() |> raise
        
        member this.Transformation (compilation, transformed) = 
            let step = this :> IRewriteStep
            let dir = step.AssemblyConstants.TryGetValue AssemblyConstants.OutputPath |> function
                | true, outputFolder when outputFolder <> null -> Path.Combine(outputFolder, "src")
                | _ -> step.Name
            let context = CodegenContext.Create (compilation.Namespaces, step.AssemblyConstants)

            let allSources = 
                GetSourceFiles.Apply compilation.Namespaces 
                |> Seq.filter (fun fileName -> not ((fileName.Value |> Path.GetFileName).EndsWith ".dll"))
            for source in allSources do
                let content = SimulationCode.generate source context
                CompilationLoader.GeneratedFile(source, dir, ".g.cs", content) |> ignore

            // TODO: Show diagnostic if there is more than one entry point.
            match Seq.tryExactlyOne compilation.EntryPoints with
            | Some entryPoint ->
                let callable = context.allCallables.[entryPoint]
                let content = EntryPoint.generate context callable
                CompilationLoader.GeneratedFile(callable.SourceFile, dir, ".EntryPoint.g.cs", content) |> ignore
            | None -> ()

            transformed <- compilation
            true
