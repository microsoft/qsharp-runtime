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

    let _AssemblyConstants = new Dictionary<_, _>()

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
                CompilationLoader.GeneratedFile(source, dir, ".g.cs", content) |> ignore
            for source in allSources |> Seq.filter (not << context.GenerateCodeForSource) do
                let content = SimulationCode.loadedViaTestNames source context
                if content <> null then CompilationLoader.GeneratedFile(source, dir, ".dll.g.cs", content) |> ignore

            if not compilation.EntryPoints.IsEmpty then

                let entryPointCallables =
                    compilation.EntryPoints
                    |> Seq.map (fun ep -> context.allCallables.[ep])

                let entryPointSources =
                    entryPointCallables
                    |> Seq.groupBy (fun ep -> ep.Source.CodeFile)

                let content = EntryPoint.generateMainSource context entryPointCallables
                let outputFolder = Path.GetFullPath(dir.TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar.ToString());
                let outputUri = Uri(outputFolder);
                let fileDir = Path.GetDirectoryName(outputUri.LocalPath);
                let targetFile = Path.GetFullPath(Path.Combine(fileDir, "EntryPoint.g.Main.cs"));
                if content <> null then
                    if not (Directory.Exists(fileDir)) then
                        Directory.CreateDirectory(fileDir) |> ignore;
                    File.WriteAllText(targetFile, content);

                for (sourceFile, callables) in entryPointSources do
                    let content = EntryPoint.generateSource context callables
                    CompilationLoader.GeneratedFile(sourceFile, dir, ".g.EntryPoint.cs", content) |> ignore

            transformed <- compilation
            true
