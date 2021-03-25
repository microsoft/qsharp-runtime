// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.IO
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.CompilationBuilder
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


type Emitter() =

    let _AssemblyConstants = new Dictionary<_, _>()

    let _FileNamesGenerated = new HashSet<string>();

    member private this.WriteFile (fileId : string) outputFolder (fileEnding : string) content overwrite =
        let mutable fileEnding = fileEnding 
        let withOutEnding = Path.GetFileNameWithoutExtension(fileId)
        let mutable targetFile = Path.GetFullPath(Path.Combine(outputFolder, withOutEnding + fileEnding))

        if (not overwrite) && _FileNamesGenerated.Contains(targetFile) then
            let mutable enumeration = 1
            let pos = fileEnding.LastIndexOf('.')
            let (beforeEnumeration, afterEnumeration) =
                if pos = -1
                then "", fileEnding
                else fileEnding.Substring(0, pos), fileEnding.Substring(pos)
            while _FileNamesGenerated.Contains(targetFile) && enumeration < 100 do
                fileEnding <- beforeEnumeration + enumeration.ToString() + afterEnumeration
                targetFile <- Path.GetFullPath(Path.Combine(outputFolder, withOutEnding + fileEnding))
                enumeration <- enumeration + 1

        _FileNamesGenerated.Add targetFile |> ignore
        CompilationLoader.GeneratedFile(fileId, outputFolder, fileEnding, content) |> ignore


    interface IRewriteStep with

        member this.Name = "CSharpGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.AssemblyConstants = upcast _AssemblyConstants
        member this.GeneratedDiagnostics = Seq.empty

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

            let context = CodegenContext.Create (compilation, step.AssemblyConstants)
            let allSources = GetSourceFiles.Apply compilation.Namespaces

            for source in allSources |> Seq.filter context.GenerateCodeForSource do
                let content = SimulationCode.generate source context
                this.WriteFile source dir ".g.cs" content false
            for source in allSources |> Seq.filter (not << context.GenerateCodeForSource) do
                let content = SimulationCode.loadedViaTestNames source context
                this.WriteFile source dir ".dll.g.cs" content false

            if not compilation.EntryPoints.IsEmpty then

                let entryPointCallables =
                    compilation.EntryPoints
                    |> Seq.map (fun ep -> context.allCallables.[ep])

                let entryPointSources =
                    entryPointCallables
                    |> Seq.groupBy (fun ep -> ep.Source.CodeFile)

                let mainSourceFile = (dir, "EntryPoint") |> Path.Combine |> Path.GetFullPath |> Uri |> CompilationUnitManager.GetFileId
                let content = EntryPoint.generateMainSource context entryPointCallables
                this.WriteFile mainSourceFile dir ".g.Main.cs" content false

                for (sourceFile, callables) in entryPointSources do
                    let content = EntryPoint.generateSource context callables
                    this.WriteFile sourceFile dir ".g.EntryPoint.cs" content false

            transformed <- compilation
            true
