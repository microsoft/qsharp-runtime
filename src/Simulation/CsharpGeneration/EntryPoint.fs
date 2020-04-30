// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License.

module Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPoint

open Microsoft.CodeAnalysis.CSharp
open Microsoft.CodeAnalysis.CSharp.Syntax
open Microsoft.Quantum.QsCompiler.ReservedKeywords
open Microsoft.Quantum.QsCompiler.SyntaxProcessing.SyntaxExtensions
open Microsoft.Quantum.QsCompiler.SyntaxTokens
open Microsoft.Quantum.QsCompiler.SyntaxTree
open Microsoft.Quantum.RoslynWrapper
open System


/// An entry point parameter.
type private Parameter =
    { Name : string
      QsharpType : ResolvedType
      CsharpTypeName : string
      Description : string }

/// The name of the generated entry point class.
let entryPointClassName = "__QsEntryPoint__"

/// The namespace containing the non-generated parts of the entry point driver.
let private driverNamespace = "Microsoft.Quantum.CsharpGeneration.EntryPointDriver"

/// A sequence of all of the named parameters in the argument tuple and their respective C# and Q# types.
let rec private parameters context doc = function
    | QsTupleItem variable ->
        match variable.VariableName with
        | ValidName name ->
            Seq.singleton { Name = name.Value
                            QsharpType = variable.Type
                            CsharpTypeName = SimulationCode.roslynTypeName context variable.Type
                            Description = ParameterDescription doc name.Value }
        | InvalidName -> Seq.empty
    | QsTuple items -> items |> Seq.map (parameters context doc) |> Seq.concat

/// An expression representing the name of an entry point option given its parameter name.
let private optionName (paramName : string) =
    let toKebabCaseIdent = ident "System.CommandLine.Parsing.StringExtensions.ToKebabCase"
    if paramName.Length = 1
    then literal ("-" + paramName)
    else literal "--" <+> invoke toKebabCaseIdent ``(`` [literal paramName] ``)``

/// A property containing a sequence of command-line options corresponding to each parameter given.
let private parameterOptionsProperty parameters =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let option { Name = name; CsharpTypeName = typeName; Description = desc } =
        let createOption = ident (sprintf "%s.Options.CreateOption<%s>" driverNamespace typeName)
        let args = [optionName name; literal desc]
        invoke createOption ``(`` args ``)``
    let options = parameters |> Seq.map option |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``]
        get (``=>`` (``new array`` (Some optionTypeName) options))

/// A method that creates an instance of the default simulator if it is a custom simulator.
let private customSimulatorFactory name =
    let isCustomSimulator =
        not <| List.contains name [
            AssemblyConstants.QuantumSimulator
            AssemblyConstants.ToffoliSimulator
            AssemblyConstants.ResourcesEstimator
        ]
    let factory =
        if isCustomSimulator
        then ``new`` (``type`` name) ``(`` [] ``)``
        else upcast SyntaxFactory.ThrowExpression (``new`` (``type`` "InvalidOperationException") ``(`` [] ``)``)
        
    arrow_method "IOperationFactory" "CreateDefaultCustomSimulator" ``<<`` [] ``>>``
        ``(`` [] ``)``
        [``public``]
        (Some (``=>`` factory))

/// The method that creates the argument tuple for the entry point, given the command-line parsing result.
let private createArgument context (entryPoint : QsCallable) =
    let inTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ArgumentType
    let parseResultName = "parseResult"
    let valueForParam { Name = name; CsharpTypeName = typeName } =
        let valueForOption = ident (sprintf "ValueForOption<%s>" typeName)
        ident parseResultName <.> (valueForOption, [optionName name])
    // TODO: How are nested tuples handled?
    let values =
        parameters context entryPoint.Documentation entryPoint.ArgumentTuple
        |> Seq.map valueForParam
    let argTuple : ExpressionSyntax =
        if Seq.isEmpty values
        then ``type`` (SimulationCode.roslynTypeName context (ResolvedType.New UnitType)) <|.|> ident "Instance"
        else tuple (Seq.toList values)
    arrow_method inTypeName "CreateArgument" ``<<`` [] ``>>``
        ``(`` [param parseResultName ``of`` (``type`` "System.CommandLine.Parsing.ParseResult")] ``)``
        [``public``]
        (Some (``=>`` argTuple))

/// The main method for the standalone executable.
let private mainMethod context (entryPoint : QsCallable) =
    let _, callableTypeName = SimulationCode.findClassName context entryPoint
    let argTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ArgumentType
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let driverType = generic (driverNamespace + ".Driver") ``<<`` [callableTypeName; argTypeName; returnTypeName] ``>>``
    let entryPointInstance = ``new`` (``type`` entryPointClassName) ``(`` [] ``)``
    let driver = ``new`` driverType ``(`` [entryPointInstance] ``)``
    let commandLineArgsName = "args"
    arrow_method "System.Threading.Tasks.Task<int>" "Main" ``<<`` [] ``>>``
        ``(`` [param commandLineArgsName ``of`` (``type`` "string[]")] ``)``
        [``private``; ``static``; async]
        (Some (``=>`` (await (driver <.> (ident "Run", [ident commandLineArgsName])))))

/// The class that adapts the entry point for use with the command-line parsing library and the driver.
let private entryPointClass context (entryPoint : QsCallable) =
    let property name typeName value = ``property-arrow_get`` typeName name [``public``] get (``=>`` value)
    let summaryProperty = property "Summary" "string" (literal ((PrintSummary entryPoint.Documentation false).Trim ()))
    let defaultSimulator =
        context.assemblyConstants.TryGetValue AssemblyConstants.DefaultSimulator
        |> snd
        |> (fun value -> if String.IsNullOrWhiteSpace value then AssemblyConstants.QuantumSimulator else value)
    let defaultSimulatorProperty = property "DefaultSimulator" "string" (literal defaultSimulator)
    let parameters = parameters context entryPoint.Documentation entryPoint.ArgumentTuple
    let members : MemberDeclarationSyntax list = [
        summaryProperty
        defaultSimulatorProperty
        parameterOptionsProperty parameters
        customSimulatorFactory defaultSimulator
        createArgument context entryPoint
        mainMethod context entryPoint
    ]
    let inTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ArgumentType
    let baseName = sprintf "%s.IEntryPoint<%s>" driverNamespace inTypeName
    ``class`` entryPointClassName``<<`` [] ``>>``
        ``:`` (Some (simpleBase baseName)) ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let generate context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` entryPoint.FullName.Namespace.Value
            ``{``
                (Seq.map using SimulationCode.autoNamespaces)
                [entryPointClass context entryPoint]
            ``}``
    ``compilation unit`` [] [] [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree
