// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.CsharpGeneration

open System
open System.Collections.Generic
open System.IO
open System.Linq
open Microsoft.Quantum.QsCompiler
open Microsoft.Quantum.QsCompiler.CsharpGeneration
open Microsoft.Quantum.QsCompiler.DataTypes
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.QsCompiler.Transformations.BasicTransformations


type Emitter() =

    let _AssemblyConstants = new Dictionary<string, string>()

    static member internal IsTestProject = "CsharpGeneration/TestProject"

    interface IRewriteStep with

        member this.Name = "CsharpGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.AssemblyConstants = _AssemblyConstants :> IDictionary<string, string> 
        
        member this.ImplementsPreconditionVerification = false
        member this.ImplementsPostconditionVerification = false
        member this.ImplementsTransformation = true

        member this.PreconditionVerification _ = NotImplementedException() |> raise
        member this.PostconditionVerification _ = NotImplementedException() |> raise
        
        member this.Transformation (compilation, transformed) = 
            let step = this :> IRewriteStep
            let dir = step.AssemblyConstants.TryGetValue AssemblyConstants.OutputPath |> function
                | true, outputFolder when outputFolder <> null -> outputFolder
                | _ -> step.Name
            let isTestProject = step.AssemblyConstants.TryGetValue Emitter.IsTestProject |> function
                | true, value -> value <> null && value.ToLowerInvariant() = "true"
                | _ -> false
            let context = CodegenContext.Create (compilation.Namespaces, step.AssemblyConstants, isTestProject)

            let allSources = 
                GetSourceFiles.Apply compilation.Namespaces 
                |> Seq.filter (fun fileName -> (fileName.Value |> Path.GetFileName).StartsWith "Microsoft.Quantum" |> not)
            for source in allSources do
                let content = SimulationCode.generate source context
                CompilationLoader.GeneratedFile(source, dir, ".g.cs", content) |> ignore
            if context.unitTests.Any() then 
                let unitTestSetup = SimulationCode.generateUnitTestClasses context
                let fileName = "UnitTestsClassConstructors.cs" |>  Path.GetFullPath |> NonNullable<string>.New
                CompilationLoader.GeneratedFile(fileName, dir, ".g.cs", unitTestSetup) |> ignore
            transformed <- compilation
            true


