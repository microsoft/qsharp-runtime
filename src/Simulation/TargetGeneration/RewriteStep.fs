// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

namespace Microsoft.Quantum.QsCompiler.TargetGeneration

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

open GenerateTarget

type Emitter() =

    let _AssemblyConstants = new Dictionary<_, _>()
    let mutable _Diagnostics = []

    let TargetQualifiedClassKey = "TargetClass"
    let ExtendsTargetKey = "TargetToExtend"
    let CustomQubitMgmtKey = "CustomQubitManagement"
    let CustomDumpKey = "CustomStateDump"

    let DefaultNamespace = "Quantum.Simulator"

    let validateFQN (name : string) =
        (name |> String.IsNullOrWhiteSpace |> not) &&
        (name.Split '.' |> Seq.forall (fun s -> s.Length > 0 &&
                                                Char.IsLetter s.[0] &&
                                                s |> Seq.skip 1 |> Seq.forall Char.IsLetterOrDigit))
        
    let parseFQN (name : string) =
        let lastDot = name.LastIndexOf '.'
        if lastDot >= 0
        then name.Substring(0, lastDot), name.Substring(lastDot + 1)
        else DefaultNamespace, name

    interface IRewriteStep with

        member this.Name = "TargetGeneration"
        member this.Priority = -1 // doesn't matter because this rewrite step is the only one in the dll
        member this.AssemblyConstants = upcast _AssemblyConstants
        member this.GeneratedDiagnostics = upcast _Diagnostics
        
        member this.ImplementsPreconditionVerification = true
        member this.ImplementsPostconditionVerification = false
        member this.ImplementsTransformation = true

        /// The precondition is that the TargetQualifiedClassKey has to be present and has to be
        /// a valid class name, optionally fully-qualified, and that if the ExtendsTargetKey is
        /// present, it is also a valid class name, optionally fully-qualified.
        member this.PreconditionVerification _ = 
            let step = this :> IRewriteStep
            step.AssemblyConstants.ContainsKey(TargetQualifiedClassKey) &&
            validateFQN step.AssemblyConstants.[TargetQualifiedClassKey] &&
            match step.AssemblyConstants.TryGetValue ExtendsTargetKey with 
            | true, s -> validateFQN s 
            | false, _ -> true

        member this.PostconditionVerification _ = NotImplementedException() |> raise
        
        member this.Transformation (compilation, transformed) = 
            let step = this :> IRewriteStep
            let dir = step.AssemblyConstants.TryGetValue AssemblyConstants.OutputPath |> function
                | true, outputFolder when not (String.IsNullOrEmpty outputFolder) -> outputFolder
                | _ -> step.Name

            let targetNamespace, targetClassName = 
                step.AssemblyConstants.[TargetQualifiedClassKey] |> parseFQN
            let baseClassName = match step.AssemblyConstants.TryGetValue ExtendsTargetKey with 
                                | true, s -> Some s 
                                | false, _ -> None
            let outputFileName = Path.Combine(dir, targetClassName + ".cs")
            let generateCustomQubitMgmt = 
                match step.AssemblyConstants.TryGetValue CustomQubitMgmtKey with
                | true, "true" -> true
                | _ -> false
            let generateDump = 
                match step.AssemblyConstants.TryGetValue CustomDumpKey with
                | true, "true" -> true
                | _ -> baseClassName.IsNone

            let text = GenerateTarget compilation.Namespaces targetClassName targetNamespace 
                                        baseClassName generateCustomQubitMgmt generateDump
            File.WriteAllText(outputFileName, text)

            transformed <- compilation
            true
