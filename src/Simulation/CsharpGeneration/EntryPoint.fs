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

/// The namespace in which to put generated code for the entry point.
let generatedNamespace entryPointNamespace = entryPointNamespace + ".__QsEntryPoint__"

/// The namespace containing the non-generated parts of the entry point driver.
let private nonGeneratedNamespace = "Microsoft.Quantum.CsharpGeneration.EntryPointDriver"

/// The name of the C# type used by the parameter in its command-line option, given its Q# type.
let rec private csharpParameterTypeName context (qsType : ResolvedType) =
    match qsType.Resolution with
    | ArrayType itemType -> sprintf "System.Collections.Generic.IEnumerable<%s>"
                                    (csharpParameterTypeName context itemType)
    | _ -> SimulationCode.roslynTypeName context qsType

/// A sequence of all of the named parameters in the argument tuple and their respective C# and Q# types.
let rec private parameters context doc = function
    | QsTupleItem variable ->
        match variable.VariableName with
        | ValidName name ->
            Seq.singleton { Name = name.Value
                            QsharpType = variable.Type
                            CsharpTypeName = csharpParameterTypeName context variable.Type
                            Description = ParameterDescription doc name.Value }
        | InvalidName -> Seq.empty
    | QsTuple items -> items |> Seq.map (parameters context doc) |> Seq.concat

/// The argument parser for the Q# type.
let private argumentParser qsType =
    let rec valueParser = function
        | ArrayType (itemType : ResolvedType) -> valueParser itemType.Resolution
        | BigInt -> Some "TryParseBigInteger"
        | Range -> Some "TryParseQRange"
        | Result -> Some "TryParseResult"
        | UnitType -> Some "TryParseQVoid"
        | _ -> None
    let argParser =
        match qsType with
        | ArrayType _ -> "ParseArgumentsWith"
        | _ -> "ParseArgumentWith"
    let parsersIdent = ident (nonGeneratedNamespace + ".Parsers")
    valueParser qsType
    |> Option.map (fun valueParser ->
        parsersIdent <.> (ident argParser, [parsersIdent <|.|> ident valueParser]))

/// Adds suggestions, if any, to the option based on the Q# type.
let private withSuggestions qsType option =
    let rec suggestions = function
        | ArrayType (itemType : ResolvedType) -> suggestions itemType.Resolution
        | Result -> ["Zero"; "One"]
        | _ -> []
    match suggestions qsType with
    | [] -> option
    | suggestions ->
        let args = option :: List.map literal suggestions
        invoke (ident "System.CommandLine.OptionExtensions.WithSuggestions") ``(`` args ``)``

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
    let getOption { Name = name; QsharpType = qsType; CsharpTypeName = typeName; Description = desc } =
        let args =
            match argumentParser qsType.Resolution with
            | Some parser -> [optionName name; parser; upcast ``false``; literal desc]
            | None -> [optionName name; literal desc]

        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` args ``)``
            ``{``
                [ident "Required" <-- ``true``]
            ``}``
        |> withSuggestions qsType.Resolution

    let options = parameters |> Seq.map getOption |> Seq.toList
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

/// The method for running the entry point using command-line arguments.
let private runMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let factoryName = "factory"
    let parseResultName = "parseResult"
    let runParams = [
        param factoryName ``of`` (``type`` "IOperationFactory")
        param parseResultName ``of`` (``type`` "System.CommandLine.Parsing.ParseResult")
    ]
    
    let argExpr { Name = name; QsharpType = qsType; CsharpTypeName = typeName } =
        let valueForOption = ident (sprintf "ValueForOption<%s>" typeName)
        let value = ident parseResultName <.> (valueForOption, [optionName name])
        match qsType.Resolution with
        | ArrayType itemType ->
            let arrayTypeName = sprintf "QArray<%s>" (SimulationCode.roslynTypeName context itemType)
            ``new`` (``type`` arrayTypeName) ``(`` [value] ``)``
        | _ -> value
        
    let callArgs : ExpressionSyntax seq =
        Seq.concat [
            Seq.singleton (upcast ident factoryName)
            Seq.map argExpr (parameters context entryPoint.Documentation entryPoint.ArgumentTuple)
        ]

    arrow_method taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` runParams ``)``
        [``public``; async]
        (Some (``=>`` (await (ident entryPointName <.> (ident "Run", callArgs)))))

/// The main method for the standalone executable.
let private mainMethod =
    let commandLineArgsName = "args"
    let runIdent = ident (nonGeneratedNamespace + ".Driver.Run")
    let runArgs = [``new`` (``type`` "EntryPoint") ``(`` [] ``)``; upcast ident commandLineArgsName]
    arrow_method "System.Threading.Tasks.Task<int>" "Main" ``<<`` [] ``>>``
        ``(`` [param commandLineArgsName ``of`` (``type`` "string[]")] ``)``
        [``private``; ``static``; async]
        (Some (``=>`` (await (invoke runIdent ``(`` runArgs ``)``))))

/// The class that adapts the entry point for use with the command-line parsing library and the driver.
let private entryPointClass context (entryPoint : QsCallable) =
    let property name typeName value =
        ``property-arrow_get`` typeName name [``public``] get (``=>`` value)
    let summaryProperty =
        property "Summary" "string" (literal ((PrintSummary entryPoint.Documentation false).Trim ()))
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
        runMethod context entryPoint
        mainMethod
    ]

    let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    let baseName = sprintf "%s.IEntryPoint<%s>" nonGeneratedNamespace returnTypeName
    ``class`` "EntryPoint" ``<<`` [] ``>>``
        ``:`` (Some (simpleBase baseName)) ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let generate context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` (generatedNamespace entryPoint.FullName.Namespace.Value)
            ``{``
                (Seq.map using SimulationCode.autoNamespaces)
                [entryPointClass context entryPoint]
            ``}``
    ``compilation unit`` [] [] [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree
