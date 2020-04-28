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
open System.IO
open System.Reflection


/// An entry point parameter.
type private Parameter =
    { Name : string
      QsharpType : ResolvedType
      CsharpTypeName : string
      Description : string }

/// The namespace in which to put generated code for the entry point.
let generatedNamespace entryPointNamespace = entryPointNamespace + ".__QsEntryPoint__"

/// The namespace containing the non-generated parts of the entry point driver.
let private nonGeneratedNamespace = "Microsoft.Quantum.QsCompiler.CsharpGeneration.EntryPointDriver"

/// A static class containing constants used by the entry point driver.
let private constantsClass =
    let property name typeName value =
        ``property-arrow_get`` typeName name [``public``; ``static``] ``get`` (``=>`` value)
    let constant name typeName value =
        ``field`` typeName name [``public``; ``const``] (``:=`` value |> Some)
    
    ``class`` "Constants" ``<<`` [] ``>>``
        ``:`` None ``,`` []
        [``internal``; ``static``]
        ``{``
            [property "SimulatorOptions" "System.Collections.Generic.IEnumerable<string>"
                (``new array`` (Some "") [``literal`` ("--" + fst CommandLineArguments.SimulatorOption)
                                          ``literal`` ("-" + snd CommandLineArguments.SimulatorOption)])
             constant "QuantumSimulator" "string" (``literal`` AssemblyConstants.QuantumSimulator)
             constant "ToffoliSimulator" "string" (``literal`` AssemblyConstants.ToffoliSimulator)
             constant "ResourcesEstimator" "string" (``literal`` AssemblyConstants.ResourcesEstimator)]
        ``}``

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
    let parsersIdent = ``ident`` (nonGeneratedNamespace + ".Parsers")
    valueParser qsType
    |> Option.map (fun valueParser ->
        parsersIdent <.> (``ident`` argParser, [parsersIdent <|.|> ``ident`` valueParser]))

/// Adds suggestions, if any, to the option based on the Q# type.
let private withSuggestions qsType option =
    let rec suggestions = function
        | ArrayType (itemType : ResolvedType) -> suggestions itemType.Resolution
        | Result -> ["Zero"; "One"]
        | _ -> []
    match suggestions qsType with
    | [] -> option
    | suggestions ->
        let args = option :: List.map ``literal`` suggestions
        ``invoke`` (``ident`` "System.CommandLine.OptionExtensions.WithSuggestions") ``(`` args ``)``

let private optionName (paramName : string) =
    let toKebabCaseIdent = ``ident`` "System.CommandLine.Parsing.StringExtensions.ToKebabCase"
    if paramName.Length = 1
    then ``literal`` ("-" + paramName)
    else ``literal`` "--" <+> ``invoke`` toKebabCaseIdent ``(`` [``literal`` paramName] ``)``

/// A property containing a sequence of command-line options corresponding to each parameter given.
let private parameterOptionsProperty parameters =
    let optionTypeName = "System.CommandLine.Option"
    let optionsEnumerableTypeName = sprintf "System.Collections.Generic.IEnumerable<%s>" optionTypeName
    let getOption { Name = name; QsharpType = qsType; CsharpTypeName = typeName; Description = desc } =
        let args =
            match argumentParser qsType.Resolution with
            | Some parser -> [optionName name; parser; upcast ``false``; ``literal`` desc]
            | None -> [optionName name; ``literal`` desc]

        ``new init`` (``type`` [sprintf "%s<%s>" optionTypeName typeName]) ``(`` args ``)``
            ``{``
                [``ident`` "Required" <-- ``true``]
            ``}``
        |> withSuggestions qsType.Resolution

    let options = parameters |> Seq.map getOption |> Seq.toList
    ``property-arrow_get`` optionsEnumerableTypeName "Options" [``public``]
        ``get`` (``=>`` (``new array`` (Some optionTypeName) options))

/// A method that creates an instance of the default simulator if it is a custom simulator.
let private customSimulatorFactory name =
    let expr : ExpressionSyntax =
        if name = AssemblyConstants.QuantumSimulator ||
           name = AssemblyConstants.ToffoliSimulator ||
           name = AssemblyConstants.ResourcesEstimator 
        then upcast SyntaxFactory.ThrowExpression (``new`` (``type`` "InvalidOperationException") ``(`` [] ``)``)
        else ``new`` (``type`` name) ``(`` [] ``)``
    ``arrow_method`` "IOperationFactory" "CreateDefaultCustomSimulator" ``<<`` [] ``>>``
        ``(`` [] ``)``
        [``public``]
        (Some (``=>`` expr))

/// The name of the parameter property for the given parameter name.
let private parameterPropertyName (s : string) = s.Substring(0, 1).ToUpper() + s.Substring 1

/// A sequence of properties corresponding to each parameter given.
let private parameterProperties =
    Seq.map (fun { Name = name; CsharpTypeName = typeName } ->
        ``prop`` typeName (parameterPropertyName name) [``public``])

