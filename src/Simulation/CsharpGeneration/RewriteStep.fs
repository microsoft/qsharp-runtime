// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.IO
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.CsharpGeneration;
open Microsoft.Quantum.QsCompiler.SyntaxTree;
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations;


type Emitter() =

    let mutable _OutputFolder = null

    interface IRewriteStep with

        member this.Name = "CsharpGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.OutputFolder
            with get () = _OutputFolder
            and set name = _OutputFolder <- name
        
        member this.ImplementsPreconditionVerification = false
        member this.ImplementsPostconditionVerification = false
        member this.ImplementsTransformation = true

        member this.PreconditionVerification _ = NotImplementedException() |> raise
        member this.PostconditionVerification _ = NotImplementedException() |> raise
        
        member this.Transformation (compilation, transformed) = 
            let step = this :> IRewriteStep
            let dir = if step.OutputFolder = null then step.Name else step.OutputFolder
            let allSources = 
                GetSourceFiles.Apply compilation.Namespaces 
                |> Seq.filter (fun fileName -> (fileName.Value |> Path.GetFileName).StartsWith "Microsoft.Quantum" |> not)
            for source in allSources do
                let content = compilation.Namespaces |> SimulationCode.generate source
                CompilationLoader.GeneratedFile(source, dir, ".g.cs", content) |> ignore
            transformed <- compilation
            true


