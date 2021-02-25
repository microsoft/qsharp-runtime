// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.IO
open Microsoft.CodeAnalysis
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.Quantum.QsCompiler.Diagnostics
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


type Emitter() =

    let _AssemblyConstants = new Dictionary<_, _>()
    let mutable _Diagnostics = []

    interface IRewriteStep with

        member this.Name = "CSharpGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.AssemblyConstants = upcast _AssemblyConstants
        member this.GeneratedDiagnostics = upcast _Diagnostics
        
        member this.ImplementsPreconditionVerification = true
        member this.ImplementsPostconditionVerification = false
        member this.ImplementsTransformation = true

        member this.PreconditionVerification compilation =
            if compilation.EntryPoints.Length > 1 then
                _Diagnostics <- IRewriteStep.Diagnostic
                    (Message = DiagnosticItem.Message (ErrorCode.MultipleEntryPoints, []),
                     Severity = DiagnosticSeverity.Error,
                     Stage = IRewriteStep.Stage.PreconditionVerification) :: _Diagnostics
                false
            else
                true

        member this.PostconditionVerification _ = NotImplementedException() |> raise
        
        member this.Transformation (compilation, transformed) = 
            let step = this :> IRewriteStep
            let dir = step.AssemblyConstants.TryGetValue AssemblyConstants.OutputPath |> function
                | true, outputFolder when outputFolder <> null -> Path.Combine(outputFolder, "src")
                | _ -> step.Name

            let context = CodegenContext.Create (compilation, step.AssemblyConstants)
            let allSources = GetSourceFiles.Apply compilation.Namespaces 

            for source in allSources |> Seq.filter context.GenerateCodeForSource do
                let content = SimulationCode.generate source context
                CompilationLoader.GeneratedFile(source, dir, ".g.cs", content) |> ignore
            for source in allSources |> Seq.filter (not << context.GenerateCodeForSource) do
                let content = SimulationCode.loadedViaTestNames source context
                if content <> null then CompilationLoader.GeneratedFile(source, dir, ".dll.g.cs", content) |> ignore

            if not compilation.EntryPoints.IsEmpty then

                let entryPointCallables =
                    compilation.EntryPoints
                    |> Seq.map (fun ep -> context.allCallables.[ep])

                let main = EntryPoint.mainNamespace entryPointCallables

                let entryPointSources =
                    entryPointCallables
                    |> Seq.groupBy (fun ep -> ep.Source.CodeFile)

                let (sourceFile, callables) = Seq.head entryPointSources
                let content = EntryPoint.generateSource context callables (Some main)
                CompilationLoader.GeneratedFile(sourceFile, dir, ".EntryPoint.g.cs", content) |> ignore

                for (sourceFile, callables) in Seq.tail entryPointSources do
                    let content = EntryPoint.generateSource context callables None
                    CompilationLoader.GeneratedFile(sourceFile, dir, ".EntryPoint.g.cs", content) |> ignore

            transformed <- compilation
            true