/// The method for running the entry point using the parameter properties declared in the adapter.
let private runMethod context (entryPoint : QsCallable) =
    let entryPointName = sprintf "%s.%s" entryPoint.FullName.Namespace.Value entryPoint.FullName.Name.Value
    // TODO:
    // let returnTypeName = SimulationCode.roslynTypeName context entryPoint.Signature.ReturnType
    // let taskTypeName = sprintf "System.Threading.Tasks.Task<%s>" returnTypeName
    let taskTypeName = "System.Threading.Tasks.Task<object>"
    let factoryName = "__factory__"
    let parseResultName = "__parseResult__"
    let runParams = [
        ``param`` factoryName ``of`` (``type`` "IOperationFactory")
        ``param`` parseResultName ``of`` (``type`` "System.CommandLine.Parsing.ParseResult")
    ]
    let argExpr { Name = name; QsharpType = qsType; CsharpTypeName = typeName } =
        let valueForOption = ``ident`` (sprintf "ValueForOption<%s>" typeName)
        let value = ``ident`` parseResultName <.> (valueForOption, [optionName name])
        match qsType.Resolution with
        | ArrayType itemType ->
            let arrayTypeName = sprintf "QArray<%s>" (SimulationCode.roslynTypeName context itemType)
            ``new`` (``type`` arrayTypeName) ``(`` [value] ``)``
        | _ -> value
    let callArgs : ExpressionSyntax seq =
        Seq.concat [
            Seq.singleton (upcast ``ident`` factoryName)
            Seq.map argExpr (parameters context entryPoint.Documentation entryPoint.ArgumentTuple)
        ]

    ``arrow_method`` taskTypeName "Run" ``<<`` [] ``>>``
        ``(`` runParams ``)``
        [``public``; ``async``]
        (Some (``=>`` (``await`` (``ident`` entryPointName <.> (``ident`` "Run", callArgs)))))

/// The main method for the standalone executable.
let private mainMethod =
    let commandLineArgsName = "args"
    let runIdent = ``ident`` (nonGeneratedNamespace + ".Driver.Run")
    let runArgs = [``new`` (``type`` "EntryPoint") ``(`` [] ``)``; upcast ``ident`` commandLineArgsName]
    ``arrow_method`` "System.Threading.Tasks.Task<int>" "Main" ``<<`` [] ``>>``
        ``(`` [``param`` commandLineArgsName ``of`` (``type`` "string[]")] ``)``
        [``private``; ``static``; ``async``]
        (Some (``=>`` (``await`` (``invoke`` runIdent ``(`` runArgs ``)``))))

/// The class that adapts the entry point for use with the command-line parsing library and the driver.
let private adapterClass context (entryPoint : QsCallable) =
    let property name typeName value =
        ``property-arrow_get`` typeName name [``public``] ``get`` (``=>`` value)
        
    let summaryProperty =
        property "Summary" "string" (``literal`` ((PrintSummary entryPoint.Documentation false).Trim ()))
    let defaultSimulator =
        context.assemblyConstants.TryGetValue AssemblyConstants.DefaultSimulator
        |> snd
        |> (fun value -> if String.IsNullOrWhiteSpace value then AssemblyConstants.QuantumSimulator else value)
    let defaultSimulatorProperty = property "DefaultSimulator" "string" (``literal`` defaultSimulator)
    let parameters = parameters context entryPoint.Documentation entryPoint.ArgumentTuple
    let members : MemberDeclarationSyntax seq =
        Seq.concat [
            Seq.ofList [
                summaryProperty
                defaultSimulatorProperty
                parameterOptionsProperty parameters
                customSimulatorFactory defaultSimulator
                runMethod context entryPoint
                mainMethod
            ]
            parameterProperties parameters |> Seq.map (fun property -> upcast property)
        ]

    let baseName = simpleBase (nonGeneratedNamespace + ".IEntryPoint")
    ``class`` "EntryPoint" ``<<`` [] ``>>``
        ``:`` (Some baseName) ``,`` []
        [``internal``]
        ``{``
            members
        ``}``

/// The source code for the entry point constants and adapter classes.
let private generatedClasses context (entryPoint : QsCallable) =
    let ns =
        ``namespace`` (generatedNamespace entryPoint.FullName.Namespace.Value)
            ``{``
                (Seq.map ``using`` SimulationCode.autoNamespaces)
                [
                    constantsClass
                    adapterClass context entryPoint
                ]
            ``}``
    ``compilation unit`` [] [] [ns]
    |> ``with leading comments`` SimulationCode.autogenComment
    |> SimulationCode.formatSyntaxTree

/// The source code for the entry point driver.
let private driver () =
    let source fileName =
        let resourceName = "Microsoft.Quantum.CsharpGeneration." + fileName
        use stream = Assembly.GetExecutingAssembly().GetManifestResourceStream resourceName
        use reader = new StreamReader(stream)
        reader.ReadToEnd ()
    [
        "Driver.cs"
        "IEntryPoint.cs"
        "Parsers.cs"
        "Validation.cs"
    ]
    |> List.map (fun fileName -> Path.GetFileNameWithoutExtension fileName, source fileName)

/// Generates C# source code for a standalone executable that runs the Q# entry point.
let generate context entryPoint = ("EntryPoint", generatedClasses context entryPoint) :: driver ()
